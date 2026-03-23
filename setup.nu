#!/usr/bin/env nu

use std/log
use std/util "path add"

export-env {
  $env.DOT_DIR = ($env.HOME | path join ".local/share/fedora-nix-niri-config")
  $env.LOG_FILE = ($env.HOME | path join ".fedora-nix-niri-config.log")
}

export def init-log-file [] {
  if ($env.LOG_FILE | path exists) {
    if (has-cmd trash) { ^trash $env.LOG_FILE } else { rm $env.LOG_FILE }
  }

  touch $env.LOG_FILE
}

export def log-to-file [level: string, msg: string] {
  $"[($level)] ($msg)\n" | save --append $env.LOG_FILE
}

export def log+ [msg: string] { log info $msg; log-to-file "INFO" $msg }
export def warn+ [msg: string] { log warning $msg; log-to-file "WARNING" $msg }
export def error+ [msg: string] { log error $msg; log-to-file "ERROR" $msg }

export def die [msg: string] {
  log critical $msg
  log-to-file "CRITICAL" $msg
  error make {
    msg: $msg
    label: { text: "fatal error", span: (metadata $msg).span }
  }
}

export def ensure-parent-dir [path: string] {
  let parent = ($path | path dirname)
  if not (dir-exists $parent) {
    mkdir $parent
  }
}

export def has-cmd [cmd: string]: nothing -> bool {
  (which $cmd | is-not-empty)
}

export def dir-exists [path: string]: nothing -> bool {
  ($path | path exists) and ($path | path type) == "dir"
}

export def is-fedora []: nothing -> bool {
  if not ("/etc/redhat-release" | path exists) { return false }
  let content = (open /etc/redhat-release | str downcase)
  $content =~ "fedora"
}

export def sln [src: string, dst: string] {
  if not (($src | path exists) and (($src | path type) != "dir")) {
    error+ $"($src) does not exist. Skipping linking."
    return
  }

  if ($dst | path exists) {
    if (has-cmd trash) { ^trash $dst } else { rm -f $dst }
  }

  ^ln -s $src $dst
}

export def stow-package [package: string] {
  let root = (($env.DOT_DIR | path join $package) | path expand)

  for $f in (glob $"($root)/**/*" --no-dir) {
    let src = ($f | path expand)
    let rel = ($src | path relative-to $root)
    let dst = ($env.HOME | path join ".config" $package $rel)
    ensure-parent-dir $dst
    sln $src $dst
  }
}

export def group-add [group: string] {
  let groups_output = (^getent group | lines)
  let group_names = ($groups_output | parse "{name}:x:{gid}:{members}" | get name)

  if $group in $group_names {
    do -i { ^sudo usermod -aG $group $env.USER }
  } else {
    warn+ $"($group) group not found, skipping"
  }
}

export def si [packages: list<string>]: nothing -> bool {
  log+ $"Installing ($packages | str join ' ')"
  do -i { ^sudo dnf install -y ...$packages }
}

export def keep-sudo-alive []: nothing -> int {
  ^sudo -v
  job spawn {
    loop {
      ^sudo -n true
      sleep 55sec
    }
  }
}

export def stop-sudo-alive [job_id: int] {
  do -i {
    job kill $job_id
    ^sudo -k
  }
}

export def --env bootstrap [] {
  init-log-file

  path add "/nix/var/nix/profiles/default/bin"

  for p in [
    "bin"
    ".pixi/bin"
    ".local/bin"
    ".cargo/bin"
    $"($env.DOT_DIR)/nu"
  ] {
    path add ($env.HOME | path join $p | path expand)
  }
}

export def touch-files [dir: string, files: list<string>] {
  do -i { mkdir $dir }

  for f in $files {
    let file_path = ($dir | path join $f)
    if not ($file_path | path exists) {
      touch $file_path
    }
  }
}

def "main nix" [] {
  if (has-cmd nix) {
    log+ "nix is already installed"
    return
  }

  log+ "Installing nix..."
  http get https://install.determinate.systems/nix | ^sh -s -- install --determinate --no-confirm
}

def "main home-manager" [] {
  if not (has-cmd nix) {
    main nix
  }

  log+ "Setting up home-manager"
  let flake_path = ($env.DOT_DIR | path join "home-manager")
  ^nix run home-manager -- switch --flake $"($flake_path)#($env.USER)" --impure -b backup
}

def "main system" [] {
  log+ "Installing system packages..."
  si [
    "fish"
    "gcc"
    "git"
    "libatomic"
    "make"
    "plocate"
    "tar"
    "unzip"
    "zstd"
  ]
  do -i { ^sudo updatedb }
}

def "main fish config" [] {
  log+ "setting up fish..."
  stow-package "fish"

  log+ "Change default shell to fish"
  do -i { ^chsh -s (which fish) }
}

def "main fish" [] {
  si ["fish"]
  main fish config
}

def "main bun" [] {
  if (has-cmd bun) {
    log+ "bun already installed. Skipping."
    return
  }

  log+ "Installing bun..."
  curl -fsSL https://bun.com/install | bash
}

def "main uv" [] {
  if not (has-cmd uv) {
    log+ "Installing uv..."
    (http get https://astral.sh/uv/install.sh) | ^bash
  }

  if not (has-cmd pipx) {
    log+ "Installing pipx with uv..."
    ^uv tool install pipx
  }
}

def "main shell" [] {
  if not (is-fedora) {
    die "Only Fedora supported. Quitting."
  }

  init-log-file
  bootstrap

  main system
  main home-manager
  main uv
  main bun
}

def "main stow" [package: string] {
  stow-package $package
}

def wm-install [] {
  log+ "Installing window manager packages..."
  si [
    "adw-gtk3-theme"
    "cups-pk-helper"
    "grim"
    "gvfs"
    "gvfs-fuse"
    "gvfs-smb"
    "imv"
    "kitty"
    "libsecret"
    "mate-polkit"
    "mpv"
    "nautilus"
    "pipewire"
    "pipewire-pulse"
    "pipewire-pulseaudio"
    "qt5ct"
    "qt6ct"
    "slurp"
    "udiskie"
    "udisks2"
    "wireplumber"
    "wl-clipboard"
    "xdg-desktop-portal-gnome"
    "xdg-desktop-portal-gtk"
    "xdg-desktop-portal-wlr"
  ]

  if not (has-cmd pipx) {
    main uv
  }

  log+ "Installing pywal packages"
  ^pipx install pywal
  ^pipx install pywalfox

  let pictures = ($env.HOME | path join "Pictures")
  do -i { mkdir $"($pictures)/Screenshots" }
  do -i { mkdir $"($pictures)/Wallpapers" }

  stow-package "kitty"
  stow-package "xdg-desktop-portal"
}

def "main niri install" [] {
  wm-install

  if (has-cmd dms) and (has-cmd niri) {
    log+ "niri and dms are already installed"
    return
  }

  log+ "Installing niri and dms..."
  ^sudo dnf copr enable avengemedia/dms
  si ["niri" "dms" "cliphist"]
}

def "main niri config" [] {
  log+ "Setting up niri config..."
  stow-package "niri"

  let niri_dms = ($env.HOME | path join ".config/niri/dms")
  touch-files $niri_dms ["alttab.kdl" "colors.kdl" "layout.kdl" "wpblur.kdl" "binds.kdl" "cursor.kdl" "outputs.kdl"]

  do -i { ^systemctl --user add-wants niri.service dms }
}

def "main niri" [] {
  main niri install
  main niri config
}

def "main flatpaks" [] {
  if not (has-cmd flatpak) {
    si ["flatpak"]
  }

  log+ "Adding flathub remote..."
  ^flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo --user

  let flatpaks = [
    "com.github.tchx84.Flatseal"
    "md.obsidian.Obsidian"
    "org.gnome.Firmware"
    "org.gnome.Papers"
  ]

  for pkg in $flatpaks {
    log+ $"Installing ($pkg)"
    do -i { ^flatpak --user install -y flathub $pkg }
  }
}

def "main virt config" [] {
  log+ "Setting up libvirt..."

  for group in ["libvirt" "qemu" "libvirt-qemu" "kvm" "libvirtd"] {
    do -i { ^sudo usermod -aG $group $env.USER }
  }

  do -i { ^sudo systemctl enable --now libvirtd }
  do -i { ^sudo virsh net-autostart default }

  if (has-cmd authselect) {
    do -i { ^sudo authselect enable-feature with-libvirt }
  }
}

def "main virt install" [] {
  log+ "Installing virt-manager..."

  si [
    "dnsmasq"
    "libvirt"
    "libvirt-nss"
    "qemu-img"
    "qemu-tools"
    "swtpm"
    "virt-install"
    "virt-manager"
    "virt-viewer"
  ]
}

def "main virt" [] {
  main virt install
  main virt config
}

def "main desktop" [] {
  log+ "Installing desktop packages..."
  si [
    "distrobox"
    "flatpak"
    "gnome-keyring"
  ]

  main virt
  main flatpaks
  main niri
}

def "main help" [] {
  print "Usage:"
  print "  setup.nu"
  print "  setup.nu help"
  print "  setup.nu <command>"
  print ""
  print "Running without a command performs the full setup:"
  print "  update -> shell -> desktop"
  print ""
  print "Commands:"
  print "  help             Show this help message"
  print "  update           Update system packages with dnf"
  print "  shell            Run shell setup (system, home-manager, uv, bun)"
  print "  desktop          Run desktop setup (virt, flatpaks, niri)"
  print ""
  print "  nix              Install nix package manager"
  print "  home-manager     Apply the home-manager flake"
  print "  system           Install base Fedora packages"
  print "  fish             Install fish and apply fish config"
  print "  fish config      Apply fish config only"
  print "  bun              Install bun"
  print "  uv               Install uv and pipx"
  print ""
  print "  virt             Install and configure virt-manager/libvirt"
  print "  virt install     Install virt packages only"
  print "  virt config      Configure libvirt only"
  print "  niri             Install and configure niri WM"
  print "  niri install     Install niri, dms, and related packages"
  print "  niri config      Apply niri config only"
  print "  flatpaks         Install flatpak applications"
  print "  stow <package>   Symlink a config package into ~/.config"
  print ""
}

def "main update" [] {
  log+ "Updating packages..."
  ^sudo dnf update -y
}

def main [] {
  let job_id = keep-sudo-alive
  bootstrap
  main update
  main shell
  main desktop
  stop-sudo-alive $job_id
}

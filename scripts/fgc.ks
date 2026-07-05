# Kickstart file for Fedora Everything ISO install
# Generated from scripts/fgc - includes all DNF packages referenced
#
# Usage:
#   Place this file on a USB or serve via HTTP, then at the boot menu of the
#   Fedora Everything ISO, press Tab and append:
#     inst.ks=hd:LABEL=<USB_LABEL>:/fgc.ks
#   or:
#     inst.ks=http://example.com/fgc.ks

text

lang en_US.UTF-8
keyboard us
timezone Asia/Kolkata
selinux --enforcing
firewall --enabled --service=ssh
services --enabled=sshd,gdm
network --hostname=fgc
firstboot --enable
reboot --eject

skipx

%packages --ignoremissing
# # Base system
# @standard
# @base-x
# @gnome
@^gnome-desktop-environment
@base
@core
@workstation-product
@development-tools
@virtualization

bat
difftastic
duf
eza
fd
fish
fzf
gdu
gh
htop
jq
micro
rclone
ripgrep
rsync
shellcheck
tealdeer
tmux
trash-cli
ugrep
yq
zoxide
git
which
curl
wget
tar
gcc
less
libatomic
make
pipx
plocate
zip
unzip
zstd

cascadia-code-nf-fonts
cascadia-mono-nf-fonts
papers
imv
mpv
google-noto-color-emoji-fonts
gvfs-nfs
gvfs-smb
nautilus
udiskie
udisks2
xdg-utils

# From gnome_flatpaks
flatpak

# Extra useful packages
openssh-clients
openssh-server
sudo

%end

%post --erroronfail

# Enable flathub
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo --user

# Install flatpak packages from gnome_flatpaks
flatpak --user install -y flathub \
  com.github.tchx84.Flatseal \
  com.mattjakeman.ExtensionManager \
  org.gtk.Gtk3theme.adw-gtk3 \
  org.gtk.Gtk3theme.adw-gtk3-dark \
  io.github.swordpuffin.rewaita 2>/dev/null || true

# Install gnome-extensions-cli via pipx
pipx install gnome-extensions-cli --system-site-packages 2>/dev/null || true

# Enable GDM graphical target
systemctl set-default graphical.target
systemctl enable gdm

echo "Kickstart installation complete. Reboot to continue."
echo "After reboot, run: ~/.fgc/scripts/fgc shell"
echo "Then optionally: ~/.fgc/scripts/fgc gnome"
echo "Then optionally: ~/.fgc/scripts/fgc dev"
echo "Then optionally: ~/.fgc/scripts/fgc zed / vscode"

%end

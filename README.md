# Fedora Config

## Bootstrap

First, update your system and reboot your computer. This will save a lot of time, when executing the following scripts.

On Fedora Workstation

```sh
sudo dnf update -y --refresh
```

On Bluefin

```sh
ujust update
```

On Silverblue

```sh
sudo rpm-ostree upgrade
```

Then run the following bootstrap script

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/pervezfunctor/fgc/main/scripts/fgc)"
```

This script clones this repo to `~/.fgc`, and add a single line to your ~/.bashrc to put all scripts on PATH.

## Shell

Restart your terminal and execute the following script. This install shell tools and sets up fish as default.

```sh
fgc shell
```

Reboot your computer and open terminal. You should be in fish shell. On atomic fedora(silverblue/bluefin) use `ptyxis` terminal.

On non atomic fedora, use the following command to check your shell.

```sh
echo $SHELL
```

If fish shell is not the default, use the following command.

```sh
chsh -s $(command -v fish)
```

## Development Tools

Install node(vite+), Rust(rustup), Python(uv) tools.

```sh
fgc dev
```

Install and setup your preferred editor,

For zed editor

```sh
fgc zed
```

For

```sh
fgc vscode
```

## Gnome setup

To setup gnome almost like niri, and use scrolling layout(paperwm), use the following script

```sh
fgc gnome
```

Some important keybindings

- Open Terminal - Super+Return
- Pick Predefined Size - Super+R (This is super important)
- Center Window - Super+C (Super important)
- Close Window - Super+Q
- Switch Focus - Super+<Arrow Key>
- Move Window - Super+Shift+<Arrow Key>
- Switch Workspace - Super+Page_Up/Page_Down
- Move Window to Workspace - Super+Shift+Page_Up/Page_Down

## Virtual Machines

incus supports simple cloud-init based virtual machines that are great for development.

Install and setup incus with

```sh
vm install
```

Reboot your computer. Then execute the following.

```sh
vm install post
```

Create a Debian VM with

```sh
vm debian         # one of debian, fedora, ubuntu, tumbleweed and arch
```

Wait for a few minutes(for cloud-init to finish), list all VMs, confirm they have IPv4 address assigned and SSH into the one you just created.

```sh
vm list
vm ssh <name> # or ssh "$USER"@<ip-address>
```

For additional commands

```sh
vm help
```

If you prefer `virt-manager` for installing desktop linux distributions, install libvirt with

```sh
fgc libvirt
```

This installs the `@virtualization` group (libvirt, qemu-kvm, virt-manager, virt-viewer), adds your user to the `libvirt` group (passwordless `qemu:///system` via polkit), enables `libvirtd`, and starts the `default` NAT network. Reboot your computer afterwards.

To run VMs as LAN peers (getting an IP directly from your router), also set up a host bridge. This enslaves your primary ethernet (e.g. `enp4s0`) under a `br0` bridge and moves the host IP onto it — your network will drop briefly during the switch.

```sh
sudo nmcli connection add type bridge ifname br0 con-name br0
sudo nmcli connection add type bridge-slave ifname enp4s0 master br0
sudo nmcli connection up br0
```

To revert the bridge: `sudo nmcli connection delete br0 && sudo nmcli connection up "Wired connection 1"` (use your original connection name).

Bluefin dx already includes `virt-manager`.

### Debian cloud VM (bridged)

`debian-libvirt-vm` creates a Debian 13 (trixie) VM on `qemu:///system`, bridged to the LAN, using virt-install + cloud-init + the Debian cloud image (UEFI, serial console). Disks are libvirt-managed volumes (correct `qemu:qemu` ownership and SELinux labels). Requires `fgc libvirt`, a host bridge named `br0`, then a reboot. The `default` storage pool is created automatically on first run.

```sh
debian-libvirt-vm create                              # defaults: name=debian, 2 vcpu, 2G, 20G
debian-libvirt-vm create --name build --cpus 4        # custom
debian-libvirt-vm create --name big --memory 8192 --disk 50
debian-libvirt-vm ssh debian                          # ssh in (uses the router-assigned IP)
debian-libvirt-vm list
debian-libvirt-vm destroy debian
```

## Bluefin

No need to use scripts from this repository. Use the following instead.

First switch to devmode

```sh
ujust devmode
```

Restart computer and setup dev groups.

```sh
ujust dx-group
```

Restart your computer again. You should have `incus`, `libvirt` and `vscode` installed.

You could setup your shell with

```sh
ujust bluefin-cli
```

bootstrap script should work with `Bluefin` too. You will have access to most scripts after bootstrap.

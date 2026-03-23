# Fedora Nix Niri Config

## Bootstrap

Run the bootstrap script:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/pervezfunctor/fedora-nix-niri-config/main/setup)"
```

The bootstrap script clones the repo to `~/.local/share/fedora-nix-niri-config`, installs nix and configures shell.

## Nushell setup commands

After the repo is available locally, run the Nushell entrypoint directly:

```bash
setup.nu
```

Available commands include:

```bash
nu setup.nu shell
nu setup.nu niri
nu setup.nu flatpaks
nu setup.nu virt
nu setup.nu update
nu setup.nu help
```

## Dotfile layout

`setup.nu stow` is intentionally simple.

- Pass a package name like `kitty`, or `niri`
- The package is resolved from `$DOT_DIR/<package>`
- Files are linked into `~/.config/<package>/...`

Example:

```bash
nu setup.nu stow niri
```

This links files from `$DOT_DIR/niri` into `~/.config/niri`.

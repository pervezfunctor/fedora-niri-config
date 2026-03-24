# Fedora Niri Config

## Bootstrap

Run the bootstrap script:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/pervezfunctor/fedora-niri-config/main/setup)"
```

The bootstrap script clones the repo to `~/.local/share/fedora-niri-config`, installs pixi and configures shell.

## Nushell setup commands

After the repo is available locally, run the Nushell entrypoint directly:

```bash
setup.nu
```

Available commands include:

```bash
nu setup.nu help
nu setup.nu niri
nu setup.nu flatpaks
nu setup.nu virt
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

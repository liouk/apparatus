# :gear: apparatus

Dotfiles and setup automation, managed with [GNU Stow](https://www.gnu.org/software/stow/).

Originally forked from [michailpanagiotis/apparatus](https://github.com/michailpanagiotis/apparatus) :heart:

## Structure

```
platforms/<os>/          # per-platform config (packages, stow targets, repos, links)
<package>/               # stow packages (zsh, git, kitty, sway, etc.)
install.sh               # generic driver script
```

## Usage

```bash
# check if current OS is supported
./install.sh --check-support

# full install (packages + repos + links + stow)
./install.sh

# restow dotfiles only
./install.sh --stow-only

# unstow dotfiles
./install.sh --unstow-only
```

## Adding a new platform

Create `platforms/<os-id>/` (where `<os-id>` matches the `ID` field in `/etc/os-release`) with:

- `config` — `APPARATUS_DIR`, `PKG_CMD`, `PKG_PER_LINE` declarations
- `packages.<N>.<manager>` — one package per line, installed in sort order
- `stow-targets` — `TARGET:package` per line
- `repos` (optional) — `target_dir git_url` per line
- `links` (optional) — `link_name:target_path` per line
- `pre-install.sh` / `post-install.sh` (optional) — run before/after package install

## Theme

[Catppuccin Mocha](https://github.com/catppuccin/catppuccin), applied in kitty, neovim, sway, waybar, mako, tig, and swaylock.

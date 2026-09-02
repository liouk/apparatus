# :gear: apparatus

Dotfiles and setup automation, managed with [GNU Stow](https://www.gnu.org/software/stow/).

Originally forked from [michailpanagiotis/apparatus](https://github.com/michailpanagiotis/apparatus) :heart:

## Structure

```
platforms/<os>/          # per-platform config (packages, stow targets, repos, links)
<package>/               # stow packages (zsh, git, kitty, sway, etc.)
bootstrap.sh             # clones the repo, then invokes install.sh
install.sh               # repo-local installation driver
```

## Usage

Apparatus requires Bash 4 or newer. On macOS, install Homebrew if necessary, then install a current Bash:

```bash
brew install bash
```

To bootstrap a new machine:

```bash
curl -fsSL https://raw.githubusercontent.com/liouk/apparatus/master/bootstrap.sh | sh
```

From an existing checkout:

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

Additional machine- or work-specific shell files can be linked into `~/.zsh/conf.d/`. Files ending in `.zsh` or `.sh` are sourced in filename order.

## Adding a new platform

Create `platforms/<os-id>/` (where `<os-id>` matches the `ID` field in `/etc/os-release`) with:

- `config` — an `install_<manager>_packages` function for each package manager
- `packages.<N>.<manager>` — one package per line, installed in sort order
- `stow-targets` — `TARGET:package` per line
- `repos` (optional) — `target_dir git_url` per line
- `links` (optional) — `link_name:target_path` per line
- `pre-install.sh` / `post-install.sh` (optional) — run before/after package install

## Theme

[Catppuccin Mocha](https://github.com/catppuccin/catppuccin), applied in kitty, neovim, sway, waybar, mako, tig, and swaylock.

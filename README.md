# :gear: apparatus

Dotfiles and setup automation, managed with [GNU Stow](https://www.gnu.org/software/stow/).

Originally forked from [michailpanagiotis/apparatus](https://github.com/michailpanagiotis/apparatus) :heart:

## Structure

```
platforms/<os>/          # per-platform config (packages, stow targets, repos, links)
platforms/<os>/zsh.zsh   # platform-specific shell settings
platforms/<os>/stow/     # platform-local Stow packages
<package>/               # stow packages (zsh, git, foot, sway, etc.)
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

Keep platform customizations under `platforms/<os>/`. The shared Zsh config resolves its Stow symlink to load `platforms/<os>/zsh.zsh` from the checkout.

## Fedora

The `fedora` platform targets a regular, DNF-based Fedora installation, including a managed CSB with permission to install packages. Fedora Atomic is not supported by the full installer. Install Git first if needed (`sudo dnf install git`), and configure GitHub SSH access for the personal repositories before running the bootstrap or `./install.sh`.

On Fedora, the bootstrap defaults to `~/liouk/apparatus`, alongside `~/liouk/toolshed`. The `zap` shell alias and Sway apparatus shortcut use this location. Arch and macOS retain their existing paths.

The package list covers Apparatus tools, not base-system provisioning. Standard utilities (including SSH and curl), a working build toolchain, and graphics drivers are assumed to come from the CSB. DNF still installs dependencies required by the listed tools.

- Reuses the shared dotfiles, including Foot, Sway, Waybar, Mako, Neovim and Zed. Fedora-only Sway session helpers are in `platforms/fedora/stow/sway/`.
- Uses Fedora packages for the desktop and CLI tools. Keeps the existing desktop/login manager and audio stack; only installs PulseAudio-compatible client tools (`pulseaudio-utils`, `pavucontrol`), not an audio server.
- Installs the NetBird CLI/daemon using its [signed upstream RPM repository](https://docs.netbird.io/get-started/install/linux). Existing NetBird installations or `netbird.repo` files are preserved. Unlike personal helper tools, this is a system package; no GUI or automatic VPN enrollment is configured. OpenVPN is not installed by this platform.
- Uses Fuzzel on `$mod+Space` instead of sway-launcher-desktop, with Fedora-local configuration in `platforms/fedora/stow/fuzzel/`. Tig is unchanged.
- Clones Powerlevel10k from upstream. Installs [Zed stable](https://zed.dev/docs/linux) and [latest stable kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/) only if missing, preserving existing installations. Adds a `zeditor` compatibility link when needed. Kubectl downloads are SHA-256 checked.
- Installs Go helpers and `yamlfmt`, plus the same Nerd Font symbols release as Arch. No AUR/COPR setup or `fzfpac` link is added.
- Installs [Ankit Pokhrel's JiraCLI](https://github.com/ankitpokhrel/jira-cli), the same CLI used on the Arch machine, as `~/.local/bin/jira` through Go. Jira configuration and credentials are not copied; initialize or supply them separately.
- Installs [Bitwarden CLI (`bw`)](https://bitwarden.com/help/cli/) through npm with the user-local prefix `~/.local`, placing `bw` in `~/.local/bin`. Rerunning the installer updates it to the latest release. Vault login is separate.

Personal helper links, Go binaries, and newly installed Zed/kubectl commands live in `~/.local/bin`, without sudo. Fedora's Zsh settings set `GOBIN` there for future Go installs. Both Zsh and the Fedora Sway session explicitly put this directory on `PATH`; log into Sway through the login screen (or use `start-sway`) to load its environment. Existing system-managed tool installations are left alone.

The installer does not overwrite conflicting dotfiles: resolve Stow conflicts explicitly. Review the shared Sway output names/scaling and `/usr/share/backgrounds/bg.png` wallpaper path for the new hardware. Slack and Spotify remain optional external installations referenced by the shared Sway config; they are not installed here. Personal SSH/GPG keys, Git signing configuration, work credentials and the local Codex ACP adapter patch must be set up separately.

After installation, select **Sway** at the existing login screen. The installer does not change your login shell; use `zsh` explicitly, or change it through the method permitted by your CSB. Reruns skip existing upstream clones, Zed, kubectl and installed symbol fonts; update these separately when needed.

### Updating Zed

For the upstream Zed installation created by this platform, rerun the official installer as your normal user, then restart Zed:

```sh
curl -fsSL https://zed.dev/install.sh | sh
```

This installs or refreshes `~/.local/zed.app` and its `~/.local/bin/zed` command. The `zeditor` compatibility link continues to work. Automatic update checks remain disabled by the shared Zed settings. If Zed was supplied by the CSB instead, use its installation/update mechanism.

## Adding a new platform

Create `platforms/<os-id>/` (where `<os-id>` matches the `ID` field in `/etc/os-release`) with:

- `config` — an `install_<manager>_packages` function for each package manager
- `APPARATUS_BIN_DIR` (optional, set in `config`) — user-owned directory for helper links; defaults to `/usr/local/bin` with sudo
- `packages.<N>.<manager>` — one package per line, installed in sort order
- `stow-targets` — `TARGET:package-path[:no-folding]` per line, with package paths relative to the checkout (e.g. `.config:platforms/fedora/stow/sway:no-folding`)
- `zsh.zsh` — platform-specific shell settings loaded by the shared Zsh config
- `stow/` (optional) — platform-local Stow packages; use `no-folding` on both shared and platform-local entries that merge into the same directory, so Stow links individual files rather than whole directories
- `repos` (optional) — `target_dir git_url` per line
- `links` (optional) — `link_name:target_path` per line
- `pre-install.sh` / `post-install.sh` (optional) — run before/after package install

## Theme

[Catppuccin Mocha](https://github.com/catppuccin/catppuccin), applied in foot, neovim, sway, waybar, mako, tig, and swaylock.

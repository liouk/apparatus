# :gear: apparatus

Dotfiles and setup automation, managed with [GNU Stow](https://www.gnu.org/software/stow/).

Originally forked from [michailpanagiotis/apparatus](https://github.com/michailpanagiotis/apparatus) :heart:

## Structure

```
platforms/<os>/          # per-platform config (packages, stow targets, repos, links)
platforms/<os>/bootstrap.sh # checkout defaults and bootstrap prerequisites
platforms/<os>/zsh.zsh   # platform-specific shell settings
platforms/<os>/stow/     # platform-local Stow packages
<package>/               # stow packages (zsh, git, foot, sway, etc.)
bootstrap.sh             # checks prerequisites, clones over HTTPS, runs install.sh
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

The bootstrap clones public apparatus over HTTPS; GitHub authentication is not
required. It runs downloaded code, so review the script first if desired. A piped
bootstrap also fetches the selected `platforms/<os>/bootstrap.sh` over HTTPS;
running from a checkout uses the local platform file instead. On Fedora it offers
to install missing Git and modern Bash with DNF before cloning. OpenSSH is
installed later through Fedora's normal package list. Existing checkouts and custom `APPARATUS_REPO_URL` /
`APPARATUS_INSTALL_DIR` overrides are preserved. An SSH URL override still requires
SSH authentication in advance.

For a fork or another bootstrap revision, `APPARATUS_RAW_URL` overrides the raw
repository base URL used to fetch platform files (default:
`https://raw.githubusercontent.com/liouk/apparatus/master`). Set it alongside
`APPARATUS_REPO_URL` when bootstrapping a fork over a pipe.

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

The `fedora` platform targets a regular, DNF-based Fedora installation, including a managed CSB with permission to install packages. Fedora Atomic is rejected by the platform's pre-install check. Start with curl available and permission to use sudo/DNF; the bootstrap handles missing Git and Bash, and the installer supplies OpenSSH. Public repository downloads use HTTPS, so GitHub SSH access is not needed before installation.

On Fedora, the bootstrap defaults to `~/liouk/apparatus`, alongside `~/liouk/toolshed`. The `zap` shell alias and Sway apparatus shortcut use this location. Arch and macOS retain their existing paths.

The package list covers Apparatus tools, not base-system provisioning. Standard utilities (including curl), a working build toolchain, and graphics drivers are assumed to come from the CSB. OpenSSH clients are explicitly installed; DNF supplies their FIDO2 dependencies.

- Reuses the shared dotfiles, including Foot, Sway, Waybar, Mako, Neovim and Zed. Fedora-only Sway session helpers are in `platforms/fedora/stow/sway/`.
- Uses Fedora packages for the desktop and CLI tools. Keeps the existing desktop/login manager and audio stack; only installs PulseAudio-compatible client tools (`pulseaudio-utils`, `pavucontrol`), not an audio server.
- Installs the NetBird CLI/daemon using its [signed upstream RPM repository](https://docs.netbird.io/get-started/install/linux). Existing NetBird installations or `netbird.repo` files are preserved. Unlike personal helper tools, this is a system package; no GUI or automatic VPN enrollment is configured. OpenVPN is not installed by this platform.
- Uses Fuzzel on `$mod+Space` instead of sway-launcher-desktop, with Fedora-local configuration in `platforms/fedora/stow/fuzzel/`. Tig is unchanged.
- Clones Powerlevel10k from upstream. Installs [Zed stable](https://zed.dev/docs/linux) and [latest stable kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/) only if missing, preserving existing installations. Adds a `zeditor` compatibility link when needed. Kubectl downloads are SHA-256 checked.
- Installs Go helpers and `yamlfmt`, plus the same Nerd Font symbols release as Arch. No AUR/COPR setup or `fzfpac` link is added.
- Installs [Ankit Pokhrel's JiraCLI](https://github.com/ankitpokhrel/jira-cli), the same CLI used on the Arch machine, as `~/.local/bin/jira` through Go. Jira configuration and credentials are not copied; initialize or supply them separately.
- Installs [Bitwarden CLI (`bw`)](https://bitwarden.com/help/cli/) through npm with the user-local prefix `~/.local`, placing `bw` in `~/.local/bin`. Rerunning the installer updates it to the latest release. Vault login is separate.
- Installs [Codex CLI](https://learn.chatgpt.com/docs/codex/cli) through npm with the same user-local prefix, placing `codex` in `~/.local/bin`. Rerunning the installer updates it to the latest release. Authentication is separate; redhat-config owns the global Codex instructions.

Personal helper links, Go binaries, and newly installed Zed/kubectl commands live in `~/.local/bin`, without sudo. Fedora's Zsh settings set `GOBIN` there for future Go installs. Both Zsh and the Fedora Sway session explicitly put this directory on `PATH`; log into Sway through the login screen (or use `start-sway`) to load its environment. Existing system-managed tool installations are left alone.

The installer does not overwrite conflicting dotfiles: resolve Stow conflicts explicitly. Review the shared Sway output names/scaling and `/usr/share/backgrounds/bg.png` wallpaper path for the new hardware. Slack and Spotify remain optional external installations referenced by the shared Sway config; they are not installed here. Commit-signing keys/configuration, work credentials and the local Codex ACP adapter patch must be set up separately.

After installation, select **Sway** at the existing login screen. The installer does not change your login shell; use `zsh` explicitly, or change it through the method permitted by your CSB. Reruns skip existing upstream clones, Zed, kubectl and installed symbol fonts; update these separately when needed.

### GitHub authentication with the YubiKey

Fedora's post-install step asks whether to recover SSH keys, then waits for you
to plug in the YubiKey and press Enter. It runs `ssh-keygen -K` directly in
`~/.ssh`; OpenSSH handles PIN/passphrase and existing-filename prompts.

All resident SSH keys are recovered and left there. A short fingerprint lookup
using `platforms/fedora/github-key.fingerprints` adds the
`id_ed25519_sk_github` alias (and its `.pub` companion) expected by our SSH config.
Existing aliases are left alone. There is no temporary directory, key deletion,
or replacement credential generation. Never commit key handles.

The GitHub configuration in `platforms/fedora/github-ssh.conf` is linked as
`~/.ssh/config` if that path is absent. Existing SSH configuration is preserved;
merge the GitHub block manually if needed. Verify access with
`ssh -T git@github.com`, checking GitHub's host fingerprint on first connection.

Recovery is skipped without a controlling terminal or with
`YUBIKEY_NONINTERACTIVE=1`. Apparatus stops here: clone and install any
private/work configuration yourself.

### Updating Zed

For the upstream Zed installation created by this platform, rerun the official installer as your normal user, then restart Zed:

```sh
curl -fsSL https://zed.dev/install.sh | sh
```

This installs or refreshes `~/.local/zed.app` and its `~/.local/bin/zed` command. The `zeditor` compatibility link continues to work. Automatic update checks remain disabled by the shared Zed settings. If Zed was supplied by the CSB instead, use its installation/update mechanism.

## Adding a new platform

Create `platforms/<os-id>/` (where `<os-id>` matches the `ID` field in `/etc/os-release`) with:

- `config` — an `install_<manager>_packages` function for each package manager
- `bootstrap.sh` — POSIX-shell defaults (`default_install_dir`, optional `bash_candidates` / `bash_hint`) and an optional `bootstrap_prepare` function for prerequisites needed before cloning
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

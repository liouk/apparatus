# :gear: apparatus

Dotfiles and setup automation, managed with [GNU Stow](https://www.gnu.org/software/stow/).

Originally forked from [michailpanagiotis/apparatus](https://github.com/michailpanagiotis/apparatus) :heart:

## Structure

```
platforms/<os>/             # platform config, packages, Stow targets, repos, links
platforms/<os>/bootstrap.sh # checkout defaults and bootstrap prerequisites
platforms/<os>/zsh.zsh      # platform-specific shell settings
platforms/<os>/stow/        # platform-local Stow packages
<package>/                  # Stow packages (zsh, git, foot, sway, ...)
bootstrap.sh                # prerequisite check, HTTPS clone, then install.sh
install.sh                  # installation driver
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

Bootstrap uses HTTPS, so GitHub authentication is unnecessary. It executes
downloaded code; review the script first if desired. A piped run also fetches the
selected platform bootstrap file, while a checkout uses its local copy. Fedora
offers to install missing Git and Bash before cloning; OpenSSH comes from its
normal package list. Existing checkouts and `APPARATUS_REPO_URL` /
`APPARATUS_INSTALL_DIR` overrides are preserved. An SSH repository URL requires
SSH authentication already to work.

For a fork or revision, set `APPARATUS_RAW_URL` to its raw-file base URL (default:
`https://raw.githubusercontent.com/liouk/apparatus/master`) alongside
`APPARATUS_REPO_URL`.

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

Machine- or work-specific `.zsh` / `.sh` files in `~/.zsh/conf.d/` are sourced in
filename order. Keep platform customizations in `platforms/<os>/`; the shared Zsh
config resolves its Stow symlink to load that platform's `zsh.zsh`.

## Git signing

Git uses SSH commit signing by default. The shared identity lives in
`git/.config/git/personal`; `.gitconfig` includes platform settings from
`~/.config/git/signing.conf` after the optional, user-managed
`~/.config/git/local.conf`. Repository-local settings can override these values.
`includeIf "gitdir:..."` rules continue to work for linked worktrees.

Full `./install.sh` runs the platform signing script. On a new machine, the
first run recovers the handle from the YubiKey or Secure Enclave and configures
Git; it may prompt for the authenticator PIN, handle passphrase, and approval.
Later full installs reuse the local handle and refresh the same Git settings.
`--stow-only` does not recover signing keys. To run signing setup by itself:

```sh
# Fedora: insert the YubiKey, then recover the resident SSH handle
bash platforms/fedora/git-signing.sh

# macOS: recover the Secure Enclave handle and register it with Apple's SSH agent
bash platforms/macos/git-signing.sh
```

Fedora uses `ssh-keygen -K` and expects the recovered handle at
`~/.ssh/id_ed25519_sk_git_signing_personal`. If OpenSSH restores it under another
filename, rename that key and its `.pub` file to the expected name and rerun the
script. macOS uses `/usr/bin/ssh-keygen` with Apple's
`/usr/lib/ssh-keychain.dylib` provider and expects the handle at
`~/.ssh/macos-signing/id_ecdsa_sk_rk`. It loads the handle into Apple's SSH agent;
the full macOS installer installs and starts a small LaunchAgent to reload it at
graphical login. Register each platform's public key with the Git hosting service
as a signing key. Never commit private key handles, PINs, or tokens.

The installer still manages GitHub SSH authentication separately: on Fedora and
macOS it can create `~/.ssh/id_ed25519_github` and switch Apparatus's remote to
SSH when that key exists.

## Codex instructions

Stow links `codex/AGENTS.md` into `~/.codex/AGENTS.md` (or `$CODEX_HOME`). It
contains global action-authorization rules, not credentials or machine-local
settings. Restart Codex after changing it. `AGENTS.override.md` in that directory
takes precedence; see the
[instruction discovery documentation](https://learn.chatgpt.com/docs/agent-configuration/agents-md).

## Codex ACP command preview

Zed uses the registry-managed adapter. To apply the local command-title patch:

```sh
bash ~/.config/zed/apply-codex-acp-show-command-patch.sh
```

Restart Zed afterwards. Registry updates can overwrite this patch; reapply it
after an update, or adapt it if the upstream code has changed.

## Fedora

The `fedora` platform targets regular DNF-based Fedora; Fedora Atomic is rejected.
Start with curl and sudo/DNF access. Bootstrap handles missing Git and Bash, and
the installer supplies OpenSSH. Public repositories use HTTPS, so GitHub SSH
access is not needed beforehand.

Fedora defaults to `~/liouk/apparatus`, alongside `~/liouk/toolshed`; the `zap`
alias and Sway shortcut use this location. Arch and macOS retain their paths.

The package list covers Apparatus tools, not system provisioning. Standard
utilities, a working build toolchain, and graphics drivers are prerequisites.

- Reuses shared dotfiles; Fedora-only Sway helpers live in `platforms/fedora/stow/sway/`.
- Uses Fedora packages without replacing the existing login manager or audio server.
  It installs only PulseAudio-compatible clients (`pulseaudio-utils`, `pavucontrol`).
- Uses Fuzzel on `$mod+Space`, with configuration in `platforms/fedora/stow/fuzzel/`.
- Installs [Zed stable](https://zed.dev/docs/linux) and [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)
  only when absent; kubectl downloads are SHA-256 checked, and `zeditor` is added
  as needed. It also installs Powerlevel10k, Go helpers, `yamlfmt`, Maple Mono NL
  NF, Nerd Font symbols, [Codex CLI](https://learn.chatgpt.com/docs/codex/cli),
  and [CodeRabbit CLI](https://www.coderabbit.ai/cli). Authentication remains
  separate.

Personal helpers, Go binaries, and newly installed Zed/kubectl commands live in
`~/.local/bin`, which Fedora's Zsh and Sway session add to `PATH`. Existing
system-managed tools are left alone.

The installer never overwrites Stow conflicts. Review Sway output names, scaling,
and the `/usr/share/backgrounds/bg.png` wallpaper path. Slack, Spotify,
credentials, and the Codex ACP patch remain separate setup.

Select **Sway** at the existing login screen. The installer does not change your
login shell. Reruns skip existing upstream clones, Zed, kubectl, and installed
symbol fonts; update them separately.

### GitHub authentication

The shared GitHub configuration is stowed as `~/.ssh/config`. Existing SSH config
is preserved, so merge its GitHub block manually if needed. Add the requested
`~/.ssh/id_ed25519_github.pub` key to GitHub, then verify with
`ssh -T git@github.com` after checking GitHub's host fingerprint.

### Updating Zed

For the upstream Zed installation created by this platform, rerun the official installer as your normal user, then restart Zed:

```sh
curl -fsSL https://zed.dev/install.sh | sh
```

This refreshes `~/.local/zed.app` and `~/.local/bin/zed`; `zeditor` continues to
work. For a system-managed Zed installation, use its package manager instead.

## Adding a new platform

Create `platforms/<os-id>/` (where `<os-id>` matches the `ID` field in `/etc/os-release`) with:

- `config` — `install_<manager>_packages` functions and optional platform flags
- `MANAGE_GITHUB_SSH_AUTH` (optional, set in `config`) — set to `true` to
  offer GitHub SSH authentication-key creation and switch Apparatus's public
  `origin` URL to SSH; defaults to `false`
- `bootstrap.sh` — POSIX-shell defaults (`default_install_dir`, optional
  `bash_candidates` / `bash_hint`) and optional pre-clone prerequisites
- `APPARATUS_BIN_DIR` (optional, set in `config`) — user-owned directory for helper links; defaults to `/usr/local/bin` with sudo
- `packages.<N>.<manager>` — one package per line, installed in sort order
- `stow-targets` — `TARGET:package-path[:no-folding]`; paths are checkout-relative.
  `HOME` targets the home directory, `CODEX` targets `${CODEX_HOME:-$HOME/.codex}`.
- `zsh.zsh` — platform-specific shell settings loaded by the shared Zsh config
- `stow/` (optional) — platform-local packages; use `no-folding` for merged directories
- `repos` (optional) — `target_dir git_url` per line
- `links` (optional) — `link_name:target_path` per line
- `pre-install.sh` / `post-install.sh` (optional) — run before/after package install

## Theme

[Catppuccin Mocha](https://github.com/catppuccin/catppuccin), applied in foot, neovim, sway, waybar, mako, tig, and swaylock.

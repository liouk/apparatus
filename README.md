# Apparatus

Dotfiles and setup automation, managed with [GNU Stow](https://www.gnu.org/software/stow/).
Originally forked from [michailpanagiotis/apparatus](https://github.com/michailpanagiotis/apparatus).

Shared dotfiles live in Stow packages at the repository root. Platform-specific
packages, bootstrap defaults, and install hooks live in `platforms/<os>/`.

## Install

Apparatus requires Bash 4 or newer. To bootstrap a new machine:

```sh
curl -fsSL https://raw.githubusercontent.com/liouk/apparatus/master/bootstrap.sh | sh
```

Bootstrap detects the operating system, clones Apparatus over HTTPS, and runs
`install.sh`. GitHub authentication is not needed to clone the public repository.
On Fedora, bootstrap can offer to install missing Git and Bash with DNF. On
macOS, it can install Homebrew and Homebrew Bash.

To use a fork or choose another checkout location, set `APPARATUS_REPO_URL`,
`APPARATUS_RAW_URL`, or `APPARATUS_INSTALL_DIR`. The defaults are the Apparatus
GitHub repository, its `master` branch, and a platform-specific directory.

From an existing checkout:

```sh
./install.sh --check-support  # report whether this OS is supported
./install.sh                  # full setup
./install.sh --stow-only      # link or refresh dotfiles
./install.sh --unstow-only    # remove Stow links
```

The full install handles packages, configured repositories and links, platform
SSH signing setup, then Stow. It preserves Stow conflicts instead of overwriting
them. `--stow-only` does not install packages or recover signing keys.

## Git and SSH keys

Git commit signing uses SSH keys. The shared personal identity is in
`git/.config/git/personal`. The main Git config includes optional
`~/.config/git/local.conf` for machine-specific settings and
`~/.config/git/signing.conf` for platform signing settings. Repository-local
config can override these defaults.

On Fedora, the full installer recovers the resident signing key from the YubiKey.
On macOS, it recovers the Secure Enclave handle and loads it into Apple's SSH
agent. The first recovery may prompt for the authenticator PIN, key passphrase,
or user approval. Later installs reuse the recovered files. macOS also installs a
LaunchAgent to load the handle at graphical login.

To run signing setup without the full installer:

```sh
bash platforms/fedora/git-signing.sh  # YubiKey
bash platforms/macos/git-signing.sh   # Secure Enclave
```

The Fedora handle is expected at
`~/.ssh/id_ed25519_sk_git_signing_personal`; rename the recovered key and its
`.pub` file if OpenSSH uses another name. The macOS handle is expected at
`~/.ssh/macos-signing/id_ecdsa_sk_rk`. Register each public key with your Git
hosting service for commit signing. Never commit private handles, PINs, or tokens.

GitHub SSH authentication is separate from commit signing. On Fedora and macOS,
the full installer offers to create `~/.ssh/id_ed25519_github`. Add its public key
to GitHub. When the key exists, Apparatus switches its own remote to SSH. The
shared SSH config is in `ssh/`; if you already have `~/.ssh/config`, merge its
GitHub block manually.

## Fedora

The Fedora profile targets regular DNF-based Fedora, not Fedora Atomic. It
defaults to `~/liouk/apparatus` and installs the Sway desktop alongside the
existing system. It does not replace the login manager, audio server, or login
shell; choose Sway at the login screen after installation.

The profile installs Apparatus tools and desktop packages, but does not provision
the whole system. A working build toolchain, graphics drivers, and standard
system utilities are assumed. Personal tools and Go binaries are installed under
`~/.local/bin`. Existing system-managed Zed and kubectl installs are left alone;
missing ones are installed, and the kubectl download is checksum-verified.

Fedora-only Sway and Fuzzel settings are under `platforms/fedora/stow/`. Review
the output names, scaling, and `/usr/share/backgrounds/bg.png` wallpaper path for
your hardware. Slack, Spotify, and credentials require separate setup.

To update the upstream Zed installation created by Apparatus, run its installer
as your normal user and restart Zed:

```sh
curl -fsSL https://zed.dev/install.sh | sh
```

## Codex and Zed

Stow links `codex/AGENTS.md` into `~/.codex/AGENTS.md` (or `$CODEX_HOME`). Restart
Codex after changing it. `AGENTS.override.md` in that directory takes precedence;
see the [instruction discovery documentation](https://learn.chatgpt.com/docs/agent-configuration/agents-md).

Zed uses the registry-managed Codex ACP adapter. To apply Apparatus's local
command-title patch, run:

```sh
bash ~/.config/zed/apply-codex-acp-show-command-patch.sh
```

Restart Zed afterwards. Registry updates can overwrite the patch; reapply it
after an update, or adapt it if upstream has changed.

## Adding a platform

Create `platforms/<os-id>/`, using the Linux `ID` from `/etc/os-release` or
`macos`. Add a `bootstrap.sh` and `stow-targets`; use `config` for package-manager
functions and optional flags. Package lists, `pre-install.sh`, `post-install.sh`,
`git-signing.sh`, `repos`, `links`, and platform-local Stow packages are optional.
Set `MANAGE_GITHUB_SSH_AUTH=true` in `config` to enable GitHub SSH key setup and
remote switching for that platform.

## Theme

[Catppuccin Mocha](https://github.com/catppuccin/catppuccin) is used in Foot,
Neovim, Sway, Waybar, Mako, Tig, and Swaylock.

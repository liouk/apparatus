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

# full install, offering recovery even when signing handles already exist
./install.sh --force-recover-keys

# force resident SSH key recovery and create their configured aliases only
./install.sh --recover-keys-only
```

Machine- or work-specific `.zsh` / `.sh` files in `~/.zsh/conf.d/` are sourced in
filename order. Keep platform customizations in `platforms/<os>/`; the shared Zsh
config resolves its Stow symlink to load that platform's `zsh.zsh`.

## Git signing and SSH key recovery

All platforms use `git/.config/git/personal` and SSH commit signing by default.
Private key handles stay in `~/.ssh`; identity files contain only the email and
signing-key reference. Git loads the personal identity, optional
`~/.config/git/local.conf`, then optional `~/.config/git/platform.conf` for
platform signing settings. Apparatus never manages `local.conf`,
which is the place for machine-specific settings and conditional identities.

`includeIf "gitdir:..."` rules match Git metadata, so linked worktrees retain
their identity routing. Repository-local Git settings can still override these
global defaults.

macOS installs Homebrew OpenSSH for FIDO2 support and writes its `ssh-keygen` path
to `~/.config/git/platform.conf` as `gpg.ssh.program`. Recovery also uses that
binary, independent of shell startup. Restart Zsh after a full installation;
Stow-only runs do not refresh this generated setting.

On Macs with an existing native Secure Enclave handle at
`~/.ssh/macos-signing/id_ecdsa_sk_rk` and its `.pub` file, full installation instead
writes `platform.conf` with Apple's `/usr/bin/ssh-keygen` and that public
key. This final override selects the same Mac key for personal and work commits
while preserving each identity's email. Set `MACOS_NATIVE_SIGNING_KEY` to another
handle path when invoking the installer if your handle has a different name.
Repository-local Git configuration still takes precedence.

Apparatus installs `~/Library/LaunchAgents/com.liouk.apparatus.git-signing.plist`
to load the native handle into Apple's SSH agent at graphical login, and starts
it for the current GUI session during installation. It uses
`/usr/bin/ssh-add -S /usr/lib/ssh-keychain.dylib`; no custom SSH agent or socket is
created. Key loading does not bypass biometric approval when signing. Without a
GUI session, loading waits until the next graphical login. Stow-only runs do not
install or start this login task.

Native identities must be created manually and their public keys registered as
signing keys with your Git hosting service. Apparatus never creates or recovers
them. Native signing skips automatic YubiKey recovery; `--force-recover-keys` and
`--recover-keys-only` still explicitly offer YubiKey recovery. Macs without the
native key pair retain the Homebrew/YubiKey setup. If a native handle is later
removed, existing platform signing settings are preserved and a warning is shown;
review that override before switching back to YubiKey signing.

Platforms with `MANAGE_PERSONAL_GIT_AND_SSH=true` (Fedora and macOS) offer to
create `~/.ssh/id_ed25519_github` and recover resident YubiKey signing keys with
`ssh-keygen -K`. When the GitHub key is available, Apparatus's `origin` changes
from HTTPS to SSH.
Public fingerprints in `ssh-key.fingerprints` identify resident signing keys.
An optional `~/.config/git/signing-key.fingerprints` can supply additional
alias/fingerprint pairs without putting them in this repository.

Normal installation offers YubiKey recovery only when a configured signing
handle is missing locally. Already-downloaded handles are matched by fingerprint
and renamed to their configured aliases first. Recovery downloads credentials
into a temporary directory and imports only missing configured handles, preserving
existing handles and their touch settings. `--force-recover-keys` offers recovery
even when all handles exist and allows replacing configured handles;
`--recover-keys-only` also forces recovery. Both retain the recovery confirmation.
Unlisted credentials are not imported, and existing unlisted local files are left
alone. Incomplete local key pairs are preserved rather than overwritten during
normal recovery; use forced recovery to replace them.

After recovery, Apparatus disables touch only for newly imported FIDO signing
handles, including those in the optional manifest. This requires OpenSSH
10.5 or newer; older versions warn and leave the touch policy unchanged. The
interactive step asks for the handle's old and new passphrase; reuse the same
passphrase to preserve it. It changes only the local handle, so recovery on each
machine must repeat it. GitHub authentication keys are unaffected. If a handle
is already loaded in an SSH agent, remove and reload it to use the changed policy.

Recovery is skipped without a controlling terminal or with
`YUBIKEY_NONINTERACTIVE=1`. Missing signing keys never disable signing. On an
opted-in platform, use `--recover-keys-only` to repeat recovery without installing
packages or restowing config. Never commit private key handles, PINs, or tokens.

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
- `MANAGE_PERSONAL_GIT_AND_SSH` (optional, set in `config`) — set to `true` to
  offer local GitHub authentication-key creation, recover resident signing
  keys, and switch Apparatus's public `origin` URL to SSH; defaults to `false`
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

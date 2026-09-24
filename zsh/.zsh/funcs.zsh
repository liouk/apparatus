# jump between subdirs of a base dir
__jumpfunc() {
  local jump_basedir=$1
  shift
  case $1 in
    "ls"|"-l"|"--ls")
      ls -lah $jump_basedir
      ;;
    *)
      cd "$jump_basedir/$1"
      ;;
  esac
}

# manage git worktrees
git-wt() {
  if [[ -z "$1" ]]; then
    local -a roots=("$APPARATUS_WORKSPACE_ROOT" "${GIT_WORKTREE_ROOTS[@]}")
    find "${roots[@]}" -maxdepth 3 -name .git -exec sh -c \
      'wt="$(git --git-dir="$1" worktree list)"; [ "$(echo "$wt" | wc -l)" -gt 1 ] && echo "$wt" && echo' _ {} \; 2>/dev/null
  elif [[ "$1" == "remove" || "$1" == "rm" ]]; then
    local toplevel="$(git rev-parse --show-toplevel)"
    local wtdir="${toplevel}.wt"
    if [[ -z "$2" ]]; then
      echo "usage: git-wt remove <worktree-name>"
      echo "available worktrees in ${wtdir}:"
      ls -1 "$wtdir" 2>/dev/null || echo "  (none)"
      return 1
    fi
    if [[ ! -d "${wtdir}/$2" ]]; then
      echo "worktree '${2}' not found in ${wtdir}"
      return 1
    fi
    git worktree remove "${wtdir}/$2"
  else
    local toplevel="$(git rev-parse --show-toplevel)"
    local wtdir="${toplevel}.wt/$1"
    [[ -d "${toplevel}.wt" ]] || mkdir -p "${toplevel}.wt"
    if git show-ref --verify --quiet "refs/heads/$1"; then
      git worktree add "$wtdir" "$1"
    else
      git worktree add -b "$1" "$wtdir"
    fi
  fi
}

# checkout a GitHub PR in a new git worktree
gh-prw() {
  local wtdir="$(git rev-parse --show-toplevel).wt/pr-$1"
  git worktree add "$wtdir" && (cd "$wtdir" && gh pr checkout --force "$1") && zeditor "$wtdir"
}

# replace a go module with another on a specific commit
go-replace() {
  if (( $# < 2 || $# > 3 )); then
    echo "examples:" >&2
    echo "  go-replace library-go github.com/you/library-go@my-branch" >&2
    echo "  go-replace library-go ~/src/library-go" >&2
    echo "  go-replace library-go ~/src/library-go my-branch" >&2
    return 2
  fi

  local query="$1"
  local fork_source="$2"
  local fork ref origin prefix
  local modules module upstream version
  local -a matches

  if [[ -d "$fork_source" ]]; then
    origin="$(git -C "$fork_source" remote get-url origin)" || return
    case "$origin" in
      git@github.com:*) fork="github.com/${origin#git@github.com:}" ;;
      https://github.com/*) fork="${origin#https://}" ;;
      http://github.com/*) fork="${origin#http://}" ;;
      ssh://git@github.com/*) fork="${origin#ssh://git@}" ;;
      *)
        echo "go-replace: local fork origin is not a GitHub URL: $origin" >&2
        return 1
        ;;
    esac
    fork="${fork%.git}"
    prefix="$(git -C "$fork_source" rev-parse --show-prefix)" || return
    [[ -n "$prefix" ]] && fork+="/${prefix%/}"
    ref="${3:-HEAD}"
    ref="$(git -C "$fork_source" rev-parse --verify "${ref}^{commit}")" || return
  else
    if (( $# != 2 )) || [[ "$fork_source" != *'@'* ]]; then
      echo "go-replace: expected a local fork path or module@ref" >&2
      echo "example: go-replace library-go github.com/you/library-go@my-branch" >&2
      return 2
    fi
    fork="${fork_source%@*}"
    ref="${fork_source##*@}"
    if [[ -z "$fork" || -z "$ref" ]]; then
      echo "go-replace: fork module and ref must both be non-empty" >&2
      return 2
    fi
  fi

  modules="$(go list -mod=mod -m -f '{{if not .Main}}{{.Path}}{{end}}' all)" || return
  matches=()
  while IFS= read -r module; do
    [[ "$module" == *"$query"* ]] && matches+=("$module")
  done <<< "$modules"

  if (( ${#matches[@]} == 0 )); then
    echo "go-replace: no dependency module matches '$query'" >&2
    return 1
  fi
  if (( ${#matches[@]} > 1 )); then
    echo "go-replace: multiple dependency modules match '$query':" >&2
    printf '  %s\n' "${matches[@]}" >&2
    return 1
  fi

  upstream="${matches[1]}"

  version="$(go list -mod=mod -m -f '{{.Version}}' "${fork}@${ref}")" || return
  go mod edit -replace="${upstream}=${fork}@${version}"
}

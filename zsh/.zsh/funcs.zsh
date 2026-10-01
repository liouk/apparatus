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

# replace a Go dependency with a pushed ref from a fork
go-replace() {
  local usage="usage: go-replace <dependency> <ref> [owner/repo]"

  if [[ "${1:-}" == help || "${1:-}" == -h || "${1:-}" == --help ]]; then
    print -r -- "$usage"
    return
  elif (( $# < 2 || $# > 3 )); then
    print -u2 -r -- "$usage"
    return 2
  fi

  local query="$1" ref="$2" fork="$3"
  local modules module upstream version
  local -a matches

  modules="$(go list -mod=mod -m -f '{{if not .Main}}{{.Path}}{{end}}' all)" || return
  while IFS= read -r module; do
    [[ "$module" == *"$query"* ]] && matches+=("$module")
  done <<< "$modules"

  case ${#matches} in
    0)
      print -u2 "go-replace: no dependency matches '$query'"
      return 1
      ;;
    1) upstream="${matches[1]}" ;;
    *)
      print -u2 "go-replace: multiple dependencies match '$query':"
      printf '  %s\n' "${matches[@]}" >&2
      return 1
      ;;
  esac

  if [[ -z "$fork" ]]; then
    if [[ "$upstream" != github.com/*/* ]]; then
      echo "go-replace: cannot derive a GitHub fork from '$upstream'" >&2
      return 1
    fi
    fork="liouk/${${upstream#github.com/}#*/}"
  fi
  fork="github.com/${fork#github.com/}"

  version="$(go list -mod=mod -m -f '{{.Version}}' "${fork}@${ref}")" || return
  go mod edit -replace="${upstream}=${fork}@${version}" || return
  print -r -- "replace $upstream => $fork $version"
}

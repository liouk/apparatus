# jump between subdirs of a base dir
function __jumpfunc () {
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
function git-wt () {
  if [[ -z "$1" ]]; then
    find ~/redhat/repos ~/liouk -maxdepth 3 -name .git -exec sh -c \
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
    git worktree add "$wtdir" "$1"
  fi
}

# checkout a GitHub PR in a new git worktree
function gh-prw () {
  local wtdir="$(git rev-parse --show-toplevel).wt/pr-$1"
  git worktree add "$wtdir" && (cd "$wtdir" && gh pr checkout --force "$1")
}

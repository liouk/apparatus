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

# choose a kube namespace using fzf and set it in the current kube context
function kns () {
  chosen=$(kubectl get ns --no-headers -o custom-columns=":metadata.name" | fzf)
  kubectl config set-context --current --namespace="$chosen"
}

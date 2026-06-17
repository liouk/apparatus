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

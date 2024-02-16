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

# choose a kube namespace using fzf and set it in the current kube context
function kns () {
  chosen=$(kubectl get ns --no-headers -o custom-columns=":metadata.name" | fzf)
  kubectl config set-context --current --namespace="$chosen"
}

function makesh () {
	name="$1"
	[ -f $name ] && { echo "file '$name' already exists"; return; }
	echo "#!/usr/bin/env bash" > "$name"
	chmod +x "$name"
}

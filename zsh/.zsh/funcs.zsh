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

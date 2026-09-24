# Environment inherited by interactive shells and commands launched from them.
# Limit Go's default package/build parallelism to keep large test runs from
# exhausting this machine while leaving an explicit user override intact.
export GOMAXPROCS="${GOMAXPROCS:-4}"

case " ${GOFLAGS-} " in
  *" -p="*) ;;
  *) export GOFLAGS="${GOFLAGS:+$GOFLAGS }-p=4" ;;
esac

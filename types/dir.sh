# modified from original version at https://github.com/mattly/bork

# TODO
# - add --perms
# - add --owner

action=$1
dir=$2
shift

case $action in
  desc)
    echo "assert presence of a directory"
    echo "> dir /tmp/foo"
    ;;

  status)
    [ ! -e $dir ] && return $STATUS_MISSING
    [ -d $dir ] && return $STATUS_OK
    echo "target exists as non-directory"
    return $STATUS_MISMATCH
    ;;

  install) mkdir -p $dir;;

  *) return 1 ;;
esac

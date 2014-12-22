# modified from original version at https://github.com/mattly/bork

action=$1
target=$2
source=$3
shift 3

case $action in
  desc)
    echo "assert presence and target of a symlink"
    echo "> symlink .bashrc ~/dotfiles/bashrc"
    ;;
  status)
    [ -z "$source" ] && echo "needs both source and target defined" && return "$STATUS_FAILED_PRECONDITION"
    if [ -h "$target" ]; then
      existing_source=$(readlink "$target")
      if [ "$existing_source" != "$source" ]; then
        echo "received source for existing symlink: $existing_source"
        echo "expected source for symlink: $source"
        return "$STATUS_CONFLICT"
      else
        return "$STATUS_OK"
      fi
    elif [ -e "$target" ]; then
      echo "not a symlink: $target"
      return "$STATUS_CONFLICT"
    else
      return "$STATUS_MISSING"
    fi
    ;;

  install|upgrade)
    ln -s "$source" "$target"
    ;;

  *) return 1;;
esac

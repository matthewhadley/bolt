# modified from original version at https://github.com/mattly/bork

action=$1
name=$2
shift 2

case $action in
  desc)
    echo "assert package installed via homebrew on OSX"
    echo "> brew package"
    ;;

  status)
    platform "Darwin" || return "$STATUS_UNSUPPORTED_PLATFORM"
    exec "ruby" || return "$STATUS_FAILED_PRECONDITION"

    echo "$(brew list)" | grep "^$name"
    [ "$?" -gt 0 ] && return "$STATUS_MISSING"

    brew outdated $name
    [ "$?" -ne 0 ] && return "$STATUS_OUTDATED"
    return "$STATUS_OK"
    ;;

  install)
    brew install $name
    ;;

  upgrade)
    brew upgrade $name
    ;;

  *) return 1 ;;
esac

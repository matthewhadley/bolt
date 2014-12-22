# modified from original version at https://github.com/mattly/bork

action=$1
name=$2
shift 2

case $action in
  desc)
    echo "assert package installed via apt-get on Debian or Ubuntu linux"
    echo "> apt package"
    ;;

  status)
    root || return "$STATUS_FAILED_PRECONDITION"
    platform "Linux" || return "$STATUS_UNSUPPORTED_PLATFORM"
    exec "apt-get" || return "$STATUS_FAILED_PRECONDITION"
    exec "dpkg" || return "$STATUS_FAILED_PRECONDITION"

    echo "$(dpkg --get-selections)" | grep -E "^$name\\s+install$"
    [ "$?" -gt 0 ] && return "$STATUS_MISSING"

    outdated=$(sudo apt-get -u update --dry-run | grep "^Inst" | awk '{print $2}')
    match "$outdated" "$name"
    [ "$?" -eq 0 ] && return "$STATUS_OUTDATED"
    return "$STATUS_OK"
    ;;

  install|upgrade)
    sudo -i apt-get --yes install "$name"
    ;;

  *) return 1 ;;
esac


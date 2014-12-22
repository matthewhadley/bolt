# modified from original version at https://github.com/mattly/bork

action=$1
name=$2
shift 2

case $action in
  desc)
    echo "assert package installed via yum on CentOS or RedHat"
    echo "> yum package"
    ;;

  status)
    root || return "$STATUS_FAILED_PRECONDITION"
    platform "Linux" || return "$STATUS_UNSUPPORTED"
    exec "yum" || return "$STATUS_FAILED_PRECONDITION"

    echo "$(rpm -qa)" | grep "^$name"
    [ "$?" -gt 0 ] && return "$STATUS_MISSING"

    echo "$(sudo yum list updates)" | grep "^$name"
    [ "$?" -eq 0 ] && return "$STATUS_OUTDATED"
    return "$STATUS_OK"
    ;;

  install|upgrade)
    sudo yum -y install "$name"
    ;;

  *) return 1 ;;
esac

# modified from original version at https://github.com/mattly/bork

action=$1
group=$2
shift 2

case $action in
  desc)
    echo "assert presence of a unix group"
    echo "> group admin"
    ;;
  status)
    root || return "$STATUS_UNPRIVILEGED"
    exec "groupadd" || return "$STATUS_FAILED_PRECONDITION"

    grep -E "^$group:" < /etc/group
    [ "$?" -gt 0 ] && return "$STATUS_MISSING"
    return "$STATUS_OK"
    ;;

  install) groupadd "$group" ;;

  *) return 1 ;;
esac

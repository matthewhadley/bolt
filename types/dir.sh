# modified from original version at https://github.com/mattly/bork

action=$1
target=$2
shift

perms=$(arg perms "$*")
owner=$(arg owner "$*")
group=$(arg group "$*")

case $action in
  desc)
    echo "assert presence of a directory"
    echo "> dir /tmp/foo [arguments]"
    echo "--perms 555       permissions for the directory"
    echo "--owner name      owner name of the directory"
    echo "--group name      group name of the directory"
    ;;

  status)
    # check any requested owner exists
    owner_exists "$owner" || return $?

    # check any requested group exists
    group_exists "$group" || return $?

    # check existing permissions
    check_perms "$target" "$perms" || return $?

    # check existing owner
    check_owner "$target" "$owner" || return $?

    # check existing group
    check_group "$target" "$group" || return $?

    [ ! -e "$target" ] && return "$STATUS_MISSING"
    [ -d "$target" ] && return "$STATUS_OK"
    echo "target exists as non-directory"
    return "$STATUS_MISMATCH"
    ;;

  install)
    mkdir -p "$target"
    [ -n "$owner" ] && chown "$owner" "$target"
    [ -n "$group" ] && chgrp "$group" "$target"
    [ -n "$perms" ] && chmod "$perms" "$target"
    return 0;
    ;;

  *) return 1 ;;
esac

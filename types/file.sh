# modified from original version at https://github.com/mattly/bork

action=$1
target=$2
source=$3
shift 3

perms=$(arg perms "$*")
owner=$(arg owner "$*")
group=$(arg group "$*")

# shellcheck disable=SC2012
case $action in
  desc)
    echo "assert presence, checksum, owner and permissions of a file"
    echo "> file target source [arguments]"
    echo "--perms 755       permissions for the file"
    echo "--owner name      owner name of the file"
    echo "--group name      group name of the file"
    ;;

  status)
    # check source file exists
    if [ ! -f "$source" ]; then
      echo "source file doesn't exist: $source"
      return "$STATUS_FAILED_PRECONDITION"
    fi

    # check any requested owner exists
    owner_exists "$owner" || return $?

    # check any requested group exists
    group_exists "$group" || return $?

    # check target does not exist
    if [ ! -f "$target" ]; then
      echo "target file doesn't exist: $target"
      return "$STATUS_MISSING"
    fi

    sourcesum=$(md5_cmd "$source")
    targetsum=$(md5_cmd "$target")

    # check if source file contents are outdated
    if [ "$targetsum" != "$sourcesum" ]; then
      echo "expected sum: $sourcesum"
      echo "received sum: $targetsum"
      return "$STATUS_OUTDATED"
    fi

    # check existing permissions
    check_perms "$target" "$perms" || return $?

    # check existing owner
    check_owner "$target" "$owner" || return $?

    # check existing group
    check_group "$target" "$group" || return $?

    return "$STATUS_OK"
    ;;

  install|upgrade)
    dir=$(dirname "$target")
    [ "$dir" != . ] && mkdir -p "$dir"
    [ -n "$owner" ] && chown "$owner" "$dir"
    [ -n "$group" ] && chgrp "$group" "$dir"
    cp "$source" "$target"
    [ -n "$owner" ] && chown "$owner" "$target"
    [ -n "$group" ] && chgrp "$group" "$target"
    [ -n "$perms" ] && chmod "$perms" "$target"
    return 0
    ;;

  *) return 1 ;;
esac

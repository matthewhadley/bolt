# modified from original version at https://github.com/mattly/bork

action=$1
target=$2
source=$3
shift 3

perms=$(arg perms $@)
owner=$(arg owner $@)
group=$(arg group $@)

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
    if [ ! -f $source ]; then
      echo "source file doesn't exist: $source"
      return $STATUS_FAILED_PRECONDITION
    fi

    # check requested owner exists
    if [ -n "$owner" ]; then
      owner_id=$(id -u $owner)
      if [ "$?" -gt 0 ]; then
        echo "unknown owner: $owner"
        return $STATUS_FAILED_PRECONDITION
      fi
    fi

    # check requested group exists
    if [ -n "$group" ]; then
      cat /etc/group | grep -E "^$group:"
      if [ "$?" -gt 0 ]; then
        echo "unknown group: $group"
        return $STATUS_FAILED_PRECONDITION
      fi
    fi

    # check target does not exist
    if [ ! -f $target ]; then
      echo "target file doesn't exist: $target"
      return $STATUS_MISSING
    fi

    sourcesum=$(md5_cmd $source)
    targetsum=$(md5_cmd $target)

    # check if source file contents are outdated
    if [ "$targetsum" != $sourcesum ]; then
      echo "expected sum: $sourcesum"
      echo "received sum: $targetsum"
      return $STATUS_OUTDATED
    fi

    # check for conflicts with existing file
    conflict=
    # check existing permissions
    if [ -n "$perms" ]; then
      existing_perms=$(perms_cmd $target)
      if [ "$existing_perms" != $perms ]; then
        echo "expected permissions: $perms"
        echo "received permissions: $existing_perms"
        conflict=1
      fi
    fi
    # check existing owner
    if [ -n "$owner" ]; then
      root || return $STATUS_FAILED_PRECONDITION
      existing_user=$(ls -l $target | awk '{print $3}')
      if [ "$existing_user" != $owner ]; then
        echo "expected owner: $owner"
        echo "received owner: $existing_user"
        conflict=1
      fi
    fi
    # check existing group
    if [ -n "$group" ]; then
      root || return $STATUS_FAILED_PRECONDITION
      existing_group=$(ls -l $target | awk '{print $4}')
      if [ "$existing_group" != $group ]; then
        echo "expected group: $group"
        echo "received group: $existing_group"
        conflict=1
      fi
    fi

    [ -n "$conflict" ] && return $STATUS_CONFLICT

    return $STATUS_OK
    ;;

  install|upgrade)
    dir=$(dirname $target)
    [ "$dir" != . ] && mkdir -p $dir
    [ -n "$owner" ] && chown $owner $dir
    [ -n "$group" ] && chgrp $group $dir
    cp $source $target
    [ -n "$owner" ] && chown $owner $target
    [ -n "$group" ] && chgrp $group $target
    [ -n "$perms" ] && chmod $perms $target
    return 0
    ;;

  *) return 1 ;;
esac

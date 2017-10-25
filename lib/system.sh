# get system type
platform=$(uname -s)

# check system type
platform () {
  [ "$platform" = "$1" ]
  return $?
}

# configure system specific commands
# shellcheck disable=SC2116
case $platform in
  Darwin)
    md5_cmd () {
      eval "$(echo "md5 -q $1")"
    }
    perms_cmd() {
      eval "$(echo "stat -f '%Lp' $1")"
    }
    ;;
  Linux)
    md5_cmd () {
      eval "$(echo "md5sum $1| awk '{print \$1}'")"
    }
    perms_cmd() {
      eval "$(echo "stat --printf '%a' $1")"
    }
    ;;
  *) return 1 ;;
esac

# check for root priveleges
root() {
  [ $EUID -ne 0 ] && echo "needs root priveleges" && return 1
  return 0
}

# check for an executable
exec () {
  which "$1" &>/dev/null || { echo "exec: $1 not available" && return 1; }
}

owner_exists() {
  if [ -n "$1" ]; then
    id -u "$1" 2> /dev/null
    if [ "$?" -gt 0 ]; then
      echo "unknown owner: $1"
      return "$STATUS_FAILED_PRECONDITION"
    fi
  fi
}

group_exists() {
  if [ -n "$1" ]; then
    grep -E "^$1:" < /etc/group > /dev/null
    if [ "$?" -gt 0 ]; then
      echo "unknown group: $1"
      return "$STATUS_FAILED_PRECONDITION"
    fi
  fi
}

# $target $perms
check_perms() {
  if [ -n "$2" ]; then
    local existing_perms=$(perms_cmd "$1")
    if [ "$existing_perms" != "$2" ]; then
      echo "expected permissions: $2"
      echo "received permissions: $existing_perms"
      return "$STATUS_CONFLICT"
    fi
  fi
}

# $target $owner
check_owner() {
  if [ -n "$2" ]; then
    root || return "$STATUS_UNPRIVILEGED"

    local existing_user
    if [[ -d $1 ]]; then
      existing_user=$(ls -ld "$1" | awk '{print $3}')
    elif [[ -f $1 ]]; then
      existing_user=$(ls -l "$1" | awk '{print $3}')
    fi

    if [ "$existing_user" != "$2" ]; then
      echo "expected owner: $2"
      echo "received owner: $existing_user"
      return "$STATUS_CONFLICT"
    fi
  fi
}

# $target $group
check_group() {
  # check existing group
  if [ -n "$2" ]; then
    root || return "$STATUS_UNPRIVILEGED"

    local existing_group
    if [[ -d $1 ]]; then
      existing_group=$(ls -ld "$1" | awk '{print $4}')
    elif [[ -f $1 ]]; then
      existing_group=$(ls -l "$1" | awk '{print $4}')
    fi

    if [ "$existing_group" != "$2" ]; then
      echo "expected group: $2"
      echo "received group: $existing_group"
      return "$STATUS_CONFLICT"
    fi
  fi
}

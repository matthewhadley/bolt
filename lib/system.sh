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

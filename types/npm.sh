# modified from original version at https://github.com/mattly/bork

# TODO --status - check version outdated status
# TODO --version - support for status, install, update

action=$1
pkgname=$2
shift 2

case $action in
  desc)
    echo "assert presence of an npm package installed globally"
    echo "> npm package"
    ;;

  status)
    root || return "$STATUS_UNPRIVILEGED"
    exec "npm" || return "$STATUS_FAILED_PRECONDITION"
    pkgs=$(npm ls -g --depth 0 --parseable 2>/dev/null)
    match "$pkgs" "\/$pkgname"
    [ "$?" -ne 0 ] && return "$STATUS_MISSING"
    return "$STATUS_OK"
    ;;

  install) npm --no-spin -g install "$pkgname";;

  *) return 1 ;;
esac

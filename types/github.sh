# modified from original version at https://github.com/mattly/bork

action=$1
repo=$2
shift 2

# shellcheck disable=SC2116,SC2086,SC2048
case $action in
  desc)
    echo "interface for git type, using github user/repo combos"
    echo "> github diffsky/bolt [arguments as per git type]"
    ;;
  *) . "$BOLT_DIR/types/git.sh" "$action" "git@github.com:$(echo $repo).git" $*;;
esac

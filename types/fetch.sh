# get a file from the internets

action=$1
target=$2
source=$3
shift 3

perms=$(arg perms "$*")
owner=$(arg owner "$*")
group=$(arg group "$*")

case $action in
  desc)
    echo "interface for file type, with file retrieved from remote filesystem via curl"
    echo "> file target source [arguments as per file type]"
    ;;
  *)
    exec "curl" || return "$STATUS_FAILED_PRECONDITION"

    # create a tmp file to put contents in
    TMPFILE=$(mktemp -t bolt-file.XXXXX)

    # fetch the file with curl on silent (-s) and return fail values (-f)
    curl -sf "$source" > "$TMPFILE"
    if [ $? -gt 0 ]; then
      echo "failed to fetch $source"
      return "$STATUS_FAILED"
    fi

    # rebuild arguments
    args=''
    if [ -n "$perms" ]; then
      args="$args --perms $perms"
    fi
    if [ -n "$owner" ]; then
      args="$args --owner $owner"
    fi
    if [ -n "$group" ]; then
      args="$args --group $group"
    fi

    # run file type assertion
    . "$BOLT_DIR/types/file.sh" "$action" "$target" "$TMPFILE" "$args"
    ;;
esac

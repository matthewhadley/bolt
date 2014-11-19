# run a bolt action and return status
status() {
  type=$1
  fn=$2
  shift 2
  print "status: $type $@"
  output=$(eval . $fn 'status' $@)
  status=$?
  print "$(bolt_status $status): $type $@"
  if [[ "$BOLT_VERBOSE" = "1" || "$BOLT_OPERATION" != "status" ]]; then
    # strip any extra line breaks from output
    output=$(echo "$output" | sed '/^$/d')
    [ "$output" != "" ] && echo -e "\n$output"
  fi
  return $status
}

# control running of a bolt action
ok() {
  echo ""
  type=$1
  shift

  bolt_changes_reset

  fn="$BOLT_DIR/types/$type.sh"
  if [ ! -f $fn ]; then
    echo "unsupported type: $type"
    return 1
  fi

  case $BOLT_OPERATION in
    status|check)
      status $type $fn $@
      status=$?
      case $status in
        0) bolt_changes_done 'none';;
        1|5|6|7) bolt_changes_done 'error' $status;;
        2) bolt_changes_done 'install';;
        3|4) bolt_changes_done 'upgrade';;
        *) echo "unknown status returned from type operation";;
      esac
      ;;
    satisfy|do)
      status $type $fn $@
      status=$?
      case $status in
        0) bolt_changes_done 'none' $status;;
        1|5|6|7) bolt_changes_done 'error' $status;;
        2) echo ""; . $fn 'install' $@; bolt_changes_done 'install' $?;;
        3|4) echo ""; . $fn 'upgrade' $@; bolt_changes_done 'upgrade' $?;;
        *) echo "unknown status returned from type operation";;
      esac
      ;;
  esac

  if bolt_did_error; then
    case $status in
      5|6|7) echo "";;
    esac
    print $(bolt_status 1): $type $@
  fi

  if [ "$BOLT_OPERATION" = "satisfy" ];then
    if bolt_did_update; then
      status $type $fn $@
    fi
  fi

}

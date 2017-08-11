# statuses
bolt_did_error=0
bolt_did_install=0
bolt_did_upgrade=0

# counts
bolt_error_count=0
bolt_update_count=0
bolt_install_count=0
bolt_upgrade_count=0
bolt_satisfy_count=0
bolt_operations_count=0

bolt_changes_reset () {
  bolt_did_install=0
  bolt_did_upgrade=0
  bolt_did_error=0
}

bolt_did_install () { [ "$bolt_did_install" -eq 1 ] && return 0 || return 1; }
bolt_did_upgrade () { [ "$bolt_did_upgrade" -eq 1 ] && return 0 || return 1; }
bolt_did_update () {
  if bolt_did_install; then return 0
  elif bolt_did_upgrade; then return 0
  else return 1
  fi
}
bolt_did_error () { [ "$bolt_did_error" -gt 0 ] && return 0 || return 1; }

bolt_changes_done () {
  action=$1
  status=$2
  [ -z "$status" ] && status=0

  let bolt_operations_count=bolt_operations_count+1
  if [ "$status" -gt 0 ]; then
    bolt_did_error=1
    let bolt_error_count=bolt_error_count+1
  elif [ "$action" = "install" ]; then
    [ "$BOLT_OPERATION" = "satisfy" ] && bolt_did_install=1
    let bolt_update_count=bolt_update_count+1
    let bolt_install_count=bolt_install_count+1
  elif [ "$action" = "upgrade" ]; then
    [ "$BOLT_OPERATION" = "satisfy" ] && bolt_did_upgrade=1
    let bolt_update_count=bolt_update_count+1
    let bolt_upgrade_count=bolt_upgrade_count+1
  elif [ "$action" = "none" ]; then
    let bolt_satisfy_count=bolt_satisfy_count+1
  fi
}

# format bolt run results
reporter() {
  echo ""
  if [[ $bolt_operations_count -lt 1 ]];then
    echo "no bolt operations run"
    return
  fi
  echo ""
  if [ "$bolt_error_count" -gt 0 ];then
    echo -e "BOLT RUN ${RED}FAIL${DEF}"
  else
    if [[ $BOLT_OPERATION == "status" && $bolt_update_count -gt 0 ]];then
      echo -e "BOLT RUN ${YEL}WARN${DEF}"
    else
      echo -e "BOLT RUN ${GRE}OK${DEF}"
    fi
  fi
  echo "operations: $bolt_operations_count"
  echo "    failed: $bolt_error_count"
  echo "        ok: $bolt_satisfy_count"
  echo "   updates: $bolt_update_count"
  echo "(installs): $bolt_install_count"
  echo "(upgrades): $bolt_upgrade_count"

  if [[ "$bolt_error_count" -gt 0 && "$BOLT_VERBOSE" != "1" ]];then
    echo -e "\ntry running in verbose mode for more info"
  fi
}

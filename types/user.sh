# modified from original version at https://github.com/mattly/bork

# TODO need to check --groups to make sure they exist

action=$1
username=$2
shift 2

shell=$(arg shell "$*")
groups=$(arg groups "$*")

user_get () {
  row=$(grep -E "^$1:" < /etc/passwd)
  stat=$?
  echo "$row"
  return $stat
}

user_shell () {
  current_shell=$(echo "$1" | cut -d: -f 7)
  if [ "$current_shell" != "$2" ]; then
    echo "$current_shell"
    return 1
  fi
  return 0
}

user_groups () {
  current_groups=$(groups "$1")
  case $platform in
    Linux) current_groups=$(echo "$current_groups" | cut -d: -f 2) ;;
  esac
  missing_groups=
  # don't quote "$2" so that IFS splits it
  # shellcheck disable=SC2086
  expected_groups=$(IFS=','; echo $2)
  for group in $expected_groups; do
    echo "$current_groups" | grep -E "\b$group\b" > /dev/null
    if [ "$?" -gt 0 ]; then
      missing_groups=1
      echo "$group"
    fi
  done

  [ -n "$missing_groups" ] && return 1
  return 0
}

case $action in
  desc)
    echo "assert presence of a user on the system"
    echo "> user admin"
    echo "--shell /bin/bash"
    echo "--groups admin,deploy"
    ;;

  status)
    exec "useradd" || return "$STATUS_FAILED_PRECONDITION"

    row=$(user_get "$username")
    [ "$?" -gt 0 ] && return "$STATUS_MISSING"

    if [ -n "$shell" ]; then
      msg=$(user_shell "$row" "$shell")
      if [ "$?" -gt 0 ]; then
        echo "--shell: expected $shell; is $msg"
        missing=1
      fi
    fi

    if [ -n "$groups" ]; then
      msg=$(user_groups "$username" "$groups")
      if [ "$?" -gt 0 ]; then
        echo "--groups: expected $groups; missing $(echo "$msg")"
        missing=1
      fi
    fi
    [ -n "$missing" ] && return "$STATUS_OUTDATED"
    return 0 ;;

  install)
    args="-m"
    [ -n "$shell" ] && args="$args --shell $shell"
    # shellcheck disable=SC2206
    [ -n "$groups" ] && groups_list=(${groups//,/ }) && args="$args --groups $groups"
    # if adding a user and explicitly setting group as same name use -g flag
    [[ -n "${groups_list[0]}" && "${groups_list[0]}" == "$username" ]] && args="$args -g $username"
    # if adding a user and an existing group has with the same name exists, use -g flag
    match "$(cat /etc/group)" "^$username"
    handle_matches_group=$?
    [[ -n "$groups" && $handle_matches_group = 0 ]] && args="$args -g $username"
    # shellcheck disable=SC2086
    useradd $args $username
    ;;

  upgrade)
    if [ -n "$shell" ];then
      if ! user_shell "$(user_get "$username")" "$shell"; then
        chsh -s "$shell" "$username"
      fi
    fi
    missing=$(user_groups "$username" "$groups")
    if [ "$?" -gt 0 ]; then
      groups_to_create=$(IFS=','; echo "$missing")
      for group in $groups_to_create; do
        # shellcheck disable=SC2086
        usermod -a -G $group $username
      done
    fi
    ;;

  *) return 1 ;;
esac

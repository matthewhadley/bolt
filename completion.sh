#!/usr/bin/env bash

# command line tab completions for bolt. Source this file to add
# tab auto completions to your environment for bolt
# see https://devmanual.gentoo.org/tasks-reference/completion/index.html
_bolt()
{
  local cur prev opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  opts="status satisfy check do types"
  types=$(bolt list)

  if [ ${COMP_CWORD} -eq 1 ] ; then
    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
    return 0
  fi

  case "${prev}" in
    status|satisfy)
      COMPREPLY=($(compgen -f ${COMP_WORDS[${COMP_CWORD}]} ) )
      ;;
    do|check|types)
      COMPREPLY=( $(compgen -W "${types}" -- ${cur}) )
      ;;
  esac

}
complete -F _bolt bolt

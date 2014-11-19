#!/usr/bin/env bash

# command line tab completions for bolt. Source this file to add
# tab auto completions to your environment for bolt
_bolt()
{
  local cur prev opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  opts="status satisfy check do"

  COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
  return 0
}
complete -F _bolt bolt

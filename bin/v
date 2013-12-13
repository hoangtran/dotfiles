#!/bin/bash
#
# fork of https://github.com/rupa/v
#
###

message() {
  echo 'v [ -l ] [ vim opts ] <regex>'
  exit 1
}

errorout() {
  echo "$*" >&2
  exit 1
}

edit_from_list() {
  local i choice
  local args=( "$@" )

  for ((i=0; i < "${#args[@]}"; i++)); do
    echo -e "$i:\t${args[i]}"
  done
  echo

  read -r -p '> ' choice

  # invalid choices
  [[ -n "${choice//[0-9]/}"      ]] && errorout 'invalid choice'
  [[ "$choice" -lt 0             ]] && errorout 'invalid choice'
  [[ "$choice" -ge "${#args[@]}" ]] && errorout 'invalid choice'

  "$vim" "${vopts[@]}" "${args[choice]}"
}

# config
viminfo="$HOME/.viminfo"
vim='vim'

list=false

while [[ -n "$1" ]]; do
  case "$1" in
    -h|--help) message      ;;
    -l|--list) list=true    ;;
    --)        shift; break ;;

    # this isn't great but it's the best we've got
    -*) vopts+=( "$1" ) ;;
    +*) vopts+=( "$1" ) ;;
    *)  break           ;;
  esac
  shift
done

[[ -z "$1" ]] && message

matches=( $(sed '/^> \(.*\)/!d;s//\1/g;s%~%'"$HOME"'%g' "$viminfo" | grep "$1") )

[[ "${#matches[@]}" -eq 0 ]] && errorout 'no results found'

if [[ "${#matches[@]}" -eq 1 ]]; then
  "$vim" "${vopts[@]}" "${matches[0]}"
else
  if $list; then
    edit_from_list "${matches[@]}"
  else
    "$vim" "${vopts[@]}" "${matches[0]}"
  fi
fi

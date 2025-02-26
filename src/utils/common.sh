#!/usr/bin/env bash

log() {
  echo -e "${1}${2}${NC}"
}

mark_start() {
  mark_type="${2:-$PROMPT}"
  log "${mark_type}" "------------------- START: $1 -------------------"
}

mark_end() {
  mark_type="${2:-$PROMPT}"
  log "${mark_type}" "------------------- END: $1 -------------------"
}

break_line() {
  echo -ne "\n"
}

prompt_variable() {
  log "${PROMPT}" "Please type ${1} ${NC}"
  read -r prompt_result
  log "${INFO}" "You provided ${prompt_result} as the input."
  log "${PROMPT}" "Press y|Y if this is correct. Press any other key to try again"
}

set_variable() {
  prompt_variable "${1}"
  pass="${2}"
  while read -r response; do
    case "$response" in
    ["Yy"])
      eval export "${pass}=${prompt_result}"
      break
      ;;
    *) prompt_variable "${1}" ;;
    esac
  done
}

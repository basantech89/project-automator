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

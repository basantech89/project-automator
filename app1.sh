#!/usr/bin/env bash

if ! test sudo -l -U $USER &>/dev/null; then
  echo yes
else
  echo no
fi

#!/bin/bash

pip_install () {
  local name=$1

  apt_install python-pip

  pip list | grep -e "^${name} " > /dev/null || (
    echo " --> install pip ${name}"
    silent_output sudo pip install --upgrade $name
  )
}

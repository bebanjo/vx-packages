#!/bin/bash

gem_install () {

  local name=$1

  gem query -q -i -n "^${name}$" > /dev/null || (
    echo " --> install gem $name"
    silent_output sudo gem install --no-ri --no-rdoc $name
  )
}

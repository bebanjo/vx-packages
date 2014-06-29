#!/bin/sh

apt_install () {
  for i in "$@" ; do
    dpkg -L $i > /dev/null 2> /dev/null || (
      echo " --> install package $i"
      silent_output sudo apt-get install -qy $i
    )
  done
}

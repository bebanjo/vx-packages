#!/bin/bash

. lib/inc.sh


upload () {
  pip_install pyrax

  cf_pyrax=$(cd bin/ ; pwd)/cf_pyrax.py
  src=debs
  dst=vexor.packages.trusty

  echo " --> upload packages in $src to $dst"
  SRC=debs DST=vexor.packages.trusty $cf_pyrax
}

upload

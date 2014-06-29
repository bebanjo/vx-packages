#!/bin/bash

silent_output () {
  local cmd=$@

  local log=$(mktemp)

  $cmd > $log 2> $log || (
    echo " --> failed: $cmd"
    echo ""
    cat $log
    rm $log
    exit 1
  )

  rm -f $log
}

clean_metadata () {
  echo " --> remove $1"
  rm -rf $1
}

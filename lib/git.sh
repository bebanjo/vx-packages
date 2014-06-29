#!/bin/bash

git_clone () {

  apt_install git-core

  local src=$1
  local dst=$2

  if [ ! -d $dst ] ; then
    echo " --> git clone $src"
    silent_output git clone $src $dst
  fi

  if [ -d $dst ] ; then
    echo " --> git up $dst"
    (
      cd $dst
      silent_output git fetch origin
      silent_output git reset --hard origin/master
    )
  fi
}

git_copy () {
  local ref=$1
  local src=$2
  local dst=$3
  local log=$(mktemp)

  rm -rf $dst
  mkdir -p $dst

  (
    cd $src
    git archive $ref | tar -x -C $dst > $log 2> $log || (
      echo " --> git export failed"
      echo ""
      cat $log
      rm $log
      exit 1
    )
  )
  rm -f $log
}

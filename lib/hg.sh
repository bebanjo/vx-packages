#!/bin/bash

hg_clone () {

  apt_install mercurial

  local src=$1
  local dst=$2

  if [ ! -d $dst ] ; then
    echo " --> hg clone $src to $dst"
    silent_output hg clone $src $dst
  fi

  if [ -d $dst ] ; then
    echo " --> hg pull $dst"
    silent_output hg pull -R $dst
  fi
}

hg_copy () {

  local ref=$1
  local src=$2
  local dst=$3

  if [ -d $dst ] ; then
    rm -rf $dst
  fi

  mkdir -p $dst
  echo " --> hg clone $ref to $dst"
  silent_output hg clone -u $ref $src $dst
}

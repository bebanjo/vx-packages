#!/bin/bash

set -e

packages_root=$(cd . ; pwd)
sources_root=$packages_root/sources
install_root=/opt/vexor/packages
build_root=$packages_root/build
deb_root=$packages_root/debs
metadata_root=$packages_root/meta
metadata_file=$deb_root/metadata.txt

. lib/utils.sh
. lib/apt.sh
. lib/gem.sh
. lib/pip.sh
. lib/hg.sh
. lib/git.sh
. lib/deb.sh
. lib/deps.sh
. lib/metadata.sh

if [ ! -d $install_root ] ; then
  echo " --> creates $install_root"
  sudo mkdir -p $install_root
fi

sudo chown $USER:$USER $install_root

if [ ! -d $build_root ] ; then
  echo " --> creates $build_root"
  mkdir -p $build_root
fi

if [ ! -d $deb_root ] ; then
  echo " --> creates $deb_root"
  mkdir -p $deb_root
fi


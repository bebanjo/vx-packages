#!/bin/bash

set -e

path=$(cd $1 ; pwd)
dir=$(mktemp -d)
cur=$(dirname $0)
cur=$(cd $cur ; pwd)

finddeps=$cur/find-elf-files.sh

cd $dir

mkdir debian
touch debian/control

$finddeps $path > .list
dpkg-shlibdeps -S $path $(cat .list) > /dev/null 2> /dev/null
cat debian/substvars | sed -e "s/shlibs:Depends=//"

cd /
rm -rf $dir

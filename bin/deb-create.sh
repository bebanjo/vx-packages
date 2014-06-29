#!/bin/bash

cur=$(cd $(dirname $0) ; pwd)
path=$(cd $1 ; pwd)

name=$2
version=$3
iter=$4

deps=$($cur/deb-depends.sh $path)

fpm="fpm -f -s dir -t deb $FPM_OPTS --name $name --version $version --iteration $iter -C /"

if [ "x$deps" = "x" ] ; then
  $fpm $path
else
  $fpm --deb-field "Depends: $deps" $path
fi


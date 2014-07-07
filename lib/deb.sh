#!/bin/bash

deb_package_name () {
  echo "vx-packages-${1}"
}

deb_package_file () {
  local name=$(deb_package_name $1)
  local ver=$2
  local iter=$3
  echo "${name}_${ver}-${iter}_amd64.deb"
}

deb_exists () {
  local file=$1

  test -f debs/$file
}

deb_create () {

  apt_install ruby1.9.1 ruby1.9.1-dev
  gem_install fpm

  local path=$1
  local name=$2
  local ver=$3
  local iter=$4

  debcreate=$(cd bin/ ; pwd)/deb-create.sh

  echo " --> creates $(deb_package_file $name $ver $iter)"
  (
    cd $deb_root
    silent_output $debcreate $path $(deb_package_name $name) $ver $iter
  )
}

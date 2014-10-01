#!/bin/bash

. lib/inc.sh


nodejs_download_path=$sources_root/nodejs
nodejs_iteration=${NODEJS_ITERATION:-1}

nodejs_package_file () {
  local id=$1
  local version=$2
  deb_package_file $id $version $nodejs_iteration
}

nodejs_create_activation () {
  local id=$1
  local version=$2

  local src=$install_root/$id

  echo " --> create activation script in $src"

  cat > $src/activate << EOF
export PATH=$src/bin:\$PATH
EOF
}

nodejs_download_binary () {
  local id=$1
  local version=$2
  local dst=$nodejs_download_path/$version
  local url=http://nodejs.org/dist/v${version}/node-v${version}-linux-x64.tar.gz

  mkdir -p $dst
  echo " --> download and extract $id to $dst"
  curl --fail --silent --show-error --tcp-nodelay --retry 3 $url | \
    ( cd $dst ; tar -zxf - )
}

nodejs_install_binary () {
  local id=$1
  local version=$2
  local src=$nodejs_download_path/$version/node-v${version}-linux-x64
  local dst=$install_root/$id

  mkdir -p $dst
  echo " --> install $id to $dst"
  (
    cd $src ;
    silent_output cp -vr $src/* $dst/
  )
}

nodejs_clean_tar () {
  local id=$1
  local version=$2
  local src=$nodejs_download_path/$version/node-v${version}-linux-x64.tar.gz

  echo " --> remove ${src}"
  rm -f $src
}

nodejs_build () {
  for ref in "$@" ; do

    local id="nodejs-${ref}"
    local version=$ref

    echo " === id:${id} version:${version} i:${nodejs_iteration}"

    deb_exists $(nodejs_package_file $id $version) && (
      echo " --> package for $id exists"
    )
    deb_exists $(nodejs_package_file $id $version) || (
      nodejs_clean_tar          $id $version
      nodejs_download_binary    $id $version
      nodejs_install_binary     $id $version
      nodejs_create_activation  $id $version
      deb_create                $install_root/$id $id $version $nodejs_iteration
    )
  done
}

nodejs_build $@

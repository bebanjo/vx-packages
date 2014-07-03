#!/bin/bash

. lib/inc.sh

rust_download_path=$sources_root/rust
rust_iteration=${RUST_ITERATION:-1}

rust_package_file () {
  local id=$1
  local version=$2
  deb_package_file $id $version $rust_iteration
}

rust_clean () {
  local id=$1
  local version=$2

  local src=$install_root/$id
  local dst=$rust_download_path

  if [ -d $src ] ; then
    echo " --> remove $src"
    rm -rf $src
  fi

  if [ -d $dst ] ; then
    echo " --> remove $dst"
    rm -rf $dst
  fi
}

rust_download_binary () {
  local id=$1
  local version=$2
  local dst=$rust_download_path
  local url=http://static.rust-lang.org/dist/${id}-x86_64-unknown-linux-gnu.tar.gz

  mkdir -p $dst
  echo " --> download and extract $id to $dst"
  curl --fail --silent --show-error --tcp-nodelay --retry 3 $url | \
    ( cd $dst ; tar -zxf - )
}

rust_install_binary () {
  local id=$1
  local version=$2
  local src=$rust_download_path/${id}-x86_64-unknown-linux-gnu
  local dst=$install_root/$id

  echo " --> install $id to $dst"
  (
    cd $src ;
    silent_output ./install.sh --prefix=$dst
  )
}

rust_create_activation () {
  local id=$1
  local build_id=$2
  local version=$3
  local dst=$install_root/$id

  echo " --> create activation script in $dst"

  cat > $dst/activate << EOF
export PATH=$dst/bin:\$PATH
export LD_LIBRARY_PATH=$dst/lib:$LD_LIBRARY_PATH
EOF
}

rust_create_deb () {
  local id=$1
  local version=$2
  local dst=$install_root/$id

  deb_create $dst $id $version $rust_iteration
}

rust_build () {
  for ref in "$@" ; do

    local id="rust-${ref}"
    local version=$ref

    case $ref in
      nightly)
        version="0.0.0"
        rust_iteration=$(date +%y%m%d).${rust_iteration}
        ;;
    esac

    echo " === id:${id} version:${version} i:${rust_iteration}"

    deb_exists $(rust_package_file $id $version) && (
      echo " --> package for $id exists"
    )
    deb_exists $(rust_package_file $id $version) || (
      rust_clean              $id $version
      rust_download_binary    $id $version
      rust_install_binary     $id $version
      rust_create_activation  $id $version
      rust_create_deb         $id $version
    )

    rust_clean $id $version
  done
}

rust_build $@

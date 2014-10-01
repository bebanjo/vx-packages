#!/bin/bash

. lib/inc.sh

go_download_path=$sources_root/go
go_metadata_root=$metadata_root/go
go_iteration=${GO_ITERATION:-1}

go_package_file () {
  local id=$1
  local version=$2
  deb_package_file $id $version $go_iteration
}

go_clean () {
  local id=$1
  local version=$2

  local src=$install_root/$id

  if [ -d $src ] ; then
    echo " --> remove $src"
    rm -rf $src
  fi
}

go_create_activation () {
  local id=$1
  local version=$2
  local src=$install_root/$id

  echo " --> create activation script in $src"

  cat > $src/activate << EOF
export GOROOT=$src
export GOPATH=$src/global
export PATH=\$GOPATH/bin:\$GOROOT/bin:\$PATH
EOF
}

go_install_tools () {
  local id=$1
  local version=$2
  local src=$install_root/$id

  mkdir -p $src/global

  echo " --> install github.com/golang/lint/golint"
  silent_output env GOPATH=$src/global PATH=$src/bin:$src/global/bin:$PATH go get github.com/golang/lint/golint
}

go_download_binary () {
  local id=$1
  local version=$2
  local dst=$go_download_path/$version
  local url=https://storage.googleapis.com/golang/go${version}.linux-amd64.tar.gz

  case $version in
    "1.1.2")
      url=https://go.googlecode.com/files/go${version}.linux-amd64.tar.gz
      ;;
  esac

  mkdir -p $dst
  echo " --> download and extract $id to $dst"
  curl --fail --silent --show-error --tcp-nodelay --retry 3 $url | \
    ( cd $dst ; tar -zxf - )
  rm -rf $dst/go/blog $dst/go/doc $dst/go/test
}

go_install_binary () {
  local id=$1
  local version=$2
  local src=$go_download_path/$version/go
  local dst=$install_root/$id

  mkdir -p $dst
  echo " --> install $id to $dst"
  (
    cd $src ;
    silent_output cp -vr $src/* $dst/
  )
}

go_build () {
  for ref in "$@" ; do

    local version=$(echo $ref | sed -e "s/[^\[:digit:].]//g")
    local id="go-${version}"

    case $ref in
      "tip")
        id="go-tip"
        version=0.0.0
        go_iteration=$(date +%y%m%d).${go_iteration}
        ;;
    esac

    echo " === id:${id} version:${version} i:${go_iteration}"

    deb_exists $(go_package_file $id $version) && (
      echo " --> package for $id exists"
    )

    deb_exists $(go_package_file $id $version) || (
      go_clean             $id $version
      go_download_binary   $id $version
      go_install_binary    $id $version
      go_create_activation $id $version
      deb_create           $install_root/$id $id $version $go_iteration
    )

    go_clean           $id $version
  done
}

go_build $@


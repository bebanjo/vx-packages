#!/bin/bash

. lib/inc.sh

go_source_repo=$sources_root/go
go_metadata_root=$metadata_root/go
go_iteration=${GO_ITERATION:-1}

go_package_file () {
  local id=$1
  local version=$2
  deb_package_file $id $version $go_iteration
}

go_compile () {
  local id=$1
  local version=$2

  local src=$install_root/$id

  (
    cd $src/src
    unset GOARCH && unset GOOS && unset GOPATH && unset GOBIN && unset GOROOT
    GO_INSTALL_ROOT=$src
    GOROOT=$src
    echo " --> build $id"

    silent_output ./make.bash

    cd $src
    rm -rf ".hg"
    rm -rf "doc"
    rm -rf "test"
  )
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

go_create_metadata () {
  local id=$1
  local version=$2
  local meta=$go_metadata_root/$id

  mkdir -p $go_metadata_root
  echo " --> create metadata for $id"
  echo "$id $(go_package_file $id $version)" > $meta
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

  echo " --> install code.google.com/p/go.tools/cmd/cover"
  silent_output env GOPATH=$src/global PATH=$src/bin:$src/global/bin:$PATH go get code.google.com/p/go.tools/cmd/cover

  echo " --> install github.com/golang/lint/golint"
  silent_output env GOPATH=$src/global PATH=$src/bin:$src/global/bin:$PATH go get github.com/golang/lint/golint
}

go_build () {
  hg_clone https://go.googlecode.com/hg/ $go_source_repo

  clean_metadata $go_metadata_root

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
      hg_copy              $ref $go_source_repo $install_root/$id
      go_compile           $id $version
      go_install_tools     $id $version
      go_create_activation $id $version
      deb_create           $install_root/$id $id $version $go_iteration
    )

    go_clean           $id $version
    go_create_metadata $id $version
  done

  process_metadata "go"
}

go_build $@


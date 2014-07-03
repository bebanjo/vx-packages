#!/bin/bash

. lib/inc.sh


nodejs_source_repo=$sources_root/nodejs
nodejs_metadata_root=$metadata_root/nodejs
nodejs_iteration=${NODEJS_ITERATION:-1}

nodejs_package_file () {
  local id=$1
  local version=$2
  deb_package_file $id $version $nodejs_iteration
}

nodejs_checkout_icu () {
  local id=$1
  local version=$2
  local dst=$build_root/$id

  apt_install subversion
  (
    cd $dst

    echo " --> checkout icu64 for $id to $dst"
    silent_output svn checkout --force --revision 214189 \
      http://src.chromium.org/svn/trunk/deps/third_party/icu46 \
      deps/v8/third_party/icu46
  )
}

nodejs_compile () {
  local id=$1
  local version=$2

  local src=$build_root/$id
  local dst=$install_root/$id

  echo " --> build nodejs in $src"

  (
    cd $src
    case $version in
    0.11*)
      nodejs_checkout_icu $id $version
      echo " --> configure $id with icu64"
      silent_output ./configure --with-icu-path=deps/v8/third_party/icu46/icu.gyp \
        --prefix=$dst
      ;;
    *)
      echo " --> configure $id"
      silent_output ./configure --prefix=$dst
      ;;
    esac

    echo " --> make $id"
    silent_output make -j$(nproc)

    echo " --> install $id"
    silent_output make install
  )
}


nodejs_clean_build_root () {
  local id=$1
  local version=$2

  local src=$build_root/$id

  if [ -d $src ] ; then
    echo " --> remove $src"
    rm -rf $src
  fi
}

nodejs_clean_install_root () {
  local id=$1
  local version=$2

  local src=$install_root/$id

  if [ -d $src ] ; then
    echo " --> remove $src"
    rm -rf $src
  fi
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

nodejs_create_metadata () {
  local id=$1
  local version=$2

  local src=$install_root/$id
  local meta=$nodejs_metadata_root/$id

  mkdir -p $nodejs_metadata_root
  echo " --> create metadata for $id"
  echo "$id $(nodejs_package_file $id $version)" > $meta
}

nodejs_copy_sources () {
  local id=$1
  local version=$2

  git_copy "v$version" $nodejs_source_repo $build_root/$id
}

nodejs_update_npm () {
  local id=$1
  local version=$2

  echo " --> update npm for $id"
  silent_output "$install_root/$id/bin/npm install -g npm"
}

nodejs_build () {
  git_clone https://github.com/joyent/node.git $nodejs_source_repo
  clean_metadata $nodejs_metadata_root

  for ref in "$@" ; do

    local id="nodejs-${ref}"
    local version=$ref

    echo " === id:${id} version:${version} i:${nodejs_iteration}"

    deb_exists $(nodejs_package_file $id $version) && (
      echo " --> package for $id exists"
    )
    deb_exists $(nodejs_package_file $id $version) || (
      nodejs_clean_install_root $id $version
      nodejs_copy_sources       $id $version
      nodejs_compile            $id $version
      nodejs_update_npm         $id $version
      nodejs_create_activation  $id $version
      deb_create                $install_root/$id $id $version $nodejs_iteration
    )
    nodejs_clean_install_root $id $version
    nodejs_clean_build_root   $id $version
    nodejs_create_metadata    $id $version
  done

  process_metadata "nodejs"
}

nodejs_build $@

#!/bin/bash

. lib/inc.sh

ruby_build_source_repo=$sources_root/ruby-build
ruby_build=$ruby_build_source_repo/bin/ruby-build
ruby_metadata_root=$metadata_root/ruby
ruby_iteration=${RUBY_ITERATION:-1}

ruby_package_file () {
  local id=$1
  local build_id=$2
  local version=$3

  deb_package_file $id $version $ruby_iteration
}

ruby_compile () {
  local id=$1
  local build_id=$2
  local version=$3
  local dst=$install_root/$id

  echo " --> build ruby $build_id in $dst"

  case $build_id in
    2.1.1)
      echo " --> compile ruby 2.1.1 with readline patch"
      curl -fsSL https://gist.github.com/mislav/a18b9d7f0dc5b9efc162.txt | \
        silent_output env CONFIGURE_OPTS="--disable-install-rdoc" $ruby_build --patch $build_id $dst
      ;;
    jruby*)
      apt_install openjdk-7-jre
      silent_output env CONFIGURE_OPTS="--disable-install-rdoc" $ruby_build $build_id $dst
      ;;
    *)
      silent_output env CONFIGURE_OPTS="--disable-install-rdoc" $ruby_build $build_id $dst
      ;;
  esac
}

ruby_clean () {
  local id=$1
  local build_id=$2
  local version=$3
  local dst=$install_root/$id

  if [ -d $dst ] ; then
    echo " --> remove $dst"
    sudo rm -rf $dst
  fi
}

ruby_create_activation () {
  local id=$1
  local build_id=$2
  local version=$3
  local dst=$install_root/$id

  echo " --> create activation script in $dst"

  cat > $dst/activate << EOF
export PATH=$dst/bin:\$PATH
EOF
}

ruby_create_metadata () {
  local id=$1
  local build_id=$2
  local version=$3
  local meta=$ruby_metadata_root/$id

  mkdir -p $ruby_metadata_root
  echo " --> save metadata for $id to $meta"
  echo "$id $(ruby_package_file $id $build_id $version)" > $meta
}

ruby_upgrade_rubygems () {
  local id=$1
  local build_id=$2
  local version=$3
  local dst=$install_root/$id

  echo " --> update rubygems in $dst"
  silent_output env PATH=$dst/bin:$PATH gem update --system
}

ruby_install_bundler () {
  local id=$1
  local build_id=$2
  local version=$3
  local dst=$install_root/$id

  PATH=$dst/bin:$PATH gem_install bundler --no-ri --no-rdoc
}

ruby_create_deb () {
  local id=$1
  local build_id=$2
  local version=$3
  local dst=$install_root/$id

  case $build_id in
    jruby*)
      echo " --> create jruby package with additional java dependencies"
      FPM_OPTS='-d java-runtime' deb_create $dst $id $version $ruby_iteration
      ;;
    *)
      deb_create $dst $id $version $ruby_iteration
      ;;
  esac
}

ruby_build () {
  git_clone https://github.com/sstephenson/ruby-build.git $ruby_build_source_repo
  clean_metadata $ruby_metadata_root

  for ref in "$@" ; do
    local id="ruby-$ref"
    local build_id="$ref"
    local version="$ref"

    case $build_id in
      jruby*)
        version=$(echo $ref | sed -e "s/jruby-//")
        ;;
      2.2.0-dev)
        id="ruby-head"
        build_id=$ref
        version=$(date +%y%m%d)
        ;;
    esac

    echo " === id:${id} build_id:${build_id} version:${version} i:${ruby_iteration}"

    deb_exists $(ruby_package_file $id $build_id $version) && (
      echo " --> package for $id exists"
    )
    deb_exists $(ruby_package_file $id $build_id $version) || (
      ruby_compile           $id $build_id $version
      ruby_create_activation $id $build_id $version
      ruby_upgrade_rubygems  $id $build_id $version
      ruby_install_bundler   $id $build_id $version
      ruby_create_deb        $id $build_id $version
    )
    ruby_clean           $id $build_id $version
    ruby_create_metadata $id $build_id $version
  done

  process_metadata "ruby"
}

ruby_build $@

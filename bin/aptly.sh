#!/bin/bash

set -e

repo_name=pkg.vexor.io
repo_dist=trusty
repo_arch="amd64"

if [ -f ~/.vexor/packages.sh ] ; then
  source ~/.vexor/packages.sh
fi

silent_output () {
  cmd=$@

  log=$(mktemp)

  $cmd > $log 2> $log || (
    echoerr "failed: $cmd"
    echoerr ""
    cat $log
    rm $log
    exit 1
  )

  rm -f $log
}

echoerr() {
  echo "$@" 1>&2;
}

notice () {
  echo " --> $1"
}

aptly_create_repo () {
  aptly repo show $repo_name > /dev/null || (
    notice "create $repo_name repo"
    silent_output aptly repo create -distribution $repo_dist -architectures=$repo_arch $repo_name
  )
}

aptly_publish_repo () {
  aptly publish list | grep $repo_name > /dev/null || (
    notice "create publish for $repo_name"
    silent_output aptly publish repo -skip-signing $repo_name
  )

  notice "updating $repo_name"
  silent_output aptly publish update -skip-signing $repo_dist
}

aptly_add_files () {
  files=$(mktemp -d)
  tar -x -C $files

  notice "add $(find $files -type f -name "*.deb" | wc -l ) files to $repo_name"
  silent_output aptly repo add $repo_name $files

  rm -rf $files
}

aptly_sync_mirror () {
  cf_pyrax=$(dirname $0)/cf_pyrax.py
  notice "sync with mirrors"
  SRC=~/.aptly/public/ DST=pkg.vexor.io $cf_pyrax
}

case $1 in
  add)
    aptly_create_repo
    aptly_add_files
    aptly_publish_repo
    aptly_sync_mirror
    ;;
  *)
    echo "Usage aptly.sh add"
esac

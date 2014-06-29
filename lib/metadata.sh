#!/bin/bash

compile_metadata () {
  local id=$1
  local dst=${deb_root}/${id}.txt

  echo " --> compile $id metadata to $dst"
  cat ${metadata_root}/${id}/* > ${dst}
}

clean_legacy_packages () {
  local id=$1
  local src=${deb_root}/${id}.txt

  local tmp=$(mktemp)

  echo " --> find legacy $id packages"

  cat $src | awk '{ print $2 }' > $tmp

  (
    find debs/ -name "vx-packages-${id}-*" -type f -printf "%P\n"
    cat $tmp $tmp
  ) | sort | uniq -u | (
    while read line ; do
      echo " --> remove $line"
      rm debs/$line
    done
  )
}

process_metadata() {
  local id=$1

  compile_metadata $id
  clean_legacy_packages $id
}

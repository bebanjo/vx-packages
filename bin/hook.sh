#!/bin/bash

set -e

base=$(cd (dirname $0) ; cd .. ; pwd)

git fetch
git reset --hard origin/master

exec bin/aptly.sh add

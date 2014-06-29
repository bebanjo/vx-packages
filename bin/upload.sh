#!/bin/bash

set -e

ssh vxpackages@pkg.vexor.io "cd vx-packages && git fetch && git reset --hard origin/master"
tar -c $1 | ssh vxpackages@pkg.vexor.io "vx-packages/bin/aptly.sh add"

#!/bin/bash

set -e

tar -c $1 | ssh vxpackages@pkg.vexor.io "Hi!"

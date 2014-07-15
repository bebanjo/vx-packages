#!/bin/bash

set -e

tar -c $1 | ssh repo@pkg.vexor.io "42"

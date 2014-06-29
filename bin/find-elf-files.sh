#!/bin/bash

find $1 -type f -name "*" -not -name "*.o" -exec sh -c '
  objdump -p $1 2> /dev/null > /dev/null && file $1 | grep -v "ELF 32-bit" > /dev/null
' sh {} \; -print



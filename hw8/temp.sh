#!/usr/bin/env bash
set -e

make clean
make all

grep -i --color=always error *.log || true
grep -i --color=always warn *.log || true
grep -i --color=always bad *.log || true

exit 0
#!/usr/bin/env bash
set -e

make clean
make all
grep error *.log
grep warn *.log
grep bad *.log

exit 0
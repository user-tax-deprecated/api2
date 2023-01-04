#!/usr/bin/env bash

DIR=$(dirname $(realpath "$0"))
cd $DIR

if [ -n "$1" ]; then
  cmd=$1
else
  cmd=./lib/index.js
fi

exec $cmd

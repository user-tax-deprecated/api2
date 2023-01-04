#!/usr/bin/env bash

DIR=$(dirname $(realpath "$0"))

ROOT=$(dirname $DIR)

cd $ROOT

mkdir -p lib

timeout=60

sleep 1
lua=lib/Redis/pkg/lua.js
while [ ! -f "$lua" ]; do
  if [ "$timeout" == 0 ]; then
    echo "ERROR: $lua NOT EXIST"
    exit 1
  fi
  echo "WAIT $lua"
  sleep 1
  ((timeout--))
done
set -ex
cd lib

watchexec --shell=none \
  --no-project-ignore \
  --exts coffee,js,mjs,json,wasm,txt,yaml \
  -w . \
  -r -- $ROOT/run.sh $@

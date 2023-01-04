#!/usr/bin/env bash
DIR=$(dirname $(realpath "$0"))

cd $DIR

rm -rf lib
set -ex

rsync_js=$DIR/sh/rsync.js

if [ ! -s "$rsync_js" ]; then
  bun run cep -- -c ./sh/rsync.coffee
fi

bun run concurrently -- \
  --kill-others \
  --raw \
  "$rsync_js" \
  "./sh/dev.sh"

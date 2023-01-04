#!/usr/bin/env bash

DIR=$(dirname $(realpath "$0"))
cd $DIR
set -ex

rm -rf lib

bun run cep -- -c src -o lib >/dev/null

./lib/Init/gen/build.js

cd lib

rpl "DEBUG\s*=\s*true" "DEBUG = false"

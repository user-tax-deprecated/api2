#!/usr/bin/env bash

DIR=$(dirname $(realpath "$0"))
cd $DIR
set -ex

./build.sh
./lib/Redis/init/merge.js
cd ./src/Pg/init
./uint.coffee
cd $DIR
./run.sh ./lib/Init/main.js

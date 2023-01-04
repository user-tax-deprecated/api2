#!/usr/bin/env bash

DIR=$(dirname $(realpath "$0"))
cd $DIR
set -ex


URL="http://127.0.0.1"

while true
do
#curl http://127.0.0.1/test --data-raw 232  -s -f
curl "$URL/captcha" \
  -H 'content-type: ' \
  -H 'origin: http://127.0.0.1:8888' \
  --data-raw '2' \
  --compressed \
  -s -f \
  --output - > /dev/null
done

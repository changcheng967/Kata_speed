#!/usr/bin/env bash
cd `dirname $0`
workdir=$(cd $(dirname $0); pwd)/config.json
if [ ! -f "$workdir" ];then
./yk_linker_mac config
chmod 777 config.json
fi
./yk_linker_mac run
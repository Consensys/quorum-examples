#!/bin/bash
killall geth bootnode constellation-node

if [ "`jps | grep tessera`" != "" ]
then
  jps | grep tessera-app | cut -d " " -f1 | xargs kill
else
  echo "tessera-app: no process found"
fi

#!/bin/bash
killall geth bootnode constellation-node

if [ "`jps | grep tessera-app`" != "" ]
then
  jps | grep tessera-app | cut -d " " -f1 | xargs kill
else
  echo "tessera-app: no process found"
fi

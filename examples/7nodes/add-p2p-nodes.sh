#!/bin/bash

# Helper script to add/update p2p peers from the permissioned-nodes.json (or static-nodes.js)
# in the case where the p2p layer gets disconnected, or when adding new nodes to the network:
# $> geth attach http://localhost:22000 
# > admin.peers
# []
# 
# This script can be run to add all the peers in the permissioned-nodes.json file.
# usage:
#  ./add-p2p-nodes.sh $PATH/TO/permissioned-nodes.json

PERMISSION_FILE="qdata/dd1/permissioned-nodes.json"
QUORUM_DATA_DIR="qdata"
if [ ! -z $1 ]; then
 PERMISSION_FILE=$1
else
 echo
 echo "  Using default permission file $PERMISSION_FILE."
 echo "  Base Quorum data directory is $QUORUM_DATA_DIR."
 echo "  to use a different permission file, pass it in as an arg:"
 echo
 echo "  > ./add-p2p-nodes.sh PATH/TO/permissioned-nodes.json"
 echo
fi

ADD_PEERS=$(sed -e 's/\[//g' -e 's/\]//g' -e 's/^ *//g' -e '/^$/d' -e 's/,//g' -e 's/^/admin.addPeer(/g' -e 's/,/;/g' -e 's/"$/");/g' $PERMISSION_FILE)
#echo $ADD_PEERS
#ADD_PEERS=$(cat $PERMISSION_FILE | jq '.[]' | sed -e 's/^/admin.addPeer(/g' -e 's/$/)/g')

echo
echo "  Adding peers from permission file $PERMISSION_FILE"
echo

echo "$ADD_PEERS" | while read -r addPeer; do 
  for i in {1..7}; do 
    PRIVATE_CONFIG=$QUORUM_DATA_DIR/c$i/tm.ipc geth --exec $addPeer attach ipc:$QUORUM_DATA_DIR/dd$i/geth.ipc  > /dev/null
  done
done

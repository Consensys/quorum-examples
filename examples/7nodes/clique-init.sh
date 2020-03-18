#!/bin/bash
set -u
set -e

function usage() {
  echo ""
  echo "Usage:"
  echo "    $0 [--numNodes numberOfNodes]"
  echo ""
  echo "Where:"
  echo "    numberOfNodes is the number of nodes to initialise (default = $numNodes)"
  echo ""
  exit -1
}

numNodes=7
while (( "$#" )); do
    case "$1" in
        --numNodes)
            re='^[0-9]+$'
            if ! [[ $2 =~ $re ]] ; then
                echo "ERROR: numberOfNodes value must be a number"
                usage
            fi
            numNodes=$2
            shift 2
            ;;
        --help)
            shift
            usage
            ;;
        *)
            echo "Error: Unsupported command line parameter $1"
            usage
            ;;
    esac
done

echo "[*] Cleaning up temporary data directories"
rm -rf qdata
mkdir -p qdata/logs

echo "[*] Configuring for $numNodes node(s)"
echo $numNodes > qdata/numberOfNodes

permNodesFile=./permissioned-nodes-${numNodes}.json
./create-permissioned-nodes.sh $numNodes

numPermissionedNodes=`grep "enode" ${permNodesFile}  |wc -l`
if [[ $numPermissionedNodes -ne $numNodes ]]; then
    echo "ERROR: $numPermissionedNodes nodes are configured in 'permissioned-nodes.json', but expecting configuration for $numNodes nodes"
    rm -f $permNodesFile
    exit -1
fi

genesisFile=./clique-genesis.json
tempGenesisFile=
if [[ "$numNodes" -lt 7 ]] ; then
    # number of nodes is less than 7, update genesis file
    tempGenesisFile="clique-genesis-${numNodes}.json"
    ./create-genesis.sh clique $tempGenesisFile $numNodes
    genesisFile=$tempGenesisFile
fi

for i in `seq 1 ${numNodes}`
do
    echo "[*] Configuring node ${i}"
    mkdir -p qdata/dd${i}/{keystore,geth}
    cp ${permNodesFile} qdata/dd${i}/static-nodes.json
    cp ${permNodesFile} qdata/dd${i}/permissioned-nodes.json
    cp keys/key${i} qdata/dd${i}/keystore
    cp raft/nodekey${i} qdata/dd${i}/geth/nodekey
    geth --datadir qdata/dd${i} init $genesisFile
done

#Initialise Tessera configuration
./tessera-init.sh

#Initialise Cakeshop configuration
./cakeshop-init.sh

rm -f $tempGenesisFile $permNodesFile

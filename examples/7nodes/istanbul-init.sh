#!/bin/bash
set -u
set -e

function usage() {
  echo ""
  echo "Usage:"
  echo "    $0 [--istanbulTools] [--numNodes numberOfNodes]"
  echo ""
  echo "Where:"
  echo "    --istanbulTools will perform initialisation from data generated using"
  echo "      istanbul-tools (note that permissioned-node.json and istanbul-genesis.json"
  echo "      files will be overwritten)"
  echo "    numberOfNodes is the number of nodes to initialise (default = $numNodes)"
  echo ""
  exit -1
}

function buildGenesisFile() {
    genesisFile=$1
    nodes=$2

    extraDataLine=`awk '/extraData/{print NR; exit}' ./istanbul-genesis.json`
    totalLines=`cat ./istanbul-genesis.json| wc -l`
    i=$(( $extraDataLine -1 ))
    j=$(( $totalLines - extraDataLine ))

    extraData=`cat ./istanbul-extradata.txt | grep ${nodes}node | cut -f2 -d ":"`

    cat ./istanbul-genesis.json | head -$i >> $genesisFile
    echo -e "\t \"extraData\": ${extraData}," >> $genesisFile
    cat ./istanbul-genesis.json | tail -$j >> $genesisFile
}


istanbulTools="false"
numNodes=7
while (( "$#" )); do
    case "$1" in
        --istanbulTools)
            istanbulTools="true"
            shift
            ;;
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

if [[ "$istanbulTools" == "true" ]]; then
    cp static-nodes.json permissioned-nodes.json
    cp genesis.json istanbul-genesis.json
fi

permNodesFile=./permissioned-nodes.json

tempPermNodesFile=./permissioned-nodes-${numNodes}.json
if test -f "$tempPermNodesFile"; then
    permNodesFile=$tempPermNodesFile
fi

genesisFile=./istanbul-genesis.json
tempGenesisFile=

if [[ "$numNodes" -ne 7 ]] ; then
    # number of nodes is less than 7, update genesis file
    tempGenesisFile="istanbul-genesis-${numNodes}.json"
    buildGenesisFile $tempGenesisFile $numNodes
    genesisFile=$tempGenesisFile
fi

numPermissionedNodes=`grep "enode" ${permNodesFile} |wc -l`
if [[ $numPermissionedNodes -ne $numNodes ]]; then
    echo "ERROR: $numPermissionedNodes nodes are configured in 'permissioned-nodes.json', but expecting configuration for $numNodes nodes"
    exit -1
fi

for i in `seq 1 ${numNodes}`
do
    echo "[*] Configuring node ${i}"
    mkdir -p qdata/dd${i}/{keystore,geth}
    if [[ "$istanbulTools" == "true" ]]; then
        iMinus1=$(($i - 1))
        cp ${iMinus1}/nodekey qdata/dd${i}/geth/nodekey
    else
        cp raft/nodekey${i} qdata/dd${i}/geth/nodekey
    fi
    cp ${permNodesFile} qdata/dd${i}/static-nodes.json
    if ! [[ -z "${STARTPERMISSION+x}" ]] ; then
        cp ${permNodesFile} qdata/dd${i}/permissioned-nodes.json
    fi
    cp keys/key${i} qdata/dd${i}/keystore
    geth --datadir qdata/dd${i} init $genesisFile
done

#Initialise Tessera configuration
./tessera-init.sh

#Initialise Cakeshop configuration
./cakeshop-init.sh
rm -f $tempGenesisFile
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
  echo "      istanbul-tools (note that permissioned-node.json and qbft-genesis.json"
  echo "      files will be overwritten)"
  echo "    numberOfNodes is the number of nodes to initialise (default = $numNodes)"
  echo ""
  exit -1
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
    cp genesis.json qbft-genesis.json
fi

permNodesFile=./permissioned-nodes.json

permNodesFile=./permissioned-nodes-${numNodes}.json
./create-permissioned-nodes.sh $numNodes

numPermissionedNodes=`grep "enode" ${permNodesFile} |wc -l`
if [[ $numPermissionedNodes -ne $numNodes ]]; then
    echo "ERROR: $numPermissionedNodes nodes are configured in 'permissioned-nodes.json', but expecting configuration for $numNodes nodes"
    rm -f $permNodesFile
    exit -1
fi

genesisFile=./qbft-genesis.json
tempGenesisFile=
if [[ "$istanbulTools" == "false" ]] && [[ "$numNodes" -lt 7 ]] ; then
    # number of nodes is less than 7, update genesis file
    tempGenesisFile="qbft-genesis-${numNodes}.json"
    ./create-genesis.sh qbft $tempGenesisFile $numNodes
    genesisFile=$tempGenesisFile
fi

if [[ "${PRIVACY_ENHANCEMENTS:-false}" == "true" ]]; then
  echo "adding privacyEnhancementsBlock to genesis.config"
  tempGenesisFile="qbft-genesis-${numNodes}-pe.json"
  jq '.config.privacyEnhancementsBlock = 0' $genesisFile > $tempGenesisFile
  genesisFile=$tempGenesisFile
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
rm -f $tempGenesisFile $permNodesFile

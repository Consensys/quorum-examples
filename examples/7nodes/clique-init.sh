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

function createPermissionedNodesJson(){
    nodes=$1
    i=$(( ${nodes} + 1))

    permFile=./permissioned-nodes-${nodes}.json
    creFile=true
    if [[ "$nodes" -le 7 ]] ; then
        # check if file exists and the enode count is matching
        if test -f "$permFile"; then
            numPermissionedNodes=`grep "enode" ${permFile} |wc -l`
            if [[ $numPermissionedNodes -ne $nodes ]]; then
                rm -f ${permFile}
            else
                creFile=false
            fi
        fi
    else
        cp ./permissioned-nodes.json ${permFile}
        creFile=false
    fi
    if [[ "$creFile" == "true" ]]; then
        cat ./permissioned-nodes.json | head -${nodes} >> ./${permFile}
        cat ./permissioned-nodes.json | head -$i | tail -1 | cut -f1 -d "," >> ./${permFile}
        cat ./permissioned-nodes.json | tail -1 >> ./${permFile}
    fi
}

function buildGenesisFile() {
    genesisFile=$1
    nodes=$2

    extraDataLine=`awk '/extraData/{print NR; exit}' ./clique-genesis.json`
    totalLines=`cat ./clique-genesis.json | wc -l`
    i=$(( $extraDataLine -1 ))
    j=$(( $totalLines - extraDataLine ))

    extraData=`cat ./clique-extradata.txt | grep ${nodes}node | cut -f2 -d ":"`

    cat ./clique-genesis.json | head -$i >> $genesisFile
    echo -e "\t \"extraData\": ${extraData}," >> $genesisFile
    cat ./clique-genesis.json | tail -$j >> $genesisFile
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
createPermissionedNodesJson $numNodes

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
    buildGenesisFile $tempGenesisFile $numNodes
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

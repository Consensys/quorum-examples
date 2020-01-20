#!/bin/bash
set -u
set -e

function usage() {
  echo ""
  echo "Usage:"
  echo "    $0 [tessera | tessera-remote | constellation] [--tesseraOptions \"options for Tessera start script\"]"
  echo ""
  echo "Where:"
  echo "    tessera | tessera-remote | constellation (default = tessera): specifies which privacy implementation to use"
  echo "    --tesseraOptions: allows additional options as documented in tessera-start.sh usage which is shown below:"
  echo ""
  echo "Note that this script will examine the file qdata/numberOfNodes to"
  echo "determine how many nodes to start up. If the file doesn't exist"
  echo "then 7 nodes will be assumed"
  echo ""
  ./tessera-start.sh --help
  exit -1
}

function performValidation() {
    # Warn the user if chainId is same as Ethereum main net (see https://github.com/jpmorganchase/quorum/issues/487)
    genesisFile=$1
    NETWORK_ID=$(cat $genesisFile | tr -d '\r' | grep chainId | awk -F " " '{print $2}' | awk -F "," '{print $1}')

    if [ $NETWORK_ID -eq 1 ]
    then
        echo "  Quorum should not be run with a chainId of 1 (Ethereum mainnet)"
        echo "  please set the chainId in the $genesisFile to another value "
        echo "  1337 is the recommend ChainId for Geth private clients."
    fi

    # Check that the correct geth executable is on the path
    set +e
    if [ "`which geth`" == "" ]; then
        echo "ERROR: geth executable not found. Ensure that Quorum geth is on the path."
        exit -1
    else
        GETH_VERSION=`geth version |grep -i "Quorum Version"`
        if [ "$GETH_VERSION" == "" ]; then
            echo "ERROR: you appear to be running with upstream geth. Ensure that Quorum geth is on the PATH (before any other geth version)."
            exit -1
        fi
        echo "  Found geth: \"$GETH_VERSION\""
    fi
    set -e
}

privacyImpl=tessera
tesseraOptions=
while (( "$#" )); do
    case "$1" in
        tessera)
            privacyImpl=tessera
            shift
            ;;
        constellation)
            privacyImpl=constellation
            shift
            ;;
        tessera-remote)
            privacyImpl="tessera-remote"
            shift
            ;;
        --tesseraOptions)
            tesseraOptions=$2
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

# Perform any necessary validation
performValidation istanbul-genesis.json

mkdir -p qdata/logs

numNodes=7
if [[ -f qdata/numberOfNodes ]]; then
    numNodes=`cat qdata/numberOfNodes`
fi

if [ "$privacyImpl" == "tessera" ]; then
  echo "[*] Starting Tessera nodes"
  ./tessera-start.sh ${tesseraOptions}
elif [ "$privacyImpl" == "constellation" ]; then
  echo "[*] Starting Constellation nodes"
  ./constellation-start.sh
elif [ "$privacyImpl" == "tessera-remote" ]; then
  echo "[*] Starting tessera nodes"
  ./tessera-start-remote.sh ${tesseraOptions}
else
  echo "Unsupported privacy implementation: ${privacyImpl}"
  usage
fi

echo "[*] Starting ${numNodes} Ethereum nodes with ChainID and NetworkId of $NETWORK_ID"
QUORUM_GETH_ARGS=${QUORUM_GETH_ARGS:-}
set -v
ARGS="--nodiscover --istanbul.blockperiod 5 --networkid $NETWORK_ID --syncmode full --mine --minerthreads 1 --rpc --rpccorsdomain=* --rpcvhosts=* --rpcaddr 0.0.0.0 --rpcapi admin,eth,debug,miner,net,shh,txpool,personal,web3,quorum,istanbul,quorumPermission --unlock 0 --password passwords.txt $QUORUM_GETH_ARGS"

basePort=21000
baseRpcPort=22000
for i in `seq 1 ${numNodes}`
do
    port=$(($basePort + ${i} - 1))
    rpcPort=$(($baseRpcPort + ${i} - 1))
    permissioned=
    if ! [[ -z "${STARTPERMISSION+x}" ]] ; then
        permissioned="--permissioned"
    fi

    PRIVATE_CONFIG=qdata/c${i}/tm.ipc nohup geth --datadir qdata/dd${i} ${ARGS} ${permissioned} --rpcport ${rpcPort} --port ${port} 2>>qdata/logs/${i}.log &
done

set +v

echo
echo "All nodes configured. See 'qdata/logs' for logs, and run e.g. 'geth attach qdata/dd1/geth.ipc' to attach to the first Geth node."
echo "To test sending a private transaction from Node 1 to Node 7, run './runscript.sh private-contract.js'"

exit 0

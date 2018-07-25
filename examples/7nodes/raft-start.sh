#!/bin/bash
set -u
set -e

NETWORK_ID=$(cat genesis.json | grep chainId | awk -F " " '{print $2}' | awk -F "," '{print $1}')

if [ $NETWORK_ID -eq 1 ]
then
	echo "  Quorum should not be run with a chainId of 1 (Ethereum mainnet)"
        echo "  please set the chainId in the genensis.json to another value "
	echo "  1337 is the recommend ChainId for Geth private clients."
fi

mkdir -p qdata/logs
echo "[*] Starting Constellation nodes"
./constellation-start.sh

echo "[*] Starting Ethereum nodes with ChainID and NetworkId of $NETWORK_ID"
set -v
ARGS="--nodiscover --verbosity 5 --networkid $NETWORK_ID --raft --rpc --rpcaddr 0.0.0.0 --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum --emitcheckpoints"
PRIVATE_CONFIG=qdata/c1/tm.ipc nohup geth --datadir qdata/dd1 $ARGS --permissioned --raftport 50401 --rpcport 22000 --port 21000 --unlock 0 --password passwords.txt 2>>qdata/logs/1.log &
PRIVATE_CONFIG=qdata/c2/tm.ipc nohup geth --datadir qdata/dd2 $ARGS --permissioned --raftport 50402 --rpcport 22001 --port 21001 --unlock 0 --password passwords.txt 2>>qdata/logs/2.log &
PRIVATE_CONFIG=qdata/c3/tm.ipc nohup geth --datadir qdata/dd3 $ARGS --permissioned --raftport 50403 --rpcport 22002 --port 21002 --unlock 0 --password passwords.txt 2>>qdata/logs/3.log &
PRIVATE_CONFIG=qdata/c4/tm.ipc nohup geth --datadir qdata/dd4 $ARGS --permissioned --raftport 50404 --rpcport 22003 --port 21003 --unlock 0 --password passwords.txt 2>>qdata/logs/4.log &
PRIVATE_CONFIG=qdata/c5/tm.ipc nohup geth --datadir qdata/dd5 $ARGS --raftport 50405 --rpcport 22004 --port 21004 --unlock 0 --password passwords.txt 2>>qdata/logs/5.log &
PRIVATE_CONFIG=qdata/c6/tm.ipc nohup geth --datadir qdata/dd6 $ARGS --raftport 50406 --rpcport 22005 --port 21005 --unlock 0 --password passwords.txt 2>>qdata/logs/6.log &
PRIVATE_CONFIG=qdata/c7/tm.ipc nohup geth --datadir qdata/dd7 $ARGS --raftport 50407 --rpcport 22006 --port 21006 --unlock 0 --password passwords.txt 2>>qdata/logs/7.log &
set +v

echo
echo "All nodes configured. See 'qdata/logs' for logs, and run e.g. 'geth attach qdata/dd1/geth.ipc' to attach to the first Geth node."
echo "To test sending a private transaction from Node 1 to Node 7, run './runscript.sh private-contract.js'"

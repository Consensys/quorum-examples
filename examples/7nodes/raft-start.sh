#!/bin/bash
set -u
set -e

GLOBAL_ARGS="--raft --rpc --rpcaddr 0.0.0.0 --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum"

echo "[*] Starting Constellation nodes"
nohup constellation-node tm1.conf 2>> qdata/logs/constellation1.log &
sleep 1
nohup constellation-node tm2.conf 2>> qdata/logs/constellation2.log &
nohup constellation-node tm3.conf 2>> qdata/logs/constellation3.log &
nohup constellation-node tm4.conf 2>> qdata/logs/constellation4.log &
nohup constellation-node tm5.conf 2>> qdata/logs/constellation5.log &
nohup constellation-node tm6.conf 2>> qdata/logs/constellation6.log &
nohup constellation-node tm7.conf 2>> qdata/logs/constellation7.log &

sleep 1

echo "[*] Starting node 1"
PRIVATE_CONFIG=tm1.conf nohup geth --datadir qdata/dd1 $GLOBAL_ARGS --rpcport 22000 --port 21000 --unlock 0 --password passwords.txt 2>>qdata/logs/1.log &

echo "[*] Starting node 2"
PRIVATE_CONFIG=tm2.conf nohup geth --datadir qdata/dd2 $GLOBAL_ARGS --rpcport 22001 --port 21001 2>>qdata/logs/2.log &

echo "[*] Starting node 3"
PRIVATE_CONFIG=tm3.conf nohup geth --datadir qdata/dd3 $GLOBAL_ARGS --rpcport 22002 --port 21002 2>>qdata/logs/3.log &

echo "[*] Starting node 4"
PRIVATE_CONFIG=tm4.conf nohup geth --datadir qdata/dd4 $GLOBAL_ARGS --rpcport 22003 --port 21003 2>>qdata/logs/4.log &

echo "[*] Starting node 5"
PRIVATE_CONFIG=tm5.conf nohup geth --datadir qdata/dd5 $GLOBAL_ARGS --rpcport 22004 --port 21004 2>>qdata/logs/5.log &

echo "[*] Starting node 6"
PRIVATE_CONFIG=tm6.conf nohup geth --datadir qdata/dd6 $GLOBAL_ARGS --rpcport 22005 --port 21005 2>>qdata/logs/6.log &

echo "[*] Starting node 7"
PRIVATE_CONFIG=tm7.conf nohup geth --datadir qdata/dd7 $GLOBAL_ARGS --rpcport 22006 --port 21006 2>>qdata/logs/7.log &

echo "[*] Waiting for nodes to start"
sleep 10
echo "[*] Sending first transaction"
PRIVATE_CONFIG=tm1.conf geth --exec 'loadScript("script1.js")' attach ipc:qdata/dd1/geth.ipc

echo "All nodes configured. See 'qdata/logs' for logs, and run e.g. 'geth attach qdata/dd1/geth.ipc' to attach to the first Geth node"

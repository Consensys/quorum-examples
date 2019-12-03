#!/bin/bash
PRIVATE_CONFIG=qdata/c5/tm.ipc nohup geth --datadir qdata/dd5 --nodiscover --verbosity 5 --networkid 10 --raft --rpc --rpccorsdomain=* --rpcvhosts=* --rpcaddr 0.0.0.0 --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum,raft,quorumPermission --emitcheckpoints --unlock 0 --password passwords.txt --permissioned --raftport 50405 --rpcport 22004 --port 21004 --raftjoinexisting 5 2>>qdata/logs/5.log &


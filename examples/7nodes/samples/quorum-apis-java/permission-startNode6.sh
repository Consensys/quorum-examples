#!/bin/bash
PRIVATE_CONFIG=qdata/c6/tm.ipc nohup geth --datadir qdata/dd6 --nodiscover --verbosity 5 --networkid 10 --raft --rpc --rpccorsdomain=* --rpcvhosts=* --rpcaddr 0.0.0.0 --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum,raft,quorumPermission --emitcheckpoints --unlock 0 --password passwords.txt --permissioned --raftport 50406 --rpcport 22005 --port 21005 --raftjoinexisting 6 2>>qdata/logs/6.log &


#!/bin/bash
PRIVATE_CONFIG=qdata/c6/tm.ipc nohup geth --datadir qdata/dd6 --nodiscover --verbosity 5 --networkid 10 --raft --http --http.corsdomain=* --http.vhosts=* --http.addr 0.0.0.0 --http.api admin,db,eth,debug,miner,net,txpool,personal,web3,raft,quorumPermission --emitcheckpoints --unlock 0 --password passwords.txt --permissioned --raftport 50406 --http.port 22005 --port 21005 --raftjoinexisting 6 2>>qdata/logs/6.log &


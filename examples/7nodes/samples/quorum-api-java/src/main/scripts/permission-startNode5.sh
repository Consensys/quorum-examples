#!/bin/bash
PRIVATE_CONFIG=qdata/c5/tm.ipc nohup geth --datadir qdata/dd5 --nodiscover --verbosity 5 --networkid 10 --raft --http --http.corsdomain=* --http.vhosts=* --http.addr 0.0.0.0 --http.api admin,db,eth,debug,miner,net,txpool,personal,web3,raft,quorumPermission --emitcheckpoints --unlock 0 --password passwords.txt --permissioned --raftport 50405 --http.port 22004 --port 21004 --raftjoinexisting 5 2>>qdata/logs/5.log &


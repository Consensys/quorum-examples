#!/bin/bash

set -e

HOST=localhost

display_usage() {
    printf "\n\n======= Either run the script with default setup by exeucting 'run_nodes.sh default' OR Set up the following parameters=======\n"
    printf "\nUsage:[$0 GETH_BINARY DATADIR_BASE PERMISSONED_NODES, NODE_PERMISSIONED_NODES]. \n where:
                        GETH_BINARY is the geth command you want to use
                        DATADIR_BASE is the folder under which node specific datadir will be created
                        PERMISSONED_NODES is the number of Permissioned Nodes.
                        NODE_PERMISSIONED_NODES is number of non permissioned nodes.\n"
    printf "\nFor Example:[$0 /usr/local/bin/geth /Users/Library/Ethereum/chaindata 5 3] will start 5 permissioned nodes with node numbers from 1 to 5 &
                3 non permissioned nodes from 5 to 8\n\n"

    }

validate_inputs()
{
  if [ ! -x $1  ]; then
      echo " Geth $1 does exist. Please specify a valid geth executable"
      exit 1
  else:
      echo "Will use $1 for geth exectuable"
  fi

  if [  ! -d $2  ]; then
      echo " BASE DATADIR $2 does not exist. Please specify a valid BASE DATADIR."
      exit 1
  else:
      echo "Will use $2 for Nodes datadir."
  fi

   printf "Nodes: $3, $4\n"
  if [ "$3" -le 0 ] ; then
    echo "Invalid nodes count. Please specify a number greater than 0 and less than $4."
    exit 1
  fi

 if [ 10 -lt $4  ]; then
    echo "Too many nodes to run for an example. Please specify a number less than 10."
    exit 1
  fi

}

initialize()
{

    ###############################################
    ### ENVIRONMENT VARIBALES #############
    echo "Initializing Environment "
    QUORUM_BIN=$1
    DATADIR_BASE=$2
    BOOTNODE_KEYHEX=77bd02ffa26e3fb8f324bda24ae588066f1873d95680104de5bc2db9e7b2e510
    BOOTNODE_ENODE=enode://6433e8fb82c4638a8a6d499d40eb7d8158883219600bfd49acb968e3a37ccced04c964fa87b3a78a2da1b71dc1b90275f4d055720bb67fad4a118a56925125dc@[127.0.0.1]:33445
    NETWORK_ID=1441
    LOGDIR=$DATADIR_BASE/logs
    PERMISSIONED_CONFIG="permissioned-nodes.json"
    BASE_PORT=3030
    BASE_RPC_PORT=854

    VERBOSITY="--vmodule p2p=5" # Needed to view the debug logs
    # VERBOSITY=""
    PERMISSIONED="--permissioned" #

    #PERMISSIONED="" - set PERMISSIONED to "" if running in non permissioned mode
    ###############################################
    mkdir -p $LOGDIR
    mkdir -p $DATADIR_BASE
    printf "Initialization done. QUORUM_BIN: $QUORUM_BIN DATADIR_BASE: $DATADIR_BASE\n"
}

start_bootnode()
{
    echo -n "[*] Starting bootnode... "
    nohup bootnode --nodekeyhex "$BOOTNODE_KEYHEX" --addr="127.0.0.1:33445" 2>>$LOGDIR/bootnode.log &
    echo -n "waiting... "
    sleep 6
    echo -n "done"
}

ALL_NODES=

run_permissioned_nodes()
{
    # run in permssioned node
    START=1
    END=$1

    echo "Running Permissioned Nodes"
    PERMISSIONED_NODES+="["
    for ((NODE_NUM=START;NODE_NUM<=END;NODE_NUM++)); do
        #clean up previous logs
        cp /dev/null $LOGDIR/node$NODE_NUM.log
        echo "======== Starting Node: =====  " $NODE_NUM
        LISTEN_PORT=$BASE_PORT$NODE_NUM
        RPC_PORT=$BASE_RPC_PORT$NODE_NUM
        DATADIR=$(readlink -f $DATADIR_BASE/$NODE_NUM)
        LOGFILE=$(readlink -f $LOGDIR/node$NODE_NUM.log)
        printf "Starting $NODE_NUM with datadir $DATADIR on $HOST:$LISTEN_PORT with RPC Port http://$HOST:$RPC_PORT\n"
        COMMAND="$QUORUM_BIN $PERMISSIONED --datadir $DATADIR $VERBOSITY --identity node_$NODE_NUM --networkid=$NETWORK_ID --rpc --port $LISTEN_PORT --rpcaddr $HOST --rpcport $RPC_PORT --bootnodes $BOOTNODE_ENODE"
        mkdir -p $DATADIR
        echo "nohup $COMMAND 2>> $LOGFILE &" > $DATADIR/start.sh
        chmod 755 $DATADIR/start.sh
        $DATADIR/start.sh
        sleep 5
        ERROR=`awk '/Fatal/ {print $1}' $LOGFILE`
        NODE_ID=`awk '/Listening, enode/{ print $5 }' $LOGFILE`
        printf "Started Permissioned node $NODE_NUM with ${NODE_ID}\n"
        ALL_NODES+="\"$NODE_ID\","
        if [ ${NODE_NUM} == ${END} ]; then
            PERMISSIONED_NODES+="\"$NODE_ID\""
        else
            PERMISSIONED_NODES+="\"$NODE_ID\","
        fi

    done
    PERMISSIONED_NODES+="]"
}


run_nonpermissioned_nodes()
{
    # run in permssioned node
    START=$1
    END=START+$2
    echo "Running unpermissioned Nodes"
    for ((NODE_NUM=START+1;NODE_NUM<=END;NODE_NUM++)); do
        #clean up previous logs
        cp /dev/null $LOGDIR/node$NODE_NUM.log
        echo "======== Starting Node: =====  " $NODE_NUM
        LISTEN_PORT=$BASE_PORT$NODE_NUM
        RPC_PORT=$BASE_RPC_PORT$NODE_NUM
        DATADIR="$DATADIR_BASE/"$NODE_NUM
        LOGFILE=$LOGDIR/node$NODE_NUM.log
        printf "#Starting $NODE_NUM with datadir $DATADIR on $HOST:$LISTEN_PORT\n"
        COMMAND="$QUORUM_BIN $PERMISSIONED --datadir $DATADIR $VERBOSITY --identity node_$NODE_NUM --networkid=$NETWORK_ID --rpc --port $LISTEN_PORT --rpcaddr $HOST --rpcport $RPC_PORT"
        printf "Executing command $COMMAND\n"
        $COMMAND 2>>  $LOGFILE &
        sleep 10
        ERROR=`awk '/Fatal/ {print $1}' $LOGFILE`
        NODE_ID=`awk '/Listening, enode/{ print $5 }' $LOGFILE`
        ALL_NODES+="\"$NODE_ID\","
        printf "Started Unpermissioned node $NODE_NUM with ${NODE_ID}\n"
    done

    echo $ALL_NODES > all_nodes


}

update_permissions_file()
{

   START=1
   END=$1
   echo $PERMISSIONED_NODES > $PERMISSIONED_CONFIG
   for ((NODE_NUM=START;NODE_NUM<=END;NODE_NUM++)); do
        DATADIR="$DATADIR_BASE/"$NODE_NUM
        echo "copying $PERMISSIONED_CONFIG to $DATADIR"
        cp  $PERMISSIONED_CONFIG $DATADIR
    done
}

# allowed_pattern="ALLOWED-BY"
# denied_pattern="DENIED_BY"

verify_permissioning()
{
    echo "Verify permissioning"
    # grep ALLOWED-BY node*.log

}

set_defaults_args()
{

  QUORUM_BIN='/usr/local/bin/geth'
  mkdir -p qdata
  DATADIR_BASE="./qdata"


}

#### Run the main script
PERMISSIONED_NODES=()


run_default(){

    printf "**** Validating inputs  *** \n"
    # QUORUM_BIN='/usr/local/bin/geth'
    QUORUM_BIN='/usr/local/bin/geth'
    mkdir -p qdata
    DATADIR_BASE='./qdata'
    PERM_NODES=5
    NON_PERM_NODES=3

}

run_custom(){

    printf "**** Validating inputs  *** $1, $2, $3, $4\n"
    QUORUM_BIN=$1
    DATADIR_BASE=$2
    PERM_NODES=$3
    NON_PERM_NODES=$4
    initialize $QUORUM_BIN $DATADIR_BASE
    validate_inputs $QUORUM_BIN $DATADIR_BASE $PERM_NODES $NON_PERM_NODES

}

cleanup(){
    printf "cleaning up logs"
    rm -rf logs/
}

if [[ $1 == 'default' ]]; then
    printf "*** Running dafault setup ***"
    run_default
else
    printf "*** Running Custom setup"
    if [  $# -ne 4 ]
    then
        display_usage
        exit 1
    fi
    run_custom $1 $2 $3 $4
fi

set -u

printf "**** Initialize Environment **** \n"
initialize $QUORUM_BIN $DATADIR_BASE

start_bootnode

printf "\n*** Starting Permissioned Nodes **** \n"
run_permissioned_nodes $PERM_NODES
printf "\n*** All permissioned nodes Started. Please check the output for any errors **** \n"

printf "\n*** Starting UnPermissioned Nodes **** \n"
run_nonpermissioned_nodes $PERM_NODES $NON_PERM_NODES
printf "\n*** All Unpermissoned nodes Started. Please check the output for any errors **** \n"

printf "\n**** Update permissions config on each node *** \n"
update_permissions_file $PERM_NODES
printf "\n **** End of Script **** \n"


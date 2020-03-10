#!/bin/bash
set -u
set -e

function usage() {
  echo ""
  echo "Usage:"
  echo "    $0 [raft | istanbul | clique] [--numNodes numberOfNodes]"
  echo ""
  echo "Where:"
  echo "    raft | istanbul | clique (default = raft): specifies which consensus algorithm to use"
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

consensus=raft
numNodes=7
while (( "$#" )); do
    case "$1" in
        raft)
            consensus=raft
            shift
            ;;
        istanbul)
            consensus=istanbul
            shift
            ;;
        clique)
            consensus=clique
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

if  [[ "$numNodes" -gt 7 ]] ; then
    echo "number of node greater than 7 not supported"
    exit -1
fi

# check if the number of nodes is less than 7. if yes dynamically create the permissioned-nodes.json
createPermissionedNodesJson $numNodes

./$consensus-init.sh --numNodes $numNodes
rm -f ./permissioned-nodes-${numNodes}.json
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

./$consensus-init.sh --numNodes $numNodes
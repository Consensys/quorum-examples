#!/bin/bash
set -u
set -e

function usage() {
  echo ""
  echo "Usage:"
  echo "    $0 [raft | istanbul | clique] [tessera | constellation] [--tesseraOptions \"options for Tessera start script\"] [--blockPeriod blockPeriod] [--verbosity verbosity]"
  echo ""
  echo "Where:"
  echo "    raft | istanbul | clique : specifies which consensus algorithm to use"
  echo "    tessera | constellation (default = constellation): specifies which privacy implementation to use"
  echo "    --tesseraOptions: allows additional options as documented in tessera-start.sh usage which is shown below:"
  echo "    --blockPeriod: block period default is 5 seconds for IBFT and 50ms for Raft"
  echo "    --verbosity: verbosity for logging default is 3"

  echo ""
  ./tessera-start.sh --help
  exit -1
}

privacyImpl=tessera
tesseraOptions=
consensus=
blockPeriod=
verbosity=3
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
        tessera)
            privacyImpl=tessera
            shift
            ;;
        constellation)
            privacyImpl=constellation
            shift
            ;;
        --tesseraOptions)
            tesseraOptions=$2
            shift 2
            ;;
        --blockPeriod)
            blockPeriod=$2
            shift 2
            ;;
        --verbosity)
            verbosity=$2
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


if [ "$consensus" == "" ]; then
    echo "Error: consensus not selected"
    exit 1
fi

if [ "$blockPeriod" == "" ]; then
    if [ "$consensus" == "raft" ]; then
        blockPeriod=50
    elif [ "$consensus" == "istanbul" ]; then
        blockPeriod=5
    fi
fi

if [ "$consensus" == "raft" ] && [ "$blockPeriod" -lt 50 ]; then
    blockPeriod=50
fi

if [ "$consensus" == "clique" ]; then
    ./$consensus-start.sh $privacyImpl $tesseraOptions --verbosity $verbosity
else
    ./$consensus-start.sh $privacyImpl $tesseraOptions --verbosity $verbosity --blockPeriod $blockPeriod
fi
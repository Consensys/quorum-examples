#!/usr/bin/env bash

localPath=$(pwd)
roles="NONE"
voter="NONE"
accounts="NONE"
nodes="NONE"
org="NONE"
permImpl="NONE"
permInterface="NONE"
upgr="NONE"
nwAdminOrg=""
nwAdminRole=""
orgAdminRole=""
subOrgDepth=0
subOrgBreadth=0
sleepTime=1

function usage() {
  echo ""
  echo "Usage:"
  echo "    $0 [raft | istanbul | clique] [tessera | constellation] [--tesseraOptions \"options for Tessera start script\"]"
  echo ""
  echo "Where:"
  echo "    raft | istanbul | clique : specifies which consensus algorithm to use"
  echo "    tessera | constellation (default = tessera): specifies which privacy implementation to use"
  echo "    --tesseraOptions: allows additional options as documented in tessera-start.sh usage which is shown below:"
  echo ""
  ./tessera-start.sh --help
  exit -1
}

checkSolidityVersion(){
    sv=`solc --version | tail -1 | tr -s " "| cut -f2 -d " " | cut -f1 -d "+"`
    rv="0.5.3"
    if [ "$(printf '%s\n' "$rv" "$sv" | sort -V | head -n1)" == "$rv" ]; then
        echo "Soldity version is $sv"
    else
        echo "Solidity version is $sv. Required version is 0.5.3. Cannot proceed"
        exit 0
    fi
}
checkQuorumVersion(){
    gv=`geth version | grep "Quorum" | tr -s " " |cut -f3 -d " "`
    rv="2.2.3"
    if [ "$(printf '%s\n' "$rv" "$gv" | sort -V | head -n1)" = "$rv" ]; then
        echo "Quorum version is $gv"
    else
        echo "Quorum version is $gv.Require 2.2.3. Upgrade Quorum first"
        exit 0
    fi

}

buildFiles(){
    contract=$1
    data=$2

    echo "Compiling $1.sol"
    #compile and generate solc output in abi
    solc --bin --optimize --overwrite -o ./output ./perm-contracts/$1.sol
    solc --abi --optimize --overwrite -o ./output ./perm-contracts/$1.sol

    cd ./output

    deployFile="deploy-$contract.js"
    loadFile="load-$contract.js"

    rm $deployFile $loadFile 2>>/dev/null

    abi=`cat ./$contract.abi`
    bc=`cat ./$contract.bin`
    echo -e "ac = eth.accounts[0];" >> ./$deployFile
    echo -e "web3.eth.defaultAccount = ac;" >> ./$deployFile
    echo -e "var abi = $abi;">> ./$deployFile
    echo -e "var bytecode = \"0x$bc\";">> ./$deployFile
    echo -e "var simpleContract = web3.eth.contract(abi);">> ./$deployFile
    if [ "$data" == "NONE" ]
    then
        echo -e "var a = simpleContract.new(\"0xed9d02e382b34818e88b88a309c7fe71e65f419d\",{from:web3.eth.accounts[0], data: bytecode, gas: 9200000}, function(e, contract) {">> ./$deployFile
    elif [ "$data" == "IMPL" ]
    then
        echo -e "var a = simpleContract.new(\"$upgr\", \"$org\", \"$roles\", \"$accounts\", \"$voter\", \"$nodes\", {from:web3.eth.accounts[0], data: bytecode, gas: 9200000}, function(e, contract) {">> ./$deployFile
    else
        echo -e "var a = simpleContract.new(\"$data\", {from:web3.eth.accounts[0], data: bytecode, gas: 9200000}, function(e, contract) {">> ./$deployFile
    fi
    echo -e "\tif (e) {">> ./$deployFile
    echo -e "\t\tconsole.log(\"err creating contract\", e);">> ./$deployFile
    echo -e "\t} else {">> ./$deployFile
    echo -e "\t\tif (!contract.address) {">> ./$deployFile
    echo -e "\t\t\tconsole.log(\"Contract transaction send: TransactionHash: \" + contract.transactionHash + \" waiting to be mined...\");">> ./$deployFile
    echo -e "\t\t} else {">> ./$deployFile
    echo -e "\t\t\tconsole.log(\"Contract mined! Address: \" + contract.address);">> ./$deployFile
    echo -e "\t\t\tconsole.log(contract);">> ./$deployFile
    echo -e "\t\t}">> ./$deployFile
    echo -e "\t}">> ./$deployFile
    echo -e "});">> ./$deployFile
    cd ..
}

createLoadFile(){
    contract=$1
    addr=$2
    intr=$3
    impl=$4
    loadFile="load-$contract.js"

    cd ./output

    abi=`cat ./$contract.abi`
    echo -e "ac = eth.accounts[0];">> ./$loadFile
    echo -e "web3.eth.defaultAccount = ac;">> ./$loadFile
    echo -e "var abi = $abi;">> ./$loadFile
    echo -e "var upgr = web3.eth.contract(abi).at(\"$addr\");">> ./$loadFile
    echo -e "var impl = \"$permImpl\"">>./$loadFile
    echo -e "var intr = \"$permInterface\"">> ./$loadFile

    cd ..
}
getContractAddress(){
    txid=$1
    x=$(geth attach ipc:$localPath/qdata/dd1/geth.ipc <<EOF
    var addr=eth.getTransactionReceipt("$txid").contractAddress;
    console.log("contarct address number is :["+addr+"]");
    exit;
EOF
    )
    contaddr=`echo $x| tr -s " "| cut -f2 -d "[" | cut -f1 -d"]"`
    echo $contaddr
}

createPermConfig(){
    rm -f ./permission-config.json
    echo -e "{" >> ./permission-config.json
    echo -e "\t\"upgrdableAddress\": \"$upgr\"," >> ./permission-config.json
    echo -e "\t\"interfaceAddress\": \"$permInterface\"," >> ./permission-config.json
    echo -e "\t\"implAddress\": \"$permImpl\"," >> ./permission-config.json
    echo -e "\t\"nodeMgrAddress\": \"$nodes\"," >> ./permission-config.json
    echo -e "\t\"accountMgrAddress\": \"$accounts\"," >> ./permission-config.json
    echo -e "\t\"roleMgrAddress\": \"$roles\"," >> ./permission-config.json
    echo -e "\t\"voterMgrAddress\": \"$voter\"," >> ./permission-config.json
    echo -e "\t\"orgMgrAddress\": \"$org\"," >> ./permission-config.json
    echo -e "\t\"nwAdminOrg\": \"$nwAdminOrg\"," >> ./permission-config.json
    echo -e "\t\"nwAdminRole\": \"$nwAdminRole\"," >> ./permission-config.json
    echo -e "\t\"orgAdminRole\": \"$orgAdminRole\"," >> ./permission-config.json
    echo -e "\t\"accounts\": [\"0xed9d02e382b34818e88b88a309c7fe71e65f419d\", \"0xca843569e3427144cead5e4d5999a3d0ccf92b8e\"]," >> ./permission-config.json
    echo -e "\t\"subOrgBreadth\": $subOrgBreadth," >> ./permission-config.json
    echo -e "\t\"subOrgDepth\": $subOrgDepth" >> ./permission-config.json
    echo -e "}" >> ./permission-config.json
}

deployContract(){
    file=$1
    op=`./runscript.sh ./output/$file`
    tx=`echo $op | head -1 | tr -s " "| cut -f5 -d " "`
    sleep $sleepTime
    contAddr=`getContractAddress $tx`
    echo "$contAddr"
}

permissionInit(){
   for i in {1..7}
   do
        cp ./permission-config.json qdata/dd$i
   done
}

waitPortClose(){
    DOWN=true
    while $DOWN; do
        sleep 1
        DOWN=false
        i=`netstat -n | grep TIME_WAIT | grep -v 443| wc -l`
        if [ $i -gt 1 ]
        then
            DOWN=true
        fi
    done
}

runInit(){
    cd ./output/
    x=$(geth attach ipc:$localPath/qdata/dd1/geth.ipc <<EOF
    loadScript("load-PermissionsUpgradable.js");
    var tx = upgr.init(intr, impl, {from: eth.accounts[0], gas: 4500000});
    console.log("Init transaction id :["+tx+"]");
    exit;
EOF
    )
    cd ..
}

displayMsg(){
    torq=`tput setaf 14`
    reset=`tput sgr0`
    msg=$1
    echo -e "${torq}---------------------------------------------------------------------"
    echo -e "$msg"
    echo -e "---------------------------------------------------------------------${reset}"
}

getInputs(){
    read -p "Enter Network Admin Org Name: "  nwAdminOrg
    read -p "Enter Network Admin Role Name: "  nwAdminRole
    read -p "Enter Org Admin Role Name: "  orgAdminRole
    echo "For Sub Orgs"
    read -p "Enter Allowed Breadth [numeric]: "  subOrgBreadth
    read -p "Enter Allowed Depth [numeric]: "  subOrgDepth
    if [ "$consensus" == "istanbul" ]
    then
        read -p "Enter Block period as in geth start script: " blockPeriod
    elif [ "$consensus" == "clique" ]
    then
        read -p "Enter Block period as given in genesis.json: " blockPeriod
    fi
    sleepTime=$(( $blockPeriod + 2 ))
}

privacyImpl=tessera
tesseraOptions=
consensus=
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

./stop.sh
waitPortClose

export STARTPERMISSION=1

# check solc  & geth version if it is below 0.5.3 throw error
displayMsg "Checking solidity and geth version compatibility"
checkSolidityVersion
checkQuorumVersion

displayMsg "Input Permissions Specific parameters"
getInputs

# init the network
displayMsg "Starting the network in $consensus mode"
echo "Initializing the network"
./init.sh $consensus
echo "Starting the network"
./start.sh $consensus $privacyImpl

sleep 60

# create deployment files upgradable contract and deploy the contract
displayMsg "Building permissions deployables"
buildFiles PermissionsUpgradable $upgr
upgr=`deployContract "deploy-PermissionsUpgradable.js"`

buildFiles "OrgManager" $upgr
buildFiles "RoleManager" $upgr
buildFiles "NodeManager" $upgr
buildFiles "VoterManager" $upgr
buildFiles "AccountManager" $upgr

org=`deployContract "deploy-OrgManager.js"`
roles=`deployContract "deploy-RoleManager.js"`
nodes=`deployContract "deploy-NodeManager.js"`
voter=`deployContract "deploy-VoterManager.js"`
accounts=`deployContract "deploy-AccountManager.js"`

buildFiles "PermissionsImplementation" "IMPL"
buildFiles "PermissionsInterface" $upgr

permImpl=`deployContract "deploy-PermissionsImplementation.js"`
permInterface=`deployContract "deploy-PermissionsInterface.js"`

# create the permissions config file
displayMsg "Creating permission config file and copying to data directories"
createPermConfig
echo "created permission-config.json"
cat ./permission-config.json

#copy the permission config file to qdata/dd folders
permissionInit

displayMsg "Creating load script for upgradable contract and initializing"
# initialize the upgradable contracts with custodian address and link interface and implementation contarcts
createLoadFile "PermissionsUpgradable" $upgr $permInterface $permImpl
runInit
echo "Network initialization completed"
sleep 10


displayMsg "Restarting the network with permissions"
# Bring down the network wait for all time wait connections to close
./stop.sh
waitPortClose

# Bring the netowrk back up
./start.sh $consensus $privacyImpl

#clean up all temporary directories
rm -rf ./output deploy-*.js
rm permission-config.json
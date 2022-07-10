#!/usr/bin/env bash
# Initialise data for Tessera nodes.
# This script will normally perform initialisation for 7 nodes, however
# if file qdata/numberOfNodes exists then the script will read number
# of nodes from that file.

# Function to extract the IP for each peer from permissioned-nodes.json
# Results are written to the array 'peerIPList'
declare -a peerIPList
function getPeerIPs() {
    peerNum=0

    numLines=`wc -l permissioned-nodes.json  | xargs | cut -f 1,1 -d " "`
    for lineNumber in `seq 1 ${numLines}`
    do
        #if line contains an enode entry then process it, else ignore it
        line=`sed -n ${lineNumber},${lineNumber}p permissioned-nodes.json`
        if [[ "$line" =~ "enode" ]]; then

            hostIP=`echo $line |cut -f 2,2 -d "@" | cut -f 1,1 -d ":" `
            regexpIP='([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])'
            if [[ ! ( $hostIP =~ ^$regexpIP\.$regexpIP\.$regexpIP\.$regexpIP$ || "$hostIP" == "localhost" ) ]]; then
                hostIP="127.0.0.1"
                echo "[*] WARNING: invalid enode IP found on line ${lineNumber} of permissioned-nodes.json, defaulting to '${hostIP}'"
            fi
            peerNum=$((${peerNum} + 1))
            peerIPList[${peerNum}]="$hostIP"

        fi
    done
}


numNodes=7
if [[ -f qdata/numberOfNodes ]]; then
    numNodes=`cat qdata/numberOfNodes`
fi

echo "[*] Initialising Tessera configuration for $numNodes node(s)"

encryptorType=${ENCRYPTOR_TYPE:-NACL}
encryptorProps=""

if [ "$encryptorType" == "EC" ]; then
    tesseraJarDefault="/home/vagrant/tessera/tessera.jar"
    tesseraScriptDefault="/home/vagrant/tessera/tessera/bin/tessera"

    tesseraJar=${TESSERA_JAR:-$tesseraJarDefault}
    tesseraScript=${TESSERA_SCRIPT:-$tesseraScriptDefault}

    if [ ! -f "${tesseraJar}" ] && [ ! -f "${tesseraScript}" ]; then
        echo "ERROR: no Tessera jar or executable script found at ${tesseraJar} or ${tesseraScript}. Use TESSERA_JAR or TESSERA_SCRIPT env vars to specify the path to an executable jar or script."
        exit -1
    fi

    encryptorProps=$(printf "\"symmetricCipher\":\"%s\",\n            \"ellipticCurve\":\"%s\",\n            \"nonceLength\":\"%s\",\n            \"sharedKeyLength\":\"%s\"" \
     "${ENCRYPTOR_EC_SYMMETRIC_CIPHER:-AES/GCM/NoPadding}" "${ENCRYPTOR_EC_ELLIPTIC_CURVE:-secp256r1}" "${ENCRYPTOR_EC_NONCE_LENGTH:-24}" "${ENCRYPTOR_EC_SHARED_KEY_LENGTH:-32}" )
    encryptorCmdLineParams=$(printf " --encryptor.type EC --encryptor.symmetricCipher %s --encryptor.ellipticCurve %s --encryptor.nonceLength %s --encryptor.sharedKeyLength %s" \
     "${ENCRYPTOR_EC_SYMMETRIC_CIPHER:-AES/GCM/NoPadding}" "${ENCRYPTOR_EC_ELLIPTIC_CURVE:-secp256r1}" "${ENCRYPTOR_EC_NONCE_LENGTH:-24}" "${ENCRYPTOR_EC_SHARED_KEY_LENGTH:-32}" )
fi

# Dynamically create the config for peers, depending on numNodes
getPeerIPs	# get list of IP addresses for peers
peerList=
for i in `seq 1 ${numNodes}`
do
    if [[ $i -ne 1 ]]; then
        peerList="$peerList,"
    fi

    portNum=$((9000 + $i))

    hostIP=${peerIPList[$i]}
    if [[ "$hostIP" == "" ]]; then
        hostIP="127.0.0.1"
        echo "[*] WARNING: host IP for node $i not found in permissioned-nodes.json, defaulting to '${hostIP}'"
    fi

    peerList="${peerList}
        {
            \"url\": \"http://${hostIP}:${portNum}\"
        }"
done

# Write the config for the Tessera nodes
currentDir=$(pwd)
for i in `seq 1 ${numNodes}`
do
    DDIR="${currentDir}/qdata/c${i}"
    mkdir -p ${DDIR}
    mkdir -p qdata/logs
    if [ "$encryptorType" == "NACL" ]; then
        cp "keys/tm${i}.pub" "${DDIR}/tm.pub"
        cp "keys/tm${i}.key" "${DDIR}/tm.key"
    fi
    rm -f "${DDIR}/tm.ipc"

    serverPortP2P=$((9000 + ${i}))
    serverPortThirdParty=$((9080 + ${i}))
    serverPortEnclave=$((9180 + ${i}))

    #change tls to "strict" to enable it (don't forget to also change http -> https)
cat <<EOF > ${DDIR}/tessera-config-09-${i}.json
{
    "encryptor":{
        "type":"${encryptorType}",
        "properties":{
            ${encryptorProps}
        }
    },
    "useWhiteList": false,
    "jdbc": {
        "username": "sa",
        "password": "",
        "url": "jdbc:h2:${DDIR}/db${i};TRACE_LEVEL_SYSTEM_OUT=0",
        "autoCreateTables": true
    },
    "serverConfigs":[
        {
            "app":"ThirdParty",
            "enabled": true,
            "serverAddress": "http://localhost:${serverPortThirdParty}",
            "cors" : {
                "allowedMethods" : ["GET", "OPTIONS"],
                "allowedOrigins" : ["*"]
            },
            "communicationType" : "REST"
        },
        {
            "app":"Q2T",
            "enabled": true,
            "serverAddress":"unix:${DDIR}/tm.ipc",
            "communicationType" : "REST"
        },
        {
            "app":"P2P",
            "enabled": true,
            "serverAddress":"http://127.0.0.1:${serverPortP2P}",
            "sslConfig": {
                "tls": "OFF",
                "generateKeyStoreIfNotExisted": true,
                "serverKeyStore": "${DDIR}/server${i}-keystore",
                "serverKeyStorePassword": "quorum",
                "serverTrustStore": "${DDIR}/server-truststore",
                "serverTrustStorePassword": "quorum",
                "serverTrustMode": "TOFU",
                "knownClientsFile": "${DDIR}/knownClients",
                "clientKeyStore": "${DDIR}/client${i}-keystore",
                "clientKeyStorePassword": "quorum",
                "clientTrustStore": "${DDIR}/client-truststore",
                "clientTrustStorePassword": "quorum",
                "clientTrustMode": "TOFU",
                "knownServersFile": "${DDIR}/knownServers"
            },
            "communicationType" : "REST"
        }
    ],
    "peer": [
        ${peerList}
    ],
    "keys": {
        "passwords": [],
        "keyData": [
            {
                "privateKeyPath": "${DDIR}/tm.key",
                "publicKeyPath": "${DDIR}/tm.pub"
            }
        ]
    },
    "alwaysSendTo": [],
    "features":{
        "enablePrivacyEnhancements": "${PRIVACY_ENHANCEMENTS:-false}"
    }
}
EOF

# Enclave configurations

cat <<EOF > ${DDIR}/tessera-config-enclave-09-${i}.json
{
    "useWhiteList": false,
    "jdbc": {
        "username": "sa",
        "password": "",
        "url": "jdbc:h2:${DDIR}/db${i};TRACE_LEVEL_SYSTEM_OUT=0",
        "autoCreateTables": true
    },
    "serverConfigs":[
        {
            "app":"ENCLAVE",
            "enabled": true,
            "serverAddress": "http://localhost:${serverPortEnclave}",
            "communicationType" : "REST"
        },
        {
            "app":"ThirdParty",
            "enabled": true,
            "serverAddress": "http://localhost:${serverPortThirdParty}",
            "communicationType" : "REST"
        },
        {
            "app":"Q2T",
            "enabled": true,
             "serverAddress":"unix:${DDIR}/tm.ipc",
            "communicationType" : "REST"
        },
        {
            "app":"P2P",
            "enabled": true,
            "serverAddress":"http://127.0.0.1:${serverPortP2P}",
            "sslConfig": {
                "tls": "OFF"
            },
            "communicationType" : "REST"
        }
    ],
    "peer": [
        ${peerList}
    ]
}
EOF

cat <<EOF > ${DDIR}/enclave-09-${i}.json
{
    "encryptor":{
        "type":"${encryptorType}",
        "properties":{
            ${encryptorProps}
        }
    },
    "serverConfigs":[
        {
            "app":"ENCLAVE",
            "enabled": true,
            "serverAddress": "http://localhost:${serverPortEnclave}",
            "communicationType" : "REST"
        }
    ],
    "keys": {
        "passwords": [],
        "keyData": [
            {
                "privateKeyPath": "${DDIR}/tm.key",
                "publicKeyPath": "${DDIR}/tm.pub"
            }
        ]
    },
    "alwaysSendTo": []
}
EOF

    #generate tessera keys
    if [ "$encryptorType" == "EC" ]; then
        if [ -f "${tesseraJar}" ]; then
            tesseraExec="java -jar ${tesseraJar}"
        else
            tesseraExec=${tesseraScript}
        fi
        pushd $DDIR
        $tesseraExec -keygen $encryptorCmdLineParams -filename tm < /dev/null
        popd
    fi

done

#create a copy of private-contract.js where the public key of the tessera node (privateFor) is replaced with the newly generated key of the last node (numNodes)
if [ "$encryptorType" == "EC" ]; then
    oldKey=$(cat keys/tm7.pub)
    newKey=$(cat qdata/c${numNodes}/tm.pub)
    #replace all / with \/ in the newKey (otherwise sed complains about it)
    newKey=$(echo $newKey | sed 's/\//\\\//g')
    echo "OldKey: $oldKey NewKey: $newKey"
    newFileName=qdata/ec-${ENCRYPTOR_EC_ELLIPTIC_CURVE:-secp256r1}-private-contract.js
    sed  "s/\"$oldKey\"/\"$newKey\"/g" private-contract.js > $newFileName
    echo "private-contract sample generated in $newFileName"
fi

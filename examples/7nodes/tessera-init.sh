#!/usr/bin/env bash

echo "[*] Initialising Tessera configuration"

currentDir=$(pwd)
for i in {1..7}
do
    DDIR="qdata/c$i"
    mkdir -p ${DDIR}
    mkdir -p qdata/logs
    cp "keys/tm$i.pub" "${DDIR}/tm.pub"
    cp "keys/tm$i.key" "${DDIR}/tm.key"
    rm -f "${DDIR}/tm.ipc"

    #change tls to "strict" to enable it (don't forget to also change http -> https)
    cat <<EOF > ${DDIR}/tessera-config${i}.json
{
    "useWhiteList": false,
    "jdbc": {
        "username": "sa",
        "password": "",
        "url": "jdbc:h2:./${DDIR}/db${i};MODE=Oracle;TRACE_LEVEL_SYSTEM_OUT=0"
    },
    "server": {
        "port": 900${i},
        "hostName": "http://localhost",
        "sslConfig": {
            "tls": "OFF",
            "generateKeyStoreIfNotExisted": true,
            "serverKeyStore": "${currentDir}/qdata/c${i}/server${i}-keystore",
            "serverKeyStorePassword": "quorum",
            "serverTrustStore": "${currentDir}/qdata/c${i}/server-truststore",
            "serverTrustStorePassword": "quorum",
            "serverTrustMode": "TOFU",
            "knownClientsFile": "${currentDir}/qdata/c${i}/knownClients",
            "clientKeyStore": "${currentDir}/qdata/c${i}/client${i}-keystore",
            "clientKeyStorePassword": "quorum",
            "clientTrustStore": "${currentDir}/qdata/c${i}/client-truststore",
            "clientTrustStorePassword": "quorum",
            "clientTrustMode": "TOFU",
            "knownServersFile": "${currentDir}/qdata/c${i}/knownServers"
        }
    },
    "peer": [
        {
            "url": "http://localhost:9001"
        },
        {
            "url": "http://localhost:9002"
        },
        {
            "url": "http://localhost:9003"
        },
        {
            "url": "http://localhost:9004"
        },
        {
            "url": "http://localhost:9005"
        },
        {
            "url": "http://localhost:9006"
        },
        {
            "url": "http://localhost:9007"
        }
    ],
    "keys": {
        "passwords": [],
        "keyData": [
            {
                "config": $(cat ${currentDir}/qdata/c${i}/tm.key),
                "publicKey": "$(cat ${currentDir}/qdata/c${i}/tm.pub)"
            }
        ]
    },
    "alwaysSendTo": [],
    "unixSocketFile": "${currentDir}/qdata/c${i}/tm.ipc"
}
EOF

done
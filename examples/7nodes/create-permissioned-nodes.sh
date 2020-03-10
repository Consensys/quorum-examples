#!/usr/bin/env bash
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
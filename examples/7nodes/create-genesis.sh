#!/usr/bin/env bash
consensus=$1
genesisFile=$2
nodes=$3

extraDataLine=`awk '/extraData/{print NR; exit}' ./${consensus}-genesis.json`
totalLines=`cat ./${consensus}-genesis.json| wc -l`
i=$(( $extraDataLine -1 ))
j=$(( $totalLines - extraDataLine ))

extraData=`cat ./${consensus}-extradata.txt | grep ${nodes}node | cut -f2 -d ":"`

cat ./${consensus}-genesis.json | head -$i >> $genesisFile
echo -e "\t \"extraData\": ${extraData}," >> $genesisFile
cat ./${consensus}-genesis.json | tail -$j >> $genesisFile
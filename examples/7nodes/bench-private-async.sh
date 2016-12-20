#!/bin/sh
set -u
set -e
# c = number of concurrent connections (sending transactions over and over)
# d = duration, e.g. 30 (30 seconds), 5m, 1h
# t = threads Wrk should use, e.g. 2
#
# Example: ./bench-private-async.sh 10 1m 2
c=$1
d=$2
t=$3
curl -d '' http://localhost:22000/
wrk -s send-private-async.lua -c $c -d $d -t $t http://localhost:22000/

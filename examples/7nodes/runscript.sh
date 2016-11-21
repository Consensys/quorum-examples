#!/bin/bash
PRIVATE_CONFIG=tm1.conf geth --exec "loadScript(\"$1\")" attach ipc:qdata/dd1/geth.ipc

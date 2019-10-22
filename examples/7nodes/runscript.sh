#!/bin/bash
geth --exec "loadScript(\"$1\")" attach ipc:qdata/dd1/geth.ipc
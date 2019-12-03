#!/bin/bash
# Start Cakeshop instance

set -u
set -e

defaultCakeshopJarExpr="/home/vagrant/cakeshop/cakeshop.war"
set +e
defaultCakeshopJar=`find ${defaultCakeshopJarExpr} 2>/dev/null`
set -e
if [[ "${CAKESHOP_JAR:-unset}" == "unset" ]]; then
  cakeshopJar=${defaultCakeshopJar}
else
  cakeshopJar=${CAKESHOP_JAR}
fi

jvmParams="-Dcakeshop.config.dir=qdata/cakeshop -Dlogging.path=qdata/logs/cakeshop"

if [ ! -f qdata/cakeshop/local/application.properties ]; then
    echo "ERROR: could not find qdata/cakeshop/application.properties. Please run one of the init scripts first."
    exit 1
fi

if [  "${cakeshopJar}" == "" ]; then
  echo "ERROR: unable to find Cakeshop war file using CAKESHOP_JAR envvar, or using ${defaultCakeshopJarExpr}"
  exit 1
elif [  ! -f "${cakeshopJar}" ]; then
  echo "ERROR: unable to find Cakeshop war file: ${cakeshopJar}"
  exit 1
fi

echo "[*] Starting Cakeshop"

currentDir=`pwd`
CMD="java $jvmParams -jar ${cakeshopJar}"
echo "$CMD 2>&1 &"
${CMD} > /dev/null 2>&1 &
sleep 1

DOWN=true
k=10
while ${DOWN}; do
    sleep 1
    echo "Waiting until Cakeshop is running..."
    DOWN=false
    set +e
    result=$(curl -s http://localhost:8999/actuator/health)
    set -e
    if [ ! "${result}" == "{\"status\":\"UP\"}" ]; then
        echo "Cakeshop is not yet listening on http"
        DOWN=true
    fi

    k=$((k - 1))
    if [ ${k} -le 0 ]; then
        echo "Cakeshop is taking a long time to start.  Look at the Cakeshop logs in qdata/logs/ for help diagnosing the problem."
    fi

    sleep 5
done

echo "Cakeshop started at http://localhost:8999/"
exit 0

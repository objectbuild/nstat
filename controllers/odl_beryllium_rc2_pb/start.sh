#!/bin/bash

# Copyright (c) 2015 Intracom S.A. Telecom Solutions. All rights reserved.
#
# This program and the accompanying materials are made available under the
# terms of the Eclipse Public License v1.0 which accompanies this distribution,
# and is available at http://www.eclipse.org/legal/epl-v10.html

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd $SCRIPT_DIR

UNTIL_MAX_TRIES=120
UNTIL_SLEEP_TIME=5
UNTIL_COUNTER=0
INIT_CONTROLLER=60
KARAF_PATH="distribution-karaf-0.4.0-Beryllium-RC2"

function exec_client_command()
{
    UNTIL_COUNTER=0
    until ./client -u karaf "$@" > /dev/null 2>&1;
    do
        UNTIL_COUNTER=$(($UNTIL_COUNTER+1))
        if [ $UNTIL_COUNTER -eq $UNTIL_MAX_TRIES ]; then
            ./stop
            echo "Reached maximum amount of sleep time $(($UNTIL_COUNTER*$UNTIL_SLEEP_TIME))"
            echo "Exiting"
            exit 1
        fi
        echo "Trying to execute command \"./client "$@"\". Waiting "$UNTIL_SLEEP_TIME" seconds..."
        sleep $UNTIL_SLEEP_TIME
    done
}


if [ -d $KARAF_PATH ]; then
    cd $KARAF_PATH
else
    echo "The specified KARAF_PATH $KARAF_PATH does not exist. Exiting."
    exit 1
fi

# Remove data folder to have a fresh installation of desired features
rm -rf data > /dev/null 2>&1

if [ -d journal ]; then
    rm -rf journal/* > /dev/null 2>&1
    echo "Cleanup contents of journal folder"
fi

echo "Starting ODL controller"
cd bin
./karaf server > /dev/null 2>&1 &


if [ $? -eq 0 ]
then
    sleep $INIT_CONTROLLER
    UNTIL_COUNTER=0
    CONTROLLER_PID=$(./client -u karaf "instance:list" 2>/dev/null | grep "Started" | awk '{print $9}')
    until [ ! -z "$CONTROLLER_PID" ] ;
    do
        CONTROLLER_PID=$(./client -u karaf "instance:list" 2>/dev/null | grep "Started" | awk '{print $9}')
        UNTIL_COUNTER=$(($UNTIL_COUNTER+1))
        if [ $UNTIL_COUNTER -eq $UNTIL_MAX_TRIES ]; then
            # The following line covers the case where the controller starts with
            # Error state. We want the controller to be in Running state.
            ./stop
            echo "Controller process failed to start or stopped unexpectedly."
            echo "Maximum wait time reached $(($UNTIL_COUNTER*$UNTIL_SLEEP_TIME))"
            exit 1
        fi
        echo "Wait until controller process is ready."
        sleep $UNTIL_SLEEP_TIME
    done
    echo "Controller started successfully."
else
    echo "Controller failed to start...Exiting"
    exit 1
fi


exec_client_command "feature:install odl-restconf-all"
echo "odl-restconf-all feature was installed successfully"

exec_client_command "feature:install odl-openflowplugin-flow-services"
echo "odl-openflowplugin-flow-services feature was installed successfully"


exec_client_command "feature:install odl-l2switch-switch"
echo "feature odl-l2switch-switch was installed successfully"

exec_client_command "feature:install odl-mdsal-apidocs"
echo "feature odl-mdsal-apidocs was installed successfully"

exec_client_command "feature:install odl-dlux-core"
echo "feature install odl-dlux-core was installed successfully"

# Setting loglevel to error
exec_client_command "log:set ERROR"
echo "Karaf log level was set to ERROR successfully"

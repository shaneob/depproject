#!/bin/bash
# sburke 2014

# Level 1 functions <---------------------------------------


function isApacheRunning {
        isRunning apache2
        return $?
}

function isApacheListening {
        isTCPlisten 80
        return $?
}

function isApacheRemoteUp {
        isTCPremoteOpen 127.0.0.1 80
        return $?
}

# Level 0 functions <--------------------------------------

function isRunning {
PROCESS_NUM=$(ps -ef | grep "$1" | grep -v "grep" | wc -l)
if [ $PROCESS_NUM -gt 0 ] ; then
        echo $PROCESS_NUM
        return 1
else
	restartService
        return 0
fi
}


function isTCPlisten {
TCPCOUNT=$(netstat -tupln | grep tcp | grep "$1" | wc -l)
if [ $TCPCOUNT -gt 0 ] ; then
        return 1
else
        return 0
fi
}

function isTCPremoteOpen {
timeout 1 bash -c "echo >/dev/tcp/$1/$2" && return 1 || return 0
}

function restartService {
	$(/etc/init.d/apache2 start)
}

ERRORCOUNT=0

# Functional Body of monitoring script <----------------------------

isApacheRunning
if [ "$?" -eq 1 ]; then
        echo Apache process is Running
else
        echo Apache process is not Running
        ERRORCOUNT=$((ERRORCOUNT+1))
fi

isApacheListening
if [ "$?" -eq 1 ]; then
        echo Apache is Listening
else
        echo Apache is not Listening
        ERRORCOUNT=$((ERRORCOUNT+1))
fi

isApacheRemoteUp
if [ "$?" -eq 1 ]; then
        echo Remote Apache TCP port is up
else
        echo Remote Apache TCP port is down
        ERRORCOUNT=$((ERRORCOUNT+1))
fi

if [ $ERRORCOUNT -gt 0 ]
then
        echo "There is a problem with Apache"
fi

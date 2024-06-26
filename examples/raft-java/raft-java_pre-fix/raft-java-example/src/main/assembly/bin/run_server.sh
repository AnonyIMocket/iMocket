#!/bin/bash
if [ $# -ne 3 ]; then
    echo "Usage: ./run_server.sh DATA_PATH CLUSTER CURRENT_NODE"
    exit
fi

#begin adapt cygwin/mingw 
UNAME_STR=$(uname -a)
CURRENT_SYS=${var:0:5}
var=$(uname -a)
CURRENT_SYS=${var:0:5}
if [ $CURRENT_SYS == "MINGW" ]; then
	echo "--current system is mingw--"
elif [ $CURRENT_SYS == "CYGWI" ]; then
	echo "--current system is cygwin--"
fi
#end adapt cygwin/mingw

DATA_PATH=$1
CLUSTER=$2
CURRENT_NODE=$3

JMX_PORT=18101
GC_LOG=./logs/gc.log
#jvm config
JAVA_BASE_OPTS=" -Djava.awt.headless=true -Dfile.encoding=UTF-8 "

#JAVA_JMX_OPTS=" -Dcom.sun.management.jmxremote \
#-Dcom.sun.management.jmxremote.port=$JMX_PORT \
#-Dcom.sun.management.jmxremote.ssl=false \
#-Dcom.sun.management.jmxremote.authenticate=false "
JAVA_JMX_OPTS=""

JAVA_MEM_OPTS=" -server -Xms2g -Xmx2g -Xmn600m -XX:PermSize=128m \
-XX:MaxPermSize=128m -Xss256K \
-XX:+UseConcMarkSweepGC -XX:+CMSParallelRemarkEnabled \
-XX:+UseCMSCompactAtFullCollection -XX:LargePageSizeInBytes=128m \
-XX:+UseFastAccessorMethods -XX:+UseCMSInitiatingOccupancyOnly \
-XX:CMSInitiatingOccupancyFraction=70 "

JAVA_GC_OPTS=" -verbose:gc -Xloggc:$GC_LOG \
-XX:+PrintGCDetails -XX:+PrintGCDateStamps "

if [ $CURRENT_SYS == "MINGW" ] || [ $CURRENT_SYS == "CYGWI" ]; then
	JAVA_CP=" -cp conf;lib/* "
else
	JAVA_CP=" -cp conf:lib/* "
fi

JAVA_OPTS=" $JAVA_BASE_OPTS $JAVA_MEM_OPTS $JAVA_JMX_OPTS $JAVA_GC_OPTS $JAVA_CP"

JAVA_HOME=/lib64/jdk1.8.0_311
RUNJAVA="$JAVA_HOME/bin/java"
MAIN_CLASS=com.github.wenweihu86.raft.example.server.ServerMain

SUT="Raft"
HOST=$(echo $CURRENT_NODE | awk -F: '{print $1}')
PORT=$(echo $CURRENT_NODE | awk -F: '{print $2}')
SID=$(echo $CURRENT_NODE | awk -F: '{print $3}')
echo "The current address is $HOST:$PORT for node $SID"

MOCKET_PATH=/home/dong/Documents/MCDT/Mocket/target/Mocket-0.1-SNAPSHOT-jar-with-dependencies.jar
MOCKET_PARAM="-Xbootclasspath/a:$MOCKET_PATH -javaagent:$MOCKET_PATH=SUT=$SUT,Host=$HOST,Port=$PORT,sid=$SID,MocketHost=127.0.0.1:9090"

$RUNJAVA $MOCKET_PARAM $JAVA_CP $MAIN_CLASS $DATA_PATH $CLUSTER $CURRENT_NODE

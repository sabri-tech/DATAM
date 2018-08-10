#!/bin/ksh
##########################################################################################################
#
# This script is for displaying overall basic MQ status which includes
# 		- Queue manager, MQ process status, Queue manager cluster details.
# 		- Channel issues, SVRCONN channel connection details
#		- Dead letter queue, Transmit queue(s) and local queue(s) depth issues. 
#               - MQ file system space details etc
# 
#
# SCRIPT:      MQFIR.sh
#
# USAGE:       ./mqfir.sh <qmgr name>
#
#               Script can be run as above with Queue manager name as input. Report will be displayed for that queue manager.
#
#		or
#
#              ./MQFIR.sh   
#          
#	       If the server has only one queue manager, Output will be generated for that queue manager.
#
#              If the server has  more than one queue manager, the script will list the queue managers
#              running in the server. You will have to give one particular queue manager name or all or ALL
#              to generate the report for those queue manager(s).
#
# NOTE:        Run as a 'mqm' user.
#
# OS TESTED:   AIX, Solaris, Linux
#
# MQ VERSION:  6.x, 7.x 
# 
# COMPANY:     IBM, GDC India    
#
# VERSION:     1.0  
#
##########################################################################################################
# @AUTHOR............. Nandini devi  
#
# @REVISION1...........15 JAN 2013 - First review
# @REVIEWER(S).........Gautam K Bhat
# 
# @REVISION2...........25 FEB 2013 - Second review
# @REVIEWER(S).........Vasu Gajendran & Arundeep B Veerabhadraiah
##########################################################################################################
DEPTH()
{
COL_CURDEPTH=`echo "dis ql('$LQ')" | ./runmqsc $line | grep CURDEPTH | awk '{print $1}' | cut -d "(" -f1`
      if [[ $COL_CURDEPTH == "CURDEPTH" ]]
      then
      CURDEPTH=`echo "dis ql('$LQ')" | ./runmqsc $line | grep CURDEPTH | awk '{print $1}' |  cut -d "(" -f2 | cut -d ")" -f1`
      else 
      CURDEPTH=`echo "dis ql('$LQ')" | ./runmqsc $line | grep CURDEPTH | awk '{print $2}' |  cut -d "(" -f2 | cut -d ")" -f1`
      fi
COL_MAXDEPTH=`echo "dis ql('$LQ')" | ./runmqsc $line | grep MAXDEPTH | awk '{print $1}' | cut -d "(" -f1` 
      if [[ $COL_MAXDEPTH == "MAXDEPTH" ]]
      then
      MAXDEPTH=`echo "dis ql('$LQ')" | ./runmqsc $line | grep MAXDEPTH | awk '{print $1}' |  cut -d "(" -f2 | cut -d ")" -f1`
      else 
      MAXDEPTH=`echo "dis ql('$LQ')" | ./runmqsc $line | grep MAXDEPTH | awk '{print $2}' |  cut -d "(" -f2 | cut -d ")" -f1`
      fi
}
PROCS()
{
COL_IPPROCS=`echo "dis qs('${xy[$m]}')" | ./runmqsc $line | grep IPPROCS | awk '{print $1}' | cut -d "(" -f1` 
COL_OPPROCS=`echo "dis qs('${xy[$m]}')" | ./runmqsc $line | grep OPPROCS | awk '{print $1}' | cut -d "(" -f1`
if [[ $COL_IPPROCS == "IPPROCS" ]]
        then 
        IPPROCS=`echo "dis qs('${xy[$m]}')" | ./runmqsc $line | grep IPPROCS | awk '{print $1}' | cut -d "(" -f2 | cut -d ")" -f1`
        else
        IPPROCS=`echo "dis qs('${xy[$m]}')" | ./runmqsc $line | grep IPPROCS | cut -f 3 -d "("  | cut -d ")" -f1`
        fi

if [[ $COL_OPPROCS == "OPPROCS" ]]
        then 
        OPPROCS=`echo "dis qs('${xy[$m]}')" | ./runmqsc $line | grep OPPROCS | awk '{print $1}' | cut -d "(" -f2 | cut -d ")" -f1`
        else
        OPPROCS=`echo "dis qs('${xy[$m]}')" | ./runmqsc $line | grep OPPROCS | cut -f 3 -d "("  | cut -d ")" -f1`
        fi

}
TRIGGER()
{
COL_PROCESS=`echo "dis ql('${xy[$m]}')" | ./runmqsc $line | grep PROCESS | awk '{print $1}' | cut -d "(" -f1`
COL_INITQ=`echo "dis ql('${xy[$m]}')" | ./runmqsc $line | grep INITQ | awk '{print $1}' | cut -d "(" -f1`
if [[ $COL_PROCESS == "PROCESS" ]]
        then 
        PROCESS=`echo "dis ql('${xy[$m]}')" | ./runmqsc $line | grep PROCESS | awk '{print $1}' | cut -d "(" -f2 | cut -d ")" -f1`
        else
        PROCESS=`echo "dis ql('${xy[$m]}')" | ./runmqsc $line | grep PROCESS | cut -f 3 -d "("  | cut -d ")" -f1`
        fi

if [[ $COL_INITQ == "INITQ" ]]
        then 
        INITQ=`echo "dis ql('${xy[$m]}')" | ./runmqsc $line | grep INITQ | awk '{print $1}' | cut -d "(" -f2 | cut -d ")" -f1`
        else
        INITQ=`echo "dis ql('${xy[$m]}')" | ./runmqsc $line | grep INITQ | cut -f 3 -d "("  | cut -d ")" -f1`
        fi
if [[ ($PROCESS > 0) || ($INITQ > 0) ]]
	then
	COL_PRO_APPID=`echo "dis process('$PROCESS')" | ./runmqsc $line | grep APPLICID | awk '{print $1}' | cut -d "(" -f1`
	if [[ $COL_PRO_APPID == "APPLICID" ]]
        then 
        APPLICID=`echo "dis process('$PROCESS')" | ./runmqsc $line | grep APPLICID | awk '{print $1}' | cut -d "(" -f2 | cut -d ")" -f1`
        else
        APPLICID=`echo "dis process('$PROCESS')" | ./runmqsc $line | grep APPLICID | cut -f 3 -d "("  | cut -d ")" -f1`
        fi
	
	if [[ $APPLICID > 0 ]]
	then 
		if [[ -e $APPLICID ]]
		then
		TRIGGER=YES
		TRIGGER_PROC=1
		else
		TRIGGER=NO
		fi
	else
	TRIGGER=NO
	fi
else
TRIGGER=NO
fi
}
PROPERTY()
{
Q=0
	for j in ${QMGR[@]}
	do
	if [[ ${QMGR[$Q]} == "$line" ]]
	then
	INSTALL_PATH=${INSTALL[$Q]}
	VERSION=${VER[$Q]}
	STATUS=${STAT[$Q]}
	fi
	let Q=$Q+1
	done
}

MAIN()
{
#Checks the queue manager name passed with the list of queue managers configured in the server.
QMGR_E=`dspmq | grep "($line)"`

if [[ $QMGR_E > 0 ]]
then


if [[ $OS == "AIX" ]]
then
INSTALL_PATH=/usr/mqm
else
#For Solaris and Linux
INSTALL_PATH=/opt/mqm
fi

INSTALL_INI_PATH=/etc/opt/mqm

VERSION=`dspmqver | grep Version | awk '{print $2}'`
VER=`dspmqver | grep Version | awk '{print $2}' | cut -f 1,2 -d "."`
#Checks whether the default MQ version is 7.1 or above to check Multi-version
if [[ ($VER -nt "6.0") && ($VER -nt "7.0") ]]
then
set -A QMGR `dspmq -o installation | grep $line | awk '{print $1}' | cut -d "(" -f2 | cut -d ")" -f1`
set -A INSTALL `dspmq -o installation | grep $line | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1`
set -A VER `dspmq -o installation | grep $line | awk '{print $4}' | cut -d "(" -f2 | cut -d ")" -f1`
set -A STAT `dspmq | grep $line | awk '{print $2}' | cut -d "(" -f2 | cut -d ")" -f1`
PROPERTY
else
#It checks the MQ installation ini file for installation path for MQ multiversions installed in the server.
	if [[ ($VER == "7.0") && (-e $INSTALL_INI_PATH/mqinst.ini) ]]
	then
	set -A IPATH `cat $INSTALL_INI_PATH/mqinst.ini | grep FilePath | cut -f 2 -d "="`
	v=0
	for j in ${IPATH[@]}
 	do
 	   if [[ (${IPATH[$v]} != "/opt/mqm") && (${IPATH[$v]} != "/usr/mqm") ]]
	   then
	   INPATH=${IPATH[$v]}	
	   fi
 	let v=$v+1
 	done 
	set -A QMGR `$INPATH/bin/dspmq -o installation | grep $line | awk '{print $1}' | cut -d "(" -f2 | cut -d ")" -f1`
	set -A INSTALL `$INPATH/bin/dspmq -o installation | grep $line | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1`
	set -A VER `$INPATH/bin/dspmq -o installation | grep $line | awk '{print $4}' | cut -d "(" -f2 | cut -d ")" -f1`
	set -A STAT `$INPATH/bin/dspmq | grep $line | awk '{print $2}' | cut -d "(" -f2 | cut -d ")" -f1`
	PROPERTY
else
#For MQ versions which not supporting multiversion
set -A QMGR `dspmq | grep $line | awk '{print $1}' | cut -d "(" -f2 | cut -d ")" -f1`
set -A STAT `dspmq | grep $line | awk '{print $2}' | cut -d "(" -f2 | cut -d ")" -f1`
Q=0
	for j in ${QMGR[@]}
	do
	if [[ ${QMGR[$Q]} == "$line" ]]
	then
	STATUS=${STAT[$Q]}
	fi
	let Q=$Q+1
	done
fi
fi

#Switching to bin directory of the MQ installation path to run MQ commands - To support Multiversion.
cd $INSTALL_PATH/bin

MQS_PATH=/var/mqm
set -A PREFIX `cat $MQS_PATH/mqs.ini | grep Prefix= | grep -v Default | cut -d "=" -f2`
set -A QMGR_MQS `cat $MQS_PATH/mqs.ini | grep " Name=" | cut -d "=" -f2`

P=0
	for j in ${QMGR_MQS[@]}
	do
	if [[ ${QMGR_MQS[$P]} == "$line" ]]
	then
	MQS_PATH=${PREFIX[$P]}
	fi
	let P=$P+1
        done


#It reads the MQ config file and reads the datapath of the queue manager
QMGR_DATA_PATH=`cat $MQS_PATH/mqs.ini | grep DataPath | grep $line | cut -f 2 -d =`
if [[ -z $QMGR_DATA_PATH ]] 
then
QMGR_DATA_PATH=`echo "$MQS_PATH/qmgrs/$line" | sed 's/\./!/g'`
fi

LOGTYPE=`cat $QMGR_DATA_PATH/qm.ini | grep LogType | cut -f 2 -d "="`

if [[  $STATUS == "Running" ]]
then

##CLUSTER-----------------------------------------
#Checks the cluster details of the queue manager
set -A CLUS `echo "dis clusqmgr(*)" | ./runmqsc $line | grep CLUSTER | cut -d "(" -f2 | cut -d ")" -f1 | sort | uniq`
if [[ -z $CLUS ]]
then
CLUSTER=NO
else
CLUSTER=YES
fi

##SSL---------------------------------------
#Checks for the SSL confuration in queue manager level
SSL_PATH=`echo "dis qmgr sslkeyr" | ./runmqsc $line | grep SSLKEYR | cut -d "(" -f2 | cut -d ")" -f1 | cut -f 1-6 -d /`
SSL_KEY=`echo "dis qmgr sslkeyr" | ./runmqsc $line | grep SSLKEYR | cut -d "(" -f2 | cut -d ")" -f1 |  cut -f 7 -d /`
#Checks for the existance of SSL key database.
SSL=`ls -ltr $SSL_PATH  2>/dev/null  | grep $SSL_KEY | wc -l`
if [[ $SSL > 0 ]]
then
SSL=`echo "Configured"`
else
SSL=`echo "Not Configured"`
fi


#QMANAGERST--------------------------------------
QMGR_ST_L=`ps -ef | grep amqzxma0 | grep "$line" | wc -l`
if [[ $QMGR_ST_L -gt 1 ]];then
set -A QST `ps -ef | grep amqzxma0 | grep "$line" | awk '{print $NF}'`
set -A QST_TL `ps -ef | grep amqzxma0 | grep "$line" | awk '{print $5}' | cut -c 3`
set -A QST_ST1 `ps -ef | grep amqzxma0 | grep "$line"  | awk '{print $5}'`
set -A QST_ST2 `ps -ef | grep amqzxma0 | grep "$line"  | awk '{print $5, $6}' | sed 's/ /_/g'`
i=0
for j in ${QST[@]}
do
if [[ ${QST[$i]} == "$line" ]];then
QMGR_ST_TL=${QST_TL[$i]}
if [[ $QMGR_ST_TL == ":" ]];then
QMGR_ST=${QST_ST1[$i]}
else
QMGR_ST=${QST_ST2[$i]}
fi
fi
let i=$i+1
done
else
if [[ $OS == "Linux" ]]; then
QMGR_ST=`ps -ef | grep amqzxma0 | grep "$line" | awk '{print $5}'`
else
QMGR_ST_TL=`ps -ef | grep amqzxma0 | grep "$line" | awk '{print $5}' | cut -c 3`
if [[ $QMGR_ST_TL == ":" ]];then
QMGR_ST=`ps -ef | grep amqzxma0 | grep "$line" | awk '{print $5}'`
else
QMGR_ST=`ps -ef | grep amqzxma0 | grep "$line" | awk '{print $5, $6}' | sed 's/ /_/g'`
fi
fi
fi

HOSTNAME=`hostname`

printf "\n`tput smul`%-15s| %-10s| %-7s | %-9s | %-8s | %-7s | %-15s | %-8s`tput rmul`" "Queue Manager" VERSION  STATUS STARTTIME LOGTYPE CLUSTER SSL HOSTNAME
printf "\n%-15s| %-10s| `tput bold`\033[42;37m%-7s\033[0m`tput sgr0` | %-9s | %-8s | %-7s | %-15s | %-8s\n" $line  "$VERSION"  RUNNING $QMGR_ST $LOGTYPE $CLUSTER "$SSL" $HOSTNAME

if [[ $CLUSTER == "YES" ]]
then
#If the queue manager is member of cluster, checks for Cluster repository process (amqrrmfa) status.
RRMFA=`ps -ef | grep amqrrmfa | grep "$line "`
printf "\n`tput smul`%-15s| %-20s`tput rmul`"  "CLUSTER NAME"  REPOSITORY
#If the queue manager is member of cluster, checks for cluster names and repository details.
REPOS=`echo "dis qmgr repos" | ./runmqsc $line | grep REPOS | awk '{print $2}' | cut -d "(" -f2 | cut -d ")" -f1`
REPOSNL=`echo "dis qmgr reposnl" | ./runmqsc $line | grep REPOSNL | awk '{print $2}' | cut -d "(" -f2 | cut -d ")" -f1`
y=0
for j in ${CLUS[@]}
do
#Checks for cluster namelist if the queue manager is member of more than one cluster
NLREPO=`echo "dis namelist($REPOSNL)" | ./runmqsc $line | grep ${CLUS[$y]} |  awk '{print $1}' | cut -f 2 -d "," | cut -f 1 -d ")" | cut -f 2 -d "(" `
if [[ ($REPOS == ${CLUS[$y]}) || ($NLREPO == ${CLUS[$y]}) ]]
then
printf "\n%-15s| %-20s"  "${CLUS[$y]}" "Full Repository"   
else
printf "\n%-15s| %-20s" "${CLUS[$y]}"  "Partial Repository"  
fi
let y=$y+1
done

if [[ -z $RRMFA ]]
 then
 printf "\n%-18s| `tput bold`\033[41;37m%-4s\033[0m`tput sgr0`    | `tput bold`\033[41;37m%-5s\033[0m`tput sgr0`" "CLUSTER REPO" DOWN   ALERT  >> $FILE_PATH/"$line"_RRMFA.txt
 else
 printf "\n%-18s| `tput bold`\033[42;37m%-7s\033[0m`tput sgr0` | %-5s" "CLUSTER REPO" RUNNING   OK  >> $FILE_PATH/"$line"_RRMFA.txt
fi

fi

printf "\n\n`tput smul`%-18s| %-8s| %-7s`tput rmul`" "SERVICES/PROCESS"  STATUS  COMMENT
##For LISTENER---------------------------------------------
#Checks for name and port number of listeners in running state.
set -A LSR `echo "dis lsstatus(*) port" | ./runmqsc $line | grep PORT | awk '{print $1}' | cut -d "(" -f2 | cut -d ")" -f1`
set -A LSR_PORT `echo "dis lsstatus(*) port" | ./runmqsc $line | grep PORT | awk '{print $2}' | cut -d "(" -f2 | cut -d ")" -f1`
if [[ -e /etc/inetd.conf ]]
then
MQ_SERVICE=`cat /etc/inetd.conf | grep $line | awk '{print $1}'`
else 
if [[  (-e /etc/xinetd.conf) && ($OS == "Linux") ]]
then
MQ_SERVICE=`cat /etc/xinetd.conf | grep $line | awk '{print $1}'`
fi
fi

 if [[ -z $MQ_SERVICE ]] 
 then
 MQ_SER_PORT_ST=$MQ_SERVICE
 else
 MQ_SERVICE_FL=`echo "$MQ_SERVICE" | cut -c1`
 if [[ $MQ_SERVICE_FL != "#" ]]
 then
 MQ_SER_PORT=`cat /etc/services | grep "$MQ_SERVICE  " | awk '{print $2}' | cut -d "/" -f1`
 MQ_SER_PORT_ST=`netstat -an  | grep "$MQ_SER_PORT "`
 else
 MQ_SER_PORT_ST=''
 fi
 fi


 if [[ ($LSR > 0) && ($MQ_SER_PORT_ST > 0) ]]
then
printf "\n%-18s| `tput bold`\033[42;37m%-7s\033[0m`tput sgr0` | %-40s"   LISTENER	RUNNING  "Port: $MQ_SER_PORT"
i=0
 for j in ${LSR[@]}
 do
 printf "\n%-18s| `tput bold`\033[42;37m%-7s\033[0m`tput sgr0` | %-40s"   LISTENER	RUNNING  "Name: ${LSR[$i]}  Port: ${LSR_PORT[$i]}"  
 let i=$i+1
 done

else
 
 if [[ (-z $LSR) && (-z $MQ_SER_PORT_ST) ]]
 then
 printf "\n%-18s| `tput bold`\033[41;37m%-4s\033[0m`tput sgr0`    | `tput bold`\033[41;37m%-5s\033[0m`tput sgr0`" LISTENER DOWN ALERT  
 else
 if [[ -z $LSR ]]
 then 
 printf "\n%-18s| `tput bold`\033[42;37m%-7s\033[0m`tput sgr0` | %-40s"   LISTENER	RUNNING  "Port: $MQ_SER_PORT"
 else
 i=0
 for j in ${LSR[@]}
 do
 printf "\n%-18s| `tput bold`\033[42;37m%-7s\033[0m`tput sgr0` | %-40s"   LISTENER	RUNNING  "Name: ${LSR[$i]}  Port: ${LSR_PORT[$i]}"  
 let i=$i+1
 done
 fi
 fi
fi


##Channel Initiator process------------------------------------------
CHI=`ps -ef | grep runmqchi | grep "$line " | wc -l`
if [[ $CHI == 0 ]]
then 
printf "\n%-18s| `tput bold`\033[41;37m%-4s\033[0m`tput sgr0`    | `tput bold`\033[41;37m%-5s\033[0m`tput sgr0`" "Channel Initiator" DOWN ALERT  
else
printf "\n%-18s| `tput bold`\033[42;37m%-7s\033[0m`tput sgr0` | %-15s"  "Channel Initiator" RUNNING "$CHI instances"   
fi


if [[ -e $FILE_PATH/"$line"_RRMFA.txt ]]
then
cat  $FILE_PATH/"$line"_RRMFA.txt  
rm  $FILE_PATH/"$line"_RRMFA.txt
fi

##Command server process ------------------------------------------
CSV=`ps -ef | grep amqpcsea | grep "$line"`
if [[ -z $CSV ]]
then
printf "\n%-18s| `tput bold`\033[41;37m%-4s\033[0m`tput sgr0`    | `tput bold`\033[41;37m%-5s\033[0m`tput sgr0`" "Command Server"  DOWN ALERT  
else
printf "\n%-18s| `tput bold`\033[42;37m%-7s\033[0m`tput sgr0` | %-5s" "Command Server"  RUNNING OK   
fi




##Dead letter queue ---------------------------------------------------------------
COL_DEADQ=`echo "dis qmgr deadq" | ./runmqsc $line | grep DEADQ | awk '{print $2}' | cut -d "(" -f1`
if [[ $COL_DEADQ == "DEADQ" ]]
then 
DEADQ=`echo "dis qmgr deadq" | ./runmqsc $line | grep DEADQ | awk '{print $2}' | cut -d "(" -f2 | cut -d ")" -f1`
else
DEADQ=`echo "dis qmgr deadq" | ./runmqsc $line | grep DEADQ | awk '{print $1}' | cut -d "(" -f2 | cut -d ")" -f1`
fi
DEADQ_E=`echo "dis ql($DEADQ)" | ./runmqsc $line | grep TYPE`
if [[ (-z $DEADQ) || (-z $DEADQ_E) ]]
then 
printf "\n\n`tput bold`\033[43;37mNo Dead Letter Queue defined for the Qmgr $line\033[0m`tput sgr0`"  
else
printf "\n\n`tput smul`%-30s|%-11s|%-11s|%-7s`tput rmul`" "DEAD LETTER QUEUE" MAXDEPTH  CURDEPTH COMMENT   
LQ=$DEADQ
DEPTH
DEADQ_CURDEPTH=$CURDEPTH
DEADQ_MAXDEPTH=$MAXDEPTH

if [[ $DEADQ_CURDEPTH > 0 ]] 
then 
printf "\n%-30s|%-11s|`tput bold`\033[41;37m%-11s\033[0m`tput sgr0`|`tput bold`\033[41;37m%-5s\033[0m`tput sgr0`" "$DEADQ"  $DEADQ_MAXDEPTH $DEADQ_CURDEPTH ALERT 
else
printf "\n%-30s|%-11s|%-11s|%-5s" $DEADQ  $DEADQ_MAXDEPTH  $DEADQ_CURDEPTH OK 
fi
fi


##SVRCONN Channels----------------------------------------------
printf "\n\n`tput smul`SVRCONN channel |  MAX ACTIVE CHANNEL |  CURRENT ACTIVE CHANNEL`tput rmul`"  
#Checks for Max active channel count for the queue manager
MAX_SVRCONN=`cat $QMGR_DATA_PATH/qm.ini | grep MaxActiveChannels | cut -d "=" -f2`
if [[ -z $MAX_SVRCONN ]]
then 
MAX_SVRCONN=100
fi
MAX_SVRCONN_TEMP=`expr $MAX_SVRCONN / 100`
MAX_SVRCONN_E=`expr $MAX_SVRCONN_TEMP \* 80`
#Checks for currently active channel count
CUR_SVRCONN=`echo "dis chs(*)" | ./runmqsc $line | grep SVRCONN | wc -l | awk '{print $1}'`

if [[ $CUR_SVRCONN > $MAX_SVRCONN_E ]]
then
printf "\nCOUNT           |  $MAX_SVRCONN                |  `tput bold`\033[41;37m$CUR_SVRCONN\033[0m`tput sgr0`"  
else
printf "\nCOUNT           |  $MAX_SVRCONN                |  $CUR_SVRCONN"  
fi


##Other Channel status--------------------------------------------
set -A ab `echo "dis chs(*)" | ./runmqsc $line | grep CHANNEL | grep -v SVRCONN | cut -d "(" -f2  | cut -d ")" -f1 | sort |  uniq`
if [[ -z $ab ]]
then
printf "\n\nNo other channel is Active" 
else
  d=0
  for j in ${ab[@]}
  do
  CHL_TYPE=`echo "dis chs('${ab[$d]}')" | ./runmqsc $line | grep CHLTYPE | awk '{print $2}' | cut -d "(" -f2  | cut -d ")" -f1 | uniq`


if [[ $CHL_TYPE == "CLUSRCVR" ]]
then
#Instances of Cluster receiver channels are added to an array
set -A CHL_RQMN `echo "dis chs('${ab[$d]}')" | ./runmqsc $line | grep RQMNAME |  awk '{print $1}' | cut -f 2 -d "(" | cut -f 1 -d ")" `

CLURCV=1
RQMN=0
	for j in ${CHL_RQMN[@]}
	do
	STATUS=`echo "dis chs('${ab[$d]}') where(RQMNAME eq "${CHL_RQMN[$RQMN]}")" | ./runmqsc $line | grep STATUS | awk '{print $2}' | cut -d "(" -f2 | cut -d ")" -f1`
	if [[ ($STATUS != "RUNNING") ]]
  	then
  	CHL_XMITQ="NOT_APPLICABLE"
	CHL_CONNAME="NOT_APPLICABLE"
	LSTMSGTI=`echo "dis chs('${ab[$d]}') where(RQMNAME eq "${CHL_RQMN[$RQMN]}") lstmsgti" | ./runmqsc $line | grep LSTMSGTI | cut -f 1 -d ")" | cut -f 2 -d "("`
	LSTMSGDA=`echo "dis chs('${ab[$d]}') where(RQMNAME eq "${CHL_RQMN[$RQMN]}") lstmsgda" | ./runmqsc $line | grep LSTMSGDA | cut -f 1 -d ")" | cut -f 2 -d "("`
printf "\n%-22s|%-8s|%-25s|%-30s|`tput bold`\033[41;37m%-12s\033[0m`tput sgr0`|%10s_%-10s" "${ab[$d]} -$CLURCV instance"  $CHL_TYPE  "$CHL_CONNAME"  $CHL_XMITQ  "$STATUS"  "$LSTMSGDA"  "$LSTMSGTI" >>  $FILE_PATH/"$line"_OUTPUT_CHANNEL.txt
	else
	CHL_ISSUE_1=NO
	fi
	let RQMN=$RQMN+1
	let CLURCV=$CLURCV+1
	done
else
  COL_STATUS=`echo "dis chs('${ab[$d]}')" | ./runmqsc $line | grep STATUS | awk '{print $1}' | cut -d "(" -f1`
	if [[ $COL_STATUS == "STATUS" ]]
	then 
	STATUS=`echo "dis chs('${ab[$d]}')" | ./runmqsc $line | grep STATUS | awk '{print $1}' | cut -d "(" -f2 | cut -d ")" -f1`
	else
	STATUS=`echo "dis chs('${ab[$d]}')" | ./runmqsc $line | grep STATUS |  cut -f 3 -d "("  | cut -d ")" -f1`
	fi
  if [[ ($STATUS != "RUNNING") ]]
  then
  COL_LSTMSGTI=`echo "dis chs('${ab[$d]}') lstmsgti" | ./runmqsc $line | grep LSTMSGTI | awk '{print $1}' | cut -d "(" -f1` 
  COL_LSTMSGDA=`echo "dis chs('${ab[$d]}') lstmsgda" | ./runmqsc $line | grep LSTMSGDA | awk '{print $1}' | cut -d "(" -f1`
if [[ $COL_LSTMSGTI == "LSTMSGTI" ]]
	then 
	LSTMSGTI=`echo "dis chs('${ab[$d]}') lstmsgti" | ./runmqsc $line | grep LSTMSGTI | awk '{print $1}' | cut -d "(" -f2 | cut -d ")" -f1`
	else
	LSTMSGTI=`echo "dis chs('${ab[$d]}') lstmsgti" | ./runmqsc $line | grep LSTMSGTI | awk '{print $2}' | cut -d "(" -f2 | cut -d ")" -f1`
	fi

if [[ $COL_LSTMSGDA == "LSTMSGDA" ]]
	then 
	LSTMSGDA=`echo "dis chs('${ab[$d]}') lstmsgda" | ./runmqsc $line | grep LSTMSGDA | awk '{print $1}' | cut -d "(" -f2 | cut -d ")" -f1`
	else
	LSTMSGDA=`echo "dis chs('${ab[$d]}') lstmsgda" | ./runmqsc $line | grep LSTMSGDA | awk '{print $2}' | cut -d "(" -f2 | cut -d ")" -f1`
	fi


if [[ $CHL_TYPE == "SDR" ]]
then
#Checks for transmit queue and connection name details of the sender channels in issue.
CHL_XMITQ=`echo "dis chl('${ab[$d]}') xmitq" | ./runmqsc $line | grep XMITQ | awk '{print $1}' | cut -d "(" -f2 | cut -d ")" -f1`
CHL_CONNAME=`echo "dis chl('${ab[$d]}') conname" | ./runmqsc $line | grep CONNAME | cut -f 2,3 -d "(" | sed 's/ //g'`
else
CHL_XMITQ="NOT_APPLICABLE"
CHL_CONNAME="NOT_APPLICABLE"
fi

if  [[ ($CHL_TYPE == "SDR") || ($CHL_TYPE == "CLUSSDR") ]]
then
CHL_PING=`echo "ping chl('${ab[$d]}')" | ./runmqsc $line | grep AMQ | cut -d ":" -f2`
else
CHL_PING="NOT_APPLICABLE"
fi

 printf "\n%-22s|%-8s|%-25s|%-30s|`tput bold`\033[41;37m%-12s\033[0m`tput sgr0`|%10s_%-10s|%-20s" "${ab[$d]}"  $CHL_TYPE  "$CHL_CONNAME"  $CHL_XMITQ  "$STATUS"  "$LSTMSGDA"   "$LSTMSGTI" "$CHL_PING" >>  $FILE_PATH/"$line"_OUTPUT_CHANNEL.txt
else
CHL_ISSUE_2=NO
  fi
fi

  let d=$d+1
  done
fi


if [[ ($CHL_ISSUE_1 == "NO") && ($CHL_ISSUE_2 == "NO") ]]
then
printf "\n\n`tput bold`\033[42;37mNo other channel is in issue\033[0m`tput sgr0`"   
fi

if [[ -s $FILE_PATH/"$line"_OUTPUT_CHANNEL.txt ]]
then
printf "\n\n`tput smul`%-22s|%-8s|%-25s|%-30s|%-12s| %-18s  |%-12s`tput rmul`" CHANNEL_NAME  CHL_TYPE  CHL_CONNAME  XMITQ STATUS Last_MSG_DATE_TIME  PING_CHANNEL
cat $FILE_PATH/"$line"_OUTPUT_CHANNEL.txt 
rm $FILE_PATH/"$line"_OUTPUT_CHANNEL.txt
printf "\n"
fi


##XMITQ & Local queue depth check----------------------------------------------
#Lsits all the local and transmit queues with messages
set -A xy `echo "dis ql(*) where(curdepth ge 1)" | ./runmqsc $line | grep QUEUE | cut -d "(" -f2 | cut -d ")" -f1`
m=0
for j in ${xy[@]}
do
LQ=${xy[$m]}
DEPTH
COL_USAGE=`echo "dis ql('${xy[$m]}') usage" | ./runmqsc $line | grep USAGE | awk '{print $1}' | cut -d "(" -f1`
      if [[ $COL_USAGE == "USAGE" ]]
      then
      USAGE=`echo "dis ql('${xy[$m]}') usage" | ./runmqsc $line | grep USAGE | awk '{print $1}' |  cut -d "(" -f2 | cut -d ")" -f1`
      else 
      USAGE=`echo "dis ql('${xy[$m]}') usage" | ./runmqsc $line | grep USAGE | cut -f 3 -d "("  | cut -d ")" -f1`
      fi
if [[ $USAGE == "XMITQ" ]]
then
PROCS
printf "\n%-30s|%-11s|`tput bold`\033[41;37m%-11s\033[0m`tput sgr0`|%-10s|%-10s" "${xy[$m]}" $MAXDEPTH $CURDEPTH $IPPROCS $OPPROCS >> $FILE_PATH/"$line"_OUTPUT_X.txt
else
ALT_DEPTH_TEMP=`expr $MAXDEPTH / 100`
ALT_DEPTH_E=`expr $ALT_DEPTH_TEMP \* 80`
ALT_DEPTH_N=`expr $ALT_DEPTH_TEMP \* 90`
if [[ $CURDEPTH -ge $ALT_DEPTH_N ]]
then
PROCS
TRIGGER
printf "\n%-30s|%-11s|`tput bold`\033[41;37m%-11s\033[0m`tput sgr0`|%-10s|%-10s|%-10s" "${xy[$m]}"  $MAXDEPTH $CURDEPTH $IPPROCS $OPPROCS $TRIGGER >> $FILE_PATH/"$line"_OUTPUT_N.txt
else
if [[ $CURDEPTH -ge $ALT_DEPTH_E ]]
then
PROCS
TRIGGER
printf "\n%-30s|%-11s|`tput bold`\033[41;37m%-11s\033[0m`tput sgr0`|%-10s|%-10s|%-10s" "${xy[$m]}"  $MAXDEPTH $CURDEPTH $IPPROCS $OPPROCS $TRIGGER >> $FILE_PATH/"$line"_OUTPUT_E.txt
fi
fi
fi
let m=$m+1
done

if [[ -s  $FILE_PATH/"$line"_OUTPUT_X.txt ]]
then
printf "\n\nBelow XMITQ queues having messages - `tput bold`\033[41;37mALERT\033[0m`tput sgr0`"  
printf "\n`tput smul`%-30s|%-11s|%-11s|%-10s|%-10s`tput rmul`" "QUEUE NAME" MAXDEPTH  CURDEPTH  IPPROCS  OPPROCS 
cat $FILE_PATH/"$line"_OUTPUT_X.txt  
rm $FILE_PATH/"$line"_OUTPUT_X.txt
printf "\n"
else
printf "\n\n`tput bold`\033[42;37mAll Transmit queues are EMPTY\033[0m`tput sgr0`"   
fi


if [[ -s  $FILE_PATH/"$line"_OUTPUT_N.txt ]]
then
printf "\n\nBelow Local queues are more than 90%% FULL -  `tput bold`\033[41;37mALERT\033[0m`tput sgr0`"  
printf "\n`tput smul`%-30s|%-11s|%-11s|%-10s|%-10s|%-10s`tput rmul`" "QUEUE NAME" MAXDEPTH  CURDEPTH  IPPROCS  OPPROCS TRIGGER 
cat $FILE_PATH/"$line"_OUTPUT_N.txt 
rm $FILE_PATH/"$line"_OUTPUT_N.txt
printf "\n"
else
QL=1
fi
if [[ -s  $FILE_PATH/"$line"_OUTPUT_E.txt ]]
then
printf "\n\nBelow Local queues are more than 80%% FULL -  `tput bold`\033[43;37mWARNING\033[0m`tput sgr0`"
printf "\n`tput smul`%-30s|%-11s|%-11s|%-10s|%-10s|%-10s`tput rmul`" "QUEUE NAME" MAXDEPTH  CURDEPTH  IPPROCS  OPPROCS TRIGGER  
cat $FILE_PATH/"$line"_OUTPUT_E.txt   
rm  $FILE_PATH/"$line"_OUTPUT_E.txt
printf "\n"
else
let QL=$QL+1
fi

if [[ $QL == 2 ]]
then 
printf "\n\n`tput bold`\033[42;37mNo Local Queue is more than 80%% full\033[0m`tput sgr0`"  
fi

if [[ $TRIGGER_PROC > 0 ]]
then
#Checks for the trigger process status if any queue is more than 80% full
TRIG_PROCESS=`ps -ef | grep runmqtrm | grep "$line "`
	if [[ $TRIG_PROCESS > 0 ]]
	then
	printf "\nTrigger process is `tput bold`\033[42;37mRUNNING\033[0m`tput sgr0` fine"
	else
	printf "\nTrigger process is `tput bold`\033[41;37mDOWN\033[0m`tput sgr0`"
	fi
fi
TRIGGER_PROC=0
##FDC files --------------------------------
FDC_PATH=/var/mqm/errors
#checks for the existance of FDC file. If file(s) exists checks for last FDC file timestamp.
FDC_COUNT=`ls -ltr $FDC_PATH/*.FDC 2>/dev/null | wc -l`
if [[ $FDC_COUNT -gt 0 ]]
then
FDC=`ls -ltr $FDC_PATH/*.FDC  2>/dev/null | tail -1 | awk '{print $NF}'`
FDC_TIME=`ls -ltr $FDC_PATH/*.FDC  2>/dev/null | tail -1 | awk '{print $6, $7, $8}'`
if [[ $FDC != 0 ]]
then
printf "\n\nLast FDC file created was `tput bold`\033[46;37m$FDC\033[0m`tput sgr0` at `tput bold`\033[46;37m$FDC_TIME\033[0m`tput sgr0`"
fi
else
printf "\n\n`tput bold`\033[42;37mNo FDC files under $FDC_PATH\033[0m`tput sgr0`"
fi

##File system space ------------------------
OS=`uname`
printf "\n\nMQ FILE SYSTEM STATUS"
printf "\n`tput smul`%-35s - %-20s`tput rmul`" Directory  "Space utilization"
#It reads the QM config file and reads the LogPath location  
QMGR_LOG_PATH=`cat $QMGR_DATA_PATH/qm.ini | grep LogPath | cut -f 2 -d =`
#For AIX servers - Checks for data and log path free space status
if [[ $OS == "AIX" ]]
then
cd $QMGR_DATA_PATH
QMGR_DATA_DIR=`df -g . | grep -v File | awk '{print $NF}'`
QMGR_DATA_PER=`df -g . | grep -v File | awk '{print $(NF-3)}' | cut -f 1 -d %`
cd $QMGR_LOG_PATH
QMGR_LOG_DIR=`df -g . | grep -v File | awk '{print $NF}'`
QMGR_LOG_PER=`df -g . | grep -v File | awk '{print $(NF-3)}' | cut -f 1 -d %`
cd $FILE_PATH

if [[ $QMGR_DATA_PER > 90 ]]
then
printf "\n%-35s - `tput bold`\033[41;37m%-8s\033[0m`tput sgr0`" "$QMGR_DATA_DIR" ""$QMGR_DATA_PER"% full" 
else
printf "\n%-35s - %-20s" "$QMGR_DATA_DIR"  ""$QMGR_DATA_PER"%"
fi

if [[ "$QMGR_DATA_DIR" != "$QMGR_LOG_DIR" ]]
then
if [[ $QMGR_LOG_PER > 90 ]]
then
printf "\n%-35s - `tput bold`\033[41;37m%-8s\033[0m`tput sgr0`" "$QMGR_LOG_DIR" ""$QMGR_LOG_PER"% full" 
else
printf "\n%-35s - %-20s" "$QMGR_LOG_DIR"   ""$QMGR_LOG_PER"%"
fi
fi

QMGR_SIZE=`du -ms  $QMGR_DATA_PATH | awk '{print $1}'`
QMGR_LOG_SIZE=`du -ms  $QMGR_LOG_PATH | awk '{print $1}'`
printf "\n%-35s - %-20s" "$QMGR_DATA_PATH" ""$QMGR_SIZE"M"  
printf "\n%-35s - %-20s\n" "$QMGR_LOG_PATH" ""$QMGR_LOG_SIZE"M"  
printf "\n"


else
#For Solaris and Linux servers - Checks for data and log path free space status
cd $QMGR_DATA_PATH
QMGR_DATA_DIR=`df -h . | grep "G " | awk '{print $NF}'`
QMGR_DATA_PER=`df -h . | grep "G " | awk '{print $(NF-1)}' | cut -f 1 -d %`
QMGR_DATA_SIZ=`df -h . | grep "G " | awk '{print $(NF-3)}'`
cd $QMGR_LOG_PATH
QMGR_LOG_DIR=`df -h . | grep "G " | awk '{print $NF}'`
QMGR_LOG_PER=`df -h . | grep "G " | awk '{print $(NF-1)}' | cut -f 1 -d %`
QMGR_LOG_SIZ=`df -h . | grep "G " | awk '{print $(NF-3)}'`
cd $FILE_PATH

if [[ $QMGR_DATA_PER > 90 ]]
then
printf "\n%-35s - %-5s - `tput bold`\033[41;37m%-8s\033[0m`tput sgr0`" "$QMGR_DATA_DIR" "$QMGR_DATA_SIZ" ""$QMGR_DATA_PER"% full"
else
printf "\n%-35s - %-20s" "$QMGR_DATA_DIR" "$QMGR_DATA_SIZ - $QMGR_DATA_PER%"
fi

if [[ "$QMGR_DATA_DIR" != "$QMGR_LOG_DIR" ]]
then
if [[ $QMGR_LOG_PER > 90 ]]
then
printf "\n%-35s - %-5s - `tput bold`\033[41;37m%-8s\033[0m`tput sgr0`" "$QMGR_LOG_DIR" "$QMGR_LOG_SIZ" ""$QMGR_LOG_PER"% full" 
else
printf "\n%-35s - %-20s" "$QMGR_LOG_DIR" "$QMGR_LOG_SIZ - $QMGR_LOG_PER%"
fi
fi


QMGR_SIZE=`du -hs  $QMGR_DATA_PATH | awk '{print $1}'`
QMGR_LOG_SIZE=`du -hs  $QMGR_LOG_PATH | awk '{print $1}'`
printf "\n%-35s - %-20s" "$QMGR_DATA_PATH"  "$QMGR_SIZE"  
printf "\n%-35s - %-20s\n" "$QMGR_LOG_PATH" "$QMGR_LOG_SIZE"  
printf "\n"
fi



else
printf "\nQueue manager $line is `tput bold`\033[41;37mDOWN\033[0m`tput sgr0` --- `tput bold`\033[41;37mALERT\033[0m`tput sgr0`\n"  
fi
else
printf "\n======================================================================================="
printf "\nQueue Manager $line does not exists in the server. Please check the Queue Manager name"
printf "\n=======================================================================================\n"
fi
}


OS=`uname`
FILE_PATH=`pwd`
USER_ID=`id | awk '{print $1}' | cut -d "(" -f2 | cut -d ')' -f1`
MQM_GROUP=`id $USER_ID | grep mqm`

if [[ -z $MQM_GROUP ]]
then 
printf "\nPlease run the script with id which has 'mqm' privilages\n"
else

if [ "$#" != 0 ]
then
line=`echo $1`
printf "\n\n======================================================================================="
printf "\nMQFIR report: QMGR - `tput bold`\033[45;37m$line\033[0m`tput sgr0`"  
printf "\n=======================================================================================\n"
MAIN
else
#Reads the list of queue managers configured in the server.
set -A QMGR_LIST `dspmq | cut -d ")" -f1 | cut -d "(" -f2`
printf "\n\nQueue manager(s) configured in this server:\n"
QQ=0
for j in ${QMGR_LIST[@]}
do
echo "${QMGR_LIST[$QQ]}"
let QQ=$QQ+1
done

if [[ $QQ == 1 ]]
then
line="${QMGR_LIST[0]}"
printf "\n\n======================================================================================="
printf "\nMQFIR report: QMGR - `tput bold`\033[45;37m$line\033[0m`tput sgr0`"  
printf "\n=======================================================================================\n"
MAIN
else
printf "\n\nType a Queue manager name or ALL to see the report:"
#reads the queue manager name (or all) to generate the report
read line
if [ "$line" != 0 ]; then
FILE_PATH=`pwd`
if [[ "$line" == "all" || "$line" == "ALL" || "$line" == "All" ]]
then
QLL=0
for j in ${QMGR_LIST[@]}
do
line="${QMGR_LIST[$QLL]}" 
printf "\n\n======================================================================================="
printf "\nMQFIR report: QMGR - `tput bold`\033[45;37m$line\033[0m`tput sgr0`"  
printf "\n=======================================================================================\n"
MAIN
printf "=======================================================================================\n"
let QLL=$QLL+1
done
else
printf "\n======================================================================================="
printf "\nMQFIR report: QMGR - `tput bold`\033[45;37m$line\033[0m`tput sgr0`"  
printf "\n=======================================================================================\n"
MAIN
fi
else
printf "\n\nType a Queue manager name or ALL to see the report:"
fi
fi
fi
fi

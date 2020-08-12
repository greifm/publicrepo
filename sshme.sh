#!/bin/bash

# sshme
# an alternative to ssh and scp
# can be used accross multiple servers
# usage
# if -t to and -f from are specified it will act as scp, if not it will act as ssh, 
# in all cases -s server must be specified
# by default the scp command will copy from server to current directory
# to copy to server use -r reverse flag

#todo
#   * expansion
#       can not be fixed, use a \ backslash. (issue arrises before from=$OPTARG; possibly set -f; no)

# methods
usage () { echo "Usage: $0 [ -s SERVER ] [ -f FROM ] [ -t TO ] [ -r REVERSE ] [ -h HELP ]"
            echo "If only given a server command will connect via ssh, if given locations the command will scp"
            echo "Please use backslashes (\) on special characters"; }
exit_abnormal() { usage; exit 1; }

# defaults
to="."; reverse=false; connect=true; server=none; from=none

# getoptions
if [ $# = 0 ]; then exit_abnormal; fi
while getopts ":s:f:t:rh" arg
do
    case $arg in
        s) server=$OPTARG ;;
        f) from=$OPTARG ; connect=false ;;
        t) to=$OPTARG ; connect=false ;;
        r) reverse=true ;;
        h) usage; exit 1;;
        :) echo "Error: -${OPTARG} requires an argument."; exit_abnormal;;
        *) exit_abnormal ;;
    esac
done

# server choice
if [ $server = "magnus" ]; then 
    server="USERPAWSEY@magnus.pawsey.org.au"
elif [ $server = "gadi" ]; then 
    server="USERNCI@gadi.nci.org.au"
elif [ $server = "zeus" ]; then 
    server="USERPAWSEY@zeus.pawsey.org.au"
else 
    exit_abnormal
fi


# do work
if [ $connect = "true" ]
then
    # just connect
    ssh $server
else
    # scp
    # check input
    if [ $from = "none" ]; then exit_abnormal; fi
    if [ $reverse = "false" ]
    then
        scp ${server}:/${from} $to 
    else
        scp $to ${server}:/${from}
    fi
fi

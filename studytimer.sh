#!/bin/bash

# Study timer for studying
# takes arguments work, break, and repeat
# scrypt will signal when the work and break periods end and begin
# it will then repeat
# defauts are work for 45 minutes, break for 5, and repeat infinitely

date_str=${date}
date_int_start=$(date +%s)
alias spd-say="spd-say -r -50 "

# required methods
usage() 
{ 
	echo "Usage: $0 [ -w WORK ] [ -b BREAK ] [ -r REPEAT ] [ -h HELP ]" 
	echo "-w -b -r, time in minutes"
	echo "Will take either flagged arguments or unflagged, default order, arguments. Enable sound for full effect." # On ^C program will exit safely."
	echo "Audio glitch with spd-say can be solved easily https://askubuntu.com/questions/1027885/when-the-default-text-to-speech-program-spd-say-speaks-it-is-accompanied-by-no"
}
exit_abnormal() 
{
	usage
	exit 1
}
exit_safe()
{
	date_int_now=$(date +%s)
	time_int=$(( ($date_int_now - $date_int_start) / 60))
	echo ""
	echo "Session was active for $time_int minutes"
	spd-say "Session ended" &
	exit 0
}

# get variables, 
# default is to work for 45m break 5m and repeat forever
# can take either flagged or unflagged arguments

work=45; brek=5; repeat=0
if [[ $1 == *-* ]]
then
	while getopts ":w:b:r:h" arg
	do
		case $arg in
			w) work=$OPTARG;;
			b) brek=$OPTARG;;
			r) repeat=$OPTARG;;
			h) usage; exit 1;;
			:) echo "Error: -${OPTARG} requires an argument."; exit_abnormal;;
			*) exit_abnormal ;;
		esac
	done
elif [ "$#" == "2" ]; then work="$1"; brek="$2"
elif [ "$#" == "3" ]; then work="$1"; brek="$2"; repeat="$3"
fi 

# check input is good 
for kk in $work $brek $repeat
do
	if [[ $kk =~ ^[a-zA-Z]*$ ]] # not perfect, negs etc will break scrypt
	then 
		exit_abnormal
	fi
done 

# on ctrl-c save and exit
trap exit_safe SIGINT

# begin repeating timer
echo $date_str
if [ $repeat -eq 0 ]
then
	echo "Begining study; work for $work minutes, break for $brek minutes. This will repeat indefinitely"

	ii=0
	while :
	do
		echo "Study session $ii"; echo "Begin work for $work minutes"
		spd-say "Begin study" &
		sleep $(( 60 * $work ))
		(( ii += 1 ))
		echo "Begin break for $brek minutes"
		spd-say "Begin break" &
		sleep $(( 60 * $brek ))
		echo ""
	done
else
	echo "Begining study; work for $work minutes, break for $brek minutes, for $repeat cycles"

	for (( ii=1; ii<=$repeat; ii++ ))
	do
		echo "Study session $ii of $repeat"
		echo "Begin study for $work minutes"
		spd-say "Begin study" &
		sleep $(( 60 * $work ))
		echo "Begin break for $brek minutes"
		spd-say "Begin break" &
		sleep $(( 60 * $brek ))
		echo ""
	done
fi

# exit safely
exit_safe


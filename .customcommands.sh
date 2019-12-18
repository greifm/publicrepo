#!/bin/bash/

# custom commands for bashrc
# initiate by adding "source .customcommands.sh" to the last line of .bashrc

# connect via ssh to pawsey
function connectmagnus()
{
	ssh greifm@magnus.pawsey.org.au
}

# copy files using scp, see .securecopymagnus for help and information
function securecopymagnus()
{
	# define variables
	drive="$1"
	source="$2"
	# $3 is in path and takes null values
	if [ -z $3 ]
	then
		echo "depositing to current directory"
		deposit="."
	else
		echo "depositing to directory ${3}"
		deposit=$3
	fi

	# choose between scratch and group	
	if [[ $drive == '-s' ]]
	then
		echo "begin secure copy from scratch drive"
		scp greifm@magnus.pawsey.org.au:/scratch/pawsey0110/greifm/$source $deposit
	elif [[ $drive == '-g' ]]
	then
		echo "begin secure copy from group drive"
		scp greifm@magnus.pawsey.org.au:/group/pawsey0110/greifm/$source $deposit
	elif [[ $drive == "-h" ]]
	then
		less ~/.securecopymagnushelp
	else
		echo "no argument given, use -h for help"
	fi
}


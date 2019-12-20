#!/bin/bash/

# this is the make file for the securecopymagnus script

echo "what is your pawsey username?"
read username
echo "begining make file..."

cp .securecopymagnushelp ~/
cd ~/
echo "#!/bin/bash/" > .securecopymagnus.sh
echo "# custom commands for bashrc" >> .securecopymagnus.sh
echo "# initiate by adding \"source .securecopymagnus.sh\" to the last line of .bashrc" >> .securecopymagnus.sh
echo "" >> .securecopymagnus.sh
echo "# copy files using scp, see .securecopymagnus for help and information" >> .securecopymagnus.sh
echo "" >> .securecopymagnus.sh
echo "function securecopymagnus()"  >> .securecopymagnus.sh
echo "{" >> .securecopymagnus.sh
echo "    # define variables" >> .securecopymagnus.sh
echo "    drive=\"\$1\" " >> .securecopymagnus.sh
echo "    source=\"\$2\" " >> .securecopymagnus.sh
echo "    # \$3 is in path and takes null values " >> .securecopymagnus.sh
echo "    if [ -z \$3 ]" >> .securecopymagnus.sh
echo "    then " >> .securecopymagnus.sh
echo "        echo \"depositing to current directory\" " >> .securecopymagnus.sh
echo "        deposit=\".\" " >> .securecopymagnus.sh
echo "    else " >> .securecopymagnus.sh
echo "        echo \"depositing to directory \${3}\" " >> .securecopymagnus.sh
echo "        deposit=\$3 " >> .securecopymagnus.sh
echo "    fi " >> .securecopymagnus.sh
echo "" >> .securecopymagnus.sh
echo "    # choose between scratch and group " >> .securecopymagnus.sh
echo "    if [[ \$drive == '-s' ]] " >> .securecopymagnus.sh
echo "    then " >> .securecopymagnus.sh
echo "        echo \"begin secure copy from scratch drive\" " >> .securecopymagnus.sh
echo "        scp ${username}@magnus.pawsey.org.au:/scratch/pawsey0110/${username}/\$source \$deposit " >> .securecopymagnus.sh
echo "    elif [[ \$drive == '-g' ]] " >> .securecopymagnus.sh
echo "    then " >> .securecopymagnus.sh
echo "        echo \"begin secure copy from group drive\" " >> .securecopymagnus.sh
echo "        scp ${username}@magnus.pawsey.org.au:/group/pawsey0110/${username}/\$source \$deposit " >> .securecopymagnus.sh
echo "    elif [[ \$drive == \"-h\" ]] " >> .securecopymagnus.sh
echo "    then " >> .securecopymagnus.sh
echo "        less ~/.securecopymagnushelp " >> .securecopymagnus.sh
echo "    else " >> .securecopymagnus.sh
echo "        echo \"no argument given, use -h for help\" " >> .securecopymagnus.sh
echo "    fi " >> .securecopymagnus.sh
echo "} " >> .securecopymagnus.sh

echo "make file completed, please check .securecopymagnus.sh to ensure there was no glitch"
echo "would you like to automatically source this file to your .bashrc?"
read permission
if [ $permission == 'y' ] || [ $permission == 'yes' ]
then
    echo "source ~/.securecopymagnus.sh" >> .bashrc
    echo "command added to .bashrc"
else
    echo "command not added to .bashrc"
fi
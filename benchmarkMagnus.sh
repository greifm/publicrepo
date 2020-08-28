#!/bin/bash

# a program to benchmark gromacs md on magnus
# place this in a dir with all required files
# requires a job file with variables nodes_var and cores_var in the file jobsub.sh

# define nodes to test 
#   all other defining (such as time) is taken from the jobsub.sh file
nodes=(1 2 3 4 5 6 7 8 9 10 11 12)

for ii in ${nodes[*]}
do
    mkdir $ii
    cd $ii
    cp -r ../files/* .
    sed -i "s/nodes_var/$ii/g" jobsub.sh
    let cores=($ii * 24)
    sed -i "s/cores_var/$cores/g" jobsub.sh
    cd ..
done

# submit 
echo '############ Listing files ###############'
for ii in $nodes; do echo $ii; ls $ii; done
echo "Would you like to submit?
read nothing

for ii in ${nodes[*]}
do
    cd $ii
    sbatch jobsub.sh
    cd ..
done

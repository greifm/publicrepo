#!/bin/bash

# a program to benchmark gromacs md on magnus
# place this in a dir with all required files
# requires a job file with variables nodes_var cores_var, time_var in the file jobsub.sh
# requires the jobsub.sh file and all files required to run your sim in a dir called files
# jobsub.sh contents at end of file

# define nodes to test 
#   all other defining is taken from the jobsub.sh file

nodes=(1 2 3 4 5 6 7 8 9 10 11 12)
time_in=15 # time requested in minutes, 
time_min="0.25" # time maxh in decimal

for ii in ${nodes[*]}
do
    mkdir $ii
    cd $ii
    cp -r ../files/* .
    sed -i "s/nodes_var/$ii/g" jobsub.sh
    let cores=($ii * 24)
    sed -i "s/cores_var/$cores/g" jobsub.sh
    sed -i "s/time_var/$time_in/g" jobsub.sh
    sed -i "s/time_vim/$time_min/g" jobsub.sh
    cd ..
done

# submit 
echo '############ Listing files ###############'
for ii in ${nodes[*]}; do echo $ii; ls $ii; done
echo "Would you like to submit? (yes / no)"
read answer
if [[ $answer = "no" ]] || [[ $answer = "n" ]] ; then exit 0; fi

for ii in ${nodes[*]}
do
    cd $ii
    sbatch jobsub.sh
    cd ..
done

jobsubsh ()
{
#!/bin/bash -l
#SBATCH --account=INSERT_YOUR_GROUP_HERE
#SBATCH --job-name=Coacervate_bench
#SBATCH --partition=workq 
#SBATCH --time=00:time_var:00
#SBATCH --nodes=nodes_var
#SBATCH --export=ALL
#======START=====
module load slurm
echo "The current job ID is $SLURM_JOB_ID"
echo "Running on $SLURM_JOB_NUM_NODES nodes"
echo "Using $SLURM_NTASKS_PER_NODE tasks per node"
echo "A total of $SLURM_NTASKS tasks is used"
echo "Node list:"
sacct --format=JobID,NodeList%100 -j $SLURM_JOB_ID
module swap PrgEnv-cray PrgEnv-gnu
module load gromacs/2018.3
srun --export=all -N nodes_var -n cores_var mdrun_mpi -s OLysRNA_min_eq_prod.tpr -c coacervate_prod0.gro -v -g log.log -x traj_comp.xtc -maxh time_vim
}

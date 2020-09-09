#!/bin/bash/

# minimisation.sh
# this file requires one of each: gro, ndx, top file in this dir: one and only one
# steep and cg mdps and jobsub.sh are incuded as strings in this document; to see originals go to greifm github publicrepos/min_backups
# USAGE
# change variables in this script, run this script, run the jobsub.sh script
# when run this program will create a jobsub.sh script which:
#   1. grompp with the steep and cg files created in minimisation.sh
#   2. submit jobs, change variables, and make checks
#   2.  1. submit a steep and then a cg of nsteps and the first emstep in list
#   2.  2. check the program
#           did not crash immediately ifso it will stop
#           took too little time (ie system is running for few steps) ifso the next emstep will be used
#           the log file has "Finished mdrun" in the last line ifnot it will stop (currently disabled)

# create files
echo -e 'integrator = cg\nnsteps = nstep_var\nemtol = emtol_var\nemstep = emstep_var\n\npbc = xyz\nrlist = 1.0\nnstlist = 1\n\ncoulombtype = PME\nrcoulomb = 1.0\nvdwtype = cut-off\nrvdw = 1.0\n\nnstxout = 100\nnstvout = 100\nnstfout = 100\nnstlog = 1\nnstenergy = 1\n\n' > min_cg
echo -e '; minim.mdp - used as input into grompp to generate em.tpr\n; Parameters describing what to do, when to stop and what to save\nintegrator = steep ; Algorithm (steep = steepest descent minimization)\nemtol = emtol_var.0 ; Stop minimization when the maximum force < 25.0 kJ/mol/nm\nemstep = emstep_var ; Energy step size\nnsteps = nstep_var ; Maximum number of (minimization) steps to perform\n\n; Parameters describing how to find the neighbors of each atom and how to calculate the interactions\nnstlist = 1 ; Frequency to update the neighbor list and long range forces\nns_type = grid ; Method to determine neighbor list (simple, grid)\nrlist = 1.2 ; Cut-off for making neighbor list (short range forces)\ncoulombtype = PME ; Treatment of long range electrostatic interactions\nrcoulomb = 1.2 ; Short-range electrostatic cut-off\nrvdw = 1.2 ; Short-range Van der Waals cut-off\npbc = xyz ; Periodic Boundary Conditions\n\n' > min_sd
echo -e '#!/bin/bash -l\n#SBATCH --account=pawsey0110\n#SBATCH --job-name=minimisation\n#SBATCH --partition=job_var\n#SBATCH --time=time24_var\n#SBATCH --nodes=nodes_var\n#SBATCH --export=ALL\n#======START=====\nmodule load slurm\necho "The current job ID is $SLURM_JOB_ID"\necho "Running on $SLURM_JOB_NUM_NODES nodes"\necho "Using $SLURM_NTASKS_PER_NODE tasks per node"\necho "A total of $SLURM_NTASKS tasks is used"\necho "Node list:"\nsacct --format=JobID,NodeList%100 -j $SLURM_JOB_ID\nmodule swap PrgEnv-cray PrgEnv-gnu\nmodule load gromacs/gromacs_var\n\n# insert run\nemstep_range=(emstep_range_var)\ncount=0\nnstep_var=nstep_var_var\nemtol_var=emtol_var_var\nmintime=mintime_var\ncrashtime=1\ndebug=debug.log\necho "emsteps ${emstep_range[*]} nstep $nstep_var mintime $mintime crashtime $crashtime Beginloop" > $debug\n\nloopn=0\nleavenow=false\nwhile [[ $leavenow == false ]] ;\ndo\nemstep_var=${emstep_range[$count]}\n# make and edit mdps\ncp min_sd min_sd.mdp\nsed -i "s/nstep_var/$nstep_var/g" min_sd.mdp\nsed -i "s/emstep_var/$emstep_var/g" min_sd.mdp\nsed -i "s/emtol_var/$emtol_var/g" min_sd.mdp\ncp min_cg min_cg.mdp\nsed -i "s/nstep_var/$nstep_var/g" min_cg.mdp\nsed -i "s/emstep_var/$emstep_var/g" min_cg.mdp\nsed -i "s/emtol_var/$emtol_var/g" min_sd.mdp\n\necho "loop $loopn emstep $emstep_var" >> $debug\nfor ii in min_sd min_cg\ndo\ntimethen=$(date +%s)\n\ngmx grompp -f ${ii}.mdp -c gro_var -n index_var -p top_var -o out.tpr\nsrun --mpi=pmi2 -N nodes_var -n cores_var mdrun_mpi_d -s out.tpr -c gro_var -v -g log.log\n\ntimenow=$(date +%s); let "timecheck = timenow - timethen"\necho "$ii nsteps $nstep_var timecheck $timecheck" >> $debug\nif [[ $timecheck -lt $mintime ]] && [[ $ii == min_sd ]]; then\n# check its not crashing quickly\necho "minetime triggered" >> $debug\nif [[ $timecheck -lt $crashtime ]] ; then\nleavenow=true # exit if it seems it didnt run at all\necho "crashtime triggered leave=true= $leavenow" >> $debug\nfi\n# assume its not just crashing\nlet "count = count + 1" # use next emstep in range as it is not running for long\necho "countchanged $count" >> $debug\nif [[ ${#emstep_range[@]} == $count ]] ; then # as count indexs at zero\nlet "count = count - 1"\nleavenow=true # exit if we are at max emstep range\necho "count triggered ${#emstep_range[@]} , $count" >> $debug\nfi\nfi\n\n#if [[ "$(tail -n 1 log.log)" != *"Finished mdrun"* ]]; then leavenow=true; fi # end loop if run did not finish\n# triggers on any failure, cg is expected to fail when steep runs full or has not min enough\necho "beginlog" >> $debug; tail -n 16 log.log >> $debug; echo "endlog" >> $debug\nmv log.log log$(date +%s).log # cleanup\ndone\nlet loopn+=1\nlet " nstep_var = nstep_var + nstep_var_var " # extend nsteps, otherwise it will think its done\n# triggers at end of cg, therefore if steep runs full cg will not\n\ndone\n' > jobsub.sh

# edit jobsub
job_var=debugq
time24_var="00:30:00"
nodes_var=2
gromacs_var="2018.3"
let "cores_var = $nodes_var * 24"

sed -i "s/job_var/$job_var/g" jobsub.sh
sed -i "s/time24_var/$time24_var/g" jobsub.sh
sed -i "s/nodes_var/$nodes_var/g" jobsub.sh
sed -i "s/cores_var/$cores_var/g" jobsub.sh
sed -i "s/gromacs_var/$gromacs_var/g" jobsub.sh

# insert run
emstep_range_var="0.002 0.001 0.0005 0.0001"
nstep_var=50000
emtol_var=28
mintime_var=60
gro_var=*gro
index_var=*ndx
top_var=*top

sed -i "s/nstep_var_var/$nstep_var/g" jobsub.sh
sed -i "s/emstep_range_var/$emstep_range_var/g" jobsub.sh
sed -i "s/emtol_var_var/$emtol_var/g" jobsub.sh
sed -i "s/mintime_var/$mintime_var/g" jobsub.sh
sed -i "s/gro_var/$gro_var/g" jobsub.sh
sed -i "s/index_var/$index_var/g" jobsub.sh
sed -i "s/top_var/$top_var/g" jobsub.sh

#!/bin/bash

# creates system using list of structural inputs
# still need to solvate
# if run multiple times coacervate.top will be output and the files will have changed.
# requites listofstuct, coacervate.top, RNA_en_min1.mdp, solvate.gro
# run on gromacs 2018.1

listofstruct=("RNA_extended_nwi.gro" "RNA_extended_nwi.gro" "file1.pdb" "file1.pdb" "file1.pdb" "file1.pdb" "file1.pdb" "file1.pdb" "file1.pdb" "file1.pdb" "file1.pdb" "file1.pdb" "file1.pdb" "file1.pdb" "file1.pdb" "file1.pdb" "file1.pdb" "file10.pdb" "file16.pdb" "file43.pdb" "file76.pdb" "file84.pdb" "file89.pdb" "file97.pdb" "file163.pdb" "file184.pdb" "file214.pdb" "file275.pdb" "file286.pdb" "file321.pdb" "file68.pdb" "file118.pdb")
out=0
filein=0
sizeofbox="5.2"

for ii in ${listofstruct[*]}
do
    if [ $out = 0 ]; then 
        gmx editconf -f $ii -bt dodecahedron -c -d $sizeofbox -o out_${out}.gro
        let out+=1
    else
        gmx insert-molecules -f out_${filein}.gro -try 5000 -ci $ii -nmol 1 -o out_${out}.gro 
        let out+=1; let filein+=1
    fi
done


read nothing
gmx solvate -cp out_${filein}.gro -p coacervate.top -cs -o solvate.gro
read nothing
gmx grompp -f RNA_en_min1.mdp -c solvate.gro -p coacervate.top -pp topol.top -o test.tpr -maxwarn 10
read nothing
echo 19 | gmx genion -s test.tpr -p topol.top -np 58 -nn 480 -nname CL -pname MG -o OLysRNA_sol_ion.gro

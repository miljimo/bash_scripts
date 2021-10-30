#!/bin/bash

for counter in 1 2 3 4 5 6 7 8 9
 do
   echo $counter;
done

echo List Files 

files=$(ls -a $HOME)


for file in $file*
  do 
   echo $file
done

echo HOME BASE SCRIPTS

for file in $HOME/.bash*
    do
    echo $file
done

echo  PRINT LS ONE

for file in $(ls -a $HOME)
  do
   echo $file >> files.txt
   
done


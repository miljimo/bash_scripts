#!/bin/bash

numbers="1 2 3 4 5 6 7 8 9 10"

for number in $numbers
  do
   what=`expr $number % 2`
   if [ $what -eq 0 ]
     then
      echo "$number Is Even"
   fi
done

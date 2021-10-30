#!/bin/bash

source display.sh

source returnvalue.sh

#call display function
display 

#call the add function
result=$( add 10 50);
status=$?
if [ $status -eq 0 ] 
  then

   echo "SUM=$result"
fi

display

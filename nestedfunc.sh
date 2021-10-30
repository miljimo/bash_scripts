#!/bin/bash

recursive(){
  echo "Recursive $1"
  if [ $1 -le 1 ] 
    then
      return 0
  fi
  recursive  $(($1 - 1))
}

counter=$(($1 * 1))

if [ $counter -ge 1 ]
  then
   recursive $counter
else
  echo "expecting 1 parameter"
fi




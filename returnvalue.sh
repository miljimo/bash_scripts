#!/bin/bash


function get_region()  a=$1
  b=$2
  c=`expr $a + $b`
  echo $c
  return 0
}

param1=$(($1 * 1))
param2=$(($2 * 1))

sum=$(add $param1  $param2 )
echo "The sum is $1 and $2 = $sum"

echo $(( $sum * 2))


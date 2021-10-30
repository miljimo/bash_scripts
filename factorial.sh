#!/bin/bash



function factorial(){
  if [ $1 -le 1 ] 
    then
     return 1
  fi
  
  factorial $(($1 - 1))
  ret=$? 
  return $(($1 * $ret))
}

factorial $(($1 * 1));

echo "Factorial of $1  is = $?"


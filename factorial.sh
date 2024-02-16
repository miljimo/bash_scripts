#!/bin/bash



function factorial(){
  local n=$(($1 * 1))
  if [ $n -le 1 ]; then
     echo 1
     return ;
  fi
  local result=$(factorial $(($n - 1)))
  echo $(($result * $n))
}


result=$(factorial $(($1 * 1)))
echo "Fact($(($1 * 1))) = $result"

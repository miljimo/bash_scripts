#!/bin/bash

display(){
   echo $(wc -c wc.txt)
   return 10 
}

result=$(display)
ret=$?

echo "The result is $result, display() = $ret"

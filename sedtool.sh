#!/bin/bash
SUCCESS=1
ERROR=0
ERROR_MSG=""

#******************************************************
#
#
#******************************************************
function split_string(){
 local nargs="$#"
 if (($nargs < 3)) ; then
    ERROR_MSG="expecting two parameters but $nargs provided."
 	return $ERROR
 fi
 local value="$1"
 local delimiter="$2"
 local -n larray="${3}"
 local counter=1
  
 if [ ! -z "$value" ]; then 	
 	value=$(echo "$value" | tr "$delimiter" '\n') 	
	while read -r line
		do
	  		larray[$counter]=$line
	  		counter=$(($counter + 1))
		done <<< "$value"
 fi
 return $SUCCESS
}

#***************************************************
#*	@brief
#*	  The function is used to replace bash variables
#*	  in a given files.
#*  @param filename the file to edit and replace its variables
#*  @param the new values in "KEY=VALUE"
#***************************************************
function replace_bash_variables_infile(){
	local nargs="$#"
	if (($nargs < 0)); then
	  ERROR_MSG="$(echo "@replace_bash_variables: number of parameter provided did not match")"
	  return  $ERROR
	fi
	local filename="$1"
	local value="$2"
	
	#check if the file exist
	
	if [ ! -e "$filename" ] || [ -z "$filename" ]
	 then
	   ERROR_MSG="$(echo "@replace_bash_variables: filename '$filename' does not exist")"
	   return  $ERROR
	fi
	
	if [ -z "$value" ] ; then
		ERROR_MSG="$(echo "@replace_bash_variables: replace pair value '$value' is empty")"
	  	return  $ERROR
	fi
	
	#process the the files
	while read -r line 
		do
		    if [ -z $line ]; then
		    	continue;
		    fi
		    echo "$line" | sed -i "s/^$line" '$value'
			
		done < "$filename"
		
	return $SUCCESS
}

FILENAME="./bin/script.sh"		
VALUES="PATH=~/bin"


replace_bash_variables_infile   "$FILENAME" "$VALUES"
status="$?"

if (( $status  <= 0 )) 
	then
  		echo "replace_bash_variables_infile  failed: $ERROR_MSG, status= $status "
fi

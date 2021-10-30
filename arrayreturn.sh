#!/bin/bash


# Get PORD_SCRIPT
# GET AUT_SCRIPT
# SIZE_OF
REGION="uat aut.sh,prod.sh^r1.sh\n"
ERROR_STATUS=0
SUCCESS_STATUS=1


#*********************************
# Check if a file exists or not.#
#********************************
function file_exist(){
 args="$#" 
 # check if parameter is provided or not
 if (( $args < 1 ))
 	then
 	return "${ERROR_STATUS}"
 fi
 local filename="$1"
 # check if the file exists
 
 if [ -e "$filename" ] 
 	then
 	return "${SUCCESS_STATUS}"
 fi
 return "${ERROR_STATUS}"
}




#****************************************
#	@brief
#	  the function will get the basename of the file 
#	@param filename
#	@author Obaro I. Johnson
#****************************************
function get_bash_file_basename(){
 local filename="$1" 
 # check if the filename is set or not
 if [ ! -z "$filename" ]
    then
    # trim out the extension .sh from the from of string
   	filename="${filename%%.sh}"
   	# trim out other rest of the parts until the last '/'
   	filename="${filename##*/}"
   	echo "$filename"
   	return "${SUCCESS_STATUS}"
 fi
 return "${ERROR_STATUS}"
}

#***********************************
# @brief
# The function take two parameters filename and the an associate array for out.
# @param filename takes the path to the region_map_file
# @param arr an associate array for output
# @return 0 if the function failed otherwise 1# 
#************************************
function parse_region_map_from_file(){
	nParams="$#"
	if (( $nParams < 2 )) 
	   then
	      echo "@error: expecting 2 parameter , but $nParams provided"
	      return "${ERROR_STATUS}" && exit
	fi
	
    local filename="$1"
    declare -n region_scripts=$2
	
	#check if the file exists or not
	file_exist "$filename"
	local status=$?
	if (($status == $SUCCESS_STATUS))
	  then	  
	    # file exist , read and parse it
	    # read file data 
	    # we want leading space to be trim , therefore remove IFS=
	    while  read -r line
	      do
	        if [ ! -z "$line" ]
	            then	            
	             #split into two array
	             arr=(`echo $line | sed 's/ /\n/g'`)
	             region="${arr[0]}"
	             scripts="${arr[1]}"
	             region_scripts["$region"]="$scripts"	             
	        fi
	      done < "$filename"
	    return "${SUCCESS_STATUS}"
	else
	  	return "${ERROR_STATUS}"
	fi
}

#Function check if the is presented.
function does_region_exist(){
 local -n regions0="$1"
 local    region="$2"
 
 for key in "${!regions0[@]}"
   do
    if [ "$key" == "$region" ]
      then
        return "${SUCCESS_STATUS}"
    fi
 done
 return "${ERROR_STATUS}"
}


function parse_region_scripts(){
  local nargs="$#"
  if ((nargs <= 1)) 
     then
     return "${ERROR_STATUS}"
  fi
  
  local scripts="$1" 
  local index=0   
  declare -n local_scripts_array="$2"
  
  if [ ! -z $scripts ]
    then
      scripts=$(echo $scripts | tr "^" ",")   
     
	  while read -d ',' part 
		do
		 local_scripts_array["$index"]="$part"
		 index=$(($index + 1))				
	  done <<< "$scripts"
	  if [ ! -z "$part" ]
	    then
	  		local_scripts_array["$index"]="$part"	  		
	  fi    
  fi
  return "${SUCCESS_STATUS}"	 
}

REGION='usa'


function build_region_scripts(){
	declare -A regions;
	filename="./releaseconfig/regions.map"
	parse_region_map_from_file "$filename" regions
	status=$?
	if (($status == $SUCCESS_STATUS))
	  then
	   does_region_exist regions "$REGION"
	   status=$?
	   
	   if (($status == $SUCCESS_STATUS))
		  then
		   scripts="${regions[$REGION]}"
		   #create an output script_array that contains the prod, and the uat scripts in order of inputs
		   declare -a scripts_array
		   parse_region_scripts "$scripts"  scripts_array 
		  for script in "${scripts_array[@]}"    
		    do
		    	# check if the files exists or not
		    	# build aut scripts 
		    	if [ "$script" == *"prod"* ]
		    	    then
		     			echo "Process Production $script"
		     	else
		     	        echo "Process aut $script"
		     	fi
		  done
		   
	   fi
	fi
}


build_region_scripts






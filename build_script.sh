#!/bin/bash


# Get PORD_SCRIPT
# GET AUT_SCRIPT
# SIZE_OF
REGION="usa"
ERROR_STATUS=0
SUCCESS_STATUS=1
UAT_SCRIPT_DIR=""
PRODUCT_SCRIPT_DIR=""


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

function build_region_script(){
  nargs="$#"
  if (( nargs < 1 ))
    then
     return "${ERROR_STATUS}"
  fi
  filename="$1"
  local failed="${ERROR_STATUS}"
  
  if [ -e "$filename" ] 
  	then
  		# build the script with the current steps as usual.
  		echo "$filename"
  else
  		echo "$filename does not exist"  
  		failed="${SUCCESS_STATUS}"		
  fi
  
  if (($failed == $SUCCESS_STATUS)) 
  	then
  		return "${ERROR_STATUS}"
  fi
  return "${SUCCESS_STATUS}"
}


function build_region_scripts(){
    nargs=$#
    if (( nargs < 2))
      then
       return "${ERROR_STATUS}"
    fi
    
    local filename="$1"  
    local regionname="$2"
	declare -A regions;	
	
	parse_region_map_from_file "$filename" regions
	status=$?
	if (($status == $SUCCESS_STATUS))
	  then
	   does_region_exist regions "$regionname"
	   status=$?
	   
		if (($status == $SUCCESS_STATUS))
		 	then
		   	scripts="${regions[$regionname]}"
		   	#create an output script_array that contains the prod, and the uat scripts in order of inputs
		   	declare -a scripts_array
		   	parse_region_scripts "$scripts"  scripts_array 
		   	for script in "${scripts_array[@]}"    
		    	do
		    		# check if the files exists or not
		    		# build aut scripts 
		    		if [[ "$script" == *"prod"* ]]
		    	    	then
		    	    		path="$PRODUCT_SCRIPT_DIR/$script"
		    	    		build_region_script "$path"		     				
		     		else
		     	        	path="$UAT_SCRIPT_DIR/$script"
		     	        	build_region_script "$path"
		     		fi
		  	done		   
	   fi
	fi
}

#*******************************************************
# Author Obaro I. Johnson
# Load regions from the region file
# format of region line
#	region aut_file,...^prod_file,...
# @return it return a strings of region lines seperated with space 
# region1=autfile,...^prod_file,... region2=autfile,...^prod_file,...
#*******************************************************
function load_regions_from_file(){
 local nargs="$#"
 if(($nargs < 1)); then
 	return "$ERROR_STATUS"
 fi
 
 local filename="$1"
 file_exist $filename
 status=$?
 if(($status < 1)); then
 	return $status
 fi
 local -a region_lines
 local index=0;
 
 while read -r line 
 	do
 		if [ -z "$line" ] ; then
 			continue
 		fi
 		line=$(echo "$line" | tr ' ' '=')
 		region_lines["$index"]="$line";
 		index=$(($index + 1)) 		
 	done < "$filename"
 results=$( echo "${region_lines[@]}")
 results=${results##'\n'}
 results=${results%%'\n'}
 echo $results
 return $SUCCESS_STATUS
}

function does_region_exist(){
 nargs=$#
 if((nargs < 2)); then
 	return $ERROR_STATUS
 fi
 
 local  region="$1"
 local  regions=($(echo "$2"))
 
 for line in ${regions[@]}
   do
   	lines=($(echo $line | tr '=' ' '))
    reg="${lines[0]}"
    if [[ $reg == $region ]]; then
    	return $SUCCESS_STATUS
    fi
 done
 return "${ERROR_STATUS}"
}

filename="./releaseconfig/regions.map"
#build_region_scripts "${filename}" "$REGION"
regions=$(load_regions_from_file $filename)
#can=ir.sh,ir2.sh^ir_prod.sh,ir2_prod.sh

does_region_exist 'usa' "$regions"
status=$?
if(($status <= 0)); then
  echo "Failed" && exit 1
fi
echo "Passed"


filename="./releaseconfig/regions.map"
build_region_scripts "${filename}" "$REGION"






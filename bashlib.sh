#!/bin/bash
#
# Shell Script Lib - Just a simple library of handy shell script functions
#
# https://github.com/lowerpower 
#
#
# Handy Shell Notes
#
#${var#*SubStr}  # will drop begin of string upto first occur of `SubStr`
#${var##*SubStr} # will drop begin of string upto last occur of `SubStr`
#${var%SubStr*}  # will drop part of string from last occur of `SubStr` to the end
#${var%%SubStr*} # will drop part of string from first occur of `SubStr` to the end

#
# extract a key value from a file ($1=file $2=key, $3=optional character delimiter (default space))
#
# key must start on first character of line.
#
# key value -or-
# key=value supported
#
# Return 0 for found value, return 1 for no value found
#
# call with:  value=$(extract_key_value "filename" "key")
#
extract_key_value()
{
    local value
    local delimiter=' '
    local ret=1

    # set the delimiter 
    if [ -z "$3" ]; then
        delimiter=' '
    else
        delimiter=$3
    fi

    # search for the last key in the file and extract the value
    #value=$(grep "^$2$delimiter" "$1" | tail -n 1 | awk '{print $2}')
    value=$(grep "^${2}${delimiter}" "$1" | tail -n 1 )
    value=${value##*"${2}${delimiter}"}

    # set the return code depending on if we extracted a value
    if [ -z "$value" ]; then
        ret=0
    else
        ret=1
    fi

    echo -n $value

    return $ret
}

#
# test if a variable is a number or not, note that "12345 xx" is not a number
#
# Return 1 for is a number
#
# call with:  isNumber $var
#
# return in $?
#
isNumber()
{
    if expr "$@" : '-*[0-9][0-9]*$'>/dev/null; then
        return 1
    else
        return 0
    fi
}

#
#produces a unix timestamp in second from epoc, useful for timing operations
#
# usage : time=$(utime)
#
utime()
{ 
    echo $(date +%s)
}

#
# Produce a sortable timestamp that is year/month/day/timeofday usful for writing files, logs
# and other date that might want to be sortable by date.
#
# usage :   timestamp=$(timestamp)
#
timestamp()
{
    echo $(date +%Y%m%d%H%M%S)
}


#
# Simple Long Random
#
srand()
{
    echo "$RANDOM$RANDOM" 
}

#
# dev_random() - produces a crypto secure random number string ($1 digits) to the output (supports upto 50 digits for now)
#
# ret=dev_random(10)
#
dev_random()                                                                                                                        
{                                                                                                                                  
    local count=$1                                                                                                                 
    if [ "$count" -lt 1 ] || [ "$count" -ge 50 ]; then                           
        count=50;                                                                  
    fi                                                                             
    ret=$(cat /dev/urandom | tr -cd '0-9' | dd bs=$count count= 2>/dev/null)
    echo -n "$ret"                                 
} 

#
# xmlval() - very simple XML parse,: get the value from key $2 in buffer $1, this is simple no nesting allowed
#
xmlval()
{
   temp=`echo $1 | awk '!/<.*>/' RS="<"$2">|</"$2">"`
   echo ${temp##*|}
}

#                                                                                                                                  
# JSON parse (very simplistic):  get value frome key $2 in buffer $1,  values or keys must not have the characters {}[", 
#   and the key must not have : in it
#
#  Example:
#   value=$(jsonval "$json_buffer" "$key") 
#                                                   
jsonval()                                              
{
    temp=`echo "$1" | sed -e 's/[{}\"]//g' | sed -e 's/,/\'$'\n''/g' | grep -w $2 | cut -d":" -f2-`
    #echo ${temp##*|}         
    echo ${temp}                                                
}                                                   

#
# JSON parse
#
jsonvalx()
{
    temp=`echo $1 | sed -e 's/[{}"]//g' -e "s/,/\\$liblf/g" | grep -w $2 | cut -d":" -f2-`
    #echo ${temp##*|}
    echo ${temp}    
}

#
# for the JSON.sh project wrapper equiv to jsonval()
# https://github.com/dominictarr/JSON.sh
#
jsonval-sh()
{
   local temp
   local search_for

   search_for="\\[\"$2\"\]"

   temp=$( echo "$1" | ./JSON.sh -b | grep "$search_for" )

   temp=${temp##*$search_for}

   temp="${temp%\"*}"
   temp="${temp#*\"}"
   echo ${temp}

}

#                                                                                                
# rem_spaces $1  - replace space with underscore (_)                                                  
#
spaces2underscore()                                                                  
{
    echo "$@" | sed -e 's/ /_/g'                                                         
}      

#                                                                                                
# rem_spaces $1  - replace space with pipe (|)                                                  
#
spaces2pipe()                                                                  
{
    echo "$@" | sed -e 's/ /|/g'                                                         
}   

#                                                                                                
# rem_spaces $1  - replace | with space ( )                                                  
#
pipe2space()                                                                  
{
    echo "$@" | sed -e 's/|/ /g'                                                         
}                
                                               
#                   
# urlencode $1
#                                      
urlencode()                                                                           
{
#STR="$1"
STR="$@"          
[ "${STR}x" == "x" ] && { STR="$(cat -)"; }
                     
echo ${STR} | sed -e 's| |%20|g' \
-e 's|!|%21|g' \
-e 's|#|%23|g' \
-e 's|\$|%24|g' \
-e 's|%|%25|g' \
-e 's|&|%26|g' \
-e "s|'|%27|g" \
-e 's|(|%28|g' \
-e 's|)|%29|g' \
-e 's|*|%2A|g' \
-e 's|+|%2B|g' \
-e 's|,|%2C|g' \
-e 's|/|%2F|g' \
-e 's|:|%3A|g' \
-e 's|;|%3B|g' \
-e 's|=|%3D|g' \
-e 's|?|%3F|g' \
-e 's|@|%40|g' \
-e 's|\[|%5B|g' \
-e 's|]|%5D|g'

}    

#
# ireplace_with_newline() - replaces string with a newline or other value if specified
#
# examples:  
#   out_string=$(replace_with_newline "$in_string" "$replace_string" ) 
#          -or-
#   out_string=$(replace_with_newline "$in_string" "$replace_string" "$replace_with") 
#
function replace_with_newline()
{
    # check if replace_with is set
    if [ -z ${3+x} ]; 
    then
        # not set use newline
        replace_tmp='\n'
    else
        # set use replace_with
        replace_tmp="$3"
    fi
    
    # do the replacement
    tout=$(echo $1 | sed "s/$2/$replace_tmp/g" ) 

    
    # echo our new string with enhanced interpretation turned on and IFS deactivated
    # we need to replace IFS with something not newline, here we use null
    old_IFS=$IFS
    IFS=''
    echo -e ${tout}
    IFS=${old_IFS}
}




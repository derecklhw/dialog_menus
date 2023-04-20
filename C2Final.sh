#!/bin/bash

# create a unique temp file to store CPU options selected by user
CPUTMP=$(mktemp /tmp/cpu.sh.XXXXX)

# trap and delete temp files
# trap is used to catch any signals to avoid the script to exit immediately without deleting the temp files.
trap "rm -f $CPUTMP; exit" SIGHUP SIGINT SIGTERM EXIT


# Purpose - to display output using msgbox
function display_result() {
 	dialog --clear \
 	--backtitle "CST1500 Coursework" \
 	--title "$1" \
 	--no-collapse \
 	--msgbox "$result" 0 0
}


function showCpu () {

	# Respective $choice variables to store each command outputing different CPU informations
	choice1=$( cat /proc/cpuinfo | grep 'vendor' | uniq )
	choice2=$( cat /proc/cpuinfo | grep 'model name' | uniq )
	choice3=$( cat /proc/cpuinfo | grep processor | wc -l )
	choice4=$( cat /proc/cpuinfo | grep 'core id' )
	choice5=$( cat /proc/cpuinfo )
 	
 	# --separate-output will output result one line at a time, with no quoting
 	# no tags will dialog matches against the first character of the description instead of tags
	dialog --stdout \
	--separate-output  \
	--no-tags \
	--clear \
	--nocancel \
	--backtitle "Computer CPU Information" \
	--title "CPU Information Menu" \
    	--checklist "Use SPACE to select/deselect options and OK [ENTER] when finished."  \
    	30 100 30 \
    	"$choice1" "View Vendor Name" off \
    	"$choice2" "Display Model Name" off \
	"$choice3" "Count the number of processing units" off \
   	"$choice4" "Show individual cores" off \
      	"$choice5" "Show all CPU informations" off \
	>"${CPUTMP}"  # stderr msg from checklist redirected as stdout to $CPUTMP variable to be store in cpu.sh
 
	result=$(<"${CPUTMP}") # redirect content of CPUTEMP file to $result variable
	
	display_result "Computer CPU Information" # display_result function with argument for title
}   
    
# set infinite loop
while true
do     


# stderr msg from menu redirected as stdout to be store in $selection variable
selection=$(dialog --clear \
	--nocancel \
	--stdout \
    	--backtitle "CST1500 Coursework" \
    	--title "System Information Menu" \
    	--menu "You can use the UP/DOWN arrow keys,\
	or the number keys 1-6 to choose an option.\n\
	Choose the TASK" 0 0 7 \
    	"1" "Display your Operating system type" \
    	"2" "Display Computer cpu information" \
    	"3" "Display Memory information" \
    	"4" "Display Hard disk information" \
    	"5" "Display File system - Mounted" \
    	"6" "Return to Main Menu")

# make menu decision
# using case statement to simplify complex conditionals when you have multiple different choices.
case $selection in 
	1 )
		result=$(hostnamectl)
      		display_result "Operating system type"
		;;
	
	2 )
		showCpu
		;;
		
	3 )
		result=$(free)
      		display_result "Memory information"
		;;
		
	4 )	#sudo apt install inxi
		result=$(inxi -D)  
		display_result "Hard disk information"
		;;
		
	5 )	result=$(lsblk)
	   	display_result "File system - Mounted"
		;;
	
	6 ) 
		break
		;;
esac

done




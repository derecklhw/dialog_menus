#!/bin/bash
# A sample shell script to display menus on screen

# create a unique temp file to store menu options selected by user
INPUT=$(mktemp /tmp/menu.sh.XXXXX)

# create a unique temp file to store the content of any menu output options for display
OUTPUT=$(mktemp /tmp/output.sh.XXXXX)

# create a temporary folder to store the date temporary files for calendar

mkdir /tmp/Calendar

# trap and delete temp files
# trap is used to catch any signals to avoid the script to exit immediately without deleting the temp files.
# SIGHUP -Hang up detected on controlling terminal or death of controlling process
# SIGINT - Issued if the user sends an interrupt signal (Ctrl + C)
# SIGTERM - Software termination signal (sent by kill by default)

trap "rm -f $OUTPUT; rm -f $INPUT; rm -r /tmp/Calendar; exit" SIGHUP SIGINT SIGTERM EXIT

# Purpose - to display output using msgbox 
#  $1 -> set msgbox height
#  $2 -> set msgbox width
#  $3 -> set msgbox title

function display_output () {
	local h=${1-10}	# box height default 10
	local w=${2-41} 	# box width default 41
	local t=${3-Output} 	# box title 
	
	# dialog msgbox to display any content from $OUTPUT temp file
	dialog --clear \
		--backtitle "CST1500 Coursework" \
		--title "${t}"\
		--msgbox "$(<$OUTPUT)" ${h} ${w}
}

# Purpose - to display current system time and date
function show_date () {
	echo "Today is $(date)" >$OUTPUT
	display_output 6 60 "Date and Time"
}

# Purpose - to set calendar date
function show_calendar () {
	
	# dialog menu to display different options before displaying the calendar
	dialog --clear --backtitle "CST1500 Coursework" \
	--title "Calender" \
	--menu "Choose options" 10 50 2 \
	"Current Calendar" "Display current month" \
	"Set Calendar" "Set the date to be displayed" 2>"${INPUT}" # stderr msg from menu redirected as stdout to INPUT variable to be store in menu.sh temporary file
	
	calendaritem=$(<"${INPUT}") # redirect content of INPUT  file to calendaritem variable
	
	# case statement to execute the two option command from above menu	
	case $calendaritem in 
		"Current Calendar")
			# output the dialog calendar and store the date selected before exit command to variable reminder
			reminder=$(dialog --clear --nocancel --stdout --backtitle "CST1500 Coursework" --title "Calendar" --calendar "Select a date" 0 0)
			reminder_menu # reminder_menu function
			;;
		
		"Set Calendar")
			# dialog form to displays data entry form which consisting of day, month and year.
			dialog --clear \
			--nocancel \
			--backtitle "CST1500 Coursework" \
			--title "Set Calendar" \
			--form "Set your calendar using this format DD.MM.YYYY : " 10 60 3 \
			"Day:" 1 1 "$day" 1 30 10 0 \
			"Month:" 2 1 "$month" 2 30 10 0  \
			"Year:" 3 1 "$year" 3 30 10 0 2>"${OUTPUT}" # stderr msg from menu redirected as stdout to OUTPUT variable to be store in output.sh temporary file
		
		mapfile -t array <"${OUTPUT}" # Strip newlines and store item using -t in an array named "array"
		
		reminder=$(dialog --clear \
		--nocancel \
		--stdout \
		--backtitle "CST1500 Coursework" \
		--title "Calendar" \
		--calendar 'Select a date'  0 0 \
		"${array[0]}" "${array[1]}" "${array[2]}") # dialog calendar using the day, month and year stored in above array
		
		reminder_menu # reminder_menu function

	esac	
}

# Purpose - to display the different reminder menu options
function reminder_menu () {
	local reminder=${reminder////.}  # Use inline shell string replacement to replace all / by .
	
	touch /tmp/Calendar/$reminder # touch command: It is used to create a file without any content named the date selected.
		
	if ! grep -q '[^[:space:]]' "/tmp/Calendar/$reminder"; # to find if there is any whitespace in the file
	then	#if there is whitespace, file is empty
		
		# dialog yesno for user to confirm if he want to create a reminder or no
		dialog  --clear \
		--backtitle "Calendar" \
		--title "Reminder Confirmation" \
		--yesno "Please confirm if you want to create a reminder" 5 60
		
		local confirmation=$? # holds the exit status of the dialog yesno of reminder confirmation
		
		if [ $confirmation == 0 ] # if yes selected
		then
			
			# dialog inputbox to input the reminder to be created
			dialog --clear \
			--nocancel \
			--backtitle "Calendar" \
			--title "Reminder Creation" \
			--inputbox "Write your reminder" 15 50 2>/tmp/Calendar/$reminder # output to the respective date file
			
			echo "Reminder has been created" >$OUTPUT
			display_output 5 50 "Reminder Creation" # display_output function
			
		else	#if no selected
		
			# dialog msgbox to display that reminder was cancelled
			dialog --clear \
			--backtitle "Calendar" \
			--title "Reminder Creation" \
			--msgbox "Reminder Creation has been cancelled" 5 50
		
		fi
	else # no whitespace found, file is not empty ,a reminder dialog menu will be executed
		
		# dialog menu to display different tasks to execute if there is already a reminder in the temp file
		decision=$(dialog --clear \
				--stdout \
				--backtitle "Calendar" \
				--title "Reminder Menu" \
				--menu "You can use the UP/DOWN arrow keys, the first \n\
				letter of the choice as a hot key, or the \n\
				number keys 1-4 to choose an option.\n\
				Choose the TASK" 15 50 4 \
				"Add reminder" "To add a reminder on selected date" \
				"View reminder" "To view any reminder on selected date" \
				Delete "To delete all reminder" \
				Cancel "To cancel operation")
		
		# case statement to execute the different option command from decision menu	
		case $decision in 
			"Add reminder")
				dialog --clear \
				--backtitle "Calendar" \
				--title "Add a reminder" \
				--inputbox "Input any new reminder to be added" 0 0 2>>/tmp/Calendar/$reminder #add output to respective date file
				
				echo "Reminder has been added" >$OUTPUT
				display_output 5 50 "Reminder Creation"
				
				;;
	
			"View reminder")
				dialog --clear \
				--backtitle "Calendar" \
				--title "View reminder" \
				--textbox "/tmp/Calendar/$reminder" 0 0 # textbox is a simple text file viewer
				;;
			
			Delete)
				dialog  --clear \
				--backtitle "Calendar" \
				--title "Reminder Delete Confirmation" \
				--yesno "Please confirm to delete all reminder" 0 0
				
				local confirmation=$? # holds the exit status of the dialog yesno of the reminder delete confirmation
				
				if [ $confirmation == 0 ] # if yes selected
				then
					
					# delete the selected date file and output a dialog msgbox
					rm /tmp/Calendar/$reminder && \
					dialog --clear \
					--backtitle "Calendar" \
					--title "Delete Reminder" \
					--msgbox "All reminder has been deleted" 0 0
					
				else # if no selected
					# ouput a dialog msgbox for cancel delete
					dialog --clear \
					--backtitle "Calendar" \
					--title "Cancel delete" \
					--msgbox "Reminder delete operation cancelled" 0 0
				fi
				;;
		esac				
	fi
}

# Purpose - select file to be deleted
function delete_selection () {
	
	local DIRECTORY=$(dialog --clear \
			--nocancel \
			--stdout \
			--backtitle "CST1500 Coursework" \
			--title "Delete File" \
			--inputbox "Enter a directory" 0 0) # stderr from input box will be store in $DIRECTORY variable
	
	# std err from fselect i.e file directory will be store to $FILE variable
	FILE=$(dialog --clear \
	--nocancel \
	--stdout \
	--backtitle "Delete File" \
	--title "Please choose a file to delete" \
	--fselect $DIRECTORY/ 14 48)
	
	delete_file "$FILE"  # delete_file function follow by argument FILE variable 
}

# Purpose - delete file checker and output message
function delete_file () {
	# $1 - filename from FILE variable argument when executing the delete_selection function 
	local f="$1" 
	
	if [ -f $f ] # True if file exists and is a regular file.
	then
		dialog  --clear \
		--backtitle "Delete File" \
		--title "Delete File Confirmation" \
		--yesno "Please confirm to delete $f" 0 0
		
		confirmation=$? # holds the exit status of the dialog yesno of the delete file confirmation
		
		if [ $confirmation == 0 ] # if yes
		then
			rm $FILE && m=" $f file deleted." # rm will delete the file
		else	# if no
			m="Delete cancelled"
		fi
	else
		m="$f is not a file."
	fi 
	
	dialog --clear \
	--backtitle "CST1500 Coursework" \
	--title "Delete File" \
	--msgbox "$m" 0 0 # $m variable will store a string about different outcome msg
}

# set infinite loop
while true
do

### display main menu
dialog --clear \
--nocancel \
--backtitle "CST1500 Coursework" \
--title "[ M A I N - M E N U ]" \
--menu "You can use the UP/DOWN arrow keys, the first \n\
letter of the choice as a hot key, or the \n\
number keys 1-4 to choose an option.\n\
Choose the TASK" 15 50 5 \
Time/Date "To see current time and date" \
Calendar "To show Calendar and Reminder" \
Delete "To delete selected file" \
"System Info" "To show System Config Info" \
Exit "To Exit this shell script" 2>"${INPUT}" # stderr msg from menu redirected as stdout to $INPUT variable to be store in menu.sh temporary file

menuitem=$(<"${INPUT}") # redirect content of INPUT  file to $menuitem variable

# make menu decision
# using case statement to simplify complex conditionals when you have multiple different choices.
case $menuitem in
	Time/Date) 
		show_date
	;;
	Calendar) 
		show_calendar
	;;
	Delete) 
		delete_selection
	;;
	"System Info")
		chmod u+x C2.sh # made the file executable for your user
		source C2.sh # call another bash script file with the source command 
	;;
	Exit)
		echo "Bye Bye From The Long Lakshit and Small Dereck" >$OUTPUT
		display_output 6 60 "Thank You"
		break
	;;
esac

done
clear

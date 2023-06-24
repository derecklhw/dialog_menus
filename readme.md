# Dialog Menus

This repository contains two bash scripts: `main.sh` and `system_info.sh`. These scripts provide various functionalities and system information.

## `main.sh`

The `main.sh` script displays menus on the screen and allows the user to perform different tasks. It makes use of the `dialog` command to create interactive menus and dialog boxes. Here are the main functionalities of the script:

### Displaying Current Time and Date

The script provides an option to display the current system time and date.

### Calendar and Reminder

The script includes a calendar feature that allows the user to view and manage reminders for specific dates. The user can select a date from the calendar and perform tasks such as adding reminders, viewing existing reminders, or deleting reminders.

### Deleting Files

The script provides an option to delete selected files. The user can choose a directory and then select a file to delete.

### System Information

The script includes an option to display system configuration information. It executes another bash script named system_info.sh to retrieve and display CPU information.

### Exiting the Script

The user can choose to exit the script, which will display a farewell message.

Please note that the script uses temporary files for storing menu options and output. These files are automatically created and deleted during script execution.

## `system_info.sh`

The `system_info.sh` script is invoked by main.sh to retrieve and display CPU information. It uses the `/proc/cpuinfo` file to gather data such as vendor name, model name, number of processing units, individual core information, and overall CPU information. The script presents a menu with checkboxes to allow the user to select the desired information.

## Requirements

To run these scripts, you need a Linux environment with Bash and the `dialog` command installed. These scripts were developed and tested on Ubuntu 22.10.

## Running the Scripts

To run the main.sh script, execute the following command in the terminal:

```bash
bash main.sh
```

This will start the script, and you can navigate through the menus using the arrow keys or by typing the corresponding number key.

The `system_info.sh` script is automatically made in an executable by main.sh when selecting the "System Info" option.

To run the `system_info.sh` script directly, execute the following command in the terminal:

```bash
./system_info.sh
```

#! /bin/bash
#
#
# ------------------------------------------------------------------------------------
#
# MIT License
# 
# Copyright (c) 2017 Enterprise Group, Ltd.
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# ------------------------------------------------------------------------------------
# 
# File: aws-services-tagable-resources.sh
#
script_version=1.0.12   
#
#  Dependencies:
#  - bash shell
#  - AWS CLI tools (pre-installed on AWS AMIs) 
#  - AWS CLI profile with IAM permissions for the following AWS CLI commands:
#    - aws ec2 describe-regions
#    - aws resourcegroupstaggingapi get-resources
#    - aws sts get-caller-identity
#    - aws iam list-account-aliases
#
# Tested on: 
#   Windows Subsystem for Linux (WSL) 
#     OS Build: 15063.540
#     bash.exe version: 10.0.15063.0
#     Ubuntu 16.04
#     GNU bash, version 4.3.48(1)
#     aws-cli/1.11.134 Python/2.7.12 Linux/4.4.0-43-Microsoft botocore/1.6.1
#   
#   AWS EC2
#     Amazon Linux AMI release 2017.03 
#     Linux 4.9.43-17.38.amzn1.x86_64 
#     GNU bash, version 4.2.46(2)
#     aws-cli/1.11.133 Python/2.7.12 Linux/4.9.43-17.38.amzn1.x86_64 botocore/1.6.0
#
#
# By: Douglas Hackney
#     https://github.com/dhackney   
# 
# Type: AWS utility
# Description: 
#   This shell script creates a report of all tagable resources in all regions 
#
# Sources: 
#   * main data loop
#         The following code was provided by AWS support, which inspired this project:
#     
#           regionlist=$(aws ec2 describe-regions --output text $cliprofile | cut -f4)
#           for region in `aws ec2 describe-regions --output text | cut -f4`
#           do
#               aws resourcegroupstaggingapi get-resources --region $region $cliprofile
#           done
#
# Roadmap:
# - driver file listing AWS CLI profiles to automate multiple accounts reporting
# 
#
###############################################################################
# 
# set the environmental variables 
#
set -o pipefail 
#
###############################################################################
# 
#
# initialize the script variables
#
aws_region_list=""
aws_tagable_resources_region=""
aws_tagable_resources_region_raw=""
choices=""
cli_profile=""
cli_profile_available=""
count_aws_region_list=0
count_cli_profile=0
count_error_lines=0
count_script_version_length=0
count_subtotals_by_service_region=0
count_tagable_resources=0
count_tagable_resources_region=0
count_tags=0
count_text_header_length=0
count_text_block_length=0
count_text_width_menu=0
count_text_width_header=0
count_text_side_length_menu=0
count_text_side_length_header=0
count_text_bar_menu=0
count_text_bar_header=0
count_this_file_tasks=0
counter_aws_region_list=0
counter_this_file_tasks=0
_empty=""
_empty_task=""
_empty_task_sub=""
error_line_aws=""
error_line_pipeline=""
feed_write_log=""
feed_write_log=""
file_date=""
_fill=""
_fill_task=""
_fill_task_sub=""
full_path=""
let_done=""
let_done_task=""
let_done_task_sub=""
let_left=""
let_left_task=""
let_left_task_sub=""
let_progress=""
let_progress_task=""
let_progress_task_sub=""
logging=""
now_date=""
parameter1=""
paramter2=""
regionlist=""
text_bar_menu_build=""
text_bar_header_build=""
text_side_menu=""
text_side_header=""
text_menu=""
text_menu_bar=""
text_header=""
text_header_bar=""
this_aws_account=""
this_aws_account_alias=""
this_detail_report=""
this_detail_report_full_path=""
this_file=""
this_log=""
thislogdate=""
this_log_file=""
this_log_file_errors=""
this_log_file_errors_full_path=""
this_log_file_full_path=""
this_log_temp_file_full_path=""
this_output_file=""
this_output_file_full_path=""
this_path=""
this_summary_report=""
this_summary_report_full_path=""
this_user=""
this_utility_acronym=""
this_utility_filename_plug=""
verbose=""
write_path=""
#
###############################################################################
# 
#
# initialize the baseline variables
#
this_utility_acronym="gtr"
this_utility_filename_plug="tagable-resources"
this_path="$(pwd)"
this_file="$(basename "$0")"
full_path="${this_path}"/"$this_file"
this_log_temp_file_full_path="$this_path"/"$this_utility_filename_plug"-log-temp.log 
this_user="$(whoami)"
file_date="$(date +"%Y-%m-%d-%H%M%S")"
count_this_file_tasks="$(cat "$full_path" | grep -c "\-\-\- begin\: " )"
counter_this_file_tasks=0
logging="n"
#
###############################################################################
# 
# initialize the temp log file
#
echo "" > "$this_log_temp_file_full_path"
#
#
##############################################################################################################33
#                           Function definition begin
##############################################################################################################33
#
#
# Functions definitions
#
#######################################################################
#
#
#
#######################################################################
#
#
# function to display the usage  
#
#
function fnUsage()
{
    echo ""
    echo " ----------------------------------- AWS Services Tagable Resources utility usage ------------------------------------"
    echo ""
    echo " This utility gets all tagable resources for all AWS Services in an AWS account  "  
    echo ""
    echo " This script will: "
	echo "  * Capture all AWS Services' tagable resources for an AWS account "
	echo "  * Write the results to a text file "
	echo "  * Generate a summary report "
	echo "  * Generate a detail report "	
    echo ""
	echo " >> Note: The AWS CLI profile determines the AWS account to pull the tagable resources from <<  "
    echo ""
    echo "----------------------------------------------------------------------------------------------------------------------"
    echo ""
    echo " Usage:"
    echo "        aws-services-tagable-resources.sh -p AWS_CLI_profile "
    echo ""
    echo "        Optional parameters: -b y -g y "
    echo ""
    echo " Where: "
    echo "  -p - Name of the AWS CLI cli_profile (i.e. what you would pass to the --profile parameter in an AWS CLI command)"
    echo "         Example: -p myAWSCLIprofile "
    echo ""    
    echo "  -b - Verbose console output. Set to 'y' for verbose console output. Note: this mode is very slow."
    echo "         Example: -b y "
    echo ""
    echo "  -g - Logging on / off. Default is off. Set to 'y' to create a debug log. Note: logging mode is slower. "
    echo "         Example: -g y "
    echo ""
    echo "  -h - Display this message"
    echo "         Example: -h "
    echo ""
    echo "  ---version - Display the script version"
    echo "         Example: --version "
    echo ""
    echo ""
    exit 1
}
#
#######################################################################
#
#
# function to echo the progress bar to the console  
#
# source: https://stackoverflow.com/questions/238073/how-to-add-a-progress-bar-to-a-shell-script
#
# 1. Create ProgressBar function
# 1.1 Input is currentState($1) and totalState($2)
function fnProgressBar() 
{
# Process data
        let _progress=(${1}*100/"${2}"*100)/100
        let _done=(${_progress}*4)/10
        let _left=40-"$_done"
# Build progressbar string lengths
        _fill="$(printf "%${_done}s")"
        _empty="$(printf "%${_left}s")"
#
# 1.2 Build progressbar strings and print the ProgressBar line
# 1.2.1 Output example:
# 1.2.1.1  Progress : [########################################] 100%
printf "\r          Overall Progress : [${_fill// /#}${_empty// /-}] ${_progress}%%"
}
#
#######################################################################
#
#
# function to update the task progress bar   
#
# source: https://stackoverflow.com/questions/238073/how-to-add-a-progress-bar-to-a-shell-script
#
# 1. Create ProgressBar function
# 1.1 Input is currentState($1) and totalState($2)
function fnProgressBarTask() 
{
# Process data
        let _progress_task=(${1}*100/"${2}"*100)/100
        let _done_task=(${_progress_task}*4)/10
        let _left_task=40-"$_done_task"
# Build progressbar string lengths
        _fill_task="$(printf "%${_done_task}s")"
        _empty_task="$(printf "%${_left_task}s")"
#
# 1.2 Build progressbar strings and print the ProgressBar line
# 1.2.1 Output example:
# 1.2.1.1  Progress : [########################################] 100%
printf "\r             Task Progress : [${_fill_task// /#}${_empty_task// /-}] ${_progress_task}%%"
}
#
#######################################################################
#
#
# function to update the subtask progress bar   
#
# source: https://stackoverflow.com/questions/238073/how-to-add-a-progress-bar-to-a-shell-script
#
# 1. Create ProgressBar function
# 1.1 Input is currentState($1) and totalState($2)
function fnProgressBarTaskSub() 
{
# Process data
        let _progress_task_sub=(${1}*100/"${2}"*100)/100
        let _done_task_sub=(${_progress_task_sub}*4)/10
        let _left_task_sub=40-"$_done_task_sub"
# Build progressbar string lengths
        _fill_task_sub="$(printf "%${_done_task_sub}s")"
        _empty_task_sub="$(printf "%${_left_task_sub}s")"
#
# 1.2 Build progressbar strings and print the ProgressBar line
# 1.2.1 Output example:
# 1.2.1.1  Progress : [########################################] 100%
printf "\r         Sub-Task Progress : [${_fill_task_sub// /#}${_empty_task_sub// /-}] ${_progress_task_sub}%%"
}
#
#######################################################################
#
#
# function to display the task progress bar on the console  
#
# parameter 1 = counter
# paramter 2 = count
# 
function fnProgressBarTaskDisplay() 
{
    fnWriteLog ${LINENO} level_0 " ---------------------------------------------------------------------------------"
    fnWriteLog ${LINENO} level_0 "" 
    fnProgressBarTask "$1" "$2"
    fnWriteLog ${LINENO} level_0 "" 
    fnWriteLog ${LINENO} level_0 "" 
    fnWriteLog ${LINENO} level_0 " ---------------------------------------------------------------------------------"
    fnWriteLog ${LINENO} level_0 ""
}
#
#######################################################################
#
#
# function to display the task progress bar on the console  
#
# parameter 1 = counter
# paramter 2 = count
# 
function fnProgressBarTaskSubDisplay() 
{
    fnWriteLog ${LINENO} level_0 " ---------------------------------------------------------------------------------"
    fnWriteLog ${LINENO} level_0 "" 
    fnProgressBarTaskSub "$1" "$2"
    fnWriteLog ${LINENO} level_0 "" 
    fnWriteLog ${LINENO} level_0 "" 
    fnWriteLog ${LINENO} level_0 " ---------------------------------------------------------------------------------"
    fnWriteLog ${LINENO} level_0 ""
}
#
#######################################################################
#
#
# function to echo the header to the console  
#
function fnHeader()
{
    clear
    fnWriteLog ${LINENO} level_0 "" 
    fnWriteLog ${LINENO} "--------------------------------------------------------------------------------------------------------------------"    
    fnWriteLog ${LINENO} "--------------------------------------------------------------------------------------------------------------------" 
    fnWriteLog ${LINENO} level_0 ""
    fnWriteLog ${LINENO} level_0 "$text_header"    
    fnWriteLog ${LINENO} level_0 "" 
    fnProgressBar ${counter_this_file_tasks} ${count_this_file_tasks}
    fnWriteLog ${LINENO} level_0 "" 
    fnWriteLog ${LINENO} level_0 "" 
    fnWriteLog ${LINENO} level_0 "$text_header_bar"
    fnWriteLog ${LINENO} level_0 ""
}
#
#######################################################################
#
#
# function to echo to the console and write to the log file 
#
function fnWriteLog()
{
    # clear IFS parser
    IFS=
    # write the output to the console
    fnOutputConsole "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9"
    # if logging is enabled, then write to the log
    if [[ ("$logging" = "y") || ("$logging" = "z") ]] ;
        then
            # write the output to the log
            fnOutputLog "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9"
    fi 
    # reset IFS parser to default values 
    unset IFS
}
#
#######################################################################
#
#
# function to echo to the console  
#
function fnOutputConsole()
{
    #
    # console output section
    #
    # test for verbose
    if [ "$verbose" = "y" ] ;  
        then
            # if verbose console output then
            # echo everything to the console
            #
            # strip the leading 'level_0'
                if [ "$2" = "level_0" ] ;
                    then
                        # if the line is tagged for display in non-verbose mode
                        # then echo the line to the console without the leading 'level_0'     
                        echo " Line: "$1" "$3" "$4" "$5" "$6" "$7" "$8" "$9""
                    else
                        # if a normal line echo all to the console
                        echo " Line: "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9""
                fi
    else
        # test for minimum console output
        if [ "$2" = "level_0" ] ;
            then
                # echo ""
                # echo "console output no -v: the logic test for level_0 was true"
                # echo ""
                # if the line is tagged for display in non-verbose mode
                # then echo the line to the console without the leading 'level_0'     
                echo " "$3" "$4" "$5" "$6" "$7" "$8" "$9""
        fi
    fi
    #
    #

}  

#
#######################################################################
#
#
# function to write to the log file 
#
function fnOutputLog()
{
    # log output section
    #
    # load the timestamp
    thislogdate="$(date +"%Y-%m-%d-%H:%M:%S")"
    #
    # ----------------------------------------------------------
    #
    # normal logging
    # 
    # append the line to the log variable
    # the variable is written to the log file on exit by function fnWriteLogFile
    #
    # if the script is crashing then comment out this section and enable the
    # section below "use this logging for debug"
    #
        if [ "$2" = "level_0" ] ;
            then
                # if the line is tagged for logging in non-verbose mode
                # then write the line to the log without the leading 'level_0'     
                this_log+="$(echo "${thislogdate} Line: "$1" "$3" "$4" "$5" "$6" "$7" "$8" "$9"" 2>&1)" 
            else
                # if a normal line write the entire set to the log
                this_log+="$(echo "${thislogdate} Line: "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9"" 2>&1)" 
        fi
        #
        # append the new line  
        # do not quote this variable
        this_log+=$'\n'
        #
    #  
    # ---------------------------------------------------------
    #
    # 'use this for debugging' - debug logging
    #
    # if the script is crashing then enable this logging section and 
    # comment out the prior logging into the 'this_log' variable
    #
    # note that this form of logging is VERY slow
    # 
    # write to the log file with a prefix timestamp 
    # echo "${thislogdate} Line: "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9"" 2>&1 >> "$this_log_file_full_path"  
    #
    #
}
#
#######################################################################
#
#
# function to append the log variable to the temp log file 
#
function fnWriteLogTempFile()
{
    fnWriteLog ${LINENO} ""
    fnWriteLog ${LINENO} "Appending the log variable 'this_log' to the temp log file 'this_log_temp_file_full_path' "
    fnWriteLog ${LINENO} "" 
    fnWriteLog ${LINENO} "value of variable 'this_log_temp_file_full_path':"
    fnWriteLog ${LINENO} " "$this_log_temp_file_full_path "  "   
    fnWriteLog ${LINENO} ""
    echo "$this_log" >> "$this_log_temp_file_full_path"
    # empty the temp log variable
    this_log=""
}
#
#######################################################################
#
#
# function to write log variable to the log file 
#
function fnWriteLogFile()
{
    # append the temp log file onto the log file
    fnWriteLog ${LINENO} level_0 ""
    fnWriteLog ${LINENO} "Writing temp log to log file"
    fnWriteLog ${LINENO} "Value of variable 'this_log_temp_file_full_path': "
    fnWriteLog ${LINENO} "$this_log_temp_file_full_path"
    fnWriteLog ${LINENO} ""
    fnWriteLog ${LINENO} "Value of variable 'this_log_file_full_path': "
    fnWriteLog ${LINENO} "$this_log_file_full_path"
    fnWriteLog ${LINENO} level_0 ""   
    # write the contents of the variable to the temp log file
    fnWriteLogTempFile
    cat "$this_log_temp_file_full_path" >> "$this_log_file_full_path"
    echo "" >> "$this_log_file_full_path"
    echo "Log end" >> "$this_log_file_full_path"
    # delete the temp log file
    rm -f "$this_log_temp_file_full_path"
}
#
##########################################################################
#
#
# function to delete the work files 
#
function fnDeleteWorkFiles()
{
    fnWriteLog ${LINENO} level_0 ""
    fnWriteLog ${LINENO} level_0 ""
    fnWriteLog ${LINENO} ""
    fnWriteLog ${LINENO} "in delete work files "
    fnWriteLog ${LINENO} "value of variable 'verbose': "$verbose" "
    fnWriteLog ${LINENO} ""
        if [ "$verbose" != "y" ] ;  
            then
                # if not verbose console output then delete the work files
                fnWriteLog ${LINENO} ""
                fnWriteLog ${LINENO} "In non-verbose mode: Deleting work files"
                fnWriteLog ${LINENO} ""
                feed_write_log="$(rm -f ./"$this_utility_acronym"-* 2>&1)"
                fnWriteLog ${LINENO} "$feed_write_log"
                feed_write_log="$(rm -f ./"$this_utility_acronym"_* 2>&1)"
                fnWriteLog ${LINENO} "$feed_write_log"
                fnWriteLog ${LINENO} ""
                fnWriteLog ${LINENO} "value of variable 'this_log_file_full_path' "$this_log_file_full_path" "
                fnWriteLog ${LINENO} "$feed_write_log"
                #
                # if no errors, then delete the error log file
                count_error_lines="$(cat "$this_log_file_errors_full_path" | wc -l)"
                if (( "$count_error_lines" < 3 ))
                    then
                        rm -f "$this_log_file_errors_full_path"
                fi  
            else
                # in verbose mode so preserve the work files 
                fnWriteLog ${LINENO} level_0 ""
                fnWriteLog ${LINENO} level_0 "In verbose mode: Preserving work files "
                fnWriteLog ${LINENO} level_0 ""
                fnWriteLog ${LINENO} level_0 "work files are here: "$this_path" "
                fnWriteLog ${LINENO} level_0 ""                
        fi       
}
#
##########################################################################
#
#
# function to log non-fatal errors 
#
function fnErrorLog()
{
    fnWriteLog ${LINENO} level_0 "-----------------------------------------------------------------------------------------------------"       
    fnWriteLog ${LINENO} level_0 ""
    fnWriteLog ${LINENO} level_0 " Error message: "
    fnWriteLog ${LINENO} level_0 " "$feed_write_log""
    fnWriteLog ${LINENO} level_0 ""
    fnWriteLog ${LINENO} level_0 "-----------------------------------------------------------------------------------------------------" 
    echo "-----------------------------------------------------------------------------------------------------" >> "$this_log_file_errors_full_path"         
    echo "" >> "$this_log_file_errors_full_path" 
    echo " Error message: " >> "$this_log_file_errors_full_path" 
    echo " "$feed_write_log"" >> "$this_log_file_errors_full_path" 
    echo "" >> "$this_log_file_errors_full_path"
    echo "-----------------------------------------------------------------------------------------------------" >> "$this_log_file_errors_full_path" 
}
#
##########################################################################
#
#
# function to handle command or pipeline errors 
#
function fnErrorPipeline()
{
            fnWriteLog ${LINENO} level_0 "-----------------------------------------------------------------------------------------------------"       
            fnWriteLog ${LINENO} level_0 ""
            fnWriteLog ${LINENO} level_0 " Command or Command Pipeline Error "
            fnWriteLog ${LINENO} level_0 ""
            fnWriteLog ${LINENO} level_0 "-----------------------------------------------------------------------------------------------------"
            fnWriteLog ${LINENO} level_0 ""
            fnWriteLog ${LINENO} level_0 " System Error while running the previous command or pipeline "
            fnWriteLog ${LINENO} level_0 ""
            fnWriteLog ${LINENO} level_0 " Please check the error message above "
            fnWriteLog ${LINENO} level_0 ""
            fnWriteLog ${LINENO} level_0 " Error at script line number: "$error_line_pipeline" "
            fnWriteLog ${LINENO} level_0 ""
            if [[ "$logging" == "y" ]] ;
                then 
                    fnWriteLog ${LINENO} level_0 " The log will also show the error message and other environment, variable and diagnostic information "
                    fnWriteLog ${LINENO} level_0 ""
                    fnWriteLog ${LINENO} level_0 " The log is located here: "
                    fnWriteLog ${LINENO} level_0 " "$this_log_file_full_path" "
            fi
            fnWriteLog ${LINENO} level_0 ""        
            fnWriteLog ${LINENO} level_0 " Exiting the script"
            fnWriteLog ${LINENO} level_0 ""
            fnWriteLog ${LINENO} level_0 "-----------------------------------------------------------------------------------------------------"
            fnWriteLog ${LINENO} level_0 ""
            # append the temp log onto the log file
            fnWriteLogTempFile
            # write the log variable to the log file
            fnWriteLogFile
            exit 1
}
#
##########################################################################
#
#
# function for AWS CLI errors 
#
function fnErrorAws()
{
    fnWriteLog ${LINENO} level_0 ""
    fnWriteLog ${LINENO} level_0 " AWS Error while executing AWS CLI command"
    fnWriteLog ${LINENO} level_0 ""
    fnWriteLog ${LINENO} level_0 " Please check the AWS error message above "
    fnWriteLog ${LINENO} level_0 ""
    fnWriteLog ${LINENO} level_0 " Error at script line number: "$error_line_aws" "
    fnWriteLog ${LINENO} level_0 ""
    fnWriteLog ${LINENO} level_0 " The log will also show the AWS error message and other diagnostic information "
    fnWriteLog ${LINENO} level_0 ""
    fnWriteLog ${LINENO} level_0 " The log is located here: "
    fnWriteLog ${LINENO} level_0 " "$this_log_file_full_path" "
    fnWriteLog ${LINENO} level_0 ""        
    fnWriteLog ${LINENO} level_0 " Exiting the script"
    fnWriteLog ${LINENO} level_0 ""
    fnWriteLog ${LINENO} level_0 "--------------------------------------------------------------------------------------------------"
    fnWriteLog ${LINENO} level_0 ""
    # append the temp log onto the log file
    fnWriteLogTempFile
    # write the log variable to the log file
    fnWriteLogFile
    exit 1
}
#
##########################################################################
#
#
# function for jq errors 
#
function fnErrorJq()
{
    fnWriteLog ${LINENO} level_0 ""
    fnWriteLog ${LINENO} level_0 " Error at script line number: "$error_line_jq" "
    fnWriteLog ${LINENO} level_0 ""
    fnWriteLog ${LINENO} level_0 " There was a jq error while processing JSON "
    fnWriteLog ${LINENO} level_0 ""
    fnWriteLog ${LINENO} level_0 " Please check the jq error message above "
    fnWriteLog ${LINENO} level_0 ""
    fnWriteLog ${LINENO} level_0 " The log will also show the jq error message and other diagnostic information "
    fnWriteLog ${LINENO} level_0 ""
    fnWriteLog ${LINENO} level_0 " The log is located here: "
    fnWriteLog ${LINENO} level_0 " "$this_log_file_full_path" "
    fnWriteLog ${LINENO} level_0 ""        
    fnWriteLog ${LINENO} level_0 " Exiting the script"
    fnWriteLog ${LINENO} level_0 ""
    fnWriteLog ${LINENO} level_0 "--------------------------------------------------------------------------------------------------"
    fnWriteLog ${LINENO} level_0 ""
    # append the temp log onto the log file
    fnWriteLogTempFile
    # write the log variable to the log file
    fnWriteLogFile
    exit 1
}
#
##########################################################################
#
#
# function to increment the region counter 
#
function fnCounterIncrementRegions()
{
    #
    fnWriteLog ${LINENO} ""
    fnWriteLog ${LINENO} "increment the regions counter: 'counter_aws_region_list'"
    counter_aws_region_list="$((counter_aws_region_list+1))"
    fnWriteLog ${LINENO} "post-increment value of variable 'counter_aws_region_list': "$counter_aws_region_list" "
    fnWriteLog ${LINENO} "value of variable 'count_aws_region_list': "$count_aws_region_list" "
    fnWriteLog ${LINENO} ""
    #
}
#
##########################################################################
#
#
# function to increment the task counter 
#
function fnCounterIncrementTask()
{
    fnWriteLog ${LINENO} ""  
    fnWriteLog ${LINENO} "increment the task counter"
    counter_this_file_tasks="$((counter_this_file_tasks+1))" 
    fnWriteLog ${LINENO} "value of variable 'counter_this_file_tasks': "$counter_this_file_tasks" "
    fnWriteLog ${LINENO} "value of variable 'count_this_file_tasks': "$count_this_file_tasks" "
    fnWriteLog ${LINENO} ""
}
#
#
##############################################################################################################33
#                           Function definition end
##############################################################################################################33
#
# 
###########################################################################################################################
#
#
# enable logging to capture initial segments
#
logging="z"
# 
###########################################################################################################################
#
#
# build the menu and header text line and bars 
#
text_header='AWS Tagable Resources Utility v'
count_script_version_length=${#script_version}
count_text_header_length=${#text_header}
count_text_block_length=$(( count_script_version_length + count_text_header_length ))
count_text_width_menu=104
count_text_width_header=83
count_text_side_length_menu=$(( (count_text_width_menu - count_text_block_length) / 2 ))
count_text_side_length_header=$(( (count_text_width_header - count_text_block_length) / 2 ))
count_text_bar_menu=$(( (count_text_side_length_menu * 2) + count_text_block_length + 2 ))
count_text_bar_header=$(( (count_text_side_length_header * 2) + count_text_block_length + 2 ))
# source and explanation for the following use of printf is here: https://stackoverflow.com/questions/5799303/print-a-character-repeatedly-in-bash
text_bar_menu_build="$(printf '%0.s-' $(seq 1 "$count_text_bar_menu")  )"
text_bar_header_build="$(printf '%0.s-' $(seq 1 "$count_text_bar_header")  )"
text_side_menu="$(printf '%0.s-' $(seq 1 "$count_text_side_length_menu")  )"
text_side_header="$(printf '%0.s-' $(seq 1 "$count_text_side_length_header")  )"
text_menu="$(echo "$text_side_menu"" ""$text_header""$script_version"" ""$text_side_menu")"
text_menu_bar="$(echo "$text_bar_menu_build")"
text_header="$(echo " ""$text_side_header"" ""$text_header""$script_version"" ""$text_side_header")"
text_header_bar="$(echo " ""$text_bar_header_build")"
# 
###########################################################################################################################
#
#
# display initializing message
#
clear
fnWriteLog ${LINENO} level_0 ""
fnWriteLog ${LINENO} level_0 "$text_header"
fnWriteLog ${LINENO} level_0 ""
fnWriteLog ${LINENO} level_0 " This utility gets all tagable resources and writes them to a text file  "
fnWriteLog ${LINENO} level_0 ""
fnWriteLog ${LINENO} level_0 " This script will: "
fnWriteLog ${LINENO} level_0 " - Capture all AWS Services' tagable resources for an AWS account "
fnWriteLog ${LINENO} level_0 " - Write the results to a text file "
fnWriteLog ${LINENO} level_0 " - Generate a summary report  "
fnWriteLog ${LINENO} level_0 " - Generate a detail report "
fnWriteLog ${LINENO} level_0 ""
fnWriteLog ${LINENO} level_0 "$text_header_bar"
fnWriteLog ${LINENO} level_0 ""
fnWriteLog ${LINENO} level_0 "                            Please wait  "
fnWriteLog ${LINENO} level_0 ""
fnWriteLog ${LINENO} level_0 "  Checking the input parameters and initializing the app " 
fnWriteLog ${LINENO} level_0 ""
fnWriteLog ${LINENO} level_0 "  Depending on connection speed and AWS API response, this can take " 
fnWriteLog ${LINENO} level_0 "  from a few seconds to a few minutes "
fnWriteLog ${LINENO} level_0 ""
fnWriteLog ${LINENO} level_0 "  Status messages and opening menu will appear below"
fnWriteLog ${LINENO} level_0 ""
fnWriteLog ${LINENO} level_0 "$text_header_bar"
fnWriteLog ${LINENO} level_0 ""
fnWriteLog ${LINENO} level_0 ""
# 
#
###################################################
#
#
# check command line parameters 
# check for -h
#
if [[ "$1" = "-h" ]] ; then
    clear
    fnUsage
fi
#
###################################################
#
#
# check command line parameters 
# check for --version
#
if [[ "$1" = "--version" ]] 
    then
        clear
        echo ""
        echo "'AWS Services Tagable Resources utility ' script version: "$script_version" "
        echo ""
        exit 
fi
#
###################################################
#
#
# check command line parameters 
# if less than 2, then display the Usage
#
if [[ "$#" -lt 2 ]] ; then
    clear
    fnWriteLog ${LINENO} level_0 ""
    fnWriteLog ${LINENO} level_0 "-------------------------------------------------------------------------------"
    fnWriteLog ${LINENO} level_0 ""
    fnWriteLog ${LINENO} level_0 "  ERROR: You did not enter all of the required parameters " 
    fnWriteLog ${LINENO} level_0 ""
    fnWriteLog ${LINENO} level_0 "  You must provide a profile name for the profile parameter: -p  "
    fnWriteLog ${LINENO} level_0 ""
    fnWriteLog ${LINENO} level_0 "  Example: "$0" -p MyProfileName  "
    fnWriteLog ${LINENO} level_0 ""
    fnWriteLog ${LINENO} level_0 "-------------------------------------------------------------------------------"
    fnWriteLog ${LINENO} level_0 ""
    fnUsage
fi
#
###################################################
#
#
# check command line parameters 
# if too many parameters, then display the error message and useage
#
if [[ "$#" -gt 6 ]] ; then
    clear
    fnWriteLog ${LINENO} level_0 ""
    fnWriteLog ${LINENO} level_0 "-------------------------------------------------------------------------------"
    fnWriteLog ${LINENO} level_0 ""
    fnWriteLog ${LINENO} level_0 "  ERROR: You entered too many parameters" 
    fnWriteLog ${LINENO} level_0 ""
    fnWriteLog ${LINENO} level_0 "  You must provide only one value for all parameters: -p -b -g  "
    fnWriteLog ${LINENO} level_0 ""
    fnWriteLog ${LINENO} level_0 "  Example: "$0" -p MyProfileName -b y -g y"
    fnWriteLog ${LINENO} level_0 ""
    fnWriteLog ${LINENO} level_0 "-------------------------------------------------------------------------------"
    fnWriteLog ${LINENO} level_0 ""
    fnUsage
fi
#
###################################################
#
#
# parameter values 
#
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} "value of variable '@': "$@" "
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} "value of parameter '1' "$1" "
fnWriteLog ${LINENO} "value of parameter '2' "$2" "
fnWriteLog ${LINENO} "value of parameter '3' "$3" "
fnWriteLog ${LINENO} "value of parameter '4' "$4" "
fnWriteLog ${LINENO} "value of parameter '5' "$5" "
fnWriteLog ${LINENO} "value of parameter '6' "$6" "
#
###################################################
#
#
# load the main loop variables from the command line parameters 
#
while getopts "p:b:g:h" opt; 
    do
        #
        fnWriteLog ${LINENO} ""
        fnWriteLog ${LINENO} "value of variable '@': "$@" "
        fnWriteLog ${LINENO} "value of variable 'opt': "$opt" "
        fnWriteLog ${LINENO} "value of variable 'OPTIND': "$OPTIND" "
        fnWriteLog ${LINENO} ""   
        #     
        case "$opt" in
        p)
            cli_profile="$OPTARG"
            fnWriteLog ${LINENO} ""
            fnWriteLog ${LINENO} "value of -p 'cli_profile': "$cli_profile" "
        ;;
        b)
            verbose="$OPTARG"
            fnWriteLog ${LINENO} ""
            fnWriteLog ${LINENO} "value of -b 'verbose': "$verbose" "
        ;;  
        g)
            logging="$OPTARG"
            fnWriteLog ${LINENO} ""
            fnWriteLog ${LINENO} "value of -g 'logging': "$logging" "
        ;;  
        h)
            fnUsage
        ;;   
        \?)
            clear
            fnWriteLog ${LINENO} level_0 ""
            fnWriteLog ${LINENO} level_0 "---------------------------------------------------------------------"
            fnWriteLog ${LINENO} level_0 ""
            fnWriteLog ${LINENO} level_0 "  ERROR: You entered an invalid parameter." 
            fnWriteLog ${LINENO} level_0 ""
            fnWriteLog ${LINENO} level_0 "  Parameter entries: -"$@""
            fnWriteLog ${LINENO} level_0 ""
            fnWriteLog ${LINENO} level_0 ""
            fnWriteLog ${LINENO} level_0 "---------------------------------------------------------------------"
            fnWriteLog ${LINENO} level_0 ""
            fnUsage
        ;;
    esac
done
#
###################################################
#
#
# check logging variable 
#
#
###################################################
#
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} "value of variable '@': "$@" "
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} "value of variable 'logging': "$logging" "
fnWriteLog ${LINENO} ""
#
###################################################
#
#
# disable logging if not set by the -g parameter 
#
fnWriteLog ${LINENO} "if logging not enabled by parameter, then disabling logging "
if [[ "$logging" != "y" ]] ;
    then
        logging="n"
fi
#
# parameter values 
#
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} "value of variable 'cli_profile' "$cli_profile" "
fnWriteLog ${LINENO} "value of variable 'verbose' "$verbose" "
fnWriteLog ${LINENO} "value of variable 'logging' "$logging" "
#
###################################################
#
#
# check command line parameters 
# check for valid AWS CLI profile 
#
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} "count the available AWS CLI profiles that match the -p parameter profile name "
count_cli_profile="$(cat /home/"$this_user"/.aws/config | grep -c "$cli_profile")"
# if no match, then display the error message and the available AWS CLI profiles 
if [[ "$count_cli_profile" -ne 1 ]]
    then
        clear
        fnWriteLog ${LINENO} level_0 ""
        fnWriteLog ${LINENO} level_0 "--------------------------------------------------------------------------"
        fnWriteLog ${LINENO} level_0 ""
        fnWriteLog ${LINENO} level_0 "  ERROR: You entered an invalid AWS CLI profile: "$cli_profile" " 
        fnWriteLog ${LINENO} level_0 ""
        fnWriteLog ${LINENO} level_0 "  Available cli_profiles are:"
        cli_profile_available="$(cat /home/"$this_user"/.aws/config | grep "\[profile" 2>&1)"
        #
        # check for command / pipeline error(s)
        if [ "$?" -ne 0 ]
            then
                #
                # set the command/pipeline error line number
                error_line_pipeline="$((${LINENO}-7))"
                #
                # call the command / pipeline error function
                fnErrorPipeline
                #
        #
        fi
        #
        fnWriteLog ${LINENO} "value of variable 'cli_profile_available': "$cli_profile_available ""
        feed_write_log="$(echo "  "$cli_profile_available"" 2>&1)"
        fnWriteLog ${LINENO} level_0 "$feed_write_log"
        fnWriteLog ${LINENO} level_0 ""
        fnWriteLog ${LINENO} level_0 "  To set up an AWS CLI profile enter: aws configure --profile profileName "
        fnWriteLog ${LINENO} level_0 ""
        fnWriteLog ${LINENO} level_0 "  Example: aws configure --profile MyProfileName "
        fnWriteLog ${LINENO} level_0 ""
        fnWriteLog ${LINENO} level_0 "--------------------------------------------------------------------------"
        fnWriteLog ${LINENO} level_0 ""
        fnUsage
fi 
#
###################################################
#
#
# pull the AWS account number
#
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} "pulling AWS account"
this_aws_account="$(aws sts get-caller-identity --profile "$cli_profile" --output text --query 'Account' 2>&1)"
	#
	# check for errors from the AWS API  
	if [ "$?" -ne 0 ]
	then
	    # AWS Error while pulling the AWS Services
	    fnWriteLog ${LINENO} level_0 "--------------------------------------------------------------------------------------------------"       
	    fnWriteLog ${LINENO} level_0 ""
	    fnWriteLog ${LINENO} level_0 "AWS error message: "
	    fnWriteLog ${LINENO} level_0 "$this_aws_account"
	    fnWriteLog ${LINENO} level_0 ""
	    fnWriteLog ${LINENO} level_0 "--------------------------------------------------------------------------------------------------"
	    fnWriteLog ${LINENO} level_0 ""
	    fnWriteLog ${LINENO} level_0 " AWS Error while pulling the AWS tagable resources for region: "$aws_region" "
	    fnWriteLog ${LINENO} level_0 ""
	    fnWriteLog ${LINENO} level_0 "--------------------------------------------------------------------------------------------------"
	    #
	    # set the awserror line number
	    error_line_aws="$((${LINENO}-17))"
	    #
	    # call the AWS error handler
	    fnErrorAws
	    #
	fi # end AWS error check
	#
fnWriteLog ${LINENO} "value of variable 'this_aws_account': "$this_aws_account" "
fnWriteLog ${LINENO} ""
#
###################################################
#
#
# set the aws account dependent variables
#
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} "setting the AWS account dependent variables"
#
write_path="$this_path"/aws-"$this_aws_account"-"$this_utility_filename_plug"-"$file_date"
this_log_file=aws-"$this_aws_account"-"$this_utility_filename_plug"-v"$script_version"-"$file_date"-debug.log 
this_log_file_errors=aws-"$this_aws_account"-"$this_utility_filename_plug"-v"$script_version"-"$file_date"-errors.log 
this_log_file_full_path="$write_path"/"$this_log_file"
this_log_file_errors_full_path="$write_path"/"$this_log_file_errors"
this_summary_report=aws-"$this_aws_account"-"$this_utility_filename_plug"-"$file_date"-report-summary.txt
this_summary_report_full_path="$write_path"/"$this_summary_report"
this_detail_report=aws-"$this_aws_account"-"$this_utility_filename_plug"-"$file_date"-report-detail.txt
this_detail_report_full_path="$write_path"/"$this_detail_report"
this_output_file=aws-"$this_aws_account"-"$this_utility_filename_plug"-"$file_date"-list.txt
this_output_file_full_path="$write_path"/"$this_output_file"
#
fnWriteLog ${LINENO} "value of variable 'this_log_file': "$this_log_file" "
fnWriteLog ${LINENO} "value of variable 'this_log_file_errors': "$this_log_file_errors" "
fnWriteLog ${LINENO} "value of variable 'this_log_file_full_path': "$this_log_file_full_path" "
fnWriteLog ${LINENO} "value of variable 'this_log_file_errors_full_path': "$this_log_file_errors_full_path" "
fnWriteLog ${LINENO} "value of variable 'this_summary_report': "$this_summary_report" "
fnWriteLog ${LINENO} "value of variable 'this_summary_report_full_path': "$this_summary_report_full_path" "
fnWriteLog ${LINENO} "value of variable 'this_detail_report': "$this_detail_report" "
fnWriteLog ${LINENO} "value of variable 'this_detail_report_full_path': "$this_detail_report_full_path" "
fnWriteLog ${LINENO} "value of variable 'write_path': "$write_path" "
fnWriteLog ${LINENO} "value of variable 'this_output_file': "$this_output_file_full_path" "
fnWriteLog ${LINENO} "value of variable 'this_output_file_full_path': "$this_output_file_full_path" "
fnWriteLog ${LINENO} ""
#
###################################################
#
#
# create the directories
#
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} "creating write path directories "
feed_write_log="$(mkdir -p "$write_path" 2>&1)"
fnWriteLog ${LINENO} "$feed_write_log"
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} "status of write path directories "
feed_write_log="$(ls -ld */ "$this_path" 2>&1)"
fnWriteLog ${LINENO} "$feed_write_log"
fnWriteLog ${LINENO} ""
#
###################################################
#
#
# pull the AWS account alias
#
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} "pulling AWS account alias"
this_aws_account_alias="$(aws iam list-account-aliases --profile "$cli_profile" --output text --query 'AccountAliases' 2>&1)"
	#
	# check for errors from the AWS API  
	if [ "$?" -ne 0 ]
	then
	    # AWS Error while pulling the AWS Services
	    fnWriteLog ${LINENO} level_0 "--------------------------------------------------------------------------------------------------"       
	    fnWriteLog ${LINENO} level_0 ""
	    fnWriteLog ${LINENO} level_0 "AWS error message: "
	    fnWriteLog ${LINENO} level_0 "$this_aws_account_alias"
	    fnWriteLog ${LINENO} level_0 ""
	    fnWriteLog ${LINENO} level_0 "--------------------------------------------------------------------------------------------------"
	    fnWriteLog ${LINENO} level_0 ""
	    fnWriteLog ${LINENO} level_0 " AWS Error while pulling the AWS tagable resources for region: "$aws_region" "
	    fnWriteLog ${LINENO} level_0 ""
	    fnWriteLog ${LINENO} level_0 "--------------------------------------------------------------------------------------------------"
	    #
	    # set the awserror line number
	    error_line_aws="$((${LINENO}-17))"
	    #
	    # call the AWS error handler
	    fnErrorAws
	    #
	fi # end AWS error check
	#
	fnWriteLog ${LINENO} "value of variable 'this_aws_account_alias': "$this_aws_account_alias" "
fnWriteLog ${LINENO} ""
#
###############################################################################
# 
#
# Initialize the log file
#
if [[ "$logging" = "y" ]] ;
    then
        fnWriteLog ${LINENO} ""
        fnWriteLog ${LINENO} "initializing the log file "
        fnWriteLog ${LINENO} ""
        echo "Log start" > "$this_log_file_full_path"
        echo "" >> "$this_log_file_full_path"
        echo "This log file name: "$this_log_file"" >> "$this_log_file_full_path"
        echo "" >> "$this_log_file_full_path"
        #
        fnWriteLog ${LINENO} ""
        fnWriteLog ${LINENO} "contents of file:'$this_log_file_full_path' "
        feed_write_log="$(cat "$this_log_file_full_path"  2>&1)"
        fnWriteLog ${LINENO} "$feed_write_log"
        fnWriteLog ${LINENO} ""
#
fi 
#
###############################################################################
# 
#
# Initialize the error log file
#
echo "  Errors:" > "$this_log_file_errors_full_path"
echo "" >> "$this_log_file_errors_full_path"
#
#
###########################################################################################################################
#
#
# Begin checks and setup 
#
#

#
###################################################
#
#
# clear the console
#
clear
# 
######################################################################################################################################################################
#
#
# Opening menu
#
#
######################################################################################################################################################################
#
#
fnWriteLog ${LINENO} level_0 ""
fnWriteLog ${LINENO} level_0 "$text_menu"
fnWriteLog ${LINENO} level_0 ""
fnWriteLog ${LINENO} level_0 " Get all AWS Services' tagable resources for an AWS account and generate reports   "  
fnWriteLog ${LINENO} level_0 ""
fnWriteLog ${LINENO} level_0 "$text_menu_bar"
fnWriteLog ${LINENO} level_0 ""
fnWriteLog ${LINENO} level_0 "AWS account:............"$this_aws_account"  "$this_aws_account_alias" "
fnWriteLog ${LINENO} level_0 ""
fnWriteLog ${LINENO} level_0 ""
fnWriteLog ${LINENO} level_0 "       >> The AWS CLI profile determines the AWS account to pull the tagable resources from << "
fnWriteLog ${LINENO} level_0 ""
fnWriteLog ${LINENO} level_0 ""
fnWriteLog ${LINENO} level_0 "$text_menu_bar"
fnWriteLog ${LINENO} level_0 ""
fnWriteLog ${LINENO} level_0 ""
fnWriteLog ${LINENO} level_0 "The AWS tagable resources for this account will be captured and written to reports "
fnWriteLog ${LINENO} level_0 ""
fnWriteLog ${LINENO} level_0 ""
fnWriteLog ${LINENO} level_0 " ###############################################"
fnWriteLog ${LINENO} level_0 " >> Note: There is no undo for this operation << "
fnWriteLog ${LINENO} level_0 " ###############################################"
fnWriteLog ${LINENO} level_0 ""
fnWriteLog ${LINENO} level_0 " By running this utility script you are taking full responsibility for any and all outcomes"
fnWriteLog ${LINENO} level_0 ""
fnWriteLog ${LINENO} level_0 "AWS Services Tagable Resources utility"
fnWriteLog ${LINENO} level_0 "Run Utility Y/N Menu"
#
# Present a menu to allow the user to exit the utility and do the preliminary steps
#
# Menu code source: https://stackoverflow.com/questions/30182086/how-to-use-goto-statement-in-shell-script
#
# Define the choices to present to the user, which will be
# presented line by line, prefixed by a sequential number
# (E.g., '1) copy', ...)
choices=( 'Run' 'Exit' )
#
# Present the choices.
# The user chooses by entering the *number* before the desired choice.
select choice in "${choices[@]}"; do
#   
    # If an invalid number was chosen, "$choice" will be empty.
    # Report an error and prompt again.
    [[ -n "$choice" ]] || { fnWriteLog ${LINENO} level_0 "Invalid choice." >&2; continue; }
    #
    # Examine the choice.
    # Note that it is the choice string itself, not its number
    # that is reported in "$choice".
    case "$choice" in
        Run)
                fnWriteLog ${LINENO} level_0 ""
                fnWriteLog ${LINENO} level_0 "Running AWS Services Tagable Resources utility"
                fnWriteLog ${LINENO} level_0 ""
                # Set flag here, or call function, ...
            ;;
        Exit)
        #
        #
                fnWriteLog ${LINENO} level_0 ""
                fnWriteLog ${LINENO} level_0 "Exiting the utility..."
                fnWriteLog ${LINENO} level_0 ""
                fnWriteLog ${LINENO} level_0 ""
                # delete the work files
                fnDeleteWorkFiles
                # append the temp log onto the log file
                fnWriteLogTempFile
                # write the log variable to the log file
                fnWriteLogFile
                exit 1
    esac
    #
    # Getting here means that a valid choice was made,
    # so break out of the select statement and continue below,
    # if desired.
    # Note that without an explicit break (or exit) statement, 
    # bash will continue to prompt.
    break
    #
    # end select - menu 
    # echo "at done"
done
#
##########################################################################
#
#      *********************  begin script *********************
#
##########################################################################
#
##########################################################################
#
#
# ---- begin: write the start timestamp to the log 
#
fnHeader
#
now_date="$(date +"%Y-%m-%d-%H%M%S")"
fnWriteLog ${LINENO} "" 
fnWriteLog ${LINENO} "" 
fnWriteLog ${LINENO} "" 
fnWriteLog ${LINENO} "" 
fnWriteLog ${LINENO} "-------------------------------------------------------------------------------------------" 
fnWriteLog ${LINENO} "-------------------------------------------------------------------------------------------" 
fnWriteLog ${LINENO} "" 
fnWriteLog ${LINENO} "run start timestamp: "$now_date" " 
fnWriteLog ${LINENO} "" 
fnWriteLog ${LINENO} "-------------------------------------------------------------------------------------------" 
fnWriteLog ${LINENO} "-------------------------------------------------------------------------------------------" 
fnWriteLog ${LINENO} "" 
fnWriteLog ${LINENO} "" 
fnWriteLog ${LINENO} "" 
fnWriteLog ${LINENO} "" 
fnWriteLog ${LINENO} ""  
#
fnWriteLog ${LINENO} "increment the task counter"
fnCounterIncrementTask
#
#
##########################################################################
#
#
# clear the console for the run 
#
fnHeader
#
##########################################################################
#
#
# ---- begin: display the log location 
#
fnWriteLog ${LINENO} "" 
fnWriteLog ${LINENO} "-------------------------------------------------------------------------------------------" 
fnWriteLog ${LINENO} "-------------------------------------------------------------------------------------------" 
fnWriteLog ${LINENO} "" 
fnWriteLog ${LINENO} "Run log: "$this_log_file_full_path" " 
fnWriteLog ${LINENO} "" 
fnWriteLog ${LINENO} "-------------------------------------------------------------------------------------------" 
fnWriteLog ${LINENO} "-------------------------------------------------------------------------------------------" 
fnWriteLog ${LINENO} "" 
fnWriteLog ${LINENO} "" 
fnWriteLog ${LINENO} "" 
fnWriteLog ${LINENO} "" 
#
#
fnWriteLog ${LINENO} ""  
#
fnWriteLog ${LINENO} "increment the task counter"
fnCounterIncrementTask
#

#
#
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} "----------------------------------------------------------------------------------------------------------"
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} "------------------------------------ begin: pull the tagable resources -----------------------------------"
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} "----------------------------------------------------------------------------------------------------------"
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} ""
#
#
##########################################################################
#
#
# initialize the output file
#
echo "" > "$this_output_file_full_path"
#
#
##########################################################################
#
#
# pull the AWS regions available for this account
#
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} level_0 "Pulling the list of available regions from AWS"
fnWriteLog ${LINENO} level_0 ""
fnWriteLog ${LINENO} level_0 "This task can take a while. Please wait..."
fnWriteLog ${LINENO} "pulling a list of current AWS regions and loading variable 'aws_region_list' "
fnWriteLog ${LINENO} "command: aws ec2 describe-regions --output text --profile "$cli_profile" "
aws_region_list="$(aws ec2 describe-regions --output text --profile "$cli_profile" | cut -f4 | sort 2>&1)"
#
# check for command / pipeline error(s)
if [ "$?" -ne 0 ]
    then
        #
        # set the command/pipeline error line number
        error_line_pipeline="$((${LINENO}-7))"
        #
        # call the command / pipeline error function
        fnErrorPipeline
        #
#
fi
#
#
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} "value of variable 'aws_region_list':  "
feed_write_log="$(echo "$aws_region_list" 2>&1)"
fnWriteLog ${LINENO} "$feed_write_log"
fnWriteLog ${LINENO} ""
#
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} "counting the list of current AWS regions"
count_aws_region_list="$(echo "$aws_region_list" | wc -l )"
#
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} "value of variable 'count_aws_region_list': "$count_aws_region_list" "
fnWriteLog ${LINENO} ""
#
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} "initializing the region counter"
counter_aws_region_list=0
#
#
##########################################################################
#
#
# pull the tagable objects for all AWS regions for this account
#
# loop through the regions and pull the tagable objects
for aws_region in $aws_region_list
#
# Note: 2017-07-12: at this time there is no known API method to pull a list of non-tagable objects
#
do
    fnWriteLog ${LINENO} ""
    fnWriteLog ${LINENO} "----------------------- loop head: read variable 'aws_region_list' -----------------------  "
    fnWriteLog ${LINENO} ""
    # display the header    
    fnHeader
    # display the task progress bar - function parameters are: counter count
    fnProgressBarTaskDisplay "$counter_aws_region_list" "$count_aws_region_list"
 	#
    fnWriteLog ${LINENO} ""
    fnWriteLog ${LINENO} level_0 "Pulling tagable resources for AWS region: "$aws_region" "
    fnWriteLog ${LINENO} level_0 ""
    fnWriteLog ${LINENO} level_0 "This task can take a while. Please wait..."
    fnWriteLog ${LINENO} level_0 ""
    #
	fnWriteLog ${LINENO} level_0 ""
    fnWriteLog ${LINENO} "loading variable 'aws_tagable_resources_region_raw' "
    fnWriteLog ${LINENO} "command: aws resourcegroupstaggingapi get-resources --region "$aws_region" --profile "$cli_profile"   "
    aws_tagable_resources_region_raw="$(aws resourcegroupstaggingapi get-resources --region "$aws_region" --profile "$cli_profile" 2>&1)"
	#
	# check for errors from the AWS API  
	if [ "$?" -ne 0 ]
	then
	    # AWS Error while pulling the AWS Services
	    fnWriteLog ${LINENO} level_0 "--------------------------------------------------------------------------------------------------"       
	    fnWriteLog ${LINENO} level_0 ""
	    fnWriteLog ${LINENO} level_0 "AWS error message: "
	    fnWriteLog ${LINENO} level_0 "$aws_tagable_resources_region_raw"
	    fnWriteLog ${LINENO} level_0 ""
	    fnWriteLog ${LINENO} level_0 "--------------------------------------------------------------------------------------------------"
	    fnWriteLog ${LINENO} level_0 ""
	    fnWriteLog ${LINENO} level_0 " AWS Error while pulling the AWS tagable resources for region: "$aws_region" "
	    fnWriteLog ${LINENO} level_0 ""
	    fnWriteLog ${LINENO} level_0 "--------------------------------------------------------------------------------------------------"
	    #
	    # set the awserror line number
	    error_line_aws="$((${LINENO}-17))"
	    #
	    # call the AWS error handler
	    fnErrorAws
	    #
	fi # end AWS error check
	#
	fnWriteLog ${LINENO} ""
	fnWriteLog ${LINENO} "value of variable 'aws_tagable_resources_region_raw':  "
	feed_write_log="$(echo "$aws_tagable_resources_region_raw" 2>&1)"
	fnWriteLog ${LINENO} "$feed_write_log"
	fnWriteLog ${LINENO} ""
	#
	#
	fnWriteLog ${LINENO} ""
	fnWriteLog ${LINENO} "stip out the JSON formatting and load the variable 'aws_tagable_resources_region'"
	aws_tagable_resources_region="$(echo "$aws_tagable_resources_region_raw" | grep -v 'ResourceTagMappingList' \
	| grep -v '.*{.*' | sed 's/},/----------/' | grep -v '.*}.*' | grep -v '.*\].*' | sed 's/^ *//' | sed 's/\[//' \
	| sed 's/"//g' | sed 's/^Value:*/  Value:/' | sed 's/^Key:*/  Key:/' | sed 's/^----------*/  ----------/' | sed 's/,//g' )"
	#
	fnWriteLog ${LINENO} ""
	fnWriteLog ${LINENO} "value of variable 'aws_tagable_resources_region':  "
	feed_write_log="$(echo "$aws_tagable_resources_region" 2>&1)"
	fnWriteLog ${LINENO} "$feed_write_log"
	fnWriteLog ${LINENO} ""
	#
	fnWriteLog ${LINENO} ""
	fnWriteLog ${LINENO} "load the variable 'count_tagable_resources_region'"
    count_tagable_resources_region="$(echo "$aws_tagable_resources_region" | grep 'ResourceARN' | wc -l )"
	#
	fnWriteLog ${LINENO} ""
	fnWriteLog ${LINENO} "value of variable 'count_tagable_resources_region':  "
	feed_write_log="$(echo "$count_tagable_resources_region" 2>&1)"
	fnWriteLog ${LINENO} "$feed_write_log"
	fnWriteLog ${LINENO} ""
	#
	feed_write_log="$(echo "--------------------------------------------------------------------------------------------------" >> "$this_output_file_full_path"  2>&1)"
	fnWriteLog ${LINENO} "$feed_write_log"
	feed_write_log="$(echo -e "\nTagable resources in region: ""$aws_region"" count:""$count_tagable_resources_region" >> "$this_output_file_full_path"  2>&1)"
	fnWriteLog ${LINENO} "$feed_write_log"
	feed_write_log="$(echo "--------------------------------------------------" >> "$this_output_file_full_path"  2>&1)"
	fnWriteLog ${LINENO} "$feed_write_log"
	feed_write_log="$(echo "$aws_tagable_resources_region">> "$this_output_file_full_path"  2>&1)"
	fnWriteLog ${LINENO} "$feed_write_log"
	feed_write_log="$(echo "--------------------------------------------------------------------------------------------------" >> "$this_output_file_full_path"  2>&1)"
	fnWriteLog ${LINENO} "$feed_write_log"
    #
    #
    # increment the region counter
    fnCounterIncrementRegions
    #
    #
    # write out the temp log and empty the log variable
    fnWriteLogTempFile
    #
    #
    fnWriteLog ${LINENO} ""
    fnWriteLog ${LINENO} "----------------------- loop tail: read variable 'aws_region_list' -----------------------  "
    fnWriteLog ${LINENO} ""
#
done
#
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} "----------------------- done with section: read variable 'aws_service_key_list' -----------------------  "
fnWriteLog ${LINENO} ""
# display the header    
fnHeader
# display the task progress bar
fnProgressBarTaskDisplay "$counter_aws_region_list" "$count_aws_region_list"
#
#
#
fnWriteLog ${LINENO} ""  
#
fnWriteLog ${LINENO} "increment the task counter"
fnCounterIncrementTask
#

#
#
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} "----------------------------------------------------------------------------------------------------------"
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} "------------------------------------- end: pull the tagable resources ------------------------------------"
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} "----------------------------------------------------------------------------------------------------------"
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} ""
#
##########################################################################
#
#
# create the summary report 
#
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} "----------------------------------------------------------------------------------------------------------"
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} "-------------------------------------- begin: create summary report --------------------------------------"
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} "----------------------------------------------------------------------------------------------------------"
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} ""
#
fnHeader
#
# load the report variables
#
fnWriteLog ${LINENO} "loading variable: 'count_tagable_resources' "
count_tagable_resources="$(cat "$this_output_file_full_path" | grep 'ResourceARN'| wc -l )"
#
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} "value of variable 'count_tagable_resources':  "
feed_write_log="$(echo "$count_tagable_resources" 2>&1)"
fnWriteLog ${LINENO} "$feed_write_log"
fnWriteLog ${LINENO} ""
#
fnWriteLog ${LINENO} "loading variable: 'count_tags' "
count_tags="$(cat "$this_output_file_full_path" | grep 'Key:'| wc -l )"
#
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} "value of variable 'count_tags':  "
feed_write_log="$(echo "$count_tags" 2>&1)"
fnWriteLog ${LINENO} "$feed_write_log"
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} ""
#
#
fnWriteLog ${LINENO} "loading variable: 'count_subtotals_by_service_region' "
# do not quote the variables in the awk command 
count_subtotals_by_service_region="$(cat "$this_output_file_full_path" | grep 'ResourceARN:' | sed -e 's/.*ResourceARN: arn:aws://' \
| cut -f1,2 -d':' | sort | uniq -c | sed 's/:$/: global /' | sed 's/:/ /' | column -t | awk '{ print $2" "$3" "$1}' | column -t | sed -e 's/^/     /' 2>&1 )"
#
# check for command / pipeline error(s)
if [ "$?" -ne 0 ]
    then
        #
        # set the command/pipeline error line number
        error_line_pipeline="$((${LINENO}-7))"
        #
        # call the command / pipeline error function
        fnErrorPipeline
        #
#
fi
#
#
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} "value of variable 'count_subtotals_by_service_region':  "
feed_write_log="$(echo "$count_subtotals_by_service_region" 2>&1)"
fnWriteLog ${LINENO} "$feed_write_log"
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} ""
#
fnWriteLog ${LINENO} level_0 ""
fnWriteLog ${LINENO} level_0 "Creating job summary report file "
fnWriteLog ${LINENO} level_0 ""
#
# initialize the report file and append the report lines to the file
echo "">"$this_summary_report_full_path"
echo "">>"$this_summary_report_full_path"
echo "  ------------------------------------------------------------------------------------------">>"$this_summary_report_full_path"
echo "  ------------------------------------------------------------------------------------------">>"$this_summary_report_full_path"
echo "">>"$this_summary_report_full_path"
echo "  AWS Services Tagable Resources Summary Report">>"$this_summary_report_full_path"
echo "">>"$this_summary_report_full_path"
echo "  Script Version: "$script_version"">>"$this_summary_report_full_path"
echo "">>"$this_summary_report_full_path"
echo "  Date: "$file_date"">>"$this_summary_report_full_path"
echo "">>"$this_summary_report_full_path"
echo "  AWS Account: "$this_aws_account"  "$this_aws_account_alias"">>"$this_summary_report_full_path"
echo "">>"$this_summary_report_full_path"
echo "">>"$this_summary_report_full_path"
echo "  Number of regions: "$count_aws_region_list" ">>"$this_summary_report_full_path"
echo "">>"$this_summary_report_full_path"
echo "  Number of tagable resources: "$count_tagable_resources" ">>"$this_summary_report_full_path"
echo "">>"$this_summary_report_full_path"
echo "  Number of tags: "$count_tags" ">>"$this_summary_report_full_path"
echo "">>"$this_summary_report_full_path"
echo "">>"$this_summary_report_full_path"
if [[ "$logging" == "y" ]] ;
    then
        echo "  AWS Services Tagable Resources job log file: ">>"$this_summary_report_full_path"
        echo "  "$write_path"/ ">>"$this_summary_report_full_path"
        echo "  "$this_log_file" ">>"$this_summary_report_full_path"
        echo "">>"$this_summary_report_full_path"
        echo "">>"$this_summary_report_full_path"
fi
echo "  ------------------------------------------------------------------------------------------">>"$this_summary_report_full_path"
count_error_lines="$(cat "$this_log_file_errors_full_path" | wc -l)"
if (( "$count_error_lines" > 2 ))
    then
        echo "">>"$this_summary_report_full_path"
        echo "">>"$this_summary_report_full_path"
        # add the errors to the report
        feed_write_log="$(cat "$this_log_file_errors_full_path">>"$this_summary_report_full_path" 2>&1)"
        fnWriteLog ${LINENO} "$feed_write_log"
        echo "">>"$this_summary_report_full_path"
        echo "">>"$this_summary_report_full_path"
        echo "  ------------------------------------------------------------------------------------------">>"$this_summary_report_full_path"
fi
echo "">>"$this_summary_report_full_path"
echo "">>"$this_summary_report_full_path"
echo "  ------------------------------------------------------------------------------------------">>"$this_summary_report_full_path"
echo "">>"$this_summary_report_full_path"
echo "">>"$this_summary_report_full_path"
echo "  Tagable Resources per service per AWS Region:">>"$this_summary_report_full_path"
echo "  -----------------------------------------------------------------------">>"$this_summary_report_full_path"
fnWriteLog "adding subototals by service by region to the report from variable 'count_subtotals_by_service_region' " 
echo "$count_subtotals_by_service_region">>"$this_summary_report_full_path"
echo "">>"$this_summary_report_full_path"
echo "">>"$this_summary_report_full_path"
echo "  ------------------------------------------------------------------------------------------">>"$this_summary_report_full_path"
echo "">>"$this_summary_report_full_path"
echo "">>"$this_summary_report_full_path"
echo "  Tagable Resources per AWS Region:">>"$this_summary_report_full_path"
echo "  -----------------------------------------------------------------------">>"$this_summary_report_full_path"
#
# add leading 5 characters to match report margin
cat "$this_output_file_full_path" | grep 'Tagable resources' | sed 's/Tagable resources in region: //' | column -t | sed -e 's/^/     /'>>"$this_summary_report_full_path"
#
#
echo "">>"$this_summary_report_full_path"
echo "">>"$this_summary_report_full_path"
echo "  ------------------------------------------------------------------------------------------">>"$this_summary_report_full_path"
echo "  ------------------------------------------------------------------------------------------">>"$this_summary_report_full_path"
echo "">>"$this_summary_report_full_path"
echo "">>"$this_summary_report_full_path"
#
fnWriteLog ${LINENO} level_0 ""
fnWriteLog ${LINENO} level_0 "Summary report complete. "
fnWriteLog ${LINENO} level_0 ""
fnWriteLog ${LINENO} level_0 "Report is located here: "
fnWriteLog ${LINENO} level_0 "$this_summary_report_full_path"
fnWriteLog ${LINENO} level_0 ""
fnWriteLog ${LINENO} level_0 ""
fnWriteLog ${LINENO} ""  
#
fnWriteLog ${LINENO} "increment the task counter"
fnCounterIncrementTask
#
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} "----------------------------------------------------------------------------------------------------------"
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} "--------------------------------------- end: create summary report ---------------------------------------"
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} "----------------------------------------------------------------------------------------------------------"
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} ""
#
##########################################################################
#
#
# create the detail report 
#
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} "----------------------------------------------------------------------------------------------------------"
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} "--------------------------------------- begin: create detail report --------------------------------------"
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} "----------------------------------------------------------------------------------------------------------"
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} ""
#
fnHeader
#
fnWriteLog ${LINENO} level_0 ""
fnWriteLog ${LINENO} level_0 "Creating job detail report file "
fnWriteLog ${LINENO} level_0 ""
#
# initialize the report file and append the report lines to the file
echo "">"$this_detail_report_full_path"
echo "">>"$this_detail_report_full_path"
echo "  ------------------------------------------------------------------------------------------">>"$this_detail_report_full_path"
echo "  ------------------------------------------------------------------------------------------">>"$this_detail_report_full_path"
echo "">>"$this_detail_report_full_path"
echo "  AWS Services Tagable Resources Detail Report">>"$this_detail_report_full_path"
echo "">>"$this_detail_report_full_path"
echo "  Script Version: "$script_version"">>"$this_detail_report_full_path"
echo "">>"$this_detail_report_full_path"
echo "  Date: "$file_date"">>"$this_detail_report_full_path"
echo "">>"$this_detail_report_full_path"
echo "  AWS Account: "$this_aws_account"  "$this_aws_account_alias"">>"$this_detail_report_full_path"
echo "">>"$this_detail_report_full_path"
echo "">>"$this_detail_report_full_path"
echo "  Number of regions: "$count_aws_region_list" ">>"$this_detail_report_full_path"
echo "">>"$this_detail_report_full_path"
echo "  Number of tagable resources: "$count_tagable_resources" ">>"$this_detail_report_full_path"
echo "">>"$this_detail_report_full_path"
echo "  Number of tags: "$count_tags" ">>"$this_detail_report_full_path"
echo "">>"$this_detail_report_full_path"
echo "">>"$this_detail_report_full_path"
if [[ "$logging" == "y" ]] ;
    then
        echo "  AWS Services Tagable Resources job log file: ">>"$this_detail_report_full_path"
        echo "  "$write_path"/ ">>"$this_detail_report_full_path"
        echo "  "$this_log_file" ">>"$this_detail_report_full_path"
        echo "">>"$this_detail_report_full_path"
        echo "">>"$this_detail_report_full_path"
fi
echo "  ------------------------------------------------------------------------------------------">>"$this_detail_report_full_path"
count_error_lines="$(cat "$this_log_file_errors_full_path" | wc -l)"
if (( "$count_error_lines" > 2 ))
    then
        echo "">>"$this_detail_report_full_path"
        echo "">>"$this_detail_report_full_path"
        # add the errors to the report
        feed_write_log="$(cat "$this_log_file_errors_full_path">>"$this_detail_report_full_path" 2>&1)"
        fnWriteLog ${LINENO} "$feed_write_log"
        echo "">>"$this_detail_report_full_path"
        echo "">>"$this_detail_report_full_path"
        echo "  ------------------------------------------------------------------------------------------">>"$this_detail_report_full_path"
fi
echo "">>"$this_detail_report_full_path"
echo "">>"$this_detail_report_full_path"
echo "  Tagable Resources per service per AWS Region:">>"$this_detail_report_full_path"
echo "  -----------------------------------------------------------------------">>"$this_detail_report_full_path"
fnWriteLog "adding subototals by service by region to the report from variable 'count_subtotals_by_service_region' " 
echo "$count_subtotals_by_service_region">>"$this_detail_report_full_path"
echo "">>"$this_detail_report_full_path"
echo "">>"$this_detail_report_full_path"
echo "  ------------------------------------------------------------------------------------------">>"$this_detail_report_full_path"
echo "">>"$this_detail_report_full_path"
echo "">>"$this_detail_report_full_path"
#
# write the names of the snapshotted services to the report
fnWriteLog ${LINENO} "writing contents of file: "${!this_output_file}" to the report " 
echo "  Tagable Resources per AWS Region detail:">>"$this_detail_report_full_path"
echo "  -----------------------------------------------------------------------">>"$this_detail_report_full_path"
#
# add leading 5 characters to match report margin
cat "$this_output_file_full_path" | sed -e 's/^/     /'>>"$this_detail_report_full_path"
#
#
echo "">>"$this_detail_report_full_path"
echo "">>"$this_detail_report_full_path"
echo "  ------------------------------------------------------------------------------------------">>"$this_detail_report_full_path"
echo "  ------------------------------------------------------------------------------------------">>"$this_detail_report_full_path"
echo "">>"$this_detail_report_full_path"
echo "">>"$this_detail_report_full_path"
#
fnWriteLog ${LINENO} level_0 ""
fnWriteLog ${LINENO} level_0 "Detail report complete. "
fnWriteLog ${LINENO} level_0 ""
fnWriteLog ${LINENO} level_0 "Report is located here: "
fnWriteLog ${LINENO} level_0 "$this_detail_report_full_path"
fnWriteLog ${LINENO} level_0 ""
fnWriteLog ${LINENO} level_0 ""
fnWriteLog ${LINENO} ""  
#
fnWriteLog ${LINENO} "increment the task counter"
fnCounterIncrementTask
#
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} "----------------------------------------------------------------------------------------------------------"
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} "---------------------------------------- end: create detail report ---------------------------------------"
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} "----------------------------------------------------------------------------------------------------------"
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} ""
#
##########################################################################
#
#
# delete the work files 
#
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} "----------------------------------------------------------------------------------------------------------"
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} "---------------------------------------- begin: delete work files ----------------------------------------"
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} "----------------------------------------------------------------------------------------------------------"
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} ""
#
fnHeader
#
fnWriteLog ${LINENO} level_0 ""
fnWriteLog ${LINENO} level_0 "Deleting work files"
fnWriteLog ${LINENO} level_0 ""
fnWriteLog ${LINENO} level_0 ""
#
fnDeleteWorkFiles
#
fnWriteLog ${LINENO} ""  
#
fnWriteLog ${LINENO} "increment the task counter"
fnCounterIncrementTask
#
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} "----------------------------------------------------------------------------------------------------------"
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} "----------------------------------------- end: delete work files -----------------------------------------"
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} "----------------------------------------------------------------------------------------------------------"
fnWriteLog ${LINENO} ""
fnWriteLog ${LINENO} ""
#
##########################################################################
#
#
# done 
#
fnHeader
#
fnWriteLog ${LINENO} level_0 ""
fnWriteLog ${LINENO} level_0 ""
fnWriteLog ${LINENO} level_0 "                            Job Complete "
fnWriteLog ${LINENO} level_0 ""
fnWriteLog ${LINENO} level_0 ""
fnWriteLog ${LINENO} level_0 ""
if [[ "$logging" = "y" ]] ;
    then
		fnWriteLog ${LINENO} level_0 " Log, summary and detail reports location: "
	else
		fnWriteLog ${LINENO} level_0 " Summary and detail reports location: "		
fi 
fnWriteLog ${LINENO} level_0 " "$write_path" "
fnWriteLog ${LINENO} level_0 ""
fnWriteLog ${LINENO} level_0 ""
fnWriteLog ${LINENO} level_0 "  Count of tagable resources: "$count_tagable_resources""
fnWriteLog ${LINENO} level_0 ""
fnWriteLog ${LINENO} level_0 ""
fnWriteLog ${LINENO} level_0 "  Count of tags: "$count_tags""
fnWriteLog ${LINENO} level_0 ""
fnWriteLog ${LINENO} level_0 ""
fnWriteLog ${LINENO} level_0 ""
fnWriteLog ${LINENO} level_0 "----------------------------------------------------------------------"
fnWriteLog ${LINENO} level_0 ""
fnWriteLog ${LINENO} level_0 ""
if (( "$count_error_lines" > 2 ))
    then
    fnWriteLog ${LINENO} level_0 ""
    feed_write_log="$(cat "$this_log_file_errors_full_path" 2>&1)" 
    fnWriteLog ${LINENO} level_0 "$feed_write_log"
    fnWriteLog ${LINENO} level_0 ""
    fnWriteLog ${LINENO} level_0 "----------------------------------------------------------------------"
    fnWriteLog ${LINENO} level_0 ""
fi
#
##########################################################################
#
#
# write the stop timestamp to the log 
#
#
now_date="$(date +"%Y-%m-%d-%H%M%S")"
fnWriteLog ${LINENO} "" 
fnWriteLog ${LINENO} "-------------------------------------------------------------------------------------------" 
fnWriteLog ${LINENO} "-------------------------------------------------------------------------------------------" 
fnWriteLog ${LINENO} "" 
fnWriteLog ${LINENO} "run end timestamp: "$now_date" " 
fnWriteLog ${LINENO} "" 
fnWriteLog ${LINENO} "-------------------------------------------------------------------------------------------" 
fnWriteLog ${LINENO} "-------------------------------------------------------------------------------------------" 
fnWriteLog ${LINENO} "" 
#
##########################################################################
#
#
# write the log file 
#
if [[ ("$logging" = "y") || ("$logging" = "z") ]] 
    then 
        # append the temp log onto the log file
        fnWriteLogTempFile
        # write the log variable to the log file
        fnWriteLogFile
    else 
        # delete the temp log file
        rm -f "$this_log_temp_file_full_path"        
fi
#
# exit with success 
exit 0
#
#
# ------------------ end script ----------------------



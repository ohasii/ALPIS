#!/bin/bash
###
# ALPIS Automated Linux Post-Installation Settings
# Developed by Issac Nolis Ohasi [ github.com/ohasii/ALPIS ]
# Release ALPIS-2109
# Copyright (c) 2021
#
# This program is free software; you can redistribute it and / or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be usefull,
# but WITHOUT ANY WARRANTY; without even the impled warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
###

###
# SCRIPT SETTINGS
###
LOG_LEVEL='DEBUG'									# DEBUG | VERBOSE | INFO | ERROR_ONLY | QUIET
UNATTEND_SCRIPT=''

#######################################################################################
# DISCLAIMER                                                                          #
#                                                                                     #
# THE FOLLOW CODE CONTAINS SEVERAL COMPLEX ROUTINES. I RECOMMEND TO NEVER CHANGE IT!! #
# WHOEVER DISTURBS THE SILENCE IN THIS SCRIPT WILL BE HUNTED BY 1000 CRYING DEVILS!!! #
#######################################################################################

#######################################################################################
# NAMING CONVENTION                                                                   #
#                                                                                     #
# Script files are named by the following rules:                                      #
#  a. there are no spaces in the file name                                            #
#  b. the file name begins with a lower case letter                                   #
#  c. for the file containing multiple words, each additional word should be          #
#     underscore separated (i.e. my_script.sh)                                        #
#     underscore (i.e. my_script.sh)                                                  #
#  d. the extension of the file is '.sh'                                              #
#                                                                                     #
# Structure                                                                           #
#  a. shell script files are partitioned by using the following 80 column wide        #
#     partitioning comment:                                                           #
#                                                                                     #
#          ###                                                                        #
#          # THIS IS THE TITLE OF THE PARTITION                                       #
#          ###                                                                        #
#  b. the script should contains the following partitions:                            #
#     - SCRIPT SETTINGS                                                               #
#     - INITIALIZATION                                                                #
#     - CONSTANTS                                                                     #
#     - LIBRARIES (set of auxiliar procedures and function)                           #
#     - PROCEDURES AND FUNCTIONS                                                      #
#     - MAIN LOGIC                                                                    # 
#                                                                                     #
# Reference to the shell                                                              #
#  a. this is the mandatory reference to the shell executable each script has to      #
#     begin with:                                                                     #
#          #!/usr/bin/env bash                                                        #
#                                                                                     #
# Environment Variables, Constants and Public Variables                               #
#  a. defined in 'CAPITALS'                                                           #
#  b. for cases that contain multiple words, each additional word should be           #
#     underscore separated (i.e. SCRIPT_VERSION)                                      #
#  c. constants should be defined using 'declare' instruction with parameter -r       #
#     (i.e. declare -r SCRIPT_VERSION="1.0"                                           #
#                                                                                     #
# Local Variables                                                                     #
#  a. defined in 'lower case'                                                         #
#  b. for cases that contain multiple words, each additional word should be           #
#     underscore separated (i.e. counter_menu)                                        #
#  c. if used in internal routine procedures or functions as auxiliar variable,       #
#     it begin with underscore (i.e. _internal_variable)                              #
#                                                                                     #
# Procedures and Functions                                                            #
#  a. defined in 'lower case'                                                         #
#  b. for cases that contain multiple words, each additional word should be           #
#     underscore separated (i.e. counter_menu)                                        #
#  c. functions that return values should be declared with instruction 'function'     #
#  d. if function/routine is an auxiliar component, should begin with underscore      #
#     (i.e. _my_function)                                                             #
#######################################################################################

###
# INITIALIZATION
###
export LC_ALL=C
set -eu -o pipefail

[ "$TERM" = "unknown" ] && TERM=''
declare TERMINAL=${TERM:=xterm=256color}

###
# CONSTANTS
###
declare -r TRUE=-0				# Return TRUE
declare -r FALSE=1				# Return FALSE
declare -r ALPIS_VERSION="21Q3"			# Current script version
declare -r ALPIS_LASTEST_VERSION="https://raw.githubusercontent.com/ohasii/ALPIS/main/.version"
declare -r NEW_TAG="<"
declare -r CLOSE_TAG="</"

#######################################################################################
# LIBRARY COLOR OUTPUT                                                                #
#######################################################################################
# PURPOSE                                                                             #
#   Color the output messages following ANSI color codes.                             #
#                                                                                     #
# COLORS & STYLES                                                                     #
#   Foreground ( black red green yellow blue magenta cyan white )                     #
#   Background ( bg_black bg_red bg_green bg_yellow bg_blue bg_magenta bg_cyan        #
#                bg_white )                                                           #
#   Styles     ( bold underline inverse dim )                                         #
#                                                                                     #
# PARAMETERS                                                                          #
#   --> $1 Message                                                                    #
#                                                                                     #
# EXAMPLE                                                                             #
#   <color> "Message"                                                                 #
#   echo "$<color>Message$(reset)"                                                    #
#   echo "$(<color> Message)"                                                         #
#   echo "$colored" | uncolor                                                         #
#######################################################################################
_color_text() {
  if [ -z "$1" ] && [ ! -t 0 ]; then
    cat </dev/stdin
    tput -T$TERMINAL sgr0;
  elif [ -n "$1" ] && [ ! "$1" = "+" ]; then
    echo -n "$@"
    tput -T$TERMINAL sgr0;
  fi
}

black() { tput -T$TERMINAL setaf 0; _color_text "$@"; }
red() { tput -T$TERMINAL setaf 1; _color_text "$@"; }
green() { tput -T$TERMINAL setaf 2; _color_text "$@"; }
yellow() { tput -T$TERMINAL setaf 3; _color_text "$@"; }
blue() { tput -T$TERMINAL setaf 4; _color_text "$@"; }
magenta() { tput -T$TERMINAL setaf 5; _color_text "$@"; }
cyan() { tput -T$TERMINAL setaf 6; _color_text "$@"; }
white() { tput -T$TERMINAL setaf 7; _color_text "$@"; }

bg_black() { tput -T$TERMINAL setab 0; _color_text "$@"; }
bg_red() { tput -T$TERMINAL setab 1; _color_text "$@"; }
bg_green() { tput -T$TERMINAL setab 2; _color_text "$@"; }
bg_yellow() { tput -T$TERMINAL setab 3; _color_text "$@"; }
bg_blue() { tput -T$TERMINAL setab 4; _color_text "$@"; }
bg_magenta() { tput -T$TERMINAL setab 5; _color_text "$@"; }
bg_cyan() { tput -T$TERMINAL setab 6; _color_text "$@"; }
bg_white() { tput -T$TERMINAL setab 7; _color_text "$@"; }

bold() { tput -T$TERMINAL bold; _color_text "$@"; }
underline() { tput -T$TERMINAL smul; _color_text "$@"; }
inverse() { tput -T$TERMINAL rev; _color_text "$@"; }
dim() { tput -T$TERMINAL dim; _color_text "$@"; }

reset() { tput -T$TERMINAL sgr0; }

decolor() {
  if [ -z "$1" ] && [ ! -t 0 ]; then
    sed 's/\x1B\[[0-9;]*[a-zA-Z]//g;s/\x1B\x28\x42//g' </dev/stdin
  else
    sed 's/\x1B\[[0-9;]*[a-zA-Z]//g;s/\x1B\x28\x42//g' <<< "$@"
  fi
}

#######################################################################################
# LIBRARY LOG HANDLER                                                                 #
#######################################################################################
# PURPOSE                                                                             #
#   Log handler - It allows logging to STDERR.                                        #
#                                                                                     #
# LOG LEVELS                                                                          #
#   Eight logging levels are supported:                                               #
#                                                                                     #
#   LEVEL              | NUMERIC  | USAGE                                             #
#   ------------------- ---------- -------------------------------------------        #
#   DEBUG              | 5        | Diagnostically helpful messages                   #
#   RUNNING            | 10       | Step in execution                                 #
#   SUCCESS            | 15       | Success message or step done                      #
#   WARNING            | 20       | Warning which may be OK                           #
#   ALERT              | 25       | Very critical like incorrect method call          #
#   ERROR              | 30       | An error which can occur                          #
#   EMERGENCY          | 35       | Something which should never happen               #
#                                                                                     #
# EXAMPLES                                                                            #
#   log INFO "process is working"                                                     #
#######################################################################################
log() {
  declare -A log_severities
    log_severities[DEBUG]=5
    log_severities[RUNNING]=10
    log_severities[SUCCESS]=15
    log_severities[WARNING]=20
    log_severities[ALERT]=25
    log_severities[ERROR]=30
    log_severities[EMERGENCY]=35
  declare -r log_severities

  declare -A log_color
    log_color[DEBUG]="$(bg_cyan +)$(bold +)$(black +)"
    log_color[RUNNING]="$(bg_green +)$(bold +)$(white +)"
    log_color[SUCCESS]="$(bg_green +)$(bold +)$(white +)"
    log_color[WARNING]="$(bg_yellow +)$(bold +)$(black +)"
    log_color[ALERT]="$(bg_yellow +)$(bold +)$(black +)"
    log_color[ERROR]="$(bg_red +)$(bold +)$(white +)"
    log_color[EMERGENCY]="$(bg_red +)$(bold +)$(white +)"
  declare -r log_color

  declare -i log_severity

  declare -u message_type="${1}"
  declare -u spaces=""
  declare message_text="${2}"

# Filter log display based on LOG_LEVEL
# DEBUG   --> DEBUG > RUNNING > SUCCESS > WARNING > ALERT > ERROR > EMERGENCY
# VERBOSE --> RUNNING > SUCCESS > WARNING > ALERT > ERROR > EMERGENCY
# INFO    --> WARNING > ALERT > ERROR > EMERGENCY
# ERROR   --> ERROR > EMERGENCY
# QUIET   --> No log
  case $LOG_LEVEL in
    "DEBUG")   log_severity=${log_severities[DEBUG]};;
    "VERBOSE") log_severity=${log_severities[RUNNING]};;
    "INFO")    log_severity=${log_severities[WARNING]};;
    "ERROR")   log_severity=${log_severities[ERROR]};;
    "QUIET")   log_severity=100;;
    *)         log_severity=${log_severities[ERROR]};;
  esac

  [ "${log_severities[$message_type]}" -lt "$log_severity" ] && return

# Logging format
  if [ "${#message_type}" -eq 5 ]; then
    spaces="  "
  elif [ "${#message_type}" -eq 7 ]; then
    spaces=" "
  fi
  message_text=$( sed 's/^\[[A-Z][A-Z]* *\] //' <<< "$message_text" )
  echo "${log_color[$message_type]}[$spaces $message_type $spaces]$(reset) $message_text"
}

# Checking valid message level
declare -ar _log_level_types=(DEBUG VERBOSE INFO ERROR QUIET)
declare _valid_log_level=$FALSE
for _log_level_type in "${_log_level_types[@]}"; do
  [ "$_log_level_type" == "$LOG_LEVEL" ] && _valid_log_level=$TRUE
done
if [ $_valid_log_level = $FALSE ]; then
  log ERROR "$LOG_LEVEL is not a valid LOG_LEVEL. Please open the script and adjust settings accordingly"
  exit 1
fi

#######################################################################################
# LIBRARY XML PARSER                                                                  #
#######################################################################################
# PURPOSE                                                                             #
#   Provide interface for client applications to work with XML documents.             #
#                                                                                     #
# FUNCTIONS                                                                           #
#   read_xml                  - Read XML file                                         #
#   get_xml_element           - Return element from a tag                             #
#   get_xml_element_attribute - Return element attribute                              #
#                                                                                     #
# EXAMPLE                                                                             #
#   read_xml "unattend.xml"                                                           #
#######################################################################################
###
# FUNCTION read_xml
###
# PARAMETERS
#   --> $1 Path of XML file
#   <--    Result XML data (string)
#
# EXAMPLE
#   read_xml "unattend.xml"
###
read_xml() {
  echo "$(cat $1)"
}

###
# FUNCTION get_xml_element
###
# PARAMETERS
#   --> $1 XML data (string)
#   --> $2 Element
#   <--    Return Array of Elements
#
# EXAMPLE
#    get_xml_element( read_xml ( "deploy.xml" ) "Event" )
###
function get_xml_element() {
  local data="$1"
  echo "$data" | sed -n '/'$2'/,/\/'$2'/p'  
}

###
# FUNCTION get_xml_element_attribute
###
# PARAMETERS
#   --> $1 XML data (string)
#   --> $2 Element
#   --> $3 Attribute
#   <--    Return attribute and value
#
# EXAMPLE
#   get_xml_element_attribute ( readXMLFile ( "deploy.xml" ) "name" )
###
function get_xml_element_attribute() {
  local element="$1"
  echo "$element" | sed -e 's/^'$2'=//' -e 's/"//g'
}

###
# FUNCTION get_xml_element_attribute_value
###
# PARAMETERS
#   --> $1 Element
#   --> $2 Attribute
#   <--    Return value
###
function get_xml_element_attribute_value() {
#  local attribute="$(echo $1 | grep $2)"
#  echo "$attribute" | grep -Eo $3'=".*"' | sed -e 's/^'$3'=//' -e 's/"//g'
# grep -Eo name'=".*"' | cut -d\" -f1,2 | sed -e 's/^'name'=//' -e 's/"//g'

  echo "$1" | grep -Eo $2'=".*"' | cut -d\" -f1,2 | sed -e 's/^'$2'=//' -e 's/"//g'
}

#######################################################################################
# MAIN FUNCTIONS                                                                      #
#######################################################################################

###
# FUNCTION check_runas_root
###
# PARAMETERS
#   <--    Return code (TRUE = Running as root | FALSE = Running as user)
#
# EXAMPLE
#   check_runas_root && echo "Superman" || echo "Jocker"
###
function check_runas_root() {
  [ $(id -u) -eq 0 ] && return $TRUE || return $FALSE
}

###
# FUNCTION check_internet_connection
###
# PARAMETERS
#   <--    Return code (TRUE = Internet is working | FALSE = Internet is not working)
#
# EXAMPLE
#   check_internet_connection && echo "Internet" | echo "No internet"
###
function check_internet_connection() {
  if ping -q -c 1 -W 1 8.8.8.8 >/dev/null; then 
    return $TRUE
  else
    return $FALSE
  fi
}

###
# FUNCTION check_dns
###
# PARAMETERS
#   <--    Return code (TRUE = Resolution of nameservers is working | FALSE = Resolution of nameservers is fail)
#
# EXAMPLE
#   check_dns && echo "DNS OK" || echo "DNS NOK"
###
function check_dns() {
  if ping -q -c 1 -W 1 google.com >/dev/null; then
    return $TRUE
  else
    return $FALSE
  fi
}

###
# FUNCTION check_package_installed
###
# PARAMETERS
#   --> $1 Package name
#   <--    Return code (TRUE = Package already installed | FALSE = Package not installed)
#
# EXAMPLE
#   check_package_installed "curl"
###
function check_package_installed() {
  dpkg -s $1 >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    return $TRUE
  else
    return $FALSE
  fi
}

###
# PROCEDURE update_system
###
update_system() {
  apt-get update -y -qq >/dev/null && apt-get upgrade -y -qq >/dev/null
}

###
# PROCEDURE install_package
###
# PARAMETERS
#   --> $1 Package name
#
# EXAMPLE
#   install_package "curl"
###
install_package() {
  apt-get install $1 -y -qq >/dev/null
}

###
# PROCEDURE change_hostname
###
# PARAMETERS
#   --> $1 Hostname
#
# EXAMPLE
#   change_hostname "debian"
###
change_hostname() {
  echo "$1" > /etc/hostname
}

###
# FUNCTION add_group
###
# PARAMETERS
#   --> $1 Group Name
#   --> $2 Group ID (GID)
#   <--    Return code (TRUE = Group has benn added to system | FALSE = Failed to add a group)
#
# EXAMPLE
#   add_group "apple" "7000"
###
function add_group() {
  if grep -q $1 /etc/group; then
    return $FALSE
  else
    groupadd -f -g "$2" $1
    return $TRUE
  fi
}

###
# FUNCTION add_user
###
# PARAMETERS
#   --> $1 User Name
#   --> $2 User ID (UID)
#   --> $3 Group ID (GID)
#   <--    Return code (TRUE = User has been added to system | FALSE = Failed to add a user)
#
# EXAMPLE
#   add_user "jobs" "5000" "7000"
###
function add_user() {
  if grep -q $1 /etc/passwd; then
    return $FALSE
  else
    useradd -u $2 -g $3 $1
    return $TRUE
  fi
}

###
# PROCEDURE set_password
###
# PARAMETERS
#   --> $1 User Name
#   --> $2 Password
#
# EXAMPLE
#   set_password "jobs" "apple"
###
set_password() {
  echo "$1:$2" | chpasswd
}

###
# PROCEDURE hello_world
###
hello_world() {
  reset
  clear
  echo "      _       _____     _______  _____   ______   "
  echo "     / \     |_   _|   |_   __ \|_   _|.' ____ \  "
  echo "    / _ \      | |       | |__) | | |  | (___ \_| "
  echo '   / ___ \     | |   _   |  ___/  | |   _.____`.  '
  echo " _/ /   \ \_  _| |__/ | _| |_    _| |_ | \____) | "
  echo "|____| |____||________||_____|  |_____| \______.' "
  echo
  echo " A L P I S  -  Automated Linux Post-Installation Settings"
  echo " Developed by Issac Nolis Ohasi [ github.com/ohasii/ALPIS ]"
  echo " Release $ALPIS_VERSION"
  echo
  echo
}

###
# PROCEDURE perform_preliminary_checks
###
perform_preliminary_checks() {
  declare -ar required_packages=( curl wget )
  declare -a pending_packages=( )
  declare -i i=0

# Check if script can procced with automatic setup
  check_runas_root || ( log ERROR "User $(whoami) does not have administrative rights to run this script" && exit 1 )
  check_internet_connection || ( log ERROR "No internet connectivity: Please check your internet connection and try again" && exit 1 )
  check_dns || ( log ERROR "Internet connectivity is limited: Please check your DNS settings and try again" && exit 1 )

# Check if binaries are present on this installation
  log RUNNING "Checking required packages..."
  for package in "${required_packages[@]}"; do
    if ! check_package_installed $package; then
      let "i=i+1"
      log DEBUG "Package $package is missing"
      pending_packages[i]=$package
    fi
  done

# Install required packages
  if [ ${#pending_packages[@]} -gt 0 ]; then
    log RUNNING "Installing required packages..."
    update_system
    for package in "${pending_packages[@]}"; do
      log DEBUG "Installing package $package"
      install_package $package
    done
  fi
  log SUCCESS "Packages checked successfully"

# Check script version
  log RUNNING "Checking script version..."
  script_version_check=$(curl -s "$ALPIS_LASTEST_VERSION" | awk -F "ALPIS_VERSION=" '{print $2}' | tr -d \")
  log DEBUG "Current version: $ALPIS_VERSION"
  log DEBUG "Lastest version: $script_version_check"
  if [[ $script_version_check == *"$ALPIS_VERSION"* ]]; then
    log DEBUG "Currently execution is running at the lastest version"
  else
    log EMERGENCY "Not running lastest version of this script. Please update script before continue"
    exit 1
  fi

  #log DEBUG "Teste Debug"
  #log RUNNING "Teste Running"
  #log SUCCESS "TESTE Success"
  #log WARNING "Teste Warning"
  #log ALERT "Teste Alert"
  #log ERROR "Teste ERROR"
  #log EMERGENCY "Teste Emergency"
}

###
# FUNCTION retrive_deployment_schema
###
function retrive_deployment_schema() {
  declare deployment_data=$(read_xml "deploy.xml")
  declare events=$(get_xml_element "$deployment_data" "Event")
  declare -a block_header=( )
  declare -a block_content=( )
  declare -i block_index
  declare block_name
  declare block_description
  declare block_tasks

# Two arrays controls the events of XML (header and content).
# Array Header contains the attributes Event ID and Name - they control the log mode
# Array Content contains the tasks used to setup the host
  while IFS= read -r event_line; do
    if [[ $event_line == *"${NEW_TAG}Event"* ]]; then
      block_name=$(get_xml_element_attribute_value "${event_line}" "name")
      block_description=$(get_xml_element_attribute_value "${event_line}" "description")
      block_header[$block_name]=$block_description
    elif [[ $event_line == *"${CLOSE_TAG}Event"* ]]; then
      event_line=""
      block_name=""
      block_description=""
    else
      block_content[$block_name]+=$event_line
    fi
  done < <(printf '%s\n' "$events")

  log RUNNING "Checking deployment file..."
  if [ ${#block_header[@]} -gt 0 ]; then
    if [ ${#block_header[@]} -eq ${#block_content[@]} ]; then
      log DEBUG "${#block_header[@]} events found! Start processing..."
      block_index=1
      for event in "${block_header[@]}"; do
        log RUNNING "Performing event '$event'..."
        while IFS= read -r task; do
          case "$task" in
            *"${NEW_TAG}NetworkSettings"*) echo "Sim Habemus Networksettings";;
            *"${NEW_TAG}InstallPackage"*) echo "Sim temos InstallPackage";;
          esac
        done < <(printf '%s\n' "${block_content[$block_index]}")
#        log DEBUG "Event Details: '${block_content[$block_index]}'"
        (( block_index += 1 ))
      done
    else
      log EMERGENCY "XML file is inconsistent. Please check format file and try again."
      exit 1
    fi
  else
    log EMERGENCY "No events found. Please check file format and try again."
    exit 1
  fi
}

###
# parse_xml($xml_data, "Element" "Attribute" )
###
#parse_xml() {
  
#}

###
#
###
#user_provisioning() {

#}

show_time_remaining() {
  for i in {$2...0};
  do
    echo -ne "$2\r"
    sleep 1
  done
}

###
# MAIN LOGIC
###
hello_world
perform_preliminary_checks
retrive_deployment_schema

#echo -ne '#####                     (33%)\r'
#sleep 1
#echo -ne '#############             (66%)\r'
#sleep 1
#echo -ne '#######################   (100%)\r'
#echo -ne '\n'
# Se passar pelos mini checks acima, criar tela com quadrado e logo, dizendo a solucao de automacao
# dar 3 segundos para a pessoa decidir se vai continuar ou nao



#check_package_installed "ssh"  && echo "Existe" || echo " Nao existe" 
#change_hostname "docker-2f"
#add_group "teste2" "5553" && echo "Criou-se" || echo "Ferrou-se"
#add_user "ohasii2" "9812" "5553"  && echo "Criou-se issac" || echo "Ferrou-se Issac"

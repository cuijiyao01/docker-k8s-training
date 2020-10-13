#!/bin/bash

function wait_until_hit_c() {
  echo ""
  if [ "$slientMode" == 'false' ]; then
    while true; do
        read -p "# Please hit enter to continue?" yn
        case $yn in
  #          [Cc] ) echo ""; break;;
  #          [Nn]* ) ;;
            * ) break;;
        esac
    done
  fi
}

function step() {
  if [ "X${stepByStep}" == 'Xtrue' ] || [ "X$2" == 'X-p' ]; then
    wait_until_hit_c
  fi
  echo ""
  echo ""
  echo "----------------#STEP-${stepNumber}: $1"
  echo ""
  echo ""
  stepNumber=$((stepNumber+1))
}

##
# prints the script usage
##
function usage() {
  echo -e ""
  echo -e "Usage: $0 [options]"
  echo -e ""
  echo -e "\tWhere options is one or more of:"
  echo -e "\t-h\tPrints Help text"
  echo -e "\t--noTyping\tDebug mode. Disables simulated typing"
  echo -e "\t--noWaiting\tNo wait"
  echo -e "\t--step-by-step|--ss\tstop and wait mode"
  echo -e "\t-silent\tno prompt for postman"
  echo -e ""
}

stepByStep=false
slientMode=false
magicMode="-w2"
forceMode=false
while [ $# -ne 0 ]
do
    arg="$1"
    case "$arg" in
        -h)
            usage
            exit 1
            ;;
        -f)
            forceMode=true
            ;;
        --ss)
            stepByStep=true
            ;;
        --step-by-step)
            stepByStep=true
            ;;
        --silent)
            slientMode=true
            ;;
        --noTyping)
            magicMode="$magicMode -d"
            ;;
        --noWaiting)
            magicMode="$magicMode -n"
            ;;
        *)
            nothing="true"
            ;;
    esac
    shift
done


########################
# include the magic
########################
TYPE_SPEED=30
PATH=$PATH:$dir/magic
IFS=' ' read -r -a arguments <<< "$magicMode"
source $dir/magic/demo-magic.sh ${arguments[@]}

DEMO_PROMPT="${GREEN}➜ ${CYAN}\W $ "

#version
stepNumber=1


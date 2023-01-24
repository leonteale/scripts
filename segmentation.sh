#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as sudo"
  exit
fi

echo "Argument 1: $1"
echo "Argument 2: $2"
echo "Argument 3: $3"

if [ -z "$2" ] || [ -z "$(echo $2 | tr -d ' ')" ]; then
    echo "The script is expecting input. Please supply the name of the network as first argument"
    exit
else
    while [ "$1" != "" ]; do
    case $1 in
        -I | --ingress )  shift
                          # xterm -e "bash -c 'nmap -sT -p- -Pn -T4 -oA TCP-$2-cde -n -iL scope-cde.txt; exec bash'" &
                          # xterm -e "bash -c 'sudo nmap -sU -Pn -T4 -n -oA UDP-$2-cde -n -iL scope-cde.txt; exec bash'" &
                          echo "this is ingress $2"
                        ;;
        -E | --egress ) shift
                echo "this is the egress scan. variable $2"
                ;;
        -h | --help )   echo "Usage script.sh [OPTION] [NETWORK_NAME]"
                        echo "Options:"
                        echo " -I, --ingress Run ingress testing"
                        echo " -E, --egress Run egress testing"
                        echo " -h, --help Display this help and exit"
                        exit
                ;;
        * ) echo "Invalid option: $1"
                exit 1
                esac
        shift
done
fi

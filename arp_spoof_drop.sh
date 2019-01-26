#!/bin/bash

IP_OPTION="$1"
IP_ADDR="$2"
NUM_DOTS=$3

print_dots(){
  for ((i=0;i<$NUM_DOTS;i++)); 
  do
    sleep 0.25
    printf "."
  done
}



trap ' echo "flushing on exit..."; iptables --flush; exit 1; ' INT




while true; 
do
  print_dots  
  iptables -A OUTPUT "$IP_OPTION" "$IP_ADDR" -j DROP  
  printf "%s %s" "$IP_OPTION $IP_ADDR"
  print_dots
  iptables --flush
  printf " flushing ip tables...\n"  
done



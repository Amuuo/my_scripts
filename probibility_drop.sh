#!/bin/bash
#
# Script drops a percentage of packets intended for a specific
# desitination to simulate an inconsitent internet connection
#
# Usage: ./probability_drop.sh 
#		<-p --probibility (0..1)> 
#		<-d --destination_ip> 
#		[-s --source_ip]
#		[-D --duration duration of interrupt (sec)][0m
#
#	  Example: sudo ./prob* -p 1 -d us-west307.discord.gg -s 192.168.1.3 -D 3
#
#

PROBIBILITY=""
DESTINATION=""
SOURCE=""
DURATION=""
echo "" > log.txt
tput cup 0 0 


print_usage() {  
  
  printf "\n\t[31mUsage: ./probability_drop.sh  "
  printf "\n\t\t<-d --destination_ip>"
  printf "\n\t\t[-s --source_ip]" 
  printf "\n\t\t[-p --probibility_of_drop (1-100)]"
  printf "\n\t\t[-D --duration duration of interrupt (sec)][0m\n\n"
  printf "\t[31mExample: sudo ./prob* -p 1 -d us-west307.discord.gg -s 192.168.1.3 -D 3[0m\n\n"
  exit 1  
}

while (( "$#" )); do
  
  case "$1" in 
    -p|--probability)
      PROBIBILITY="$2"
      shift 2 ;;
    -d|--destination_ip)
      DESTINATION="$2"
      shift 2 ;;
    -s|--source_ip)
      SOURCE="$2"
      shift 2 ;;
    -D|--duration)
      DURATION="$2"
      shift 2 ;;
    -h|--help)
      print_usage
      exit 1 ;;
    -*)
      print_usage
      exit 1 ;;
  esac

done


if [[ "$PROBIBILITY" == "" || "$DESTINATION" == "" ]]; then
  print_usage
  exit 1
fi

iptables -A OUTPUT -d "$DESTINATION" -m statistic \
 --mode random --probability "$(($PROBIBILITY/100))" -j DROP

printf "\n[32m>> now dropping "$PROBIBILITY"%% of packets between gateway to "$DESTINATION"[0m\n" |& tee -a log.txt


if [[ "$SOURCE" != "" ]]; then
  iptables -A OUTPUT -d "$DESTINATION" -s "$SOURCE" \
  -m statistic --mode random --probability "$(($PROBIBILITY/100))" -j DROP
  printf "[32m>> now dropping "$PROBIBILITY"%% of packets from "$SOURCE" to "$DESTINATION"[0m" 
fi

printf "\n"

if [[ $DURATION != "" ]]; then
  
  
  for (( i=0;i<"$DURATION";i++ )); do
    printf "[s"
    printf "[32m>> Restoring in "$(($DURATION-$i))..."
    sleep 1
    printf "[u"
  done
  printf "[0m\n"
  iptables --flush
fi

printf "\n"

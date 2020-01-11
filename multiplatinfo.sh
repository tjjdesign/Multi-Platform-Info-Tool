#!/bin/bash

#hostname function
function get_hostname (){
    printf "System Hostname:\n" & hostname & printf "\n"
    sleep 1
}

#IP address function
function get_IP_addresses () {
    printf "\nIP Addresses: \n(Distinct interfaces will be on their own line.)\n" \
    & ip addr | grep -E "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" | grep -v 'scope|global|static|dynamic'
    sleep 1
}

#adds timestamp, runs functions, outputs to system.info, then cats file to clbin
(date & printf "\n") >> system.info
get_hostname >> system.info
printf "\n" >> system.info
sleep 1
get_IP_addresses >> system.info
cat system.info | curl -F 'clbin=<-' https://clbin.com

#notify user that file has also been saved locally for their own use
printf "Output also saved to system.info\n"

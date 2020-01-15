#!/bin/bash

#hostname function
function get_hostname (){
    printf "System Hostname:\n" & hostname & printf "\n"
    sleep 1
}

#IP address function
function get_IP_addresses () {
    printf "IP Addresses: \n(Distinct interfaces will be on their own line.)\n" \
    & ip addr | grep -E "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" | grep -v 'scope|global|static|dynamic'
    sleep 1
}

function network-outgoing () {
    netstat -natp
    sleep 1
}

function get-users () {
    printf "Users:\n(Distinct users will be on their own line.)\n"
    cut -d: -f1 /etc/passwd
    sleep 1
}

function get-installed () {
    printf "Installed Programs:\n"
    #if centos: rpm -qa
    printf "RPM output: (Indicates CentOS/RHEL)\n"
    rpm -qa
    #if ubuntu/debian: apt-mark showmanual
    printf "\nAPT output: (Indicates Debian/Ubuntu)\n"
    apt-mark showmanual
    sleep 1
}

function services () {
    printf "Running/enabled services:\n"
    systemctl list-unit-files | grep enabled
    sleep 1
}

#adds timestamp, runs functions, outputs to system.info, then cats file to clbin
printf "Multi-Platform-Info-Tool. Find all the infos.\n"
(date & printf "\n") >> system.info

get_hostname >> system.info
printf "\n" >> system.info

get_IP_addresses >> system.info
printf "\n" >> system.info

network-outgoing >> system.info
printf "\n" >> system.info

get-users >> system.info
printf "\n" >> system.info

get-installed >> system.info
printf "\n" >> system.info

services >> system.info
printf "\n" >> system.info

#feed to clbin
cat system.info | curl -F 'clbin=<-' https://clbin.com

#notify user that file has also been saved locally for their own use
printf "Output also saved to system.info\n"
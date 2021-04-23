#! /bin/bash

set -x

echo "Setting timezone to UTC"
sudo timedatectl set-timezone UTC

echo "RHEL/CentOS system detected"
echo "Performing updates and installing prerequisites"
sudo yum -y check-update

echo "Install some packages"
sudo yum install ntp git wget unzip jq dnsmasq java-1.8.0-openjdk bind-utils tcpdump nc -y

echo "Start NTP server"
sudo systemctl start ntpd.service
sudo systemctl enable ntpd.service

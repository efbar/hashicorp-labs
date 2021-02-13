#! /bin/bash

set -x

echo "Setting timezone to UTC"
sudo timedatectl set-timezone UTC

echo "RHEL/CentOS system detected"
echo "Performing updates and installing prerequisites"
sudo yum-config-manager --enable rhui-REGION-rhel-server-releases-optional
sudo yum-config-manager --enable rhui-REGION-rhel-server-supplementary
sudo yum-config-manager --enable rhui-REGION-rhel-server-extras
sudo yum -y check-update

echo "Install some packages"
sudo yum install ntp git wget unzip jq dnsmasq openjdk-8-jdk java-1.8.0-openjdk bind-utils tcpdump nc -y

echo "Start NTP server"
sudo systemctl start ntpd.service
sudo systemctl enable ntpd.service

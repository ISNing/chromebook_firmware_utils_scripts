#!/bin/bash
#
# This script offers provides the ability to update the
# Legacy Boot payload, set boot options, and install
# a custom coreboot firmware for supported
# ChromeOS devices
#
# Created by Mr.Chromebox <mrchromebox@gmail.com>
#
# May be freely distributed and modified as needed,
# as long as proper attribution is given.
#

#where the stuff is
export script_path=${BASH_SOURCE:-$0}
[[ $1 =~ ^/  ]] && a=$script_path || a=`pwd`/$script_path
while [ -h ${a} ]
do
   b=`ls -ld ${a}|awk '{print $NF}'`
   c=`ls -ld ${a}|awk '{print $(NF-2)}'`
   [[ $b =~ ^/ ]] && a=${b}  || a=`dirname ${c}`/${b}
done
export script_path=${a}
export root=$(cd $(dirname ${script_path});pwd)
echo root=${root}
export local_source="file://${root}/"
script_url="${local_source}/scripts/"


#ensure output of system tools in en-us for parsing
export LC_ALL=C

#set working dir
if grep -q "Chrom" /etc/lsb-release ; then
	# needed for ChromeOS/ChromiumOS v82+
	mkdir -p /usr/local/bin
	cd /usr/local/bin
else
	cd /tmp
fi

#check for cmd line param, expired CrOS certs
if [[ "$1" = "-k" ]]; then
	export CURL="curl -k"
else
	export CURL="curl"
fi

#get support scripts
echo -e "\nDownloading supporting files (from local)..."
rm -rf firmware.sh >/dev/null 2>&1
rm -rf functions.sh >/dev/null 2>&1
rm -rf sources.sh >/dev/null 2>&1
$CURL -sLO ${script_url}firmware.sh
rc0=$?
$CURL -sLO ${script_url}functions.sh
rc1=$?
$CURL -sLO ${script_url}sources.sh
rc2=$?
if [[ $rc0 -ne 0 || $rc1 -ne 0 || $rc2 -ne 0 ]]; then
	echo -e "Error downloading one or more required files; cannot continue"
	exit 1
fi

source ./sources.sh
source ./firmware.sh
source ./functions.sh

#set working dir
cd /tmp

#do setup stuff
prelim_setup || exit 1

#show menu
menu_fwupdate

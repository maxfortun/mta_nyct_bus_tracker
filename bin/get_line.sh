#!/usr/local/bin/bash
cd $(dirname $0)

line=$1
if [ -z "$line" ]; then
	echo "Usage: $0 <line>"
	echo "e.g.: $0 M14A"
	exit
fi

. setenv.sh $line

curl -s "http://api.prod.obanyc.com/api/siri/vehicle-monitoring.json?key=$key&version=2&LineRef=$lineRef"


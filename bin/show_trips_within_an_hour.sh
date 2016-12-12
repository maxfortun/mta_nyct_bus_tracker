#!/usr/local/bin/bash
cd $(dirname $0)

date=$1
time=$2

if [ -z "$time" ]; then
	echo "Usage: $0 <date> <time>"
	echo "e.g.: $0 2016-12-09 now"
fi

. setenv.sh

read -r -d '' SQL << _EOT_
select distinct trip_id 
from activity 
where date(date) = date('$date') 
and time(activity_time) > time('$time', '-1 hour') 
and time(activity_time) < time('$time', '+1 hour');
_EOT_

sqlite3 $DB "$SQL;"


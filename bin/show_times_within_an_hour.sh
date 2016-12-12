#!/usr/local/bin/bash
cd $(dirname $0)

direction=$1
date=$2
time=$3

if [ -z "$time" ]; then
	echo "Usage: $0 <direction> <date> <time>"
	echo "e.g.: $0 1 2016-12-09 now"
fi

. setenv.sh

SPOOL=$TMP/spool

read -r -d '' SQL << _EOT_
select distinct a.trip_id, st.stop_sequence,
st.arrival_time, a.arrival_time,
(strftime("%s",st.arrival_time) - strftime("%s",a.arrival_time)) / 60,
st.departure_time, a.departure_time,
(strftime("%s",st.departure_time) - strftime("%s",a.departure_time)) / 60
from	activity a,
		activity at,
		stop_times st
where st.trip_id = a.trip_id
and st.stop_id = a.stop_id
and at.trip_id = a.trip_id
and at.date = a.date
and date(at.date) = date('$date') 
and time(at.activity_time) > time('$time', '-1 hour') 
and time(at.activity_time) < time('$time', '+1 hour')
and a.direction_id = $direction
order by a.trip_id, st.stop_sequence, st.departure_time
_EOT_

if [ ! -f "$SPOOL" ]; then
	sqlite3 $DB "$SQL;" > $SPOOL
fi

cat <<_EOT_
var metadata = {
	"date": "$date",
	"time": "$time",
	"direction": "$direction"
}

var data = [];
data[0] = [ 'Stop' ];
_EOT_

stops=$(cut -d'|' -f2 $SPOOL |sort -fun|tail -1)
stop=1
while [ $stop -le $stops ]; do
	echo "data[$stop] = [];"
	stop=$(( stop + 1 ))
done

last_trip_id=
trip_offset=0
while IFS='|' read trip_id stop_sequence scheduled_arrival_time expected_arrival_time arrival_delay scheduled_departure_time expected_departure_time departure_delay; do

	if [ "$trip_id" != "$last_trip_id" ]; then
		last_trip_id=$trip_id
		trip_offset=$(( trip_offset + 1 ))
		echo "data[0][$trip_offset]='$trip_id';"
	fi
	if [ -z "$arrival_delay" ]; then
		arrival_delay=0
	fi
	year=${date%%-*}
	month=${date%-*}
	month=${month#*-}
	month=${month##0}
	day=${date##*-}
	day=${day##0}
	hour=${expected_departure_time%%:*}
	hour=${hour##0}
	minute=${expected_departure_time#*:}
	minute=${minute##0}
	if [ -z "$minute" ]; then
		continue
	fi
	echo "data[$stop_sequence][$trip_offset]=new Date($year, $month, $day, $hour, $minute);"

done < $SPOOL
echo


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

SPOOL=$TMP/$$

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
	#echo $SQL
	sqlite3 $DB "$SQL;" > $SPOOL
fi

stops=$(cut -d'|' -f2 $SPOOL |sort -fun|tail -1)
if [ -z "$stops" ]; then
	rm $SPOOL
	exit
fi

cat <<_EOT_
var metadata = {
	"date": "$date",
	"time": "$time",
	"direction": "$direction",
	"trips": []
}

var data = [];
_EOT_

stop=0
while [ $stop -lt $stops ]; do
	echo "data[$stop] = [];"
	stop=$(( stop + 1 ))
done

last_trip_id=
trip_offset=-2
while IFS='|' read trip_id stop_sequence scheduled_arrival_time expected_arrival_time arrival_delay scheduled_departure_time expected_departure_time departure_delay; do

	if [ "$trip_id" != "$last_trip_id" ]; then
		last_trip_id=$trip_id
		trip_offset=$(( trip_offset + 2 ))
		echo "metadata.trips[$trip_offset]='$trip_id';"
		echo "metadata.trips[$(( trip_offset + 1 ))]='$trip_id';"
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

	scheduled_hour=${scheduled_departure_time%%:*}
	scheduled_hour=${scheduled_hour##0}
	scheduled_minute=${scheduled_departure_time#*:}
	scheduled_minute=${scheduled_minute%:*}
	scheduled_minute=${scheduled_minute##0}

	expected_hour=${expected_departure_time%%:*}
	expected_hour=${expected_hour##0}
	expected_minute=${expected_departure_time#*:}
	expected_minute=${expected_minute##0}

	if [ -z "$expected_minute" ]; then
		continue
	fi
	stopId=$(( stop_sequence - 1 ))
	echo "data[$stopId][$trip_offset]=new Date($year, $(( month - 1 )), $day, $(( expected_hour - 1 )), $expected_minute);"
	echo "data[$stopId][$(( trip_offset + 1 ))]=createTooltip(new Date($year, $(( month - 1 )), $day, $(( scheduled_hour - 1 )), $scheduled_minute), $stopId, $trip_offset);"

done < $SPOOL
echo

rm $SPOOL


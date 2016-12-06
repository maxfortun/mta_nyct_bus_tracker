#!/usr/local/bin/bash
cd $(dirname $0)

. setenv.sh
# (strftime('%s','$stopExpectedArrival') - strftime('%s',departure_time)) / 60

read -r -d '' SQL << _EOT_
select
	a.date,
	a.direction_id,
	a.trip_id,
	vehicle_id,
	a.activity_time,
	s.stop_name||'['||a.stop_id||']',
	st.stop_sequence,
	a.proximity,
	st.arrival_time,
	a.arrival_time,
	st.departure_time,
	a.departure_time,
	a.measurements 
from
	activity a,
	stops s,
	stop_times st
where s.stop_id = a.stop_id
and st.stop_id = a.stop_id
and st.trip_id = a.trip_id
order by a.date, a.direction_id, a.activity_time, a.stop_id 
_EOT_

sqlite3 $DB "$SQL;"


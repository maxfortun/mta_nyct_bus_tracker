#!/usr/local/bin/bash
cd $(dirname $0)

. setenv.sh

sqlite3 $DB "select a.date, a.direction_id, a.trip_id, s.stop_name||'['||a.stop_id||']', a.departure_time, a.approach_time, a.proximity, a.delay, a.measurements from activity a, stops s where s.stop_id=a.stop_id order by a.date, a.direction_id, a.stop_id, a.approach_time;"


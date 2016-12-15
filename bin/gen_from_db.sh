#!/usr/local/bin/bash
cd $(dirname $0)

. setenv.sh

SPOOL=$TMP/$$

SQL="select distinct date,substr(activity_time,1,2),direction_id from activity"

sqlite3 $DB "$SQL;" > $SPOOL

while IFS='|' read date hour direction; do
	show_times_within_an_hour.sh $direction $date $hour:00 > /home/max/public_html/bustime/$date-$hour-$direction.js
done < $SPOOL

rm $SPOOL


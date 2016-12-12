#!/usr/local/bin/bash
cd $(dirname $0)

line=$1

if [ -z "$line" ]; then
	echo "Usage: $0 <line>"
	echo "e.g.: $0 M14A"
	exit
fi

. setenv.sh $line

[ ! -d "$TMP" ] && mkdir $TMP

while [ true ]; do

echo "$(date +'%Y-%m-%d %H:%M:%S') Monitoring $line"
./get_line.sh $line | python -m json.tool > $TMP/$line.json

egrep 'ValidUntil|MonitoredVehicleJourney|VehicleRef|DirectionRef|DatedVehicleJourneyRef|DestinationRef|StopPointRef|OriginRef|ExpectedArrivalTime|ExpectedDepartureTime|DataFrameRef|ArrivalProximityText' $TMP/$line.json|sed -e 's/["{,:]*//g' -e 's/^[ ]*//g' > $TMP/$line.line

function printEntry {
	[ -z "$stopId" ] && return

	now=$(date +'%H:%M:%S')

	if [ -n "$stopExpectedArrival" ]; then
		update_arrival="UPDATE OR IGNORE ACTIVITY SET activity_time='$now', proximity='$arrivalProximityText', arrival_time='$stopExpectedArrival', measurements=measurements+1 WHERE date='$date' AND trip_id='$tripId' AND stop_id=$stopId AND proximity <> 'at stop'" 
		echo $update_arrival
		sqlite3 $DB "$update_arrival;" 
	fi

	if [ -n "$stopExpectedDeparture" ]; then
		update_departure="UPDATE OR IGNORE ACTIVITY SET activity_time='$now', proximity='$arrivalProximityText', departure_time='$stopExpectedDeparture', measurements=measurements+1 WHERE date='$date' AND trip_id='$tripId' AND stop_id=$stopId AND proximity = 'at stop'" 
		echo $update_departure
		sqlite3 $DB "$update_departure;" 
	fi

	insert="INSERT OR IGNORE INTO ACTIVITY(date, trip_id, vehicle_id, direction_id, stop_id, activity_time, proximity, arrival_time, departure_time, measurements) VALUES('$date', '$tripId', $vehicleId, $directionId, $stopId, '$now', '$arrivalProximityText', '$stopExpectedArrival', '$stopExpectedDeparture', 1)"
	echo $insert
	sqlite3 $DB "$insert;" 
}

while read key value; do
	case $key in
		ValidUntil)
			validUntil=$value
			;;
		MonitoredVehicleJourney)
			printEntry
			vehicleId=
			tripId=
			stopId=
			directionId=
			stopExpectedArrival=
			stopExpectedDeparture=
			toId=
			originId=
			arrivalProximityText=
			;;
		DatedVehicleJourneyRef)
			tripId=${value##${operatorRef}_}
			;;
		DirectionRef)
			directionId=$value
			;;
		DestinationRef)
			toId=${value##${agency}_}
			;;
		StopPointRef)
			stopId=${value##${agency}_}
			;;
		OriginRef)
			originId=${value##${agency}_}
			;;
		ExpectedArrivalTime)
			stopExpectedArrival=${value##${date}T}
			stopExpectedArrival=${stopExpectedArrival%.*}
			stopExpectedArrival=${stopExpectedArrival:0:2}:${stopExpectedArrival:2:2}
			;;
		ExpectedDepartureTime)
			stopExpectedDeparture=${value##${date}T}
			stopExpectedDeparture=${stopExpectedDeparture%.*}
			stopExpectedDeparture=${stopExpectedDeparture:0:2}:${stopExpectedDeparture:2:2}
			;;
		DataFrameRef)
			date=$value
			;;
		VehicleRef)
			vehicleId=${value##${operatorRef}_}
			;;
		ArrivalProximityText)
			arrivalProximityText=$value
			;;
		*)
			echo "Unknown key: $key"
			;;
	esac
done < $TMP/$line.line
printEntry

hour=$(date +%H)

./show_times_within_an_hour.sh $directionId $date $hour:00 > ~/public_html/bustime/$date-$hour-$directionId.js.tmp
mv ~/public_html/bustime/$date-$hour-$directionId.js.tmp ~/public_html/bustime/$date-$hour-$directionId.js

waitTill=${validUntil%.*}
waitTill=${waitTill//-/}
waitTill=${waitTill//T/}
waitTill=${waitTill:0:12}.${waitTill:12}
waitTill=$(date -j +%s $waitTill)
now=$(date +%s)
sleep=$(( waitTill - now ))
if [ "$sleep" -gt 0 ]; then
	echo "$(date +'%Y-%m-%d %H:%M:%S') sleeping for $sleep"
	sleep $sleep
fi

done



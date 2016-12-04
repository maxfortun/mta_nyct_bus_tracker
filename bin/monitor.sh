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

	stopExpectedArrivalHours=${stopExpectedArrival%:*}
	stopExpectedArrivalHours=${stopExpectedArrivalHours##0}
	stopExpectedArrivalMinutes=${stopExpectedArrival#*:}
	stopExpectedArrivalMinutes=${stopExpectedArrivalMinutes##0}
	stopExpectedArrivalMinutes=$(( stopExpectedArrivalHours * 60 + stopExpectedArrivalMinutes))

	[ "$stopExpectedArrivalMinutes" = "0" ] && return

	now=$(date +'%H:%M:%S')
	insert="INSERT OR IGNORE INTO ACTIVITY(date, trip_id, vehicle_id, direction_id, stop_id, departure_time, approach_time, proximity, expected_time, delay, measurements) SELECT '$date', '$tripId', $vehicleId, $directionId, $stopId, departure_time, '$now', '$arrivalProximityText', '$stopExpectedArrival', (strftime('%s','$stopExpectedArrival') - strftime('%s',departure_time)) / 60, 1 FROM stop_times where trip_id='$tripId' AND stop_id=$stopId"

	update="UPDATE OR IGNORE ACTIVITY SET approach_time='$now', proximity='$arrivalProximityText', expected_time='$stopExpectedArrival', delay=(strftime('%s','$stopExp
ectedArrival') - strftime('%s',departure_time)) / 60, measurements=measurements+1 WHERE date='$date' AND trip_id='$tripId' AND stop_id=$stopId AND proximity <> 'at stop'" 

	echo $update
	echo $insert
	sqlite3 $DB "$update;" 
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



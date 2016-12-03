# MTA NYCT Bus Tracker
## GTFS
* Get MTA Bus Time developer key by following instructions (http://bustime.mta.info/wiki/Developers/Index)
* Write that key into bin/setenv-private.sh 
  export MTA_BUS_TIME_API_KEY=your-key-here
* Get MTA GTFS feed from (http://web.mta.info/developers/developer-data-terms.html#data) into Downloads
* mkdir GTFS and unzip downloaded file there
* Create sqlite gtfs db: sqlite3 db/gtfs.db < db/gtfs.sql 
* Create sqlite tracker db: sqlite3 db/tracker.db < db/tracker.sql


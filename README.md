# MTA NYCT Bus Tracker
## GTFS
* Get MTA Bus Time developer key by following instructions (http://bustime.mta.info/wiki/Developers/Index)
* Write that key into bin/setenv-private.sh  
  export key=your-api-key-here
* git update-index --assume-unchanged bin/setenv-private.sh 
* Get MTA GTFS feed from (http://web.mta.info/developers/developer-data-terms.html#data) into Downloads
* mkdir GTFS and unzip downloaded file there
* Create sqlite gtfs db: sqlite3 db/gtfs.db < db/gtfs.sql 
* Create sqlite tracker db: sqlite3 db/tracker.db < db/tracker.sql


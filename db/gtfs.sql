create table agency(
	agency_id		TEXT,
	agency_name		TEXT,
	agency_url		TEXT,
	agency_timezone	TEXT,
	agency_lang		TEXT,
	agency_phone	TEXT,
	primary key (agency_id)
);

create table calendar_dates(
	service_id TEXT,
	date NUMERIC,
	exception_type NUMERIC,
	primary key (service_id, date)
);

create table routes(
	route_id TEXT,
	agency_id TEXT,
	route_short_name TEXT,
	route_long_name TEXT,
	route_desc TEXT,
	route_type NUMERIC,
	route_url TEXT,
	route_color TEXT,
	route_text_color TEXT,
	primary key (route_id)
);

create table stops(
	stop_id TEXT,
	stop_name TEXT,
	stop_desc TEXT,
	stop_lat REAL,
	stop_lon REAL,
	zone_id NUMERIC,
	stop_url TEXT,
	location_type TEXT,
	parent_station NUMERIC,
	primary key (stop_id)
);

create table stop_times(
	trip_id TEXT,
	arrival_time TEXT,
	departure_time TEXT,
	stop_id TEXT,
	stop_sequence NUMERIC,
	pickup_type NUMERIC,
	drop_off_type NUMERIC,
	primary key (trip_id, stop_id)
);

create table trips(
	route_id TEXT,
	service_id TEXT,
	trip_id TEXT,
	trip_headsign TEXT,
	direction_id NUMERIC,
	shape_id TEXT,
	primary key (trip_id)
);

.separator ','

.import GTFS/agency.txt agency
.import GTFS/calendar_dates.txt calendar_dates
.import GTFS/routes.txt routes
.import GTFS/stops.txt stops
.import GTFS/stop_times.txt stop_times
.import GTFS/trips.txt trips

delete from agency where agency_id like 'agency_id';
delete from calendar_dates where service_id like 'service_id';
delete from routes where route_id like 'route_id';
delete from stops where stop_id like 'stop_id';
delete from stop_times where trip_id like 'trip_id';
delete from trips where route_id like 'route_id';


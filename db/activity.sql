create table activity (
	date			TEXT	NOT NULL,
	trip_id			TEXT	NOT NULL,
	vehicle_id		INT	 	NOT NULL,
	direction_id	INT	 	NOT NULL,
	stop_id			INT	 	NOT NULL,
	departure_time	TEXT 	NOT NULL,
	approach_time	TEXT 	NOT NULL,
	proximity		TEXT	NOT NULL,
	expected_time	TEXT 	NOT NULL,
	delay			INT	 	NOT NULL,
	measurements	INT	 	NOT NULL,
	primary key (date, trip_id, stop_id)
);


create table trips (
	date			TEXT	NOT NULL,
	trip_id			TEXT	NOT NULL,
	vehicle_id		INT	 	NOT NULL,
	direction_id	INT	 	NOT NULL,
	stop_id			INT	 	NOT NULL,
	departure_time	INT	 	NOT NULL,
	approach_time	INT	 	NOT NULL,
	proximity		TEXT	NOT NULL,
	expected_time	INT	 	NOT NULL,
	delay			INT	 	NOT NULL,
	measurements	INT	 	NOT NULL,
	primary key (date, trip_id, stop_id)
);


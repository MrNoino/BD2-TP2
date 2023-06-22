CREATE OR REPLACE FUNCTION verify_system_inactivity(IN a_system_id int)
RETURNS VOID
LANGUAGE PLPGSQL
AS $$
DECLARE

    sensor_history_row "SensorHistory"%ROWTYPE;

    inactivity_seconds numeric;

    inter interval;
	
	exist boolean := False;

    c CURSOR FOR SELECT "SensorHistory".* 
                            FROM public."SensorHistory"
                            INNER JOIN public."Sensor"
                            ON "Sensor".id = "SensorHistory".sensor_id
                            INNER JOIN public."System"
                            ON "System".id = "Sensor".system_id
                            WHERE "System".id = a_system_id;

BEGIN

	OPEN c;

  	LOOP

		FETCH c INTO sensor_history_row;
		EXIT WHEN NOT FOUND;

		inactivity_seconds = (SELECT "Sensor".inactivity_seconds 
			FROM public."Sensor" 
			INNER JOIN public."SensorHistory" 
			ON "SensorHistory".sensor_id = "Sensor".id 
			WHERE "SensorHistory".id = sensor_history_row.id);

		inter := (current_timestamp - sensor_history_row.received_datetime AT TIME ZONE 'UTC');

		IF inter <= MAKE_INTERVAL(secs => inactivity_seconds::integer) THEN

			exist := True;
			EXIT;

		END IF;
  
  	END LOOP;
  	CLOSE c;
  
  	IF NOT exist THEN
  
  		CALL raise_exception('503', 'SERVICE UNAVAILABLE', ('Inactivity detect on system ' || a_system_id));

	END IF;

END;

$$;
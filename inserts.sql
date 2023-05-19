DO $$

DECLARE

    i integer;
    id1 integer;
    id2 integer;
	ts timestamp;

BEGIN

    FOR i IN 1..100 LOOP
        
        /*CALL user_insert(right(md5(random()::text), 10));*/

        /*CALL sensor_type_insert(right(md5(random()::text), 10));*/
    
    END LOOP;

    /*FOR i IN 1..100 LOOP
        
        id1 = (SELECT "User".id FROM public."User" ORDER BY random() LIMIT 1);
        CALL system_insert(right(md5(random()::text), 10), right(md5(random()::text), 10), id1);

    END LOOP;*/

    FOR i IN 1..100 LOOP
        
        /*id1 = (SELECT "System".id FROM public."System" ORDER BY random() LIMIT 1);
        CALL actuator_insert(id1, (random() * 10000)::numeric(7));*/

        /*id1 = (SELECT "System".id FROM public."System" ORDER BY random() LIMIT 1);
        id2 = (SELECT "SensorType".id FROM public."SensorType" ORDER BY random() LIMIT 1);
        CALL sensor_insert(id2, id1, (random() * 10000)::numeric(7));*/

    END LOOP;
	
	FOR i IN 1..100 LOOP
        
        /*id1 = (SELECT "Actuator".id FROM public."Actuator" ORDER BY random() LIMIT 1);
		ts = (SELECT TIMESTAMP '2000-01-01' + (random() * (TIMESTAMP '2023-05-09' - TIMESTAMP '2000-01-01')));
        CALL actuator_history_insert(id1, ts, right(md5(random()::text), 5));*/

    END LOOP;

END $$;
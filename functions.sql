CREATE OR REPLACE FUNCTION system_select(IN a_user_id int, IN a_id int)
RETURNS TABLE(id int, location varchar(256), property varchar(256), owner_id int)
LANGUAGE PLPGSQL
AS $$
BEGIN

    RETURN QUERY SELECT "System".* 
            FROM public."System"
            LEFT JOIN public."SystemUser"
            ON "SystemUser".system_id = "System".id
            WHERE "System".id = a_id and ("System".owner_id = a_user_id OR "SystemUser".user_id = a_user_id);

END;
$$;

CREATE OR REPLACE FUNCTION system_select(IN a_user_id int)
RETURNS TABLE(id int, location varchar(256), property varchar(256), owner_id int)
LANGUAGE PLPGSQL
AS $$
BEGIN

    RETURN QUERY SELECT "System".* 
            FROM public."System"
            LEFT JOIN public."SystemUser"
            ON "SystemUser".system_id = "System".id
            WHERE "System".owner_id = a_user_id OR "SystemUser".user_id = a_user_id;

END;
$$;

CREATE OR REPLACE FUNCTION system_view(IN a_user_id int, IN a_id int)
RETURNS TABLE(id int, location varchar(256), property varchar(256), owner_id int)
LANGUAGE PLPGSQL
AS $$
BEGIN

    IF a_user_id IS NULL OR a_id IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    IF (SELECT COUNT(*)
            FROM system_select(a_user_id, a_id)) = 0 THEN

        CALL raise_exception('403', 'FORBIDDEN', 'Don''t have permissions');

    END IF; 

    RETURN QUERY SELECT * 
            FROM system_select(a_user_id, a_id);

END;
$$;

CREATE OR REPLACE FUNCTION system_view(IN a_user_id int)
RETURNS TABLE(id int, location varchar(256), property varchar(256), owner_id int)
LANGUAGE PLPGSQL
AS $$
BEGIN 

    IF a_user_id IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    IF (SELECT COUNT(*)
            FROM system_select(a_user_id)) = 0 THEN

        CALL raise_exception('403', 'FORBIDDEN', 'Don''t have permissions');

    END IF;

    RETURN QUERY SELECT * 
            FROM system_select(a_user_id);

END;
$$;

CREATE OR REPLACE FUNCTION sensor_view(IN a_user_id int)
RETURNS TABLE(id int, sensor_type_id int, system_id int, inactivity_seconds numeric)
LANGUAGE PLPGSQL
AS $$
BEGIN

    IF a_user_id IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    RETURN QUERY SELECT "Sensor".* 
            FROM public."Sensor"
            INNER JOIN public."System"
            ON "System".id = "Sensor".system_id
            LEFT JOIN public."SystemUser"
            ON "SystemUser".system_id = "System".id
            WHERE "System".owner_id = a_user_id OR "SystemUser".user_id = a_user_id;

END;
$$;

CREATE OR REPLACE FUNCTION sensor_select(IN a_user_id int, IN a_id int)
RETURNS TABLE(id int, sensor_type_id int, system_id int, inactivity_seconds numeric)
LANGUAGE PLPGSQL
AS $$
BEGIN

    RETURN QUERY SELECT "Sensor".* 
            FROM public."Sensor"
            INNER JOIN public."System"
            ON "System".id = "Sensor".system_id
            LEFT JOIN public."SystemUser"
            ON "SystemUser".system_id = "System".id
            WHERE "Sensor".id = a_id and ("System".owner_id = a_user_id OR "SystemUser".user_id = a_user_id);

END;
$$;

CREATE OR REPLACE FUNCTION sensor_view(IN a_user_id int, IN a_id int)
RETURNS TABLE(id int, sensor_type_id int, system_id int, inactivity_seconds numeric)
LANGUAGE PLPGSQL
AS $$
BEGIN

    IF a_user_id IS NULL OR a_id IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    IF (SELECT COUNT(*)
            FROM sensor_view sv
            WHERE sv.id = a_id) = 0 THEN

        CALL raise_exception('404', 'NOT FOUND', 'Doesn''t exist');
		
	END IF;

    IF (SELECT COUNT(*)
            FROM sensor_select(a_user_id, a_id)) = 0 THEN

        CALL raise_exception('403', 'FORBIDDEN', 'Don''t have permissions');

    END IF;

    RETURN QUERY SELECT * 
            FROM sensor_select(a_user_id, a_id);

END;
$$;

CREATE OR REPLACE FUNCTION sensor_type_view(IN a_id int)
RETURNS TABLE(id int, type varchar)
LANGUAGE PLPGSQL
AS $$
BEGIN

    IF a_id IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    RETURN QUERY SELECT * 
            FROM public."SensorType"
            WHERE "SensorType".id = a_id;

END;
$$;

CREATE OR REPLACE FUNCTION sensor_history_view(IN a_user_id int)
RETURNS TABLE(id int, sensor_id int, received_datetime timestamp with time zone, value varchar(256))
LANGUAGE PLPGSQL
AS $$
BEGIN

    IF a_user_id IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    RETURN QUERY SELECT "SensorHistory".* 
            FROM public."SensorHistory"
            INNER JOIN public."Sensor"
            ON "Sensor".id = "SensorHistory".sensor_id
            INNER JOIN public."System"
            ON "System".id = "Sensor".system_id
            LEFT JOIN public."SystemUser"
            ON "SystemUser".system_id = "System".id
            WHERE "System".owner_id = a_user_id OR "SystemUser".user_id = a_user_id;

END;
$$;

CREATE OR REPLACE FUNCTION sensor_history_select(IN a_user_id int, IN a_id int)
RETURNS TABLE(id int, sensor_id int, received_datetime timestamp with time zone, value varchar(256))
LANGUAGE PLPGSQL
AS $$
BEGIN

    RETURN QUERY SELECT "SensorHistory".* 
            FROM public."SensorHistory"
            INNER JOIN public."Sensor"
            ON "Sensor".id = "SensorHistory".sensor_id
            INNER JOIN public."System"
            ON "System".id = "Sensor".system_id
            LEFT JOIN public."SystemUser"
            ON "SystemUser".system_id = "System".id
            WHERE "SensorHistory".id = a_id and ("System".owner_id = a_user_id OR "SystemUser".user_id = a_user_id);

END;
$$;

CREATE OR REPLACE FUNCTION sensor_history_view(IN a_user_id int, IN a_id int)
RETURNS TABLE(id int, sensor_id int, received_datetime timestamp with time zone, value varchar(256))
LANGUAGE PLPGSQL
AS $$
BEGIN

    IF a_user_id IS NULL OR a_id IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    IF (SELECT COUNT(*)
            FROM sensor_history_select(a_user_id, a_id)) = 0 THEN

        CALL raise_exception('403', 'FORBIDDEN', 'Don''t have permissions');

    END IF;

    RETURN QUERY SELECT * 
            FROM sensor_history_select(a_user_id, a_id);

END;
$$;

CREATE OR REPLACE FUNCTION actuator_view(IN a_user_id int)
RETURNS TABLE(id int, system_id int)
LANGUAGE PLPGSQL
AS $$
BEGIN

    IF a_user_id IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    RETURN QUERY SELECT "Actuator".* 
            FROM public."Actuator"
            INNER JOIN public."System"
            ON "System".id = "Actuator".system_id
            LEFT JOIN public."SystemUser"
            ON "SystemUser".system_id = "System".id
            WHERE "System".owner_id = a_user_id OR "SystemUser".user_id = a_user_id;

END;
$$;

CREATE OR REPLACE FUNCTION actuator_select(IN a_user_id int, IN a_id int)
RETURNS TABLE(id int, system_id int)
LANGUAGE PLPGSQL
AS $$
BEGIN

    RETURN QUERY SELECT "Actuator".* 
            FROM public."Actuator"
            INNER JOIN public."System"
            ON "System".id = "Actuator".system_id
            LEFT JOIN public."SystemUser"
            ON "SystemUser".system_id = "System".id
            WHERE "Actuator".id = a_id and ("System".owner_id = a_user_id OR "SystemUser".user_id = a_user_id);

END;
$$;

CREATE OR REPLACE FUNCTION actuator_view(IN a_user_id int, IN a_id int)
RETURNS TABLE(id int, system_id int)
LANGUAGE PLPGSQL
AS $$
BEGIN

    IF a_user_id IS NULL OR a_id IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    IF (SELECT COUNT(*)
            FROM actuator_select(a_user_id, a_id)) = 0 THEN

        CALL raise_exception('403', 'FORBIDDEN', 'Don''t have permissions');

    END IF;

    RETURN QUERY SELECT * 
            FROM actuator_select(a_user_id, a_id);

END;
$$;

CREATE OR REPLACE FUNCTION actuator_history_view(IN a_user_id int)
RETURNS TABLE(id int, actuator_id int, action_datetime timestamp with time zone, action varchar(64))
LANGUAGE PLPGSQL
AS $$
BEGIN

    IF a_user_id IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    RETURN QUERY SELECT "ActuatorHistory".* 
            FROM public."ActuatorHistory"
            INNER JOIN public."Actuator"
            ON "Actuator".id = "ActuatorHistory".actuator_id
            INNER JOIN public."System"
            ON "System".id = "Actuator".system_id
            LEFT JOIN public."SystemUser"
            ON "SystemUser".system_id = "System".id
            WHERE "System".owner_id = a_user_id OR "SystemUser".user_id = a_user_id;

END;
$$;

CREATE OR REPLACE FUNCTION actuator_history_select(IN a_user_id int, IN a_id int)
RETURNS TABLE(id int, actuator_id int, action_datetime timestamp with time zone, action varchar(64))
LANGUAGE PLPGSQL
AS $$
BEGIN

    RETURN QUERY SELECT "ActuatorHistory".* 
            FROM public."ActuatorHistory"
            INNER JOIN public."Actuator"
            ON "Actuator".id = "ActuatorHistory".actuator_id
            INNER JOIN public."System"
            ON "System".id = "Actuator".system_id
            LEFT JOIN public."SystemUser"
            ON "SystemUser".system_id = "System".id
            WHERE "ActuatorHistory".id = a_id and ("System".owner_id = a_user_id OR "SystemUser".user_id = a_user_id);

END;
$$;

CREATE OR REPLACE FUNCTION actuator_history_view(IN a_user_id int, IN a_id int)
RETURNS TABLE(id int, actuator_id int, action_datetime timestamp with time zone, action varchar(64))
LANGUAGE PLPGSQL
AS $$
BEGIN

    IF a_user_id IS NULL OR a_id IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    IF (SELECT COUNT(*)
            FROM actuator_history_select(a_user_id, a_id)) = 0 THEN

        CALL raise_exception('403', 'FORBIDDEN', 'Don''t have permissions');

    END IF;

    RETURN QUERY SELECT * 
            FROM actuator_history_select(a_user_id, a_id);

END;
$$;

CREATE OR REPLACE FUNCTION alert_view(IN a_user_id int)
RETURNS TABLE(id int, sensor_id int, rule_id int, value varchar(256), alert varchar(256))
LANGUAGE PLPGSQL
AS $$
BEGIN 

    IF a_user_id IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    RETURN QUERY SELECT "Alert".* 
            FROM public."Alert"
            INNER JOIN public."Sensor"
            ON "Sensor".id = "Alert".sensor_id
            INNER JOIN public."System"
            ON "System".id = "Sensor".system_id
            LEFT JOIN public."SystemUser"
            ON "SystemUser".system_id = "System".id
            WHERE "System".owner_id = a_user_id OR "SystemUser".user_id = a_user_id;

END;
$$;

CREATE OR REPLACE FUNCTION alert_select(IN a_user_id int, IN a_id int)
RETURNS TABLE(id int, sensor_id int, rule_id int, value varchar(256), alert varchar(256))
LANGUAGE PLPGSQL
AS $$
BEGIN 

    RETURN QUERY SELECT "Alert".* 
            FROM public."Alert"
            INNER JOIN public."Sensor"
            ON "Sensor".id = "Alert".sensor_id
            INNER JOIN public."System"
            ON "System".id = "Sensor".system_id
            LEFT JOIN public."SystemUser"
            ON "SystemUser".system_id = "System".id
            WHERE "Alert".id = a_id and ("System".owner_id = a_user_id OR "SystemUser".user_id = a_user_id);

END;
$$;

CREATE OR REPLACE FUNCTION alert_view(IN a_user_id int, IN a_id int)
RETURNS TABLE(id int, sensor_id int, rule_id int, value varchar(256), alert varchar(256))
LANGUAGE PLPGSQL
AS $$
BEGIN

    IF a_user_id IS NULL OR a_id IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    IF (SELECT COUNT(*)
            FROM alert_select(a_user_id, a_id)) = 0 THEN

        CALL raise_exception('403', 'FORBIDDEN', 'Don''t have permissions');

    END IF;

    RETURN QUERY SELECT * 
            FROM alert_select(a_user_id, a_id);

END;
$$;

CREATE OR REPLACE FUNCTION rule_view(IN a_id int)
RETURNS TABLE(id int, rule varchar(16), description varchar(256))
LANGUAGE PLPGSQL
AS $$
BEGIN

    IF a_id IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    RETURN QUERY SELECT "Rule".* 
            FROM public."Rule"
            WHERE "Rule".id = a_id;

END;
$$;

CREATE OR REPLACE FUNCTION alert_actuator_select(IN a_user_id int, IN a_alert_id int, IN a_actuator_id int)
RETURNS TABLE(alert_id int, actuator_id int, action varchar(256))
LANGUAGE PLPGSQL
AS $$
BEGIN 

    RETURN QUERY SELECT "AlertActuator".* 
            FROM public."AlertActuator"
            INNER JOIN public."Alert"
            ON "Alert".id = "AlertActuator".alert_id
            INNER JOIN public."Sensor"
            ON "Sensor".id = "Alert".sensor_id
            INNER JOIN public."System"
            ON "System".id = "Sensor".system_id
            LEFT JOIN public."SystemUser"
            ON "SystemUser".system_id = "System".id
            WHERE "AlertActuator".alert_id = a_alert_id and "AlertActuator".actuator_id = a_actuator_id  and ("System".owner_id = a_user_id OR "SystemUser".user_id = a_user_id);

END;
$$;

CREATE OR REPLACE FUNCTION alert_actuator_view(IN a_user_id int, IN a_alert_id int DEFAULT NULL, IN a_actuator_id int DEFAULT NULL)
RETURNS TABLE(alert_id int, actuator_id int, action varchar(256))
LANGUAGE PLPGSQL
AS $$
BEGIN 

    IF a_user_id IS NULL OR a_alert_id IS NULL OR a_actuator_id IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    IF (SELECT COUNT(*)
            FROM public."AlertActuator"
            WHERE "AlertActuator".alert_id = a_alert_id and "AlertActuator".actuator_id = a_actuator_id) = 0 THEN

        CALL raise_exception('404', 'NOT FOUND', 'Doesn''t exist');

    END IF;

    IF (SELECT COUNT(*)
            FROM alert_actuator_select(a_user_id, a_alert_id, a_actuator_id)) = 0 THEN

        CALL raise_exception('403', 'FORBIDDEN', 'Don''t have permissions');

    END IF;

    RETURN QUERY SELECT * 
            FROM alert_actuator_select(a_user_id, a_alert_id, a_actuator_id);

END;
$$;

CREATE OR REPLACE FUNCTION user_view(IN a_id int)
RETURNS TABLE(id int, name varchar(256), email varchar(256))
LANGUAGE PLPGSQL
AS $$
BEGIN

    IF a_id IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    RETURN QUERY SELECT "User".id, "User".name, "User".email
            FROM public."User"
            WHERE "User".id = a_id;

END;
$$;

CREATE OR REPLACE FUNCTION user_select(IN a_user_id int, IN a_id int)
RETURNS TABLE(id int, name varchar(256), email varchar(256))
LANGUAGE PLPGSQL
AS $$
BEGIN 

    RETURN QUERY SELECT "User".id, "User".name, "User".email
            FROM public."User"
            INNER JOIN public."SystemUser"
            ON "SystemUser".user_id = "User".id
            LEFT JOIN public."System"
            ON "System".id = "SystemUser".system_id
            WHERE "User".id = a_id and ("System".owner_id = a_user_id OR "SystemUser".user_id = a_user_id);

END;
$$;

CREATE OR REPLACE FUNCTION user_view(IN a_user_id int, IN a_id int)
RETURNS TABLE(id int, name varchar(256), email varchar(256))
LANGUAGE PLPGSQL
AS $$
BEGIN

    IF a_user_id IS NULL OR a_id IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    IF (SELECT COUNT(*)
            FROM user_select(a_user_id, a_id)) = 0 THEN

        CALL raise_exception('403', 'FORBIDDEN', 'Don''t have permissions');

    END IF;

    RETURN QUERY SELECT *
            FROM user_select(a_user_id, a_id);

END;
$$;

CREATE OR REPLACE FUNCTION login(IN a_email varchar(256), IN a_password varchar(256))
RETURNS TABLE(id int, name varchar(256), email varchar(256))
LANGUAGE PLPGSQL
AS $$
BEGIN

    IF a_email IS NULL OR a_password IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    RETURN QUERY SELECT "User".id, "User".name, "User".email 
            FROM public."User"
            WHERE "User".email = a_email and "User".password = crypt(a_password, "User".password);

END;
$$;

CREATE OR REPLACE FUNCTION system_user_select(IN a_owner_id int)
RETURNS TABLE(system_id int, user_id int)
LANGUAGE PLPGSQL
AS $$
BEGIN 

    RETURN QUERY SELECT "SystemUser".* 
            FROM public."SystemUser"
            INNER JOIN public."System"
            ON "System".id = "SystemUser".system_id
            WHERE "System".owner_id = a_owner_id;

END;
$$;

CREATE OR REPLACE FUNCTION system_user_view(IN a_owner_id int)
RETURNS TABLE(system_id int, user_id int)
LANGUAGE PLPGSQL
AS $$
BEGIN

    IF a_owner_id IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    IF (SELECT COUNT(*)
            FROM public."System"
            WHERE "System".owner_id = a_owner_id) = 0 THEN

        CALL raise_exception('403', 'FORBIDDEN', 'Don''t have permissions');

    END IF;

    IF (SELECT COUNT(*)
            FROM system_user_select(a_owner_id)) = 0 THEN

        CALL raise_exception('404', 'NOT FOUND', 'Doesn''t exist');

    END IF;

    RETURN QUERY SELECT *
            FROM system_user_select(a_owner_id);

END;
$$;

CREATE OR REPLACE FUNCTION system_user_select(IN a_system_id int, IN a_user_id int)
RETURNS TABLE(system_id int, user_id int)
LANGUAGE PLPGSQL
AS $$
BEGIN 

    RETURN QUERY SELECT "SystemUser".* 
            FROM public."SystemUser"
            WHERE "SystemUser".system_id = a_system_id and "SystemUser".user_id = a_user_id;

END;
$$;

CREATE OR REPLACE FUNCTION system_user_view(IN a_system_id int, IN a_user_id int)
RETURNS TABLE(system_id int, user_id int)
LANGUAGE PLPGSQL
AS $$
BEGIN

    IF a_system_id IS NULL OR a_user_id IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    IF (SELECT COUNT(*)
            FROM system_user_select(a_system_id, a_user_id)) = 0 THEN

        CALL raise_exception('404', 'NOT FOUND', 'Doesn''t exist');

    END IF;

    RETURN QUERY SELECT *
            FROM system_user_select(a_system_id, a_user_id);

END;
$$;

CREATE OR REPLACE FUNCTION alert_user_view(IN a_user_id int)
RETURNS TABLE(alert_history_id int, user_id int, see_datetime timestamp with time zone)
LANGUAGE PLPGSQL
AS $$
BEGIN

    IF a_user_id IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    RETURN QUERY SELECT * 
            FROM public."AlertUser"
            WHERE "AlertUser".user_id = a_user_id;

END;
$$;

CREATE OR REPLACE FUNCTION alert_user_view(IN a_alert_history_id int, IN a_user_id int)
RETURNS TABLE(alert_history_id int, user_id int, see_datetime timestamp with time zone)
LANGUAGE PLPGSQL
AS $$
BEGIN

    IF a_alert_history_id IS NULL OR a_user_id IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    RETURN QUERY SELECT * 
            FROM public."AlertUser"
            WHERE "AlertUser".alert_history_id = a_alert_history_id and "AlertUser".user_id = a_user_id;

END;
$$;

CREATE OR REPLACE FUNCTION alert_history_view(IN a_user_id int)
RETURNS TABLE(id int, alert_id int, alert_datetime timestamp with time zone)
LANGUAGE PLPGSQL
AS $$
BEGIN

    IF a_user_id IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    RETURN QUERY SELECT "AlertHistory".* 
            FROM public."AlertHistory"
            INNER JOIN public."Alert"
            ON "Alert".id = "AlertHistory".alert_id
            INNER JOIN public."Sensor"
            ON "Sensor".id = "Alert".sensor_id
            INNER JOIN public."System"
            ON "System".id = "Sensor".system_id
            LEFT JOIN public."SystemUser"
            ON "SystemUser".system_id = "System".id
            WHERE "System".owner_id = a_user_id OR "SystemUser".user_id = a_user_id;

END;
$$;

CREATE OR REPLACE FUNCTION alert_history_select(IN a_user_id int, IN a_id int)
RETURNS TABLE(id int, alert_id int, alert_datetime timestamp with time zone)
LANGUAGE PLPGSQL
AS $$
BEGIN 

    RETURN QUERY SELECT "AlertHistory".* 
            FROM public."AlertHistory"
            INNER JOIN public."Alert"
            ON "Alert". id = "AlertHistory".alert_id
            INNER JOIN public."Sensor"
            ON "Sensor".id = "Alert".sensor_id
            INNER JOIN public."System"
            ON "System".id = "Sensor".id
            LEFT JOIN public."SystemUser"
            ON "SystemUser".system_id = "System".id
            INNER JOIN public."User"
            ON "User".id = "SystemUser".user_id
            WHERE "AlertUser".id = a_id and ("System".owner_id = a_user_id OR "SystemUser".user_id = a_user_id);

END;
$$;

CREATE OR REPLACE FUNCTION alert_history_view(IN a_user_id int, IN a_id int)
RETURNS TABLE(id int, alert_id int, alert_datetime timestamp with time zone)
LANGUAGE PLPGSQL
AS $$
BEGIN

    IF a_user_id IS NULL OR a_id IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    IF (SELECT COUNT(*)
            FROM alert_history_select(a_user_id, a_id)) = 0 THEN

        CALL raise_exception('403', 'FORBIDDEN', 'Don''t have permissions');

    END IF;

    RETURN QUERY SELECT * 
            FROM alert_history_select(a_user_id, a_id);

END;
$$;
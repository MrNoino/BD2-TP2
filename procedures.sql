CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE OR REPLACE PROCEDURE raise_exception(IN a_msg varchar(256), IN a_detail varchar(256), IN a_hint varchar(256))
LANGUAGE plpgsql
AS $$
BEGIN

    RAISE EXCEPTION 
    USING
	MESSAGE = a_msg,
    DETAIL = a_detail,
    HINT = a_hint;

END;
$$;

/* !!! INSERT !!!*/

/* Procedimento para inserir um sistema */
CREATE OR REPLACE PROCEDURE system_insert(IN a_location varchar(256), a_property varchar(256), a_owner_id int)
LANGUAGE plpgsql
AS $$
BEGIN

    IF a_location IS NULL OR a_property IS NULL OR a_owner_id IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    INSERT INTO public."System" (location, property, owner_id)
    VALUES
    (a_location, a_property, a_owner_id);

END;
$$;

/* Procedimento para inserir um sensor */
CREATE OR REPLACE PROCEDURE sensor_insert(IN a_owner_id int, IN a_sensor_type_id int, IN a_system_id int, IN a_inactivity_seconds numeric)
LANGUAGE plpgsql
AS $$
BEGIN

    IF a_owner_id IS NULL OR a_sensor_type_id IS NULL OR a_system_id IS NULL OR a_inactivity_seconds IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    IF (SELECT COUNT(*) 
        FROM public."System" 
        WHERE "System".id = a_system_id and "System".owner_id = a_owner_id) = 0 THEN

        CALL raise_exception('403', 'FORBIDDEN', 'Don''t have permissions');

    END IF;

    INSERT INTO public."Sensor" (sensor_type_id, system_id, inactivity_seconds)
    VALUES
    (a_sensor_type_id, a_system_id, a_inactivity_seconds);

END;
$$;

/* Procedimento para inserir um sensorType */
CREATE OR REPLACE PROCEDURE sensor_type_insert(IN a_type varchar(256))
LANGUAGE plpgsql
AS $$
BEGIN

    IF a_type IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    INSERT INTO public."SensorType" (type)
    VALUES
    (a_type);

END;
$$;

/* Procedimento para inserir um sensorHistory */
CREATE OR REPLACE PROCEDURE sensor_history_insert(IN a_owner_id int, IN a_sensor_id int, IN a_received_datetime timestamp with time zone, IN a_value varchar(256))
LANGUAGE plpgsql
AS $$
BEGIN

    IF a_owner_id IS NULL OR a_sensor_id IS NULL OR a_received_datetime IS NULL OR a_value IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    IF (SELECT COUNT(*) 
        FROM public."System"
        INNER JOIN public."Sensor"
        ON "Sensor".system_id = "System".id
        WHERE "Sensor".id = a_sensor_id and "System".owner_id = a_owner_id) = 0 THEN

        CALL raise_exception('403', 'FORBIDDEN', 'Don''t have permissions');

    END IF;

    INSERT INTO public."SensorHistory" (sensor_id, received_datetime, value)
    VALUES
    (a_sensor_id, (a_received_datetime  at time zone 'UTC'), a_value);

END;
$$;

/* Procedimento para inserir um actuator */
CREATE OR REPLACE PROCEDURE actuator_insert(IN a_owner_id int, IN a_system_id int)
LANGUAGE plpgsql
AS $$
BEGIN

    IF a_owner_id IS NULL OR a_system_id IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    IF (SELECT COUNT(*) 
        FROM public."System" 
        WHERE "System".id = a_system_id and "System".owner_id = a_owner_id) = 0 THEN

        CALL raise_exception('403', 'FORBIDDEN', 'Don''t have permissions');

    END IF;

    INSERT INTO public."Actuator" (system_id)
    VALUES
    (a_system_id);

END;
$$;

/* Procedimento para inserir um actuatorHistory */
CREATE OR REPLACE PROCEDURE actuator_history_insert(IN a_owner_id int, IN a_actuator_id int, a_action_datetime timestamp with time zone, IN a_action varchar(64))
LANGUAGE plpgsql
AS $$
BEGIN

    IF a_owner_id IS NULL OR a_actuator_id IS NULL OR a_action_datetime IS NULL OR a_action IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    IF (SELECT COUNT(*) 
        FROM public."System"
        INNER JOIN public."Actuator"
        ON "Actuator".system_id = "System".id
        WHERE "Actuator".id = a_actuator_id and "System".owner_id = a_owner_id) = 0 THEN

        CALL raise_exception('403', 'FORBIDDEN', 'Don''t have permissions');

    END IF;

    INSERT INTO public."ActuatorHistory" (actuator_id, action_datetime, action)
    VALUES
    (a_actuator_id, (a_action_datetime at time zone 'UTC'), a_action);

END;
$$;

/* Procedimento para inserir um alert */
CREATE OR REPLACE PROCEDURE alert_insert(IN a_owner_id int, IN a_sensor_id int, a_rule_id int, IN a_value varchar(256), IN a_alert varchar(256))
LANGUAGE plpgsql
AS $$
BEGIN

    IF a_owner_id IS NULL OR a_sensor_id IS NULL OR a_rule_id IS NULL OR a_value IS NULL OR a_alert IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    IF (SELECT COUNT(*) 
        FROM public."System"
        INNER JOIN public."Sensor"
        ON "Sensor".system_id = "System".id
        WHERE "Sensor".id = a_sensor_id and "System".owner_id = a_owner_id) = 0 THEN

        CALL raise_exception('403', 'FORBIDDEN', 'Don''t have permissions');

    END IF;

    INSERT INTO public."Alert" (sensor_id, rule_id, value, alert)
    VALUES
    (a_sensor_id, a_rule_id, a_value, a_alert);

END;
$$;

/* Procedimento para inserir um alertActuator */
CREATE OR REPLACE PROCEDURE alert_actuator_insert(IN a_owner_id int, IN a_alert_id int, a_actuator_id int, IN a_action varchar(64))
LANGUAGE plpgsql
AS $$
BEGIN

    IF a_owner_id IS NULL OR a_alert_id IS NULL OR a_actuator_id IS NULL OR a_action IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    IF (SELECT COUNT(*) 
        FROM public."System"
        INNER JOIN public."Sensor"
        ON "Sensor".system_id = "System".id
        INNER JOIN public."Alert"
        ON "Alert".sensor_id = "Sensor".id
        WHERE "Alert".id = a_alert_id and "System".owner_id = a_owner_id) = 0 THEN

        CALL raise_exception('403', 'FORBIDDEN', 'Don''t have permissions');

    END IF;

    INSERT INTO public."AlertActuator" (alert_id, actuator_id, action)
    VALUES
    (a_alert_id, a_actuator_id, a_action);

END;
$$;

/* Procedimento para inserir um user */
CREATE OR REPLACE PROCEDURE user_insert(IN a_name varchar(256), IN a_email varchar(256), IN a_password varchar(256))
LANGUAGE plpgsql
AS $$
BEGIN

    IF a_name IS NULL OR a_email IS NULL OR a_password IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    INSERT INTO public."User" (name, email, password)
    VALUES
    (a_name, a_email, crypt(a_password, gen_salt('bf')));

END;
$$;

/* Procedimento para inserir um systemUser */
CREATE OR REPLACE PROCEDURE system_user_insert(IN a_owner_id int, IN a_system_id int, a_user_id int)
LANGUAGE plpgsql
AS $$
BEGIN

    IF a_owner_id IS NULL OR a_system_id IS NULL OR a_user_id IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    IF (SELECT COUNT(*) 
        FROM public."System"
        WHERE "System".id = a_system_id and "System".owner_id = a_owner_id) = 0 THEN

        CALL raise_exception('403', 'FORBIDDEN', 'Don''t have permissions');

    END IF;

    INSERT INTO public."SystemUser" (system_id, user_id)
    VALUES
    (a_system_id, a_user_id);

END;
$$;

/* Procedimento para inserir um alertUser */
CREATE OR REPLACE PROCEDURE alert_user_insert(IN a_alert_history_id int, a_user_id int, IN a_see_datetime timestamp with time zone)
LANGUAGE plpgsql
AS $$
BEGIN

    IF a_alert_history_id IS NULL OR a_user_id IS NULL OR a_see_datetime IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    IF (SELECT COUNT(*) 
        FROM public."System"
        INNER JOIN public."Sensor"
        ON "Sensor".system_id = "System".id
        INNER JOIN public."Alert"
        ON "Alert".sensor_id = "Sensor".id
        INNER JOIN public."AlertHistory"
        ON "AlertHistory".alert_id = "Alert".id
        LEFT JOIN public."SystemUser"
        ON "SystemUser".system_id = "System".id
        WHERE "AlertHistory".id = a_alert_history_id and ("System".owner_id = a_user_id OR "SystemUser".user_id = a_user_id)) = 0 THEN

        CALL raise_exception('403', 'FORBIDDEN', 'Don''t have permissions');

    END IF;

    INSERT INTO public."AlertUser" (alert_history_id, user_id, see_datetime)
    VALUES
    (a_alert_history_id, a_user_id, (a_see_datetime at time zone 'UTC'));

END;
$$;

/* Procedimento para inserir um alertHistory */
CREATE OR REPLACE PROCEDURE alert_history_insert(IN a_owner_id int, IN a_alert_id int, a_alert_datetime timestamp with time zone)
LANGUAGE plpgsql
AS $$
BEGIN

    IF a_owner_id IS NULL OR a_alert_id IS NULL OR a_alert_datetime IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    IF (SELECT COUNT(*) 
        FROM public."System"
        INNER JOIN public."Sensor"
        ON "Sensor".system_id = "System".id
        INNER JOIN public."Alert"
        ON "Alert".sensor_id = "Sensor".id
        WHERE "Alert".id = a_alert_id and "System".owner_id = a_owner_id) = 0 THEN

        CALL raise_exception('403', 'FORBIDDEN', 'Don''t have permissions');

    END IF;

    INSERT INTO public."AlertHistory" (alert_id, alert_datetime)
    VALUES
    (a_alert_id, (a_alert_datetime at time zone 'UTC'));

END;
$$;

/* Procedimento para inserir um alertHistory */
CREATE OR REPLACE PROCEDURE alert_history_insert(IN a_alert_id int, a_alert_datetime timestamp with time zone)
LANGUAGE plpgsql
AS $$
BEGIN

    IF a_alert_id IS NULL OR a_alert_datetime IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    INSERT INTO public."AlertHistory" (alert_id, alert_datetime)
    VALUES
    (a_alert_id, (a_alert_datetime at time zone 'UTC'));

END;
$$;

/* !!! UPDATE !!! */

/* Procedimento para atualizar um sistema */
CREATE OR REPLACE PROCEDURE system_update(IN a_owner_id int, IN a_id int, IN a_location varchar(256) DEFAULT NULL, a_property varchar(256) DEFAULT NULL)
LANGUAGE plpgsql
AS $$
BEGIN

    IF a_owner_id IS NULL OR a_id IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    IF (SELECT COUNT(*) 
        FROM public."System"
        WHERE "System".id = a_id) = 0 THEN

        CALL raise_exception('404', 'NOT FOUND', 'Doesn''t exist');

    END IF;

    IF (SELECT COUNT(*) 
        FROM public."System"
        WHERE "System".id = a_id and "System".owner_id = a_owner_id) = 0 THEN

        CALL raise_exception('403', 'FORBIDDEN', 'Don''t have permissions');

    END IF;

    UPDATE public."System" 
    SET 
    location = COALESCE(a_location, location),
    property = COALESCE(a_property, property)
    WHERE id = a_id;

END;
$$;

/* Procedimento para atualizar um sensor */
CREATE OR REPLACE PROCEDURE sensor_update(IN a_owner_id int, IN a_id int, IN a_sensor_type_id int DEFAULT NULL, a_system_id int DEFAULT NULL, a_inactivity_seconds numeric DEFAULT NULL)
LANGUAGE plpgsql
AS $$
BEGIN

    IF a_owner_id IS NULL OR a_id IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    IF (SELECT COUNT(*) 
        FROM public."Sensor"
        WHERE "Sensor".id = a_id) = 0 THEN

        CALL raise_exception('404', 'NOT FOUND', 'Doesn''t exist');

    END IF;

    IF (SELECT COUNT(*) 
        FROM public."System"
        INNER JOIN public."Sensor"
        ON "Sensor".system_id = "System".id
        WHERE "Sensor".id = a_id and "System".owner_id = a_owner_id) = 0 THEN

        CALL raise_exception('403', 'FORBIDDEN', 'Don''t have permissions');

    END IF;

    UPDATE public."Sensor" 
    SET 
    sensor_type_id = COALESCE(a_sensor_type_id, sensor_type_id),
    system_id = COALESCE(a_system_id, system_id),
    inactivity_seconds = COALESCE(a_inactivity_seconds, inactivity_seconds)
    WHERE id = a_id;

END;
$$;

/* Procedimento para atualizar um sensorType */
CREATE OR REPLACE PROCEDURE sensor_type_update(IN a_id int, IN a_type varchar(256) DEFAULT NULL)
LANGUAGE plpgsql
AS $$
BEGIN

    IF a_id IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    UPDATE public."SensorType" 
    SET 
    type = COALESCE(a_type, type)
    WHERE id = a_id;

END;
$$;

/* Procedimento para atualizar um actuator */
CREATE OR REPLACE PROCEDURE actuator_update(IN a_owner_id int, IN a_id int, IN a_system_id int DEFAULT NULL)
LANGUAGE plpgsql
AS $$
BEGIN

    IF a_owner_id IS NULL OR a_id IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    IF (SELECT COUNT(*) 
        FROM public."Actuator"
        WHERE "Actuator".id = a_id) = 0 THEN

        CALL raise_exception('404', 'NOT FOUND', 'Doesn''t exist');

    END IF;

    IF (SELECT COUNT(*) 
        FROM public."System"
        INNER JOIN public."Actuator"
        ON "Actuator".system_id = "System".id
        WHERE "Actuator".id = a_id and "System".owner_id = a_owner_id) = 0 THEN

        CALL raise_exception('403', 'FORBIDDEN', 'Don''t have permissions');

    END IF;

    UPDATE public."Actuator" 
    SET 
    system_id = COALESCE(a_system_id, system_id)
    WHERE id = a_id;

END;
$$;

/* Procedimento para atualizar um actuatorHistory */
CREATE OR REPLACE PROCEDURE actuator_history_update(IN a_owner_id int, IN a_id int, IN a_actuator_id int DEFAULT NULL, IN a_action_datetime timestamp with time zone DEFAULT NULL, IN a_action varchar(64) DEFAULT NULL)
LANGUAGE plpgsql
AS $$
BEGIN

    IF a_owner_id IS NULL OR a_id IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    IF (SELECT COUNT(*) 
        FROM public."ActuatorHistory"
        WHERE "ActuatorHistory".id = a_id) = 0 THEN

        CALL raise_exception('404', 'NOT FOUND', 'Doesn''t exist');

    END IF;

    IF (SELECT COUNT(*) 
        FROM public."System"
        INNER JOIN public."Actuator"
        ON "Actuator".system_id = "System".id
        INNER JOIN public."ActuatorHistory"
        ON "ActuatorHistory".actuator_id = "Actuator".id
        WHERE "ActuatorHistory".id = a_id and "System".owner_id = a_owner_id) = 0 THEN

        CALL raise_exception('403', 'FORBIDDEN', 'Don''t have permissions');

    END IF;

    UPDATE public."ActuatorHistory" 
    SET 
    actuator_id = COALESCE(a_actuator_id, actuator_id),
    action_datetime = COALESCE((a_action_datetime at time zone 'UTC'), action_datetime),
    action = COALESCE(a_action, action)
    WHERE id = a_id;

END;
$$;

/* Procedimento para atualizar um sensorHistory */
CREATE OR REPLACE PROCEDURE sensor_history_update(IN a_owner_id int, IN a_id int, IN a_sensor_id int DEFAULT NULL, IN a_received_datetime timestamp with time zone DEFAULT NULL, IN a_value varchar(256) DEFAULT NULL)
LANGUAGE plpgsql
AS $$
BEGIN

    IF a_owner_id IS NULL OR a_id IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    IF (SELECT COUNT(*) 
        FROM public."SensorHistory"
        WHERE "SensorHistory".id = a_id) = 0 THEN

        CALL raise_exception('404', 'NOT FOUND', 'Doesn''t exist');

    END IF;

    IF (SELECT COUNT(*) 
        FROM public."System"
        INNER JOIN public."Sensor"
        ON "Sensor".system_id = "System".id
        INNER JOIN public."SensorHistory"
        ON "SensorHistory".sensor_id = "Sensor".id
        WHERE "SensorHistory".id = a_id and "System".owner_id = a_owner_id) = 0 THEN

        CALL raise_exception('403', 'FORBIDDEN', 'Don''t have permissions');

    END IF;

    UPDATE public."SensorHistory" 
    SET 
    sensor_id = COALESCE(a_sensor_id, sensor_id),
    received_datetime = COALESCE((a_received_datetime at time zone 'UTC'), received_datetime),
    value = COALESCE(a_value, value)
    WHERE id = a_id;

END;
$$;

/* Procedimento para atualizar um alert */
CREATE OR REPLACE PROCEDURE alert_update(IN a_owner_id int, IN a_id int, IN a_sensor_id int DEFAULT NULL, IN a_rule_id int DEFAULT NULL, IN a_value varchar(256) DEFAULT NULL, IN a_alert varchar(256) DEFAULT NULL)
LANGUAGE plpgsql
AS $$
BEGIN

    IF a_owner_id IS NULL OR a_id IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    IF (SELECT COUNT(*) 
        FROM public."Alert"
        WHERE "Alert".id = a_id) = 0 THEN

        CALL raise_exception('404', 'NOT FOUND', 'Doesn''t exist');

    END IF;

    IF (SELECT COUNT(*) 
        FROM public."System"
        INNER JOIN public."Sensor"
        ON "Sensor".system_id = "System".id
        INNER JOIN public."Alert"
        ON "Alert".sensor_id = "Sensor".id
        WHERE "Alert".id = a_id and "System".owner_id = a_owner_id) = 0 THEN

        CALL raise_exception('403', 'FORBIDDEN', 'Don''t have permissions');

    END IF;

    UPDATE public."Alert" 
    SET 
    sensor_id = COALESCE(a_sensor_id, sensor_id),
    rule_id = COALESCE(a_rule_id, rule_id),
    value = COALESCE(a_value, value),
    alert = COALESCE(a_alert, alert)
    WHERE id = a_id ;

END;
$$;

/* Procedimento para atualizar um alertActuator */
CREATE OR REPLACE PROCEDURE alert_actuator_update(IN a_owner_id int, IN a_alert_id int, IN a_actuator_id int, IN a_action varchar(64) DEFAULT NULL)
LANGUAGE plpgsql
AS $$
BEGIN

    IF a_owner_id IS NULL OR a_alert_id IS NULL OR a_actuator_id IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    IF (SELECT COUNT(*) 
        FROM public."AlertActuator"
        WHERE "AlertActuator".alert_id = a_alert_id and "AlertActuator".actuator_id = a_actuator_id) = 0 THEN

        CALL raise_exception('404', 'NOT FOUND', 'Doesn''t exist');

    END IF;

    IF (SELECT COUNT(*)
            FROM alert_actuator_select(a_owner_id, a_alert_id, a_actuator_id)) = 0 THEN

        CALL raise_exception('403', 'FORBIDDEN', 'Don''t have permissions');

    END IF;

    UPDATE public."AlertActuator" 
    SET 
    action = COALESCE(a_action, action)
    WHERE alert_id = a_alert_id and actuator_id = a_actuator_id;

END;
$$;

/* Procedimento para atualizar um user */
CREATE OR REPLACE PROCEDURE user_update(IN a_id int, IN a_name varchar(256) DEFAULT NULL, IN a_email varchar(256) DEFAULT NULL, IN a_password varchar(256) DEFAULT NULL)
LANGUAGE plpgsql
AS $$
BEGIN

    IF a_id IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    IF (SELECT COUNT(*) 
        FROM public."User"
        WHERE "User".id = a_id) = 0 THEN

        CALL raise_exception('404', 'NOT FOUND', 'Doesn''t exist');

    END IF;

    UPDATE public."User" 
    SET 
    name = COALESCE(a_name, name),
    email = COALESCE(a_email, email),
    password = COALESCE(crypt(a_password, gen_salt('bf')), password)
    WHERE id = a_id;

END;
$$;

/* Procedimento para atualizar um alertUser */
CREATE OR REPLACE PROCEDURE alert_user_update(IN a_alert_history_id int, IN a_user_id int, IN a_see_datetime timestamp with time zone DEFAULT NULL)
LANGUAGE plpgsql
AS $$
BEGIN

    IF a_alert_history_id IS NULL OR a_user_id IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    IF (SELECT COUNT(*) 
        FROM public."AlertUser"
        WHERE "AlertUser".alert_history_id = a_alert_history_id and "AlertUser".user_id = a_user_id) = 0 THEN

        CALL raise_exception('404', 'NOT FOUND', 'Doesn''t exist');

    END IF;

    IF (SELECT COUNT(*) 
        FROM public."System"
        INNER JOIN public."Sensor"
        ON "Sensor".system_id = "System".id
        INNER JOIN public."Alert"
        ON "Alert".sensor_id = "Sensor".id
        INNER JOIN public."AlertHistory"
        ON "AlertHistory".alert_id = "Alert".id
        INNER JOIN public."AlertUser"
        ON "AlertUser".alert_history_id = "AlertHistory".id
        WHERE "AlertUser".alert_history_id = a_alert_history_id and "AlertUser".user_id = a_user_id and "System".owner_id = a_user_id) = 0 THEN

        CALL raise_exception('403', 'FORBIDDEN', 'Don''t have permissions');

    END IF;

    UPDATE public."AlertUser" 
    SET 
    see_datetime = COALESCE((a_see_datetime at time zone 'UTC'), see_datetime)
    WHERE alert_history_id = a_alert_history_id and user_id = a_user_id;

END;
$$;

/* Procedimento para inserir um alertHistory */
CREATE OR REPLACE PROCEDURE alert_history_update(IN a_owner_id int, IN a_id int, IN a_alert_id int DEFAULT NULL, a_alert_datetime timestamp with time zone DEFAULT NULL)
LANGUAGE plpgsql
AS $$
BEGIN

    IF a_owner_id IS NULL OR a_id IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    IF (SELECT COUNT(*) 
        FROM public."AlertHistory"
        WHERE "AlertHistory".id = a_id) = 0 THEN

        CALL raise_exception('404', 'NOT FOUND', 'Doesn''t exist');

    END IF;

    IF (SELECT COUNT(*) 
        FROM public."System"
        INNER JOIN public."Sensor"
        ON "Sensor".system_id = "System".id
        INNER JOIN public."Alert"
        ON "Alert".sensor_id = "Sensor".id
        INNER JOIN public."AlertHistory"
        ON "AlertHistory".alert_id = "Alert".id
        WHERE "AlertHistory".id = a_id and "System".owner_id = a_owner_id) = 0 THEN

        CALL raise_exception('403', 'FORBIDDEN', 'Don''t have permissions');

    END IF;

    UPDATE public."AlertHistory" 
    SET 
    alert_id = COALESCE(a_alert_id, alert_id),
    alert_datetime = COALESCE((a_alert_datetime at time zone 'UTC'), alert_datetime)
    WHERE id = a_id;

END;
$$;

/* !!! DELETE !!! */

/* Procedimento para eliminar um sistema */
CREATE OR REPLACE PROCEDURE system_delete(IN a_owner_id int, IN a_id int)
LANGUAGE plpgsql
AS $$
BEGIN

    IF a_owner_id IS NULL OR a_id IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    IF (SELECT COUNT(*) 
        FROM public."System"
        WHERE "System".id = a_id) = 0 THEN

        CALL raise_exception('404', 'NOT FOUND', 'Doesn''t exist');

    END IF;

    IF (SELECT COUNT(*) 
        FROM public."System"
        WHERE "System".id = a_id and "System".owner_id = a_owner_id) = 0 THEN

        CALL raise_exception('403', 'FORBIDDEN', 'Don''t have permissions');

    END IF;

    DELETE FROM public."System"
    WHERE id = a_id;

END;
$$;

/* Procedimento para eliminar um sensor */
CREATE OR REPLACE PROCEDURE sensor_delete(IN a_owner_id int, IN a_id int)
LANGUAGE plpgsql
AS $$
BEGIN

    IF a_owner_id IS NULL OR a_id IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    IF (SELECT COUNT(*) 
        FROM public."Sensor"
        WHERE "Sensor".id = a_id) = 0 THEN

        CALL raise_exception('404', 'NOT FOUND', 'Doesn''t exist');

    END IF;

    IF (SELECT COUNT(*) 
        FROM public."System"
        INNER JOIN public."Sensor"
        ON "Sensor".system_id = "System".id
        WHERE "Sensor".id = a_id and "System".owner_id = a_owner_id) = 0 THEN

        CALL raise_exception('403', 'FORBIDDEN', 'Don''t have permissions');

    END IF;

    DELETE FROM public."Sensor"
    WHERE id = a_id;

END;
$$;

/* Procedimento para eliminar um sensorType */
CREATE OR REPLACE PROCEDURE sensor_type_delete(IN a_id int)
LANGUAGE plpgsql
AS $$
BEGIN

    IF a_id IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    DELETE FROM public."SensorType"
    WHERE id = a_id;

END;
$$;

/* Procedimento para eliminar um actuator */
CREATE OR REPLACE PROCEDURE actuator_delete(IN a_owner_id int, IN a_id int)
LANGUAGE plpgsql
AS $$
BEGIN

    IF a_owner_id IS NULL OR a_id IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    IF (SELECT COUNT(*) 
        FROM public."Actuator"
        WHERE "Actuator".id = a_id) = 0 THEN

        CALL raise_exception('404', 'NOT FOUND', 'Doesn''t exist');

    END IF;

    IF (SELECT COUNT(*) 
        FROM public."System"
        INNER JOIN public."Actuator"
        ON "Actuator".system_id = "System".id
        WHERE "Actuator".id = a_id and "System".owner_id = a_owner_id) = 0 THEN

        CALL raise_exception('403', 'FORBIDDEN', 'Don''t have permissions');

    END IF;

    DELETE FROM public."Actuator"
    WHERE id = a_id;

END;
$$;

/* Procedimento para eliminar um actuatorHistory */
CREATE OR REPLACE PROCEDURE actuator_history_delete(IN a_owner_id int, IN a_id int)
LANGUAGE plpgsql
AS $$
BEGIN

    IF a_owner_id IS NULL OR a_id IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    IF (SELECT COUNT(*) 
        FROM public."ActuatorHistory"
        WHERE "ActuatorHistory".id = a_id) = 0 THEN

        CALL raise_exception('404', 'NOT FOUND', 'Doesn''t exist');

    END IF;

    IF (SELECT COUNT(*) 
        FROM public."System"
        INNER JOIN public."Actuator"
        ON "Actuator".system_id = "System".id
        INNER JOIN public."ActuatorHistory"
        ON "ActuatorHistory".actuator_id = "Actuator".id
        WHERE "ActuatorHistory".id = a_id and "System".owner_id = a_owner_id) = 0 THEN

        CALL raise_exception('403', 'FORBIDDEN', 'Don''t have permissions');

    END IF;

    DELETE FROM public."ActuatorHistory"
    WHERE id = a_id;

END;
$$;

/* Procedimento para eliminar um sensorHistory */
CREATE OR REPLACE PROCEDURE sensor_history_delete(IN a_owner_id int, IN a_id int)
LANGUAGE plpgsql
AS $$
BEGIN

    IF a_owner_id IS NULL OR a_id IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    IF (SELECT COUNT(*) 
        FROM public."SensorHistory"
        WHERE "SensorHistory".id = a_id) = 0 THEN

        CALL raise_exception('404', 'NOT FOUND', 'Doesn''t exist');

    END IF;

    IF (SELECT COUNT(*) 
        FROM public."System"
        INNER JOIN public."Sensor"
        ON "Sensor".system_id = "Sensor".id
        INNER JOIN public."SensorHistory"
        ON "SensorHistory".sensor_id = "Sensor".id
        WHERE "SensorHistory".id = a_id and "System".owner_id = a_owner_id) = 0 THEN

        CALL raise_exception('403', 'FORBIDDEN', 'Don''t have permissions');

    END IF;

    DELETE FROM public."SensorHistory"
    WHERE id = a_id;

END;
$$;

/* Procedimento para eliminar um alert */
CREATE OR REPLACE PROCEDURE alert_delete(IN a_owner_id int, IN a_id int)
LANGUAGE plpgsql
AS $$
BEGIN

    IF a_owner_id IS NULL OR a_id IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    IF (SELECT COUNT(*) 
        FROM public."Alert"
        WHERE "Alert".id = a_id) = 0 THEN

        CALL raise_exception('404', 'NOT FOUND', 'Doesn''t exist');

    END IF;

    IF (SELECT COUNT(*) 
        FROM public."System"
        INNER JOIN public."Sensor"
        ON "Sensor".system_id = "Sensor".id
        INNER JOIN public."Alert"
        ON "Alert".sensor_id = "Sensor".id
        WHERE "Alert".id = a_id and "System".owner_id = a_owner_id) = 0 THEN

        CALL raise_exception('403', 'FORBIDDEN', 'Don''t have permissions');

    END IF;

    DELETE FROM public."Alert"
    WHERE id = a_id;

END;
$$;

/* Procedimento para eliminar um alertActuator */
CREATE OR REPLACE PROCEDURE alert_actuator_delete(IN a_owner_id int, IN a_alert_id int, IN a_actuator_id int)
LANGUAGE plpgsql
AS $$
BEGIN

    IF a_owner_id IS NULL OR a_alert_id IS NULL OR a_actuator_id IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    IF (SELECT COUNT(*) 
        FROM public."AlertActuator"
        WHERE "AlertActuator".alert_id = a_alert_id and "AlertActuator".actuator_id = a_actuator_id) = 0 THEN

        CALL raise_exception('404', 'NOT FOUND', 'Doesn''t exist');

    END IF;

    IF (SELECT COUNT(*) 
        FROM public."System"
        INNER JOIN public."Sensor"
        ON "Sensor".system_id = "System".id
        INNER JOIN public."Alert"
        ON "Alert".sensor_id = "Sensor".id
        INNER JOIN public."Actuator"
        ON "Actuator".system_id = "System".id
        INNER JOIN public."AlertActuator"
        ON "AlertActuator".actuator_id = "Actuator".id and "AlertActuator".alert_id = "Alert".id
        WHERE "AlertActuator".alert_id = a_alert_id and "AlertActuator".actuator_id = a_actuator_id and "System".owner_id = a_owner_id) = 0 THEN

        CALL raise_exception('403', 'FORBIDDEN', 'Don''t have permissions');

    END IF;
        
    DELETE FROM public."AlertActuator"
    WHERE alert_id = a_alert_id and actuator_id = a_actuator_id;

END;
$$;

/* Procedimento para eliminar um user */
CREATE OR REPLACE PROCEDURE user_delete(IN a_id int)
LANGUAGE plpgsql
AS $$
BEGIN

    IF a_id IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    IF (SELECT COUNT(*) 
        FROM public."User"
        WHERE "User".id = a_id) = 0 THEN

        CALL raise_exception('404', 'NOT FOUND', 'Doesn''t exist');

    END IF;

    DELETE FROM public."User"
    WHERE id = a_id;

END;
$$;

/* Procedimento para eliminar um systemUser */
CREATE OR REPLACE PROCEDURE system_user_delete(IN a_owner_id int, IN a_system_id int, IN a_user_id int)
LANGUAGE plpgsql
AS $$
BEGIN

    IF a_owner_id IS NULL OR a_system_id IS NULL OR a_user_id IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    IF (SELECT COUNT(*) 
        FROM public."SystemUser"
        WHERE "SystemUser".system_id = a_system_id and "SystemUser".user_id = a_user_id) = 0 THEN

        CALL raise_exception('404', 'NOT FOUND', 'Doesn''t exist');

    END IF;

    IF (SELECT COUNT(*) 
        FROM public."System"
        INNER JOIN public."SystemUser"
        ON "SystemUser".system_id = "System".id
        WHERE "SystemUser".system_id = a_system_id and "SystemUser".user_id = a_user_id and "System".owner_id = a_owner_id) = 0 THEN

        CALL raise_exception('403', 'FORBIDDEN', 'Don''t have permissions');

    END IF;

    DELETE FROM public."SystemUser"
    WHERE "SystemUser".system_id = a_system_id and "SystemUser".user_id = a_user_id;

END;
$$;

/* Procedimento para eliminar um AlertUser */
CREATE OR REPLACE PROCEDURE alert_user_delete(IN a_owner_id int, IN a_alert_history_id int, IN a_user_id int)
LANGUAGE plpgsql
AS $$
BEGIN

    IF a_owner_id IS NULL OR a_alert_history_id IS NULL OR a_user_id IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    IF (SELECT COUNT(*) 
        FROM public."AlertUser"
        WHERE "AlertUser".alert_history_id = a_alert_history_id and "AlertUser".user_id = a_user_id) = 0 THEN

        CALL raise_exception('404', 'NOT FOUND', 'Doesn''t exist');

    END IF;

    IF (SELECT COUNT(*) 
        FROM public."System"
        INNER JOIN public."Sensor"
        ON "Sensor".system_id = "System".id
        INNER JOIN public."Alert"
        ON "Alert".sensor_id = "Sensor".id
        INNER JOIN public."AlertHistory"
        ON "AlertHistory".alert_id = "Alert".id
        INNER JOIN public."AlertUser"
        ON "AlertUser".alert_history_id = "AlertHistory".id
        WHERE "AlertUser".alert_history_id = a_alert_history_id and "AlertUser".user_id = a_user_id and "System".owner_id = a_owner_id) = 0 THEN

        CALL raise_exception('403', 'FORBIDDEN', 'Don''t have permissions');

    END IF;

    DELETE FROM public."AlertUser"
    WHERE alert_history_id = a_alert_history_id and user_id = a_user_id;

END;
$$;

/* Procedimento para eliminar um AlertHistory */
CREATE OR REPLACE PROCEDURE alert_history_delete(IN a_owner_id int, IN a_id int)
LANGUAGE plpgsql
AS $$
BEGIN

    IF a_owner_id IS NULL OR a_id IS NULL THEN

        CALL raise_exception('400', 'BAD REQUEST', 'Fields empty');

    END IF;

    IF (SELECT COUNT(*) 
        FROM public."AlertHistory"
        WHERE "AlertHistory".id = a_id) = 0 THEN

        CALL raise_exception('404', 'NOT FOUND', 'Doesn''t exist');

    END IF;

    IF (SELECT COUNT(*) 
        FROM public."System"
        INNER JOIN public."Sensor"
        ON "Sensor".system_id = "System".id
        INNER JOIN public."Alert"
        ON "Alert".sensor_id = "Sensor".id
        INNER JOIN public."AlertHistory"
        ON "AlertHistory".alert_id = "Alert".id
        WHERE "AlertHistory".id = a_id and "System".owner_id = a_owner_id) = 0 THEN

        CALL raise_exception('403', 'FORBIDDEN', 'Don''t have permissions');

    END IF;

    DELETE FROM public."AlertHistory"
    WHERE id = a_id;

END;
$$;
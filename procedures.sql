/* !!! INSERT !!!*/

/* Procedimento para inserir um sistema */
CREATE OR REPLACE PROCEDURE system_insert(IN a_location varchar(256), a_property varchar(256), a_owner_id int)
LANGUAGE plpgsql
AS $$
BEGIN

    INSERT INTO public."System" (location, property, owner_id)
    VALUES
    (a_location, a_property, a_owner_id);

END;
$$;

/* Procedimento para inserir um sensor */
CREATE OR REPLACE PROCEDURE sensor_insert(IN a_sensor_type_id int, IN a_system_id int, IN a_inactivity_seconds numeric)
LANGUAGE plpgsql
AS $$
BEGIN

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

    INSERT INTO public."SensorType" (type)
    VALUES
    (a_type);

END;
$$;

/* Procedimento para inserir um actuator */
CREATE OR REPLACE PROCEDURE actuator_insert(IN a_system_id int, IN a_inactivity_seconds numeric)
LANGUAGE plpgsql
AS $$
BEGIN

    INSERT INTO public."Actuator" (system_id, inactivity_seconds)
    VALUES
    (a_system_id, a_inactivity_seconds);

END;
$$;

/* Procedimento para inserir um actuatorHistory */
CREATE OR REPLACE PROCEDURE actuator_history_insert(IN a_actuator_id int, a_action_datetime timestamp, IN a_action varchar(64))
LANGUAGE plpgsql
AS $$
BEGIN

    INSERT INTO public."ActuatorHistory" (actuator_id, action_datetime, action)
    VALUES
    (a_actuator_id, a_action_datetime, a_action);

END;
$$;

/* Procedimento para inserir um sensorHistory */
CREATE OR REPLACE PROCEDURE sensor_history_insert(IN a_sensor_id int, a_received_datetime timestamp, IN a_value varchar(256))
LANGUAGE plpgsql
AS $$
BEGIN

    INSERT INTO public."SensorHistory" (sensor_id, received_datetime, value)
    VALUES
    (a_sensor_id, a_received_datetime, a_value);

END;
$$;

/* Procedimento para inserir um alert */
CREATE OR REPLACE PROCEDURE alert_insert(IN a_sensor_id int, a_rule timestamp, IN a_value varchar(256), IN alert varchar(256))
LANGUAGE plpgsql
AS $$
BEGIN

    INSERT INTO public."Alert" (sensor_id, rule, value, alert)
    VALUES
    (a_sensor_id, a_rule, a_value, a_alert);

END;
$$;

/* Procedimento para inserir um alertActuator */
CREATE OR REPLACE PROCEDURE alert_actuator_insert(IN a_alert_id int, a_actuator_id int, IN a_action varchar(64))
LANGUAGE plpgsql
AS $$
BEGIN

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

    INSERT INTO public."User" (name, email, password)
    VALUES
    (a_name, a_email, crypt(a_password, gen_salt('bf')));

END;
$$;

/* Procedimento para inserir um systemUser */
CREATE OR REPLACE PROCEDURE system_user_insert(IN a_system_id int, a_user_id int)
LANGUAGE plpgsql
AS $$
BEGIN

    INSERT INTO public."SystemUser" (system_id, user_id)
    VALUES
    (a_system_id, a_user_id);

END;
$$;

/* Procedimento para inserir um alertUser */
CREATE OR REPLACE PROCEDURE alert_user_insert(IN a_alert_history_id int, a_user_id int, IN a_see_datetime timestamp)
LANGUAGE plpgsql
AS $$
BEGIN

    INSERT INTO public."AlertUser" (alert_history_id, user_id, see_datetime)
    VALUES
    (a_alert_history_id, a_user_id, a_see_datetime);

END;
$$;

/* Procedimento para inserir um alertHistory */
CREATE OR REPLACE PROCEDURE alert_history_insert(IN a_alert_id int, a_alert_datetime timestamp)
LANGUAGE plpgsql
AS $$
BEGIN

    INSERT INTO public."AlertHistory" (a_alert_id, a_alert_datetime)
    VALUES
    (a_alert_id, a_alert_datetime);

END;
$$;

/* !!! UPDATE !!! */

/* Procedimento para atualizar um sistema */
CREATE OR REPLACE PROCEDURE system_update(IN a_id int, IN a_location varchar(256) DEFAULT NULL, a_property varchar(256) DEFAULT NULL, a_owner_id int DEFAULT NULL)
LANGUAGE plpgsql
AS $$
BEGIN

    UPDATE public."System" 
    SET 
    location = COALESCE(a_location, location),
    property = COALESCE(a_property, property),
    owner_id = COALESCE(a_owner_id, owner_id)
    WHERE id = a_id;

END;
$$;

/* Procedimento para atualizar um sensor */
CREATE OR REPLACE PROCEDURE sensor_update(IN a_id int, IN a_sensor_type_id int DEFAULT NULL, a_system_id int DEFAULT NULL, a_inactivity_seconds numeric DEFAULT NULL)
LANGUAGE plpgsql
AS $$
BEGIN

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

    UPDATE public."SensorType" 
    SET 
    type = COALESCE(a_type, type)
    WHERE id = a_id;

END;
$$;

/* Procedimento para atualizar um actuator */
CREATE OR REPLACE PROCEDURE actuator_update(IN a_id int, IN a_system_id int DEFAULT NULL, IN a_inactivity_seconds numeric DEFAULT NULL)
LANGUAGE plpgsql
AS $$
BEGIN

    UPDATE public."Actuator" 
    SET 
    system_id = COALESCE(a_system_id, system_id),
    inactivity_seconds = COALESCE(a_inactivity_seconds, inactivity_seconds)
    WHERE id = a_id;

END;
$$;

/* Procedimento para atualizar um actuatorHistory */
CREATE OR REPLACE PROCEDURE actuator_history_update(IN a_actuator_id int, IN a_action_datetime timestamp, IN a_action varchar(64) DEFAULT NULL)
LANGUAGE plpgsql
AS $$
BEGIN

    UPDATE public."ActuatorHistory" 
    SET 
    action = COALESCE(a_action, action)
    WHERE actuator_id = a_actuator_id and action_datetime = a_action_datetime;

END;
$$;

/* Procedimento para atualizar um sensorHistory */
CREATE OR REPLACE PROCEDURE sensor_history_update(IN a_sensor_id int, IN a_received_datetime timestamp, IN a_value varchar(256) DEFAULT NULL)
LANGUAGE plpgsql
AS $$
BEGIN

    UPDATE public."SensorHistory" 
    SET 
    action = COALESCE(a_value, value)
    WHERE sensor_id = a_sensor_id and received_datetime = a_received_datetime;

END;
$$;

/* Procedimento para atualizar um alert */
CREATE OR REPLACE PROCEDURE alert_update(IN a_id int, IN a_sensor_id int DEFAULT NULL, IN a_rule varchar(256) DEFAULT NULL, IN a_value varchar(256) DEFAULT NULL, IN a_alert varchar(256) DEFAULT NULL)
LANGUAGE plpgsql
AS $$
BEGIN

    UPDATE public."Alert" 
    SET 
    sensor_id = COALESCE(a_sensor_id, sensor_id),
    rule = COALESCE(a_rule, rule),
    value = COALESCE(a_value, value),
    alert = COALESCE(a_alert, alert)
    WHERE id = a_id ;

END;
$$;

/* Procedimento para atualizar um alertActuator */
CREATE OR REPLACE PROCEDURE alert_actuator_update(IN a_alert_id int, IN a_actuator_id int, IN a_action varchar(64) DEFAULT NULL)
LANGUAGE plpgsql
AS $$
BEGIN

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

    UPDATE public."User" 
    SET 
    name = COALESCE(a_name, name),
    email = COALESCE(a_email, email),
    password = COALESCE(crypt(a_password, gen_salt('bf')), password)
    WHERE id = a_id;

END;
$$;

/* Procedimento para atualizar um alertUser */
CREATE OR REPLACE PROCEDURE alert_user_update(IN a_alert_history_id int, IN a_user_id int, IN see_datetime timestamp DEFAULT NULL)
LANGUAGE plpgsql
AS $$
BEGIN

    UPDATE public."AlertUser" 
    SET 
    see_datetime = COALESCE(a_see_datetime, see_datetime)
    WHERE alert_history_id = a_alert_history_id and user_id = a_user_id;

END;
$$;

/* Procedimento para inserir um alertHistory */
CREATE OR REPLACE PROCEDURE alert_history_update(IN a_id int, IN a_alert_id int DEFAULT NULL, a_alert_datetime timestamp DEFAULT NULL)
LANGUAGE plpgsql
AS $$
BEGIN

    UPDATE public."AlertHistory" 
    SET 
    alert_id = COALESCE(a_alert_id, alert_id),
    alert_datetime = COALESCE(a_alert_datetime, alert_datetime)
    WHERE id = a_id;

END;
$$;

/* !!! DELETE !!! */

/* Procedimento para eliminar um sistema */
CREATE OR REPLACE PROCEDURE system_delete(IN a_id int)
LANGUAGE plpgsql
AS $$
BEGIN

    CALL sensor_delete(a_system_id => a_id);

    CALL actuator_delete(a_system_id => a_id);

    DELETE FROM public."System"
    WHERE id = a_id;

END;
$$;

/* Procedimento para eliminar um sensor */
CREATE OR REPLACE PROCEDURE sensor_delete(IN a_id int DEFAULT NULL, IN a_system_id int DEFAULT NULL)
LANGUAGE plpgsql
AS $$
BEGIN

    IF a_system_id IS NULL THEN

        DELETE FROM public."Sensor"
        WHERE id = a_id;

    ELSIF a_id IS NULL THEN

        DELETE FROM public."Sensor"
        WHERE system_id = a_system_id;

    END IF;

END;
$$;

/* Procedimento para eliminar um sensorType */
CREATE OR REPLACE PROCEDURE sensor_type_delete(IN a_id int)
LANGUAGE plpgsql
AS $$
BEGIN

    DELETE FROM public."SensorType"
    WHERE id = a_id;

END;
$$;

/* Procedimento para eliminar um actuator */
CREATE OR REPLACE PROCEDURE actuator_delete(IN a_id int DEFAULT NULL, IN a_system_id int DEFAULT NULL)
LANGUAGE plpgsql
AS $$
BEGIN

    IF a_system_id IS NULL THEN

        DELETE FROM public."Actuator"
        WHERE id = a_id;

    ELSIF a_id IS NULL THEN
        
        DELETE FROM public."Actuator"
        WHERE system_id = a_system_id;

    END IF;

END;
$$;

/* Procedimento para eliminar um actuatorHistory */
CREATE OR REPLACE PROCEDURE actuator_history_delete(IN a_actuator_id int DEFAULT NULL, IN a_action_datetime timestamp DEFAULT NULL, a_system_id int DEFAULT NULL)
LANGUAGE plpgsql
AS $$
BEGIN

    IF a_action_datetime IS NULL AND a_actuator_id IS NOT NULL THEN

        DELETE FROM public."ActuatorHistory"
        WHERE actuator_id = a_actuator_id;

    ELSIF a_action_datetime IS NOT NULL AND a_actuator_id IS NOT NULL THEN

        DELETE FROM public."ActuatorHistory"
        WHERE actuator_id = a_actuator_id and action_datetime = a_action_datetime;

    ELSIF a_system_id IS NOT NULL THEN

        DELETE FROM public."ActuatorHistory"
        USING public."Actuator"
        WHERE "Actuator".system_id = a_system_id AND "ActuatorHistory".actuator_id = "Actuator".id;

    END IF;

END;
$$;

/* Procedimento para eliminar um sensorHistory */
CREATE OR REPLACE PROCEDURE sensor_history_delete(IN a_sensor_id int, IN a_received_datetime timestamp DEFAULT NULL)
LANGUAGE plpgsql
AS $$
BEGIN

    IF a_received_datetime IS NULL THEN

        DELETE FROM public."SensorHistory"
        WHERE sensor_id = a_sensor_id;

    ELSE

        DELETE FROM public."SensorHistory"
        WHERE sensor_id = a_sensor_id and received_datetime = a_received_datetime;

    END IF;

END;
$$;

/* Procedimento para eliminar um alert */
CREATE OR REPLACE PROCEDURE alert_delete(IN a_id int)
LANGUAGE plpgsql
AS $$
BEGIN

    DELETE FROM public."Alert"
    WHERE id = a_id;

END;
$$;

/* Procedimento para eliminar um alertActuator */
CREATE OR REPLACE PROCEDURE alert_actuator_delete(IN a_alert_id int DEFAULT NULL, IN a_actuator_id int DEFAULT NULL)
LANGUAGE plpgsql
AS $$
BEGIN

    IF a_alert_id IS NULL THEN

        DELETE FROM public."AlertActuator"
        WHERE actuator_id = a_actuator_id;

    ELSIF a_actuator_id IS NULL THEN

        DELETE FROM public."AlertActuator"
        WHERE alert_id = a_alert_id;

    ELSE  
        
        DELETE FROM public."AlertActuator"
        WHERE alert_id = a_alert_id and actuator_id = a_actuator_id;

    END IF;

END;
$$;

/* Procedimento para eliminar um user */
CREATE OR REPLACE PROCEDURE user_delete(IN a_id int)
LANGUAGE plpgsql
AS $$
BEGIN

    DELETE FROM public."User"
    WHERE id = a_id;

END;
$$;

/* Procedimento para eliminar um systemUser */
CREATE OR REPLACE PROCEDURE system_user_delete(IN a_system_id int DEFAULT NULL, IN a_user_id int DEFAULT NULL)
LANGUAGE plpgsql
AS $$
BEGIN

    IF a_system_id IS NULL THEN

        DELETE FROM public."SystemUser"
        WHERE "SystemUser".user_id = a_user_id;

    ELSIF a_user_id IS NULL THEN

        DELETE FROM public."SystemUser"
        WHERE "SystemUser".system_id = a_system_id;

    ELSE

        DELETE FROM public."SystemUser"
        WHERE "SystemUser".system_id = a_system_id and "SystemUser".user_id = a_user_id;

    END IF;

END;
$$;

/* Procedimento para eliminar um AlertUser */
CREATE OR REPLACE PROCEDURE alert_user_delete(IN a_alert_history_id int DEFAULT NULL, IN a_user_id int DEFAULT NULL)
LANGUAGE plpgsql
AS $$
BEGIN

    IF a_alert_history_id IS NULL THEN

        DELETE FROM public."AlertUser"
        WHERE user_id = a_user_id;

    ELSIF a_user_id IS NULL THEN

        DELETE FROM public."AlertUser"
        WHERE alert_history_id = a_alert_history_id;

    ELSE

        DELETE FROM public."AlertUser"
        WHERE alert_history_id = a_alert_history_id and user_id = a_user_id;

    END IF;

END;
$$;
CREATE OR REPLACE VIEW system_view
AS
SELECT * 
FROM public."System";

CREATE OR REPLACE FUNCTION system_view(IN a_id int)
RETURNS TABLE(id int, location varchar(256), property varchar(256), owner_id int)
LANGUAGE PLPGSQL
AS $$
BEGIN 

    RETURN QUERY SELECT * 
            FROM public."System"
            WHERE "System".id = a_id;

END;
$$;

CREATE OR REPLACE VIEW sensor_view
AS
SELECT * 
FROM public."Sensor";

CREATE OR REPLACE FUNCTION sensor_view(IN a_id int)
RETURNS TABLE(id int, sensor_type_id int, system_id int, inactivity_seconds numeric)
LANGUAGE PLPGSQL
AS $$
BEGIN 

    RETURN QUERY SELECT * 
            FROM public."Sensor"
            WHERE "Sensor".id = a_id;

END;
$$;

CREATE OR REPLACE VIEW sensor_type_view
AS
SELECT * 
FROM public."SensorType";

CREATE OR REPLACE FUNCTION sensor_type_view(IN a_id int)
RETURNS TABLE(id int, type varchar)
LANGUAGE PLPGSQL
AS $$
BEGIN 

    RETURN QUERY SELECT * 
            FROM public."SensorType"
            WHERE "SensorType".id = a_id;

END;
$$;

CREATE OR REPLACE VIEW actuator_view
AS
SELECT * 
FROM public."Actuator";

CREATE OR REPLACE FUNCTION actuator_view(IN a_id int)
RETURNS TABLE(id int, system_id int, inactivity_seconds numeric)
LANGUAGE PLPGSQL
AS $$
BEGIN 

    RETURN QUERY SELECT * 
            FROM public."Actuator"
            WHERE "Actuator".id = a_id;

END;
$$;

CREATE OR REPLACE VIEW actuator_history_view
AS
SELECT * 
FROM public."ActuatorHistory";

CREATE OR REPLACE FUNCTION actuator_history_view(IN a_actuator_id int)
RETURNS TABLE(actuator_id int, action_datetime timestamp, action varchar(64))
LANGUAGE PLPGSQL
AS $$
BEGIN 

    RETURN QUERY SELECT * 
            FROM public."ActuatorHistory"
            WHERE "ActuatorHistory".actuator_id = a_actuator_id;

END;
$$;

CREATE OR REPLACE VIEW sensor_history_view
AS
SELECT * 
FROM public."SensorHistory";

CREATE OR REPLACE FUNCTION sensor_history_view(IN a_sensor_id int)
RETURNS TABLE(sensor_id int, received_datetime timestamp, value varchar(256))
LANGUAGE PLPGSQL
AS $$
BEGIN 

    RETURN QUERY SELECT * 
            FROM public."SensorHistory"
            WHERE "SensorHistory".sensor_id = a_sensor_id;

END;
$$;

CREATE OR REPLACE VIEW alert_view
AS
SELECT * 
FROM public."Alert";

CREATE OR REPLACE FUNCTION alert_view(IN a_id int)
RETURNS TABLE(id int, sensor_id int, rule varchar(256), value varchar(256), alert varchar(256))
LANGUAGE PLPGSQL
AS $$
BEGIN 

    RETURN QUERY SELECT * 
            FROM public."Alert"
            WHERE "Alert".id = a_id;

END;
$$;

CREATE OR REPLACE VIEW alert_actuator_view
AS
SELECT * 
FROM public."AlertActuator";

CREATE OR REPLACE FUNCTION alert_actuator_view(IN a_alert_id int, IN a_actuator_id int)
RETURNS TABLE(alert_id int, actuator_id int, action varchar(256))
LANGUAGE PLPGSQL
AS $$
BEGIN 

    RETURN QUERY SELECT * 
            FROM public."AlertActuator"
            WHERE "AlertActuator".alert_id = COALESCE(a_alert_id, "AlertActuator".alert_id) and "AlertActuator".actuator_id = COALESCE(a_actuator_id, "AlertActuator".actuator_id);

END;
$$;

CREATE OR REPLACE VIEW user_view
AS
SELECT * 
FROM public."User";

CREATE OR REPLACE FUNCTION user_view(IN a_id int)
RETURNS TABLE(id int, name varchar(256))
LANGUAGE PLPGSQL
AS $$
BEGIN 

    RETURN QUERY SELECT * 
            FROM public."User"
            WHERE "User".id = a_id;

END;
$$;

CREATE OR REPLACE FUNCTION login(IN a_email varchar(256), IN a_password varchar(256))
RETURNS TABLE(id int, name varchar(256), email varchar(256))
LANGUAGE PLPGSQL
AS $$
BEGIN 

    RETURN QUERY SELECT "User".id, "User".name, "User".email 
            FROM public."User"
            WHERE "User".email = a_email and "User".password = crypt(a_password, "User".password);

END;
$$;

CREATE OR REPLACE VIEW system_user_view
AS
SELECT * 
FROM public."SystemUser";

CREATE OR REPLACE FUNCTION system_user_view(IN a_system_id int, IN a_user_id int)
RETURNS TABLE(system_id int, user_id int)
LANGUAGE PLPGSQL
AS $$
BEGIN 

    RETURN QUERY SELECT * 
            FROM public."SystemUser"
            WHERE "SystemUser".system_id = COALESCE(a_system_id, "SystemUser".system_id) and "SystemUser".user_id = COALESCE(a_user_id, "SystemUser".user_id);

END;
$$;

CREATE OR REPLACE VIEW alert_user_view
AS
SELECT * 
FROM public."AlertUser";

CREATE OR REPLACE FUNCTION alert_user_view(IN a_alert_id int, IN a_user_id int)
RETURNS TABLE(alert_id int, user_id int, see_datetime timestamp)
LANGUAGE PLPGSQL
AS $$
BEGIN 

    RETURN QUERY SELECT * 
            FROM public."AlertUser"
            WHERE "AlertUser".alert_id = COALESCE(a_alert_id, "AlertUser".alert_id) and "AlertUser".user_id = COALESCE(a_user_id, "AlertUser".user_id);

END;
$$;
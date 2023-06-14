/*CREATE DATABASE "IOT";*/

CREATE TABLE IF NOT EXISTS "System"
(
    id serial NOT NULL,
    location character varying(256) NOT NULL,
    property character varying(256) NOT NULL,
    owner_id int NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS "Sensor"
(
    id serial NOT NULL,
    sensor_type_id int NOT NULL,
    system_id int NOT NULL,
    inactivity_seconds numeric NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS "SensorType"
(
    id serial NOT NULL,
    type character varying(256) NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS "Actuator"
(
    id serial NOT NULL,
    system_id int NOT NULL
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public."ActuatorHistory"
(
    id serial NOT NULL,
    actuator_id integer NOT NULL,
    action_datetime timestamp with time zone NOT NULL DEFAULT(now() at time zone 'utc'),
    action character varying(64) NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public."SensorHistory"
(
    id serial NOT NULL,
    sensor_id integer NOT NULL,
    received_datetime timestamp with time zone NOT NULL DEFAULT(now() at time zone 'utc'),
    value character varying(256) NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public."Rule"
(
    id serial NOT NULL,
    rule character varying(16) NOT NULL,
    description character varying(256),
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public."Alert"
(
    id serial NOT NULL,
    sensor_id integer NOT NULL,
    rule_id integer NOT NULL,
    value character varying(256) NOT NULL,
    alert character varying(256) NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS "AlertActuator"
(
    alert_id serial NOT NULL,
    actuator_id int NOT NULL,
    action character varying(64) NOT NULL,
    PRIMARY KEY (alert_id, actuator_id)
);

CREATE TABLE IF NOT EXISTS "User"
(
    id serial NOT NULL,
    name character varying(256) NOT NULL,
    email  character varying(256) NOT NULL,
    password character varying(256) NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS "SystemUser"
(
    system_id int NOT NULL,
    user_id int NOT NULL,
    PRIMARY KEY (system_id, user_id)
);

CREATE TABLE IF NOT EXISTS "AlertUser"
(
    alert_history_id int NOT NULL,
    user_id int NOT NULL,
    see_datetime timestamp with time zone NOT NULL DEFAULT(now() at time zone 'utc'),
    PRIMARY KEY (alert_history_id, user_id)
);

CREATE TABLE IF NOT EXISTS public."AlertHistory"
(
    id serial NOT NULL,
    alert_id integer NOT NULL,
    alert_datetime timestamp with time zone NOT NULL,
    PRIMARY KEY (id)
);

ALTER TABLE IF EXISTS "System"
    ADD FOREIGN KEY (owner_id)
    REFERENCES "User" (id);


ALTER TABLE IF EXISTS "Sensor"
    ADD FOREIGN KEY (sensor_type_id)
    REFERENCES "SensorType" (id);


ALTER TABLE IF EXISTS "Sensor"
    ADD FOREIGN KEY (system_id)
    REFERENCES "System" (id);


ALTER TABLE IF EXISTS "Actuator"
    ADD FOREIGN KEY (system_id)
    REFERENCES "System" (id);


ALTER TABLE IF EXISTS "ActuatorHistory"
    ADD FOREIGN KEY (actuator_id)
    REFERENCES "Actuator" (id);


ALTER TABLE IF EXISTS "SensorHistory"
    ADD FOREIGN KEY (sensor_id)
    REFERENCES "Sensor" (id);


ALTER TABLE IF EXISTS "Alert"
    ADD FOREIGN KEY (sensor_id)
    REFERENCES "Sensor" (id);

ALTER TABLE IF EXISTS public."Alert"
    ADD FOREIGN KEY (rule_id)
    REFERENCES public."Rule" (id);


ALTER TABLE IF EXISTS "AlertActuator"
    ADD FOREIGN KEY (alert_id)
    REFERENCES "Alert" (id);


ALTER TABLE IF EXISTS "AlertActuator"
    ADD FOREIGN KEY (actuator_id)
    REFERENCES "Actuator" (id);


ALTER TABLE IF EXISTS "SystemUser"
    ADD FOREIGN KEY (system_id)
    REFERENCES "System" (id);


ALTER TABLE IF EXISTS "SystemUser"
    ADD FOREIGN KEY (user_id)
    REFERENCES "User" (id);


ALTER TABLE IF EXISTS "AlertUser"
    ADD FOREIGN KEY (alert_history_id)
    REFERENCES "AlertHistory" (id);


ALTER TABLE IF EXISTS "AlertUser"
    ADD FOREIGN KEY (user_id)
    REFERENCES "User" (id);

ALTER TABLE IF EXISTS public."AlertHistory"
    ADD FOREIGN KEY (alert_id)
    REFERENCES public."Alert" (id);


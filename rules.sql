CREATE OR REPLACE RULE remove_actuator_dependencies AS 
ON DELETE TO public."Actuator"
DO ALSO 
DELETE FROM public."ActuatorHistory" WHERE actuator_id = OLD.id;

CREATE OR REPLACE RULE remove_sensor_dependencies AS 
ON DELETE TO public."Sensor"
DO ALSO 
DELETE FROM public."SensorHistory" WHERE sensor_id = OLD.id;

CREATE OR REPLACE RULE remove_system_dependencies AS
ON DELETE TO public."System"
DO ALSO 
(
    DELETE FROM public."Sensor" WHERE system_id = OLD.id;
    DELETE FROM public."Actuator" WHERE system_id = OLD.id;
);

CREATE OR REPLACE RULE remove_sensor_type_dependencies AS
ON DELETE TO public."SensorType"
DO ALSO 
DELETE FROM public."Sensor" WHERE sensor_type_id = OLD.id;

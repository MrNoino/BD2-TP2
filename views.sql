CREATE OR REPLACE VIEW system_view
AS
SELECT * 
FROM public."System";

CREATE OR REPLACE VIEW sensor_view
AS
SELECT * 
FROM public."Sensor";

CREATE OR REPLACE VIEW sensor_type_view
AS
SELECT * 
FROM public."SensorType";

CREATE OR REPLACE VIEW sensor_history_view
AS
SELECT * 
FROM public."SensorHistory";

CREATE OR REPLACE VIEW actuator_view
AS
SELECT * 
FROM public."Actuator";

CREATE OR REPLACE VIEW actuator_history_view
AS
SELECT * 
FROM public."ActuatorHistory";

CREATE OR REPLACE VIEW rule_view
AS
SELECT * 
FROM public."Rule";

CREATE OR REPLACE VIEW alert_view
AS
SELECT * 
FROM public."Alert";

CREATE OR REPLACE VIEW alert_actuator_view
AS
SELECT * 
FROM public."AlertActuator";

CREATE OR REPLACE VIEW user_view
AS
SELECT "User".id, "User".name, "User".email 
FROM public."User";

CREATE OR REPLACE VIEW system_user_view
AS
SELECT * 
FROM public."SystemUser";

CREATE OR REPLACE VIEW alert_user_view
AS
SELECT * 
FROM public."AlertUser";

CREATE OR REPLACE VIEW alert_history_view
AS
SELECT * 
FROM public."AlertHistory";
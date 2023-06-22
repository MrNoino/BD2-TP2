/*s. Estes utilizadores devem ter acesso de forma rápida aos dados relevantes dos 
seus sistemas tais como estáticas tais como a lista de sistemas com mais alertas, o número de alertas por dia, o número de 
leituras de sensores por hora entre outros. */

DROP MATERIALIZED VIEW IF EXISTS system_more_alerts;
CREATE MATERIALIZED VIEW system_more_alerts
AS 
SELECT "System".id AS "System ID", 
        COUNT("AlertHistory".*) AS "Total Alerts"
FROM public."System"
INNER JOIN public."Sensor"
ON "Sensor".system_id = "System".id
INNER JOIN public."Alert"
ON "Alert".sensor_id = "Sensor".id
INNER JOIN public."AlertHistory"
ON "AlertHistory".alert_id = "Alert".id
GROUP BY "System".id
ORDER BY "Total Alerts" DESC;

DROP MATERIALIZED VIEW IF EXISTS alerts_today;
CREATE MATERIALIZED VIEW alerts_today
AS 
SELECT COUNT( "AlertHistory".*) AS "Total Alerts Today"
FROM public."AlertHistory"
WHERE "AlertHistory".alert_datetime::date = CURRENT_DATE;

DROP MATERIALIZED VIEW IF EXISTS sensor_readings_one_hour;
CREATE MATERIALIZED VIEW sensor_readings_one_hour
AS 
SELECT COUNT( "SensorHistory".*) AS "Total Sensor Readings by 1h"
FROM public."SensorHistory"
WHERE ("SensorHistory".received_datetime at time zone 'UTC') <= CURRENT_TIMESTAMP AND ("SensorHistory".received_datetime at time zone 'UTC') >=  CURRENT_TIMESTAMP - INTERVAL '1 hour';

CREATE OR REPLACE PROCEDURE refresh_materialized_views()
LANGUAGE plpgsql
AS $$
BEGIN

    REFRESH MATERIALIZED VIEW system_more_alerts;

    REFRESH MATERIALIZED VIEW alerts_today;

    REFRESH MATERIALIZED VIEW sensor_readings_one_hour;

END;
$$;

SELECT "Utilizador".* 
FROM public."Utilizador"
WHERE "Utilizador".U_Nome = 'Karine'
AND "Utilizador".U_Password = crypt('a', "Utilizador".U_Password);

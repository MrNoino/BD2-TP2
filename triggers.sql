CREATE OR REPLACE FUNCTION verify_value()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
DECLARE
	r record;
    
BEGIN
	
    FOREACH r IN ARRAY (SELECT "Rule".rule as "rule", "Alert".id as "alert_id","Alert".value as "value"
            FROM public."Rule" 
            INNER JOIN public."Alert" 
            ON "Alert".rule_id = "Rule".id
            WHERE "Alert".sensor_id = NEW.id)
    LOOP

        CASE r.rule
            WHEN '>' THEN
                IF NEW.value > r.value THEN
                    CALL alert_history_insert(r.alert_id, (SELECT now() AT TIME ZONE 'UTC'));
                END IF;
            WHEN '<' THEN
                IF NEW.value < r.value THEN
                    CALL alert_history_insert(r.alert_id, (SELECT now() AT TIME ZONE 'UTC'));
                END IF;
            WHEN '>=' THEN
                IF NEW.value >= r.value THEN
                    CALL alert_history_insert(r.alert_id, (SELECT now() AT TIME ZONE 'UTC'));
                END IF;
            WHEN '<=' THEN
                IF NEW.value <= r.value THEN
                    CALL alert_history_insert(r.alert_id, (SELECT now() AT TIME ZONE 'UTC'));
                END IF;
            WHEN '=' THEN
                IF NEW.value = r.value THEN
                    CALL alert_history_insert(r.alert_id, (SELECT now() AT TIME ZONE 'UTC'));
                END IF;
            WHEN '!=' THEN
                IF NEW.value != r.value THEN
                    CALL alert_history_insert(r.alert_id, (SELECT now() AT TIME ZONE 'UTC'));
                END IF;
        END CASE;

    END LOOP;

    RETURN NEW;

END;
$$;

CREATE OR REPLACE TRIGGER verify_value
AFTER INSERT
ON public."SensorHistory"
FOR EACH ROW
EXECUTE FUNCTION verify_value();

CREATE TRIGGER prevent_rule_manipulation BEFORE INSERT OR UPDATE OR DELETE ON public."Rule"
FOR EACH STATEMENT EEXECUTE FUNCTION pg_catalog.null();
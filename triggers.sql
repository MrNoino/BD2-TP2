CREATE OR REPLACE FUNCTION verify_value()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
DECLARE

	r record;
	
	dt timestamp;
    
BEGIN
	
    FOR r IN SELECT "Rule".rule as "rule", "Alert".id as "alert_id","Alert".value as "value"
            FROM public."Rule" 
            INNER JOIN public."Alert" 
            ON "Alert".rule_id = "Rule".id
            WHERE "Alert".sensor_id = NEW.sensor_id
    LOOP
	
		dt = (SELECT now() AT TIME ZONE 'UTC');

        CASE r.rule
            WHEN '>' THEN
                IF NEW.value::numeric > r.value::numeric THEN
                    CALL alert_history_insert(r.alert_id, dt);
                END IF;
            WHEN '<' THEN
                IF NEW.value::numeric < r.value::numeric THEN
                    CALL alert_history_insert(r.alert_id, dt);
                END IF;
            WHEN '>=' THEN
                IF NEW.value::numeric >= r.value::numeric THEN
                    CALL alert_history_insert(r.alert_id, dt);
                END IF;
            WHEN '<=' THEN
                IF NEW.value::numeric <= r.value::numeric THEN
                    CALL alert_history_insert(r.alert_id, dt);
                END IF;
            WHEN '=' THEN
                IF NEW.value::numeric = r.value::numeric THEN
                    CALL alert_history_insert(r.alert_id, dt);
                END IF;
            WHEN '!=' THEN
                IF NEW.value::numeric != r.value::numeric THEN
                    CALL alert_history_insert(r.alert_id, dt);
                END IF;
			ELSE
				RAISE EXCEPTION 'The rule is not valid!';
			
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

CREATE OR REPLACE FUNCTION prevent_rule_manipulation() 
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
BEGIN
	RAISE EXCEPTION 'Operation not allowed';
	RETURN NULL;
END;
$$;

CREATE OR REPLACE TRIGGER prevent_rule_manipulation 
BEFORE INSERT OR UPDATE OR DELETE ON public."Rule"
FOR EACH STATEMENT EXECUTE FUNCTION prevent_rule_manipulation();

CREATE OR REPLACE FUNCTION prevent_sensor_history_manipulation() 
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
DECLARE 

    inter interval;
	
	datetime timestamp;

BEGIN

	datetime := (NEW.received_datetime at time zone 'UTC');

    inter := (datetime - current_timestamp);

    IF inter > INTERVAL '5 minutes' OR inter < INTERVAL '-5 minutes' THEN

        CALL raise_exception('400', 'BAD REQUEST', 'The date and time is greater or less than 5 minutes');

        RETURN NULL;

    END IF;
	
    RETURN NEW;
	
END;
$$;

CREATE OR REPLACE TRIGGER prevent_sensor_history_manipulation
BEFORE INSERT OR UPDATE ON public."SensorHistory"
FOR EACH ROW EXECUTE FUNCTION prevent_sensor_history_manipulation();
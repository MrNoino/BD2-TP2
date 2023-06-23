--
-- PostgreSQL database dump
--

-- Dumped from database version 15.2 (Debian 15.2-1.pgdg110+1)
-- Dumped by pg_dump version 15.1

-- Started on 2023-06-22 20:36:16

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 2 (class 3079 OID 35348)
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- TOC entry 3686 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- TOC entry 355 (class 1255 OID 35654)
-- Name: actuator_delete(integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.actuator_delete(IN a_owner_id integer, IN a_id integer)
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


ALTER PROCEDURE public.actuator_delete(IN a_owner_id integer, IN a_id integer) OWNER TO a2020126392;

--
-- TOC entry 321 (class 1255 OID 35655)
-- Name: actuator_history_delete(integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.actuator_history_delete(IN a_owner_id integer, IN a_id integer)
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


ALTER PROCEDURE public.actuator_history_delete(IN a_owner_id integer, IN a_id integer) OWNER TO a2020126392;

--
-- TOC entry 371 (class 1255 OID 35632)
-- Name: actuator_history_insert(integer, integer, timestamp without time zone, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.actuator_history_insert(IN a_owner_id integer, IN a_actuator_id integer, IN a_action_datetime timestamp without time zone, IN a_action character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN

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


ALTER PROCEDURE public.actuator_history_insert(IN a_owner_id integer, IN a_actuator_id integer, IN a_action_datetime timestamp without time zone, IN a_action character varying) OWNER TO a2020126392;

--
-- TOC entry 358 (class 1255 OID 35888)
-- Name: actuator_history_insert(integer, integer, timestamp with time zone, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.actuator_history_insert(IN a_owner_id integer, IN a_actuator_id integer, IN a_action_datetime timestamp with time zone, IN a_action character varying)
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


ALTER PROCEDURE public.actuator_history_insert(IN a_owner_id integer, IN a_actuator_id integer, IN a_action_datetime timestamp with time zone, IN a_action character varying) OWNER TO a2020126392;

--
-- TOC entry 326 (class 1255 OID 35817)
-- Name: actuator_history_select(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.actuator_history_select(a_user_id integer, a_id integer) RETURNS TABLE(id integer, actuator_id integer, action_datetime timestamp with time zone, action character varying)
    LANGUAGE plpgsql
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


ALTER FUNCTION public.actuator_history_select(a_user_id integer, a_id integer) OWNER TO a2020126392;

--
-- TOC entry 309 (class 1255 OID 35644)
-- Name: actuator_history_update(integer, integer, integer, timestamp without time zone, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.actuator_history_update(IN a_owner_id integer, IN a_id integer, IN a_actuator_id integer DEFAULT NULL::integer, IN a_action_datetime timestamp without time zone DEFAULT NULL::timestamp without time zone, IN a_action character varying DEFAULT NULL::character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN

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


ALTER PROCEDURE public.actuator_history_update(IN a_owner_id integer, IN a_id integer, IN a_actuator_id integer, IN a_action_datetime timestamp without time zone, IN a_action character varying) OWNER TO a2020126392;

--
-- TOC entry 367 (class 1255 OID 35887)
-- Name: actuator_history_update(integer, integer, integer, timestamp with time zone, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.actuator_history_update(IN a_owner_id integer, IN a_id integer, IN a_actuator_id integer DEFAULT NULL::integer, IN a_action_datetime timestamp with time zone DEFAULT NULL::timestamp with time zone, IN a_action character varying DEFAULT NULL::character varying)
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


ALTER PROCEDURE public.actuator_history_update(IN a_owner_id integer, IN a_id integer, IN a_actuator_id integer, IN a_action_datetime timestamp with time zone, IN a_action character varying) OWNER TO a2020126392;

--
-- TOC entry 315 (class 1255 OID 35816)
-- Name: actuator_history_view(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.actuator_history_view(a_user_id integer) RETURNS TABLE(id integer, actuator_id integer, action_datetime timestamp with time zone, action character varying)
    LANGUAGE plpgsql
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


ALTER FUNCTION public.actuator_history_view(a_user_id integer) OWNER TO a2020126392;

--
-- TOC entry 317 (class 1255 OID 35818)
-- Name: actuator_history_view(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.actuator_history_view(a_user_id integer, a_id integer) RETURNS TABLE(id integer, actuator_id integer, action_datetime timestamp with time zone, action character varying)
    LANGUAGE plpgsql
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


ALTER FUNCTION public.actuator_history_view(a_user_id integer, a_id integer) OWNER TO a2020126392;

--
-- TOC entry 319 (class 1255 OID 35831)
-- Name: actuator_insert(integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.actuator_insert(IN a_owner_id integer, IN a_system_id integer)
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


ALTER PROCEDURE public.actuator_insert(IN a_owner_id integer, IN a_system_id integer) OWNER TO a2020126392;

--
-- TOC entry 313 (class 1255 OID 35829)
-- Name: actuator_select(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.actuator_select(a_user_id integer, a_id integer) RETURNS TABLE(id integer, system_id integer)
    LANGUAGE plpgsql
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


ALTER FUNCTION public.actuator_select(a_user_id integer, a_id integer) OWNER TO a2020126392;

--
-- TOC entry 366 (class 1255 OID 36010)
-- Name: actuator_update(integer, integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.actuator_update(IN a_owner_id integer, IN a_id integer, IN a_system_id integer DEFAULT NULL::integer)
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


ALTER PROCEDURE public.actuator_update(IN a_owner_id integer, IN a_id integer, IN a_system_id integer) OWNER TO a2020126392;

--
-- TOC entry 312 (class 1255 OID 35828)
-- Name: actuator_view(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.actuator_view(a_user_id integer) RETURNS TABLE(id integer, system_id integer)
    LANGUAGE plpgsql
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


ALTER FUNCTION public.actuator_view(a_user_id integer) OWNER TO a2020126392;

--
-- TOC entry 314 (class 1255 OID 35830)
-- Name: actuator_view(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.actuator_view(a_user_id integer, a_id integer) RETURNS TABLE(id integer, system_id integer)
    LANGUAGE plpgsql
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


ALTER FUNCTION public.actuator_view(a_user_id integer, a_id integer) OWNER TO a2020126392;

--
-- TOC entry 373 (class 1255 OID 35658)
-- Name: alert_actuator_delete(integer, integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.alert_actuator_delete(IN a_owner_id integer, IN a_alert_id integer, IN a_actuator_id integer)
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


ALTER PROCEDURE public.alert_actuator_delete(IN a_owner_id integer, IN a_alert_id integer, IN a_actuator_id integer) OWNER TO a2020126392;

--
-- TOC entry 376 (class 1255 OID 35635)
-- Name: alert_actuator_insert(integer, integer, integer, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.alert_actuator_insert(IN a_owner_id integer, IN a_alert_id integer, IN a_actuator_id integer, IN a_action character varying)
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


ALTER PROCEDURE public.alert_actuator_insert(IN a_owner_id integer, IN a_alert_id integer, IN a_actuator_id integer, IN a_action character varying) OWNER TO a2020126392;

--
-- TOC entry 389 (class 1255 OID 35769)
-- Name: alert_actuator_select(integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.alert_actuator_select(a_user_id integer, a_alert_id integer, a_actuator_id integer) RETURNS TABLE(alert_id integer, actuator_id integer, action character varying)
    LANGUAGE plpgsql
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


ALTER FUNCTION public.alert_actuator_select(a_user_id integer, a_alert_id integer, a_actuator_id integer) OWNER TO a2020126392;

--
-- TOC entry 327 (class 1255 OID 35846)
-- Name: alert_actuator_update(integer, integer, integer, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.alert_actuator_update(IN a_owner_id integer, IN a_alert_id integer, IN a_actuator_id integer, IN a_action character varying DEFAULT NULL::character varying)
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


ALTER PROCEDURE public.alert_actuator_update(IN a_owner_id integer, IN a_alert_id integer, IN a_actuator_id integer, IN a_action character varying) OWNER TO a2020126392;

--
-- TOC entry 330 (class 1255 OID 35770)
-- Name: alert_actuator_view(integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.alert_actuator_view(a_user_id integer, a_alert_id integer DEFAULT NULL::integer, a_actuator_id integer DEFAULT NULL::integer) RETURNS TABLE(alert_id integer, actuator_id integer, action character varying)
    LANGUAGE plpgsql
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


ALTER FUNCTION public.alert_actuator_view(a_user_id integer, a_alert_id integer, a_actuator_id integer) OWNER TO a2020126392;

--
-- TOC entry 369 (class 1255 OID 35657)
-- Name: alert_delete(integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.alert_delete(IN a_owner_id integer, IN a_id integer)
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


ALTER PROCEDURE public.alert_delete(IN a_owner_id integer, IN a_id integer) OWNER TO a2020126392;

--
-- TOC entry 372 (class 1255 OID 35662)
-- Name: alert_history_delete(integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.alert_history_delete(IN a_owner_id integer, IN a_id integer)
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


ALTER PROCEDURE public.alert_history_delete(IN a_owner_id integer, IN a_id integer) OWNER TO a2020126392;

--
-- TOC entry 341 (class 1255 OID 35870)
-- Name: alert_history_insert(integer, timestamp without time zone); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.alert_history_insert(IN a_alert_id integer, IN a_alert_datetime timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
BEGIN

    INSERT INTO public."AlertHistory" (alert_id, alert_datetime)
    VALUES
    (a_alert_id, (a_alert_datetime at time zone 'UTC'));

END;
$$;


ALTER PROCEDURE public.alert_history_insert(IN a_alert_id integer, IN a_alert_datetime timestamp without time zone) OWNER TO a2020126392;

--
-- TOC entry 362 (class 1255 OID 35891)
-- Name: alert_history_insert(integer, timestamp with time zone); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.alert_history_insert(IN a_alert_id integer, IN a_alert_datetime timestamp with time zone)
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


ALTER PROCEDURE public.alert_history_insert(IN a_alert_id integer, IN a_alert_datetime timestamp with time zone) OWNER TO a2020126392;

--
-- TOC entry 323 (class 1255 OID 35840)
-- Name: alert_history_insert(integer, integer, timestamp without time zone); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.alert_history_insert(IN a_owner_id integer, IN a_alert_id integer, IN a_alert_datetime timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
BEGIN

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


ALTER PROCEDURE public.alert_history_insert(IN a_owner_id integer, IN a_alert_id integer, IN a_alert_datetime timestamp without time zone) OWNER TO a2020126392;

--
-- TOC entry 361 (class 1255 OID 35890)
-- Name: alert_history_insert(integer, integer, timestamp with time zone); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.alert_history_insert(IN a_owner_id integer, IN a_alert_id integer, IN a_alert_datetime timestamp with time zone)
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


ALTER PROCEDURE public.alert_history_insert(IN a_owner_id integer, IN a_alert_id integer, IN a_alert_datetime timestamp with time zone) OWNER TO a2020126392;

--
-- TOC entry 305 (class 1255 OID 35821)
-- Name: alert_history_select(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.alert_history_select(a_user_id integer, a_id integer) RETURNS TABLE(id integer, alert_id integer, alert_datetime timestamp with time zone)
    LANGUAGE plpgsql
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


ALTER FUNCTION public.alert_history_select(a_user_id integer, a_id integer) OWNER TO a2020126392;

--
-- TOC entry 339 (class 1255 OID 35650)
-- Name: alert_history_update(integer, integer, integer, timestamp without time zone); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.alert_history_update(IN a_owner_id integer, IN a_id integer, IN a_alert_id integer DEFAULT NULL::integer, IN a_alert_datetime timestamp without time zone DEFAULT NULL::timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
BEGIN

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


ALTER PROCEDURE public.alert_history_update(IN a_owner_id integer, IN a_id integer, IN a_alert_id integer, IN a_alert_datetime timestamp without time zone) OWNER TO a2020126392;

--
-- TOC entry 348 (class 1255 OID 35894)
-- Name: alert_history_update(integer, integer, integer, timestamp with time zone); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.alert_history_update(IN a_owner_id integer, IN a_id integer, IN a_alert_id integer DEFAULT NULL::integer, IN a_alert_datetime timestamp with time zone DEFAULT NULL::timestamp with time zone)
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


ALTER PROCEDURE public.alert_history_update(IN a_owner_id integer, IN a_id integer, IN a_alert_id integer, IN a_alert_datetime timestamp with time zone) OWNER TO a2020126392;

--
-- TOC entry 325 (class 1255 OID 35839)
-- Name: alert_history_view(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.alert_history_view(a_user_id integer) RETURNS TABLE(id integer, alert_id integer, alert_datetime timestamp with time zone)
    LANGUAGE plpgsql
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


ALTER FUNCTION public.alert_history_view(a_user_id integer) OWNER TO a2020126392;

--
-- TOC entry 306 (class 1255 OID 35822)
-- Name: alert_history_view(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.alert_history_view(a_user_id integer, a_id integer) RETURNS TABLE(id integer, alert_id integer, alert_datetime timestamp with time zone)
    LANGUAGE plpgsql
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


ALTER FUNCTION public.alert_history_view(a_user_id integer, a_id integer) OWNER TO a2020126392;

--
-- TOC entry 359 (class 1255 OID 35838)
-- Name: alert_insert(integer, integer, integer, character varying, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.alert_insert(IN a_owner_id integer, IN a_sensor_id integer, IN a_rule_id integer, IN a_value character varying, IN a_alert character varying)
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


ALTER PROCEDURE public.alert_insert(IN a_owner_id integer, IN a_sensor_id integer, IN a_rule_id integer, IN a_value character varying, IN a_alert character varying) OWNER TO a2020126392;

--
-- TOC entry 365 (class 1255 OID 35634)
-- Name: alert_insert(integer, integer, character varying, character varying, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.alert_insert(IN a_owner_id integer, IN a_sensor_id integer, IN a_rule character varying, IN a_value character varying, IN a_alert character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN

    IF (SELECT COUNT(*) 
        FROM public."System"
        INNER JOIN public."Sensor"
        ON "Sensor".system_id = "System".id
        WHERE "Sensor".id = a_sensor_id and "System".owner_id = a_owner_id) = 0 THEN

        CALL raise_exception('403', 'FORBIDDEN', 'Don''t have permissions');

    END IF;

    INSERT INTO public."Alert" (sensor_id, rule, value, alert)
    VALUES
    (a_sensor_id, a_rule, a_value, a_alert);

END;
$$;


ALTER PROCEDURE public.alert_insert(IN a_owner_id integer, IN a_sensor_id integer, IN a_rule character varying, IN a_value character varying, IN a_alert character varying) OWNER TO a2020126392;

--
-- TOC entry 386 (class 1255 OID 35767)
-- Name: alert_select(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.alert_select(a_user_id integer, a_id integer) RETURNS TABLE(id integer, sensor_id integer, rule_id integer, value character varying, alert character varying)
    LANGUAGE plpgsql
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


ALTER FUNCTION public.alert_select(a_user_id integer, a_id integer) OWNER TO a2020126392;

--
-- TOC entry 364 (class 1255 OID 35646)
-- Name: alert_update(integer, integer, integer, integer, character varying, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.alert_update(IN a_owner_id integer, IN a_id integer, IN a_sensor_id integer DEFAULT NULL::integer, IN a_rule_id integer DEFAULT NULL::integer, IN a_value character varying DEFAULT NULL::character varying, IN a_alert character varying DEFAULT NULL::character varying)
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


ALTER PROCEDURE public.alert_update(IN a_owner_id integer, IN a_id integer, IN a_sensor_id integer, IN a_rule_id integer, IN a_value character varying, IN a_alert character varying) OWNER TO a2020126392;

--
-- TOC entry 322 (class 1255 OID 35661)
-- Name: alert_user_delete(integer, integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.alert_user_delete(IN a_owner_id integer, IN a_alert_history_id integer, IN a_user_id integer)
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


ALTER PROCEDURE public.alert_user_delete(IN a_owner_id integer, IN a_alert_history_id integer, IN a_user_id integer) OWNER TO a2020126392;

--
-- TOC entry 378 (class 1255 OID 35638)
-- Name: alert_user_insert(integer, integer, timestamp without time zone); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.alert_user_insert(IN a_alert_history_id integer, IN a_user_id integer, IN a_see_datetime timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
BEGIN

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


ALTER PROCEDURE public.alert_user_insert(IN a_alert_history_id integer, IN a_user_id integer, IN a_see_datetime timestamp without time zone) OWNER TO a2020126392;

--
-- TOC entry 360 (class 1255 OID 35889)
-- Name: alert_user_insert(integer, integer, timestamp with time zone); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.alert_user_insert(IN a_alert_history_id integer, IN a_user_id integer, IN a_see_datetime timestamp with time zone)
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


ALTER PROCEDURE public.alert_user_insert(IN a_alert_history_id integer, IN a_user_id integer, IN a_see_datetime timestamp with time zone) OWNER TO a2020126392;

--
-- TOC entry 334 (class 1255 OID 35845)
-- Name: alert_user_update(integer, integer, timestamp without time zone); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.alert_user_update(IN a_alert_history_id integer, IN a_user_id integer, IN a_see_datetime timestamp without time zone DEFAULT NULL::timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
BEGIN

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


ALTER PROCEDURE public.alert_user_update(IN a_alert_history_id integer, IN a_user_id integer, IN a_see_datetime timestamp without time zone) OWNER TO a2020126392;

--
-- TOC entry 354 (class 1255 OID 35893)
-- Name: alert_user_update(integer, integer, timestamp with time zone); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.alert_user_update(IN a_alert_history_id integer, IN a_user_id integer, IN a_see_datetime timestamp with time zone DEFAULT NULL::timestamp with time zone)
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


ALTER PROCEDURE public.alert_user_update(IN a_alert_history_id integer, IN a_user_id integer, IN a_see_datetime timestamp with time zone) OWNER TO a2020126392;

--
-- TOC entry 318 (class 1255 OID 35819)
-- Name: alert_user_view(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.alert_user_view(a_user_id integer) RETURNS TABLE(alert_history_id integer, user_id integer, see_datetime timestamp with time zone)
    LANGUAGE plpgsql
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


ALTER FUNCTION public.alert_user_view(a_user_id integer) OWNER TO a2020126392;

--
-- TOC entry 316 (class 1255 OID 35820)
-- Name: alert_user_view(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.alert_user_view(a_alert_history_id integer, a_user_id integer) RETURNS TABLE(alert_history_id integer, user_id integer, see_datetime timestamp with time zone)
    LANGUAGE plpgsql
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


ALTER FUNCTION public.alert_user_view(a_alert_id integer, a_user_id integer) OWNER TO a2020126392;

--
-- TOC entry 324 (class 1255 OID 35837)
-- Name: alert_view(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.alert_view(a_user_id integer) RETURNS TABLE(id integer, sensor_id integer, rule_id integer, value character varying, alert character varying)
    LANGUAGE plpgsql
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


ALTER FUNCTION public.alert_view(a_user_id integer) OWNER TO a2020126392;

--
-- TOC entry 388 (class 1255 OID 35768)
-- Name: alert_view(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.alert_view(a_user_id integer, a_id integer) RETURNS TABLE(id integer, sensor_id integer, rule_id integer, value character varying, alert character varying)
    LANGUAGE plpgsql
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


ALTER FUNCTION public.alert_view(a_user_id integer, a_id integer) OWNER TO a2020126392;

--
-- TOC entry 335 (class 1255 OID 35866)
-- Name: do_nothing(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.do_nothing() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN NULL;
END;
$$;


ALTER FUNCTION public.do_nothing() OWNER TO a2020126392;

--
-- TOC entry 381 (class 1255 OID 35674)
-- Name: login(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.login(a_email character varying, a_password character varying) RETURNS TABLE(id integer, name character varying, email character varying)
    LANGUAGE plpgsql
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


ALTER FUNCTION public.login(a_email character varying, a_password character varying) OWNER TO a2020126392;

--
-- TOC entry 338 (class 1255 OID 35869)
-- Name: prevent_manipulation(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.prevent_manipulation() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	RAISE EXCEPTION 'Operation not allowed';
	RETURN NULL;
END;
$$;


ALTER FUNCTION public.prevent_manipulation() OWNER TO a2020126392;

--
-- TOC entry 336 (class 1255 OID 35879)
-- Name: prevent_rule_manipulation(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.prevent_rule_manipulation() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	RAISE EXCEPTION 'Operation not allowed';
	RETURN NULL;
END;
$$;


ALTER FUNCTION public.prevent_rule_manipulation() OWNER TO a2020126392;

--
-- TOC entry 337 (class 1255 OID 35880)
-- Name: prevent_sensor_history_manipulation(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.prevent_sensor_history_manipulation() RETURNS trigger
    LANGUAGE plpgsql
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


ALTER FUNCTION public.prevent_sensor_history_manipulation() OWNER TO a2020126392;

--
-- TOC entry 340 (class 1255 OID 35627)
-- Name: raise_exception(character varying, character varying, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.raise_exception(IN a_msg character varying, IN a_detail character varying, IN a_hint character varying)
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


ALTER PROCEDURE public.raise_exception(IN a_msg character varying, IN a_detail character varying, IN a_hint character varying) OWNER TO a2020126392;

--
-- TOC entry 351 (class 1255 OID 35977)
-- Name: refresh_materialized_view(); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.refresh_materialized_view()
    LANGUAGE plpgsql
    AS $$
BEGIN

    REFRESH MATERIALIZED VIEW system_more_alerts;

    REFRESH MATERIALIZED VIEW alerts_today;

    REFRESH MATERIALIZED VIEW sensor_readings_one_hour;

END;
$$;


ALTER PROCEDURE public.refresh_materialized_view() OWNER TO a2020126392;

--
-- TOC entry 352 (class 1255 OID 35991)
-- Name: refresh_materialized_views(); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.refresh_materialized_views()
    LANGUAGE plpgsql
    AS $$
BEGIN

    REFRESH MATERIALIZED VIEW system_more_alerts;

    REFRESH MATERIALIZED VIEW alerts_today;

    REFRESH MATERIALIZED VIEW sensor_readings_one_hour;

END;
$$;


ALTER PROCEDURE public.refresh_materialized_views() OWNER TO a2020126392;

--
-- TOC entry 302 (class 1255 OID 35670)
-- Name: rule_view(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.rule_view(a_id integer) RETURNS TABLE(id integer, rule character varying, description character varying)
    LANGUAGE plpgsql
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


ALTER FUNCTION public.rule_view(a_id integer) OWNER TO a2020126392;

--
-- TOC entry 320 (class 1255 OID 35652)
-- Name: sensor_delete(integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.sensor_delete(IN a_owner_id integer, IN a_id integer)
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


ALTER PROCEDURE public.sensor_delete(IN a_owner_id integer, IN a_id integer) OWNER TO a2020126392;

--
-- TOC entry 349 (class 1255 OID 35656)
-- Name: sensor_history_delete(integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.sensor_history_delete(IN a_owner_id integer, IN a_id integer)
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


ALTER PROCEDURE public.sensor_history_delete(IN a_owner_id integer, IN a_id integer) OWNER TO a2020126392;

--
-- TOC entry 374 (class 1255 OID 35633)
-- Name: sensor_history_insert(integer, integer, timestamp without time zone, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.sensor_history_insert(IN a_owner_id integer, IN a_sensor_id integer, IN a_received_datetime timestamp without time zone, IN a_value character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN

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


ALTER PROCEDURE public.sensor_history_insert(IN a_owner_id integer, IN a_sensor_id integer, IN a_received_datetime timestamp without time zone, IN a_value character varying) OWNER TO a2020126392;

--
-- TOC entry 343 (class 1255 OID 35886)
-- Name: sensor_history_insert(integer, integer, timestamp with time zone, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.sensor_history_insert(IN a_owner_id integer, IN a_sensor_id integer, IN a_received_datetime timestamp with time zone, IN a_value character varying)
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


ALTER PROCEDURE public.sensor_history_insert(IN a_owner_id integer, IN a_sensor_id integer, IN a_received_datetime timestamp with time zone, IN a_value character varying) OWNER TO a2020126392;

--
-- TOC entry 311 (class 1255 OID 35811)
-- Name: sensor_history_select(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sensor_history_select(a_user_id integer, a_id integer) RETURNS TABLE(id integer, sensor_id integer, received_datetime timestamp with time zone, value character varying)
    LANGUAGE plpgsql
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


ALTER FUNCTION public.sensor_history_select(a_user_id integer, a_id integer) OWNER TO a2020126392;

--
-- TOC entry 308 (class 1255 OID 35645)
-- Name: sensor_history_update(integer, integer, integer, timestamp without time zone, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.sensor_history_update(IN a_owner_id integer, IN a_id integer, IN a_sensor_id integer DEFAULT NULL::integer, IN a_received_datetime timestamp without time zone DEFAULT NULL::timestamp without time zone, IN a_value character varying DEFAULT NULL::character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN

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


ALTER PROCEDURE public.sensor_history_update(IN a_owner_id integer, IN a_id integer, IN a_sensor_id integer, IN a_received_datetime timestamp without time zone, IN a_value character varying) OWNER TO a2020126392;

--
-- TOC entry 368 (class 1255 OID 35892)
-- Name: sensor_history_update(integer, integer, integer, timestamp with time zone, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.sensor_history_update(IN a_owner_id integer, IN a_id integer, IN a_sensor_id integer DEFAULT NULL::integer, IN a_received_datetime timestamp with time zone DEFAULT NULL::timestamp with time zone, IN a_value character varying DEFAULT NULL::character varying)
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


ALTER PROCEDURE public.sensor_history_update(IN a_owner_id integer, IN a_id integer, IN a_sensor_id integer, IN a_received_datetime timestamp with time zone, IN a_value character varying) OWNER TO a2020126392;

--
-- TOC entry 304 (class 1255 OID 35810)
-- Name: sensor_history_view(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sensor_history_view(a_user_id integer) RETURNS TABLE(id integer, sensor_id integer, received_datetime timestamp with time zone, value character varying)
    LANGUAGE plpgsql
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


ALTER FUNCTION public.sensor_history_view(a_user_id integer) OWNER TO a2020126392;

--
-- TOC entry 310 (class 1255 OID 35812)
-- Name: sensor_history_view(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sensor_history_view(a_user_id integer, a_id integer) RETURNS TABLE(id integer, sensor_id integer, received_datetime timestamp with time zone, value character varying)
    LANGUAGE plpgsql
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


ALTER FUNCTION public.sensor_history_view(a_user_id integer, a_id integer) OWNER TO a2020126392;

--
-- TOC entry 342 (class 1255 OID 35629)
-- Name: sensor_insert(integer, integer, integer, numeric); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.sensor_insert(IN a_owner_id integer, IN a_sensor_type_id integer, IN a_system_id integer, IN a_inactivity_seconds numeric)
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


ALTER PROCEDURE public.sensor_insert(IN a_owner_id integer, IN a_sensor_type_id integer, IN a_system_id integer, IN a_inactivity_seconds numeric) OWNER TO a2020126392;

--
-- TOC entry 382 (class 1255 OID 35758)
-- Name: sensor_select(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sensor_select(a_user_id integer) RETURNS TABLE(id integer, sensor_type_id integer, system_id integer, inactivity_seconds numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN 

    RETURN QUERY SELECT "Sensor".* 
            FROM public."Sensor"
            INNER JOIN public."System"
            ON "System".id = "Sensor".system_id
            LEFT JOIN public."SystemUser"
            ON "SystemUser".system_id = "System".id
            WHERE "System".owner_id = a_user_id OR "SystemUser".user_id = a_user_id;

END;
$$;


ALTER FUNCTION public.sensor_select(a_user_id integer) OWNER TO a2020126392;

--
-- TOC entry 385 (class 1255 OID 35757)
-- Name: sensor_select(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sensor_select(a_user_id integer, a_id integer) RETURNS TABLE(id integer, sensor_type_id integer, system_id integer, inactivity_seconds numeric)
    LANGUAGE plpgsql
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


ALTER FUNCTION public.sensor_select(a_user_id integer, a_id integer) OWNER TO a2020126392;

--
-- TOC entry 375 (class 1255 OID 35653)
-- Name: sensor_type_delete(integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.sensor_type_delete(IN a_id integer)
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


ALTER PROCEDURE public.sensor_type_delete(IN a_id integer) OWNER TO a2020126392;

--
-- TOC entry 347 (class 1255 OID 35630)
-- Name: sensor_type_insert(character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.sensor_type_insert(IN a_type character varying)
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


ALTER PROCEDURE public.sensor_type_insert(IN a_type character varying) OWNER TO a2020126392;

--
-- TOC entry 379 (class 1255 OID 35642)
-- Name: sensor_type_update(integer, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.sensor_type_update(IN a_id integer, IN a_type character varying DEFAULT NULL::character varying)
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


ALTER PROCEDURE public.sensor_type_update(IN a_id integer, IN a_type character varying) OWNER TO a2020126392;

--
-- TOC entry 345 (class 1255 OID 35665)
-- Name: sensor_type_view(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sensor_type_view(a_id integer) RETURNS TABLE(id integer, type character varying)
    LANGUAGE plpgsql
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


ALTER FUNCTION public.sensor_type_view(a_id integer) OWNER TO a2020126392;

--
-- TOC entry 363 (class 1255 OID 35641)
-- Name: sensor_update(integer, integer, integer, integer, numeric); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.sensor_update(IN a_owner_id integer, IN a_id integer, IN a_sensor_type_id integer DEFAULT NULL::integer, IN a_system_id integer DEFAULT NULL::integer, IN a_inactivity_seconds numeric DEFAULT NULL::numeric)
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


ALTER PROCEDURE public.sensor_update(IN a_owner_id integer, IN a_id integer, IN a_sensor_type_id integer, IN a_system_id integer, IN a_inactivity_seconds numeric) OWNER TO a2020126392;

--
-- TOC entry 393 (class 1255 OID 35801)
-- Name: sensor_view(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sensor_view(a_user_id integer) RETURNS TABLE(id integer, sensor_type_id integer, system_id integer, inactivity_seconds numeric)
    LANGUAGE plpgsql
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


ALTER FUNCTION public.sensor_view(a_user_id integer) OWNER TO a2020126392;

--
-- TOC entry 387 (class 1255 OID 35759)
-- Name: sensor_view(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sensor_view(a_user_id integer, a_id integer) RETURNS TABLE(id integer, sensor_type_id integer, system_id integer, inactivity_seconds numeric)
    LANGUAGE plpgsql
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


ALTER FUNCTION public.sensor_view(a_user_id integer, a_id integer) OWNER TO a2020126392;

--
-- TOC entry 307 (class 1255 OID 35651)
-- Name: system_delete(integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.system_delete(IN a_owner_id integer, IN a_id integer)
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


ALTER PROCEDURE public.system_delete(IN a_owner_id integer, IN a_id integer) OWNER TO a2020126392;

--
-- TOC entry 346 (class 1255 OID 35628)
-- Name: system_insert(character varying, character varying, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.system_insert(IN a_location character varying, IN a_property character varying, IN a_owner_id integer)
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


ALTER PROCEDURE public.system_insert(IN a_location character varying, IN a_property character varying, IN a_owner_id integer) OWNER TO a2020126392;

--
-- TOC entry 384 (class 1255 OID 35754)
-- Name: system_select(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.system_select(a_user_id integer) RETURNS TABLE(id integer, location character varying, property character varying, owner_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN

    RETURN QUERY SELECT "System".* 
            FROM public."System"
            LEFT JOIN public."SystemUser"
            ON "SystemUser".system_id = "System".id
            WHERE "System".owner_id = a_user_id OR "SystemUser".user_id = a_user_id;

END;
$$;


ALTER FUNCTION public.system_select(a_user_id integer) OWNER TO a2020126392;

--
-- TOC entry 383 (class 1255 OID 35753)
-- Name: system_select(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.system_select(a_user_id integer, a_id integer) RETURNS TABLE(id integer, location character varying, property character varying, owner_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN

    RETURN QUERY SELECT "System".* 
            FROM public."System"
            LEFT JOIN public."SystemUser"
            ON "SystemUser".system_id = "System".id
            WHERE "System".id = a_id and ("System".owner_id = a_user_id OR "SystemUser".user_id = a_user_id);

END;
$$;


ALTER FUNCTION public.system_select(a_user_id integer, a_id integer) OWNER TO a2020126392;

--
-- TOC entry 333 (class 1255 OID 35640)
-- Name: system_update(integer, integer, character varying, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.system_update(IN a_owner_id integer, IN a_id integer, IN a_location character varying DEFAULT NULL::character varying, IN a_property character varying DEFAULT NULL::character varying)
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


ALTER PROCEDURE public.system_update(IN a_owner_id integer, IN a_id integer, IN a_location character varying, IN a_property character varying) OWNER TO a2020126392;

--
-- TOC entry 380 (class 1255 OID 35660)
-- Name: system_user_delete(integer, integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.system_user_delete(IN a_owner_id integer, IN a_system_id integer, IN a_user_id integer)
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


ALTER PROCEDURE public.system_user_delete(IN a_owner_id integer, IN a_system_id integer, IN a_user_id integer) OWNER TO a2020126392;

--
-- TOC entry 332 (class 1255 OID 35861)
-- Name: system_user_insert(integer, integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.system_user_insert(IN a_owner_id integer, IN a_system_id integer, IN a_user_id integer)
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


ALTER PROCEDURE public.system_user_insert(IN a_owner_id integer, IN a_system_id integer, IN a_user_id integer) OWNER TO a2020126392;

--
-- TOC entry 331 (class 1255 OID 35857)
-- Name: system_user_select(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.system_user_select(a_owner_id integer) RETURNS TABLE(system_id integer, user_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN 

    RETURN QUERY SELECT "SystemUser".* 
            FROM public."SystemUser"
            INNER JOIN public."System"
            ON "System".id = "SystemUser".system_id
            WHERE "System".owner_id = a_owner_id;

END;
$$;


ALTER FUNCTION public.system_user_select(a_owner_id integer) OWNER TO a2020126392;

--
-- TOC entry 356 (class 1255 OID 35859)
-- Name: system_user_select(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.system_user_select(a_system_id integer, a_user_id integer) RETURNS TABLE(system_id integer, user_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN 

    RETURN QUERY SELECT "SystemUser".* 
            FROM public."SystemUser"
            WHERE "SystemUser".system_id = a_system_id and "SystemUser".user_id = a_user_id;

END;
$$;


ALTER FUNCTION public.system_user_select(a_system_id integer, a_user_id integer) OWNER TO a2020126392;

--
-- TOC entry 353 (class 1255 OID 35858)
-- Name: system_user_view(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.system_user_view(a_owner_id integer) RETURNS TABLE(system_id integer, user_id integer)
    LANGUAGE plpgsql
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


ALTER FUNCTION public.system_user_view(a_owner_id integer) OWNER TO a2020126392;

--
-- TOC entry 357 (class 1255 OID 35860)
-- Name: system_user_view(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.system_user_view(a_system_id integer, a_user_id integer) RETURNS TABLE(system_id integer, user_id integer)
    LANGUAGE plpgsql
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


ALTER FUNCTION public.system_user_view(a_system_id integer, a_user_id integer) OWNER TO a2020126392;

--
-- TOC entry 329 (class 1255 OID 35856)
-- Name: system_view(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.system_view(a_user_id integer) RETURNS TABLE(id integer, location character varying, property character varying, owner_id integer)
    LANGUAGE plpgsql
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


ALTER FUNCTION public.system_view(a_user_id integer) OWNER TO a2020126392;

--
-- TOC entry 328 (class 1255 OID 35855)
-- Name: system_view(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.system_view(a_user_id integer, a_id integer) RETURNS TABLE(id integer, location character varying, property character varying, owner_id integer)
    LANGUAGE plpgsql
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


ALTER FUNCTION public.system_view(a_user_id integer, a_id integer) OWNER TO a2020126392;

--
-- TOC entry 370 (class 1255 OID 35659)
-- Name: user_delete(integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.user_delete(IN a_id integer)
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


ALTER PROCEDURE public.user_delete(IN a_id integer) OWNER TO a2020126392;

--
-- TOC entry 377 (class 1255 OID 35636)
-- Name: user_insert(character varying, character varying, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.user_insert(IN a_name character varying, IN a_email character varying, IN a_password character varying)
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


ALTER PROCEDURE public.user_insert(IN a_name character varying, IN a_email character varying, IN a_password character varying) OWNER TO a2020126392;

--
-- TOC entry 392 (class 1255 OID 35772)
-- Name: user_select(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.user_select(a_user_id integer, a_id integer) RETURNS TABLE(id integer, name character varying, email character varying)
    LANGUAGE plpgsql
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


ALTER FUNCTION public.user_select(a_user_id integer, a_id integer) OWNER TO a2020126392;

--
-- TOC entry 391 (class 1255 OID 35648)
-- Name: user_update(integer, character varying, character varying, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.user_update(IN a_id integer, IN a_name character varying DEFAULT NULL::character varying, IN a_email character varying DEFAULT NULL::character varying, IN a_password character varying DEFAULT NULL::character varying)
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


ALTER PROCEDURE public.user_update(IN a_id integer, IN a_name character varying, IN a_email character varying, IN a_password character varying) OWNER TO a2020126392;

--
-- TOC entry 390 (class 1255 OID 35771)
-- Name: user_view(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.user_view(a_id integer) RETURNS TABLE(id integer, name character varying, email character varying)
    LANGUAGE plpgsql
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


ALTER FUNCTION public.user_view(a_id integer) OWNER TO a2020126392;

--
-- TOC entry 303 (class 1255 OID 35773)
-- Name: user_view(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.user_view(a_user_id integer, a_id integer) RETURNS TABLE(id integer, name character varying, email character varying)
    LANGUAGE plpgsql
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


ALTER FUNCTION public.user_view(a_user_id integer, a_id integer) OWNER TO a2020126392;

--
-- TOC entry 350 (class 1255 OID 35898)
-- Name: verify_system_inactivity(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.verify_system_inactivity(a_system_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE

    sensor_history_row "SensorHistory"%ROWTYPE;

    inactivity_seconds numeric;

    inter interval;
	
	exist boolean := False;

    c CURSOR FOR SELECT "SensorHistory".* 
                            FROM public."SensorHistory"
                            INNER JOIN public."Sensor"
                            ON "Sensor".id = "SensorHistory".sensor_id
                            INNER JOIN public."System"
                            ON "System".id = "Sensor".system_id
                            WHERE "System".id = a_system_id;

BEGIN

	OPEN c;

  	LOOP

		FETCH c INTO sensor_history_row;
		EXIT WHEN NOT FOUND;

		inactivity_seconds = (SELECT "Sensor".inactivity_seconds 
			FROM public."Sensor" 
			INNER JOIN public."SensorHistory" 
			ON "SensorHistory".sensor_id = "Sensor".id 
			WHERE "SensorHistory".id = sensor_history_row.id);

		inter := (current_timestamp - sensor_history_row.received_datetime AT TIME ZONE 'UTC');

		IF inter <= MAKE_INTERVAL(secs => inactivity_seconds::integer) THEN

			exist := True;
			EXIT;

		END IF;
  
  	END LOOP;
  	CLOSE c;
  
  	IF NOT exist THEN
  
  		CALL raise_exception('503', 'SERVICE UNAVAILABLE', ('Inactivity detect on system ' || a_system_id));

	END IF;

END;

$$;


ALTER FUNCTION public.verify_system_inactivity(a_system_id integer) OWNER TO a2020126392;

--
-- TOC entry 344 (class 1255 OID 35864)
-- Name: verify_value(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.verify_value() RETURNS trigger
    LANGUAGE plpgsql
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


ALTER FUNCTION public.verify_value() OWNER TO a2020126392;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 222 (class 1259 OID 35199)
-- Name: Actuator; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Actuator" (
    id integer NOT NULL,
    system_id integer NOT NULL
);


ALTER TABLE public."Actuator" OWNER TO a2020126392;

--
-- TOC entry 224 (class 1259 OID 35208)
-- Name: ActuatorHistory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ActuatorHistory" (
    id integer NOT NULL,
    actuator_id integer NOT NULL,
    action_datetime timestamp with time zone DEFAULT (now() AT TIME ZONE 'utc'::text) NOT NULL,
    action character varying(64) NOT NULL
);


ALTER TABLE public."ActuatorHistory" OWNER TO a2020126392;

--
-- TOC entry 223 (class 1259 OID 35207)
-- Name: ActuatorHistory_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."ActuatorHistory_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."ActuatorHistory_id_seq" OWNER TO a2020126392;

--
-- TOC entry 3689 (class 0 OID 0)
-- Dependencies: 223
-- Name: ActuatorHistory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."ActuatorHistory_id_seq" OWNED BY public."ActuatorHistory".id;


--
-- TOC entry 221 (class 1259 OID 35198)
-- Name: Actuator_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Actuator_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Actuator_id_seq" OWNER TO a2020126392;

--
-- TOC entry 3691 (class 0 OID 0)
-- Dependencies: 221
-- Name: Actuator_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Actuator_id_seq" OWNED BY public."Actuator".id;


--
-- TOC entry 230 (class 1259 OID 35231)
-- Name: Alert; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Alert" (
    id integer NOT NULL,
    sensor_id integer NOT NULL,
    rule_id integer NOT NULL,
    value character varying(256) NOT NULL,
    alert character varying(256) NOT NULL
);


ALTER TABLE public."Alert" OWNER TO a2020126392;

--
-- TOC entry 232 (class 1259 OID 35240)
-- Name: AlertActuator; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."AlertActuator" (
    alert_id integer NOT NULL,
    actuator_id integer NOT NULL,
    action character varying(64) NOT NULL
);


ALTER TABLE public."AlertActuator" OWNER TO a2020126392;

--
-- TOC entry 231 (class 1259 OID 35239)
-- Name: AlertActuator_alert_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."AlertActuator_alert_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."AlertActuator_alert_id_seq" OWNER TO a2020126392;

--
-- TOC entry 3695 (class 0 OID 0)
-- Dependencies: 231
-- Name: AlertActuator_alert_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."AlertActuator_alert_id_seq" OWNED BY public."AlertActuator".alert_id;


--
-- TOC entry 238 (class 1259 OID 35267)
-- Name: AlertHistory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."AlertHistory" (
    id integer NOT NULL,
    alert_id integer NOT NULL,
    alert_datetime timestamp with time zone NOT NULL
);


ALTER TABLE public."AlertHistory" OWNER TO a2020126392;

--
-- TOC entry 237 (class 1259 OID 35266)
-- Name: AlertHistory_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."AlertHistory_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."AlertHistory_id_seq" OWNER TO a2020126392;

--
-- TOC entry 3698 (class 0 OID 0)
-- Dependencies: 237
-- Name: AlertHistory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."AlertHistory_id_seq" OWNED BY public."AlertHistory".id;


--
-- TOC entry 236 (class 1259 OID 35260)
-- Name: AlertUser; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."AlertUser" (
    alert_history_id integer NOT NULL,
    user_id integer NOT NULL,
    see_datetime timestamp with time zone DEFAULT (now() AT TIME ZONE 'utc'::text) NOT NULL
);


ALTER TABLE public."AlertUser" OWNER TO a2020126392;

--
-- TOC entry 229 (class 1259 OID 35230)
-- Name: Alert_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Alert_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Alert_id_seq" OWNER TO a2020126392;

--
-- TOC entry 3701 (class 0 OID 0)
-- Dependencies: 229
-- Name: Alert_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Alert_id_seq" OWNED BY public."Alert".id;


--
-- TOC entry 228 (class 1259 OID 35224)
-- Name: Rule; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Rule" (
    id integer NOT NULL,
    rule character varying(16) NOT NULL,
    description character varying(256)
);


ALTER TABLE public."Rule" OWNER TO a2020126392;

--
-- TOC entry 227 (class 1259 OID 35223)
-- Name: Rule_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Rule_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Rule_id_seq" OWNER TO a2020126392;

--
-- TOC entry 3704 (class 0 OID 0)
-- Dependencies: 227
-- Name: Rule_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Rule_id_seq" OWNED BY public."Rule".id;


--
-- TOC entry 218 (class 1259 OID 35183)
-- Name: Sensor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Sensor" (
    id integer NOT NULL,
    sensor_type_id integer NOT NULL,
    system_id integer NOT NULL,
    inactivity_seconds numeric NOT NULL
);


ALTER TABLE public."Sensor" OWNER TO a2020126392;

--
-- TOC entry 226 (class 1259 OID 35216)
-- Name: SensorHistory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SensorHistory" (
    id integer NOT NULL,
    sensor_id integer NOT NULL,
    received_datetime timestamp with time zone DEFAULT (now() AT TIME ZONE 'utc'::text) NOT NULL,
    value character varying(256) NOT NULL
);


ALTER TABLE public."SensorHistory" OWNER TO a2020126392;

--
-- TOC entry 225 (class 1259 OID 35215)
-- Name: SensorHistory_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."SensorHistory_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."SensorHistory_id_seq" OWNER TO a2020126392;

--
-- TOC entry 3708 (class 0 OID 0)
-- Dependencies: 225
-- Name: SensorHistory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."SensorHistory_id_seq" OWNED BY public."SensorHistory".id;


--
-- TOC entry 220 (class 1259 OID 35192)
-- Name: SensorType; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SensorType" (
    id integer NOT NULL,
    type character varying(256) NOT NULL
);


ALTER TABLE public."SensorType" OWNER TO a2020126392;

--
-- TOC entry 219 (class 1259 OID 35191)
-- Name: SensorType_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."SensorType_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."SensorType_id_seq" OWNER TO a2020126392;

--
-- TOC entry 3711 (class 0 OID 0)
-- Dependencies: 219
-- Name: SensorType_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."SensorType_id_seq" OWNED BY public."SensorType".id;


--
-- TOC entry 217 (class 1259 OID 35182)
-- Name: Sensor_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Sensor_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Sensor_id_seq" OWNER TO a2020126392;

--
-- TOC entry 3713 (class 0 OID 0)
-- Dependencies: 217
-- Name: Sensor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Sensor_id_seq" OWNED BY public."Sensor".id;


--
-- TOC entry 216 (class 1259 OID 35174)
-- Name: System; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."System" (
    id integer NOT NULL,
    location character varying(256) NOT NULL,
    property character varying(256) NOT NULL,
    owner_id integer NOT NULL
);


ALTER TABLE public."System" OWNER TO a2020126392;

--
-- TOC entry 235 (class 1259 OID 35255)
-- Name: SystemUser; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SystemUser" (
    system_id integer NOT NULL,
    user_id integer NOT NULL
);


ALTER TABLE public."SystemUser" OWNER TO a2020126392;

--
-- TOC entry 215 (class 1259 OID 35173)
-- Name: System_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."System_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."System_id_seq" OWNER TO a2020126392;

--
-- TOC entry 3717 (class 0 OID 0)
-- Dependencies: 215
-- Name: System_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."System_id_seq" OWNED BY public."System".id;


--
-- TOC entry 234 (class 1259 OID 35247)
-- Name: User; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."User" (
    id integer NOT NULL,
    name character varying(256) NOT NULL,
    email character varying(256) NOT NULL,
    password character varying(256) NOT NULL
);


ALTER TABLE public."User" OWNER TO a2020126392;

--
-- TOC entry 233 (class 1259 OID 35246)
-- Name: User_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."User_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."User_id_seq" OWNER TO a2020126392;

--
-- TOC entry 3720 (class 0 OID 0)
-- Dependencies: 233
-- Name: User_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."User_id_seq" OWNED BY public."User".id;


--
-- TOC entry 243 (class 1259 OID 35698)
-- Name: actuator_history_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.actuator_history_view AS
 SELECT "ActuatorHistory".id,
    "ActuatorHistory".actuator_id,
    "ActuatorHistory".action_datetime,
    "ActuatorHistory".action
   FROM public."ActuatorHistory";


ALTER TABLE public.actuator_history_view OWNER TO a2020126392;

--
-- TOC entry 246 (class 1259 OID 35710)
-- Name: alert_actuator_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.alert_actuator_view AS
 SELECT "AlertActuator".alert_id,
    "AlertActuator".actuator_id,
    "AlertActuator".action
   FROM public."AlertActuator";


ALTER TABLE public.alert_actuator_view OWNER TO a2020126392;

--
-- TOC entry 250 (class 1259 OID 35726)
-- Name: alert_history_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.alert_history_view AS
 SELECT "AlertHistory".id,
    "AlertHistory".alert_id,
    "AlertHistory".alert_datetime
   FROM public."AlertHistory";


ALTER TABLE public.alert_history_view OWNER TO a2020126392;

--
-- TOC entry 249 (class 1259 OID 35722)
-- Name: alert_user_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.alert_user_view AS
 SELECT "AlertUser".alert_history_id,
    "AlertUser".user_id,
    "AlertUser".see_datetime
   FROM public."AlertUser";


ALTER TABLE public.alert_user_view OWNER TO a2020126392;

--
-- TOC entry 245 (class 1259 OID 35706)
-- Name: alert_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.alert_view AS
 SELECT "Alert".id,
    "Alert".sensor_id,
    "Alert".rule_id,
    "Alert".value,
    "Alert".alert
   FROM public."Alert";


ALTER TABLE public.alert_view OWNER TO a2020126392;

--
-- TOC entry 253 (class 1259 OID 35983)
-- Name: alerts_today; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.alerts_today AS
 SELECT count("AlertHistory".*) AS "Total Alerts Today"
   FROM public."AlertHistory"
  WHERE (("AlertHistory".alert_datetime)::date = CURRENT_DATE)
  WITH NO DATA;


ALTER TABLE public.alerts_today OWNER TO a2020126392;

--
-- TOC entry 244 (class 1259 OID 35702)
-- Name: rule_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.rule_view AS
 SELECT "Rule".id,
    "Rule".rule,
    "Rule".description
   FROM public."Rule";


ALTER TABLE public.rule_view OWNER TO a2020126392;

--
-- TOC entry 242 (class 1259 OID 35690)
-- Name: sensor_history_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.sensor_history_view AS
 SELECT "SensorHistory".id,
    "SensorHistory".sensor_id,
    "SensorHistory".received_datetime,
    "SensorHistory".value
   FROM public."SensorHistory";


ALTER TABLE public.sensor_history_view OWNER TO a2020126392;

--
-- TOC entry 254 (class 1259 OID 35987)
-- Name: sensor_readings_one_hour; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.sensor_readings_one_hour AS
 SELECT count("SensorHistory".*) AS "Total Sensor Readings by 1h"
   FROM public."SensorHistory"
  WHERE ((("SensorHistory".received_datetime AT TIME ZONE 'UTC'::text) <= CURRENT_TIMESTAMP) AND (("SensorHistory".received_datetime AT TIME ZONE 'UTC'::text) >= (CURRENT_TIMESTAMP - '01:00:00'::interval)))
  WITH NO DATA;


ALTER TABLE public.sensor_readings_one_hour OWNER TO a2020126392;

--
-- TOC entry 241 (class 1259 OID 35686)
-- Name: sensor_type_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.sensor_type_view AS
 SELECT "SensorType".id,
    "SensorType".type
   FROM public."SensorType";


ALTER TABLE public.sensor_type_view OWNER TO a2020126392;

--
-- TOC entry 240 (class 1259 OID 35682)
-- Name: sensor_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.sensor_view AS
 SELECT "Sensor".id,
    "Sensor".sensor_type_id,
    "Sensor".system_id,
    "Sensor".inactivity_seconds
   FROM public."Sensor";


ALTER TABLE public.sensor_view OWNER TO a2020126392;

--
-- TOC entry 251 (class 1259 OID 35904)
-- Name: statistics; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.statistics AS
 SELECT count("System".*) AS "N. Systems",
    count("Sensor".*) AS "N. Sensors",
    count("Actuator".*) AS "N. Actuators"
   FROM public."System",
    public."Sensor",
    public."Actuator"
  WITH NO DATA;


ALTER TABLE public.statistics OWNER TO a2020126392;

--
-- TOC entry 252 (class 1259 OID 35978)
-- Name: system_more_alerts; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.system_more_alerts AS
 SELECT "System".id AS "System ID",
    count("AlertHistory".*) AS "Total Alerts"
   FROM (((public."System"
     JOIN public."Sensor" ON (("Sensor".system_id = "System".id)))
     JOIN public."Alert" ON (("Alert".sensor_id = "Sensor".id)))
     JOIN public."AlertHistory" ON (("AlertHistory".alert_id = "Alert".id)))
  GROUP BY "System".id
  ORDER BY (count("AlertHistory".*)) DESC
  WITH NO DATA;


ALTER TABLE public.system_more_alerts OWNER TO a2020126392;

--
-- TOC entry 248 (class 1259 OID 35718)
-- Name: system_user_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.system_user_view AS
 SELECT "SystemUser".system_id,
    "SystemUser".user_id
   FROM public."SystemUser";


ALTER TABLE public.system_user_view OWNER TO a2020126392;

--
-- TOC entry 239 (class 1259 OID 35678)
-- Name: system_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.system_view AS
 SELECT "System".id,
    "System".location,
    "System".property,
    "System".owner_id
   FROM public."System";


ALTER TABLE public.system_view OWNER TO a2020126392;

--
-- TOC entry 247 (class 1259 OID 35714)
-- Name: user_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.user_view AS
 SELECT "User".id,
    "User".name,
    "User".email
   FROM public."User";


ALTER TABLE public.user_view OWNER TO a2020126392;

--
-- TOC entry 3430 (class 2604 OID 35202)
-- Name: Actuator id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Actuator" ALTER COLUMN id SET DEFAULT nextval('public."Actuator_id_seq"'::regclass);


--
-- TOC entry 3431 (class 2604 OID 35211)
-- Name: ActuatorHistory id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ActuatorHistory" ALTER COLUMN id SET DEFAULT nextval('public."ActuatorHistory_id_seq"'::regclass);


--
-- TOC entry 3436 (class 2604 OID 35234)
-- Name: Alert id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Alert" ALTER COLUMN id SET DEFAULT nextval('public."Alert_id_seq"'::regclass);


--
-- TOC entry 3437 (class 2604 OID 35243)
-- Name: AlertActuator alert_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AlertActuator" ALTER COLUMN alert_id SET DEFAULT nextval('public."AlertActuator_alert_id_seq"'::regclass);


--
-- TOC entry 3440 (class 2604 OID 35270)
-- Name: AlertHistory id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AlertHistory" ALTER COLUMN id SET DEFAULT nextval('public."AlertHistory_id_seq"'::regclass);


--
-- TOC entry 3435 (class 2604 OID 35227)
-- Name: Rule id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Rule" ALTER COLUMN id SET DEFAULT nextval('public."Rule_id_seq"'::regclass);


--
-- TOC entry 3428 (class 2604 OID 35186)
-- Name: Sensor id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Sensor" ALTER COLUMN id SET DEFAULT nextval('public."Sensor_id_seq"'::regclass);


--
-- TOC entry 3433 (class 2604 OID 35219)
-- Name: SensorHistory id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SensorHistory" ALTER COLUMN id SET DEFAULT nextval('public."SensorHistory_id_seq"'::regclass);


--
-- TOC entry 3429 (class 2604 OID 35195)
-- Name: SensorType id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SensorType" ALTER COLUMN id SET DEFAULT nextval('public."SensorType_id_seq"'::regclass);


--
-- TOC entry 3427 (class 2604 OID 35177)
-- Name: System id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."System" ALTER COLUMN id SET DEFAULT nextval('public."System_id_seq"'::regclass);


--
-- TOC entry 3438 (class 2604 OID 35250)
-- Name: User id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."User" ALTER COLUMN id SET DEFAULT nextval('public."User_id_seq"'::regclass);


--
-- TOC entry 3659 (class 0 OID 35199)
-- Dependencies: 222
-- Data for Name: Actuator; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Actuator" (id, system_id) VALUES (2, 1);


--
-- TOC entry 3661 (class 0 OID 35208)
-- Dependencies: 224
-- Data for Name: ActuatorHistory; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."ActuatorHistory" (id, actuator_id, action_datetime, action) VALUES (1, 2, '2023-05-26 13:00:00+00', 'Off');


--
-- TOC entry 3667 (class 0 OID 35231)
-- Dependencies: 230
-- Data for Name: Alert; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Alert" (id, sensor_id, rule_id, value, alert) VALUES (1, 1, 1, '30', 'Valor acima do esperado');


--
-- TOC entry 3669 (class 0 OID 35240)
-- Dependencies: 232
-- Data for Name: AlertActuator; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."AlertActuator" (alert_id, actuator_id, action) VALUES (1, 2, 'ON');


--
-- TOC entry 3675 (class 0 OID 35267)
-- Dependencies: 238
-- Data for Name: AlertHistory; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."AlertHistory" (id, alert_id, alert_datetime) VALUES (1, 1, '2023-06-12 11:00:00+00');
INSERT INTO public."AlertHistory" (id, alert_id, alert_datetime) VALUES (3, 1, '2023-06-16 11:02:09.681432+00');
INSERT INTO public."AlertHistory" (id, alert_id, alert_datetime) VALUES (4, 1, '2023-06-20 17:45:13.193993+00');
INSERT INTO public."AlertHistory" (id, alert_id, alert_datetime) VALUES (5, 1, '2023-06-20 17:45:55.212594+00');
INSERT INTO public."AlertHistory" (id, alert_id, alert_datetime) VALUES (6, 1, '2023-06-20 17:46:23.227556+00');
INSERT INTO public."AlertHistory" (id, alert_id, alert_datetime) VALUES (7, 1, '2023-06-20 17:54:18.280172+00');
INSERT INTO public."AlertHistory" (id, alert_id, alert_datetime) VALUES (8, 1, '2023-06-20 18:58:09.204731+00');
INSERT INTO public."AlertHistory" (id, alert_id, alert_datetime) VALUES (9, 1, '2023-06-21 10:27:23.144036+00');
INSERT INTO public."AlertHistory" (id, alert_id, alert_datetime) VALUES (10, 1, '2023-06-21 10:46:39.011288+00');
INSERT INTO public."AlertHistory" (id, alert_id, alert_datetime) VALUES (11, 1, '2023-06-21 11:11:28.13641+00');
INSERT INTO public."AlertHistory" (id, alert_id, alert_datetime) VALUES (12, 1, '2023-06-21 11:36:37.42954+00');
INSERT INTO public."AlertHistory" (id, alert_id, alert_datetime) VALUES (13, 1, '2023-06-21 11:42:48.094511+00');
INSERT INTO public."AlertHistory" (id, alert_id, alert_datetime) VALUES (14, 1, '2023-06-21 19:01:43.213329+00');
INSERT INTO public."AlertHistory" (id, alert_id, alert_datetime) VALUES (15, 1, '2023-06-21 20:33:03.187106+00');
INSERT INTO public."AlertHistory" (id, alert_id, alert_datetime) VALUES (16, 1, '2023-06-22 19:12:06.876111+00');


--
-- TOC entry 3673 (class 0 OID 35260)
-- Dependencies: 236
-- Data for Name: AlertUser; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."AlertUser" (alert_history_id, user_id, see_datetime) VALUES (1, 3, '2023-06-09 21:00:00+00');


--
-- TOC entry 3665 (class 0 OID 35224)
-- Dependencies: 228
-- Data for Name: Rule; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Rule" (id, rule, description) VALUES (1, '>', 'Maior que');
INSERT INTO public."Rule" (id, rule, description) VALUES (2, '<', 'Menor que');
INSERT INTO public."Rule" (id, rule, description) VALUES (3, '>=', 'Maior ou igual que');
INSERT INTO public."Rule" (id, rule, description) VALUES (4, '<=', 'Menor ou igual que');
INSERT INTO public."Rule" (id, rule, description) VALUES (5, '=', 'Igual a');
INSERT INTO public."Rule" (id, rule, description) VALUES (6, '!=', 'Diferente de');


--
-- TOC entry 3655 (class 0 OID 35183)
-- Dependencies: 218
-- Data for Name: Sensor; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Sensor" (id, sensor_type_id, system_id, inactivity_seconds) VALUES (1, 1, 1, 1000);


--
-- TOC entry 3663 (class 0 OID 35216)
-- Dependencies: 226
-- Data for Name: SensorHistory; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."SensorHistory" (id, sensor_id, received_datetime, value) VALUES (1, 1, '2023-06-08 20:00:00+00', '15');
INSERT INTO public."SensorHistory" (id, sensor_id, received_datetime, value) VALUES (42, 1, '2023-06-20 19:00:00+00', '35');
INSERT INTO public."SensorHistory" (id, sensor_id, received_datetime, value) VALUES (46, 1, '2023-06-21 11:15:00+00', '35');
INSERT INTO public."SensorHistory" (id, sensor_id, received_datetime, value) VALUES (48, 1, '2023-06-21 11:40:00+00', '35');
INSERT INTO public."SensorHistory" (id, sensor_id, received_datetime, value) VALUES (50, 1, '2023-06-21 11:40:00+00', '35');
INSERT INTO public."SensorHistory" (id, sensor_id, received_datetime, value) VALUES (51, 1, '2023-06-21 19:00:00+00', '35');
INSERT INTO public."SensorHistory" (id, sensor_id, received_datetime, value) VALUES (52, 1, '2023-06-21 20:30:00+00', '35');
INSERT INTO public."SensorHistory" (id, sensor_id, received_datetime, value) VALUES (53, 1, '2023-06-22 19:15:00+00', '35');


--
-- TOC entry 3657 (class 0 OID 35192)
-- Dependencies: 220
-- Data for Name: SensorType; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."SensorType" (id, type) VALUES (1, 'Gás');


--
-- TOC entry 3653 (class 0 OID 35174)
-- Dependencies: 216
-- Data for Name: System; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."System" (id, location, property, owner_id) VALUES (1, 'OHP', 'Quinta das Telhas', 3);


--
-- TOC entry 3672 (class 0 OID 35255)
-- Dependencies: 235
-- Data for Name: SystemUser; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."SystemUser" (system_id, user_id) VALUES (1, 2);


--
-- TOC entry 3671 (class 0 OID 35247)
-- Dependencies: 234
-- Data for Name: User; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."User" (id, name, email, password) VALUES (2, 'Joel', 'joel@gmail.com', '$2a$06$OAKYWFZ1ol9cWc03CVK/f.QVoPUQRIIBgnXJWyBKlGA83cXjSagyS');
INSERT INTO public."User" (id, name, email, password) VALUES (4, 'Joel Coelho', 'joel@gmail.com', '$2a$06$fM.8n0VeLrsSJFYcPWieSedHjjY.b7yC68614YTp8yNkz56VbMzci');
INSERT INTO public."User" (id, name, email, password) VALUES (3, 'Nuno Lopes', 'nuno@gmail.com', '$2a$06$pw/MJ51aYqQbWSjuHVxI/u/NvBklYjjXiA3ua.DjsEM9d9cFY.ehC');


--
-- TOC entry 3734 (class 0 OID 0)
-- Dependencies: 223
-- Name: ActuatorHistory_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."ActuatorHistory_id_seq"', 2, true);


--
-- TOC entry 3735 (class 0 OID 0)
-- Dependencies: 221
-- Name: Actuator_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Actuator_id_seq"', 3, true);


--
-- TOC entry 3736 (class 0 OID 0)
-- Dependencies: 231
-- Name: AlertActuator_alert_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."AlertActuator_alert_id_seq"', 1, false);


--
-- TOC entry 3737 (class 0 OID 0)
-- Dependencies: 237
-- Name: AlertHistory_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."AlertHistory_id_seq"', 16, true);


--
-- TOC entry 3738 (class 0 OID 0)
-- Dependencies: 229
-- Name: Alert_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Alert_id_seq"', 2, true);


--
-- TOC entry 3739 (class 0 OID 0)
-- Dependencies: 227
-- Name: Rule_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Rule_id_seq"', 7, true);


--
-- TOC entry 3740 (class 0 OID 0)
-- Dependencies: 225
-- Name: SensorHistory_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."SensorHistory_id_seq"', 53, true);


--
-- TOC entry 3741 (class 0 OID 0)
-- Dependencies: 219
-- Name: SensorType_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."SensorType_id_seq"', 2, true);


--
-- TOC entry 3742 (class 0 OID 0)
-- Dependencies: 217
-- Name: Sensor_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Sensor_id_seq"', 2, true);


--
-- TOC entry 3743 (class 0 OID 0)
-- Dependencies: 215
-- Name: System_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."System_id_seq"', 2, true);


--
-- TOC entry 3744 (class 0 OID 0)
-- Dependencies: 233
-- Name: User_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."User_id_seq"', 4, true);


--
-- TOC entry 3451 (class 2606 OID 35214)
-- Name: ActuatorHistory ActuatorHistory_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ActuatorHistory"
    ADD CONSTRAINT "ActuatorHistory_pkey" PRIMARY KEY (id);


--
-- TOC entry 3449 (class 2606 OID 35206)
-- Name: Actuator Actuator_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Actuator"
    ADD CONSTRAINT "Actuator_pkey" PRIMARY KEY (id);


--
-- TOC entry 3460 (class 2606 OID 35245)
-- Name: AlertActuator AlertActuator_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AlertActuator"
    ADD CONSTRAINT "AlertActuator_pkey" PRIMARY KEY (alert_id, actuator_id);


--
-- TOC entry 3469 (class 2606 OID 35272)
-- Name: AlertHistory AlertHistory_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AlertHistory"
    ADD CONSTRAINT "AlertHistory_pkey" PRIMARY KEY (id);


--
-- TOC entry 3467 (class 2606 OID 35265)
-- Name: AlertUser AlertUser_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AlertUser"
    ADD CONSTRAINT "AlertUser_pkey" PRIMARY KEY (alert_history_id, user_id);


--
-- TOC entry 3457 (class 2606 OID 35238)
-- Name: Alert Alert_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Alert"
    ADD CONSTRAINT "Alert_pkey" PRIMARY KEY (id);


--
-- TOC entry 3455 (class 2606 OID 35229)
-- Name: Rule Rule_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Rule"
    ADD CONSTRAINT "Rule_pkey" PRIMARY KEY (id);


--
-- TOC entry 3453 (class 2606 OID 35222)
-- Name: SensorHistory SensorHistory_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SensorHistory"
    ADD CONSTRAINT "SensorHistory_pkey" PRIMARY KEY (id);


--
-- TOC entry 3447 (class 2606 OID 35197)
-- Name: SensorType SensorType_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SensorType"
    ADD CONSTRAINT "SensorType_pkey" PRIMARY KEY (id);


--
-- TOC entry 3445 (class 2606 OID 35190)
-- Name: Sensor Sensor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Sensor"
    ADD CONSTRAINT "Sensor_pkey" PRIMARY KEY (id);


--
-- TOC entry 3465 (class 2606 OID 35259)
-- Name: SystemUser SystemUser_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SystemUser"
    ADD CONSTRAINT "SystemUser_pkey" PRIMARY KEY (system_id, user_id);


--
-- TOC entry 3442 (class 2606 OID 35181)
-- Name: System System_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."System"
    ADD CONSTRAINT "System_pkey" PRIMARY KEY (id);


--
-- TOC entry 3462 (class 2606 OID 35254)
-- Name: User User_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_pkey" PRIMARY KEY (id);


--
-- TOC entry 3458 (class 1259 OID 35910)
-- Name: alert_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX alert_index ON public."Alert" USING btree (id, sensor_id);


--
-- TOC entry 3443 (class 1259 OID 35909)
-- Name: system_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX system_index ON public."System" USING btree (id, owner_id);


--
-- TOC entry 3463 (class 1259 OID 35911)
-- Name: user_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX user_index ON public."User" USING btree (email, password);


--
-- TOC entry 3642 (class 2618 OID 35734)
-- Name: Actuator remove_actuator_dependencies; Type: RULE; Schema: public; Owner: postgres
--

CREATE RULE remove_actuator_dependencies AS
    ON DELETE TO public."Actuator" DO ( DELETE FROM public."ActuatorHistory"
  WHERE ("ActuatorHistory".actuator_id = old.id);
 DELETE FROM public."AlertActuator"
  WHERE ("AlertActuator".actuator_id = old.id);
);


--
-- TOC entry 3646 (class 2618 OID 35738)
-- Name: Alert remove_alert_dependencies; Type: RULE; Schema: public; Owner: postgres
--

CREATE RULE remove_alert_dependencies AS
    ON DELETE TO public."Alert" DO ( DELETE FROM public."AlertHistory"
  WHERE ("AlertHistory".alert_id = old.id);
 DELETE FROM public."AlertActuator"
  WHERE ("AlertActuator".alert_id = old.id);
);


--
-- TOC entry 3643 (class 2618 OID 35735)
-- Name: Sensor remove_sensor_dependencies; Type: RULE; Schema: public; Owner: postgres
--

CREATE RULE remove_sensor_dependencies AS
    ON DELETE TO public."Sensor" DO  DELETE FROM public."SensorHistory"
  WHERE ("SensorHistory".sensor_id = old.id);


--
-- TOC entry 3645 (class 2618 OID 35737)
-- Name: SensorType remove_sensor_type_dependencies; Type: RULE; Schema: public; Owner: postgres
--

CREATE RULE remove_sensor_type_dependencies AS
    ON DELETE TO public."SensorType" DO  DELETE FROM public."Sensor"
  WHERE ("Sensor".sensor_type_id = old.id);


--
-- TOC entry 3644 (class 2618 OID 35736)
-- Name: System remove_system_dependencies; Type: RULE; Schema: public; Owner: postgres
--

CREATE RULE remove_system_dependencies AS
    ON DELETE TO public."System" DO ( DELETE FROM public."Sensor"
  WHERE ("Sensor".system_id = old.id);
 DELETE FROM public."Actuator"
  WHERE ("Actuator".system_id = old.id);
);


--
-- TOC entry 3647 (class 2618 OID 35739)
-- Name: Alert remove_user_dependencies; Type: RULE; Schema: public; Owner: postgres
--

CREATE RULE remove_user_dependencies AS
    ON DELETE TO public."Alert" DO ( DELETE FROM public."SystemUser"
  WHERE ("SystemUser".user_id = old.id);
 DELETE FROM public."System"
  WHERE ("System".owner_id = old.id);
 DELETE FROM public."AlertUser"
  WHERE ("AlertUser".user_id = old.id);
);


--
-- TOC entry 3487 (class 2620 OID 35867)
-- Name: Rule prevent_rule_manipulation; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER prevent_rule_manipulation BEFORE INSERT OR DELETE OR UPDATE ON public."Rule" FOR EACH STATEMENT EXECUTE FUNCTION public.prevent_rule_manipulation();


--
-- TOC entry 3485 (class 2620 OID 35881)
-- Name: SensorHistory prevent_sensor_history_manipulation; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER prevent_sensor_history_manipulation BEFORE INSERT OR UPDATE ON public."SensorHistory" FOR EACH ROW EXECUTE FUNCTION public.prevent_sensor_history_manipulation();


--
-- TOC entry 3486 (class 2620 OID 35865)
-- Name: SensorHistory verify_value; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER verify_value AFTER INSERT ON public."SensorHistory" FOR EACH ROW EXECUTE FUNCTION public.verify_value();


--
-- TOC entry 3474 (class 2606 OID 35293)
-- Name: ActuatorHistory ActuatorHistory_actuator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ActuatorHistory"
    ADD CONSTRAINT "ActuatorHistory_actuator_id_fkey" FOREIGN KEY (actuator_id) REFERENCES public."Actuator"(id);


--
-- TOC entry 3473 (class 2606 OID 35288)
-- Name: Actuator Actuator_system_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Actuator"
    ADD CONSTRAINT "Actuator_system_id_fkey" FOREIGN KEY (system_id) REFERENCES public."System"(id);


--
-- TOC entry 3478 (class 2606 OID 35318)
-- Name: AlertActuator AlertActuator_actuator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AlertActuator"
    ADD CONSTRAINT "AlertActuator_actuator_id_fkey" FOREIGN KEY (actuator_id) REFERENCES public."Actuator"(id);


--
-- TOC entry 3479 (class 2606 OID 35313)
-- Name: AlertActuator AlertActuator_alert_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AlertActuator"
    ADD CONSTRAINT "AlertActuator_alert_id_fkey" FOREIGN KEY (alert_id) REFERENCES public."Alert"(id);


--
-- TOC entry 3484 (class 2606 OID 35343)
-- Name: AlertHistory AlertHistory_alert_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AlertHistory"
    ADD CONSTRAINT "AlertHistory_alert_id_fkey" FOREIGN KEY (alert_id) REFERENCES public."Alert"(id);


--
-- TOC entry 3482 (class 2606 OID 35333)
-- Name: AlertUser AlertUser_alert_history_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AlertUser"
    ADD CONSTRAINT "AlertUser_alert_history_id_fkey" FOREIGN KEY (alert_history_id) REFERENCES public."AlertHistory"(id);


--
-- TOC entry 3483 (class 2606 OID 35338)
-- Name: AlertUser AlertUser_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AlertUser"
    ADD CONSTRAINT "AlertUser_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public."User"(id);


--
-- TOC entry 3476 (class 2606 OID 35308)
-- Name: Alert Alert_rule_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Alert"
    ADD CONSTRAINT "Alert_rule_id_fkey" FOREIGN KEY (rule_id) REFERENCES public."Rule"(id);


--
-- TOC entry 3477 (class 2606 OID 35303)
-- Name: Alert Alert_sensor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Alert"
    ADD CONSTRAINT "Alert_sensor_id_fkey" FOREIGN KEY (sensor_id) REFERENCES public."Sensor"(id);


--
-- TOC entry 3475 (class 2606 OID 35298)
-- Name: SensorHistory SensorHistory_sensor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SensorHistory"
    ADD CONSTRAINT "SensorHistory_sensor_id_fkey" FOREIGN KEY (sensor_id) REFERENCES public."Sensor"(id);


--
-- TOC entry 3471 (class 2606 OID 35278)
-- Name: Sensor Sensor_sensor_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Sensor"
    ADD CONSTRAINT "Sensor_sensor_type_id_fkey" FOREIGN KEY (sensor_type_id) REFERENCES public."SensorType"(id);


--
-- TOC entry 3472 (class 2606 OID 35283)
-- Name: Sensor Sensor_system_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Sensor"
    ADD CONSTRAINT "Sensor_system_id_fkey" FOREIGN KEY (system_id) REFERENCES public."System"(id);


--
-- TOC entry 3480 (class 2606 OID 35323)
-- Name: SystemUser SystemUser_system_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SystemUser"
    ADD CONSTRAINT "SystemUser_system_id_fkey" FOREIGN KEY (system_id) REFERENCES public."System"(id);


--
-- TOC entry 3481 (class 2606 OID 35328)
-- Name: SystemUser SystemUser_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SystemUser"
    ADD CONSTRAINT "SystemUser_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public."User"(id);


--
-- TOC entry 3470 (class 2606 OID 35273)
-- Name: System System_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."System"
    ADD CONSTRAINT "System_owner_id_fkey" FOREIGN KEY (owner_id) REFERENCES public."User"(id);


--
-- TOC entry 3685 (class 0 OID 0)
-- Dependencies: 6
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

REFRESH MATERIALIZED VIEW public.alerts_today;


--
-- TOC entry 3679 (class 0 OID 35987)
-- Dependencies: 254 3681
-- Name: sensor_readings_one_hour; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: postgres
--

REFRESH MATERIALIZED VIEW public.sensor_readings_one_hour;


--
-- TOC entry 3676 (class 0 OID 35904)
-- Dependencies: 251 3681
-- Name: statistics; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: postgres
--

REFRESH MATERIALIZED VIEW public.statistics;


--
-- TOC entry 3677 (class 0 OID 35978)
-- Dependencies: 252 3681
-- Name: system_more_alerts; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: postgres
--

REFRESH MATERIALIZED VIEW public.system_more_alerts;


-- Completed on 2023-06-22 20:36:16

--
-- PostgreSQL database dump complete
--


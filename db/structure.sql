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
-- Name: fuzzystrmatch; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;


--
-- Name: EXTENSION fuzzystrmatch; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: que_validate_tags(jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.que_validate_tags(tags_array jsonb) RETURNS boolean
    LANGUAGE sql
    AS $$
  SELECT bool_and(
    jsonb_typeof(value) = 'string'
    AND
    char_length(value::text) <= 100
  )
  FROM jsonb_array_elements(tags_array)
$$;


SET default_tablespace = '';

--
-- Name: que_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.que_jobs (
    priority smallint DEFAULT 100 NOT NULL,
    run_at timestamp with time zone DEFAULT now() NOT NULL,
    id bigint NOT NULL,
    job_class text NOT NULL,
    error_count integer DEFAULT 0 NOT NULL,
    last_error_message text,
    queue text DEFAULT 'default'::text NOT NULL,
    last_error_backtrace text,
    finished_at timestamp with time zone,
    expired_at timestamp with time zone,
    args jsonb DEFAULT '[]'::jsonb NOT NULL,
    data jsonb DEFAULT '{}'::jsonb NOT NULL,
    CONSTRAINT error_length CHECK (((char_length(last_error_message) <= 500) AND (char_length(last_error_backtrace) <= 10000))),
    CONSTRAINT job_class_length CHECK ((char_length(
CASE job_class
    WHEN 'ActiveJob::QueueAdapters::QueAdapter::JobWrapper'::text THEN ((args -> 0) ->> 'job_class'::text)
    ELSE job_class
END) <= 200)),
    CONSTRAINT queue_length CHECK ((char_length(queue) <= 100)),
    CONSTRAINT valid_args CHECK ((jsonb_typeof(args) = 'array'::text)),
    CONSTRAINT valid_data CHECK (((jsonb_typeof(data) = 'object'::text) AND ((NOT (data ? 'tags'::text)) OR ((jsonb_typeof((data -> 'tags'::text)) = 'array'::text) AND (jsonb_array_length((data -> 'tags'::text)) <= 5) AND public.que_validate_tags((data -> 'tags'::text))))))
)
WITH (fillfactor='90');


--
-- Name: TABLE que_jobs; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.que_jobs IS '4';


--
-- Name: que_determine_job_state(public.que_jobs); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.que_determine_job_state(job public.que_jobs) RETURNS text
    LANGUAGE sql
    AS $$
  SELECT
    CASE
    WHEN job.expired_at  IS NOT NULL    THEN 'expired'
    WHEN job.finished_at IS NOT NULL    THEN 'finished'
    WHEN job.error_count > 0            THEN 'errored'
    WHEN job.run_at > CURRENT_TIMESTAMP THEN 'scheduled'
    ELSE                                     'ready'
    END
$$;


--
-- Name: que_job_notify(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.que_job_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  DECLARE
    locker_pid integer;
    sort_key json;
  BEGIN
    -- Don't do anything if the job is scheduled for a future time.
    IF NEW.run_at IS NOT NULL AND NEW.run_at > now() THEN
      RETURN null;
    END IF;

    -- Pick a locker to notify of the job's insertion, weighted by their number
    -- of workers. Should bounce pseudorandomly between lockers on each
    -- invocation, hence the md5-ordering, but still touch each one equally,
    -- hence the modulo using the job_id.
    SELECT pid
    INTO locker_pid
    FROM (
      SELECT *, last_value(row_number) OVER () + 1 AS count
      FROM (
        SELECT *, row_number() OVER () - 1 AS row_number
        FROM (
          SELECT *
          FROM public.que_lockers ql, generate_series(1, ql.worker_count) AS id
          WHERE listening AND queues @> ARRAY[NEW.queue]
          ORDER BY md5(pid::text || id::text)
        ) t1
      ) t2
    ) t3
    WHERE NEW.id % count = row_number;

    IF locker_pid IS NOT NULL THEN
      -- There's a size limit to what can be broadcast via LISTEN/NOTIFY, so
      -- rather than throw errors when someone enqueues a big job, just
      -- broadcast the most pertinent information, and let the locker query for
      -- the record after it's taken the lock. The worker will have to hit the
      -- DB in order to make sure the job is still visible anyway.
      SELECT row_to_json(t)
      INTO sort_key
      FROM (
        SELECT
          'job_available' AS message_type,
          NEW.queue       AS queue,
          NEW.priority    AS priority,
          NEW.id          AS id,
          -- Make sure we output timestamps as UTC ISO 8601
          to_char(NEW.run_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS.US"Z"') AS run_at
      ) t;

      PERFORM pg_notify('que_listener_' || locker_pid::text, sort_key::text);
    END IF;

    RETURN null;
  END
$$;


--
-- Name: que_state_notify(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.que_state_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  DECLARE
    row record;
    message json;
    previous_state text;
    current_state text;
  BEGIN
    IF TG_OP = 'INSERT' THEN
      previous_state := 'nonexistent';
      current_state  := public.que_determine_job_state(NEW);
      row            := NEW;
    ELSIF TG_OP = 'DELETE' THEN
      previous_state := public.que_determine_job_state(OLD);
      current_state  := 'nonexistent';
      row            := OLD;
    ELSIF TG_OP = 'UPDATE' THEN
      previous_state := public.que_determine_job_state(OLD);
      current_state  := public.que_determine_job_state(NEW);

      -- If the state didn't change, short-circuit.
      IF previous_state = current_state THEN
        RETURN null;
      END IF;

      row := NEW;
    ELSE
      RAISE EXCEPTION 'Unrecognized TG_OP: %', TG_OP;
    END IF;

    SELECT row_to_json(t)
    INTO message
    FROM (
      SELECT
        'job_change' AS message_type,
        row.id       AS id,
        row.queue    AS queue,

        coalesce(row.data->'tags', '[]'::jsonb) AS tags,

        to_char(row.run_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS.US"Z"') AS run_at,
        to_char(now()      AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS.US"Z"') AS time,

        CASE row.job_class
        WHEN 'ActiveJob::QueueAdapters::QueAdapter::JobWrapper' THEN
          coalesce(
            row.args->0->>'job_class',
            'ActiveJob::QueueAdapters::QueAdapter::JobWrapper'
          )
        ELSE
          row.job_class
        END AS job_class,

        previous_state AS previous_state,
        current_state  AS current_state
    ) t;

    PERFORM pg_notify('que_state', message::text);

    RETURN null;
  END
$$;


--
-- Name: queue_classic_notify(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.queue_classic_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ BEGIN
  perform pg_notify(new.q_name, ''); RETURN NULL;
END $$;


--
-- Name: age_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.age_groups (
    id integer NOT NULL,
    name character varying,
    season_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    year_of_birth_from integer,
    year_of_birth_to integer,
    gender character varying,
    status integer DEFAULT 0,
    started_on date,
    ended_on date,
    players_per_team integer,
    minutes_per_half integer,
    tenant_id bigint,
    training_only boolean DEFAULT false
);


--
-- Name: age_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.age_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: age_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.age_groups_id_seq OWNED BY public.age_groups.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: club_data_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.club_data_logs (
    id bigint NOT NULL,
    source character varying,
    level integer,
    body character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    tenant_id bigint
);


--
-- Name: club_data_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.club_data_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: club_data_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.club_data_logs_id_seq OWNED BY public.club_data_logs.id;


--
-- Name: club_data_team_competitions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.club_data_team_competitions (
    competition_id bigint NOT NULL,
    club_data_team_id bigint NOT NULL,
    id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    tenant_id bigint
);


--
-- Name: club_data_team_competitions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.club_data_team_competitions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: club_data_team_competitions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.club_data_team_competitions_id_seq OWNED BY public.club_data_team_competitions.id;


--
-- Name: club_data_teams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.club_data_teams (
    id bigint NOT NULL,
    teamcode integer NOT NULL,
    teamnaam character varying,
    spelsoort character varying,
    geslacht character varying,
    teamsoort character varying,
    leeftijdscategorie character varying,
    kalespelsoort character varying,
    speeldag character varying,
    speeldagteam character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    active boolean DEFAULT true,
    season_id bigint,
    tenant_id bigint
);


--
-- Name: club_data_teams_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.club_data_teams_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: club_data_teams_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.club_data_teams_id_seq OWNED BY public.club_data_teams.id;


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comments (
    id integer NOT NULL,
    body text,
    user_id integer,
    comment_type integer DEFAULT 0,
    commentable_type character varying,
    commentable_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    private boolean DEFAULT false,
    tenant_id bigint
);


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.comments_id_seq OWNED BY public.comments.id;


--
-- Name: competitions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.competitions (
    id bigint NOT NULL,
    poulecode integer NOT NULL,
    competitienaam character varying,
    klasse character varying,
    poule character varying,
    klassepoule character varying,
    competitiesoort character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    active boolean DEFAULT true,
    ranking json,
    remark text,
    user_modified boolean DEFAULT false,
    tenant_id bigint
);


--
-- Name: competitions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.competitions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: competitions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.competitions_id_seq OWNED BY public.competitions.id;


--
-- Name: email_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.email_logs (
    id bigint NOT NULL,
    "from" character varying,
    "to" character varying,
    subject character varying,
    body text,
    body_plain text,
    user_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    tenant_id bigint
);


--
-- Name: email_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.email_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: email_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.email_logs_id_seq OWNED BY public.email_logs.id;


--
-- Name: favorites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites (
    id integer NOT NULL,
    user_id integer,
    favorable_type character varying,
    favorable_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    tenant_id bigint
);


--
-- Name: favorites_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.favorites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: favorites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.favorites_id_seq OWNED BY public.favorites.id;


--
-- Name: field_positions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.field_positions (
    id bigint NOT NULL,
    name character varying,
    "position" integer DEFAULT 0,
    indent_in_select boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_blank boolean DEFAULT false,
    line_parent_id bigint,
    axis_parent_id bigint,
    tenant_id bigint,
    position_type integer
);


--
-- Name: field_positions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.field_positions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: field_positions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.field_positions_id_seq OWNED BY public.field_positions.id;


--
-- Name: field_positions_team_members; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.field_positions_team_members (
    field_position_id bigint NOT NULL,
    team_member_id bigint NOT NULL
);


--
-- Name: group_members; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.group_members (
    id bigint NOT NULL,
    group_id bigint,
    member_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    memberable_type character varying,
    memberable_id bigint,
    tenant_id bigint,
    status integer DEFAULT 1,
    started_on date,
    ended_on date,
    description character varying
);


--
-- Name: group_members_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.group_members_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: group_members_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.group_members_id_seq OWNED BY public.group_members.id;


--
-- Name: groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.groups (
    id bigint NOT NULL,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    memberable_via_type character varying,
    tenant_id bigint,
    status integer DEFAULT 1,
    started_on date,
    ended_on date
);


--
-- Name: groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.groups_id_seq OWNED BY public.groups.id;


--
-- Name: groups_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.groups_roles (
    group_id bigint,
    role_id bigint
);


--
-- Name: injuries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.injuries (
    id bigint NOT NULL,
    started_on date,
    ended_on date,
    title character varying,
    body text,
    user_id bigint,
    member_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    tenant_id bigint
);


--
-- Name: injuries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.injuries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: injuries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.injuries_id_seq OWNED BY public.injuries.id;


--
-- Name: logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.logs (
    id bigint NOT NULL,
    logable_type character varying,
    logable_id bigint,
    user_id bigint,
    body text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    tenant_id bigint
);


--
-- Name: logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.logs_id_seq OWNED BY public.logs.id;


--
-- Name: matches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.matches (
    id bigint NOT NULL,
    wedstrijddatum timestamp without time zone,
    wedstrijdcode integer,
    wedstrijdnummer integer,
    thuisteam character varying,
    uitteam character varying,
    thuisteamclubrelatiecode character varying,
    uitteamclubrelatiecode character varying,
    accommodatie character varying,
    plaats character varying,
    wedstrijd character varying,
    thuisteamid integer,
    uitteamid integer,
    competition_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    remark text,
    user_modified boolean DEFAULT false,
    uitslag character varying,
    eigenteam boolean DEFAULT false,
    uitslag_at timestamp without time zone,
    adres character varying,
    postcode character varying,
    telefoonnummer character varying,
    route character varying,
    afgelast boolean DEFAULT false,
    afgelast_status character varying,
    created_by_id bigint,
    edit_level integer DEFAULT 0,
    tenant_id bigint,
    ends_at timestamp without time zone
);


--
-- Name: matches_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.matches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: matches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.matches_id_seq OWNED BY public.matches.id;


--
-- Name: matches_teams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.matches_teams (
    match_id bigint NOT NULL,
    team_id bigint NOT NULL
);


--
-- Name: members; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.members (
    id integer NOT NULL,
    first_name character varying,
    middle_name character varying,
    last_name character varying,
    born_on date,
    address character varying,
    zipcode character varying,
    city character varying,
    country character varying,
    phone character varying,
    phone2 character varying,
    email character varying,
    email2 character varying,
    gender character varying,
    member_number character varying,
    association_number character varying,
    active boolean DEFAULT true,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id integer,
    email_2 character varying,
    phone_2 character varying,
    initials character varying,
    conduct_number character varying,
    sport_category character varying,
    status character varying,
    full_name_2 character varying,
    last_change_at date,
    privacy_level character varying,
    street character varying,
    house_number character varying,
    house_number_addition character varying,
    phone_home character varying,
    phone_parent character varying,
    phone_parent_2 character varying,
    email_parent character varying,
    email_parent_2 character varying,
    registered_at date,
    deregistered_at date,
    member_since date,
    age_category character varying,
    local_teams character varying,
    club_sports character varying,
    association_sports character varying,
    person_type character varying,
    injured boolean DEFAULT false,
    full_name character varying,
    photo character varying,
    missed_import_on timestamp without time zone,
    tenant_id bigint
);


--
-- Name: members_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.members_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: members_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.members_id_seq OWNED BY public.members.id;


--
-- Name: members_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.members_users (
    member_id bigint NOT NULL,
    user_id bigint NOT NULL
);


--
-- Name: notes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notes (
    id bigint NOT NULL,
    title character varying,
    body text,
    user_id bigint,
    team_id bigint,
    member_id bigint,
    visibility integer DEFAULT 0,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    tenant_id bigint
);


--
-- Name: notes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notes_id_seq OWNED BY public.notes.id;


--
-- Name: play_bans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.play_bans (
    id bigint NOT NULL,
    member_id bigint,
    started_on date,
    ended_on date,
    play_ban_type integer,
    body text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    tenant_id bigint
);


--
-- Name: play_bans_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.play_bans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: play_bans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.play_bans_id_seq OWNED BY public.play_bans.id;


--
-- Name: player_evaluations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.player_evaluations (
    id integer NOT NULL,
    team_evaluation_id integer,
    advise_next_season character varying,
    field_1 character varying,
    field_2 character varying,
    field_3 character varying,
    field_4 character varying,
    field_5 character varying,
    field_6 character varying,
    field_7 character varying,
    field_8 character varying,
    field_9 character varying,
    field_10 character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    remark text,
    team_member_id bigint,
    tenant_id bigint
);


--
-- Name: player_evaluations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.player_evaluations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: player_evaluations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.player_evaluations_id_seq OWNED BY public.player_evaluations.id;


--
-- Name: presences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.presences (
    id bigint NOT NULL,
    presentable_type character varying,
    presentable_id bigint,
    member_id bigint,
    is_present boolean DEFAULT true,
    on_time integer DEFAULT 0,
    signed_off integer DEFAULT 0,
    remark text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    team_id bigint,
    tenant_id bigint,
    own_player boolean DEFAULT true,
    minutes_played integer
);


--
-- Name: presences_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.presences_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: presences_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.presences_id_seq OWNED BY public.presences.id;


--
-- Name: que_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.que_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: que_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.que_jobs_id_seq OWNED BY public.que_jobs.id;


--
-- Name: que_lockers; Type: TABLE; Schema: public; Owner: -
--

CREATE UNLOGGED TABLE public.que_lockers (
    pid integer NOT NULL,
    worker_count integer NOT NULL,
    worker_priorities integer[] NOT NULL,
    ruby_pid integer NOT NULL,
    ruby_hostname text NOT NULL,
    queues text[] NOT NULL,
    listening boolean NOT NULL,
    CONSTRAINT valid_queues CHECK (((array_ndims(queues) = 1) AND (array_length(queues, 1) IS NOT NULL))),
    CONSTRAINT valid_worker_priorities CHECK (((array_ndims(worker_priorities) = 1) AND (array_length(worker_priorities, 1) IS NOT NULL)))
);


--
-- Name: que_values; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.que_values (
    key text NOT NULL,
    value jsonb DEFAULT '{}'::jsonb NOT NULL,
    CONSTRAINT valid_value CHECK ((jsonb_typeof(value) = 'object'::text))
)
WITH (fillfactor='90');


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id bigint NOT NULL,
    name character varying,
    resource_type character varying,
    resource_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    description text,
    body text,
    tenant_id bigint
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: seasons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.seasons (
    id integer NOT NULL,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    status integer DEFAULT 0,
    started_on date,
    ended_on date,
    tenant_id bigint
);


--
-- Name: seasons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seasons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seasons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.seasons_id_seq OWNED BY public.seasons.id;


--
-- Name: soccer_fields; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.soccer_fields (
    id bigint NOT NULL,
    name character varying,
    training boolean DEFAULT false,
    match boolean DEFAULT true,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    tenant_id bigint
);


--
-- Name: soccer_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.soccer_fields_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: soccer_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.soccer_fields_id_seq OWNED BY public.soccer_fields.id;


--
-- Name: team_evaluation_configs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.team_evaluation_configs (
    id bigint NOT NULL,
    name character varying,
    status integer DEFAULT 0,
    config jsonb,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    tenant_id bigint
);


--
-- Name: team_evaluation_configs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.team_evaluation_configs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: team_evaluation_configs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.team_evaluation_configs_id_seq OWNED BY public.team_evaluation_configs.id;


--
-- Name: team_evaluations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.team_evaluations (
    id integer NOT NULL,
    team_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    invited_at timestamp without time zone,
    finished_at timestamp without time zone,
    invited_by_id bigint,
    finished_by_id bigint,
    private boolean DEFAULT false,
    tenant_id bigint,
    config jsonb,
    hide_remark_from_player boolean DEFAULT false
);


--
-- Name: team_evaluations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.team_evaluations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: team_evaluations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.team_evaluations_id_seq OWNED BY public.team_evaluations.id;


--
-- Name: team_members; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.team_members (
    id integer NOT NULL,
    member_id integer,
    team_id integer,
    role integer DEFAULT 0,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    prefered_foot character varying,
    status integer DEFAULT 0,
    started_on date,
    ended_on date,
    tenant_id bigint
);


--
-- Name: team_members_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.team_members_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: team_members_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.team_members_id_seq OWNED BY public.team_members.id;


--
-- Name: team_members_training_schedules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.team_members_training_schedules (
    team_member_id bigint NOT NULL,
    training_schedule_id bigint NOT NULL
);


--
-- Name: teams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.teams (
    id integer NOT NULL,
    name character varying,
    age_group_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    status integer DEFAULT 0,
    started_on date,
    ended_on date,
    division character varying,
    remark text,
    players_per_team integer,
    minutes_per_half integer,
    club_data_team_id bigint,
    uuid uuid DEFAULT public.uuid_generate_v4(),
    tenant_id bigint
);


--
-- Name: teams_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.teams_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: teams_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.teams_id_seq OWNED BY public.teams.id;


--
-- Name: tenant_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenant_settings (
    id bigint NOT NULL,
    tenant_id bigint,
    application_name character varying DEFAULT 'TeamPlan'::character varying,
    application_hostname character varying DEFAULT 'teamplan.defrog.nl'::character varying,
    application_email character varying DEFAULT 'helpdesk@defrog.nl'::character varying,
    application_contact_name character varying DEFAULT 'Thimo Jansen'::character varying,
    application_maintenance boolean DEFAULT false,
    application_favicon_url character varying DEFAULT '/favicon.ico'::character varying,
    application_sysadmin_email character varying DEFAULT 'thimo@teamplanpro.nl'::character varying,
    club_name character varying DEFAULT 'Defrog'::character varying,
    club_name_short character varying DEFAULT 'Defrog'::character varying,
    club_website character varying DEFAULT 'https://teamplan.defrog.nl/'::character varying,
    club_sportscenter character varying,
    club_address character varying,
    club_zip character varying,
    club_city character varying,
    club_phone character varying,
    club_relatiecode character varying,
    club_logo_url character varying,
    club_member_administration_email character varying,
    clubdata_urls_competities character varying DEFAULT 'https://data.sportlink.com/teams?teamsoort=bond&spelsoort=ve&gebruiklokaleteamgegevens=NEE'::character varying,
    clubdata_urls_poulestand character varying DEFAULT 'https://data.sportlink.com/poulestand?gebruiklokaleteamgegevens=NEE'::character varying,
    clubdata_urls_poule_programma character varying DEFAULT 'https://data.sportlink.com/poule-programma?eigenwedstrijden=NEE&gebruiklokaleteamgegevens=NEE&aantaldagen=365&weekoffset=-2'::character varying,
    clubdata_urls_pouleuitslagen character varying DEFAULT 'https://data.sportlink.com/pouleuitslagen?eigenwedstrijden=NEE&gebruiklokaleteamgegevens=NEE&aantaldagen=30&weekoffset=-4&'::character varying,
    clubdata_urls_uitslagen character varying DEFAULT 'https://data.sportlink.com/uitslagen?aantalregels=300&gebruiklokaleteamgegevens=NEE&sorteervolgorde=datum-omgekeerd&thuis=JA&uit=JA'::character varying,
    clubdata_urls_team_indeling character varying DEFAULT 'https://data.sportlink.com/team-indeling?lokaleteamcode=-1&teampersoonrol=ALLES&toonlidfoto=JA'::character varying,
    clubdata_urls_wedstrijd_accommodatie character varying DEFAULT 'https://data.sportlink.com/wedstrijd-accommodatie'::character varying,
    clubdata_urls_afgelastingen character varying DEFAULT 'https://data.sportlink.com/afgelastingen?aantalregels=100&weekoffset=-1'::character varying,
    clubdata_urls_club_logos character varying DEFAULT 'http://bin617.website-voetbal.nl/sites/voetbal.nl/files/knvblogos/'::character varying,
    clubdata_client_id character varying,
    google_maps_base_url character varying DEFAULT 'https://www.google.com/maps/embed/v1/'::character varying,
    google_maps_api_key character varying,
    google_analytics_tracking_id character varying,
    sportlink_members_encoding character varying DEFAULT 'utf-8'::character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    last_import_members timestamp without time zone,
    fontawesome_kit_nr character varying,
    voetbalassist_referee_url character varying
);


--
-- Name: tenant_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tenant_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tenant_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tenant_settings_id_seq OWNED BY public.tenant_settings.id;


--
-- Name: tenants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenants (
    id bigint NOT NULL,
    name character varying,
    subdomain character varying,
    domain character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    status integer DEFAULT 1,
    host character varying
);


--
-- Name: tenants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tenants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tenants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tenants_id_seq OWNED BY public.tenants.id;


--
-- Name: todos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.todos (
    id bigint NOT NULL,
    user_id bigint,
    body text,
    waiting boolean DEFAULT false,
    finished boolean DEFAULT false,
    todoable_type character varying,
    todoable_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    started_on date,
    ended_on date,
    tenant_id bigint
);


--
-- Name: todos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.todos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: todos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.todos_id_seq OWNED BY public.todos.id;


--
-- Name: training_schedules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.training_schedules (
    id bigint NOT NULL,
    day integer,
    start_time time without time zone,
    end_time time without time zone,
    field_part integer,
    soccer_field_id bigint,
    team_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    cios boolean DEFAULT false,
    active boolean DEFAULT true,
    present_minutes integer DEFAULT 0,
    tenant_id bigint,
    started_on date,
    ended_on date
);


--
-- Name: training_schedules_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.training_schedules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: training_schedules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.training_schedules_id_seq OWNED BY public.training_schedules.id;


--
-- Name: trainings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trainings (
    id bigint NOT NULL,
    training_schedule_id bigint,
    active boolean DEFAULT true,
    started_at timestamp without time zone,
    ended_at timestamp without time zone,
    user_modified boolean DEFAULT false,
    body text,
    remark text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    team_id bigint,
    tenant_id bigint
);


--
-- Name: trainings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.trainings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trainings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.trainings_id_seq OWNED BY public.trainings.id;


--
-- Name: user_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_settings (
    id bigint NOT NULL,
    tenant_id bigint,
    user_id bigint,
    name character varying,
    value text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: user_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_settings_id_seq OWNED BY public.user_settings.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    last_sign_in_ip inet,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    role integer DEFAULT 0,
    first_name character varying,
    middle_name character varying,
    last_name character varying,
    confirmation_token character varying,
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    unconfirmed_email character varying,
    uuid uuid DEFAULT public.uuid_generate_v4(),
    status integer DEFAULT 1,
    tenant_id bigint
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: users_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users_roles (
    user_id bigint,
    role_id bigint
);


--
-- Name: version_updates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.version_updates (
    id bigint NOT NULL,
    released_at timestamp without time zone,
    name character varying,
    body text,
    for_role integer DEFAULT 0,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: version_updates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.version_updates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: version_updates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.version_updates_id_seq OWNED BY public.version_updates.id;


--
-- Name: versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.versions (
    id bigint NOT NULL,
    item_type character varying NOT NULL,
    item_id integer NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object json,
    created_at timestamp without time zone,
    object_changes text
);


--
-- Name: versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.versions_id_seq OWNED BY public.versions.id;


--
-- Name: age_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.age_groups ALTER COLUMN id SET DEFAULT nextval('public.age_groups_id_seq'::regclass);


--
-- Name: club_data_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.club_data_logs ALTER COLUMN id SET DEFAULT nextval('public.club_data_logs_id_seq'::regclass);


--
-- Name: club_data_team_competitions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.club_data_team_competitions ALTER COLUMN id SET DEFAULT nextval('public.club_data_team_competitions_id_seq'::regclass);


--
-- Name: club_data_teams id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.club_data_teams ALTER COLUMN id SET DEFAULT nextval('public.club_data_teams_id_seq'::regclass);


--
-- Name: comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments ALTER COLUMN id SET DEFAULT nextval('public.comments_id_seq'::regclass);


--
-- Name: competitions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.competitions ALTER COLUMN id SET DEFAULT nextval('public.competitions_id_seq'::regclass);


--
-- Name: email_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_logs ALTER COLUMN id SET DEFAULT nextval('public.email_logs_id_seq'::regclass);


--
-- Name: favorites id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: field_positions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.field_positions ALTER COLUMN id SET DEFAULT nextval('public.field_positions_id_seq'::regclass);


--
-- Name: group_members id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_members ALTER COLUMN id SET DEFAULT nextval('public.group_members_id_seq'::regclass);


--
-- Name: groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups ALTER COLUMN id SET DEFAULT nextval('public.groups_id_seq'::regclass);


--
-- Name: injuries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.injuries ALTER COLUMN id SET DEFAULT nextval('public.injuries_id_seq'::regclass);


--
-- Name: logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.logs ALTER COLUMN id SET DEFAULT nextval('public.logs_id_seq'::regclass);


--
-- Name: matches id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.matches ALTER COLUMN id SET DEFAULT nextval('public.matches_id_seq'::regclass);


--
-- Name: members id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.members ALTER COLUMN id SET DEFAULT nextval('public.members_id_seq'::regclass);


--
-- Name: notes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes ALTER COLUMN id SET DEFAULT nextval('public.notes_id_seq'::regclass);


--
-- Name: play_bans id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.play_bans ALTER COLUMN id SET DEFAULT nextval('public.play_bans_id_seq'::regclass);


--
-- Name: player_evaluations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.player_evaluations ALTER COLUMN id SET DEFAULT nextval('public.player_evaluations_id_seq'::regclass);


--
-- Name: presences id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.presences ALTER COLUMN id SET DEFAULT nextval('public.presences_id_seq'::regclass);


--
-- Name: que_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.que_jobs ALTER COLUMN id SET DEFAULT nextval('public.que_jobs_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: seasons id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.seasons ALTER COLUMN id SET DEFAULT nextval('public.seasons_id_seq'::regclass);


--
-- Name: soccer_fields id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.soccer_fields ALTER COLUMN id SET DEFAULT nextval('public.soccer_fields_id_seq'::regclass);


--
-- Name: team_evaluation_configs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_evaluation_configs ALTER COLUMN id SET DEFAULT nextval('public.team_evaluation_configs_id_seq'::regclass);


--
-- Name: team_evaluations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_evaluations ALTER COLUMN id SET DEFAULT nextval('public.team_evaluations_id_seq'::regclass);


--
-- Name: team_members id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_members ALTER COLUMN id SET DEFAULT nextval('public.team_members_id_seq'::regclass);


--
-- Name: teams id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams ALTER COLUMN id SET DEFAULT nextval('public.teams_id_seq'::regclass);


--
-- Name: tenant_settings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_settings ALTER COLUMN id SET DEFAULT nextval('public.tenant_settings_id_seq'::regclass);


--
-- Name: tenants id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenants ALTER COLUMN id SET DEFAULT nextval('public.tenants_id_seq'::regclass);


--
-- Name: todos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.todos ALTER COLUMN id SET DEFAULT nextval('public.todos_id_seq'::regclass);


--
-- Name: training_schedules id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.training_schedules ALTER COLUMN id SET DEFAULT nextval('public.training_schedules_id_seq'::regclass);


--
-- Name: trainings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trainings ALTER COLUMN id SET DEFAULT nextval('public.trainings_id_seq'::regclass);


--
-- Name: user_settings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_settings ALTER COLUMN id SET DEFAULT nextval('public.user_settings_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: version_updates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.version_updates ALTER COLUMN id SET DEFAULT nextval('public.version_updates_id_seq'::regclass);


--
-- Name: versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions ALTER COLUMN id SET DEFAULT nextval('public.versions_id_seq'::regclass);


--
-- Name: age_groups age_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.age_groups
    ADD CONSTRAINT age_groups_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: club_data_logs club_data_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.club_data_logs
    ADD CONSTRAINT club_data_logs_pkey PRIMARY KEY (id);


--
-- Name: club_data_team_competitions club_data_team_competitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.club_data_team_competitions
    ADD CONSTRAINT club_data_team_competitions_pkey PRIMARY KEY (id);


--
-- Name: club_data_teams club_data_teams_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.club_data_teams
    ADD CONSTRAINT club_data_teams_pkey PRIMARY KEY (id);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: competitions competitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.competitions
    ADD CONSTRAINT competitions_pkey PRIMARY KEY (id);


--
-- Name: email_logs email_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_logs
    ADD CONSTRAINT email_logs_pkey PRIMARY KEY (id);


--
-- Name: favorites favorites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT favorites_pkey PRIMARY KEY (id);


--
-- Name: field_positions field_positions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.field_positions
    ADD CONSTRAINT field_positions_pkey PRIMARY KEY (id);


--
-- Name: group_members group_members_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_members
    ADD CONSTRAINT group_members_pkey PRIMARY KEY (id);


--
-- Name: groups groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: injuries injuries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.injuries
    ADD CONSTRAINT injuries_pkey PRIMARY KEY (id);


--
-- Name: logs logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.logs
    ADD CONSTRAINT logs_pkey PRIMARY KEY (id);


--
-- Name: matches matches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_pkey PRIMARY KEY (id);


--
-- Name: members members_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.members
    ADD CONSTRAINT members_pkey PRIMARY KEY (id);


--
-- Name: notes notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT notes_pkey PRIMARY KEY (id);


--
-- Name: play_bans play_bans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.play_bans
    ADD CONSTRAINT play_bans_pkey PRIMARY KEY (id);


--
-- Name: player_evaluations player_evaluations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.player_evaluations
    ADD CONSTRAINT player_evaluations_pkey PRIMARY KEY (id);


--
-- Name: presences presences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.presences
    ADD CONSTRAINT presences_pkey PRIMARY KEY (id);


--
-- Name: que_jobs que_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.que_jobs
    ADD CONSTRAINT que_jobs_pkey PRIMARY KEY (id);


--
-- Name: que_lockers que_lockers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.que_lockers
    ADD CONSTRAINT que_lockers_pkey PRIMARY KEY (pid);


--
-- Name: que_values que_values_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.que_values
    ADD CONSTRAINT que_values_pkey PRIMARY KEY (key);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: seasons seasons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.seasons
    ADD CONSTRAINT seasons_pkey PRIMARY KEY (id);


--
-- Name: soccer_fields soccer_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.soccer_fields
    ADD CONSTRAINT soccer_fields_pkey PRIMARY KEY (id);


--
-- Name: team_evaluation_configs team_evaluation_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_evaluation_configs
    ADD CONSTRAINT team_evaluation_configs_pkey PRIMARY KEY (id);


--
-- Name: team_evaluations team_evaluations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_evaluations
    ADD CONSTRAINT team_evaluations_pkey PRIMARY KEY (id);


--
-- Name: team_members team_members_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_members
    ADD CONSTRAINT team_members_pkey PRIMARY KEY (id);


--
-- Name: teams teams_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_pkey PRIMARY KEY (id);


--
-- Name: tenant_settings tenant_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_settings
    ADD CONSTRAINT tenant_settings_pkey PRIMARY KEY (id);


--
-- Name: tenants tenants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenants
    ADD CONSTRAINT tenants_pkey PRIMARY KEY (id);


--
-- Name: todos todos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.todos
    ADD CONSTRAINT todos_pkey PRIMARY KEY (id);


--
-- Name: training_schedules training_schedules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.training_schedules
    ADD CONSTRAINT training_schedules_pkey PRIMARY KEY (id);


--
-- Name: trainings trainings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trainings
    ADD CONSTRAINT trainings_pkey PRIMARY KEY (id);


--
-- Name: user_settings user_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_settings
    ADD CONSTRAINT user_settings_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: version_updates version_updates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.version_updates
    ADD CONSTRAINT version_updates_pkey PRIMARY KEY (id);


--
-- Name: versions versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


--
-- Name: competition_team; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX competition_team ON public.club_data_team_competitions USING btree (tenant_id, competition_id, club_data_team_id);


--
-- Name: index_age_groups_on_season_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_age_groups_on_season_id ON public.age_groups USING btree (season_id);


--
-- Name: index_age_groups_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_age_groups_on_tenant_id ON public.age_groups USING btree (tenant_id);


--
-- Name: index_club_data_logs_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_club_data_logs_on_tenant_id ON public.club_data_logs USING btree (tenant_id);


--
-- Name: index_club_data_team_competitions_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_club_data_team_competitions_on_tenant_id ON public.club_data_team_competitions USING btree (tenant_id);


--
-- Name: index_club_data_teams_on_season_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_club_data_teams_on_season_id ON public.club_data_teams USING btree (season_id);


--
-- Name: index_club_data_teams_on_season_id_and_teamcode; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_club_data_teams_on_season_id_and_teamcode ON public.club_data_teams USING btree (tenant_id, season_id, teamcode);


--
-- Name: index_club_data_teams_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_club_data_teams_on_tenant_id ON public.club_data_teams USING btree (tenant_id);


--
-- Name: index_comments_on_commentable_type_and_commentable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comments_on_commentable_type_and_commentable_id ON public.comments USING btree (commentable_type, commentable_id);


--
-- Name: index_comments_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comments_on_tenant_id ON public.comments USING btree (tenant_id);


--
-- Name: index_comments_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comments_on_user_id ON public.comments USING btree (user_id);


--
-- Name: index_competitions_on_poulecode; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_competitions_on_poulecode ON public.competitions USING btree (tenant_id, poulecode);


--
-- Name: index_competitions_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_competitions_on_tenant_id ON public.competitions USING btree (tenant_id);


--
-- Name: index_email_logs_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_email_logs_on_tenant_id ON public.email_logs USING btree (tenant_id);


--
-- Name: index_email_logs_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_email_logs_on_user_id ON public.email_logs USING btree (user_id);


--
-- Name: index_favorites_on_favorable_type_and_favorable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_on_favorable_type_and_favorable_id ON public.favorites USING btree (favorable_type, favorable_id);


--
-- Name: index_favorites_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_on_tenant_id ON public.favorites USING btree (tenant_id);


--
-- Name: index_favorites_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_on_user_id ON public.favorites USING btree (user_id);


--
-- Name: index_field_positions_on_axis_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_field_positions_on_axis_parent_id ON public.field_positions USING btree (axis_parent_id);


--
-- Name: index_field_positions_on_line_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_field_positions_on_line_parent_id ON public.field_positions USING btree (line_parent_id);


--
-- Name: index_field_positions_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_field_positions_on_tenant_id ON public.field_positions USING btree (tenant_id);


--
-- Name: index_group_members_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_group_members_on_group_id ON public.group_members USING btree (group_id);


--
-- Name: index_group_members_on_member_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_group_members_on_member_id ON public.group_members USING btree (member_id);


--
-- Name: index_group_members_on_memberable_type_and_memberable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_group_members_on_memberable_type_and_memberable_id ON public.group_members USING btree (memberable_type, memberable_id);


--
-- Name: index_group_members_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_group_members_on_tenant_id ON public.group_members USING btree (tenant_id);


--
-- Name: index_group_members_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_group_members_unique ON public.group_members USING btree (group_id, member_id, memberable_type, memberable_id);


--
-- Name: index_groups_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_on_tenant_id ON public.groups USING btree (tenant_id);


--
-- Name: index_groups_roles_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_roles_on_group_id ON public.groups_roles USING btree (group_id);


--
-- Name: index_groups_roles_on_group_id_and_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_roles_on_group_id_and_role_id ON public.groups_roles USING btree (group_id, role_id);


--
-- Name: index_groups_roles_on_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_roles_on_role_id ON public.groups_roles USING btree (role_id);


--
-- Name: index_injuries_on_member_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_injuries_on_member_id ON public.injuries USING btree (member_id);


--
-- Name: index_injuries_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_injuries_on_tenant_id ON public.injuries USING btree (tenant_id);


--
-- Name: index_injuries_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_injuries_on_user_id ON public.injuries USING btree (user_id);


--
-- Name: index_logs_on_logable_type_and_logable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_logs_on_logable_type_and_logable_id ON public.logs USING btree (logable_type, logable_id);


--
-- Name: index_logs_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_logs_on_tenant_id ON public.logs USING btree (tenant_id);


--
-- Name: index_logs_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_logs_on_user_id ON public.logs USING btree (user_id);


--
-- Name: index_matches_on_competition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_matches_on_competition_id ON public.matches USING btree (competition_id);


--
-- Name: index_matches_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_matches_on_created_by_id ON public.matches USING btree (created_by_id);


--
-- Name: index_matches_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_matches_on_tenant_id ON public.matches USING btree (tenant_id);


--
-- Name: index_matches_on_wedstrijdcode; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_matches_on_wedstrijdcode ON public.matches USING btree (tenant_id, wedstrijdcode);


--
-- Name: index_matches_teams_on_match_id_and_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_matches_teams_on_match_id_and_team_id ON public.matches_teams USING btree (match_id, team_id);


--
-- Name: index_matches_teams_on_team_id_and_match_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_matches_teams_on_team_id_and_match_id ON public.matches_teams USING btree (team_id, match_id);


--
-- Name: index_members_on_association_number; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_members_on_association_number ON public.members USING btree (association_number);


--
-- Name: index_members_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_members_on_tenant_id ON public.members USING btree (tenant_id);


--
-- Name: index_members_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_members_on_user_id ON public.members USING btree (user_id);


--
-- Name: index_members_users_on_member_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_members_users_on_member_id_and_user_id ON public.members_users USING btree (member_id, user_id);


--
-- Name: index_members_users_on_user_id_and_member_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_members_users_on_user_id_and_member_id ON public.members_users USING btree (user_id, member_id);


--
-- Name: index_notes_on_member_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notes_on_member_id ON public.notes USING btree (member_id);


--
-- Name: index_notes_on_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notes_on_team_id ON public.notes USING btree (team_id);


--
-- Name: index_notes_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notes_on_tenant_id ON public.notes USING btree (tenant_id);


--
-- Name: index_notes_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notes_on_user_id ON public.notes USING btree (user_id);


--
-- Name: index_play_bans_on_member_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_play_bans_on_member_id ON public.play_bans USING btree (member_id);


--
-- Name: index_play_bans_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_play_bans_on_tenant_id ON public.play_bans USING btree (tenant_id);


--
-- Name: index_player_evaluations_on_team_evaluation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_player_evaluations_on_team_evaluation_id ON public.player_evaluations USING btree (team_evaluation_id);


--
-- Name: index_player_evaluations_on_team_member_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_player_evaluations_on_team_member_id ON public.player_evaluations USING btree (team_member_id);


--
-- Name: index_player_evaluations_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_player_evaluations_on_tenant_id ON public.player_evaluations USING btree (tenant_id);


--
-- Name: index_presences_on_member_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_presences_on_member_id ON public.presences USING btree (member_id);


--
-- Name: index_presences_on_presentable_type_and_presentable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_presences_on_presentable_type_and_presentable_id ON public.presences USING btree (presentable_type, presentable_id);


--
-- Name: index_presences_on_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_presences_on_team_id ON public.presences USING btree (team_id);


--
-- Name: index_presences_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_presences_on_tenant_id ON public.presences USING btree (tenant_id);


--
-- Name: index_roles_on_name_and_resource_type_and_resource_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_roles_on_name_and_resource_type_and_resource_id ON public.roles USING btree (name, resource_type, resource_id);


--
-- Name: index_roles_on_resource_type_and_resource_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_roles_on_resource_type_and_resource_id ON public.roles USING btree (resource_type, resource_id);


--
-- Name: index_roles_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_roles_on_tenant_id ON public.roles USING btree (tenant_id);


--
-- Name: index_seasons_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_seasons_on_tenant_id ON public.seasons USING btree (tenant_id);


--
-- Name: index_soccer_fields_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_soccer_fields_on_tenant_id ON public.soccer_fields USING btree (tenant_id);


--
-- Name: index_team_evaluation_configs_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_team_evaluation_configs_on_tenant_id ON public.team_evaluation_configs USING btree (tenant_id);


--
-- Name: index_team_evaluations_on_finished_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_team_evaluations_on_finished_by_id ON public.team_evaluations USING btree (finished_by_id);


--
-- Name: index_team_evaluations_on_invited_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_team_evaluations_on_invited_by_id ON public.team_evaluations USING btree (invited_by_id);


--
-- Name: index_team_evaluations_on_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_team_evaluations_on_team_id ON public.team_evaluations USING btree (team_id);


--
-- Name: index_team_evaluations_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_team_evaluations_on_tenant_id ON public.team_evaluations USING btree (tenant_id);


--
-- Name: index_team_members_on_member_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_team_members_on_member_id ON public.team_members USING btree (member_id);


--
-- Name: index_team_members_on_member_id_and_team_id_and_role; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_team_members_on_member_id_and_team_id_and_role ON public.team_members USING btree (member_id, team_id, role);


--
-- Name: index_team_members_on_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_team_members_on_team_id ON public.team_members USING btree (team_id);


--
-- Name: index_team_members_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_team_members_on_tenant_id ON public.team_members USING btree (tenant_id);


--
-- Name: index_teams_on_age_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_teams_on_age_group_id ON public.teams USING btree (age_group_id);


--
-- Name: index_teams_on_club_data_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_teams_on_club_data_team_id ON public.teams USING btree (club_data_team_id);


--
-- Name: index_teams_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_teams_on_tenant_id ON public.teams USING btree (tenant_id);


--
-- Name: index_teams_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_teams_on_uuid ON public.teams USING btree (uuid);


--
-- Name: index_tenant_settings_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tenant_settings_on_tenant_id ON public.tenant_settings USING btree (tenant_id);


--
-- Name: index_todos_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_todos_on_tenant_id ON public.todos USING btree (tenant_id);


--
-- Name: index_todos_on_todoable_type_and_todoable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_todos_on_todoable_type_and_todoable_id ON public.todos USING btree (todoable_type, todoable_id);


--
-- Name: index_todos_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_todos_on_user_id ON public.todos USING btree (user_id);


--
-- Name: index_training_schedules_on_soccer_field_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_training_schedules_on_soccer_field_id ON public.training_schedules USING btree (soccer_field_id);


--
-- Name: index_training_schedules_on_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_training_schedules_on_team_id ON public.training_schedules USING btree (team_id);


--
-- Name: index_training_schedules_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_training_schedules_on_tenant_id ON public.training_schedules USING btree (tenant_id);


--
-- Name: index_trainings_on_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trainings_on_team_id ON public.trainings USING btree (team_id);


--
-- Name: index_trainings_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trainings_on_tenant_id ON public.trainings USING btree (tenant_id);


--
-- Name: index_trainings_on_training_schedule_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trainings_on_training_schedule_id ON public.trainings USING btree (training_schedule_id);


--
-- Name: index_user_settings_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_settings_on_tenant_id ON public.user_settings USING btree (tenant_id);


--
-- Name: index_user_settings_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_settings_on_user_id ON public.user_settings USING btree (user_id);


--
-- Name: index_user_settings_on_user_id_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_user_settings_on_user_id_and_name ON public.user_settings USING btree (user_id, name);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON public.users USING btree (confirmation_token);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: index_users_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_tenant_id ON public.users USING btree (tenant_id);


--
-- Name: index_users_on_tenant_id_and_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_tenant_id_and_email ON public.users USING btree (tenant_id, email);


--
-- Name: index_users_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_uuid ON public.users USING btree (uuid);


--
-- Name: index_users_roles_on_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_roles_on_role_id ON public.users_roles USING btree (role_id);


--
-- Name: index_users_roles_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_roles_on_user_id ON public.users_roles USING btree (user_id);


--
-- Name: index_users_roles_on_user_id_and_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_roles_on_user_id_and_role_id ON public.users_roles USING btree (user_id, role_id);


--
-- Name: index_versions_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_versions_on_item_type_and_item_id ON public.versions USING btree (item_type, item_id);


--
-- Name: member_position_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX member_position_index ON public.field_positions_team_members USING btree (team_member_id, field_position_id);


--
-- Name: member_schedule; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX member_schedule ON public.team_members_training_schedules USING btree (team_member_id, training_schedule_id);


--
-- Name: position_member_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX position_member_index ON public.field_positions_team_members USING btree (field_position_id, team_member_id);


--
-- Name: que_jobs_args_gin_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX que_jobs_args_gin_idx ON public.que_jobs USING gin (args jsonb_path_ops);


--
-- Name: que_jobs_data_gin_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX que_jobs_data_gin_idx ON public.que_jobs USING gin (data jsonb_path_ops);


--
-- Name: que_poll_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX que_poll_idx ON public.que_jobs USING btree (queue, priority, run_at, id) WHERE ((finished_at IS NULL) AND (expired_at IS NULL));


--
-- Name: schedule_member; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX schedule_member ON public.team_members_training_schedules USING btree (training_schedule_id, team_member_id);


--
-- Name: team_competition; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX team_competition ON public.club_data_team_competitions USING btree (tenant_id, club_data_team_id, competition_id);


--
-- Name: que_jobs que_job_notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER que_job_notify AFTER INSERT ON public.que_jobs FOR EACH ROW EXECUTE PROCEDURE public.que_job_notify();


--
-- Name: que_jobs que_state_notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER que_state_notify AFTER INSERT OR DELETE OR UPDATE ON public.que_jobs FOR EACH ROW EXECUTE PROCEDURE public.que_state_notify();


--
-- Name: field_positions fk_rails_014fe50d63; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.field_positions
    ADD CONSTRAINT fk_rails_014fe50d63 FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: notes fk_rails_024ba0b8ac; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT fk_rails_024ba0b8ac FOREIGN KEY (team_id) REFERENCES public.teams(id);


--
-- Name: presences fk_rails_03b51a059a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.presences
    ADD CONSTRAINT fk_rails_03b51a059a FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: comments fk_rails_03de2dc08c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT fk_rails_03de2dc08c FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: presences fk_rails_0d142e1d7d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.presences
    ADD CONSTRAINT fk_rails_0d142e1d7d FOREIGN KEY (member_id) REFERENCES public.members(id);


--
-- Name: users fk_rails_135c8f54b2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_135c8f54b2 FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: groups fk_rails_13822f50e5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT fk_rails_13822f50e5 FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: matches fk_rails_14949c9da2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT fk_rails_14949c9da2 FOREIGN KEY (competition_id) REFERENCES public.competitions(id);


--
-- Name: team_members fk_rails_194b5b076d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_members
    ADD CONSTRAINT fk_rails_194b5b076d FOREIGN KEY (team_id) REFERENCES public.teams(id);


--
-- Name: club_data_team_competitions fk_rails_1b6811f793; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.club_data_team_competitions
    ADD CONSTRAINT fk_rails_1b6811f793 FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: team_members fk_rails_21c6860154; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_members
    ADD CONSTRAINT fk_rails_21c6860154 FOREIGN KEY (member_id) REFERENCES public.members(id);


--
-- Name: email_logs fk_rails_283edf4550; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_logs
    ADD CONSTRAINT fk_rails_283edf4550 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: teams fk_rails_287242fcbb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT fk_rails_287242fcbb FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: members fk_rails_2e88fb7ce9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.members
    ADD CONSTRAINT fk_rails_2e88fb7ce9 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: favorites fk_rails_31f9a48853; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT fk_rails_31f9a48853 FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: team_evaluation_configs fk_rails_35cf8b2c8a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_evaluation_configs
    ADD CONSTRAINT fk_rails_35cf8b2c8a FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: seasons fk_rails_3b9439a8f9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.seasons
    ADD CONSTRAINT fk_rails_3b9439a8f9 FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: tenant_settings fk_rails_3edf7ce8f1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_settings
    ADD CONSTRAINT fk_rails_3edf7ce8f1 FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: members fk_rails_4e4771d44b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.members
    ADD CONSTRAINT fk_rails_4e4771d44b FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: field_positions fk_rails_5159f4d33e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.field_positions
    ADD CONSTRAINT fk_rails_5159f4d33e FOREIGN KEY (line_parent_id) REFERENCES public.field_positions(id);


--
-- Name: todos fk_rails_52ad4f9198; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.todos
    ADD CONSTRAINT fk_rails_52ad4f9198 FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: club_data_teams fk_rails_5468d32560; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.club_data_teams
    ADD CONSTRAINT fk_rails_5468d32560 FOREIGN KEY (season_id) REFERENCES public.seasons(id);


--
-- Name: player_evaluations fk_rails_54e32c014b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.player_evaluations
    ADD CONSTRAINT fk_rails_54e32c014b FOREIGN KEY (team_member_id) REFERENCES public.team_members(id);


--
-- Name: notes fk_rails_556b0a09d2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT fk_rails_556b0a09d2 FOREIGN KEY (member_id) REFERENCES public.members(id);


--
-- Name: team_evaluations fk_rails_5ca4986c4f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_evaluations
    ADD CONSTRAINT fk_rails_5ca4986c4f FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: age_groups fk_rails_5e74eb4322; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.age_groups
    ADD CONSTRAINT fk_rails_5e74eb4322 FOREIGN KEY (season_id) REFERENCES public.seasons(id);


--
-- Name: soccer_fields fk_rails_5f5b2dac7a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.soccer_fields
    ADD CONSTRAINT fk_rails_5f5b2dac7a FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: user_settings fk_rails_6395e91cb6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_settings
    ADD CONSTRAINT fk_rails_6395e91cb6 FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: injuries fk_rails_67a4af66e2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.injuries
    ADD CONSTRAINT fk_rails_67a4af66e2 FOREIGN KEY (member_id) REFERENCES public.members(id);


--
-- Name: teams fk_rails_69373c545a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT fk_rails_69373c545a FOREIGN KEY (age_group_id) REFERENCES public.age_groups(id);


--
-- Name: field_positions fk_rails_6cb5937a09; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.field_positions
    ADD CONSTRAINT fk_rails_6cb5937a09 FOREIGN KEY (axis_parent_id) REFERENCES public.field_positions(id);


--
-- Name: team_evaluations fk_rails_7baa249e25; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_evaluations
    ADD CONSTRAINT fk_rails_7baa249e25 FOREIGN KEY (invited_by_id) REFERENCES public.users(id);


--
-- Name: notes fk_rails_7f2323ad43; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT fk_rails_7f2323ad43 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: group_members fk_rails_8a23e975cb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_members
    ADD CONSTRAINT fk_rails_8a23e975cb FOREIGN KEY (member_id) REFERENCES public.members(id);


--
-- Name: training_schedules fk_rails_8cb99eb117; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.training_schedules
    ADD CONSTRAINT fk_rails_8cb99eb117 FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: logs fk_rails_8fc980bf44; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.logs
    ADD CONSTRAINT fk_rails_8fc980bf44 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: email_logs fk_rails_91eebd67f4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_logs
    ADD CONSTRAINT fk_rails_91eebd67f4 FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: team_evaluations fk_rails_9716ab4fe1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_evaluations
    ADD CONSTRAINT fk_rails_9716ab4fe1 FOREIGN KEY (team_id) REFERENCES public.teams(id);


--
-- Name: injuries fk_rails_99832e8dde; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.injuries
    ADD CONSTRAINT fk_rails_99832e8dde FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: club_data_logs fk_rails_9e40c5636e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.club_data_logs
    ADD CONSTRAINT fk_rails_9e40c5636e FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: matches fk_rails_a45bcc172b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT fk_rails_a45bcc172b FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: matches fk_rails_aae99f8132; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT fk_rails_aae99f8132 FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: trainings fk_rails_ac438219b6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trainings
    ADD CONSTRAINT fk_rails_ac438219b6 FOREIGN KEY (training_schedule_id) REFERENCES public.training_schedules(id);


--
-- Name: team_members fk_rails_ae9354d0c4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_members
    ADD CONSTRAINT fk_rails_ae9354d0c4 FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: teams fk_rails_b533d8992e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT fk_rails_b533d8992e FOREIGN KEY (club_data_team_id) REFERENCES public.club_data_teams(id);


--
-- Name: team_evaluations fk_rails_b98c2c45e3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_evaluations
    ADD CONSTRAINT fk_rails_b98c2c45e3 FOREIGN KEY (finished_by_id) REFERENCES public.users(id);


--
-- Name: age_groups fk_rails_c3a5a62548; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.age_groups
    ADD CONSTRAINT fk_rails_c3a5a62548 FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: trainings fk_rails_c43a08d290; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trainings
    ADD CONSTRAINT fk_rails_c43a08d290 FOREIGN KEY (team_id) REFERENCES public.teams(id);


--
-- Name: club_data_teams fk_rails_ce763ff64c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.club_data_teams
    ADD CONSTRAINT fk_rails_ce763ff64c FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: player_evaluations fk_rails_ceaeff1722; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.player_evaluations
    ADD CONSTRAINT fk_rails_ceaeff1722 FOREIGN KEY (team_evaluation_id) REFERENCES public.team_evaluations(id);


--
-- Name: presences fk_rails_cf0f9828ad; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.presences
    ADD CONSTRAINT fk_rails_cf0f9828ad FOREIGN KEY (team_id) REFERENCES public.teams(id);


--
-- Name: player_evaluations fk_rails_d008b5c5ac; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.player_evaluations
    ADD CONSTRAINT fk_rails_d008b5c5ac FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: user_settings fk_rails_d1371c6356; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_settings
    ADD CONSTRAINT fk_rails_d1371c6356 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: favorites fk_rails_d15744e438; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT fk_rails_d15744e438 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: roles fk_rails_d7321fcec4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT fk_rails_d7321fcec4 FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: todos fk_rails_d94154aa95; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.todos
    ADD CONSTRAINT fk_rails_d94154aa95 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: play_bans fk_rails_db5c62b912; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.play_bans
    ADD CONSTRAINT fk_rails_db5c62b912 FOREIGN KEY (member_id) REFERENCES public.members(id);


--
-- Name: comments fk_rails_dbb1cfb9be; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT fk_rails_dbb1cfb9be FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: competitions fk_rails_dbde41c703; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.competitions
    ADD CONSTRAINT fk_rails_dbde41c703 FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: training_schedules fk_rails_e328e3417e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.training_schedules
    ADD CONSTRAINT fk_rails_e328e3417e FOREIGN KEY (soccer_field_id) REFERENCES public.soccer_fields(id);


--
-- Name: notes fk_rails_e420fccb7e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT fk_rails_e420fccb7e FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: trainings fk_rails_e6eb87ac3b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trainings
    ADD CONSTRAINT fk_rails_e6eb87ac3b FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: injuries fk_rails_e9475c85ac; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.injuries
    ADD CONSTRAINT fk_rails_e9475c85ac FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: group_members fk_rails_e9fdb70ec5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_members
    ADD CONSTRAINT fk_rails_e9fdb70ec5 FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- Name: training_schedules fk_rails_ed08ef065c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.training_schedules
    ADD CONSTRAINT fk_rails_ed08ef065c FOREIGN KEY (team_id) REFERENCES public.teams(id);


--
-- Name: logs fk_rails_f1e325f6ae; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.logs
    ADD CONSTRAINT fk_rails_f1e325f6ae FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: group_members fk_rails_f45936ea8a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_members
    ADD CONSTRAINT fk_rails_f45936ea8a FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: play_bans fk_rails_fc1459b167; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.play_bans
    ADD CONSTRAINT fk_rails_fc1459b167 FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20161226222341'),
('20161226224151'),
('20161226224257'),
('20161226224343'),
('20161226225340'),
('20161226225943'),
('20161227162416'),
('20161227175913'),
('20170118132825'),
('20170118135107'),
('20170118151921'),
('20170118152835'),
('20170121221156'),
('20170128135917'),
('20170128140801'),
('20170128201140'),
('20170129142446'),
('20170129143733'),
('20170130114607'),
('20170130115241'),
('20170204191220'),
('20170205100942'),
('20170205132729'),
('20170205140822'),
('20170205174901'),
('20170206161904'),
('20170210212301'),
('20170211215820'),
('20170211220755'),
('20170225185527'),
('20170225190530'),
('20170227114741'),
('20170302100722'),
('20170304174406'),
('20170306070142'),
('20170306071202'),
('20170306072110'),
('20170320203647'),
('20170320203856'),
('20170320204144'),
('20170320204356'),
('20170320205108'),
('20170320210001'),
('20170320211831'),
('20170408143141'),
('20170413154252'),
('20170417093846'),
('20170417094415'),
('20170417094451'),
('20170417094858'),
('20170417144632'),
('20170419194444'),
('20170419201122'),
('20170423200050'),
('20170427145206'),
('20170429182804'),
('20170503205739'),
('20170515200126'),
('20170517193234'),
('20170521135241'),
('20170521135928'),
('20170521140336'),
('20170611143235'),
('20170611194722'),
('20170625104951'),
('20170626190711'),
('20170709101523'),
('20170709102623'),
('20170715142252'),
('20170715192502'),
('20170716191232'),
('20170716191309'),
('20170717160726'),
('20170717160803'),
('20170717181322'),
('20170717190649'),
('20170717190840'),
('20170718190250'),
('20170722184614'),
('20170801113603'),
('20170801121951'),
('20170801144627'),
('20170801182425'),
('20170802132401'),
('20170804110413'),
('20170809152944'),
('20170810114134'),
('20170810114525'),
('20170814162653'),
('20170814163552'),
('20170815203006'),
('20170817204540'),
('20170818171117'),
('20170818171126'),
('20170818171455'),
('20170818194440'),
('20170819114247'),
('20170902134025'),
('20170905202518'),
('20170905203855'),
('20170905203902'),
('20170905205039'),
('20170907132901'),
('20170908171420'),
('20170908172143'),
('20170908181149'),
('20170908182912'),
('20170908183004'),
('20170908193301'),
('20170908205241'),
('20170908210945'),
('20170909192305'),
('20170909194732'),
('20170912065846'),
('20170919195012'),
('20170930185703'),
('20171017153001'),
('20171019074055'),
('20171121170830'),
('20171210152003'),
('20171210152925'),
('20171219164626'),
('20171219165330'),
('20171219170012'),
('20180116170658'),
('20180116171941'),
('20180131194902'),
('20180131203352'),
('20180131215209'),
('20180131215914'),
('20180204204727'),
('20180206203400'),
('20180206204545'),
('20180206212125'),
('20180206212307'),
('20180206212458'),
('20180206212645'),
('20180206214137'),
('20180206214340'),
('20180216184044'),
('20180216200551'),
('20180327154015'),
('20180329201829'),
('20180329201938'),
('20180401153926'),
('20180401154144'),
('20180401154733'),
('20180401174624'),
('20180401193716'),
('20180430065114'),
('20180810145052'),
('20180812153929'),
('20180816211827'),
('20180816212034'),
('20180816214740'),
('20180819142418'),
('20180819142440'),
('20180819170913'),
('20180819172702'),
('20180819174301'),
('20180819201223'),
('20180819201347'),
('20180902173017'),
('20180924190351'),
('20180924193315'),
('20180928183231'),
('20180928190828'),
('20180928192231'),
('20181012193336'),
('20181017150831'),
('20181123163533'),
('20181123192059'),
('20190130185811'),
('20190130190627'),
('20190622185242'),
('20190622210438'),
('20190626114823'),
('20190629180337'),
('20190629183634'),
('20190713134522'),
('20190716164017'),
('20190720204451'),
('20190720204557'),
('20190721064333'),
('20190723103301'),
('20190723104251'),
('20190723104900'),
('20190723105047'),
('20190723105633'),
('20190723105838'),
('20190723124341'),
('20190723141249'),
('20190723150507'),
('20190801122232'),
('20190809102112'),
('20190814195847'),
('20190820125446'),
('20190829080916'),
('20191020180708'),
('20191020183442'),
('20191020191520'),
('20191020192117'),
('20191020193409'),
('20191020193522'),
('20191023193359'),
('20191103143230'),
('20191205193014'),
('20191217145730'),
('20191223164010'),
('20200103161730'),
('20200130200633'),
('20200130205010'),
('20200130205011'),
('20200130205012'),
('20200130205013'),
('20200130205014'),
('20200131180415'),
('20200131195637'),
('20200207190510');



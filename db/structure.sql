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
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: active_storage_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_attachments (
    id bigint NOT NULL,
    name character varying NOT NULL,
    record_type character varying NOT NULL,
    record_id bigint NOT NULL,
    blob_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL
);


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_attachments_id_seq OWNED BY public.active_storage_attachments.id;


--
-- Name: active_storage_blobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_blobs (
    id bigint NOT NULL,
    key character varying NOT NULL,
    filename character varying NOT NULL,
    content_type character varying,
    metadata text,
    service_name character varying NOT NULL,
    byte_size bigint NOT NULL,
    checksum character varying,
    created_at timestamp(6) without time zone NOT NULL
);


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_blobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_blobs_id_seq OWNED BY public.active_storage_blobs.id;


--
-- Name: active_storage_variant_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_variant_records (
    id bigint NOT NULL,
    blob_id bigint NOT NULL,
    variation_digest character varying NOT NULL
);


--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_variant_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_variant_records_id_seq OWNED BY public.active_storage_variant_records.id;


--
-- Name: alcaldias; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alcaldias (
    id bigint NOT NULL,
    name character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    boundary public.geometry(Polygon,4326),
    state_id bigint NOT NULL
);


--
-- Name: alcaldias_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.alcaldias_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: alcaldias_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.alcaldias_id_seq OWNED BY public.alcaldias.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.categories (
    id bigint NOT NULL,
    name character varying,
    sla_hours integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    alcaldia_id bigint NOT NULL
);


--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.categories_id_seq OWNED BY public.categories.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notifications (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    title character varying NOT NULL,
    body text,
    path character varying,
    read_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;


--
-- Name: push_subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.push_subscriptions (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    endpoint text NOT NULL,
    p256dh_key text NOT NULL,
    auth_key text NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: push_subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.push_subscriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: push_subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.push_subscriptions_id_seq OWNED BY public.push_subscriptions.id;


--
-- Name: report_resolution_cycles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.report_resolution_cycles (
    id bigint NOT NULL,
    report_id bigint NOT NULL,
    assigned_at timestamp(6) without time zone,
    assignee_id bigint NOT NULL,
    assignment_note text,
    resolution_note text,
    resolved_at timestamp(6) without time zone,
    reporter_rejection_note text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    resolver_id bigint
);


--
-- Name: report_resolution_cycles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.report_resolution_cycles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: report_resolution_cycles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.report_resolution_cycles_id_seq OWNED BY public.report_resolution_cycles.id;


--
-- Name: report_snapshots; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.report_snapshots (
    id bigint NOT NULL,
    alcaldia_id bigint NOT NULL,
    snapshot_date date NOT NULL,
    total_reports integer DEFAULT 0 NOT NULL,
    pending_count integer DEFAULT 0 NOT NULL,
    read_count integer DEFAULT 0 NOT NULL,
    assigned_count integer DEFAULT 0 NOT NULL,
    resolved_count integer DEFAULT 0 NOT NULL,
    overdue_count integer DEFAULT 0 NOT NULL,
    reopened_count integer DEFAULT 0 NOT NULL,
    avg_resolution_hours double precision,
    avg_response_hours double precision,
    by_category jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: report_snapshots_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.report_snapshots_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: report_snapshots_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.report_snapshots_id_seq OWNED BY public.report_snapshots.id;


--
-- Name: reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reports (
    id bigint NOT NULL,
    reporter_id bigint NOT NULL,
    category_id bigint NOT NULL,
    status character varying DEFAULT 'pending'::character varying NOT NULL,
    assignee_id bigint,
    latitude numeric(10,7),
    longitude numeric(10,7),
    location_description text,
    description text NOT NULL,
    resolution_note text,
    reopened boolean DEFAULT false NOT NULL,
    read_at timestamp(6) without time zone,
    assigned_at timestamp(6) without time zone,
    resolved_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    assignment_note text,
    reporter_rejection_note text,
    reporter_accepted_at timestamp(6) without time zone,
    alcaldia_id bigint,
    resolved_by_id bigint
);


--
-- Name: reports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.reports_id_seq OWNED BY public.reports.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sessions (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    ip_address character varying,
    user_agent character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sessions_id_seq OWNED BY public.sessions.id;


--
-- Name: states; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.states (
    id bigint NOT NULL,
    name character varying NOT NULL,
    code character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: states_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.states_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: states_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.states_id_seq OWNED BY public.states.id;


--
-- Name: system_audit_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.system_audit_logs (
    id bigint NOT NULL,
    actor_id bigint NOT NULL,
    action character varying NOT NULL,
    target_type character varying,
    target_id bigint,
    metadata jsonb DEFAULT '{}'::jsonb,
    ip_address character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: system_audit_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.system_audit_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: system_audit_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.system_audit_logs_id_seq OWNED BY public.system_audit_logs.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email_address character varying,
    password_digest character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    name character varying,
    active boolean DEFAULT true NOT NULL,
    role character varying DEFAULT 'citizen'::character varying NOT NULL,
    manager_id bigint,
    alcaldia_id bigint
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
-- Name: active_storage_attachments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments ALTER COLUMN id SET DEFAULT nextval('public.active_storage_attachments_id_seq'::regclass);


--
-- Name: active_storage_blobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs ALTER COLUMN id SET DEFAULT nextval('public.active_storage_blobs_id_seq'::regclass);


--
-- Name: active_storage_variant_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records ALTER COLUMN id SET DEFAULT nextval('public.active_storage_variant_records_id_seq'::regclass);


--
-- Name: alcaldias id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alcaldias ALTER COLUMN id SET DEFAULT nextval('public.alcaldias_id_seq'::regclass);


--
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories ALTER COLUMN id SET DEFAULT nextval('public.categories_id_seq'::regclass);


--
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);


--
-- Name: push_subscriptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.push_subscriptions ALTER COLUMN id SET DEFAULT nextval('public.push_subscriptions_id_seq'::regclass);


--
-- Name: report_resolution_cycles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_resolution_cycles ALTER COLUMN id SET DEFAULT nextval('public.report_resolution_cycles_id_seq'::regclass);


--
-- Name: report_snapshots id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_snapshots ALTER COLUMN id SET DEFAULT nextval('public.report_snapshots_id_seq'::regclass);


--
-- Name: reports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports ALTER COLUMN id SET DEFAULT nextval('public.reports_id_seq'::regclass);


--
-- Name: sessions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions ALTER COLUMN id SET DEFAULT nextval('public.sessions_id_seq'::regclass);


--
-- Name: states id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.states ALTER COLUMN id SET DEFAULT nextval('public.states_id_seq'::regclass);


--
-- Name: system_audit_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system_audit_logs ALTER COLUMN id SET DEFAULT nextval('public.system_audit_logs_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: active_storage_attachments active_storage_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT active_storage_attachments_pkey PRIMARY KEY (id);


--
-- Name: active_storage_blobs active_storage_blobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs
    ADD CONSTRAINT active_storage_blobs_pkey PRIMARY KEY (id);


--
-- Name: active_storage_variant_records active_storage_variant_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT active_storage_variant_records_pkey PRIMARY KEY (id);


--
-- Name: alcaldias alcaldias_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alcaldias
    ADD CONSTRAINT alcaldias_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: push_subscriptions push_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.push_subscriptions
    ADD CONSTRAINT push_subscriptions_pkey PRIMARY KEY (id);


--
-- Name: report_resolution_cycles report_resolution_cycles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_resolution_cycles
    ADD CONSTRAINT report_resolution_cycles_pkey PRIMARY KEY (id);


--
-- Name: report_snapshots report_snapshots_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_snapshots
    ADD CONSTRAINT report_snapshots_pkey PRIMARY KEY (id);


--
-- Name: reports reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports
    ADD CONSTRAINT reports_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: states states_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.states
    ADD CONSTRAINT states_pkey PRIMARY KEY (id);


--
-- Name: system_audit_logs system_audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system_audit_logs
    ADD CONSTRAINT system_audit_logs_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_reports_alcaldia_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_reports_alcaldia_status ON public.reports USING btree (alcaldia_id, status);


--
-- Name: idx_reports_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_reports_created_at ON public.reports USING btree (created_at);


--
-- Name: idx_reports_status_resolved_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_reports_status_resolved_at ON public.reports USING btree (status, resolved_at);


--
-- Name: idx_users_role_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_role_active ON public.users USING btree (role, active);


--
-- Name: index_active_storage_attachments_on_blob_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_storage_attachments_on_blob_id ON public.active_storage_attachments USING btree (blob_id);


--
-- Name: index_active_storage_attachments_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_attachments_uniqueness ON public.active_storage_attachments USING btree (record_type, record_id, name, blob_id);


--
-- Name: index_active_storage_blobs_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_blobs_on_key ON public.active_storage_blobs USING btree (key);


--
-- Name: index_active_storage_variant_records_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_variant_records_uniqueness ON public.active_storage_variant_records USING btree (blob_id, variation_digest);


--
-- Name: index_alcaldias_on_boundary; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_alcaldias_on_boundary ON public.alcaldias USING gist (boundary);


--
-- Name: index_alcaldias_on_name_and_state_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_alcaldias_on_name_and_state_id ON public.alcaldias USING btree (name, state_id);


--
-- Name: index_alcaldias_on_state_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_alcaldias_on_state_id ON public.alcaldias USING btree (state_id);


--
-- Name: index_categories_on_alcaldia_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_categories_on_alcaldia_id ON public.categories USING btree (alcaldia_id);


--
-- Name: index_categories_on_alcaldia_id_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_categories_on_alcaldia_id_and_name ON public.categories USING btree (alcaldia_id, name);


--
-- Name: index_notifications_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notifications_on_user_id ON public.notifications USING btree (user_id);


--
-- Name: index_notifications_on_user_id_and_read_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notifications_on_user_id_and_read_at ON public.notifications USING btree (user_id, read_at);


--
-- Name: index_push_subscriptions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_push_subscriptions_on_user_id ON public.push_subscriptions USING btree (user_id);


--
-- Name: index_push_subscriptions_on_user_id_and_endpoint; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_push_subscriptions_on_user_id_and_endpoint ON public.push_subscriptions USING btree (user_id, endpoint);


--
-- Name: index_report_resolution_cycles_on_assignee_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_report_resolution_cycles_on_assignee_id ON public.report_resolution_cycles USING btree (assignee_id);


--
-- Name: index_report_resolution_cycles_on_report_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_report_resolution_cycles_on_report_id ON public.report_resolution_cycles USING btree (report_id);


--
-- Name: index_report_resolution_cycles_on_resolver_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_report_resolution_cycles_on_resolver_id ON public.report_resolution_cycles USING btree (resolver_id);


--
-- Name: index_report_snapshots_on_alcaldia_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_report_snapshots_on_alcaldia_id ON public.report_snapshots USING btree (alcaldia_id);


--
-- Name: index_report_snapshots_on_alcaldia_id_and_snapshot_date; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_report_snapshots_on_alcaldia_id_and_snapshot_date ON public.report_snapshots USING btree (alcaldia_id, snapshot_date);


--
-- Name: index_report_snapshots_on_snapshot_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_report_snapshots_on_snapshot_date ON public.report_snapshots USING btree (snapshot_date);


--
-- Name: index_reports_on_alcaldia_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reports_on_alcaldia_id ON public.reports USING btree (alcaldia_id);


--
-- Name: index_reports_on_assignee_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reports_on_assignee_id ON public.reports USING btree (assignee_id);


--
-- Name: index_reports_on_assignee_id_and_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reports_on_assignee_id_and_status ON public.reports USING btree (assignee_id, status);


--
-- Name: index_reports_on_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reports_on_category_id ON public.reports USING btree (category_id);


--
-- Name: index_reports_on_reporter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reports_on_reporter_id ON public.reports USING btree (reporter_id);


--
-- Name: index_reports_on_reporter_id_and_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reports_on_reporter_id_and_status ON public.reports USING btree (reporter_id, status);


--
-- Name: index_reports_on_resolved_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reports_on_resolved_by_id ON public.reports USING btree (resolved_by_id);


--
-- Name: index_reports_on_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reports_on_status ON public.reports USING btree (status);


--
-- Name: index_sessions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sessions_on_user_id ON public.sessions USING btree (user_id);


--
-- Name: index_states_on_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_states_on_code ON public.states USING btree (code);


--
-- Name: index_states_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_states_on_name ON public.states USING btree (name);


--
-- Name: index_system_audit_logs_on_action; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_system_audit_logs_on_action ON public.system_audit_logs USING btree (action);


--
-- Name: index_system_audit_logs_on_actor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_system_audit_logs_on_actor_id ON public.system_audit_logs USING btree (actor_id);


--
-- Name: index_system_audit_logs_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_system_audit_logs_on_created_at ON public.system_audit_logs USING btree (created_at);


--
-- Name: index_system_audit_logs_on_target_type_and_target_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_system_audit_logs_on_target_type_and_target_id ON public.system_audit_logs USING btree (target_type, target_id);


--
-- Name: index_users_on_alcaldia_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_alcaldia_id ON public.users USING btree (alcaldia_id);


--
-- Name: index_users_on_email_address; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email_address ON public.users USING btree (email_address) WHERE (email_address IS NOT NULL);


--
-- Name: index_users_on_manager_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_manager_id ON public.users USING btree (manager_id);


--
-- Name: index_users_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_name ON public.users USING btree (name);


--
-- Name: report_snapshots fk_rails_04ff0b48fd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_snapshots
    ADD CONSTRAINT fk_rails_04ff0b48fd FOREIGN KEY (alcaldia_id) REFERENCES public.alcaldias(id);


--
-- Name: reports fk_rails_12eb92a4f5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports
    ADD CONSTRAINT fk_rails_12eb92a4f5 FOREIGN KEY (assignee_id) REFERENCES public.users(id);


--
-- Name: alcaldias fk_rails_17f637bc9b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alcaldias
    ADD CONSTRAINT fk_rails_17f637bc9b FOREIGN KEY (state_id) REFERENCES public.states(id);


--
-- Name: reports fk_rails_34e271b8f8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports
    ADD CONSTRAINT fk_rails_34e271b8f8 FOREIGN KEY (category_id) REFERENCES public.categories(id);


--
-- Name: push_subscriptions fk_rails_43d43720fc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.push_subscriptions
    ADD CONSTRAINT fk_rails_43d43720fc FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: categories fk_rails_4431b344ec; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT fk_rails_4431b344ec FOREIGN KEY (alcaldia_id) REFERENCES public.alcaldias(id);


--
-- Name: system_audit_logs fk_rails_51f4ecb588; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system_audit_logs
    ADD CONSTRAINT fk_rails_51f4ecb588 FOREIGN KEY (actor_id) REFERENCES public.users(id);


--
-- Name: reports fk_rails_603b4fc04c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports
    ADD CONSTRAINT fk_rails_603b4fc04c FOREIGN KEY (alcaldia_id) REFERENCES public.alcaldias(id);


--
-- Name: sessions fk_rails_758836b4f0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT fk_rails_758836b4f0 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: reports fk_rails_87004f508b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports
    ADD CONSTRAINT fk_rails_87004f508b FOREIGN KEY (resolved_by_id) REFERENCES public.users(id);


--
-- Name: users fk_rails_889b0bfe64; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_889b0bfe64 FOREIGN KEY (alcaldia_id) REFERENCES public.alcaldias(id);


--
-- Name: active_storage_variant_records fk_rails_993965df05; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT fk_rails_993965df05 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: report_resolution_cycles fk_rails_a598887808; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_resolution_cycles
    ADD CONSTRAINT fk_rails_a598887808 FOREIGN KEY (report_id) REFERENCES public.reports(id);


--
-- Name: notifications fk_rails_b080fb4855; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT fk_rails_b080fb4855 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: active_storage_attachments fk_rails_c3b3935057; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT fk_rails_c3b3935057 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: reports fk_rails_c4cb6e6463; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports
    ADD CONSTRAINT fk_rails_c4cb6e6463 FOREIGN KEY (reporter_id) REFERENCES public.users(id);


--
-- Name: report_resolution_cycles fk_rails_c925542fc3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_resolution_cycles
    ADD CONSTRAINT fk_rails_c925542fc3 FOREIGN KEY (assignee_id) REFERENCES public.users(id);


--
-- Name: users fk_rails_cc166f32f0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_cc166f32f0 FOREIGN KEY (manager_id) REFERENCES public.users(id);


--
-- Name: report_resolution_cycles fk_rails_eab52011d6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_resolution_cycles
    ADD CONSTRAINT fk_rails_eab52011d6 FOREIGN KEY (resolver_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20260303010446'),
('20260303010445'),
('20260303002345'),
('20260302212822'),
('20260302212807'),
('20260302193404'),
('20260302171828'),
('20260302171458'),
('20260302143209'),
('20260302141706'),
('20260302093903'),
('20260302093856'),
('20260302091806'),
('20260302083724'),
('20260302075905'),
('20260302075248'),
('20260302075246'),
('20260302072028'),
('20260302072025'),
('20260302072024'),
('20260302070512'),
('20260302070408'),
('20260302070353'),
('20260302070352');


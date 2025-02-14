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
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


--
-- Name: creator_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.creator_status AS ENUM (
    'signed_up',
    'verified',
    'inactive'
);


--
-- Name: func_refresh_creator_details(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.func_refresh_creator_details() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        BEGIN
          REFRESH MATERIALIZED VIEW CONCURRENTLY creator_details;
          RETURN NULL;
        EXCEPTION
          WHEN feature_not_supported THEN
            RETURN NULL;
        END $$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: account_campaigns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.account_campaigns (
    id integer NOT NULL,
    account_id integer,
    campaign_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: account_campaigns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.account_campaigns_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: account_campaigns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.account_campaigns_id_seq OWNED BY public.account_campaigns.id;


--
-- Name: accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.accounts (
    id integer NOT NULL,
    creator_id integer,
    type character varying,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.accounts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.accounts_id_seq OWNED BY public.accounts.id;


--
-- Name: addresses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.addresses (
    id integer NOT NULL,
    street character varying NOT NULL,
    city character varying NOT NULL,
    state_id integer NOT NULL,
    zipcode character varying NOT NULL
);


--
-- Name: addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.addresses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.addresses_id_seq OWNED BY public.addresses.id;


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
-- Name: campaigns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.campaigns (
    id integer NOT NULL,
    user_id integer,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: campaigns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.campaigns_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: campaigns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.campaigns_id_seq OWNED BY public.campaigns.id;


--
-- Name: creators; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.creators (
    id integer NOT NULL,
    first_name character varying NOT NULL,
    last_name character varying NOT NULL,
    email character varying NOT NULL,
    username character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    insights jsonb DEFAULT '{}'::jsonb,
    status public.creator_status DEFAULT 'signed_up'::public.creator_status NOT NULL
);


--
-- Name: creators_billing_addresses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.creators_billing_addresses (
    id integer NOT NULL,
    creator_id integer NOT NULL,
    address_id integer NOT NULL
);


--
-- Name: creators_shipping_addresses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.creators_shipping_addresses (
    id integer NOT NULL,
    creator_id integer NOT NULL,
    address_id integer NOT NULL,
    "primary" boolean DEFAULT false NOT NULL
);


--
-- Name: states; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.states (
    id integer NOT NULL,
    code character varying NOT NULL,
    name character varying NOT NULL
);


--
-- Name: creator_details; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.creator_details AS
 SELECT creators.id,
    creators.first_name,
    creators.last_name,
    creators.email,
    creators.username,
    creators.created_at,
    billing_address.id AS billing_address_id,
    billing_address.street AS billing_address_street,
    billing_address.city AS billing_address_city,
    billing_state.code AS billing_address_code,
    billing_address.zipcode AS billing_zipcode,
    shipping_address.id AS shipping_address_id,
    shipping_address.street AS shipping_street,
    shipping_address.city AS shipping_city,
    shipping_state.code AS shipping_state,
    shipping_address.zipcode AS shipping_zipcode
   FROM ((((((public.creators
     LEFT JOIN public.creators_billing_addresses ON ((creators.id = creators_billing_addresses.creator_id)))
     LEFT JOIN public.addresses billing_address ON ((billing_address.id = creators_billing_addresses.address_id)))
     LEFT JOIN public.states billing_state ON ((billing_address.state_id = billing_state.id)))
     LEFT JOIN public.creators_shipping_addresses ON (((creators.id = creators_shipping_addresses.creator_id) AND (creators_shipping_addresses."primary" = true))))
     LEFT JOIN public.addresses shipping_address ON ((shipping_address.id = creators_shipping_addresses.address_id)))
     LEFT JOIN public.states shipping_state ON ((shipping_address.state_id = shipping_state.id)))
  WITH NO DATA;


--
-- Name: creators_billing_addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.creators_billing_addresses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: creators_billing_addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.creators_billing_addresses_id_seq OWNED BY public.creators_billing_addresses.id;


--
-- Name: creators_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.creators_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: creators_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.creators_id_seq OWNED BY public.creators.id;


--
-- Name: creators_shipping_addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.creators_shipping_addresses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: creators_shipping_addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.creators_shipping_addresses_id_seq OWNED BY public.creators_shipping_addresses.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: states_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.states_id_seq
    AS integer
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
    roles character varying[] DEFAULT '{}'::character varying[],
    settings public.hstore DEFAULT ''::public.hstore
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    AS integer
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
-- Name: account_campaigns id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_campaigns ALTER COLUMN id SET DEFAULT nextval('public.account_campaigns_id_seq'::regclass);


--
-- Name: accounts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts ALTER COLUMN id SET DEFAULT nextval('public.accounts_id_seq'::regclass);


--
-- Name: addresses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addresses ALTER COLUMN id SET DEFAULT nextval('public.addresses_id_seq'::regclass);


--
-- Name: campaigns id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaigns ALTER COLUMN id SET DEFAULT nextval('public.campaigns_id_seq'::regclass);


--
-- Name: creators id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.creators ALTER COLUMN id SET DEFAULT nextval('public.creators_id_seq'::regclass);


--
-- Name: creators_billing_addresses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.creators_billing_addresses ALTER COLUMN id SET DEFAULT nextval('public.creators_billing_addresses_id_seq'::regclass);


--
-- Name: creators_shipping_addresses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.creators_shipping_addresses ALTER COLUMN id SET DEFAULT nextval('public.creators_shipping_addresses_id_seq'::regclass);


--
-- Name: states id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.states ALTER COLUMN id SET DEFAULT nextval('public.states_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: account_campaigns account_campaigns_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_campaigns
    ADD CONSTRAINT account_campaigns_pkey PRIMARY KEY (id);


--
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: addresses addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: campaigns campaigns_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaigns
    ADD CONSTRAINT campaigns_pkey PRIMARY KEY (id);


--
-- Name: creators_billing_addresses creators_billing_addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.creators_billing_addresses
    ADD CONSTRAINT creators_billing_addresses_pkey PRIMARY KEY (id);


--
-- Name: creators creators_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.creators
    ADD CONSTRAINT creators_pkey PRIMARY KEY (id);


--
-- Name: creators_shipping_addresses creators_shipping_addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.creators_shipping_addresses
    ADD CONSTRAINT creators_shipping_addresses_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: states states_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.states
    ADD CONSTRAINT states_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: creator_details_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX creator_details_creator_id ON public.creator_details USING btree (id);


--
-- Name: creators_insights_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX creators_insights_idx ON public.creators USING gin (insights);


--
-- Name: creators_lower_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX creators_lower_email ON public.creators USING btree (lower((email)::text));


--
-- Name: creators_lower_first_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX creators_lower_first_name ON public.creators USING btree (lower((first_name)::text) varchar_pattern_ops);


--
-- Name: creators_lower_last_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX creators_lower_last_name ON public.creators USING btree (lower((last_name)::text) varchar_pattern_ops);


--
-- Name: index_addresses_on_state_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_addresses_on_state_id ON public.addresses USING btree (state_id);


--
-- Name: index_creators_billing_addresses_on_address_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_creators_billing_addresses_on_address_id ON public.creators_billing_addresses USING btree (address_id);


--
-- Name: index_creators_billing_addresses_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_creators_billing_addresses_on_creator_id ON public.creators_billing_addresses USING btree (creator_id);


--
-- Name: index_creators_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_creators_on_email ON public.creators USING btree (email);


--
-- Name: index_creators_on_username; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_creators_on_username ON public.creators USING btree (username);


--
-- Name: index_creators_shipping_addresses_on_address_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_creators_shipping_addresses_on_address_id ON public.creators_shipping_addresses USING btree (address_id);


--
-- Name: index_creators_shipping_addresses_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_creators_shipping_addresses_on_creator_id ON public.creators_shipping_addresses USING btree (creator_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: users_roles; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_roles ON public.users USING gin (roles);


--
-- Name: addresses trigger_refresh_creator_details; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_refresh_creator_details AFTER INSERT OR DELETE OR UPDATE ON public.addresses FOR EACH STATEMENT EXECUTE FUNCTION public.func_refresh_creator_details();


--
-- Name: creators trigger_refresh_creator_details; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_refresh_creator_details AFTER INSERT OR DELETE OR UPDATE ON public.creators FOR EACH STATEMENT EXECUTE FUNCTION public.func_refresh_creator_details();


--
-- Name: creators_billing_addresses trigger_refresh_creator_details; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_refresh_creator_details AFTER INSERT OR DELETE OR UPDATE ON public.creators_billing_addresses FOR EACH STATEMENT EXECUTE FUNCTION public.func_refresh_creator_details();


--
-- Name: creators_shipping_addresses trigger_refresh_creator_details; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_refresh_creator_details AFTER INSERT OR DELETE OR UPDATE ON public.creators_shipping_addresses FOR EACH STATEMENT EXECUTE FUNCTION public.func_refresh_creator_details();


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20170322042945'),
('20170322042906'),
('20170322042530'),
('20170214032027'),
('20170213202323'),
('20170213201301'),
('20170213200143'),
('20170213195815'),
('20170213195513'),
('20170213193405'),
('20170213185557'),
('20170213183955'),
('20170205175901'),
('20170203100716'),
('20170202085152');


--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


SET search_path = public, pg_catalog;

--
-- Name: creator_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE creator_status AS ENUM (
    'signed_up',
    'verified',
    'inactive'
);


--
-- Name: func_refresh_creator_details(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION func_refresh_creator_details() RETURNS trigger
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

SET default_with_oids = false;

--
-- Name: account_campaigns; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE account_campaigns (
    id integer NOT NULL,
    account_id integer,
    campaign_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: account_campaigns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE account_campaigns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: account_campaigns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE account_campaigns_id_seq OWNED BY account_campaigns.id;


--
-- Name: accounts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE accounts (
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

CREATE SEQUENCE accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE accounts_id_seq OWNED BY accounts.id;


--
-- Name: addresses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE addresses (
    id integer NOT NULL,
    street character varying NOT NULL,
    city character varying NOT NULL,
    state_id integer NOT NULL,
    zipcode character varying NOT NULL
);


--
-- Name: addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE addresses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE addresses_id_seq OWNED BY addresses.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: campaigns; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE campaigns (
    id integer NOT NULL,
    user_id integer,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: campaigns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE campaigns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: campaigns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE campaigns_id_seq OWNED BY campaigns.id;


--
-- Name: creators; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE creators (
    id integer NOT NULL,
    first_name character varying NOT NULL,
    last_name character varying NOT NULL,
    email character varying NOT NULL,
    username character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    insights json DEFAULT '{}'::json,
    status creator_status DEFAULT 'signed_up'::creator_status NOT NULL
);


--
-- Name: creators_billing_addresses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE creators_billing_addresses (
    id integer NOT NULL,
    creator_id integer NOT NULL,
    address_id integer NOT NULL
);


--
-- Name: creators_shipping_addresses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE creators_shipping_addresses (
    id integer NOT NULL,
    creator_id integer NOT NULL,
    address_id integer NOT NULL,
    "primary" boolean DEFAULT false NOT NULL
);


--
-- Name: states; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE states (
    id integer NOT NULL,
    code character varying NOT NULL,
    name character varying NOT NULL
);


--
-- Name: creator_details; Type: MATERIALIZED VIEW; Schema: public; Owner: -; Tablespace: 
--

CREATE MATERIALIZED VIEW creator_details AS
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
   FROM ((((((creators
     LEFT JOIN creators_billing_addresses ON ((creators.id = creators_billing_addresses.creator_id)))
     LEFT JOIN addresses billing_address ON ((billing_address.id = creators_billing_addresses.address_id)))
     LEFT JOIN states billing_state ON ((billing_address.state_id = billing_state.id)))
     LEFT JOIN creators_shipping_addresses ON (((creators.id = creators_shipping_addresses.creator_id) AND (creators_shipping_addresses."primary" = true))))
     LEFT JOIN addresses shipping_address ON ((shipping_address.id = creators_shipping_addresses.address_id)))
     LEFT JOIN states shipping_state ON ((shipping_address.state_id = shipping_state.id)))
  WITH NO DATA;


--
-- Name: creators_billing_addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE creators_billing_addresses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: creators_billing_addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE creators_billing_addresses_id_seq OWNED BY creators_billing_addresses.id;


--
-- Name: creators_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE creators_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: creators_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE creators_id_seq OWNED BY creators.id;


--
-- Name: creators_shipping_addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE creators_shipping_addresses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: creators_shipping_addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE creators_shipping_addresses_id_seq OWNED BY creators_shipping_addresses.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: states_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE states_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: states_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE states_id_seq OWNED BY states.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
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
    settings hstore DEFAULT ''::hstore
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY account_campaigns ALTER COLUMN id SET DEFAULT nextval('account_campaigns_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY accounts ALTER COLUMN id SET DEFAULT nextval('accounts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY addresses ALTER COLUMN id SET DEFAULT nextval('addresses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY campaigns ALTER COLUMN id SET DEFAULT nextval('campaigns_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY creators ALTER COLUMN id SET DEFAULT nextval('creators_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY creators_billing_addresses ALTER COLUMN id SET DEFAULT nextval('creators_billing_addresses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY creators_shipping_addresses ALTER COLUMN id SET DEFAULT nextval('creators_shipping_addresses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY states ALTER COLUMN id SET DEFAULT nextval('states_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: account_campaigns_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY account_campaigns
    ADD CONSTRAINT account_campaigns_pkey PRIMARY KEY (id);


--
-- Name: accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: campaigns_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY campaigns
    ADD CONSTRAINT campaigns_pkey PRIMARY KEY (id);


--
-- Name: creators_billing_addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY creators_billing_addresses
    ADD CONSTRAINT creators_billing_addresses_pkey PRIMARY KEY (id);


--
-- Name: creators_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY creators
    ADD CONSTRAINT creators_pkey PRIMARY KEY (id);


--
-- Name: creators_shipping_addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY creators_shipping_addresses
    ADD CONSTRAINT creators_shipping_addresses_pkey PRIMARY KEY (id);


--
-- Name: states_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY states
    ADD CONSTRAINT states_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: creator_details_creator_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX creator_details_creator_id ON creator_details USING btree (id);


--
-- Name: creators_lower_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX creators_lower_email ON creators USING btree (lower((email)::text));


--
-- Name: creators_lower_first_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX creators_lower_first_name ON creators USING btree (lower((first_name)::text) varchar_pattern_ops);


--
-- Name: creators_lower_last_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX creators_lower_last_name ON creators USING btree (lower((last_name)::text) varchar_pattern_ops);


--
-- Name: index_addresses_on_state_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_addresses_on_state_id ON addresses USING btree (state_id);


--
-- Name: index_creators_billing_addresses_on_address_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_creators_billing_addresses_on_address_id ON creators_billing_addresses USING btree (address_id);


--
-- Name: index_creators_billing_addresses_on_creator_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_creators_billing_addresses_on_creator_id ON creators_billing_addresses USING btree (creator_id);


--
-- Name: index_creators_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_creators_on_email ON creators USING btree (email);


--
-- Name: index_creators_on_username; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_creators_on_username ON creators USING btree (username);


--
-- Name: index_creators_shipping_addresses_on_address_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_creators_shipping_addresses_on_address_id ON creators_shipping_addresses USING btree (address_id);


--
-- Name: index_creators_shipping_addresses_on_creator_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_creators_shipping_addresses_on_creator_id ON creators_shipping_addresses USING btree (creator_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: users_roles; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX users_roles ON users USING gin (roles);


--
-- Name: trigger_refresh_creator_details; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_refresh_creator_details AFTER INSERT OR DELETE OR UPDATE ON creators FOR EACH STATEMENT EXECUTE PROCEDURE func_refresh_creator_details();


--
-- Name: trigger_refresh_creator_details; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_refresh_creator_details AFTER INSERT OR DELETE OR UPDATE ON creators_shipping_addresses FOR EACH STATEMENT EXECUTE PROCEDURE func_refresh_creator_details();


--
-- Name: trigger_refresh_creator_details; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_refresh_creator_details AFTER INSERT OR DELETE OR UPDATE ON creators_billing_addresses FOR EACH STATEMENT EXECUTE PROCEDURE func_refresh_creator_details();


--
-- Name: trigger_refresh_creator_details; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_refresh_creator_details AFTER INSERT OR DELETE OR UPDATE ON addresses FOR EACH STATEMENT EXECUTE PROCEDURE func_refresh_creator_details();


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES
('20170202085152'),
('20170203100716'),
('20170205175901'),
('20170213183955'),
('20170213185557'),
('20170213193405'),
('20170213195513'),
('20170213195815'),
('20170213200143'),
('20170213201301'),
('20170213202323'),
('20170214032027'),
('20170322042530'),
('20170322042906'),
('20170322042945');



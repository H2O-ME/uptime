-- Auto-generated schema for Supabase (PostgreSQL)
-- Please review and adjust types if necessary

CREATE TABLE "user"(
  "id" SERIAL PRIMARY KEY NOT NULL, 
  "username" VARCHAR(255) NOT NULL UNIQUE, 
  "password" VARCHAR(255), 
  "active" BOOLEAN NOT NULL DEFAULT true, 
  "timezone" VARCHAR(150), twofa_secret VARCHAR(64), twofa_status BOOLEAN default false NOT NULL, twofa_last_token VARCHAR(6));

CREATE TABLE "notification"(
  "id" SERIAL PRIMARY KEY NOT NULL, 
  "name" VARCHAR(255), 
  "active" BOOLEAN NOT NULL DEFAULT true, 
  "user_id" INTEGER NOT NULL, is_default BOOLEAN default false NOT NULL, config TEXT);

CREATE TABLE "monitor_notification"(
  "id" SERIAL PRIMARY KEY NOT NULL, 
  "monitor_id" INTEGER NOT NULL REFERENCES "monitor"("id") ON DELETE CASCADE ON UPDATE CASCADE, 
  "notification_id" INTEGER NOT NULL REFERENCES "notification"("id") ON DELETE CASCADE ON UPDATE CASCADE);

CREATE TABLE tag (
	id SERIAL PRIMARY KEY,
	name VARCHAR(255) NOT NULL,
    color VARCHAR(255) NOT NULL,
	created_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE monitor_tag (
	id SERIAL PRIMARY KEY,
	monitor_id INTEGER NOT NULL,
	tag_id INTEGER NOT NULL,
	value TEXT,
	CONSTRAINT FK_tag FOREIGN KEY (tag_id) REFERENCES tag(id) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT FK_monitor FOREIGN KEY (monitor_id) REFERENCES monitor(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "setting"
(
    id SERIAL PRIMARY KEY,
    key VARCHAR(200) not null
        unique,
    value TEXT,
    type VARCHAR(20)
);

CREATE TABLE incident
(
    "id" SERIAL not null
        constraint incident_pk
            PRIMARY KEY,
    title VARCHAR(255) not null,
    content TEXT not null,
    style VARCHAR(30) default 'warning' not null,
    created_date TIMESTAMP WITH TIME ZONE default CURRENT_TIMESTAMP not null,
    last_updated_date TIMESTAMP WITH TIME ZONE,
    pin BOOLEAN default true not null,
    active BOOLEAN default true not null
, status_page_id INTEGER);

CREATE TABLE "group"
(
    "id" SERIAL      not null
        constraint group_pk
            PRIMARY KEY,
    name         VARCHAR(255) not null,
    created_date TIMESTAMP WITH TIME ZONE              default CURRENT_TIMESTAMP not null,
    public       BOOLEAN               default false not null,
    active       BOOLEAN               default true not null,
    "weight" INTEGER      NOT NULL DEFAULT 1000
, status_page_id INTEGER);

CREATE TABLE "monitor_group"
(
    "id"         SERIAL PRIMARY KEY NOT NULL,
    "monitor_id" INTEGER                           NOT NULL REFERENCES "monitor" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    "group_id"   INTEGER                           NOT NULL REFERENCES "group" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    "weight" INTEGER NOT NULL DEFAULT 1000
, send_url BOOLEAN DEFAULT false NOT NULL, "custom_url" text);

CREATE TABLE "notification_sent_history" (
    "id" SERIAL PRIMARY KEY NOT NULL,
    "type" VARCHAR(50) NOT NULL,
    "monitor_id" INTEGER NOT NULL,
    "days" INTEGER NOT NULL,
    UNIQUE("type", "monitor_id", "days")
);

CREATE TABLE docker_host (
	id SERIAL PRIMARY KEY,
	user_id INT NOT NULL,
	docker_daemon VARCHAR(255),
	docker_type VARCHAR(255),
	name VARCHAR(255)
);

CREATE TABLE "status_page"(
    "id" SERIAL PRIMARY KEY NOT NULL,
    "slug" VARCHAR(255) NOT NULL UNIQUE,
    "title" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "icon" VARCHAR(255) NOT NULL,
    "theme" VARCHAR(30) NOT NULL,
    "published" BOOLEAN NOT NULL DEFAULT true,
    "search_engine_index" BOOLEAN NOT NULL DEFAULT true,
    "show_tags" BOOLEAN NOT NULL DEFAULT false,
    "password" VARCHAR,
    "created_date" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "modified_date" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
, footer_text TEXT, custom_css TEXT, show_powered_by BOOLEAN NOT NULL DEFAULT true, "analytics_id" VARCHAR, show_certificate_expiry BOOLEAN default false NOT NULL, "auto_refresh_interval" integer default '300', "analytics_script_url" varchar(255), "analytics_type" text check ("analytics_type" in ('google', 'umami', 'plausible', 'matomo')) default null, "show_only_last_heartbeat" boolean not null default false, "rss_title" varchar(255));

CREATE TABLE "status_page_cname"(
    "id" SERIAL PRIMARY KEY NOT NULL,
    "status_page_id" INTEGER NOT NULL REFERENCES "status_page"("id") ON DELETE CASCADE ON UPDATE CASCADE,
    "domain" VARCHAR NOT NULL UNIQUE
);

CREATE TABLE "maintenance" (
    "id" SERIAL PRIMARY KEY NOT NULL,
    "title" VARCHAR(150) NOT NULL,
    "description" TEXT NOT NULL,
    "user_id" INTEGER REFERENCES "user"("id") ON DELETE SET NULL ON UPDATE CASCADE,
    "active" BOOLEAN NOT NULL DEFAULT true,
    "strategy" VARCHAR(50) NOT NULL DEFAULT 'single',
    "start_date" TIMESTAMP WITH TIME ZONE,
    "end_date" TIMESTAMP WITH TIME ZONE,
    "start_time" TIME,
    "end_time" TIME,
    "weekdays" VARCHAR(250) DEFAULT '[]',
    "days_of_month" TEXT DEFAULT '[]',
    "interval_day" INTEGER
, cron TEXT, timezone VARCHAR(255), duration INTEGER, "last_start_date" TIMESTAMP WITH TIME ZONE);

CREATE TABLE maintenance_status_page (
    id SERIAL PRIMARY KEY,
    status_page_id INTEGER NOT NULL,
    maintenance_id INTEGER NOT NULL,
    CONSTRAINT FK_maintenance FOREIGN KEY (maintenance_id) REFERENCES maintenance (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_status_page FOREIGN KEY (status_page_id) REFERENCES status_page (id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE monitor_maintenance (
    id SERIAL PRIMARY KEY,
    monitor_id INTEGER NOT NULL,
    maintenance_id INTEGER NOT NULL,
    CONSTRAINT FK_maintenance FOREIGN KEY (maintenance_id) REFERENCES maintenance (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_monitor FOREIGN KEY (monitor_id) REFERENCES monitor (id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "api_key" (
    "id" SERIAL PRIMARY KEY,
    "key" VARCHAR(255) NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "user_id" INTEGER NOT NULL,
    "created_date" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "active" BOOLEAN DEFAULT true NOT NULL,
    "expires" TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    CONSTRAINT FK_user FOREIGN KEY ("user_id") REFERENCES "user"("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "knex_migrations" ("id" SERIAL PRIMARY KEY, "name" varchar(255), "batch" integer, "migration_time" TIMESTAMP WITH TIME ZONE);

CREATE TABLE "knex_migrations_lock" ("index" SERIAL PRIMARY KEY, "is_locked" integer);

CREATE TABLE "remote_browser" ("id" SERIAL PRIMARY KEY, "name" varchar(255) not null, "url" varchar(255) not null, "user_id" integer);

CREATE TABLE "monitor_tls_info" ("id" SERIAL PRIMARY KEY NOT NULL, "monitor_id" INTEGER NOT NULL REFERENCES "monitor" ("id") ON DELETE CASCADE ON UPDATE CASCADE, "info_json" text);

CREATE TABLE "proxy" ("id" SERIAL PRIMARY KEY NOT NULL, "user_id" INT NOT NULL, "protocol" VARCHAR(10) NOT NULL, "host" VARCHAR(255) NOT NULL, "port" integer, "auth" BOOLEAN NOT NULL, "username" VARCHAR(255) NULL, "password" VARCHAR(255) NULL, "active" BOOLEAN NOT NULL DEFAULT true, "default" BOOLEAN NOT NULL DEFAULT false, "created_date" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP);

CREATE TABLE "domain_expiry" ("id" SERIAL PRIMARY KEY NOT NULL, "last_check" TIMESTAMP WITH TIME ZONE, "domain" varchar(255) NOT NULL, "expiry" TIMESTAMP WITH TIME ZONE, "last_expiry_notification_sent" integer DEFAULT null);

CREATE TABLE "heartbeat" ("id" SERIAL PRIMARY KEY NOT NULL, "important" BOOLEAN NOT NULL DEFAULT false, "monitor_id" INTEGER NOT NULL REFERENCES "monitor" ("id") ON DELETE CASCADE ON UPDATE CASCADE, "status" SMALLINT NOT NULL, "msg" TEXT, "time" TIMESTAMP WITH TIME ZONE NOT NULL, "ping" bigint, "duration" INTEGER NOT NULL DEFAULT 0, "down_count" INTEGER NOT NULL DEFAULT 0, "end_time" TIMESTAMP WITH TIME ZONE NULL DEFAULT null, "retries" integer NOT NULL DEFAULT '0', "response" text NULL DEFAULT null);

CREATE TABLE "stat_minutely" ("id" SERIAL PRIMARY KEY NOT NULL, "monitor_id" integer NOT NULL, "timestamp" integer NOT NULL, "ping" float NOT NULL, "up" integer NOT NULL, "down" integer NOT NULL, "ping_min" float NOT NULL DEFAULT '0', "ping_max" float NOT NULL DEFAULT '0', "extras" text DEFAULT null, FOREIGN KEY ("monitor_id") REFERENCES "monitor" ("id") ON DELETE CASCADE ON UPDATE CASCADE);

CREATE TABLE "stat_daily" ("id" SERIAL PRIMARY KEY NOT NULL, "monitor_id" integer NOT NULL, "timestamp" integer NOT NULL, "ping" float NOT NULL, "up" integer NOT NULL, "down" integer NOT NULL, "ping_min" float NOT NULL DEFAULT '0', "ping_max" float NOT NULL DEFAULT '0', "extras" text DEFAULT null, FOREIGN KEY ("monitor_id") REFERENCES "monitor" ("id") ON DELETE CASCADE ON UPDATE CASCADE);

CREATE TABLE "stat_hourly" ("id" SERIAL PRIMARY KEY NOT NULL, "monitor_id" integer NOT NULL, "timestamp" integer NOT NULL, "ping" float NOT NULL, "ping_min" float NOT NULL DEFAULT '0', "ping_max" float NOT NULL DEFAULT '0', "up" integer NOT NULL, "down" integer NOT NULL, "extras" text DEFAULT null, FOREIGN KEY ("monitor_id") REFERENCES "monitor" ("id") ON DELETE CASCADE ON UPDATE CASCADE);

CREATE TABLE "monitor" ("id" SERIAL PRIMARY KEY NOT NULL, "name" VARCHAR(150), "active" BOOLEAN NOT NULL DEFAULT true, "user_id" INTEGER REFERENCES "user" ON DELETE SET NULL ON UPDATE CASCADE, "interval" INTEGER NOT NULL DEFAULT 20, "url" TEXT, "type" VARCHAR(20), "weight" INTEGER DEFAULT 2000, "hostname" VARCHAR(255), "port" INTEGER, "created_date" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP, "keyword" VARCHAR(255), "maxretries" INTEGER NOT NULL DEFAULT 0, "ignore_tls" BOOLEAN NOT NULL DEFAULT false, "upside_down" BOOLEAN NOT NULL DEFAULT false, "maxredirects" INTEGER NOT NULL DEFAULT 10, "accepted_statuscodes_json" TEXT NOT NULL DEFAULT '""200-299""', "dns_resolve_type" VARCHAR(5), "dns_resolve_server" VARCHAR(255), "dns_last_result" text, "retry_interval" INTEGER NOT NULL DEFAULT 0, "push_token" varchar(32), "method" TEXT NOT NULL DEFAULT 'GET', "body" TEXT DEFAULT null, "headers" TEXT DEFAULT null, "basic_auth_user" TEXT DEFAULT null, "basic_auth_pass" TEXT DEFAULT null, "docker_host" INTEGER REFERENCES "docker_host" ("id"), "docker_container" VARCHAR(255), "proxy_id" INTEGER REFERENCES "proxy" ("id"), "expiry_notification" BOOLEAN DEFAULT true, "mqtt_topic" TEXT, "mqtt_success_message" VARCHAR(255), "mqtt_username" VARCHAR(255), "mqtt_password" VARCHAR(255), "database_connection_string" VARCHAR(2000), "database_query" TEXT, "auth_method" VARCHAR(250), "auth_domain" TEXT, "auth_workstation" TEXT, "grpc_url" VARCHAR(255) DEFAULT null, "grpc_protobuf" TEXT DEFAULT null, "grpc_body" TEXT DEFAULT null, "grpc_metadata" TEXT DEFAULT null, "grpc_method" VARCHAR(255) DEFAULT null, "grpc_service_name" VARCHAR(255) DEFAULT null, "grpc_enable_tls" BOOLEAN NOT NULL DEFAULT false, "radius_username" VARCHAR(255), "radius_password" VARCHAR(255), "radius_calling_station_id" VARCHAR(50), "radius_called_station_id" VARCHAR(50), "radius_secret" VARCHAR(255), "resend_interval" INTEGER NOT NULL DEFAULT 0, "packet_size" INTEGER NOT NULL DEFAULT 56, "game" VARCHAR(255), "http_body_encoding" VARCHAR(25), "description" TEXT DEFAULT null, "tls_ca" TEXT DEFAULT null, "tls_cert" TEXT DEFAULT null, "tls_key" TEXT DEFAULT null, "parent" INTEGER REFERENCES "monitor" ("id") ON DELETE SET NULL ON UPDATE CASCADE, "invert_keyword" BOOLEAN NOT NULL DEFAULT false, "json_path" TEXT, "expected_value" VARCHAR(255), "kafka_producer_topic" VARCHAR(255), "kafka_producer_brokers" TEXT, "kafka_producer_sasl_options" TEXT, "kafka_producer_message" TEXT, "oauth_client_id" TEXT DEFAULT null, "oauth_client_secret" TEXT DEFAULT null, "oauth_token_url" TEXT DEFAULT null, "oauth_scopes" TEXT DEFAULT null, "oauth_auth_method" TEXT DEFAULT null, "timeout" DOUBLE NOT NULL DEFAULT 0, "gamedig_given_port_only" BOOLEAN NOT NULL DEFAULT true, "kafka_producer_ssl" BOOLEAN NOT NULL DEFAULT false, "kafka_producer_allow_auto_topic_creation" BOOLEAN NOT NULL DEFAULT false, "mqtt_check_type" varchar(255) NOT NULL DEFAULT 'keyword', "remote_browser" integer NULL DEFAULT null, "snmp_oid" varchar(255) DEFAULT null, "snmp_version" text CHECK ("snmp_version" in('1' , '2c' , '3')) DEFAULT '2c', "json_path_operator" varchar(255) DEFAULT null, "cache_bust" boolean NOT NULL DEFAULT false, "conditions" text NOT NULL DEFAULT '[]', "rabbitmq_nodes" text, "rabbitmq_username" varchar(255), "rabbitmq_password" varchar(255), "smtp_security" varchar(255) DEFAULT null, "ws_ignore_sec_websocket_accept_header" boolean NOT NULL DEFAULT false, "ws_subprotocol" varchar(255) NOT NULL DEFAULT '', "ping_count" integer NOT NULL DEFAULT '1', "ping_numeric" boolean NOT NULL DEFAULT true, "ping_per_request_timeout" integer NOT NULL DEFAULT '2', "ip_family" varchar(4) DEFAULT null, "manual_status" integer, "oauth_audience" varchar(255) NULL DEFAULT null, "mqtt_websocket_path" varchar(255) NULL, "domain_expiry_notification" boolean DEFAULT false, "save_response" boolean NOT NULL DEFAULT false, "save_error_response" boolean NOT NULL DEFAULT true, "response_max_length" integer NOT NULL DEFAULT '1024', "system_service_name" varchar(255), "subtype" varchar(10) NULL, "location" varchar(255) NULL, "protocol" varchar(20) NULL, "snmp_v3_username" varchar(255), "expected_tls_alert" varchar(50) DEFAULT null, "retry_only_on_status_code_failure" boolean NOT NULL DEFAULT false, "screenshot_delay" integer NOT NULL DEFAULT '0', FOREIGN KEY ("remote_browser") REFERENCES "remote_browser" ("id"));


-- Migration History
INSERT INTO "knex_migrations" ("name", "batch", "migration_time") VALUES ('2023-08-16-0000-create-uptime.js', 1, '2026-02-22T11:51:33.850Z');
INSERT INTO "knex_migrations" ("name", "batch", "migration_time") VALUES ('2023-08-18-0301-heartbeat.js', 1, '2026-02-22T11:51:33.852Z');
INSERT INTO "knex_migrations" ("name", "batch", "migration_time") VALUES ('2023-09-29-0000-heartbeat-retires.js', 1, '2026-02-22T11:51:33.854Z');
INSERT INTO "knex_migrations" ("name", "batch", "migration_time") VALUES ('2023-10-08-0000-mqtt-query.js', 1, '2026-02-22T11:51:33.857Z');
INSERT INTO "knex_migrations" ("name", "batch", "migration_time") VALUES ('2023-10-11-1915-push-token-to-32.js', 1, '2026-02-22T11:51:33.895Z');
INSERT INTO "knex_migrations" ("name", "batch", "migration_time") VALUES ('2023-10-16-0000-create-remote-browsers.js', 1, '2026-02-22T11:51:33.917Z');
INSERT INTO "knex_migrations" ("name", "batch", "migration_time") VALUES ('2023-12-20-0000-alter-status-page.js', 1, '2026-02-22T11:51:33.919Z');
INSERT INTO "knex_migrations" ("name", "batch", "migration_time") VALUES ('2023-12-21-0000-stat-ping-min-max.js', 1, '2026-02-22T11:51:33.926Z');
INSERT INTO "knex_migrations" ("name", "batch", "migration_time") VALUES ('2023-12-22-0000-hourly-uptime.js', 1, '2026-02-22T11:51:33.928Z');
INSERT INTO "knex_migrations" ("name", "batch", "migration_time") VALUES ('2024-01-22-0000-stats-extras.js', 1, '2026-02-22T11:51:33.935Z');
INSERT INTO "knex_migrations" ("name", "batch", "migration_time") VALUES ('2024-04-26-0000-snmp-monitor.js', 1, '2026-02-22T11:51:33.940Z');
INSERT INTO "knex_migrations" ("name", "batch", "migration_time") VALUES ('2024-08-24-000-add-cache-bust.js', 1, '2026-02-22T11:51:33.943Z');
INSERT INTO "knex_migrations" ("name", "batch", "migration_time") VALUES ('2024-08-24-0000-conditions.js', 1, '2026-02-22T11:51:33.945Z');
INSERT INTO "knex_migrations" ("name", "batch", "migration_time") VALUES ('2024-10-1315-rabbitmq-monitor.js', 1, '2026-02-22T11:51:33.949Z');
INSERT INTO "knex_migrations" ("name", "batch", "migration_time") VALUES ('2024-10-31-0000-fix-snmp-monitor.js', 1, '2026-02-22T11:51:33.950Z');
INSERT INTO "knex_migrations" ("name", "batch", "migration_time") VALUES ('2024-11-27-1927-fix-info-json-data-type.js', 1, '2026-02-22T11:51:33.958Z');
INSERT INTO "knex_migrations" ("name", "batch", "migration_time") VALUES ('2025-01-01-0000-add-smtp.js', 1, '2026-02-22T11:51:33.961Z');
INSERT INTO "knex_migrations" ("name", "batch", "migration_time") VALUES ('2025-02-15-2312-add-wstest.js', 1, '2026-02-22T11:51:33.967Z');
INSERT INTO "knex_migrations" ("name", "batch", "migration_time") VALUES ('2025-02-17-2142-generalize-analytics.js', 1, '2026-02-22T11:51:33.978Z');
INSERT INTO "knex_migrations" ("name", "batch", "migration_time") VALUES ('2025-03-04-0000-ping-advanced-options.js', 1, '2026-02-22T11:51:33.982Z');
INSERT INTO "knex_migrations" ("name", "batch", "migration_time") VALUES ('2025-03-25-0127-fix-5721.js', 1, '2026-02-22T11:51:33.988Z');
INSERT INTO "knex_migrations" ("name", "batch", "migration_time") VALUES ('2025-05-09-0000-add-custom-url.js', 1, '2026-02-22T11:51:33.991Z');
INSERT INTO "knex_migrations" ("name", "batch", "migration_time") VALUES ('2025-06-03-0000-add-ip-family.js', 1, '2026-02-22T11:51:33.993Z');
INSERT INTO "knex_migrations" ("name", "batch", "migration_time") VALUES ('2025-06-11-0000-add-manual-monitor.js', 1, '2026-02-22T11:51:33.996Z');
INSERT INTO "knex_migrations" ("name", "batch", "migration_time") VALUES ('2025-06-13-0000-maintenance-add-last-start.js', 1, '2026-02-22T11:51:34.000Z');
INSERT INTO "knex_migrations" ("name", "batch", "migration_time") VALUES ('2025-06-15-0001-manual-monitor-fix.js', 1, '2026-02-22T11:51:34.018Z');
INSERT INTO "knex_migrations" ("name", "batch", "migration_time") VALUES ('2025-06-24-0000-add-audience-to-oauth.js', 1, '2026-02-22T11:51:34.020Z');
INSERT INTO "knex_migrations" ("name", "batch", "migration_time") VALUES ('2025-07-17-0000-mqtt-websocket-path.js', 1, '2026-02-22T11:51:34.023Z');
INSERT INTO "knex_migrations" ("name", "batch", "migration_time") VALUES ('2025-09-02-0000-add-domain-expiry.js', 1, '2026-02-22T11:51:34.027Z');
INSERT INTO "knex_migrations" ("name", "batch", "migration_time") VALUES ('2025-10-14-0000-add-ip-family-fix.js', 1, '2026-02-22T11:51:34.051Z');
INSERT INTO "knex_migrations" ("name", "batch", "migration_time") VALUES ('2025-10-15-0000-stat-table-fix.js', 1, '2026-02-22T11:51:34.082Z');
INSERT INTO "knex_migrations" ("name", "batch", "migration_time") VALUES ('2025-10-15-0001-add-monitor-response-config.js', 1, '2026-02-22T11:51:34.086Z');
INSERT INTO "knex_migrations" ("name", "batch", "migration_time") VALUES ('2025-10-15-0002-add-response-to-heartbeat.js', 1, '2026-02-22T11:51:34.089Z');
INSERT INTO "knex_migrations" ("name", "batch", "migration_time") VALUES ('2025-10-24-0000-show-only-last-heartbeat.js', 1, '2026-02-22T11:51:34.092Z');
INSERT INTO "knex_migrations" ("name", "batch", "migration_time") VALUES ('2025-12-09-0000-add-system-service-monitor.js', 1, '2026-02-22T11:51:34.095Z');
INSERT INTO "knex_migrations" ("name", "batch", "migration_time") VALUES ('2025-12-17-0000-add-globalping-monitor.js', 1, '2026-02-22T11:51:34.101Z');
INSERT INTO "knex_migrations" ("name", "batch", "migration_time") VALUES ('2025-12-22-0121-optimize-important-indexes.js', 1, '2026-02-22T11:51:34.103Z');
INSERT INTO "knex_migrations" ("name", "batch", "migration_time") VALUES ('2025-12-29-0000-remove-line-notify.js', 1, '2026-02-22T11:51:34.104Z');
INSERT INTO "knex_migrations" ("name", "batch", "migration_time") VALUES ('2025-12-31-2143-add-snmp-v3-username.js', 1, '2026-02-22T11:51:34.108Z');
INSERT INTO "knex_migrations" ("name", "batch", "migration_time") VALUES ('2026-01-02-0551-dns-last-result-to-text.js', 1, '2026-02-22T11:51:34.129Z');
INSERT INTO "knex_migrations" ("name", "batch", "migration_time") VALUES ('2026-01-02-0713-gamedig-v4-to-v5.js', 1, '2026-02-22T11:51:34.132Z');
INSERT INTO "knex_migrations" ("name", "batch", "migration_time") VALUES ('2026-01-05-0000-add-rss-title.js', 1, '2026-02-22T11:51:34.135Z');
INSERT INTO "knex_migrations" ("name", "batch", "migration_time") VALUES ('2026-01-05-0000-add-tls-monitor.js', 1, '2026-02-22T11:51:34.136Z');
INSERT INTO "knex_migrations" ("name", "batch", "migration_time") VALUES ('2026-01-06-0000-fix-domain-expiry-column-type.js', 1, '2026-02-22T11:51:34.145Z');
INSERT INTO "knex_migrations" ("name", "batch", "migration_time") VALUES ('2026-01-10-0000-convert-float-precision.js', 1, '2026-02-22T11:51:34.177Z');
INSERT INTO "knex_migrations" ("name", "batch", "migration_time") VALUES ('2026-01-15-0000-add-json-query-retry-only-status-code.js', 1, '2026-02-22T11:51:34.179Z');
INSERT INTO "knex_migrations" ("name", "batch", "migration_time") VALUES ('2026-01-16-0000-add-screenshot-delay.js', 1, '2026-02-22T11:51:34.181Z');
INSERT INTO "knex_migrations" ("name", "batch", "migration_time") VALUES ('2026-02-07-0000-disable-domain-expiry-unsupported-tlds.js', 1, '2026-02-22T11:51:34.199Z');
CREATE INDEX "monitor_notification_index"
ON "monitor_notification"(
  "monitor_id", 
  "notification_id");

CREATE INDEX monitor_tag_monitor_id_index ON monitor_tag (monitor_id);

CREATE INDEX monitor_tag_tag_id_index ON monitor_tag (tag_id);

CREATE INDEX "fk"
    ON "monitor_group" (
                        "monitor_id",
                        "group_id");

CREATE INDEX "good_index" ON "notification_sent_history" (
    "type",
    "monitor_id",
    "days"
);

CREATE UNIQUE INDEX "slug" ON "status_page"("slug");

CREATE INDEX "manual_active" ON "maintenance" (
    "strategy",
    "active"
);

CREATE INDEX "active" ON "maintenance" ("active");

CREATE INDEX "maintenance_user_id" ON "maintenance" ("user_id");

CREATE INDEX "status_page_id_index"
    ON "maintenance_status_page"("status_page_id");

CREATE INDEX "maintenance_id_index"
    ON "maintenance_status_page"("maintenance_id");

CREATE INDEX "maintenance_id_index2" ON "monitor_maintenance"("maintenance_id");

CREATE INDEX "monitor_id_index" ON "monitor_maintenance"("monitor_id");

CREATE INDEX proxy_user_id ON proxy (user_id);

CREATE UNIQUE INDEX "domain_expiry_domain_unique" on "domain_expiry" ("domain");

CREATE INDEX "monitor_id" ON "heartbeat"("monitor_id");

CREATE INDEX "important" ON "heartbeat"("important");

CREATE INDEX monitor_time_index ON heartbeat (monitor_id, time);

CREATE INDEX "monitor_important_time_index" on "heartbeat" ("monitor_id", "time") where important = true;

CREATE INDEX "heartbeat_important_index" on "heartbeat" ("important") where important = true;

CREATE UNIQUE INDEX "stat_minutely_monitor_id_timestamp_unique" on "stat_minutely" ("monitor_id", "timestamp");

CREATE UNIQUE INDEX "stat_daily_monitor_id_timestamp_unique" on "stat_daily" ("monitor_id", "timestamp");

CREATE UNIQUE INDEX "stat_hourly_monitor_id_timestamp_unique" on "stat_hourly" ("monitor_id", "timestamp");

CREATE INDEX user_id on monitor (user_id);

CREATE INDEX proxy_id ON monitor (proxy_id);

CREATE INDEX "monitor_remote_browser_index" on "monitor" ("remote_browser");


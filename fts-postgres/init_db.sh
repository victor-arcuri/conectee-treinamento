#!/bin/bash

psql -U postgres -d postgres -c "
CREATE DATABASE BD_PESQUISADOR
WITH
OWNER = postgres
ENCODING = 'UTF8'
TABLESPACE = pg_default
CONNECTION LIMIT = -1
IS_TEMPLATE = False;
"

psql -U postgres -d BD_PESQUISADOR -c "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";"
psql -U postgres -d BD_PESQUISADOR -f /docker-entrypoint-initdb.d/tables.sql

psql -U postgres -d BD_PESQUISADOR -c "\COPY pesquisadores FROM '/docker-entrypoint-initdb.d/pesquisadores.csv' DELIMITER ',' CSV HEADER;"
psql -U postgres -d BD_PESQUISADOR -c "\COPY producoes FROM '/docker-entrypoint-initdb.d/producoes.csv' DELIMITER ',' CSV HEADER;"

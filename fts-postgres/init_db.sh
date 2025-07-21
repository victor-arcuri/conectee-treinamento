#!/bin/bash

psql -U postgres -d postgres -c "
CREATE DATABASE BD_PESQUISADOR
WITH
OWNER = postgres
ENCODING = 'UTF8'
LOCALE_PROVIDER = icu
ICU_LOCALE = 'pt-BR'
TEMPLATE = template0
TABLESPACE = pg_default
CONNECTION LIMIT = -1
IS_TEMPLATE = False;
"


psql -U postgres -d BD_PESQUISADOR -c "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";"

psql -U postgres -d BD_PESQUISADOR -f /docker-entrypoint-initdb.d/tables.sql

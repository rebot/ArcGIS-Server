#!/usr/bin/env bash
set -e

# Create new database
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE USER sweco;
    CREATE DATABASE sweco;
    GRANT ALL PRIVILEGES ON DATABASE sweco TO sweco;
EOSQL
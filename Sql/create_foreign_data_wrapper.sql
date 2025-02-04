﻿CREATE EXTENSION IF NOT EXISTS POSTGRES_FDW;

CREATE SERVER IF NOT EXISTS SOURCE_DB
    FOREIGN DATA WRAPPER POSTGRES_FDW
    OPTIONS (host 'localhost', dbname 'world_content', port '5432');

CREATE USER MAPPING IF NOT EXISTS FOR POSTGRES
    SERVER SOURCE_DB
    OPTIONS (user 'postgres', password 'postgres');
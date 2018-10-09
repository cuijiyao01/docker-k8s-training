-- This is a postgres initialization script for the postgres container. 
-- Will be executed during container initialization ($> psql postgres -f initdb.sql)
CREATE ROLE adsuser WITH LOGIN PASSWORD 'initial' INHERIT CREATEDB;
CREATE DATABASE ads WITH ENCODING 'UNICODE' LC_COLLATE 'C' LC_CTYPE 'C' TEMPLATE template0;
GRANT ALL PRIVILEGES ON DATABASE ads TO adsuser;
CREATE SCHEMA ads AUTHORIZATION adsuser;
-- ALTER DATABASE ads SET search_path TO 'ads';
ALTER DATABASE ads OWNER TO adsuser;

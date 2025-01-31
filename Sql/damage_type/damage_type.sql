CREATE FOREIGN TABLE IF NOT EXISTS DAMAGE_TYPE_FT (
    ID BIGINT NOT NULL,
    JSON JSONB NOT NULL
    ) SERVER SOURCE_DB OPTIONS (table_name 'destinydamagetypedefinition');

DROP TABLE IF EXISTS DAMAGE_TYPE;

CREATE TABLE IF NOT EXISTS DAMAGE_TYPE
(
    ID          SERIAL,
    HASH        BIGINT       NOT NULL,
    NAME        VARCHAR(100) NOT NULL,
    DESCRIPTION VARCHAR(100) NOT NULL,
    ICON        VARCHAR(100) NOT NULL,
    RED         SMALLINT     NOT NULL,
    GREEN       SMALLINT     NOT NULL,
    BLUE        SMALLINT     NOT NULL,
    ALPHA       SMALLINT     NOT NULL,
    CONSTRAINT DAMAGE_TYPE_PK PRIMARY KEY (ID)
);

INSERT INTO DAMAGE_TYPE (HASH, NAME, DESCRIPTION, ICON, RED, GREEN, BLUE, ALPHA)
SELECT (JSON ->> 'hash')::BIGINT                                                            AS HASH,
       (JSON -> 'displayProperties' ->> 'name')::VARCHAR(100)                               AS NAME,
       (JSON -> 'displayProperties' ->> 'description')::VARCHAR(100)                        AS DESCRIPTION,
       (COALESCE((JSON -> 'displayProperties' ->> 'icon')::VARCHAR(100), ''))::VARCHAR(100) AS ICON,
       COALESCE((JSON -> 'color' -> 'red')::SMALLINT, 255)::SMALLINT                        AS RED,
       COALESCE((JSON -> 'color' -> 'green')::SMALLINT, 255)::SMALLINT                      AS GREEN,
       COALESCE((JSON -> 'color' -> 'blue')::SMALLINT, 255)::SMALLINT                       AS BLUE,
       COALESCE((JSON -> 'color' -> 'alpha')::SMALLINT, 255)::SMALLINT                      AS ALPHA
FROM PUBLIC.DAMAGE_TYPE_FT;
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
WITH DT AS (
    SELECT 'displayProperties'   AS DISPLAYPROPERTIES,
                     'description'         AS DTDESCR,
                     'color' as COLOR
)
SELECT (JSON ->> 'hash')::BIGINT                                                            AS HASH,
       (JSON -> DT.DISPLAYPROPERTIES ->> 'name')::VARCHAR(100)                               AS NAME,
       (JSON -> DT.DISPLAYPROPERTIES ->> 'description')::VARCHAR(100)                        AS DESCRIPTION,
       (COALESCE((JSON -> DT.DISPLAYPROPERTIES ->> 'icon')::VARCHAR(100), ''))::VARCHAR(100) AS ICON,
       COALESCE((JSON -> DT.COLOR -> 'red')::SMALLINT, 255)::SMALLINT                        AS RED,
       COALESCE((JSON -> DT.COLOR -> 'green')::SMALLINT, 255)::SMALLINT                      AS GREEN,
       COALESCE((JSON -> DT.COLOR -> 'blue')::SMALLINT, 255)::SMALLINT                       AS BLUE,
       COALESCE((JSON -> DT.COLOR -> 'alpha')::SMALLINT, 255)::SMALLINT                      AS ALPHA
FROM PUBLIC.DAMAGE_TYPE_FT CROSS JOIN DT;
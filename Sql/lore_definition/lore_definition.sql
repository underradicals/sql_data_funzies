CREATE FOREIGN TABLE IF NOT EXISTS LORE_DEFINITION_FT (
    ID BIGINT NOT NULL,
    JSON JSONB NOT NULL
    ) SERVER SOURCE_DB OPTIONS (table_name 'destinyloredefinition');

DROP TABLE IF EXISTS LORE_DEFINITION;

CREATE TABLE IF NOT EXISTS LORE_DEFINITION
(
    ID              SERIAL,
    HASH            BIGINT         NOT NULL,
    DESCRIPTION     VARCHAR(12000) NOT NULL CHECK (LENGTH(DESCRIPTION) > 0),
    NAME            VARCHAR(100)   NOT NULL CHECK (LENGTH(NAME) > 0),
    SUBTITLE        VARCHAR(300)   NOT NULL CHECK (LENGTH(SUBTITLE) > 0),
    DESC_LENGTH     INTEGER        NOT NULL CHECK (DESC_LENGTH >= 0),
    SUBTITLE_LENGTH INTEGER        NOT NULL CHECK (SUBTITLE_LENGTH >= 0),
    CONSTRAINT LORE_DEFINITION_PK PRIMARY KEY (ID)
);

INSERT INTO LORE_DEFINITION (HASH, DESCRIPTION, NAME, SUBTITLE, DESC_LENGTH, SUBTITLE_LENGTH)
WITH LORE AS (
    select 'displayProperties' as DisplayProperties,
           'Nothing to see here' as NothingToSeeHere,
           'description' as LoreDescr,
           'name' as LoreName,
           'subtitle' as LoreSubtitle
)
SELECT (JSON ->> 'hash')::BIGINT                                      AS HASH,
       CASE (JSON -> LORE.DISPLAYPROPERTIES ->> LORE.LOREDESCR)::VARCHAR(12000)
           WHEN NULL THEN LORE.NOTHINGTOSEEHERE
           WHEN '' THEN LORE.NOTHINGTOSEEHERE
           ELSE (JSON -> LORE.DISPLAYPROPERTIES ->> LORE.LOREDESCR)::VARCHAR(12000)
           END                                                        AS DESCRIPTION,
       CASE (JSON -> LORE.DISPLAYPROPERTIES ->> 'name')::VARCHAR(100)
           WHEN NULL THEN LORE.NOTHINGTOSEEHERE
           WHEN '' THEN LORE.NOTHINGTOSEEHERE
           ELSE (JSON -> LORE.DISPLAYPROPERTIES ->> 'name')::VARCHAR(100)
           END                                                        AS NAME,
       CASE
           WHEN (JSON ->> LORE.LoreSubtitle)::VARCHAR(300) IS NULL THEN LORE.NOTHINGTOSEEHERE
           WHEN (JSON ->> LORE.LoreSubtitle)::VARCHAR(300) = '' THEN LORE.NOTHINGTOSEEHERE
           ELSE (JSON ->> LORE.LoreSubtitle)::VARCHAR(300)
           END                                                        AS SUBTITLE,
       LENGTH(JSON -> LORE.DISPLAYPROPERTIES ->> LORE.LOREDESCR)::INTEGER AS DESC_LENGTH,
       COALESCE(LENGTH(JSON ->> LORE.LoreSubtitle)::INTEGER, 0)              AS SUBTITLE_LENGTH
FROM PUBLIC.LORE_DEFINITION_FT cross join LORE;
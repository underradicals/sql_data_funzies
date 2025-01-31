-- First install the extension:
CREATE EXTENSION IF NOT EXISTS POSTGRES_FDW;

/*
    ----------------------------------------------------------------------------
    Then create a foreign server on host `localhost`, this could also be
    a remote server `192.82.123.69`. The key here is that `dbname` is the name
    of the database you are pulling data FROM.
    -----------------------------------------------------------------------------

    CREATE SERVER defines a new foreign server. The user who defines the server becomes its owner.

    A foreign server typically encapsulates connection information that a foreign-data wrapper uses
    to access an external data resource. Additional user-specific connection information may be specified
    by means of user mappings.

    The server name must be unique within the database.

    Creating a server requires USAGE privilege on the foreign-data wrapper being used.
*/
CREATE SERVER SOURCE_DB
    FOREIGN DATA WRAPPER POSTGRES_FDW
    OPTIONS (host 'localhost', dbname 'world_content', port '5432');

/*
    A user mapping, defined with CREATE USER MAPPING, is needed as well to identify the role that will be used on the remote server:

    CREATE USER MAPPING defines a mapping of a user to a foreign server. A user mapping typically
    encapsulates connection information that a foreign-data wrapper uses together with the information
    encapsulated by a foreign server to access an external data resource.

    The owner of a foreign server can create user mappings for that server for any user.
    Also, a user can create a user mapping for his own username if USAGE privilege on the
    server has been granted to the user.
*/
CREATE USER MAPPING FOR POSTGRES
    SERVER SOURCE_DB
    OPTIONS (user 'postgres', password 'postgres');

/*
    ---------------------------------------------------------------------------
    The Foreign Table acts as a virtual table in the local database. In this
    example `SourceDestinyDamageTypeDefinition` is located locally, but no data
    has been copied over from the remote database. It is retrieved on demand.
    ---------------------------------------------------------------------------

    CREATE FOREIGN TABLE creates a new foreign table in the current database. The table will be
    owned by the user issuing the command.

    If a schema name is given (for example, CREATE FOREIGN TABLE my_schema.my_table ...) then the
    table is created in the specified schema, otherwise it is created in the current schema. The
    name of the foreign table must be distinct from the name of any other foreign table, table,
    sequence, index, view, or materialized view in the same schema.

    CREATE FOREIGN TABLE also automatically creates a data type that represents the composite
    type corresponding to one row of the foreign table. Therefore, foreign tables cannot have
    the same name as any existing data type in the same schema.

    To be able to create a foreign table, you must have USAGE privilege on the foreign server,
    as well as USAGE privilege on all column types used in the table.
*/

-- This table references `destinydamagetypedefinition` on remote database `source_db` world_content

------------------------------------------------------------------------------------------------------------------------
-- Damage Type Definitions
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
------------------------------------------------------------------------------------------------------------------------


DROP FOREIGN TABLE IF EXISTS DAMAGE_TYPE_FT;
DROP USER MAPPING IF EXISTS FOR POSTGRES SERVER SOURCE_DB;
DROP SERVER IF EXISTS SOURCE_DB CASCADE;
DROP EXTENSION IF EXISTS POSTGRES_FDW;
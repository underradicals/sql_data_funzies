import sqlite3
from pathlib import Path
import csv

import psycopg2

cwd = Path.cwd()
data_dir = cwd / "data"

print(f"Creating Directory: {data_dir}")
data_dir.mkdir(exist_ok = True, parents = True)

def get_all_world_content_table_names(conn: sqlite3.Connection):
    sql = """select name from SQLITE_MASTER where type = 'table' and tbl_name != 'DestinyHistoricalStatsDefinition';"""
    c = conn.cursor()
    return c.execute(sql).fetchall()


def flatten(tuple_list: list[tuple[str]]):
    l = []
    [l.append(x[0]) for x in tuple_list]
    return l


def port_sqlite_table_to_csv(conn: sqlite3.Connection,
                             table_name: str):
    filename = data_dir / f"{table_name}.csv"
    if filename.exists():
        return
    c = conn.cursor()
    sql = f"select * from {table_name};"
    c.execute(sql)

    with open(filename, "w", newline = "", encoding = "utf-8") as file:
      csv_writer = csv.writer(file)
      csv_writer.writerow(header_name[0] for header_name in c.description)
      csv_writer.writerows(c.fetchall())
    print(f"Created File: {filename}")

def csv_to_pgsql_table(conn, table_name: str):
    drop_stmt = f"""
    drop table if exists {table_name};
    """

    create_stmt = f"""
    create table {table_name}
    (
        id   bigint not null constraint {table_name}_pk primary key,
        json jsonb    not null
    );

    """
    copy_stmt = f"""copy {table_name} (id, json) from 
    'F:\\D2SqlFun\\data\\{table_name}.csv' with (format csv, header 
    true);"""

    c = conn.cursor()
    c.execute(drop_stmt)
    print(f"Drop table: {table_name}")
    print(f"{drop_stmt}")
    c.execute(create_stmt)
    print(f"Executed Query: {create_stmt}")
    c.execute(copy_stmt)
    print(f"Copy Data: {copy_stmt}")

if __name__ == '__main__':
    sqlite_connection = sqlite3.connect("world_content.db")
    postgres_world_content_connection = psycopg2.connect(
        "dbname=world_content user=postgres password=postgres")

    all_world_content_table_names = get_all_world_content_table_names(sqlite_connection)
    world_content_table_name_list = flatten(all_world_content_table_names)
    [port_sqlite_table_to_csv(sqlite_connection, x) for x in world_content_table_name_list]
    [csv_to_pgsql_table(postgres_world_content_connection,x) for x in world_content_table_name_list]

    sqlite_connection.commit()
    postgres_world_content_connection.commit()
    sqlite_connection.close()
    postgres_world_content_connection.close()

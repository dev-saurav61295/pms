#!/usr/bin/env python3
"""
Generate a report of empty vs non-empty tables in a MySQL database.

Usage:
  pip install pymysql
  python3 table_empty_report.py

Optional environment variables:
  MYSQL_HOST, MYSQL_PORT, MYSQL_USER, MYSQL_PASSWORD, MYSQL_DATABASE
"""

import json
import os
import sys
from datetime import datetime

try:
    import pymysql
except ImportError:
    print("ERROR: pymysql not installed. Run: pip install pymysql")
    sys.exit(1)


def load_dotenv(dotenv_path=".env"):
    """Load simple KEY=VALUE pairs from .env into process env (if not already set)."""
    if not os.path.exists(dotenv_path):
        return

    with open(dotenv_path, "r", encoding="utf-8") as f:
        for raw_line in f:
            line = raw_line.strip()
            if not line or line.startswith("#"):
                continue
            if line.startswith("export "):
                line = line[7:].strip()
            if "=" not in line:
                continue

            key, value = line.split("=", 1)
            key = key.strip()
            value = value.strip().strip('"').strip("'")
            if key:
                os.environ.setdefault(key, value)


load_dotenv()


DB_CONFIG = {
    "host": os.getenv("MYSQL_HOST", "43.204.209.116"),
    "port": int(os.getenv("MYSQL_PORT", "3306")),
    "user": os.getenv("MYSQL_USER", "engagedb_ro_usr"),
    "password": os.getenv("MYSQL_PASSWORD", ""),
    "database": os.getenv("MYSQL_DATABASE", "engagedb"),
    "charset": "utf8mb4",
    "connect_timeout": 10,
    "read_timeout": 30,
}


def quote_ident(name: str) -> str:
    """Safely quote MySQL identifiers like table names."""
    return "`" + name.replace("`", "``") + "`"


def get_tables(cursor):
    cursor.execute(
        """
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = %s
          AND table_type = 'BASE TABLE'
        ORDER BY table_name
        """,
        (DB_CONFIG["database"],),
    )
    return [row[0] for row in cursor.fetchall()]


def is_table_empty(cursor, table_name: str) -> bool:
    sql = f"SELECT 1 FROM {quote_ident(table_name)} LIMIT 1"
    cursor.execute(sql)
    return cursor.fetchone() is None


def main():
    if not DB_CONFIG["password"]:
        print("ERROR: MYSQL_PASSWORD is empty.")
        print("Set it and rerun, e.g.: export MYSQL_PASSWORD='your_password'")
        sys.exit(1)

    print(
        f"Connecting to {DB_CONFIG['host']}:{DB_CONFIG['port']}/{DB_CONFIG['database']}..."
    )

    try:
        conn = pymysql.connect(**DB_CONFIG)
    except Exception as e:
        print(f"CONNECTION FAILED: {e}")
        sys.exit(1)

    try:
        cursor = conn.cursor()
        tables = get_tables(cursor)

        if not tables:
            print("No base tables found in this database.")
            sys.exit(0)

        empty_tables = []
        non_empty_tables = []
        errors = []

        for table in tables:
            try:
                if is_table_empty(cursor, table):
                    empty_tables.append(table)
                else:
                    non_empty_tables.append(table)
            except Exception as e:
                errors.append({"table": table, "error": str(e)})

        report = {
            "generated_at": datetime.now().isoformat(),
            "database": DB_CONFIG["database"],
            "summary": {
                "total_tables": len(tables),
                "empty_tables": len(empty_tables),
                "non_empty_tables": len(non_empty_tables),
                "errors": len(errors),
            },
            "empty_table_names": empty_tables,
            "non_empty_table_names": non_empty_tables,
            "table_errors": errors,
        }

        output_file = "empty_tables_report.json"
        with open(output_file, "w", encoding="utf-8") as f:
            json.dump(report, f, indent=2)

        print("\nReport generated successfully.")
        print(f"Total tables:      {report['summary']['total_tables']}")
        print(f"Empty tables:      {report['summary']['empty_tables']}")
        print(f"Non-empty tables:  {report['summary']['non_empty_tables']}")
        print(f"Errors:            {report['summary']['errors']}")
        print(f"Output file:       {output_file}")

        if empty_tables:
            print("\nEmpty tables:")
            for name in empty_tables:
                print(f"- {name}")

        if errors:
            print("\nTables with errors:")
            for item in errors:
                print(f"- {item['table']}: {item['error']}")

    finally:
        conn.close()


if __name__ == "__main__":
    main()

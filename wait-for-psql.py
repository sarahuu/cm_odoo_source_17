#!/usr/bin/env python3
import psycopg2
import time
import os
import sys

host = os.environ.get("DB_HOST", "db")
port = int(os.environ.get("DB_PORT", 5432))
user = os.environ.get("DB_USER", "odoo")
password = os.environ.get("DB_PASSWORD", "odoo")

while True:
    try:
        conn = psycopg2.connect(host=host, port=port, user=user, password=password)
        conn.close()
        break
    except psycopg2.OperationalError:
        print("Waiting for PostgreSQL...")
        time.sleep(1)

print("PostgreSQL is up and running!")
sys.exit(0)

#!/bin/bash

mkdir -p /var/lib/postgresql/12/evr_hour
mkdir -p /var/lib/postgresql/12/evr_hour/db
mkdir -p /var/lib/postgresql/12/evr_hour/wal

echo "0 */1 * * * pg_basebackup -p 5432 -U postgres -D /var/lib/postgresql/12/evr_hour/db --waldir=/var/lib/postgresql/12/evr_hour/wal" | tee /var/spool/cron/crontabs/postgres

#!/bin/bash

mkdir -p /var/lib/postgresql/12/main

echo "*/5  * * * * /usr/local/bin/wal-g backup-push /var/lib/postgresql/12/main >> /var/log/postgresql/walg_backup.log 2>&1" | tee /var/spool/cron/crontabs/postgres

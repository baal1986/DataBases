#!/bin/bash


service pgbouncer stop
monit stop pgsql12
service monit stop
service postgresql stop
rm -rf /var/lib/postgresql/12/main
su - postgres -c '/usr/local/bin/wal-g backup-fetch /var/lib/postgresql/12/main LATEST'
su - postgres -c 'touch /var/lib/postgresql/12/main/recovery.signal'
service postgresql start



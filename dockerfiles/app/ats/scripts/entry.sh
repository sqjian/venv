#! /bin/bash
set -e
chown -R nobody /opt/ats/var
exec gosu root "$@"
#!/bin/sh
# abort script in case of failure
set -e

lighttpd -f /etc/lighttpd/lighttpd.conf

# keep the container running
tail -f /var/log/lighttpd/error.log

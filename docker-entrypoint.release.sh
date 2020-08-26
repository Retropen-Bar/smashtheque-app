#!/bin/bash
set -euo pipefail

rm -rf tmp/pids

# parse DATABASE_URL
proto="$(echo $DATABASE_URL | grep :// | sed -e's,^\(.*://\).*,\1,g')"
url="$(echo ${DATABASE_URL/$proto/})"
user="$(echo $url | grep @ | cut -d@ -f1)"
host_with_port="$(echo ${url/$user@/} | cut -d/ -f1)"
port="$(echo $host_with_port | sed -e 's,^.*:,:,g' -e 's,.*:\([0-9]*\).*,\1,g' -e 's,[^0-9],,g')"
host="$(echo ${host_with_port/:$port/})"

echo "Waiting for pg:" $proto$url
dockerize -wait tcp://$host:$port -timeout 1m

echo "Running migrations..."
bundle exec rails db:migrate

echo "$@"
eval "$@"

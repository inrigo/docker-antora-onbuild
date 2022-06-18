#!/bin/sh
# abort script in case of failure
set -e
# start kroki server and wait for until it can serve requests
nohup java -jar /usr/local/lib/kroki-server.jar > /var/log/kroki &
count=50
while [ $(curl http://localhost:8000 -o /dev/null -w '%{http_code}\n' -s) != "200" ] && [ $count -gt 0 ]; do
  sleep 0.1
  count=$((count-1))
done
if [ $count -eq 0 ]; then
  >&2 echo Kroki not found
  exit 1
fi
echo "Generating documentation"
# build the documentation
antora antora-playbook.yml
# copy generated documents to lighttpd content root
cp -r /antora/build/site/* /var/www/localhost/htdocs/

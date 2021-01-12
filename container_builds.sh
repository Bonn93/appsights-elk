#!/bin/bash
TAG=$1

# Build nginx webdav
docker build -f webdav/Dockerfile -t mbern/nginx-suppdav:$TAG ./webdav

# build Logstash1
docker build -f logstash/Dockerfile -t mbern/logstash-supp:$TAG ./logstash

# build Logstash2
docker build -f logstash-access/Dockerfile -t mbern/logstashaccess-supp:$TAG ./logstash-access

# build elastic
docker build -f elasticsearch/Dockerfile -t mbern/elastic-supp:$TAG ./elasticsearch

# build kibana
docker build -f kibana/Dockerfile -t mbern/kibana-supp:$TAG ./kibana

# build filebeat 
docker build -f filebeat/Dockerfile -t mbern/filebeat-supp:$TAG ./filebeat

# Publish Tags
docker tag mbern/nginx-suppdav:$TAG mbern/nginx-suppdav:$TAG
docker tag mbern/logstash-supp:$TAG mbern/logstash-supp:$TAG
docker tag mbern/logstashaccess-supp:$TAG mbern/logstashaccess-supp:$TAG
docker tag mbern/elastic-supp:$TAG mbern/elastic-supp:$TAG
docker tag mbern/kibana-supp:$TAG mbern/kibana-supp:$TAG
docker tag mbern/filebeat-supp:$TAG mbern/filebeat-supp:$TAG

# Push to registry
#docker push mbern/nginx-suppdav:$TAG
#docker push mbern/logstash-supp:$TAG
#docker push mbern/elastic-supp:$TAG
#docker push mbern/kibana-supp:$TAG


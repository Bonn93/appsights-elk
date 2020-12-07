#!/bin/bash
# Set VARS

# image version, latest should work.. 
VERSION=$1

# JVM sizing -- More data == Bigger JVM. Don't be stupid. 
ELASTIC_JVM_MIN=-Xms2096m
ELASTIC_JVM_MAX=-Xmx2096m
LOGSTASH_JVM_MIN=-Xms2096m
LOGSTASH_JVM_MAX=-Xmx2096m

# Where yo data/logs at? 
JIRA_LOGS=$HOME/jira
N1_LOGS=$HOME/jira_node1
N2_LOGS=$HOME/jira_node2
N3_LOGS=$HOME/jira_node3
BITBUCKET_LOGS=$HOME/bitbucket
CONFLUENCE_LOGS=$HOME/confluence
BAMBOO_LOGS=$HOME/bamboo
CROWD_LOGS=$HOME/crowd

# clear logs
rm -rf $JIRA_LOGS/*
rm -rf $HOME/jira_*/*


# Manage Networks, to make things nice.. 
docker network create elk

# Check Container Status / kill existing
docker stop elasticsearch logstash kibana webdav grafana
docker rm elasticsearch logstash kibana webdav grafana

# Start Elastic:
docker run -d \
-p 9200:9200 \
-p 9300:9300 \
--name=elasticsearch \
--network=elk \
-e ES_JAVA_OPTS="$ELASTIC_JVM_MIN $ELASTIC_JVM_MAX" \
mbern/elastic-supp:$VERSION

# Wait for Elastic before doing anything else
printf "Waiting for HTTP Response from ELASTICSEARCH...\n"
until $(curl --output /dev/null --silent --head --fail http://localhost:9200); do
    printf '.'
    sleep 5s
    done
printf "Awesome!\n"

# Start a webdav for ingest
docker run -d \
--name=webdav \
--network=elk \
-p 8080:80 \
-v $JIRA_LOGS:/var/webdav/jira \
-v $BITBUCKET_LOGS:/var/webdav/bitbucket \
-v $CONFLUENCE_LOGS:/var/webdav/confluence \
-v $BAMBOO_LOGS:/var/webdav/bamboo \
-v $CROWD_LOGS:/var/webdav/crowd \
mbern/nginx-suppdav:$VERSION

# Start Logstash
docker run -d \
-p 5000:5000 \
--name=logstash \
--network=elk \
-e LS_JAVA_OPTS="$LOGSTASH_JVM_MIN $LOGSTASH_JVM_MAX" \
-v $JIRA_LOGS:/usr/share/logstash/logs \
-v $N1_LOGS:/usr/share/logstash/logs/n1 \
-v $N2_LOGS:/usr/share/logstash/logs/n2 \
-v $N3_LOGS:/usr/share/logstash/logs/n3 \
-v $BITBUCKET_LOGS:/usr/share/logstash/pipeline/bitbucket \
-v $CONFLUENCE_LOGS:/usr/share/logstash/pipeline/confluence \
-v $BAMBOO_LOGS:/usr/share/logstash/pipeline/bamboo \
-v $CROWD_LOGS:/usr/share/logstash/pipeline/crowd \
mbern/logstash-supp:$VERSION

# Start Kibana
docker run -d \
-p 5601:5601 \
--name=kibana \
--network=elk \
-e ELASTICSEARCH_HOSTS="http://elasticsearch:9200" \
-e LOGGING_VERBOSE="true" \
mbern/kibana-supp:$VERSION

printf "Waiting for HTTP Response from KIBANA...\n"
until $(curl --output /dev/null --silent --head --fail http://localhost:5601); do
    printf '.'
    sleep 5s
    done
printf "Yay!\n"

# Create default index
#curl --location --request POST 'http://localhost:5601/api/saved_objects/index-pattern' \
#--header 'Content-Type: application/json' \
#--header 'kbn-version: 7.9.3' \
#--data-raw '{
#"attributes": {
#    "title": "logstash-*",
#    "timeFieldName": "@timestamp"
#    }
#}'
#printf "Default index created!"

printf "Kibana is now available at http://localhost:5601\n"
printf "WebDav for log ingest via HTTP is available at http://localhost/<product>\n"
printf "WebDav accepts HTTP PUT with file\n"
printf "Place application logs unzipped in $HOME/<product>\n"

# bad perms
chmod -R 777 $JIRA_LOGS $BITBUCKET_LOGS $CONFLUENCE_LOGS

cd kibana/dashboard
printf "attempting loop\n"
for f in *.json
    do 
    curl -X POST 'http://localhost:5601/api/kibana/dashboards/import' -H 'kbn-version: 7.4.2' -H 'Content-Type: application/json' -d @"$f"
    done


sleep 1s

docker run -d \
-p 3000:3000 \
--name=grafana \
--network=elk \
grafana/grafana



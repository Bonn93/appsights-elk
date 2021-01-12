FROM docker.elastic.co/beats/filebeat:7.9.3
COPY filebeat.yml /usr/share/filebeat/filebeat.yml
USER root
RUN mkdir -p /usr/share/filebeat/data/n1 /usr/share/filebeat/data/n2 /usr/share/filebeat/data/n3
RUN chown root:filebeat /usr/share/filebeat/filebeat.yml
RUN chmod go-w /usr/share/filebeat/filebeat.yml
USER filebeat
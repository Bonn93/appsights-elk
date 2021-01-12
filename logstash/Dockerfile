FROM docker.elastic.co/logstash/logstash:7.10.0

#RUN mkdir -p /plugin-tmp

COPY ./pipeline /usr/share/logstash/config
COPY ./config /usr/share/logstash/config/
COPY ./plugin /plugin

RUN rm -rf /usr/share/logstash/pipeline/logstash.conf \
    && rm -f /usr/share/logstash/config/pipeline.yml \
    && /usr/share/logstash/bin/logstash-plugin install --no-verify /plugin/logstash-filter-healthcheck-1.0.2.gem \
    && /usr/share/logstash/bin/logstash-plugin install --no-verify /plugin/logstash-filter-perf_log_parser-1.0.1.gem
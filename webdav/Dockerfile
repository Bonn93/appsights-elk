FROM nginx

RUN apt-get update && apt-get install -y nginx-extras && rm /etc/nginx/sites-enabled/*

RUN apt-get install htop procps curl -y

RUN mkdir -p /var/webdav/jira /var/webdav/bitbucket /var/webdav/crowd /var/webdav/bamboo /var/webdav/confluence /var/webdav/fecru /var/webdav/hipchat
RUN chown -R www-data /var/webdav/
RUN chmod -R 755 /var/webdav/

COPY default.conf /etc/nginx/conf.d/default.conf
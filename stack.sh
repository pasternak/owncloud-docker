#!/usr/bin/env bash

# If VIRTUAL_HOST is not set, default to 'localhost'
[[ -z ${VIRTUAL_HOST} ]] && VIRTUAL_HOST='localhost'
# Owncloud version, if not set, then use 8.1.3
[[ -z ${VERSION} ]] && VERSION=8.1.3

# Setup default nginx configuration
mv /etc/nginx/conf.d/default{.conf,}

# Replace VirtualHost env var in config file using bash tmpl
envsubst '${VIRTUAL_HOST}' < owncloud.tmpl > /etc/nginx/conf.d/owncloud.conf

# Setup php-fpm to work as user nginx
sed -i -r -e 's/^(user|group)\s+=\s+\w+/\1 = nginx/g' /etc/php-fpm.d/www.conf

# Setup nginx to run in foreground
if [[ `grep daemon /etc/nginx/nginx.conf` ]]; then
	sed -i -r -e 's/^(daemon)\s+\w+;?/\1 off;/g' /etc/nginx/nginx.conf
else
	echo "daemon off;" >> /etc/nginx/nginx.conf
fi

# Install owncloud archive
if [[ ! -f /var/www/owncloud/index.php ]]; then
	wget https://download.owncloud.org/community/owncloud-${VERSION}.tar.bz2 -O /tmp/owncloud.tar.bz2
	tar xjpvf /tmp/owncloud.tar.bz2 -C /var/www/
	mkdir -p /var/www/owncloud/data /var/lib/php/session/
	chown nginx.nginx -R /var/www/owncloud/ /var/lib/php/session/
fi

# RUN apps, move to supervisord?
php-fpm &
nginx

FROM centos:latest
MAINTAINER karol@pasternak.pro

# Install missing repositories
RUN yum -y install epel-release wget
RUN rpm -Uvh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm

# Install packages
RUN yum -y install nginx sqlite php-fpm php-cli php-gd php-mcrypt php-mysql php-pear php-xml bzip2 vim gettext

# Mount certificates
# -v /path/to/certs/:/etc/nginx/cert/
VOLUME ['/etc/nginx/cert/']

# Copy files
COPY stack.sh /stack.sh
COPY owncloud.tmpl /owncloud.tmpl

EXPOSE 80
EXPOSE 443

CMD ["/stack.sh"]

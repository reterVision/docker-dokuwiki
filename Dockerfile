FROM ubuntu:14.04
MAINTAINER Brandon Gao <reterclose@gmail.com>

# Install apache & php
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y  apache2 libapache2-mod-php5

# Change apache settings
RUN a2enmod rewrite

# Doku wiki
ADD http://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz dokuwiki.tgz
RUN tar xvf dokuwiki.tgz -C /var/www
RUN mv /var/www/dokuwiki-* /var/www/dokuwiki
RUN rm dokuwiki.tgz
RUN chown -R www-data:www-data /var/www/dokuwiki
 
# Enable htaccess
RUN awk '/<Directory \/var\/www\/>/,/AllowOverride None/{sub("None", "All",$0)}{print}' /etc/apache2/apache2.conf >apache2.conf.temp && mv apache2.conf.temp /etc/apache2/apache2.conf

# Switch the DocumentRoot to our wiki's root
RUN awk '/DocumentRoot/{sub("/var/www/html", "/var/www/dokuwiki",$0)}{print}' /etc/apache2/sites-available/000-default.conf >000-default.temp && mv 000-default.temp /etc/apache2/sites-available/000-default.conf

# Set environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APACHE_LOCK_DIR /var/run/apache2

# Expose ports
EXPOSE 80

# Run apache
CMD ["/usr/sbin/apache2", "-D", "FOREGROUND"]

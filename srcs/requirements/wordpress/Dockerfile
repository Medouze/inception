FROM debian:12

# Installation PHP-FPM + extensions necessaires pour WordPress
# php8.2-fpm: FastCGI Process Manager (communique avec NGINX)
# php8.2-mysql: Connexion a MariaDB
# php8.2-gd: Manipulation d'images (thumbnails)
# php8.2-curl, xml, zip, etc: Requis par WordPress core et plugins
# mariadb-client: Pour tester la connexion DB avant de lancer WP
RUN apt update && \
    apt install -y \
        php8.2-fpm \
        php8.2-mysql \
        php8.2-curl \
        php8.2-gd \
        php8.2-mbstring \
        php8.2-xml \
        php8.2-xmlrpc \
        php8.2-soap \
        php8.2-intl \
        php8.2-zip \
        wget \
        curl \
        mariadb-client && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# Installation WP-CLI
# Outil en ligne de commande pour gerer WordPress
# Permet d'installer WP et creer des users automatiquement
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O /usr/local/bin/wp && \
    chmod +x /usr/local/bin/wp

# Creation du repertoire WordPress avec les bonnes permissions
# www-data: user sous lequel PHP-FPM s'execute
RUN mkdir -p /var/www/html && \
    chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

# Configuration PHP-FPM
# Listen sur 0.0.0.0:9000 pour accepter les connexions de NGINX
# clear_env=no pour garder les variables d'environnement
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

# Script de setup et demarrage
# 1. Attend que MariaDB soit pret
# 2. Telecharge WordPress via WP-CLI
# 3. Configure wp-config.php
# 4. Installe WordPress et cree les users
# 5. Lance PHP-FPM en foreground
COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

# Port FastCGI (interne au reseau Docker)
EXPOSE 9000

# Point d'entree: lance le script qui demarre PHP-FPM
ENTRYPOINT ["/usr/local/bin/setup.sh"]
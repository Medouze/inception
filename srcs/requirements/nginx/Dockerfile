FROM debian:12

# Installation NGINX et OpenSSL
# nginx: Serveur web et reverse proxy
# openssl: Generation du certificat SSL auto-signe
RUN apt update && \
    apt install -y nginx openssl && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# Creation des repertoires necessaires
# /etc/nginx/ssl: Stockage du certificat et de la cle TLS
# /var/www/html: Document root partage avec WordPress
RUN mkdir -p /etc/nginx/ssl /var/www/html

# Configuration NGINX
# nginx.conf: Config complete (TLS 1.2/1.3, FastCGI vers WordPress)
# entrypoint.sh: Script qui genere le certificat SSL puis demarre NGINX
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh

# Permissions
# www-data: user qui execute NGINX
RUN chmod +x /usr/local/bin/entrypoint.sh && \
    chmod 755 /var/www/html && \
    chown -R www-data:www-data /var/www/html

# Port HTTPS uniquement (subject interdit HTTP)
EXPOSE 443

# Point d'entree
# 1. Genere le certificat SSL si absent
# 2. Demarre NGINX en foreground
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]



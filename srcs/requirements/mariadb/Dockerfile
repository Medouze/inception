FROM debian:12

# Installation MariaDB et nettoyage
# rm -rf /var/lib/mysql/*: Force une init propre au premier demarrage
RUN apt update && \
      apt-get install mariadb-server -y  && \
      apt clean && \
      rm -rf /var/lib/apt/lists/* && \
      rm -rf /var/lib/mysql/*

# Configuration serveur MariaDB
# bind_address=*: Ecoute sur toutes les interfaces (accepte les connexions Docker)
# port=3306: Port MySQL standard
COPY conf/50-server.cnf	/etc/mysql/mariadb.conf.d/.

# Script de setup et demarrage
# 1. Initialise la DB (premier demarrage)
# 2. Cree la base WordPress et l'utilisateur
# 3. Lance MariaDB en foreground
COPY ./tools/run.sh   /.

CMD ["bash", "/run.sh"]
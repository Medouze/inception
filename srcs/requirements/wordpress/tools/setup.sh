#!/bin/bash
set -e  # Stop le script si une commande echoue

echo "WordPress setup starting..."

# ============================================================================
# ETAPE 1: Attente que MariaDB soit pret
# Probleme: Docker demarre les conteneurs en parallele
# Solution: Boucle jusqu'a ce que MariaDB reponde a une requete SQL
# ============================================================================
echo "Waiting for MariaDB..."
until mariadb -h"${MYSQL_HOST}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" "${MYSQL_DATABASE}" -e "SELECT 1;" >/dev/null 2>&1; do
    sleep 2
done
echo "MariaDB ready!"

cd /var/www/html

# ============================================================================
# ETAPE 2: Nettoyage et telechargement de WordPress
# Supprime les fichiers par defaut qui pourraient interferer
# Telecharge WordPress via WP-CLI si pas deja present
# ============================================================================
rm -f index.nginx-debian.html

if [ ! -f "wp-settings.php" ]; then
    echo "Downloading WordPress..."
    wp core download --locale=fr_FR --allow-root
fi

# ============================================================================
# ETAPE 3: Configuration de WordPress (wp-config.php)
# Fichier contenant les parametres de connexion a la base de donnees
# WP-CLI le genere automatiquement a partir des variables d'environnement
# ============================================================================
if [ ! -f "wp-config.php" ]; then
    echo "Creating wp-config.php..."
    wp config create \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost="${MYSQL_HOST}" \
        --allow-root \
        --skip-check
fi

# ============================================================================
# ETAPE 4: Installation de WordPress dans la base de donnees
# Cree les tables, configure le site, cree les utilisateurs
# Idempotent: verifie d'abord si deja installe pour eviter d'ecraser
# ============================================================================
if ! wp core is-installed --allow-root 2>/dev/null; then
    echo "Installing WordPress..."
    wp core install \
        --url="https://${DOMAIN_NAME}" \
        --title="Inception" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --allow-root

    # Creation utilisateur supplementaire (requirement du subject)
    # Role=author: peut creer/editer/publier ses propres posts
    if [ -n "${WP_USER}" ]; then
        wp user create \
            "${WP_USER}" \
            "${WP_USER_EMAIL}" \
            --user_pass="${WP_USER_PASSWORD}" \
            --role=author \
            --allow-root
    fi
fi

# ============================================================================
# ETAPE 5: Permissions finales
# www-data: user qui execute PHP-FPM
# 755: owner peut ecrire, autres peuvent lire/executer
# ============================================================================
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# ============================================================================
# ETAPE 6: Demarrage de PHP-FPM
# -F: foreground mode (requis pour Docker)
# exec: remplace le shell par PHP-FPM (devient PID 1)
# ============================================================================
mkdir -p /run/php
echo "Starting PHP-FPM..."
exec /usr/sbin/php-fpm8.2 -F

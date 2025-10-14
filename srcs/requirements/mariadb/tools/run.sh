#!/bin/bash

# ============================================================================
# ETAPE 1: Initialisation de la base de donnees (premier demarrage)
# Cree la structure de base MariaDB si elle n'existe pas
# mysql_install_db cree les tables systeme (mysql.user, mysql.db, etc)
# ============================================================================
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "First run - Initializing MariaDB database..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# ============================================================================
# ETAPE 2: Demarrage temporaire de MariaDB
# Demarre le serveur en arriere-plan pour pouvoir executer des commandes SQL
# ============================================================================
service mariadb start

# Attente que MariaDB soit pret a accepter des connexions
until mysqladmin ping >/dev/null 2>&1; do
    echo "Waiting for MariaDB to start..."
    sleep 1
done

# ============================================================================
# ETAPE 3: Configuration de la base et des utilisateurs
# Idempotent: utilise un fichier marqueur pour ne configurer qu'une fois
# - Cree la base de donnees WordPress
# - Cree un user non-root pour WordPress (plus secure)
# - '@%': permet la connexion depuis n'importe quel host (reseau Docker)
# - Change le mot de passe root
# ============================================================================
if [ ! -f "/var/lib/mysql/.setup_done" ]; then
    echo "Creating database and users..."

    mysql <<EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

    touch /var/lib/mysql/.setup_done
    echo "Setup complete!"
fi

# ============================================================================
# ETAPE 4: Redemarrage propre
# Arrete le serveur temporaire pour le relancer en mode production
# mysqld_safe relancera automatiquement MariaDB s'il crash
# ============================================================================
echo "Shutting down MariaDB..."
pkill mariadbd

while pgrep mariadbd > /dev/null; do
    echo "Waiting for MariaDB to shut down..."
    sleep 1
done
echo "MariaDB stopped successfully"

# ============================================================================
# ETAPE 5: Demarrage final en foreground
# exec: remplace le shell par mysqld_safe (devient PID 1)
# mysqld_safe: wrapper qui supervise mariadbd
# ============================================================================
exec mysqld_safe


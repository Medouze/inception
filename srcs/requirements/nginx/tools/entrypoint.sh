#!/bin/sh
set -e  # Stop le script si une commande echoue

# ============================================================================
# Generation du certificat SSL auto-signe
# Idempotent: genere uniquement si le certificat n'existe pas deja
# -x509: Format standard pour les certificats
# -nodes: Pas de chiffrement de la cle privee (pas de passphrase)
# -days 365: Validite 1 an
# -newkey rsa:2048: Cle RSA de 2048 bits (standard securise)
# -subj: Informations du certificat (CN doit correspondre au domaine)
# ============================================================================
if [ ! -f /etc/nginx/ssl/inception.crt ]; then
    echo "Generating SSL certificate for ${DOMAIN_NAME}..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -out /etc/nginx/ssl/inception.crt \
        -keyout /etc/nginx/ssl/inception.key \
        -subj "/C=BE/ST=BRU/L=Bruxelles/O=42/OU=student/CN=${DOMAIN_NAME}"
    echo "SSL certificate generated successfully"
fi

# ============================================================================
# Demarrage de NGINX en foreground
# -g "daemon off;": Force le mode foreground (requis pour Docker)
# exec: Remplace le shell par NGINX (devient PID 1)
# ============================================================================
echo "Starting NGINX..."
exec nginx -g "daemon off;"

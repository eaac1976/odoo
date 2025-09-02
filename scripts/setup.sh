#!/bin/bash
# This script creates the entire directory structure and configuration files
# needed to run an Odoo 18 environment with Docker and a self-signed SSL certificate.

# --- Welcome Message ---
echo "🚀 Creating the production environment for Odoo 18 with Docker..."
echo "--------------------------------------------------------"

# --- 1. Create directory structure ---
echo "-> Creating directories: config, addons, nginx/certs..."
mkdir -p config
mkdir -p addons
mkdir -p nginx/certs
echo "✅ Directories created."
echo ""

# --- 2. Generate self-signed SSL certificate ---
echo "-> Generating self-signed SSL certificate (valid for 365 days)..."
if openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
   -keyout nginx/certs/nginx-selfsigned.key \
   -out nginx/certs/nginx-selfsigned.crt \
   -subj "/C=US/ST=California/L=SanFrancisco/O=MyCompany/OU=IT/CN=localhost"; then
    echo "✅ Certificate and key generated in nginx/certs/."
else
    echo "❌ Error generating certificate. Make sure OpenSSL is installed."
    exit 1
fi
echo ""

# --- 3. Create .env file ---
echo "-> Creating .env environment file..."
cat <<EOF > .env
# .env
# --- Credentials for the PostgreSQL database ---
# IMPORTANT: Change 'your-secret-db-password' to a secure, random password.
POSTGRES_PASSWORD=your-secret-db-password
POSTGRES_USER=odoo
POSTGRES_DB=postgres

# --- Credentials for Odoo's DB connection ---
# Must match the PostgreSQL password.
ODOO_DB_HOST=db
ODOO_DB_PORT=5432
ODOO_DB_USER=odoo
ODOO_DB_PASSWORD=your-secret-db-password
EOF
echo "✅ .env file created. Don't forget to change the passwords!"
echo ""

# --- 4. Create Odoo configuration file ---
echo "-> Creating config/odoo.conf configuration file..."
cat <<EOF > config/odoo.conf
[options]
; IMPORTANT: Change 'your-super-secret-master-password' to a very secure password.
admin_passwd = your-super-secret-master-password
db_host = \${ODOO_DB_HOST}
db_port = \${ODOO_DB_PORT}
db_user = \${ODOO_DB_USER}
db_password = \${ODOO_DB_PASSWORD}
db_template = template0
addons_path = /usr/lib/python3/dist-packages/odoo/addons,/mnt/extra-addons

; --- Worker Configuration for Production ---
; (Number of CPUs * 2) + 1. Adjust according to your server.
workers = 4
limit_request = 8192
limit_memory_hard = 2684354560
limit_memory_soft = 2147483648
proxy_mode = True
EOF
echo "✅ config/odoo.conf file created. Don't forget to change the master password!"
echo ""

# --- 5. Create Nginx configuration file ---
echo "-> Creating nginx/nginx-selfsigned.conf configuration file..."
cat <<EOF > nginx/nginx-selfsigned.conf
# nginx/nginx-selfsigned.conf

upstream odoo {
 server odoo:8069;
}
upstream odoochat {
 server odoo:8072;
}

# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name _;
    return 301 https://\$host\$request_uri;
}

# Main server with SSL
server {
    listen 443 ssl;
    server_name _;

    ssl_certificate /etc/nginx/certs/nginx-selfsigned.crt;
    ssl_certificate_key /etc/nginx/certs/nginx-selfsigned.key;

    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:10m;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384';
    ssl_prefer_server_ciphers off;

    proxy_read_timeout 720s;
    proxy_connect_timeout 720s;
    proxy_send_timeout 720s;
    proxy_set_header X-Forwarded-Host \$host;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_set_header X-Real-IP \$remote_addr;

    location /longpolling {
        proxy_pass http://odoochat;
    }

    location / {
        proxy_redirect off;
        proxy_pass http://odoo;
    }

    location ~* /web/static/ {
        proxy_cache_valid 200 60m;
        proxy_buffering on;
        expires 864000;
        proxy_pass http://odoo;
    }

    client_max_body_size 200m;
    gzip on;
    gzip_min_length 1000;
}
EOF
echo "✅ nginx/nginx-selfsigned.conf file created."
echo ""

# --- 6. Create the docker-compose.yaml file ---
echo "-> Creating main docker-compose.yaml file..."
cat <<EOF > docker-compose.yaml
version: '3.8'

services:
  odoo:
    image: odoo:18.0
    depends_on:
      - db
    env_file: .env
    restart: always
    volumes:
      - odoo-data:/var/lib/odoo
      - ./config/odoo.conf:/etc/odoo/odoo.conf
      - ./addons:/mnt/extra-addons
    networks:
      - odoo-network

  db:
    image: postgres:16
    env_file: .env
    restart: always
    volumes:
      - db-data:/var/lib/postgresql/data/
    networks:
      - odoo-network

  nginx:
    image: nginx:latest
    depends_on:
      - odoo
    restart: always
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx-selfsigned.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/certs:/etc/nginx/certs:ro
      - odoo-data:/var/lib/odoo
    networks:
      - odoo-network

volumes:
  odoo-data:
  db-data:

networks:
  odoo-network:
    driver: bridge
EOF
echo "✅ docker-compose.yaml file created."
echo ""

# --- Final Message ---
echo "--------------------------------------------------------"
echo "🎉 The project for Odoo 18 has been created successfully!"
echo ""
echo "Next steps:"
echo "1. (Important) Edit the '.env' and 'config/odoo.conf' files to set secure passwords."
echo "2. Run 'docker compose up -d' to start all services."
echo "3. Access Odoo in your browser via https://your-ip-address"
echo "   (You will have to accept the certificate's security warning)."
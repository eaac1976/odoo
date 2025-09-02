# Odoo 18 Installation with Docker and Nginx (Self-Signed SSL)

This project deploys a production-ready Odoo 18 instance using Docker and Docker Compose. The setup includes a container for Odoo, a PostgreSQL database, and an Nginx reverse proxy to securely handle web traffic over HTTPS using a self-signed certificate.

## 📋 Prerequisites

Before you begin, **please follow the installation and setup instructions for Docker and Git provided in the [development-tools repository](https://github.com/eaac1976/development-tools)**:

- [Docker Installation Guide](https://github.com/eaac1976/development-tools/blob/main/README_docker_setup_guide.md)
- [Git Installation & Configuration Guide](https://github.com/eaac1976/development-tools/blob/main/README_git_setup_guide.md)

> **Tip:** You can reference documents from another repository by using full URLs, as shown above. For example:
> ```
> [Docker Guide](https://github.com/eaac1976/development-tools/blob/main/docker/README.md)
> ```

## 🚀 Quick Installation Guide

Once you have Docker and Git installed and configured (see above), follow these steps to get your Odoo instance up and running:

### Step 1: Get the Installation Script

Clone this project from Git:

```sh
git clone <your-repository-url>
cd <repository-name>
```

### Step 2: Run the Setup Script

This script will generate all the necessary configurations, including directories, `.env` file, `odoo.conf`, `nginx.conf`, `docker-compose.yaml`, and the self-signed SSL certificates.

```sh
./setup.sh
```

### Step 3: (CRITICAL) Change Default Passwords

Edit the `.env` and `config/odoo.conf` files to set secure passwords.

### Step 4: Start the Containers

```sh
docker compose up -d
```

## ✅ Access and Verify

Open your browser and navigate to `https://<your-server-ip-address>` (or `https://localhost` if running locally). Accept the self-signed certificate warning.

## ⚙️ Environment Management

To stop all services:

```sh
docker compose down
```

To restart all services:

```sh
docker compose restart
```

---
**For more details on installing and configuring Docker and Git, always refer to the [development-tools repository](https://github.com/eaac1976/development-tools).**
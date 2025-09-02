# Odoo 18 Installation with Docker and Nginx (Self-Signed SSL)
This project deploys a production-ready Odoo 18 instance using Docker and Docker Compose. The setup includes a container for Odoo, a PostgreSQL database, and an Nginx reverse proxy to securely handle web traffic over HTTPS using a self-signed certificate.

The repository includes an installation script (setup.sh) that automates the creation of the entire directory structure and all necessary configuration files.

📋 Prerequisites
Before you begin, ensure you have the following installed on your Linux server (Ubuntu/Debian is recommended):

Docker: Official Docker installation guide

Docker Compose: Official Docker Compose installation guide (The compose plugin is included with Docker Desktop or installed separately on Linux).

Git: sudo apt install git

OpenSSL: Usually pre-installed on most Linux distributions.

🚀 Quick Installation Guide
Follow these steps to get your Odoo instance up and running in minutes.

Step 1: Get the Installation Script
The easiest way is to clone this project from a Git repository. Alternatively, you can create the setup.sh file manually.

# Option A: If you have the project in Git
git clone <your-repository-url>
cd <repository-name>

# Option B: Create the script manually
# 1. Create a file named setup.sh
touch setup.sh
# 2. Make it executable
chmod +x setup.sh
# 3. Copy the contents of the provided script into the file.

Step 2: Run the Setup Script
This script will generate all the necessary configurations, including directories, .env file, odoo.conf, nginx.conf, docker-compose.yaml, and the self-signed SSL certificates.

./setup.sh

Upon completion, you will see a success message, and your project structure will be ready.

Step 3: (CRITICAL) Change Default Passwords
The script creates default placeholder passwords. You must change them before starting the services.

Database Password:

Open the .env file.

Modify the POSTGRES_PASSWORD and ODOO_DB_PASSWORD lines with a strong, secure password. Both values must be identical.

# .env
- POSTGRES_PASSWORD=your-secret-db-password
+ POSTGRES_PASSWORD=R4nDoM_S#cur3_P@ssw0rd!
...
- ODOO_DB_PASSWORD=your-secret-db-password
+ ODOO_DB_PASSWORD=R4nDoM_S#cur3_P@ssw0rd!

Odoo Master Password:

Open the config/odoo.conf file.

Modify the admin_passwd line with a different and very secure password. This password protects the creation, deletion, and restoration of your databases.

# config/odoo.conf
- admin_passwd = your-super-secret-master-password
+ admin_passwd = An0th3r_V3ry_S#cur3_M@st3r_P@ss!

Step 4: Start the Containers
Once you have saved your new passwords, you can launch the entire environment with a single command:

docker compose up -d

The -d flag runs the containers in the background (detached mode).

✅ Access and Verify
Accessing Odoo
Open your web browser.

Navigate to https://<your-server-ip-address> (or https://localhost if running locally).

Your browser will display a security warning because the SSL certificate is self-signed. This is expected. Click on "Advanced," then "Accept the risk and continue" or "Proceed to site."

You will be greeted by the Odoo database creation screen.

Checking Service Status
To ensure that all three containers (odoo, db, nginx) are running correctly, execute:

docker compose ps

To view real-time logs for troubleshooting:

# View logs from all services
docker compose logs -f

# View logs from the Odoo service only
docker compose logs -f odoo

⚙️ Environment Management
To stop all services:

docker compose down

To restart all services:

docker compose restart

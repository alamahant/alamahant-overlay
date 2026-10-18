#!/bin/bash
# hMailServer initial configuration script
# PostgreSQL and MySQL/MariaDB backends

set -e

INI="/etc/hmailserver/hMailServer.ini"
DBSCRIPTS="/usr/share/hmailserver/DBScripts"

echo "======================================"
echo " hMailServer Initial Configuration"
echo "======================================"
echo
echo "NOTE: Your chosen database server (PostgreSQL or MariaDB/MySQL)"
echo "must already be installed, initialized, and running before you"
echo "continue. If you have just installed it, run:"
echo
echo "    PostgreSQL : sudo emerge --config dev-db/postgresql"
echo "    MariaDB    : sudo emerge --config dev-db/mariadb"
echo
read -p "Press Enter to continue, or Ctrl+C to abort..."
echo

# --- 1. Admin password ---
echo "Step 1: Set the administrator password."
echo "This gates the REST API (web UI)."
echo
sudo hmailserver --set-admin-password
echo

# --- 2. Database type ---
echo "Step 2: Database type."
echo
echo "  1) PostgreSQL"
echo "  2) MySQL / MariaDB"
echo
read -p "Select database type [1]: " DB_CHOICE
DB_CHOICE="${DB_CHOICE:-1}"

if [ "$DB_CHOICE" = "1" ]; then
    DB_TYPE="PostgreSQL"
    DEFAULT_PORT="5432"
    DEFAULT_USER="hmail"
    SCHEMA_FILE="$DBSCRIPTS/CreateTablesPGSQL.sql"
elif [ "$DB_CHOICE" = "2" ]; then
    DB_TYPE="MySQL"
    DEFAULT_PORT="3306"
    DEFAULT_USER="hmail"
    SCHEMA_FILE="$DBSCRIPTS/CreateTablesMySQL.sql"
else
    echo "Invalid choice. Aborting."
    exit 1
fi

# --- 3. Database prompts ---
echo
echo "Step 3: Database settings for $DB_TYPE."
echo

read -p "Database host [localhost]: " DB_HOST
DB_HOST="${DB_HOST:-localhost}"

read -p "Database port [$DEFAULT_PORT]: " DB_PORT
DB_PORT="${DB_PORT:-$DEFAULT_PORT}"

read -p "Database name [hmail]: " DB_NAME
DB_NAME="${DB_NAME:-hmail}"

read -p "Database user [$DEFAULT_USER]: " DB_USER
DB_USER="${DB_USER:-$DEFAULT_USER}"

read -s -p "Set database password: " DB_PASS
echo
if [ -z "$DB_PASS" ]; then
    echo "Error: password cannot be empty."
    exit 1
fi

read -p "REST API port [8089]: " API_PORT
API_PORT="${API_PORT:-8089}"

# --- 3a. MariaDB admin access (only if MariaDB chosen) ---
if [ "$DB_TYPE" = "MySQL" ]; then
    echo
    echo "MariaDB administrative access is needed to create the"
    echo "database and user. This is usually the 'root' account."
    echo
    read -p "MariaDB admin user [root]: " MYSQL_ADMIN_USER
    MYSQL_ADMIN_USER="${MYSQL_ADMIN_USER:-root}"

    read -s -p "MariaDB admin password (leave empty to try socket auth): " MYSQL_ADMIN_PASS
    echo

    if [ -z "$MYSQL_ADMIN_PASS" ]; then
        MYSQL_ADMIN_CMD="mariadb -u $MYSQL_ADMIN_USER"
    else
        MYSQL_ADMIN_CMD="mariadb -u $MYSQL_ADMIN_USER -p$MYSQL_ADMIN_PASS"
    fi

    # Verify the credentials work before proceeding
    if ! $MYSQL_ADMIN_CMD -e "SELECT 1;" >/dev/null 2>&1; then
        echo "Error: cannot connect to MariaDB as '$MYSQL_ADMIN_USER'."
        echo "Check the username/password, or configure socket auth."
        exit 1
    fi
fi

# --- 4. Confirm ---
echo
echo "--------------------------------------"
echo "Summary:"
echo "  Database type : $DB_TYPE"
echo "  Database host : $DB_HOST"
echo "  Database port : $DB_PORT"
echo "  Database name : $DB_NAME"
echo "  Database user : $DB_USER"
echo "  Database pass : (set)"
echo "  REST API port : $API_PORT"
echo "--------------------------------------"
read -p "Proceed? [Y/n]: " CONFIRM
CONFIRM="${CONFIRM:-Y}"
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

# --- 5. Create user and database ---
echo
echo "Checking for existing database user and database..."

if [ "$DB_TYPE" = "PostgreSQL" ]; then
    # PostgreSQL
    USER_EXISTS=$(sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='$DB_USER';")
    if [ "$USER_EXISTS" = "1" ]; then
        echo "Error: database user '$DB_USER' already exists. Aborting."
        exit 1
    fi
    DB_EXISTS=$(sudo -u postgres psql -tAc "SELECT 1 FROM pg_database WHERE datname='$DB_NAME';")
    if [ "$DB_EXISTS" = "1" ]; then
        echo "Error: database '$DB_NAME' already exists. Aborting."
        exit 1
    fi
    echo "Creating database user '$DB_USER'..."
    sudo -u postgres psql -c "CREATE USER \"$DB_USER\" WITH PASSWORD '$DB_PASS';"
    echo "Creating database '$DB_NAME'..."
    sudo -u postgres psql -c "CREATE DATABASE \"$DB_NAME\" OWNER \"$DB_USER\" ENCODING 'UTF8';"
else
    # MySQL / MariaDB
    USER_EXISTS=$($MYSQL_ADMIN_CMD -N -B -e "SELECT 1 FROM mysql.user WHERE user='$DB_USER' AND host='localhost';" 2>/dev/null || echo "")
    if [ "$USER_EXISTS" = "1" ]; then
        echo "Error: database user '$DB_USER' already exists. Aborting."
        exit 1
    fi
    DB_EXISTS=$($MYSQL_ADMIN_CMD -N -B -e "SELECT 1 FROM information_schema.schemata WHERE schema_name='$DB_NAME';" 2>/dev/null || echo "")
    if [ "$DB_EXISTS" = "1" ]; then
        echo "Error: database '$DB_NAME' already exists. Aborting."
        exit 1
    fi
    echo "Creating database '$DB_NAME'..."
    $MYSQL_ADMIN_CMD -e "CREATE DATABASE \`$DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    echo "Creating database user '$DB_USER'..."
    $MYSQL_ADMIN_CMD -e "CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';"
    echo "Granting privileges..."
    $MYSQL_ADMIN_CMD -e "GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'localhost';"
    $MYSQL_ADMIN_CMD -e "FLUSH PRIVILEGES;"
fi

# --- 6. Edit INI ---
echo "Updating $INI..."
sudo sed -i \
    -e "s|^Type=.*|Type=$DB_TYPE|" \
    -e "s|^Server=.*|Server=$DB_HOST|" \
    -e "s|^Port=.*|Port=$DB_PORT|" \
    -e "s|^Database=.*|Database=$DB_NAME|" \
    -e "s|^Username=.*|Username=$DB_USER|" \
    -e "s|^Password=.*|Password=$DB_PASS|" \
    -e "s|^RestApiPort=.*|RestApiPort=$API_PORT|" \
    -e "s|^RestApiBindAddress=.*|RestApiBindAddress=127.0.0.1|" \
    "$INI"

# --- 7. Import schema ---
echo
echo "Checking schema..."

if [ "$DB_TYPE" = "PostgreSQL" ]; then
    VERSION_EXISTS=$(PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc "SELECT 1 FROM information_schema.tables WHERE table_name='hm_dbversion';" 2>/dev/null || echo "")
    if [ "$VERSION_EXISTS" != "1" ]; then
        echo "Importing schema from $SCHEMA_FILE..."
        PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$SCHEMA_FILE" > /dev/null
        echo "Schema imported."
    else
        echo "Schema already present. Skipping import."
    fi
else
    VERSION_EXISTS=$(mariadb -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" -N -B -e "SELECT 1 FROM information_schema.tables WHERE table_schema='$DB_NAME' AND table_name='hm_dbversion';" 2>/dev/null || echo "")
    if [ "$VERSION_EXISTS" != "1" ]; then
        echo "Importing schema from $SCHEMA_FILE..."
        mariadb -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$SCHEMA_FILE"
        echo "Schema imported."
    else
        echo "Schema already present. Skipping import."
    fi
fi

# --- 8. Done ---
echo
echo "======================================"
echo " Configuration complete."
echo "======================================"
echo
echo "Start the service with:"
echo
echo "  OpenRC : sudo rc-service hmailserver start"
echo "  systemd: sudo systemctl start hmailserver"
echo
echo "Then access the web UI at:"
echo "  http://127.0.0.1:$API_PORT"
echo
echo "The API is bound to loopback only. For remote access,"
echo "use an SSH tunnel:"
echo "  ssh -L $API_PORT:127.0.0.1:$API_PORT <user>@<server>"
echo
echo "If the service fails to start via OpenRC or systemd, you can"
echo "invoke the daemon directly:"
echo
echo "  sudo /usr/bin/hmailserver --foreground"
echo
echo "Press Ctrl+C to stop it. This bypasses the service manager and"
echo "is useful for diagnosing configuration errors."
echo
#!/bin/bash

# Database configuration
DB_HOST=${DB_HOST:-localhost}
DB_PORT=${DB_PORT:-5432}
DB_USER=${DB_USER:-$(whoami)}  # Use current user as default for macOS
DB_PASSWORD=${DB_PASSWORD:-}    # No password for local macOS PostgreSQL
DB_NAME=${DB_NAME:-mdcn}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# PostgreSQL client paths for different installations
PG_PATHS=(
    "/Applications/Postgres.app/Contents/Versions/18/bin"
    "/Applications/Postgres.app/Contents/Versions/17/bin"
    "/Applications/Postgres.app/Contents/Versions/16/bin"
    "/opt/homebrew/bin"
    "/usr/local/bin"
    "/usr/bin"
)

# Find PostgreSQL binaries
find_pg_binary() {
    local binary_name=$1
    for path in "${PG_PATHS[@]}"; do
        if [ -f "$path/$binary_name" ]; then
            echo "$path/$binary_name"
            return 0
        fi
    done
    echo ""
    return 1
}

# Get PostgreSQL binary paths
PG_ISREADY=$(find_pg_binary "pg_isready")
PSQL=$(find_pg_binary "psql")
CREATEDB=$(find_pg_binary "createdb")
DROPDB=$(find_pg_binary "dropdb")

# Function to check if PostgreSQL is running
check_postgres() {
    echo -e "${BLUE}🔍 Checking PostgreSQL connection...${NC}"
    
    if [ -z "$PG_ISREADY" ]; then
        echo -e "${RED}❌ pg_isready not found. Please install PostgreSQL client tools.${NC}"
        echo -e "${YELLOW}💡 Install Postgres.app from https://postgresapp.com${NC}"
        return 1
    fi
    
    if [ -z "$DB_PASSWORD" ]; then
        # Try without password first (common for macOS local installations)
        if $PG_ISREADY -h $DB_HOST -p $DB_PORT -U $DB_USER > /dev/null 2>&1; then
            echo -e "${GREEN}✅ PostgreSQL is running (passwordless)${NC}"
            return 0
        fi
    else
        # Try with password
        if PGPASSWORD=$DB_PASSWORD $PG_ISREADY -h $DB_HOST -p $DB_PORT -U $DB_USER > /dev/null 2>&1; then
            echo -e "${GREEN}✅ PostgreSQL is running${NC}"
            return 0
        fi
    fi
    
    echo -e "${RED}❌ PostgreSQL is not running or not accessible${NC}"
    echo -e "${YELLOW}💡 Please ensure PostgreSQL is running and accessible:${NC}"
    echo -e "   - Check Postgres.app is running"
    echo -e "   - Verify user '$DB_USER' has access"
    echo -e "   - Try: $PSQL -h $DB_HOST -p $DB_PORT -U $DB_USER -l"
    return 1
}

# Function to check if database exists
check_database() {
    echo -e "${BLUE}🔍 Checking if database '$DB_NAME' exists...${NC}"
    
    if [ -z "$PSQL" ]; then
        echo -e "${RED}❌ psql not found${NC}"
        return 1
    fi
    
    local db_exists
    if [ -z "$DB_PASSWORD" ]; then
        db_exists=$($PSQL -h $DB_HOST -p $DB_PORT -U $DB_USER -lqt 2>/dev/null | cut -d \| -f 1 | grep -qw $DB_NAME && echo "yes" || echo "no")
    else
        db_exists=$(PGPASSWORD=$DB_PASSWORD $PSQL -h $DB_HOST -p $DB_PORT -U $DB_USER -lqt 2>/dev/null | cut -d \| -f 1 | grep -qw $DB_NAME && echo "yes" || echo "no")
    fi
    
    if [ "$db_exists" = "yes" ]; then
        echo -e "${GREEN}✅ Database '$DB_NAME' exists${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️  Database '$DB_NAME' does not exist${NC}"
        return 1
    fi
}

# Function to create database
create_database() {
    echo -e "${BLUE}🏗️  Creating database '$DB_NAME'...${NC}"
    
    if [ -z "$CREATEDB" ]; then
        echo -e "${RED}❌ createdb not found${NC}"
        return 1
    fi
    
    local result
    if [ -z "$DB_PASSWORD" ]; then
        result=$($CREATEDB -h $DB_HOST -p $DB_PORT -U $DB_USER $DB_NAME 2>&1)
    else
        result=$(PGPASSWORD=$DB_PASSWORD $CREATEDB -h $DB_HOST -p $DB_PORT -U $DB_USER $DB_NAME 2>&1)
    fi
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Database '$DB_NAME' created successfully${NC}"
        return 0
    else
        echo -e "${RED}❌ Failed to create database '$DB_NAME'${NC}"
        echo -e "${RED}Error: $result${NC}"
        return 1
    fi
}

# Function to terminate all connections to database
terminate_connections() {
    echo -e "${YELLOW}⚡ Terminating all connections to database '$DB_NAME'...${NC}"
    
    if [ -z "$PSQL" ]; then
        echo -e "${RED}❌ psql not found${NC}"
        return 1
    fi
    
    local query="SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$DB_NAME' AND pid <> pg_backend_pid();"
    local result
    
    if [ -z "$DB_PASSWORD" ]; then
        result=$($PSQL -h $DB_HOST -p $DB_PORT -U $DB_USER -d postgres -c "$query" 2>&1)
    else
        result=$(PGPASSWORD=$DB_PASSWORD $PSQL -h $DB_HOST -p $DB_PORT -U $DB_USER -d postgres -c "$query" 2>&1)
    fi
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ All connections terminated${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️  Warning: Could not terminate connections (database might not exist)${NC}"
        return 0  # Continue anyway, database might not exist
    fi
}

# Function to drop database (force)
drop_database() {
    echo -e "${BLUE}🗑️  Dropping database '$DB_NAME'...${NC}"
    
    if [ -z "$DROPDB" ]; then
        echo -e "${RED}❌ dropdb not found${NC}"
        return 1
    fi
    
    # First terminate all connections
    terminate_connections
    
    # Small delay to ensure connections are closed
    sleep 1
    
    local result
    if [ -z "$DB_PASSWORD" ]; then
        result=$($DROPDB -h $DB_HOST -p $DB_PORT -U $DB_USER --if-exists $DB_NAME 2>&1)
    else
        result=$(PGPASSWORD=$DB_PASSWORD $DROPDB -h $DB_HOST -p $DB_PORT -U $DB_USER --if-exists $DB_NAME 2>&1)
    fi
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Database '$DB_NAME' dropped successfully${NC}"
        return 0
    else
        echo -e "${RED}❌ Failed to drop database '$DB_NAME'${NC}"
        echo -e "${RED}Error: $result${NC}"
        return 1
    fi
}

# Function to setup database completely
setup_database() {
    local force_recreate=${1:-false}
    
    # Check PostgreSQL connection
    if ! check_postgres; then
        return 1
    fi
    
    # Handle database creation/recreation
    if check_database; then
        if [ "$force_recreate" = true ]; then
            echo -e "${YELLOW}🔄 Force recreating database...${NC}"
            drop_database || return 1
            create_database || return 1
        else
            echo -e "${GREEN}✅ Using existing database${NC}"
        fi
    else
        create_database || return 1
    fi
    
    # Run Prisma migrations
    echo -e "${BLUE}🔧 Running Prisma migrations...${NC}"
    if npx prisma migrate deploy; then
        echo -e "${GREEN}✅ Migrations completed successfully${NC}"
    else
        echo -e "${RED}❌ Migration failed${NC}"
        return 1
    fi
    
    # Generate Prisma client
    echo -e "${BLUE}⚙️  Generating Prisma client...${NC}"
    if npx prisma generate; then
        echo -e "${GREEN}✅ Prisma client generated successfully${NC}"
    else
        echo -e "${RED}❌ Failed to generate Prisma client${NC}"
        return 1
    fi
    
    return 0
}

# Function to seed database
seed_database() {
    echo -e "${BLUE}🌱 Seeding database...${NC}"
    if npx prisma db seed; then
        echo -e "${GREEN}✅ Database seeded successfully${NC}"
        return 0
    else
        echo -e "${RED}❌ Database seeding failed${NC}"
        return 1
    fi
}

# Main function
main() {
    local command=${1:-help}
    
    case $command in
        "check")
            check_postgres && check_database
            ;;
        "create")
            setup_database false
            ;;
        "recreate"|"reset")
            setup_database true
            ;;
        "seed")
            seed_database
            ;;
        "reroll")
            echo -e "${BLUE}🔄 Performing complete database reset and reseed...${NC}"
            setup_database true && seed_database
            ;;
        "help"|*)
            echo -e "${BLUE}Database Setup Script${NC}"
            echo -e ""
            echo -e "Usage: $0 [command]"
            echo -e ""
            echo -e "Commands:"
            echo -e "  check     - Check PostgreSQL and database connectivity"
            echo -e "  create    - Create database if it doesn't exist"
            echo -e "  recreate  - Force drop and recreate database"
            echo -e "  reset     - Alias for recreate"
            echo -e "  seed      - Seed the database with initial data"
            echo -e "  reroll    - Complete reset and reseed (recreate + seed)"
            echo -e "  help      - Show this help message"
            echo -e ""
            echo -e "Environment variables:"
            echo -e "  DB_HOST     - Database host (default: localhost)"
            echo -e "  DB_PORT     - Database port (default: 5432)"
            echo -e "  DB_USER     - Database user (default: postgres)"
            echo -e "  DB_PASSWORD - Database password (default: postgres)"
            echo -e "  DB_NAME     - Database name (default: mdcn)"
            ;;
    esac
}

# Execute main function with all arguments
main "$@"
# Database Setup PowerShell Script

param(
    [string]$Command = "help"
)

# Load environment variables from .env file
function Load-EnvFile {
    param([string]$FilePath = ".env")
    
    if (Test-Path $FilePath) {
        Get-Content $FilePath | ForEach-Object {
            if ($_ -match '^([^#=]+)=(.*)$') {
                $name = $matches[1].Trim()
                $value = $matches[2].Trim().Trim('"')
                [Environment]::SetEnvironmentVariable($name, $value, "Process")
            }
        }
        Write-Host "Environment variables loaded from $FilePath" -ForegroundColor Green
    } else {
        Write-Host "Warning: $FilePath not found" -ForegroundColor Yellow
    }
}

# Parse DATABASE_URL
function Parse-DatabaseUrl {
    param([string]$DatabaseUrl)
    
    if ($DatabaseUrl -match 'postgresql://([^:]+):([^@]+)@([^:]+):(\d+)/([^?]+)') {
        return @{
            User = $matches[1]
            Password = $matches[2]
            Host = $matches[3]
            Port = $matches[4]
            Database = $matches[5]
        }
    }
    return $null
}

# Check PostgreSQL connection
function Test-PostgresConnection {
    param($Config)
    
    Write-Host "Checking PostgreSQL connection..." -ForegroundColor Cyan
    
    try {
        $env:PGPASSWORD = $Config.Password
        $result = & pg_isready -h $Config.Host -p $Config.Port -U $Config.User 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "PostgreSQL is running" -ForegroundColor Green
            return $true
        } else {
            Write-Host "PostgreSQL is not accessible" -ForegroundColor Red
            Write-Host "Error: $result" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "pg_isready not found. Please install PostgreSQL client tools." -ForegroundColor Red
        return $false
    }
}

# Check if database exists
function Test-DatabaseExists {
    param($Config)
    
    Write-Host "Checking if database '$($Config.Database)' exists..." -ForegroundColor Cyan
    
    try {
        $env:PGPASSWORD = $Config.Password
        $result = & psql -h $Config.Host -p $Config.Port -U $Config.User -d postgres -c "SELECT 1 FROM pg_database WHERE datname='$($Config.Database)';" -t 2>&1
        
        if ($LASTEXITCODE -eq 0 -and $result -match "1") {
            Write-Host "Database '$($Config.Database)' exists" -ForegroundColor Green
            return $true
        } else {
            Write-Host "Database '$($Config.Database)' does not exist" -ForegroundColor Yellow
            return $false
        }
    }
    catch {
        Write-Host "Failed to check database existence" -ForegroundColor Red
        return $false
    }
}

# Terminate database connections
function Stop-DatabaseConnections {
    param($Config)
    
    Write-Host "Terminating all connections to database '$($Config.Database)'..." -ForegroundColor Yellow
    
    try {
        $env:PGPASSWORD = $Config.Password
        $query = "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$($Config.Database)' AND pid <> pg_backend_pid();"
        & psql -h $Config.Host -p $Config.Port -U $Config.User -d postgres -c $query 2>&1 | Out-Null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "All connections terminated" -ForegroundColor Green
            return $true
        } else {
            Write-Host "Failed to terminate connections" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "Error terminating connections: $_" -ForegroundColor Red
        return $false
    }
}

# Create database
function New-Database {
    param($Config)
    
    Write-Host "Creating database '$($Config.Database)'..." -ForegroundColor Cyan
    
    try {
        $env:PGPASSWORD = $Config.Password
        & createdb -h $Config.Host -p $Config.Port -U $Config.User $Config.Database 2>&1 | Out-Null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Database '$($Config.Database)' created successfully" -ForegroundColor Green
            return $true
        } else {
            Write-Host "Failed to create database '$($Config.Database)'" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "Error creating database: $_" -ForegroundColor Red
        return $false
    }
}

# Drop database
function Remove-Database {
    param($Config)
    
    Write-Host "Dropping database '$($Config.Database)'..." -ForegroundColor Yellow
    
    try {
        Stop-DatabaseConnections $Config
        Start-Sleep -Seconds 1
        
        $env:PGPASSWORD = $Config.Password
        & dropdb -h $Config.Host -p $Config.Port -U $Config.User $Config.Database 2>&1 | Out-Null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Database '$($Config.Database)' dropped successfully" -ForegroundColor Green
            return $true
        } else {
            Write-Host "Failed to drop database '$($Config.Database)'" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "Error dropping database: $_" -ForegroundColor Red
        return $false
    }
}

# Setup database
function Initialize-Database {
    param($Config, [bool]$ForceRecreate = $false)
    
    if (-not (Test-PostgresConnection $Config)) {
        return $false
    }
    
    $dbExists = Test-DatabaseExists $Config
    
    if ($ForceRecreate -and $dbExists) {
        if (-not (Remove-Database $Config)) {
            return $false
        }
        $dbExists = $false
    }
    
    if (-not $dbExists) {
        if (-not (New-Database $Config)) {
            return $false
        }
    }
    
    Write-Host "Running Prisma migrations..." -ForegroundColor Cyan
    try {
        $output = & .\node_modules\.bin\prisma db push 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Database schema pushed successfully" -ForegroundColor Green
        } else {
            Write-Host "Schema push failed" -ForegroundColor Red
            Write-Host "Error output: $output" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "Error running migrations: $_" -ForegroundColor Red
        return $false
    }
    
    Write-Host "Generating Prisma client..." -ForegroundColor Cyan
    try {
        $output = & .\node_modules\.bin\prisma generate 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Prisma client generated successfully" -ForegroundColor Green
            return $true
        } else {
            Write-Host "Failed to generate Prisma client" -ForegroundColor Red
            Write-Host "Error output: $output" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "Error generating Prisma client: $_" -ForegroundColor Red
        return $false
    }
}

# Seed database
function Invoke-DatabaseSeed {
    Write-Host "Seeding database..." -ForegroundColor Cyan
    
    try {
        $output = & .\node_modules\.bin\tsx prisma/seed.ts 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Database seeded successfully" -ForegroundColor Green
            return $true
        } else {
            Write-Host "Failed to seed database" -ForegroundColor Red
            Write-Host "Error output: $output" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "Error seeding database: $_" -ForegroundColor Red
        return $false
    }
}

# Main function
function Main {
    # Load environment variables
    Load-EnvFile
    
    # Parse database configuration
    $databaseUrl = [Environment]::GetEnvironmentVariable("DATABASE_URL")
    if (-not $databaseUrl) {
        Write-Host "DATABASE_URL not found in environment" -ForegroundColor Red
        exit 1
    }
    
    $config = Parse-DatabaseUrl $databaseUrl
    if (-not $config) {
        Write-Host "Failed to parse DATABASE_URL" -ForegroundColor Red
        exit 1
    }
    
    # Execute command
    switch ($Command.ToLower()) {
        "check" {
            $success = Test-PostgresConnection $config
            if ($success) {
                Test-DatabaseExists $config | Out-Null
            }
            exit $(if ($success) { 0 } else { 1 })
        }
        "create" {
            $success = Initialize-Database $config $false
            exit $(if ($success) { 0 } else { 1 })
        }
        { $_ -in @("recreate", "reset") } {
            $success = Initialize-Database $config $true
            exit $(if ($success) { 0 } else { 1 })
        }
        "seed" {
            $success = Invoke-DatabaseSeed
            exit $(if ($success) { 0 } else { 1 })
        }
        "reroll" {
            Write-Host "Performing complete database reset and reseed..." -ForegroundColor Cyan
            $setupSuccess = Initialize-Database $config $true
            if ($setupSuccess) {
                $seedSuccess = Invoke-DatabaseSeed
                exit $(if ($seedSuccess) { 0 } else { 1 })
            } else {
                exit 1
            }
        }
        default {
            Write-Host "Database Setup Script" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "Usage: .\db-setup.ps1 [command]"
            Write-Host ""
            Write-Host "Commands:"
            Write-Host "  check     - Check PostgreSQL and database connectivity"
            Write-Host "  create    - Create database if it doesn't exist"
            Write-Host "  recreate  - Force drop and recreate database"
            Write-Host "  reset     - Alias for recreate"
            Write-Host "  seed      - Seed the database with initial data"
            Write-Host "  reroll    - Complete reset and reseed (recreate + seed)"
            Write-Host "  help      - Show this help message"
            Write-Host ""
            Write-Host "Environment variables (loaded from .env):"
            Write-Host "  DATABASE_URL - Full PostgreSQL connection string"
            exit 0
        }
    }
}

# Execute main function
Main

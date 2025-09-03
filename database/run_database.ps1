# =============================================
# Warehouse Management Database Setup
# PowerShell Script
# =============================================

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "Warehouse Management Database Setup" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# Function to test SQL Server connection
function Test-SqlConnection {
    param($ServerInstance)
    
    try {
        $connection = New-Object System.Data.SqlClient.SqlConnection
        $connection.ConnectionString = "Server=$ServerInstance;Integrated Security=true;Connection Timeout=5"
        $connection.Open()
        $connection.Close()
        return $true
    }
    catch {
        return $false
    }
}

# Function to find SQL Server instances
function Find-SqlInstances {
    $instances = @()
    
    # Try common instance names
    $commonInstances = @(".", "localhost", "(local)", ".\SQLEXPRESS", ".\MSSQLSERVER")
    
    foreach ($instance in $commonInstances) {
        if (Test-SqlConnection -ServerInstance $instance) {
            $instances += $instance
        }
    }
    
    return $instances
}

# Find available SQL Server instances
Write-Host "Searching for SQL Server instances..." -ForegroundColor Yellow
$sqlInstances = Find-SqlInstances

if ($sqlInstances.Count -eq 0) {
    Write-Host "ERROR: No SQL Server instances found!" -ForegroundColor Red
    Write-Host "Please ensure SQL Server is running and accessible." -ForegroundColor Red
    Write-Host ""
    Write-Host "Common solutions:" -ForegroundColor Yellow
    Write-Host "1. Start SQL Server service" -ForegroundColor White
    Write-Host "2. Enable TCP/IP protocol in SQL Server Configuration Manager" -ForegroundColor White
    Write-Host "3. Check Windows Firewall settings" -ForegroundColor White
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Found SQL Server instances:" -ForegroundColor Green
foreach ($instance in $sqlInstances) {
    Write-Host "  - $instance" -ForegroundColor White
}

# Select SQL Server instance
$selectedInstance = $sqlInstances[0]
if ($sqlInstances.Count -gt 1) {
    Write-Host ""
    Write-Host "Multiple instances found. Using: $selectedInstance" -ForegroundColor Yellow
    Write-Host "To use a different instance, modify the script." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Using SQL Server instance: $selectedInstance" -ForegroundColor Green

# Check if sqlcmd is available
try {
    $sqlcmdVersion = sqlcmd -? 2>&1 | Select-String "SQL Server Command Line Utility"
    if ($sqlcmdVersion) {
        Write-Host "sqlcmd found: $sqlcmdVersion" -ForegroundColor Green
    }
}
catch {
    Write-Host "WARNING: sqlcmd not found. Installing SQL Server Command Line Utilities..." -ForegroundColor Yellow
    Write-Host "Download from: https://docs.microsoft.com/en-us/sql/tools/sqlcmd-utility" -ForegroundColor Yellow
    Write-Host "After installation, run this script again." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Get the script directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$sqlFile = Join-Path $scriptDir "warehouse_management.sql"

if (-not (Test-Path $sqlFile)) {
    Write-Host "ERROR: SQL script file not found: $sqlFile" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "SQL Script file: $sqlFile" -ForegroundColor Green
Write-Host "File size: $((Get-Item $sqlFile).Length) bytes" -ForegroundColor Green

Write-Host ""
Write-Host "Starting database creation..." -ForegroundColor Yellow
Write-Host "This may take a few minutes..." -ForegroundColor Yellow
Write-Host ""

# Run the SQL script
try {
    $startTime = Get-Date
    
    # Build sqlcmd command
    $sqlcmdArgs = @(
        "-S", $selectedInstance,
        "-E",  # Windows Authentication
        "-i", $sqlFile,
        "-o", "database_setup.log"  # Log output to file
    )
    
    Write-Host "Executing: sqlcmd $($sqlcmdArgs -join ' ')" -ForegroundColor Gray
    
    # Run sqlcmd
    $process = Start-Process -FilePath "sqlcmd" -ArgumentList $sqlcmdArgs -Wait -PassThru -NoNewWindow
    
    $endTime = Get-Date
    $duration = $endTime - $startTime
    
    if ($process.ExitCode -eq 0) {
        Write-Host ""
        Write-Host "=============================================" -ForegroundColor Green
        Write-Host "Database created successfully!" -ForegroundColor Green
        Write-Host "=============================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "Database Name: HR_MANAGEMENT" -ForegroundColor White
        Write-Host "Tables Created: 18" -ForegroundColor White
        Write-Host "Sample Data: Inserted" -ForegroundColor White
        Write-Host "Views: 3" -ForegroundColor White
        Write-Host "Stored Procedures: 2" -ForegroundColor White
        Write-Host "Functions: 2" -ForegroundColor White
        Write-Host "Triggers: 1" -ForegroundColor White
        Write-Host "Execution Time: $($duration.TotalSeconds.ToString('F2')) seconds" -ForegroundColor White
        Write-Host ""
        Write-Host "Connection String:" -ForegroundColor Yellow
        Write-Host "Data Source=$selectedInstance;Initial Catalog=HR_MANAGEMENT;Integrated Security=True" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Log file created: database_setup.log" -ForegroundColor Gray
        
        # Test connection to new database
        Write-Host ""
        Write-Host "Testing connection to new database..." -ForegroundColor Yellow
        try {
            $testConnection = New-Object System.Data.SqlClient.SqlConnection
            $testConnection.ConnectionString = "Server=$selectedInstance;Database=HR_MANAGEMENT;Integrated Security=true;Connection Timeout=5"
            $testConnection.Open()
            $testConnection.Close()
            Write-Host "Connection test: SUCCESS" -ForegroundColor Green
        }
        catch {
            Write-Host "Connection test: FAILED - $($_.Exception.Message)" -ForegroundColor Red
        }
        
    }
    else {
        Write-Host ""
        Write-Host "=============================================" -ForegroundColor Red
        Write-Host "Database creation failed!" -ForegroundColor Red
        Write-Host "=============================================" -ForegroundColor Red
        Write-Host ""
        Write-Host "Exit Code: $($process.ExitCode)" -ForegroundColor White
        Write-Host "Check the log file: database_setup.log" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Common issues:" -ForegroundColor Yellow
        Write-Host "1. Insufficient permissions" -ForegroundColor White
        Write-Host "2. Database already exists" -ForegroundColor White
        Write-Host "3. SQL Server version compatibility" -ForegroundColor White
    }
    
}
catch {
    Write-Host ""
    Write-Host "ERROR: Failed to execute sqlcmd" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

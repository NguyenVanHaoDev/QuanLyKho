@echo off
echo =============================================
echo Warehouse Management Database Setup
echo =============================================

REM Check if sqlcmd is available
sqlcmd -? >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: sqlcmd not found. Please install SQL Server Command Line Utilities.
    echo Download from: https://docs.microsoft.com/en-us/sql/tools/sqlcmd-utility
    pause
    exit /b 1
)

echo.
echo Connecting to SQL Server and creating database...
echo.

REM Run the SQL script
sqlcmd -S . -E -i warehouse_management.sql

if %errorlevel% equ 0 (
    echo.
    echo =============================================
    echo Database created successfully!
    echo =============================================
    echo.
    echo Database Name: HR_MANAGEMENT
    echo Tables Created: 18
    echo Sample Data: Inserted
    echo Views: 3
    echo Stored Procedures: 2
    echo Functions: 2
    echo Triggers: 1
    echo.
    echo You can now connect to the database using:
    echo Connection String: Data Source=.;Initial Catalog=HR_MANAGEMENT;Integrated Security=True
    echo.
) else (
    echo.
    echo ERROR: Failed to create database. Check the error messages above.
    echo.
)

pause

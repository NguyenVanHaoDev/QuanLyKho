@echo off
chcp 65001 >nul
title Chạy Database Warehouse Management

echo ============================================
echo    CHẠY DATABASE WAREHOUSE MANAGEMENT
echo ============================================
echo.

echo 1. Kiểm tra SQL Server...
for /f "tokens=*" %%i in ('sc query MSSQL* ^| find "RUNNING"') do (
    echo    ✓ SQL Server đang chạy
    goto :found_sql
)
echo    ✗ SQL Server không chạy!
echo    Hãy khởi động SQL Server trước
pause
exit /b 1

:found_sql
echo.

echo 2. Chạy SQL script...
if exist "warehouse_management.sql" (
    echo    ✓ Tìm thấy file SQL
    echo    Đang chạy script...
    echo.
    
    REM Thử chạy với sqlcmd
    sqlcmd -S . -E -i "warehouse_management.sql"
    if %errorlevel% equ 0 (
        echo.
        echo    ✓ Database đã được tạo thành công!
        echo    Database: QUANLYKHO
        echo    Server: . (Local)
    ) else (
        echo.
        echo    ✗ Lỗi khi chạy SQL script
        echo    Exit code: %errorlevel%
        echo.
        echo    Hãy chạy script trong SQL Server Management Studio:
        echo    1. Mở SSMS
        echo    2. Kết nối đến server local
        echo    3. Mở file warehouse_management.sql
        echo    4. Nhấn F5 để chạy
    )
) else (
    echo    ✗ Không tìm thấy file warehouse_management.sql
    echo    Hãy đảm bảo file này nằm trong thư mục database
)

echo.
echo ============================================
echo    HOÀN THÀNH
echo ============================================
echo.
echo Nhấn phím bất kỳ để thoát...
pause >nul

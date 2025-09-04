# Script chạy database warehouse_management.sql
# Chạy với quyền Administrator

Write-Host "=== CHẠY DATABASE WAREHOUSE MANAGEMENT ===" -ForegroundColor Green
Write-Host ""

# Kiểm tra SQL Server
Write-Host "1. Kiểm tra SQL Server..." -ForegroundColor Yellow
try {
    $sqlServer = Get-Service -Name "MSSQL*" | Where-Object { $_.Status -eq "Running" }
    if ($sqlServer) {
        Write-Host "   ✓ SQL Server đang chạy: $($sqlServer.Name)" -ForegroundColor Green
    }
    else {
        Write-Host "   ✗ SQL Server không chạy!" -ForegroundColor Red
        Write-Host "   Hãy khởi động SQL Server trước" -ForegroundColor Red
        exit 1
    }
}
catch {
    Write-Host "   ✗ Không thể kiểm tra SQL Server" -ForegroundColor Red
    exit 1
}

# Đường dẫn đến file SQL
$sqlFile = Join-Path $PSScriptRoot "warehouse_management.sql"
if (-not (Test-Path $sqlFile)) {
    Write-Host "   ✗ Không tìm thấy file: $sqlFile" -ForegroundColor Red
    exit 1
}

Write-Host "   ✓ Tìm thấy file SQL: $sqlFile" -ForegroundColor Green

# Chạy SQL script
Write-Host ""
Write-Host "2. Chạy SQL script..." -ForegroundColor Yellow

try {
    # Sử dụng sqlcmd để chạy script
    $sqlcmd = "sqlcmd"
    if (Get-Command $sqlcmd -ErrorAction SilentlyContinue) {
        Write-Host "   ✓ Tìm thấy sqlcmd" -ForegroundColor Green
        
        # Chạy script
        $result = & $sqlcmd -S "." -E -i $sqlFile 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   ✓ Database đã được tạo thành công!" -ForegroundColor Green
            Write-Host "   Database: QUANLYKHO" -ForegroundColor Green
            Write-Host "   Server: . (Local)" -ForegroundColor Green
        }
        else {
            Write-Host "   ✗ Lỗi khi chạy SQL script" -ForegroundColor Red
            Write-Host "   Exit code: $LASTEXITCODE" -ForegroundColor Red
            Write-Host "   Output: $result" -ForegroundColor Red
        }
    }
    else {
        Write-Host "   ✗ Không tìm thấy sqlcmd" -ForegroundColor Red
        Write-Host "   Hãy cài đặt SQL Server Command Line Utilities" -ForegroundColor Red
        Write-Host "   Hoặc chạy script trong SQL Server Management Studio" -ForegroundColor Red
    }
}
catch {
    Write-Host "   ✗ Lỗi: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "3. Hướng dẫn sử dụng:" -ForegroundColor Yellow
Write-Host "   - Mở SQL Server Management Studio" -ForegroundColor White
Write-Host "   - Kết nối đến server local" -ForegroundColor White
Write-Host "   - Mở file warehouse_management.sql" -ForegroundColor White
Write-Host "   - Chạy script (F5)" -ForegroundColor White
Write-Host "   - Kiểm tra database QUANLYKHO đã được tạo" -ForegroundColor White

Write-Host ""
Write-Host "=== HOÀN THÀNH ===" -ForegroundColor Green
Write-Host "Nhấn phím bất kỳ để thoát..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

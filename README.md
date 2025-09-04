# HỆ THỐNG QUẢN LÝ KHO HÀNG (QLKHO)

## 📋 Mô tả
Hệ thống quản lý kho hàng được xây dựng bằng C# WinForms với kiến trúc 3-layer:
- **QLKHO.DLL**: Data Access Layer (Repository pattern)
- **QLKHO.BLL**: Business Logic Layer (Service pattern)  
- **QLKHO.GUI**: Presentation Layer (Windows Forms)

## 🚀 Cài đặt và chạy

### Bước 1: Chuẩn bị môi trường
- **SQL Server** (2016 trở lên) hoặc **SQL Server Express**
- **Visual Studio** 2017 trở lên hoặc **.NET Framework 4.7.2**
- **SQL Server Management Studio** (SSMS) - khuyến nghị

### Bước 2: Tạo database
Có 3 cách để tạo database:

#### Cách 1: Chạy script PowerShell (Khuyến nghị)
```powershell
# Mở PowerShell với quyền Administrator
cd database
.\run_database.ps1
```

#### Cách 2: Chạy file batch
```cmd
# Mở Command Prompt với quyền Administrator
cd database
run_database.bat
```

#### Cách 3: Chạy thủ công trong SSMS
1. Mở **SQL Server Management Studio**
2. Kết nối đến server local (.)
3. Mở file `database/warehouse_management.sql`
4. Nhấn **F5** để chạy script

### Bước 3: Build và chạy ứng dụng
1. Mở solution `warehouse_management.sln` trong Visual Studio
2. **Build Solution** (Ctrl+Shift+B)
3. **Start Debugging** (F5) hoặc **Start Without Debugging** (Ctrl+F5)

## 🗄️ Cấu trúc Database

### Bảng chính:
- **SanPham**: Thông tin sản phẩm
- **DanhMucSanPham**: Danh mục sản phẩm
- **NhaCungCap**: Nhà cung cấp
- **KhoHang**: Kho hàng
- **TonKho**: Tồn kho
- **DonDatHang**: Đơn đặt hàng
- **DonHangBan**: Đơn hàng bán
- **PhieuNhapKho**: Phiếu nhập kho
- **PhieuXuatKho**: Phiếu xuất kho

### Dữ liệu mẫu:
- 24 sản phẩm mẫu
- 10 danh mục sản phẩm
- 10 nhà cung cấp
- 5 kho hàng
- Dữ liệu tồn kho và giao dịch

## 🔧 Cấu hình kết nối

### Connection String mặc định:
```xml
Data Source=.;Initial Catalog=QUANLYKHO;Integrated Security=True;MultipleActiveResultSets=True
```

### Thay đổi server database:
Sửa file `QLKHO.DLL/App.config`:
```xml
<add name="QUANLYKHO_Connection" 
     connectionString="Data Source=YOUR_SERVER;Initial Catalog=QUANLYKHO;Integrated Security=True;MultipleActiveResultSets=True"
     providerName="System.Data.SqlClient" />
```

## 📱 Tính năng chính

### Quản lý sản phẩm:
- ✅ Xem danh sách sản phẩm
- ✅ Tìm kiếm sản phẩm
- ✅ Hiển thị thông tin tồn kho
- ✅ Lọc theo danh mục

### Giao diện:
- ✅ Form hiện đại với panel header
- ✅ DataGridView hiển thị dữ liệu
- ✅ Tìm kiếm và làm mới dữ liệu
- ✅ Responsive design

## 🚨 Xử lý lỗi thường gặp

### Lỗi 1: "Login failed for user"
**Nguyên nhân**: SQL Server không chạy hoặc không có quyền
**Giải pháp**: 
- Kiểm tra SQL Server service
- Chạy với quyền Administrator
- Kiểm tra Windows Authentication

### Lỗi 2: "Database QUANLYKHO does not exist"
**Nguyên nhân**: Chưa chạy script tạo database
**Giải pháp**: Chạy `warehouse_management.sql` trong SSMS

### Lỗi 3: "Build failed"
**Nguyên nhân**: Thiếu project references
**Giải pháp**: 
- Clean Solution
- Rebuild Solution
- Kiểm tra project references

## 📁 Cấu trúc thư mục

```
QuanLyKho/
├── QLKHO.DLL/           # Data Access Layer
│   ├── ProductRepository.cs
│   └── App.config
├── QLKHO.BLL/           # Business Logic Layer
│   ├── ProductService.cs
│   └── App.config
├── QLKHO.GUI/           # Presentation Layer
│   ├── FrmSanPham.cs
│   ├── FrmSanPham.Designer.cs
│   └── App.config
├── database/             # Database scripts
│   ├── warehouse_management.sql
│   ├── run_database.ps1
│   └── run_database.bat
└── README.md
```

## 🎯 Tính năng đang phát triển

- [ ] Thêm/sửa/xóa sản phẩm
- [ ] Quản lý nhập/xuất kho
- [ ] Báo cáo tồn kho
- [ ] Quản lý người dùng và phân quyền
- [ ] Export dữ liệu ra Excel/PDF

## 📞 Hỗ trợ

Nếu gặp vấn đề:
1. Kiểm tra SQL Server đã chạy chưa
2. Kiểm tra database QUANLYKHO đã tạo chưa
3. Kiểm tra connection string trong App.config
4. Chạy script database trong SSMS

## 📝 Ghi chú

- Hệ thống sử dụng **Windows Authentication**
- Database được thiết kế theo chuẩn **3NF**
- Có đầy đủ **foreign keys** và **constraints**
- Hỗ trợ **audit trail** và **logging**

---
**Phiên bản**: 1.0.0  
**Ngày cập nhật**: 2024  
**Tác giả**: AI Assistant 

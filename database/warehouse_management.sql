-- =============================================
-- HỆ THỐNG QUẢN LÝ KHO HÀNG
-- Thiết kế chuyên nghiệp với kiến trúc dễ mở rộng
-- Tác giả: AI Assistant
-- Tạo: 2024
-- =============================================

USE master;
GO

-- Xóa database nếu đã tồn tại
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'QUANLYKHO')
BEGIN
    ALTER DATABASE [QUANLYKHO] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [QUANLYKHO];
END
GO

-- Tạo database mới
CREATE DATABASE [QUANLYKHO]
ON PRIMARY (
    NAME = N'QUANLYKHO',
    FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\QUANLYKHO.mdf',
    SIZE = 8192KB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 65536KB
)
LOG ON (
    NAME = N'QUANLYKHO_log',
    FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\QUANLYKHO_log.ldf',
    SIZE = 8192KB,
    MAXSIZE = 2048GB,
    FILEGROWTH = 65536KB
);
GO

USE [QUANLYKHO];
GO

-- =============================================
-- TẠO CÁC BẢNG
-- =============================================

-- 1. Bảng Danh Mục Sản Phẩm
CREATE TABLE [dbo].[DanhMucSanPham] (
    [MaDanhMuc] INT IDENTITY(1,1) NOT NULL,
    [MaDanhMucCode] NVARCHAR(20) NOT NULL,
    [TenDanhMuc] NVARCHAR(100) NOT NULL,
    [MoTa] NVARCHAR(500) NULL,
    [MaDanhMucCha] INT NULL,
    [HoatDong] BIT NOT NULL DEFAULT 1,
    [NgayTao] DATETIME NOT NULL DEFAULT GETDATE(),
    [NguoiTao] NVARCHAR(50) NULL,
    [NgaySua] DATETIME NULL,
    [NguoiSua] NVARCHAR(50) NULL,
    CONSTRAINT [PK_DanhMucSanPham] PRIMARY KEY CLUSTERED ([MaDanhMuc] ASC),
    CONSTRAINT [UQ_DanhMucSanPham_MaDanhMucCode] UNIQUE NONCLUSTERED ([MaDanhMucCode] ASC),
    CONSTRAINT [FK_DanhMucSanPham_DanhMucCha] FOREIGN KEY ([MaDanhMucCha]) REFERENCES [dbo].[DanhMucSanPham] ([MaDanhMuc])
);
GO

-- 2. Bảng Nhà Cung Cấp
CREATE TABLE [dbo].[NhaCungCap] (
    [MaNhaCungCap] INT IDENTITY(1,1) NOT NULL,
    [MaNhaCungCapCode] NVARCHAR(20) NOT NULL,
    [TenNhaCungCap] NVARCHAR(200) NOT NULL,
    [NguoiLienHe] NVARCHAR(100) NULL,
    [SoDienThoai] NVARCHAR(20) NULL,
    [Email] NVARCHAR(100) NULL,
    [DiaChi] NVARCHAR(500) NULL,
    [MaSoThue] NVARCHAR(50) NULL,
    [TaiKhoanNganHang] NVARCHAR(50) NULL,
    [TenNganHang] NVARCHAR(100) NULL,
    [DieuKienThanhToan] NVARCHAR(100) NULL,
    [HanMucTinDung] DECIMAL(18,2) NULL,
    [HoatDong] BIT NOT NULL DEFAULT 1,
    [NgayTao] DATETIME NOT NULL DEFAULT GETDATE(),
    [NguoiTao] NVARCHAR(50) NULL,
    [NgaySua] DATETIME NULL,
    [NguoiSua] NVARCHAR(50) NULL,
    CONSTRAINT [PK_NhaCungCap] PRIMARY KEY CLUSTERED ([MaNhaCungCap] ASC),
    CONSTRAINT [UQ_NhaCungCap_MaCode] UNIQUE NONCLUSTERED ([MaNhaCungCapCode] ASC)
);
GO

-- 3. Bảng Sản Phẩm
CREATE TABLE [dbo].[SanPham] (
    [MaSanPham] INT IDENTITY(1,1) NOT NULL,
    [MaSanPhamCode] NVARCHAR(50) NOT NULL,
    [TenSanPham] NVARCHAR(200) NOT NULL,
    [MaDanhMuc] INT NOT NULL,
    [MaNhaCungCap] INT NULL,
    [MoTa] NVARCHAR(1000) NULL,
    [DonViTinh] NVARCHAR(20) NOT NULL,
    [GiaVon] DECIMAL(18,4) NULL,
    [GiaBan] DECIMAL(18,4) NULL,
    [MucTonKhoToiThieu] INT NULL,
    [MucTonKhoToiDa] INT NULL,
    [DiemDatHangLai] INT NULL,
    [ThoiGianGiaoHang] INT NULL, -- Số ngày
    [HoatDong] BIT NOT NULL DEFAULT 1,
    [NgayTao] DATETIME NOT NULL DEFAULT GETDATE(),
    [NguoiTao] NVARCHAR(50) NULL,
    [NgaySua] DATETIME NULL,
    [NguoiSua] NVARCHAR(50) NULL,
    CONSTRAINT [PK_SanPham] PRIMARY KEY CLUSTERED ([MaSanPham] ASC),
    CONSTRAINT [UQ_SanPham_MaCode] UNIQUE NONCLUSTERED ([MaSanPhamCode] ASC),
    CONSTRAINT [FK_SanPham_DanhMuc] FOREIGN KEY ([MaDanhMuc]) REFERENCES [dbo].[DanhMucSanPham] ([MaDanhMuc]),
    CONSTRAINT [FK_SanPham_NhaCungCap] FOREIGN KEY ([MaNhaCungCap]) REFERENCES [dbo].[NhaCungCap] ([MaNhaCungCap])
);
GO

-- 4. Bảng Kho Hàng
CREATE TABLE [dbo].[KhoHang] (
    [MaKho] INT IDENTITY(1,1) NOT NULL,
    [MaKhoCode] NVARCHAR(20) NOT NULL,
    [TenKho] NVARCHAR(100) NOT NULL,
    [DiaChi] NVARCHAR(500) NULL,
    [MaQuanLy] INT NULL,
    [SoDienThoai] NVARCHAR(20) NULL,
    [Email] NVARCHAR(100) NULL,
    [HoatDong] BIT NOT NULL DEFAULT 1,
    [NgayTao] DATETIME NOT NULL DEFAULT GETDATE(),
    [NguoiTao] NVARCHAR(50) NULL,
    [NgaySua] DATETIME NULL,
    [NguoiSua] NVARCHAR(50) NULL,
    CONSTRAINT [PK_KhoHang] PRIMARY KEY CLUSTERED ([MaKho] ASC),
    CONSTRAINT [UQ_KhoHang_MaKhoCode] UNIQUE NONCLUSTERED ([MaKhoCode] ASC)
);
GO

-- 5. Bảng Vị Trí Trong Kho
CREATE TABLE [dbo].[ViTriTrongKho] (
    [MaViTri] INT IDENTITY(1,1) NOT NULL,
    [MaKho] INT NOT NULL,
    [MaViTriCode] NVARCHAR(20) NOT NULL,
    [TenViTri] NVARCHAR(100) NOT NULL,
    [LoaiViTri] NVARCHAR(50) NULL, -- Kệ, Giá, Thùng, etc.
    [LoiDi] NVARCHAR(10) NULL,
    [Hang] NVARCHAR(10) NULL,
    [Tang] NVARCHAR(10) NULL,
    [ViTri] NVARCHAR(10) NULL,
    [DungLuong] DECIMAL(18,4) NULL,
    [HoatDong] BIT NOT NULL DEFAULT 1,
    [NgayTao] DATETIME NOT NULL DEFAULT GETDATE(),
    [NguoiTao] NVARCHAR(50) NULL,
    [NgaySua] DATETIME NULL,
    [NguoiSua] NVARCHAR(50) NULL,
    CONSTRAINT [PK_ViTriTrongKho] PRIMARY KEY CLUSTERED ([MaViTri] ASC),
    CONSTRAINT [UQ_ViTriTrongKho_MaKho_MaViTriCode] UNIQUE NONCLUSTERED ([MaKho] ASC, [MaViTriCode] ASC),
    CONSTRAINT [FK_ViTriTrongKho_KhoHang] FOREIGN KEY ([MaKho]) REFERENCES [dbo].[KhoHang] ([MaKho])
);
GO

-- 6. Bảng Tồn Kho
CREATE TABLE [dbo].[TonKho] (
    [MaTonKho] INT IDENTITY(1,1) NOT NULL,
    [MaSanPham] INT NOT NULL,
    [MaKho] INT NOT NULL,
    [MaViTri] INT NULL,
    [SoLo] NVARCHAR(50) NULL,
    [SoSerial] NVARCHAR(100) NULL,
    [NgayHetHan] DATE NULL,
    [SoLuongTon] DECIMAL(18,4) NOT NULL DEFAULT 0,
    [SoLuongDatTruoc] DECIMAL(18,4) NOT NULL DEFAULT 0,
    [SoLuongKhaDung] AS ([SoLuongTon] - [SoLuongDatTruoc]),
    [NgayKiemKeCuoi] DATETIME NULL,
    [NgaySuaCuoi] DATETIME NOT NULL DEFAULT GETDATE(),
    [NguoiSuaCuoi] NVARCHAR(50) NULL,
    CONSTRAINT [PK_TonKho] PRIMARY KEY CLUSTERED ([MaTonKho] ASC),
    CONSTRAINT [UQ_TonKho_SanPham_Kho_Lo] UNIQUE NONCLUSTERED ([MaSanPham] ASC, [MaKho] ASC, [SoLo] ASC),
    CONSTRAINT [FK_TonKho_SanPham] FOREIGN KEY ([MaSanPham]) REFERENCES [dbo].[SanPham] ([MaSanPham]),
    CONSTRAINT [FK_TonKho_KhoHang] FOREIGN KEY ([MaKho]) REFERENCES [dbo].[KhoHang] ([MaKho]),
    CONSTRAINT [FK_TonKho_ViTriTrongKho] FOREIGN KEY ([MaViTri]) REFERENCES [dbo].[ViTriTrongKho] ([MaViTri])
);
GO

-- 7. Bảng Đơn Đặt Hàng
CREATE TABLE [dbo].[DonDatHang] (
    [MaDonDatHang] INT IDENTITY(1,1) NOT NULL,
    [SoDonDatHang] NVARCHAR(50) NOT NULL,
    [MaNhaCungCap] INT NOT NULL,
    [NgayDat] DATETIME NOT NULL DEFAULT GETDATE(),
    [NgayGiaoDuKien] DATETIME NULL,
    [NgayGiaoThucTe] DATETIME NULL,
    [TrangThai] NVARCHAR(20) NOT NULL DEFAULT N'Nháp', -- Nháp, Đã gửi, Đã duyệt, Đã nhận, Đã hủy
    [TongTien] DECIMAL(18,4) NULL,
    [GhiChu] NVARCHAR(1000) NULL,
    [NgayTao] DATETIME NOT NULL DEFAULT GETDATE(),
    [NguoiTao] NVARCHAR(50) NULL,
    [NgaySua] DATETIME NULL,
    [NguoiSua] NVARCHAR(50) NULL,
    CONSTRAINT [PK_DonDatHang] PRIMARY KEY CLUSTERED ([MaDonDatHang] ASC),
    CONSTRAINT [UQ_DonDatHang_SoDonDatHang] UNIQUE NONCLUSTERED ([SoDonDatHang] ASC),
    CONSTRAINT [FK_DonDatHang_NhaCungCap] FOREIGN KEY ([MaNhaCungCap]) REFERENCES [dbo].[NhaCungCap] ([MaNhaCungCap])
);
GO

-- 8. Bảng Chi Tiết Đơn Đặt Hàng
CREATE TABLE [dbo].[ChiTietDonDatHang] (
    [MaChiTietDonDatHang] INT IDENTITY(1,1) NOT NULL,
    [MaDonDatHang] INT NOT NULL,
    [MaSanPham] INT NOT NULL,
    [SoLuong] DECIMAL(18,4) NOT NULL,
    [DonGia] DECIMAL(18,4) NOT NULL,
    [ThanhTien] AS ([SoLuong] * [DonGia]),
    [SoLuongDaNhan] DECIMAL(18,4) NOT NULL DEFAULT 0,
    [GhiChu] NVARCHAR(500) NULL,
    CONSTRAINT [PK_ChiTietDonDatHang] PRIMARY KEY CLUSTERED ([MaChiTietDonDatHang] ASC),
    CONSTRAINT [FK_ChiTietDonDatHang_DonDatHang] FOREIGN KEY ([MaDonDatHang]) REFERENCES [dbo].[DonDatHang] ([MaDonDatHang]),
    CONSTRAINT [FK_ChiTietDonDatHang_SanPham] FOREIGN KEY ([MaSanPham]) REFERENCES [dbo].[SanPham] ([MaSanPham])
);
GO

-- 9. Bảng Phiếu Nhập Kho
CREATE TABLE [dbo].[PhieuNhapKho] (
    [MaPhieuNhap] INT IDENTITY(1,1) NOT NULL,
    [SoPhieuNhap] NVARCHAR(50) NOT NULL,
    [MaDonDatHang] INT NULL,
    [MaNhaCungCap] INT NOT NULL,
    [NgayNhap] DATETIME NOT NULL DEFAULT GETDATE(),
    [MaKho] INT NOT NULL,
    [TrangThai] NVARCHAR(20) NOT NULL DEFAULT N'Nháp', -- Nháp, Đã nhận, Đã ghi sổ
    [TongTien] DECIMAL(18,4) NULL,
    [GhiChu] NVARCHAR(1000) NULL,
    [NgayTao] DATETIME NOT NULL DEFAULT GETDATE(),
    [NguoiTao] NVARCHAR(50) NULL,
    [NgaySua] DATETIME NULL,
    [NguoiSua] NVARCHAR(50) NULL,
    CONSTRAINT [PK_PhieuNhapKho] PRIMARY KEY CLUSTERED ([MaPhieuNhap] ASC),
    CONSTRAINT [UQ_PhieuNhapKho_SoPhieuNhap] UNIQUE NONCLUSTERED ([SoPhieuNhap] ASC),
    CONSTRAINT [FK_PhieuNhapKho_DonDatHang] FOREIGN KEY ([MaDonDatHang]) REFERENCES [dbo].[DonDatHang] ([MaDonDatHang]),
    CONSTRAINT [FK_PhieuNhapKho_NhaCungCap] FOREIGN KEY ([MaNhaCungCap]) REFERENCES [dbo].[NhaCungCap] ([MaNhaCungCap]),
    CONSTRAINT [FK_PhieuNhapKho_KhoHang] FOREIGN KEY ([MaKho]) REFERENCES [dbo].[KhoHang] ([MaKho])
);
GO

-- 10. Bảng Chi Tiết Phiếu Nhập Kho
CREATE TABLE [dbo].[ChiTietPhieuNhapKho] (
    [MaChiTietPhieuNhap] INT IDENTITY(1,1) NOT NULL,
    [MaPhieuNhap] INT NOT NULL,
    [MaSanPham] INT NOT NULL,
    [MaViTri] INT NULL,
    [SoLuong] DECIMAL(18,4) NOT NULL,
    [DonGia] DECIMAL(18,4) NOT NULL,
    [ThanhTien] AS ([SoLuong] * [DonGia]),
    [SoLo] NVARCHAR(50) NULL,
    [SoSerial] NVARCHAR(100) NULL,
    [NgayHetHan] DATE NULL,
    [GhiChu] NVARCHAR(500) NULL,
    CONSTRAINT [PK_ChiTietPhieuNhapKho] PRIMARY KEY CLUSTERED ([MaChiTietPhieuNhap] ASC),
    CONSTRAINT [FK_ChiTietPhieuNhapKho_PhieuNhapKho] FOREIGN KEY ([MaPhieuNhap]) REFERENCES [dbo].[PhieuNhapKho] ([MaPhieuNhap]),
    CONSTRAINT [FK_ChiTietPhieuNhapKho_SanPham] FOREIGN KEY ([MaSanPham]) REFERENCES [dbo].[SanPham] ([MaSanPham]),
    CONSTRAINT [FK_ChiTietPhieuNhapKho_ViTriTrongKho] FOREIGN KEY ([MaViTri]) REFERENCES [dbo].[ViTriTrongKho] ([MaViTri])
);
GO

-- 11. Bảng Đơn Hàng Bán
CREATE TABLE [dbo].[DonHangBan] (
    [MaDonHangBan] INT IDENTITY(1,1) NOT NULL,
    [SoDonHangBan] NVARCHAR(50) NOT NULL,
    [MaKhachHang] INT NULL, -- Có thể null cho khách hàng vãng lai
    [NgayDat] DATETIME NOT NULL DEFAULT GETDATE(),
    [NgayYeuCau] DATETIME NULL,
    [NgayGiao] DATETIME NULL,
    [TrangThai] NVARCHAR(20) NOT NULL DEFAULT N'Nháp', -- Nháp, Đã xác nhận, Đã giao, Đã giao hàng, Đã hủy
    [TongTien] DECIMAL(18,4) NULL,
    [GhiChu] NVARCHAR(1000) NULL,
    [NgayTao] DATETIME NOT NULL DEFAULT GETDATE(),
    [NguoiTao] NVARCHAR(50) NULL,
    [NgaySua] DATETIME NULL,
    [NguoiSua] NVARCHAR(50) NULL,
    CONSTRAINT [PK_DonHangBan] PRIMARY KEY CLUSTERED ([MaDonHangBan] ASC),
    CONSTRAINT [UQ_DonHangBan_SoDonHangBan] UNIQUE NONCLUSTERED ([SoDonHangBan] ASC)
);
GO

-- 12. Bảng Chi Tiết Đơn Hàng Bán
CREATE TABLE [dbo].[ChiTietDonHangBan] (
    [MaChiTietDonHangBan] INT IDENTITY(1,1) NOT NULL,
    [MaDonHangBan] INT NOT NULL,
    [MaSanPham] INT NOT NULL,
    [SoLuong] DECIMAL(18,4) NOT NULL,
    [DonGia] DECIMAL(18,4) NOT NULL,
    [ThanhTien] AS ([SoLuong] * [DonGia]),
    [SoLuongDaGiao] DECIMAL(18,4) NOT NULL DEFAULT 0,
    [GhiChu] NVARCHAR(500) NULL,
    CONSTRAINT [PK_ChiTietDonHangBan] PRIMARY KEY CLUSTERED ([MaChiTietDonHangBan] ASC),
    CONSTRAINT [FK_ChiTietDonHangBan_DonHangBan] FOREIGN KEY ([MaDonHangBan]) REFERENCES [dbo].[DonHangBan] ([MaDonHangBan]),
    CONSTRAINT [FK_ChiTietDonHangBan_SanPham] FOREIGN KEY ([MaSanPham]) REFERENCES [dbo].[SanPham] ([MaSanPham])
);
GO

-- 13. Bảng Phiếu Xuất Kho
CREATE TABLE [dbo].[PhieuXuatKho] (
    [MaPhieuXuat] INT IDENTITY(1,1) NOT NULL,
    [SoPhieuXuat] NVARCHAR(50) NOT NULL,
    [MaDonHangBan] INT NULL,
    [MaKhachHang] INT NULL,
    [NgayXuat] DATETIME NOT NULL DEFAULT GETDATE(),
    [MaKho] INT NOT NULL,
    [TrangThai] NVARCHAR(20) NOT NULL DEFAULT N'Nháp', -- Nháp, Đã lấy hàng, Đã giao, Đã giao hàng
    [TongTien] DECIMAL(18,4) NULL,
    [GhiChu] NVARCHAR(1000) NULL,
    [NgayTao] DATETIME NOT NULL DEFAULT GETDATE(),
    [NguoiTao] NVARCHAR(50) NULL,
    [NgaySua] DATETIME NULL,
    [NguoiSua] NVARCHAR(50) NULL,
    CONSTRAINT [PK_PhieuXuatKho] PRIMARY KEY CLUSTERED ([MaPhieuXuat] ASC),
    CONSTRAINT [UQ_PhieuXuatKho_SoPhieuXuat] UNIQUE NONCLUSTERED ([SoPhieuXuat] ASC),
    CONSTRAINT [FK_PhieuXuatKho_DonHangBan] FOREIGN KEY ([MaDonHangBan]) REFERENCES [dbo].[DonHangBan] ([MaDonHangBan]),
    CONSTRAINT [FK_PhieuXuatKho_KhoHang] FOREIGN KEY ([MaKho]) REFERENCES [dbo].[KhoHang] ([MaKho])
);
GO

-- 14. Bảng Chi Tiết Phiếu Xuất Kho
CREATE TABLE [dbo].[ChiTietPhieuXuatKho] (
    [MaChiTietPhieuXuat] INT IDENTITY(1,1) NOT NULL,
    [MaPhieuXuat] INT NOT NULL,
    [MaSanPham] INT NOT NULL,
    [MaViTri] INT NULL,
    [SoLuong] DECIMAL(18,4) NOT NULL,
    [DonGia] DECIMAL(18,4) NOT NULL,
    [ThanhTien] AS ([SoLuong] * [DonGia]),
    [SoLo] NVARCHAR(50) NULL,
    [SoSerial] NVARCHAR(100) NULL,
    [GhiChu] NVARCHAR(500) NULL,
    CONSTRAINT [PK_ChiTietPhieuXuatKho] PRIMARY KEY CLUSTERED ([MaChiTietPhieuXuat] ASC),
    CONSTRAINT [FK_ChiTietPhieuXuatKho_PhieuXuatKho] FOREIGN KEY ([MaPhieuXuat]) REFERENCES [dbo].[PhieuXuatKho] ([MaPhieuXuat]),
    CONSTRAINT [FK_ChiTietPhieuXuatKho_SanPham] FOREIGN KEY ([MaSanPham]) REFERENCES [dbo].[SanPham] ([MaSanPham]),
    CONSTRAINT [FK_ChiTietPhieuXuatKho_ViTriTrongKho] FOREIGN KEY ([MaViTri]) REFERENCES [dbo].[ViTriTrongKho] ([MaViTri])
);
GO

-- 15. Bảng Giao Dịch Tồn Kho
CREATE TABLE [dbo].[GiaoDichTonKho] (
    [MaGiaoDich] INT IDENTITY(1,1) NOT NULL,
    [NgayGiaoDich] DATETIME NOT NULL DEFAULT GETDATE(),
    [LoaiGiaoDich] NVARCHAR(20) NOT NULL, -- Nhập kho, Xuất kho, Điều chỉnh, Chuyển kho, Kiểm kê
    [LoaiThamChieu] NVARCHAR(20) NULL, -- Đơn đặt hàng, Đơn hàng bán, Điều chỉnh, Chuyển kho, Kiểm kê
    [MaThamChieu] INT NULL,
    [MaSanPham] INT NOT NULL,
    [MaKho] INT NOT NULL,
    [MaViTri] INT NULL,
    [SoLuong] DECIMAL(18,4) NOT NULL,
    [ChiPhiDonVi] DECIMAL(18,4) NULL,
    [TongChiPhi] AS ([SoLuong] * [ChiPhiDonVi]),
    [SoLo] NVARCHAR(50) NULL,
    [SoSerial] NVARCHAR(100) NULL,
    [NgayHetHan] DATE NULL,
    [GhiChu] NVARCHAR(500) NULL,
    [NgayTao] DATETIME NOT NULL DEFAULT GETDATE(),
    [NguoiTao] NVARCHAR(50) NULL,
    CONSTRAINT [PK_GiaoDichTonKho] PRIMARY KEY CLUSTERED ([MaGiaoDich] ASC),
    CONSTRAINT [FK_GiaoDichTonKho_SanPham] FOREIGN KEY ([MaSanPham]) REFERENCES [dbo].[SanPham] ([MaSanPham]),
    CONSTRAINT [FK_GiaoDichTonKho_KhoHang] FOREIGN KEY ([MaKho]) REFERENCES [dbo].[KhoHang] ([MaKho]),
    CONSTRAINT [FK_GiaoDichTonKho_ViTriTrongKho] FOREIGN KEY ([MaViTri]) REFERENCES [dbo].[ViTriTrongKho] ([MaViTri])
);
GO

-- 16. Bảng Khách Hàng
CREATE TABLE [dbo].[KhachHang] (
    [MaKhachHang] INT IDENTITY(1,1) NOT NULL,
    [MaKhachHangCode] NVARCHAR(20) NOT NULL,
    [TenKhachHang] NVARCHAR(200) NOT NULL,
    [NguoiLienHe] NVARCHAR(100) NULL,
    [SoDienThoai] NVARCHAR(20) NULL,
    [Email] NVARCHAR(100) NULL,
    [DiaChi] NVARCHAR(500) NULL,
    [MaSoThue] NVARCHAR(50) NULL,
    [HanMucTinDung] DECIMAL(18,2) NULL,
    [DieuKienThanhToan] NVARCHAR(100) NULL,
    [HoatDong] BIT NOT NULL DEFAULT 1,
    [NgayTao] DATETIME NOT NULL DEFAULT GETDATE(),
    [NguoiTao] NVARCHAR(50) NULL,
    [NgaySua] DATETIME NULL,
    [NguoiSua] NVARCHAR(50) NULL,
    CONSTRAINT [PK_KhachHang] PRIMARY KEY CLUSTERED ([MaKhachHang] ASC),
    CONSTRAINT [UQ_KhachHang_MaKhachHangCode] UNIQUE NONCLUSTERED ([MaKhachHangCode] ASC)
);
GO

-- 17. Bảng Người Dùng Hệ Thống
CREATE TABLE [dbo].[NguoiDungHeThong] (
    [MaNguoiDung] INT IDENTITY(1,1) NOT NULL,
    [TenDangNhap] NVARCHAR(50) NOT NULL,
    [MatKhau] NVARCHAR(255) NOT NULL,
    [HoTen] NVARCHAR(100) NOT NULL,
    [Email] NVARCHAR(100) NULL,
    [SoDienThoai] NVARCHAR(20) NULL,
    [HoatDong] BIT NOT NULL DEFAULT 1,
    [NgayDangNhapCuoi] DATETIME NULL,
    [NgayTao] DATETIME NOT NULL DEFAULT GETDATE(),
    [NguoiTao] NVARCHAR(50) NULL,
    [NgaySua] DATETIME NULL,
    [NguoiSua] NVARCHAR(50) NULL,
    CONSTRAINT [PK_NguoiDungHeThong] PRIMARY KEY CLUSTERED ([MaNguoiDung] ASC),
    CONSTRAINT [UQ_NguoiDungHeThong_TenDangNhap] UNIQUE NONCLUSTERED ([TenDangNhap] ASC)
);
GO

-- 18. Bảng Vai Trò Người Dùng
CREATE TABLE [dbo].[VaiTroNguoiDung] (
    [MaVaiTro] INT IDENTITY(1,1) NOT NULL,
    [MaNguoiDung] INT NOT NULL,
    [TenVaiTro] NVARCHAR(50) NOT NULL, -- Quản trị viên, Quản lý, Nhân viên, Người xem
    [HoatDong] BIT NOT NULL DEFAULT 1,
    [NgayTao] DATETIME NOT NULL DEFAULT GETDATE(),
    [NguoiTao] NVARCHAR(50) NULL,
    CONSTRAINT [PK_VaiTroNguoiDung] PRIMARY KEY CLUSTERED ([MaVaiTro] ASC),
    CONSTRAINT [FK_VaiTroNguoiDung_NguoiDungHeThong] FOREIGN KEY ([MaNguoiDung]) REFERENCES [dbo].[NguoiDungHeThong] ([MaNguoiDung])
);
GO

-- =============================================
-- CREATE INDEXES FOR PERFORMANCE
-- =============================================

-- Indexes cho bảng Tồn Kho
CREATE NONCLUSTERED INDEX [IX_TonKho_SanPham_Kho] ON [dbo].[TonKho] ([MaSanPham] ASC, [MaKho] ASC);
CREATE NONCLUSTERED INDEX [IX_TonKho_SoLo] ON [dbo].[TonKho] ([SoLo] ASC);
CREATE NONCLUSTERED INDEX [IX_TonKho_NgayHetHan] ON [dbo].[TonKho] ([NgayHetHan] ASC);

-- Indexes cho bảng Giao Dịch Tồn Kho
CREATE NONCLUSTERED INDEX [IX_GiaoDichTonKho_Ngay_Loai] ON [dbo].[GiaoDichTonKho] ([NgayGiaoDich] ASC, [LoaiGiaoDich] ASC);
CREATE NONCLUSTERED INDEX [IX_GiaoDichTonKho_SanPham_Kho] ON [dbo].[GiaoDichTonKho] ([MaSanPham] ASC, [MaKho] ASC);
CREATE NONCLUSTERED INDEX [IX_GiaoDichTonKho_ThamChieu] ON [dbo].[GiaoDichTonKho] ([LoaiThamChieu] ASC, [MaThamChieu] ASC);

-- Indexes cho bảng Sản Phẩm
CREATE NONCLUSTERED INDEX [IX_SanPham_DanhMuc] ON [dbo].[SanPham] ([MaDanhMuc] ASC);
CREATE NONCLUSTERED INDEX [IX_SanPham_NhaCungCap] ON [dbo].[SanPham] ([MaNhaCungCap] ASC);
CREATE NONCLUSTERED INDEX [IX_SanPham_HoatDong] ON [dbo].[SanPham] ([HoatDong] ASC);

-- Indexes cho bảng Đơn Đặt Hàng
CREATE NONCLUSTERED INDEX [IX_DonDatHang_NhaCungCap_Ngay] ON [dbo].[DonDatHang] ([MaNhaCungCap] ASC, [NgayDat] ASC);
CREATE NONCLUSTERED INDEX [IX_DonDatHang_TrangThai] ON [dbo].[DonDatHang] ([TrangThai] ASC);

-- Indexes cho bảng Đơn Hàng Bán
CREATE NONCLUSTERED INDEX [IX_DonHangBan_KhachHang_Ngay] ON [dbo].[DonHangBan] ([MaKhachHang] ASC, [NgayDat] ASC);
CREATE NONCLUSTERED INDEX [IX_DonHangBan_TrangThai] ON [dbo].[DonHangBan] ([TrangThai] ASC);

-- =============================================
-- INSERT SAMPLE DATA
-- =============================================

-- Thêm dữ liệu mẫu danh mục
INSERT INTO [dbo].[DanhMucSanPham] ([MaDanhMucCode], [TenDanhMuc], [MoTa], [NguoiTao])
VALUES 
    ('DM001', N'Điện tử', N'Thiết bị và linh kiện điện tử', 'Hệ thống'),
    ('DM002', N'Quần áo', N'Trang phục và phụ kiện', 'Hệ thống'),
    ('DM003', N'Sách', N'Sách và ấn phẩm', 'Hệ thống'),
    ('DM004', N'Thực phẩm', N'Thực phẩm và đồ uống', 'Hệ thống'),
    ('DM005', N'Gia dụng', N'Đồ gia dụng và nội thất', 'Hệ thống'),
    ('DM006', N'Thể thao', N'Dụng cụ thể thao và giải trí', 'Hệ thống'),
    ('DM007', N'Làm đẹp', N'Mỹ phẩm và sản phẩm chăm sóc cá nhân', 'Hệ thống'),
    ('DM008', N'Văn phòng phẩm', N'Đồ dùng văn phòng và học tập', 'Hệ thống'),
    ('DM009', N'Đồ chơi', N'Đồ chơi trẻ em và người lớn', 'Hệ thống'),
    ('DM010', N'Y tế', N'Thiết bị y tế và dược phẩm', 'Hệ thống');

-- Thêm dữ liệu mẫu nhà cung cấp
INSERT INTO [dbo].[NhaCungCap] ([MaNhaCungCapCode], [TenNhaCungCap], [NguoiLienHe], [SoDienThoai], [Email], [DiaChi], [NguoiTao])
VALUES 
    ('NCC001', N'Công ty Giải pháp Công nghệ', N'Nguyễn Văn A', '0123456789', 'nguyenvana@tech.com', N'123 Đường Công nghệ, TP.HCM', 'Hệ thống'),
    ('NCC002', N'Công ty Thời trang Thế giới', N'Trần Thị B', '0987654321', 'tranthib@fashion.com', N'456 Đại lộ Thời trang, Hà Nội', 'Hệ thống'),
    ('NCC003', N'Công ty Xuất bản Sách', N'Lê Văn C', '0369852147', 'levanc@book.com', N'789 Đường Sách, Đà Nẵng', 'Hệ thống'),
    ('NCC004', N'Công ty Thực phẩm Sạch', N'Phạm Thị D', '0123456780', 'phamthid@food.com', N'321 Đường Thực phẩm, TP.HCM', 'Hệ thống'),
    ('NCC005', N'Công ty Gia dụng Việt Nam', N'Hoàng Văn E', '0987654320', 'hoangvane@home.com', N'654 Đường Gia dụng, Hà Nội', 'Hệ thống'),
    ('NCC006', N'Công ty Thể thao Quốc tế', N'Vũ Thị F', '0369852140', 'vuthif@sport.com', N'987 Đường Thể thao, Đà Nẵng', 'Hệ thống'),
    ('NCC007', N'Công ty Mỹ phẩm Châu Á', N'Đặng Văn G', '0123456781', 'dangvang@beauty.com', N'147 Đường Làm đẹp, TP.HCM', 'Hệ thống'),
    ('NCC008', N'Công ty Văn phòng phẩm ABC', N'Bùi Thị H', '0987654322', 'buithih@office.com', N'258 Đường Văn phòng, Hà Nội', 'Hệ thống'),
    ('NCC009', N'Công ty Đồ chơi Sáng tạo', N'Lý Văn I', '0369852141', 'lyvani@toy.com', N'369 Đường Đồ chơi, Đà Nẵng', 'Hệ thống'),
    ('NCC010', N'Công ty Thiết bị Y tế', N'Trịnh Thị K', '0123456782', 'trinhthik@medical.com', N'741 Đường Y tế, TP.HCM', 'Hệ thống');

-- Thêm dữ liệu mẫu sản phẩm
INSERT INTO [dbo].[SanPham] ([MaSanPhamCode], [TenSanPham], [MaDanhMuc], [MaNhaCungCap], [MoTa], [DonViTinh], [GiaVon], [GiaBan], [MucTonKhoToiThieu], [MucTonKhoToiDa], [DiemDatHangLai], [NguoiTao])
VALUES 
    ('SP001', N'Laptop Dell Inspiron', 1, 1, N'Laptop hiệu suất cao với thông số kỹ thuật mới nhất', 'Cái', 20000000, 30000000, 5, 50, 10, 'Hệ thống'),
    ('SP002', N'Điện thoại iPhone 15', 1, 1, N'Điện thoại thông minh mới nhất với tính năng tiên tiến', 'Cái', 10000000, 15000000, 10, 100, 20, 'Hệ thống'),
    ('SP003', N'Áo thun nam', 2, 2, N'Áo thun cotton nhiều màu sắc, chất liệu thoáng mát', 'Cái', 150000, 250000, 50, 500, 100, 'Hệ thống'),
    ('SP004', N'Sách lập trình C#', 3, 3, N'Hướng dẫn hoàn chỉnh về lập trình C# từ cơ bản đến nâng cao', 'Cuốn', 200000, 350000, 20, 200, 40, 'Hệ thống'),
    ('SP005', N'Bàn phím cơ gaming', 1, 1, N'Bàn phím cơ chuyên dụng cho game thủ, đèn LED RGB', 'Cái', 800000, 1200000, 15, 150, 30, 'Hệ thống'),
    ('SP006', N'Chuột không dây', 1, 1, N'Chuột không dây công nghệ Bluetooth 5.0, pin sạc', 'Cái', 300000, 500000, 25, 250, 50, 'Hệ thống'),
    ('SP007', N'Quần jean nam', 2, 2, N'Quần jean nam chất liệu denim cao cấp, nhiều size', 'Cái', 400000, 600000, 30, 300, 60, 'Hệ thống'),
    ('SP008', N'Váy đầm nữ', 2, 2, N'Váy đầm nữ thiết kế thời trang, phù hợp nhiều dịp', 'Cái', 500000, 800000, 20, 200, 40, 'Hệ thống'),
    ('SP009', N'Sách tiếng Anh', 3, 3, N'Sách học tiếng Anh cho người mới bắt đầu', 'Cuốn', 150000, 250000, 35, 350, 70, 'Hệ thống'),
    ('SP010', N'Tạp chí công nghệ', 3, 3, N'Tạp chí cập nhật tin tức công nghệ mới nhất', 'Cuốn', 50000, 80000, 100, 1000, 200, 'Hệ thống'),
    ('SP011', N'Gạo nếp cái hoa vàng', 4, 4, N'Gạo nếp cái hoa vàng thơm ngon, chất lượng cao', 'Kg', 25000, 35000, 200, 2000, 400, 'Hệ thống'),
    ('SP012', N'Thịt heo tươi', 4, 4, N'Thịt heo tươi ngon, đảm bảo vệ sinh an toàn thực phẩm', 'Kg', 120000, 180000, 100, 1000, 200, 'Hệ thống'),
    ('SP013', N'Bàn ăn gỗ', 5, 5, N'Bàn ăn gỗ tự nhiên, thiết kế hiện đại', 'Cái', 3000000, 4500000, 5, 50, 10, 'Hệ thống'),
    ('SP014', N'Ghế sofa', 5, 5, N'Ghế sofa phòng khách, chất liệu cao cấp', 'Bộ', 5000000, 7500000, 3, 30, 6, 'Hệ thống'),
    ('SP015', N'Bóng đá', 6, 6, N'Bóng đá chính hãng, kích thước chuẩn', 'Quả', 200000, 300000, 20, 200, 40, 'Hệ thống'),
    ('SP016', N'Vợt cầu lông', 6, 6, N'Vợt cầu lông chuyên nghiệp, trọng lượng nhẹ', 'Cái', 800000, 1200000, 15, 150, 30, 'Hệ thống'),
    ('SP017', N'Son môi', 7, 7, N'Son môi màu đẹp, không khô môi', 'Cây', 150000, 250000, 50, 500, 100, 'Hệ thống'),
    ('SP018', N'Kem dưỡng ẩm', 7, 7, N'Kem dưỡng ẩm cho da khô, thành phần tự nhiên', 'Hộp', 300000, 450000, 30, 300, 60, 'Hệ thống'),
    ('SP019', N'Bút bi', 8, 8, N'Bút bi mực đen, viết mượt mà', 'Cây', 5000, 8000, 500, 5000, 1000, 'Hệ thống'),
    ('SP020', N'Vở học sinh', 8, 8, N'Vở học sinh 200 trang, giấy trắng mịn', 'Quyển', 15000, 25000, 200, 2000, 400, 'Hệ thống'),
    ('SP021', N'Xe đồ chơi điều khiển', 9, 9, N'Xe đồ chơi điều khiển từ xa, pin sạc', 'Cái', 500000, 800000, 10, 100, 20, 'Hệ thống'),
    ('SP022', N'Búp bê Barbie', 9, 9, N'Búp bê Barbie cao cấp, nhiều phụ kiện', 'Cái', 300000, 500000, 15, 150, 30, 'Hệ thống'),
    ('SP023', N'Máy đo huyết áp', 10, 10, N'Máy đo huyết áp điện tử, độ chính xác cao', 'Cái', 800000, 1200000, 8, 80, 16, 'Hệ thống'),
    ('SP024', N'Thuốc cảm cúm', 10, 10, N'Thuốc cảm cúm hiệu quả, an toàn cho sức khỏe', 'Hộp', 50000, 80000, 100, 1000, 200, 'Hệ thống');

-- Thêm dữ liệu mẫu kho hàng
INSERT INTO [dbo].[KhoHang] ([MaKhoCode], [TenKho], [DiaChi], [SoDienThoai], [Email], [NguoiTao])
VALUES 
    ('KH001', N'Kho chính TP.HCM', N'100 Đường Kho hàng, Khu Công nghiệp Tân Bình, TP.HCM', '0123456789', 'khochinh@quanlykho.com', 'Hệ thống'),
    ('KH002', N'Kho phụ TP.HCM', N'200 Đường Lưu trữ, Khu Thương mại Quận 1, TP.HCM', '0987654321', 'khophu@quanlykho.com', 'Hệ thống'),
    ('KH003', N'Kho Hà Nội', N'300 Đường Kho hàng, Khu Công nghiệp Long Biên, Hà Nội', '0369852147', 'khohn@quanlykho.com', 'Hệ thống'),
    ('KH004', N'Kho Đà Nẵng', N'400 Đường Lưu trữ, Khu Thương mại Hải Châu, Đà Nẵng', '0123456780', 'khodn@quanlykho.com', 'Hệ thống'),
    ('KH005', N'Kho Cần Thơ', N'500 Đường Kho hàng, Khu Công nghiệp Cái Răng, Cần Thơ', '0987654320', 'khoct@quanlykho.com', 'Hệ thống');

-- Thêm dữ liệu mẫu vị trí trong kho
INSERT INTO [dbo].[ViTriTrongKho] ([MaKho], [MaViTriCode], [TenViTri], [LoaiViTri], [LoiDi], [Hang], [Tang], [ViTri], [NguoiTao])
VALUES 
    -- Kho chính TP.HCM
    (1, 'A1-H1-T1', N'Lối đi 1, Hàng 1, Tầng 1', N'Kệ', 'A1', 'H1', 'T1', 'V1', 'Hệ thống'),
    (1, 'A1-H1-T2', N'Lối đi 1, Hàng 1, Tầng 2', N'Kệ', 'A1', 'H1', 'T2', 'V1', 'Hệ thống'),
    (1, 'A2-H1-T1', N'Lối đi 2, Hàng 1, Tầng 1', N'Giá', 'A2', 'H1', 'T1', 'V1', 'Hệ thống'),
    (1, 'A2-H2-T1', N'Lối đi 2, Hàng 2, Tầng 1', N'Giá', 'A2', 'H2', 'T1', 'V1', 'Hệ thống'),
    (1, 'A3-H1-T1', N'Lối đi 3, Hàng 1, Tầng 1', N'Thùng', 'A3', 'H1', 'T1', 'V1', 'Hệ thống'),
    
    -- Kho phụ TP.HCM
    (2, 'A1-H1-T1', N'Lối đi 1, Hàng 1, Tầng 1', N'Kệ', 'A1', 'H1', 'T1', 'V1', 'Hệ thống'),
    (2, 'A1-H2-T1', N'Lối đi 1, Hàng 2, Tầng 1', N'Kệ', 'A1', 'H2', 'T1', 'V1', 'Hệ thống'),
    
    -- Kho Hà Nội
    (3, 'A1-H1-T1', N'Lối đi 1, Hàng 1, Tầng 1', N'Kệ', 'A1', 'H1', 'T1', 'V1', 'Hệ thống'),
    (3, 'A1-H1-T2', N'Lối đi 1, Hàng 1, Tầng 2', N'Kệ', 'A1', 'H1', 'T2', 'V1', 'Hệ thống'),
    
    -- Kho Đà Nẵng
    (4, 'A1-H1-T1', N'Lối đi 1, Hàng 1, Tầng 1', N'Kệ', 'A1', 'H1', 'T1', 'V1', 'Hệ thống'),
    
    -- Kho Cần Thơ
    (5, 'A1-H1-T1', N'Lối đi 1, Hàng 1, Tầng 1', N'Kệ', 'A1', 'H1', 'T1', 'V1', 'Hệ thống');

-- Thêm dữ liệu mẫu người dùng hệ thống
INSERT INTO [dbo].[NguoiDungHeThong] ([TenDangNhap], [MatKhau], [HoTen], [Email], [NguoiTao])
VALUES 
    ('admin', 'admin123', N'Quản trị viên hệ thống', 'admin@quanlykho.com', 'Hệ thống'),
    ('manager', 'manager123', N'Quản lý kho', 'manager@quanlykho.com', 'Hệ thống'),
    ('operator', 'operator123', N'Nhân viên kho', 'operator@quanlykho.com', 'Hệ thống'),
    ('nguyenvana', 'nvana123', N'Nguyễn Văn A', 'nguyenvana@quanlykho.com', 'Hệ thống'),
    ('tranthib', 'tthib123', N'Trần Thị B', 'tranthib@quanlykho.com', 'Hệ thống'),
    ('levanc', 'lvanc123', N'Lê Văn C', 'levanc@quanlykho.com', 'Hệ thống'),
    ('phamthid', 'pthid123', N'Phạm Thị D', 'phamthid@quanlykho.com', 'Hệ thống'),
    ('hoangvane', 'hvane123', N'Hoàng Văn E', 'hoangvane@quanlykho.com', 'Hệ thống'),
    ('vuthif', 'vthif123', N'Vũ Thị F', 'vuthif@quanlykho.com', 'Hệ thống'),
    ('dangvang', 'dvang123', N'Đặng Văn G', 'dangvang@quanlykho.com', 'Hệ thống');

-- Thêm dữ liệu mẫu vai trò người dùng
INSERT INTO [dbo].[VaiTroNguoiDung] ([MaNguoiDung], [TenVaiTro], [NguoiTao])
VALUES 
    (1, N'Quản trị viên', 'Hệ thống'),
    (2, N'Quản lý', 'Hệ thống'),
    (3, N'Nhân viên', 'Hệ thống'),
    (4, N'Quản lý', 'Hệ thống'),
    (5, N'Quản lý', 'Hệ thống'),
    (6, N'Nhân viên', 'Hệ thống'),
    (7, N'Nhân viên', 'Hệ thống'),
    (8, N'Nhân viên', 'Hệ thống'),
    (9, N'Nhân viên', 'Hệ thống'),
    (10, N'Nhân viên', 'Hệ thống');

-- Thêm dữ liệu mẫu khách hàng
INSERT INTO [dbo].[KhachHang] ([MaKhachHangCode], [TenKhachHang], [NguoiLienHe], [SoDienThoai], [Email], [DiaChi], [MaSoThue], [HanMucTinDung], [DieuKienThanhToan], [NguoiTao])
VALUES 
    ('KH001', N'Công ty TNHH ABC', N'Nguyễn Văn X', '0123456789', 'contact@abc.com', N'123 Đường ABC, Quận 1, TP.HCM', '0123456789', 100000000, N'Thanh toán 30 ngày', 'Hệ thống'),
    ('KH002', N'Cửa hàng Thời trang XYZ', N'Trần Thị Y', '0987654321', 'info@xyz.com', N'456 Đường XYZ, Quận 3, TP.HCM', '0987654321', 50000000, N'Thanh toán ngay', 'Hệ thống'),
    ('KH003', N'Siêu thị Mini Mart', N'Lê Văn Z', '0369852147', 'sales@minimart.com', N'789 Đường Mini, Quận 5, TP.HCM', '0369852147', 200000000, N'Thanh toán 15 ngày', 'Hệ thống'),
    ('KH004', N'Công ty Công nghệ TechPro', N'Phạm Thị W', '0123456780', 'hello@techpro.com', N'321 Đường Tech, Quận 7, TP.HCM', '0123456780', 150000000, N'Thanh toán 30 ngày', 'Hệ thống'),
    ('KH005', N'Cửa hàng Điện máy E-Mart', N'Hoàng Văn V', '0987654320', 'sales@emart.com', N'654 Đường E-Mart, Quận 10, TP.HCM', '0987654320', 300000000, N'Thanh toán 45 ngày', 'Hệ thống'),
    ('KH006', N'Công ty Thực phẩm FoodCorp', N'Vũ Thị U', '0369852140', 'info@foodcorp.com', N'987 Đường Food, Quận 11, TP.HCM', '0369852140', 80000000, N'Thanh toán 30 ngày', 'Hệ thống'),
    ('KH007', N'Cửa hàng Sách BookStore', N'Đặng Văn T', '0123456781', 'contact@bookstore.com', N'147 Đường Book, Quận 2, TP.HCM', '0123456781', 40000000, N'Thanh toán ngay', 'Hệ thống'),
    ('KH008', N'Công ty Gia dụng HomePro', N'Bùi Thị S', '0987654322', 'sales@homepro.com', N'258 Đường Home, Quận 4, TP.HCM', '0987654322', 120000000, N'Thanh toán 30 ngày', 'Hệ thống'),
    ('KH009', N'Cửa hàng Thể thao SportMax', N'Lý Văn R', '0369852141', 'info@sportmax.com', N'369 Đường Sport, Quận 6, TP.HCM', '0369852141', 60000000, N'Thanh toán 15 ngày', 'Hệ thống'),
    ('KH010', N'Công ty Mỹ phẩm BeautyCorp', N'Trịnh Thị Q', '0123456782', 'hello@beautycorp.com', N'741 Đường Beauty, Quận 8, TP.HCM', '0123456782', 90000000, N'Thanh toán 30 ngày', 'Hệ thống');

-- Thêm dữ liệu mẫu đơn đặt hàng
INSERT INTO [dbo].[DonDatHang] ([SoDonDatHang], [MaNhaCungCap], [NgayDat], [NgayGiaoDuKien], [TrangThai], [TongTien], [GhiChu], [NguoiTao])
VALUES 
    ('DDH001', 1, '2024-01-15', '2024-01-25', N'Đã duyệt', 25000000, N'Đơn hàng laptop cho phòng IT', 'nguyenvana'),
    ('DDH002', 2, '2024-01-16', '2024-01-26', N'Đã gửi', 1500000, N'Đơn hàng quần áo cho nhân viên', 'tranthib'),
    ('DDH003', 3, '2024-01-17', '2024-01-27', N'Đã duyệt', 500000, N'Đơn hàng sách cho thư viện', 'levanc'),
    ('DDH004', 4, '2024-01-18', '2024-01-28', N'Nháp', 2000000, N'Đơn hàng thực phẩm cho căng tin', 'phamthid'),
    ('DDH005', 5, '2024-01-19', '2024-01-29', N'Đã gửi', 8000000, N'Đơn hàng đồ gia dụng cho văn phòng', 'hoangvane');

-- Thêm dữ liệu mẫu chi tiết đơn đặt hàng
INSERT INTO [dbo].[ChiTietDonDatHang] ([MaDonDatHang], [MaSanPham], [SoLuong], [DonGia], [GhiChu])
VALUES 
    (1, 1, 1, 25000000, N'Laptop Dell Inspiron'),
    (2, 3, 10, 150000, N'Áo thun nam'),
    (2, 7, 5, 400000, N'Quần jean nam'),
    (3, 4, 2, 200000, N'Sách lập trình C#'),
    (3, 9, 3, 150000, N'Sách tiếng Anh'),
    (4, 11, 50, 25000, N'Gạo nếp cái hoa vàng'),
    (4, 12, 20, 120000, N'Thịt heo tươi'),
    (5, 13, 2, 3000000, N'Bàn ăn gỗ'),
    (5, 14, 1, 5000000, N'Ghế sofa');

-- Thêm dữ liệu mẫu đơn hàng bán
INSERT INTO [dbo].[DonHangBan] ([SoDonHangBan], [MaKhachHang], [NgayDat], [NgayYeuCau], [TrangThai], [TongTien], [GhiChu], [NguoiTao])
VALUES 
    ('DHB001', 1, '2024-01-20', '2024-01-25', N'Đã xác nhận', 30000000, N'Đơn hàng laptop cho công ty', 'nguyenvana'),
    ('DHB002', 2, '2024-01-21', '2024-01-26', N'Đã giao', 800000, N'Đơn hàng quần áo cho cửa hàng', 'tranthib'),
    ('DHB003', 3, '2024-01-22', '2024-01-27', N'Đã xác nhận', 350000, N'Đơn hàng sách cho siêu thị', 'levanc'),
    ('DHB004', 4, '2024-01-23', '2024-01-28', N'Đã giao', 1200000, N'Đơn hàng thiết bị công nghệ', 'phamthid'),
    ('DHB005', 5, '2024-01-24', '2024-01-29', N'Đã xác nhận', 6000000, N'Đơn hàng đồ gia dụng', 'hoangvane');

-- Thêm dữ liệu mẫu chi tiết đơn hàng bán
INSERT INTO [dbo].[ChiTietDonHangBan] ([MaDonHangBan], [MaSanPham], [SoLuong], [DonGia], [GhiChu])
VALUES 
    (1, 1, 1, 30000000, N'Laptop Dell Inspiron'),
    (2, 3, 3, 250000, N'Áo thun nam'),
    (2, 7, 1, 600000, N'Quần jean nam'),
    (3, 4, 1, 350000, N'Sách lập trình C#'),
    (4, 5, 1, 1200000, N'Bàn phím cơ gaming'),
    (5, 13, 2, 3000000, N'Bàn ăn gỗ');

-- Thêm dữ liệu mẫu phiếu nhập kho
INSERT INTO [dbo].[PhieuNhapKho] ([SoPhieuNhap], [MaDonDatHang], [MaNhaCungCap], [NgayNhap], [MaKho], [TrangThai], [TongTien], [GhiChu], [NguoiTao])
VALUES 
    ('PNK001', 1, 1, '2024-01-25', 1, N'Đã ghi sổ', 25000000, N'Phiếu nhập laptop', 'nguyenvana'),
    ('PNK002', 2, 2, '2024-01-26', 1, N'Đã ghi sổ', 1500000, N'Phiếu nhập quần áo', 'tranthib'),
    ('PNK003', 3, 3, '2024-01-27', 1, N'Đã ghi sổ', 500000, N'Phiếu nhập sách', 'levanc'),
    ('PNK004', 5, 5, '2024-01-29', 2, N'Đã ghi sổ', 8000000, N'Phiếu nhập đồ gia dụng', 'hoangvane');

-- Thêm dữ liệu mẫu chi tiết phiếu nhập kho
INSERT INTO [dbo].[ChiTietPhieuNhapKho] ([MaPhieuNhap], [MaSanPham], [MaViTri], [SoLuong], [DonGia], [SoLo], [GhiChu])
VALUES 
    (1, 1, 1, 1, 25000000, 'LOT001', N'Laptop Dell Inspiron'),
    (2, 3, 2, 10, 150000, 'LOT002', N'Áo thun nam'),
    (2, 7, 2, 5, 400000, 'LOT003', N'Quần jean nam'),
    (3, 4, 3, 2, 200000, 'LOT004', N'Sách lập trình C#'),
    (3, 9, 3, 3, 150000, 'LOT005', N'Sách tiếng Anh'),
    (4, 13, 4, 2, 3000000, 'LOT006', N'Bàn ăn gỗ'),
    (4, 14, 4, 1, 5000000, 'LOT007', N'Ghế sofa');

-- Thêm dữ liệu mẫu phiếu xuất kho
INSERT INTO [dbo].[PhieuXuatKho] ([SoPhieuXuat], [MaDonHangBan], [MaKhachHang], [NgayXuat], [MaKho], [TrangThai], [TongTien], [GhiChu], [NguoiTao])
VALUES 
    ('PXK001', 1, 1, '2024-01-25', 1, N'Đã giao', 30000000, N'Phiếu xuất laptop', 'nguyenvana'),
    ('PXK002', 2, 2, '2024-01-26', 1, N'Đã giao', 800000, N'Phiếu xuất quần áo', 'tranthib'),
    ('PXK003', 3, 3, '2024-01-27', 1, N'Đã giao', 350000, N'Phiếu xuất sách', 'levanc'),
    ('PXK004', 4, 4, '2024-01-28', 1, N'Đã giao', 1200000, N'Phiếu xuất thiết bị công nghệ', 'phamthid'),
    ('PXK005', 5, 5, '2024-01-29', 2, N'Đã giao', 6000000, N'Phiếu xuất đồ gia dụng', 'hoangvane');

-- Thêm dữ liệu mẫu chi tiết phiếu xuất kho
INSERT INTO [dbo].[ChiTietPhieuXuatKho] ([MaPhieuXuat], [MaSanPham], [MaViTri], [SoLuong], [DonGia], [GhiChu])
VALUES 
    (1, 1, 1, 1, 30000000, N'Laptop Dell Inspiron'),
    (2, 3, 2, 3, 250000, N'Áo thun nam'),
    (2, 7, 2, 1, 600000, N'Quần jean nam'),
    (3, 4, 3, 1, 350000, N'Sách lập trình C#'),
    (4, 5, 1, 1, 1200000, N'Bàn phím cơ gaming'),
    (5, 13, 4, 2, 3000000, N'Bàn ăn gỗ');

-- Thêm dữ liệu mẫu tồn kho
INSERT INTO [dbo].[TonKho] ([MaSanPham], [MaKho], [MaViTri], [SoLo], [SoSerial], [NgayHetHan], [SoLuongTon], [SoLuongDatTruoc], [NgayKiemKeCuoi], [NguoiSuaCuoi])
VALUES 
    (1, 1, 1, 'LOT001', 'SN001', '2027-01-25', 0, 0, '2024-01-25', 'nguyenvana'),
    (3, 1, 2, 'LOT002', NULL, '2026-01-26', 7, 0, '2024-01-26', 'tranthib'),
    (7, 1, 2, 'LOT003', NULL, '2026-01-26', 4, 0, '2024-01-26', 'tranthib'),
    (4, 1, 3, 'LOT004', NULL, '2029-01-27', 1, 0, '2024-01-27', 'levanc'),
    (9, 1, 3, 'LOT005', NULL, '2029-01-27', 2, 0, '2024-01-27', 'levanc'),
    (13, 2, 4, 'LOT006', NULL, '2034-01-29', 0, 0, '2024-01-29', 'hoangvane'),
    (14, 2, 4, 'LOT007', NULL, '2034-01-29', 0, 0, '2024-01-29', 'hoangvane'),
    (5, 1, 1, 'LOT008', NULL, '2027-01-28', 0, 0, '2024-01-28', 'phamthid'),
    (2, 1, 1, 'LOT009', 'SN002', '2027-01-20', 8, 0, '2024-01-20', 'nguyenvana'),
    (6, 1, 1, 'LOT010', NULL, '2027-01-20', 22, 0, '2024-01-20', 'nguyenvana'),
    (8, 1, 2, 'LOT011', NULL, '2026-01-20', 18, 0, '2024-01-20', 'tranthib'),
    (10, 1, 3, 'LOT012', NULL, '2024-12-31', 95, 0, '2024-01-20', 'levanc'),
    (11, 1, 3, 'LOT013', NULL, '2025-06-30', 180, 0, '2024-01-20', 'phamthid'),
    (12, 1, 3, 'LOT014', NULL, '2024-02-15', 85, 0, '2024-01-20', 'phamthid'),
    (15, 1, 5, 'LOT015', NULL, '2026-01-20', 18, 0, '2024-01-20', 'vuthif'),
    (16, 1, 5, 'LOT016', NULL, '2026-01-20', 13, 0, '2024-01-20', 'vuthif'),
    (17, 1, 2, 'LOT017', NULL, '2026-06-30', 45, 0, '2024-01-20', 'dangvang'),
    (18, 1, 2, 'LOT018', NULL, '2026-06-30', 27, 0, '2024-01-20', 'dangvang'),
    (19, 1, 3, 'LOT019', NULL, '2027-12-31', 480, 0, '2024-01-20', 'buithih'),
    (20, 1, 3, 'LOT020', NULL, '2027-12-31', 185, 0, '2024-01-20', 'buithih'),
    (21, 1, 5, 'LOT021', NULL, '2027-01-20', 8, 0, '2024-01-20', 'lyvani'),
    (22, 1, 5, 'LOT022', NULL, '2027-01-20', 13, 0, '2024-01-20', 'lyvani'),
    (23, 1, 1, 'LOT023', 'SN003', '2027-01-20', 7, 0, '2024-01-20', 'trinhthik'),
    (24, 1, 3, 'LOT024', NULL, '2026-06-30', 95, 0, '2024-01-20', 'trinhthik');

-- Thêm dữ liệu mẫu giao dịch tồn kho
INSERT INTO [dbo].[GiaoDichTonKho] ([LoaiGiaoDich], [LoaiThamChieu], [MaThamChieu], [MaSanPham], [MaKho], [MaViTri], [SoLuong], [ChiPhiDonVi], [SoLo], [GhiChu], [NguoiTao])
VALUES 
    (N'Nhập kho', N'Phiếu nhập kho', 1, 1, 1, 1, 1, 25000000, 'LOT001', N'Tự động tạo từ phiếu nhập kho', 'Hệ thống'),
    (N'Nhập kho', N'Phiếu nhập kho', 2, 3, 1, 2, 10, 150000, 'LOT002', N'Tự động tạo từ phiếu nhập kho', 'Hệ thống'),
    (N'Nhập kho', N'Phiếu nhập kho', 2, 7, 1, 2, 5, 400000, 'LOT003', N'Tự động tạo từ phiếu nhập kho', 'Hệ thống'),
    (N'Nhập kho', N'Phiếu nhập kho', 3, 4, 1, 3, 2, 200000, 'LOT004', N'Tự động tạo từ phiếu nhập kho', 'Hệ thống'),
    (N'Nhập kho', N'Phiếu nhập kho', 3, 9, 1, 3, 3, 150000, 'LOT005', N'Tự động tạo từ phiếu nhập kho', 'Hệ thống'),
    (N'Nhập kho', N'Phiếu nhập kho', 4, 13, 2, 4, 2, 3000000, 'LOT006', N'Tự động tạo từ phiếu nhập kho', 'Hệ thống'),
    (N'Nhập kho', N'Phiếu nhập kho', 4, 14, 2, 4, 1, 5000000, 'LOT007', N'Tự động tạo từ phiếu nhập kho', 'Hệ thống'),
    (N'Xuất kho', N'Phiếu xuất kho', 1, 1, 1, 1, -1, 30000000, 'LOT001', N'Tự động tạo từ phiếu xuất kho', 'Hệ thống'),
    (N'Xuất kho', N'Phiếu xuất kho', 2, 3, 1, 2, -3, 250000, 'LOT002', N'Tự động tạo từ phiếu xuất kho', 'Hệ thống'),
    (N'Xuất kho', N'Phiếu xuất kho', 2, 7, 1, 2, -1, 600000, 'LOT003', N'Tự động tạo từ phiếu xuất kho', 'Hệ thống'),
    (N'Xuất kho', N'Phiếu xuất kho', 3, 4, 1, 3, -1, 350000, 'LOT004', N'Tự động tạo từ phiếu xuất kho', 'Hệ thống'),
    (N'Xuất kho', N'Phiếu xuất kho', 4, 5, 1, 1, -1, 1200000, 'LOT008', N'Tự động tạo từ phiếu xuất kho', 'Hệ thống'),
    (N'Xuất kho', N'Phiếu xuất kho', 5, 13, 2, 4, -2, 3000000, 'LOT006', N'Tự động tạo từ phiếu xuất kho', 'Hệ thống');

-- =============================================
-- CREATE VIEWS FOR REPORTING
-- =============================================

-- View hiển thị tồn kho hiện tại
GO
CREATE VIEW [dbo].[vw_TonKhoHienTai] AS
SELECT 
    p.MaSanPhamCode,
    p.TenSanPham,
    c.TenDanhMuc,
    s.TenNhaCungCap,
    i.MaKho,
    w.TenKho,
    i.MaViTri,
    l.MaViTriCode,
    i.SoLo,
    i.SoSerial,
    i.NgayHetHan,
    i.SoLuongTon,
    i.SoLuongDatTruoc,
    i.SoLuongKhaDung,
    i.NgayKiemKeCuoi,
    i.NgaySuaCuoi
FROM [dbo].[TonKho] i
INNER JOIN [dbo].[SanPham] p ON i.MaSanPham = p.MaSanPham
INNER JOIN [dbo].[DanhMucSanPham] c ON p.MaDanhMuc = c.MaDanhMuc
LEFT JOIN [dbo].[NhaCungCap] s ON p.MaNhaCungCap = s.MaNhaCungCap
INNER JOIN [dbo].[KhoHang] w ON i.MaKho = w.MaKho
LEFT JOIN [dbo].[ViTriTrongKho] l ON i.MaViTri = l.MaViTri
WHERE i.SoLuongTon > 0;

-- View hiển thị sản phẩm tồn kho thấp
GO
CREATE VIEW [dbo].[vw_SanPhamTonKhoThap] AS
SELECT 
    p.MaSanPhamCode,
    p.TenSanPham,
    c.TenDanhMuc,
    s.TenNhaCungCap,
    i.MaKho,
    w.TenKho,
    i.SoLuongTon,
    p.MucTonKhoToiThieu,
    p.DiemDatHangLai,
    CASE 
        WHEN i.SoLuongTon <= p.MucTonKhoToiThieu THEN N'Nguy hiểm'
        WHEN i.SoLuongTon <= p.DiemDatHangLai THEN N'Thấp'
        ELSE N'Bình thường'
    END AS TrangThaiTonKho
FROM [dbo].[TonKho] i
INNER JOIN [dbo].[SanPham] p ON i.MaSanPham = p.MaSanPham
INNER JOIN [dbo].[DanhMucSanPham] c ON p.MaDanhMuc = c.MaDanhMuc
LEFT JOIN [dbo].[NhaCungCap] s ON p.MaNhaCungCap = s.MaNhaCungCap
INNER JOIN [dbo].[KhoHang] w ON i.MaKho = w.MaKho
WHERE i.SoLuongTon <= p.DiemDatHangLai;

-- View tổng hợp giao dịch tồn kho
GO
CREATE VIEW [dbo].[vw_TongHopGiaoDichTonKho] AS
SELECT 
    p.MaSanPhamCode,
    p.TenSanPham,
    c.TenDanhMuc,
    w.TenKho,
    it.LoaiGiaoDich,
    COUNT(*) AS SoLuongGiaoDich,
    SUM(it.SoLuong) AS TongSoLuong,
    SUM(it.TongChiPhi) AS TongChiPhi,
    MIN(it.NgayGiaoDich) AS GiaoDichDauTien,
    MAX(it.NgayGiaoDich) AS GiaoDichCuoiCung
FROM [dbo].[GiaoDichTonKho] it
INNER JOIN [dbo].[SanPham] p ON it.MaSanPham = p.MaSanPham
INNER JOIN [dbo].[DanhMucSanPham] c ON p.MaDanhMuc = c.MaDanhMuc
INNER JOIN [dbo].[KhoHang] w ON it.MaKho = w.MaKho
GROUP BY p.MaSanPhamCode, p.TenSanPham, c.TenDanhMuc, w.TenKho, it.LoaiGiaoDich;

-- =============================================
-- CREATE STORED PROCEDURES
-- =============================================

-- Stored procedure lấy tồn kho sản phẩm theo kho
GO
CREATE PROCEDURE [dbo].[sp_LayTonKhoSanPhamTheoKho]
    @MaSanPham INT = NULL,
    @MaKho INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        p.MaSanPhamCode,
        p.TenSanPham,
        c.TenDanhMuc,
        w.TenKho,
        l.MaViTriCode,
        i.SoLo,
        i.SoSerial,
        i.NgayHetHan,
        i.SoLuongTon,
        i.SoLuongDatTruoc,
        i.SoLuongKhaDung,
        i.NgayKiemKeCuoi
    FROM [dbo].[TonKho] i
    INNER JOIN [dbo].[SanPham] p ON i.MaSanPham = p.MaSanPham
    INNER JOIN [dbo].[DanhMucSanPham] c ON p.MaDanhMuc = c.MaDanhMuc
    INNER JOIN [dbo].[KhoHang] w ON i.MaKho = w.MaKho
    LEFT JOIN [dbo].[ViTriTrongKho] l ON i.MaViTri = l.MaViTri
    WHERE (@MaSanPham IS NULL OR i.MaSanPham = @MaSanPham)
        AND (@MaKho IS NULL OR i.MaKho = @MaKho)
        AND i.SoLuongTon > 0
    ORDER BY p.MaSanPhamCode, w.TenKho, l.MaViTriCode;
END;
GO

-- Stored procedure cập nhật số lượng tồn kho
GO
CREATE PROCEDURE [dbo].[sp_CapNhatSoLuongTonKho]
    @MaSanPham INT,
    @MaKho INT,
    @MaViTri INT = NULL,
    @ThayDoiSoLuong DECIMAL(18,4),
    @LoaiGiaoDich NVARCHAR(20),
    @LoaiThamChieu NVARCHAR(20) = NULL,
    @MaThamChieu INT = NULL,
    @SoLo NVARCHAR(50) = NULL,
    @SoSerial NVARCHAR(100) = NULL,
    @NgayHetHan DATE = NULL,
    @ChiPhiDonVi DECIMAL(18,4) = NULL,
    @GhiChu NVARCHAR(500) = NULL,
    @MaNguoiDung NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    
    BEGIN TRY
        -- Cập nhật tồn kho
        UPDATE [dbo].[TonKho]
        SET 
            [SoLuongTon] = [SoLuongTon] + @ThayDoiSoLuong,
            [NgaySuaCuoi] = GETDATE(),
            [NguoiSuaCuoi] = @MaNguoiDung
        WHERE [MaSanPham] = @MaSanPham 
            AND [MaKho] = @MaKho
            AND (@MaViTri IS NULL OR [MaViTri] = @MaViTri)
            AND (@SoLo IS NULL OR [SoLo] = @SoLo);
        
        -- Thêm bản ghi giao dịch tồn kho
        INSERT INTO [dbo].[GiaoDichTonKho] (
            [NgayGiaoDich], [LoaiGiaoDich], [LoaiThamChieu], [MaThamChieu],
            [MaSanPham], [MaKho], [MaViTri], [SoLuong], [ChiPhiDonVi],
            [SoLo], [SoSerial], [NgayHetHan], [GhiChu], [NguoiTao]
        )
        VALUES (
            GETDATE(), @LoaiGiaoDich, @LoaiThamChieu, @MaThamChieu,
            @MaSanPham, @MaKho, @MaViTri, @ThayDoiSoLuong, @ChiPhiDonVi,
            @SoLo, @SoSerial, @NgayHetHan, @GhiChu, @MaNguoiDung
        );
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- =============================================
-- CREATE FUNCTIONS
-- =============================================

-- Function tính toán số lượng khả dụng cho sản phẩm trong kho
GO
CREATE FUNCTION [dbo].[fn_TinhSoLuongKhaDung]
(
    @MaSanPham INT,
    @MaKho INT
)
RETURNS DECIMAL(18,4)
AS
BEGIN
    DECLARE @SoLuongKhaDung DECIMAL(18,4) = 0;
    
    SELECT @SoLuongKhaDung = ISNULL(SUM([SoLuongKhaDung]), 0)
    FROM [dbo].[TonKho]
    WHERE [MaSanPham] = @MaSanPham AND [MaKho] = @MaKho;
    
    RETURN @SoLuongKhaDung;
END;
GO

-- Function lấy chi phí sản phẩm theo ngày
GO
CREATE FUNCTION [dbo].[fn_LayChiPhiSanPhamTheoNgay]
(
    @MaSanPham INT,
    @Ngay DATE
)
RETURNS DECIMAL(18,4)
AS
BEGIN
    DECLARE @ChiPhi DECIMAL(18,4) = 0;
    
    SELECT TOP 1 @ChiPhi = [ChiPhiDonVi]
    FROM [dbo].[GiaoDichTonKho]
    WHERE [MaSanPham] = @MaSanPham 
        AND [LoaiGiaoDich] = N'Nhập kho'
        AND [NgayGiaoDich] <= @Ngay
        AND [ChiPhiDonVi] IS NOT NULL
    ORDER BY [NgayGiaoDich] DESC;
    
    RETURN ISNULL(@ChiPhi, 0);
END;
GO

-- =============================================
-- CREATE TRIGGERS
-- =============================================

-- Trigger tự động cập nhật tồn kho khi thêm chi tiết phiếu nhập kho
GO
CREATE TRIGGER [dbo].[tr_ChiTietPhieuNhapKho_Insert] ON [dbo].[ChiTietPhieuNhapKho]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @MaPhieuNhap INT, @MaSanPham INT, @MaKho INT, @MaViTri INT;
    DECLARE @SoLuong DECIMAL(18,4), @DonGia DECIMAL(18,4);
    DECLARE @SoLo NVARCHAR(50), @SoSerial NVARCHAR(100), @NgayHetHan DATE;
    
    SELECT 
        @MaPhieuNhap = i.[MaPhieuNhap],
        @MaSanPham = i.[MaSanPham],
        @MaKho = r.[MaKho],
        @MaViTri = i.[MaViTri],
        @SoLuong = i.[SoLuong],
        @DonGia = i.[DonGia],
        @SoLo = i.[SoLo],
        @SoSerial = i.[SoSerial],
        @NgayHetHan = i.[NgayHetHan]
    FROM inserted i
    INNER JOIN [dbo].[PhieuNhapKho] r ON i.[MaPhieuNhap] = r.[MaPhieuNhap];
    
    -- Cập nhật hoặc thêm tồn kho
    IF EXISTS (SELECT 1 FROM [dbo].[TonKho] WHERE [MaSanPham] = @MaSanPham AND [MaKho] = @MaKho AND (@SoLo IS NULL OR [SoLo] = @SoLo))
    BEGIN
        UPDATE [dbo].[TonKho]
        SET 
            [SoLuongTon] = [SoLuongTon] + @SoLuong,
            [MaViTri] = ISNULL(@MaViTri, [MaViTri]),
            [NgaySuaCuoi] = GETDATE(),
            [NguoiSuaCuoi] = N'Hệ thống'
        WHERE [MaSanPham] = @MaSanPham AND [MaKho] = @MaKho AND (@SoLo IS NULL OR [SoLo] = @SoLo);
    END
    ELSE
    BEGIN
        INSERT INTO [dbo].[TonKho] ([MaSanPham], [MaKho], [MaViTri], [SoLo], [SoSerial], [NgayHetHan], [SoLuongTon], [NguoiSuaCuoi])
        VALUES (@MaSanPham, @MaKho, @MaViTri, @SoLo, @SoSerial, @NgayHetHan, @SoLuong, N'Hệ thống');
    END
    
    -- Thêm giao dịch tồn kho
    INSERT INTO [dbo].[GiaoDichTonKho] ([LoaiGiaoDich], [LoaiThamChieu], [MaThamChieu], [MaSanPham], [MaKho], [MaViTri], [SoLuong], [ChiPhiDonVi], [SoLo], [SoSerial], [NgayHetHan], [GhiChu], [NguoiTao])
    VALUES (N'Nhập kho', N'Phiếu nhập kho', @MaPhieuNhap, @MaSanPham, @MaKho, @MaViTri, @SoLuong, @DonGia, @SoLo, @SoSerial, @NgayHetHan, N'Tự động tạo từ phiếu nhập kho', N'Hệ thống');
END;
GO

-- =============================================
-- FINAL COMMENTS
-- =============================================

/*
Thiết kế cơ sở dữ liệu này cung cấp:

1. **Khả năng mở rộng**: Thiết kế module cho phép dễ dàng thêm tính năng mới
2. **Hiệu suất**: Chỉ mục phù hợp và truy vấn được tối ưu hóa
3. **Tính toàn vẹn dữ liệu**: Ràng buộc khóa ngoại và trigger
4. **Lịch sử kiểm tra**: Theo dõi toàn diện tất cả thay đổi tồn kho
5. **Tính linh hoạt**: Hỗ trợ nhiều kho, vị trí và theo dõi lô hàng
6. **Báo cáo**: Views và stored procedures cho các thao tác thông thường
7. **Bảo mật**: Quản lý người dùng và kiểm soát truy cập dựa trên vai trò

Tính năng chính:
- Hỗ trợ nhiều kho
- Theo dõi số lô và số serial
- Quản lý ngày hết hạn
- Lịch sử giao dịch toàn diện
- Quản lý nhà cung cấp và khách hàng
- Xử lý đơn đặt hàng và bán hàng
- Định giá và chi phí tồn kho
- Xác thực và phân quyền người dùng

Để mở rộng hệ thống này, hãy xem xét thêm:
- Hỗ trợ mã vạch/QR code
- Tích hợp ứng dụng di động
- Báo cáo và phân tích nâng cao
- Tích hợp với hệ thống kế toán
- Theo dõi vận chuyển và hậu cần
- Kiểm soát chất lượng và kiểm tra
- Dự báo và lập kế hoạch nhu cầu
*/

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
    [WarehouseID] INT IDENTITY(1,1) NOT NULL,
    [WarehouseCode] NVARCHAR(20) NOT NULL,
    [WarehouseName] NVARCHAR(100) NOT NULL,
    [Address] NVARCHAR(500) NULL,
    [ManagerID] INT NULL,
    [PhoneNumber] NVARCHAR(20) NULL,
    [Email] NVARCHAR(100) NULL,
    [IsActive] BIT NOT NULL DEFAULT 1,
    [CreatedDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [CreatedBy] NVARCHAR(50) NULL,
    [ModifiedDate] DATETIME NULL,
    [ModifiedBy] NVARCHAR(50) NULL,
    CONSTRAINT [PK_Warehouses] PRIMARY KEY CLUSTERED ([WarehouseID] ASC),
    CONSTRAINT [UQ_Warehouses_WarehouseCode] UNIQUE NONCLUSTERED ([WarehouseCode] ASC)
);
GO

-- 5. Bảng Vị Trí Trong Kho
CREATE TABLE [dbo].[ViTriTrongKho] (
    [LocationID] INT IDENTITY(1,1) NOT NULL,
    [WarehouseID] INT NOT NULL,
    [LocationCode] NVARCHAR(20) NOT NULL,
    [LocationName] NVARCHAR(100) NOT NULL,
    [LocationType] NVARCHAR(50) NULL, -- Shelf, Rack, Bin, etc.
    [Aisle] NVARCHAR(10) NULL,
    [Row] NVARCHAR(10) NULL,
    [Level] NVARCHAR(10) NULL,
    [Position] NVARCHAR(10) NULL,
    [Capacity] DECIMAL(18,4) NULL,
    [IsActive] BIT NOT NULL DEFAULT 1,
    [CreatedDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [CreatedBy] NVARCHAR(50) NULL,
    [ModifiedDate] DATETIME NULL,
    [ModifiedBy] NVARCHAR(50) NULL,
    CONSTRAINT [PK_Locations] PRIMARY KEY CLUSTERED ([LocationID] ASC),
    CONSTRAINT [UQ_Locations_Warehouse_Code] UNIQUE NONCLUSTERED ([WarehouseID] ASC, [LocationCode] ASC),
    CONSTRAINT [FK_Locations_Warehouses] FOREIGN KEY ([WarehouseID]) REFERENCES [dbo].[Warehouses] ([WarehouseID])
);
GO

-- 6. Bảng Tồn Kho
CREATE TABLE [dbo].[TonKho] (
    [InventoryID] INT IDENTITY(1,1) NOT NULL,
    [ProductID] INT NOT NULL,
    [WarehouseID] INT NOT NULL,
    [LocationID] INT NULL,
    [LotNumber] NVARCHAR(50) NULL,
    [SerialNumber] NVARCHAR(100) NULL,
    [ExpiryDate] DATE NULL,
    [QuantityOnHand] DECIMAL(18,4) NOT NULL DEFAULT 0,
    [QuantityReserved] DECIMAL(18,4) NOT NULL DEFAULT 0,
    [QuantityAvailable] AS ([QuantityOnHand] - [QuantityReserved]),
    [LastCountDate] DATETIME NULL,
    [LastModifiedDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [LastModifiedBy] NVARCHAR(50) NULL,
    CONSTRAINT [PK_Inventory] PRIMARY KEY CLUSTERED ([InventoryID] ASC),
    CONSTRAINT [UQ_Inventory_Product_Warehouse_Lot] UNIQUE NONCLUSTERED ([ProductID] ASC, [WarehouseID] ASC, [LotNumber] ASC),
    CONSTRAINT [FK_Inventory_Products] FOREIGN KEY ([ProductID]) REFERENCES [dbo].[Products] ([ProductID]),
    CONSTRAINT [FK_Inventory_Warehouses] FOREIGN KEY ([WarehouseID]) REFERENCES [dbo].[Warehouses] ([WarehouseID]),
    CONSTRAINT [FK_Inventory_Locations] FOREIGN KEY ([LocationID]) REFERENCES [dbo].[Locations] ([LocationID])
);
GO

-- 7. Bảng Đơn Đặt Hàng
CREATE TABLE [dbo].[DonDatHang] (
    [PurchaseOrderID] INT IDENTITY(1,1) NOT NULL,
    [PurchaseOrderNumber] NVARCHAR(50) NOT NULL,
    [SupplierID] INT NOT NULL,
    [OrderDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [ExpectedDeliveryDate] DATETIME NULL,
    [ActualDeliveryDate] DATETIME NULL,
    [Status] NVARCHAR(20) NOT NULL DEFAULT 'Draft', -- Draft, Submitted, Approved, Received, Cancelled
    [TotalAmount] DECIMAL(18,4) NULL,
    [Notes] NVARCHAR(1000) NULL,
    [CreatedDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [CreatedBy] NVARCHAR(50) NULL,
    [ModifiedDate] DATETIME NULL,
    [ModifiedBy] NVARCHAR(50) NULL,
    CONSTRAINT [PK_PurchaseOrders] PRIMARY KEY CLUSTERED ([PurchaseOrderID] ASC),
    CONSTRAINT [UQ_PurchaseOrders_Number] UNIQUE NONCLUSTERED ([PurchaseOrderNumber] ASC),
    CONSTRAINT [FK_PurchaseOrders_Suppliers] FOREIGN KEY ([SupplierID]) REFERENCES [dbo].[Suppliers] ([SupplierID])
);
GO

-- 8. Bảng Chi Tiết Đơn Đặt Hàng
CREATE TABLE [dbo].[ChiTietDonDatHang] (
    [PurchaseOrderDetailID] INT IDENTITY(1,1) NOT NULL,
    [PurchaseOrderID] INT NOT NULL,
    [ProductID] INT NOT NULL,
    [Quantity] DECIMAL(18,4) NOT NULL,
    [UnitPrice] DECIMAL(18,4) NOT NULL,
    [LineTotal] AS ([Quantity] * [UnitPrice]),
    [ReceivedQuantity] DECIMAL(18,4) NOT NULL DEFAULT 0,
    [Notes] NVARCHAR(500) NULL,
    CONSTRAINT [PK_PurchaseOrderDetails] PRIMARY KEY CLUSTERED ([PurchaseOrderDetailID] ASC),
    CONSTRAINT [FK_PurchaseOrderDetails_PurchaseOrders] FOREIGN KEY ([PurchaseOrderID]) REFERENCES [dbo].[PurchaseOrders] ([PurchaseOrderID]),
    CONSTRAINT [FK_PurchaseOrderDetails_Products] FOREIGN KEY ([ProductID]) REFERENCES [dbo].[Products] ([ProductID])
);
GO

-- 9. Bảng Phiếu Nhập Kho
CREATE TABLE [dbo].[PhieuNhapKho] (
    [ReceiptID] INT IDENTITY(1,1) NOT NULL,
    [ReceiptNumber] NVARCHAR(50) NOT NULL,
    [PurchaseOrderID] INT NULL,
    [SupplierID] INT NOT NULL,
    [ReceiptDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [WarehouseID] INT NOT NULL,
    [Status] NVARCHAR(20) NOT NULL DEFAULT 'Draft', -- Draft, Received, Posted
    [TotalAmount] DECIMAL(18,4) NULL,
    [Notes] NVARCHAR(1000) NULL,
    [CreatedDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [CreatedBy] NVARCHAR(50) NULL,
    [ModifiedDate] DATETIME NULL,
    [ModifiedBy] NVARCHAR(50) NULL,
    CONSTRAINT [PK_Receipts] PRIMARY KEY CLUSTERED ([ReceiptID] ASC),
    CONSTRAINT [UQ_Receipts_Number] UNIQUE NONCLUSTERED ([ReceiptNumber] ASC),
    CONSTRAINT [FK_Receipts_PurchaseOrders] FOREIGN KEY ([PurchaseOrderID]) REFERENCES [dbo].[PurchaseOrders] ([PurchaseOrderID]),
    CONSTRAINT [FK_Receipts_Suppliers] FOREIGN KEY ([SupplierID]) REFERENCES [dbo].[Suppliers] ([SupplierID]),
    CONSTRAINT [FK_Receipts_Warehouses] FOREIGN KEY ([WarehouseID]) REFERENCES [dbo].[Warehouses] ([WarehouseID])
);
GO

-- 10. Bảng Chi Tiết Phiếu Nhập Kho
CREATE TABLE [dbo].[ChiTietPhieuNhapKho] (
    [ReceiptDetailID] INT IDENTITY(1,1) NOT NULL,
    [ReceiptID] INT NOT NULL,
    [ProductID] INT NOT NULL,
    [LocationID] INT NULL,
    [Quantity] DECIMAL(18,4) NOT NULL,
    [UnitPrice] DECIMAL(18,4) NOT NULL,
    [LineTotal] AS ([Quantity] * [UnitPrice]),
    [LotNumber] NVARCHAR(50) NULL,
    [SerialNumber] NVARCHAR(100) NULL,
    [ExpiryDate] DATE NULL,
    [Notes] NVARCHAR(500) NULL,
    CONSTRAINT [PK_ReceiptDetails] PRIMARY KEY CLUSTERED ([ReceiptDetailID] ASC),
    CONSTRAINT [FK_ReceiptDetails_Receipts] FOREIGN KEY ([ReceiptID]) REFERENCES [dbo].[Receipts] ([ReceiptID]),
    CONSTRAINT [FK_ReceiptDetails_Products] FOREIGN KEY ([ProductID]) REFERENCES [dbo].[Products] ([ProductID]),
    CONSTRAINT [FK_ReceiptDetails_Locations] FOREIGN KEY ([LocationID]) REFERENCES [dbo].[Locations] ([LocationID])
);
GO

-- 11. Bảng Đơn Hàng Bán
CREATE TABLE [dbo].[DonHangBan] (
    [SalesOrderID] INT IDENTITY(1,1) NOT NULL,
    [SalesOrderNumber] NVARCHAR(50) NOT NULL,
    [CustomerID] INT NULL, -- Can be null for walk-in customers
    [OrderDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [RequiredDate] DATETIME NULL,
    [ShippedDate] DATETIME NULL,
    [Status] NVARCHAR(20) NOT NULL DEFAULT 'Draft', -- Draft, Confirmed, Shipped, Delivered, Cancelled
    [TotalAmount] DECIMAL(18,4) NULL,
    [Notes] NVARCHAR(1000) NULL,
    [CreatedDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [CreatedBy] NVARCHAR(50) NULL,
    [ModifiedDate] DATETIME NULL,
    [ModifiedBy] NVARCHAR(50) NULL,
    CONSTRAINT [PK_SalesOrders] PRIMARY KEY CLUSTERED ([SalesOrderID] ASC),
    CONSTRAINT [UQ_SalesOrders_Number] UNIQUE NONCLUSTERED ([SalesOrderNumber] ASC)
);
GO

-- 12. Bảng Chi Tiết Đơn Hàng Bán
CREATE TABLE [dbo].[ChiTietDonHangBan] (
    [SalesOrderDetailID] INT IDENTITY(1,1) NOT NULL,
    [SalesOrderID] INT NOT NULL,
    [ProductID] INT NOT NULL,
    [Quantity] DECIMAL(18,4) NOT NULL,
    [UnitPrice] DECIMAL(18,4) NOT NULL,
    [LineTotal] AS ([Quantity] * [UnitPrice]),
    [ShippedQuantity] DECIMAL(18,4) NOT NULL DEFAULT 0,
    [Notes] NVARCHAR(500) NULL,
    CONSTRAINT [PK_SalesOrderDetails] PRIMARY KEY CLUSTERED ([SalesOrderDetailID] ASC),
    CONSTRAINT [FK_SalesOrderDetails_SalesOrders] FOREIGN KEY ([SalesOrderID]) REFERENCES [dbo].[SalesOrders] ([SalesOrderID]),
    CONSTRAINT [FK_SalesOrderDetails_Products] FOREIGN KEY ([ProductID]) REFERENCES [dbo].[Products] ([ProductID])
);
GO

-- 13. Bảng Phiếu Xuất Kho
CREATE TABLE [dbo].[PhieuXuatKho] (
    [ShipmentID] INT IDENTITY(1,1) NOT NULL,
    [ShipmentNumber] NVARCHAR(50) NOT NULL,
    [SalesOrderID] INT NULL,
    [CustomerID] INT NULL,
    [ShipmentDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [WarehouseID] INT NOT NULL,
    [Status] NVARCHAR(20) NOT NULL DEFAULT 'Draft', -- Draft, Picked, Shipped, Delivered
    [TotalAmount] DECIMAL(18,4) NULL,
    [Notes] NVARCHAR(1000) NULL,
    [CreatedDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [CreatedBy] NVARCHAR(50) NULL,
    [ModifiedDate] DATETIME NULL,
    [ModifiedBy] NVARCHAR(50) NULL,
    CONSTRAINT [PK_Shipments] PRIMARY KEY CLUSTERED ([ShipmentID] ASC),
    CONSTRAINT [UQ_Shipments_Number] UNIQUE NONCLUSTERED ([ShipmentNumber] ASC),
    CONSTRAINT [FK_Shipments_SalesOrders] FOREIGN KEY ([SalesOrderID]) REFERENCES [dbo].[SalesOrders] ([SalesOrderID]),
    CONSTRAINT [FK_Shipments_Warehouses] FOREIGN KEY ([WarehouseID]) REFERENCES [dbo].[Warehouses] ([WarehouseID])
);
GO

-- 14. Bảng Chi Tiết Phiếu Xuất Kho
CREATE TABLE [dbo].[ChiTietPhieuXuatKho] (
    [ShipmentDetailID] INT IDENTITY(1,1) NOT NULL,
    [ShipmentID] INT NOT NULL,
    [ProductID] INT NOT NULL,
    [LocationID] INT NULL,
    [Quantity] DECIMAL(18,4) NOT NULL,
    [UnitPrice] DECIMAL(18,4) NOT NULL,
    [LineTotal] AS ([Quantity] * [UnitPrice]),
    [LotNumber] NVARCHAR(50) NULL,
    [SerialNumber] NVARCHAR(100) NULL,
    [Notes] NVARCHAR(500) NULL,
    CONSTRAINT [PK_ShipmentDetails] PRIMARY KEY CLUSTERED ([ShipmentDetailID] ASC),
    CONSTRAINT [FK_ShipmentDetails_Shipments] FOREIGN KEY ([ShipmentID]) REFERENCES [dbo].[Shipments] ([ShipmentID]),
    CONSTRAINT [FK_ShipmentDetails_Products] FOREIGN KEY ([ProductID]) REFERENCES [dbo].[Products] ([ProductID]),
    CONSTRAINT [FK_ShipmentDetails_Locations] FOREIGN KEY ([LocationID]) REFERENCES [dbo].[Locations] ([LocationID])
);
GO

-- 15. Bảng Giao Dịch Tồn Kho
CREATE TABLE [dbo].[GiaoDichTonKho] (
    [TransactionID] INT IDENTITY(1,1) NOT NULL,
    [TransactionDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [TransactionType] NVARCHAR(20) NOT NULL, -- Receipt, Shipment, Adjustment, Transfer, Count
    [ReferenceType] NVARCHAR(20) NULL, -- PurchaseOrder, SalesOrder, Adjustment, Transfer, Count
    [ReferenceID] INT NULL,
    [ProductID] INT NOT NULL,
    [WarehouseID] INT NOT NULL,
    [LocationID] INT NULL,
    [Quantity] DECIMAL(18,4) NOT NULL,
    [UnitCost] DECIMAL(18,4) NULL,
    [TotalCost] AS ([Quantity] * [UnitCost]),
    [LotNumber] NVARCHAR(50) NULL,
    [SerialNumber] NVARCHAR(100) NULL,
    [ExpiryDate] DATE NULL,
    [Notes] NVARCHAR(500) NULL,
    [CreatedDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [CreatedBy] NVARCHAR(50) NULL,
    CONSTRAINT [PK_InventoryTransactions] PRIMARY KEY CLUSTERED ([TransactionID] ASC),
    CONSTRAINT [FK_InventoryTransactions_Products] FOREIGN KEY ([ProductID]) REFERENCES [dbo].[Products] ([ProductID]),
    CONSTRAINT [FK_InventoryTransactions_Warehouses] FOREIGN KEY ([WarehouseID]) REFERENCES [dbo].[Warehouses] ([WarehouseID]),
    CONSTRAINT [FK_InventoryTransactions_Locations] FOREIGN KEY ([LocationID]) REFERENCES [dbo].[Locations] ([LocationID])
);
GO

-- 16. Bảng Khách Hàng
CREATE TABLE [dbo].[KhachHang] (
    [CustomerID] INT IDENTITY(1,1) NOT NULL,
    [CustomerCode] NVARCHAR(20) NOT NULL,
    [CustomerName] NVARCHAR(200) NOT NULL,
    [ContactPerson] NVARCHAR(100) NULL,
    [PhoneNumber] NVARCHAR(20) NULL,
    [Email] NVARCHAR(100) NULL,
    [Address] NVARCHAR(500) NULL,
    [TaxCode] NVARCHAR(50) NULL,
    [CreditLimit] DECIMAL(18,2) NULL,
    [PaymentTerms] NVARCHAR(100) NULL,
    [IsActive] BIT NOT NULL DEFAULT 1,
    [CreatedDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [CreatedBy] NVARCHAR(50) NULL,
    [ModifiedDate] DATETIME NULL,
    [ModifiedBy] NVARCHAR(50) NULL,
    CONSTRAINT [PK_Customers] PRIMARY KEY CLUSTERED ([CustomerID] ASC),
    CONSTRAINT [UQ_Customers_CustomerCode] UNIQUE NONCLUSTERED ([CustomerCode] ASC)
);
GO

-- 17. Bảng Người Dùng Hệ Thống
CREATE TABLE [dbo].[NguoiDungHeThong] (
    [UserID] INT IDENTITY(1,1) NOT NULL,
    [Username] NVARCHAR(50) NOT NULL,
    [PasswordHash] NVARCHAR(255) NOT NULL,
    [FullName] NVARCHAR(100) NOT NULL,
    [Email] NVARCHAR(100) NULL,
    [PhoneNumber] NVARCHAR(20) NULL,
    [IsActive] BIT NOT NULL DEFAULT 1,
    [LastLoginDate] DATETIME NULL,
    [CreatedDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [CreatedBy] NVARCHAR(50) NULL,
    [ModifiedDate] DATETIME NULL,
    [ModifiedBy] NVARCHAR(50) NULL,
    CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED ([UserID] ASC),
    CONSTRAINT [UQ_Users_Username] UNIQUE NONCLUSTERED ([Username] ASC)
);
GO

-- 18. Bảng Vai Trò Người Dùng
CREATE TABLE [dbo].[VaiTroNguoiDung] (
    [UserRoleID] INT IDENTITY(1,1) NOT NULL,
    [UserID] INT NOT NULL,
    [RoleName] NVARCHAR(50) NOT NULL, -- Admin, Manager, Operator, Viewer
    [IsActive] BIT NOT NULL DEFAULT 1,
    [CreatedDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [CreatedBy] NVARCHAR(50) NULL,
    CONSTRAINT [PK_UserRoles] PRIMARY KEY CLUSTERED ([UserRoleID] ASC),
    CONSTRAINT [FK_UserRoles_Users] FOREIGN KEY ([UserID]) REFERENCES [dbo].[Users] ([UserID])
);
GO

-- =============================================
-- CREATE INDEXES FOR PERFORMANCE
-- =============================================

-- Indexes for Inventory table
CREATE NONCLUSTERED INDEX [IX_Inventory_Product_Warehouse] ON [dbo].[Inventory] ([ProductID] ASC, [WarehouseID] ASC);
CREATE NONCLUSTERED INDEX [IX_Inventory_LotNumber] ON [dbo].[Inventory] ([LotNumber] ASC);
CREATE NONCLUSTERED INDEX [IX_Inventory_ExpiryDate] ON [dbo].[Inventory] ([ExpiryDate] ASC);

-- Indexes for Inventory Transactions table
CREATE NONCLUSTERED INDEX [IX_InventoryTransactions_Date_Type] ON [dbo].[InventoryTransactions] ([TransactionDate] ASC, [TransactionType] ASC);
CREATE NONCLUSTERED INDEX [IX_InventoryTransactions_Product_Warehouse] ON [dbo].[InventoryTransactions] ([ProductID] ASC, [WarehouseID] ASC);
CREATE NONCLUSTERED INDEX [IX_InventoryTransactions_Reference] ON [dbo].[InventoryTransactions] ([ReferenceType] ASC, [ReferenceID] ASC);

-- Indexes for Products table
CREATE NONCLUSTERED INDEX [IX_Products_Category] ON [dbo].[Products] ([CategoryID] ASC);
CREATE NONCLUSTERED INDEX [IX_Products_Supplier] ON [dbo].[Products] ([SupplierID] ASC);
CREATE NONCLUSTERED INDEX [IX_Products_Active] ON [dbo].[Products] ([IsActive] ASC);

-- Indexes for Purchase Orders table
CREATE NONCLUSTERED INDEX [IX_PurchaseOrders_Supplier_Date] ON [dbo].[PurchaseOrders] ([SupplierID] ASC, [OrderDate] ASC);
CREATE NONCLUSTERED INDEX [IX_PurchaseOrders_Status] ON [dbo].[PurchaseOrders] ([Status] ASC);

-- Indexes for Sales Orders table
CREATE NONCLUSTERED INDEX [IX_SalesOrders_Customer_Date] ON [dbo].[SalesOrders] ([CustomerID] ASC, [OrderDate] ASC);
CREATE NONCLUSTERED INDEX [IX_SalesOrders_Status] ON [dbo].[SalesOrders] ([Status] ASC);

-- =============================================
-- INSERT SAMPLE DATA
-- =============================================

-- Thêm dữ liệu mẫu danh mục
INSERT INTO [dbo].[DanhMucSanPham] ([MaDanhMucCode], [TenDanhMuc], [MoTa], [NguoiTao])
VALUES 
    ('DM001', N'Điện tử', N'Thiết bị và linh kiện điện tử', 'Hệ thống'),
    ('DM002', N'Quần áo', N'Trang phục và phụ kiện', 'Hệ thống'),
    ('DM003', N'Sách', N'Sách và ấn phẩm', 'Hệ thống'),
    ('DM004', N'Thực phẩm', N'Thực phẩm và đồ uống', 'Hệ thống');

-- Thêm dữ liệu mẫu nhà cung cấp
INSERT INTO [dbo].[NhaCungCap] ([MaNhaCungCapCode], [TenNhaCungCap], [NguoiLienHe], [SoDienThoai], [Email], [DiaChi], [NguoiTao])
VALUES 
    ('NCC001', N'Công ty Giải pháp Công nghệ', N'Nguyễn Văn A', '0123456789', 'nguyenvana@tech.com', N'123 Đường Công nghệ, TP.HCM', 'Hệ thống'),
    ('NCC002', N'Công ty Thời trang Thế giới', N'Trần Thị B', '0987654321', 'tranthib@fashion.com', N'456 Đại lộ Thời trang, Hà Nội', 'Hệ thống'),
    ('NCC003', N'Công ty Xuất bản Sách', N'Lê Văn C', '0369852147', 'levanc@book.com', N'789 Đường Sách, Đà Nẵng', 'Hệ thống');

-- Thêm dữ liệu mẫu sản phẩm
INSERT INTO [dbo].[SanPham] ([MaSanPhamCode], [TenSanPham], [MaDanhMuc], [MaNhaCungCap], [MoTa], [DonViTinh], [GiaVon], [GiaBan], [MucTonKhoToiThieu], [MucTonKhoToiDa], [DiemDatHangLai], [NguoiTao])
VALUES 
    ('SP001', N'Laptop Dell', 1, 1, N'Laptop hiệu suất cao với thông số kỹ thuật mới nhất', 'Cái', 20000000, 30000000, 5, 50, 10, 'Hệ thống'),
    ('SP002', N'Điện thoại thông minh', 1, 1, N'Điện thoại thông minh mới nhất với tính năng tiên tiến', 'Cái', 10000000, 15000000, 10, 100, 20, 'Hệ thống'),
    ('SP003', N'Áo thun', 2, 2, N'Áo thun cotton nhiều màu sắc', 'Cái', 150000, 250000, 50, 500, 100, 'Hệ thống'),
    ('SP004', N'Sách lập trình', 3, 3, N'Hướng dẫn hoàn chỉnh về lập trình', 'Cuốn', 200000, 350000, 20, 200, 40, 'Hệ thống');

-- Thêm dữ liệu mẫu kho hàng
INSERT INTO [dbo].[KhoHang] ([MaKhoCode], [TenKho], [DiaChi], [SoDienThoai], [Email], [NguoiTao])
VALUES 
    ('KH001', N'Kho chính', N'100 Đường Kho hàng, Khu Công nghiệp', '0123456789', 'khochinh@quanlykho.com', 'Hệ thống'),
    ('KH002', N'Kho phụ', N'200 Đường Lưu trữ, Khu Thương mại', '0987654321', 'khophu@quanlykho.com', 'Hệ thống');

-- Thêm dữ liệu mẫu vị trí trong kho
INSERT INTO [dbo].[ViTriTrongKho] ([MaKho], [MaViTriCode], [TenViTri], [LoaiViTri], [LoiDi], [Hang], [Tang], [ViTri], [NguoiTao])
VALUES 
    (1, 'A1-H1-T1', N'Lối đi 1, Hàng 1, Tầng 1', N'Kệ', 'A1', 'H1', 'T1', 'V1', 'Hệ thống'),
    (1, 'A1-H1-T2', N'Lối đi 1, Hàng 1, Tầng 2', N'Kệ', 'A1', 'H1', 'T2', 'V1', 'Hệ thống'),
    (1, 'A2-H1-T1', N'Lối đi 2, Hàng 1, Tầng 1', N'Giá', 'A2', 'H1', 'T1', 'V1', 'Hệ thống'),
    (2, 'A1-H1-T1', N'Lối đi 1, Hàng 1, Tầng 1', N'Kệ', 'A1', 'H1', 'T1', 'V1', 'Hệ thống');

-- Thêm dữ liệu mẫu người dùng hệ thống
INSERT INTO [dbo].[NguoiDungHeThong] ([TenDangNhap], [MatKhau], [HoTen], [Email], [NguoiTao])
VALUES 
    ('admin', 'admin123', N'Quản trị viên hệ thống', 'admin@quanlykho.com', 'Hệ thống'),
    ('manager', 'manager123', N'Quản lý kho', 'manager@quanlykho.com', 'Hệ thống'),
    ('operator', 'operator123', N'Nhân viên kho', 'operator@quanlykho.com', 'Hệ thống');

-- Thêm dữ liệu mẫu vai trò người dùng
INSERT INTO [dbo].[VaiTroNguoiDung] ([MaNguoiDung], [TenVaiTro], [NguoiTao])
VALUES 
    (1, N'Quản trị viên', 'Hệ thống'),
    (2, N'Quản lý', 'Hệ thống'),
    (3, N'Nhân viên', 'Hệ thống');

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

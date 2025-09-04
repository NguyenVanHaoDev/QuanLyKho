using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic; // Added for Dictionary

namespace QLKHO.DLL
{
    public class ProductRepository
    {
        private readonly string _connectionString;

        public ProductRepository()
        {
            _connectionString = ConfigurationManager.ConnectionStrings["QUANLYKHO_Connection"].ConnectionString;
        }

        public DataTable GetAllProducts()
        {
            var dataTable = new DataTable();
            using (var connection = new SqlConnection(_connectionString))
            using (var command = new SqlCommand(@"
                SELECT 
                    p.[MaSanPham],
                    p.[MaSanPhamCode],
                    p.[TenSanPham],
                    p.[MoTa],
                    p.[DonViTinh],
                    p.[GiaVon],
                    p.[GiaBan],
                    p.[MucTonKhoToiThieu],
                    p.[MucTonKhoToiDa],
                    p.[DiemDatHangLai],
                    p.[ThoiGianGiaoHang],
                    p.[HoatDong],
                    p.[NgayTao],
                    p.[MaDanhMuc],
                    p.[MaNhaCungCap],
                    c.[TenDanhMuc],
                    n.[TenNhaCungCap]
                FROM [dbo].[SanPham] p
                INNER JOIN [dbo].[DanhMucSanPham] c ON p.[MaDanhMuc] = c.[MaDanhMuc]
                LEFT JOIN [dbo].[NhaCungCap] n ON p.[MaNhaCungCap] = n.[MaNhaCungCap]
                WHERE p.[HoatDong] = 1
                ORDER BY p.[TenSanPham]", connection))
            {
                using (var adapter = new SqlDataAdapter(command))
                {
                    adapter.Fill(dataTable);
                }
            }
            return dataTable;
        }



        public DataTable GetProductsWithStock()
        {
            var dataTable = new DataTable();
            using (var connection = new SqlConnection(_connectionString))
            using (var command = new SqlCommand(@"
                SELECT 
                    p.[MaSanPham],
                    p.[MaSanPhamCode],
                    p.[TenSanPham],
                    p.[MoTa],
                    p.[DonViTinh],
                    p.[GiaVon],
                    p.[GiaBan],
                    p.[MucTonKhoToiThieu],
                    p.[MucTonKhoToiDa],
                    p.[DiemDatHangLai],
                    p.[ThoiGianGiaoHang],
                    p.[HoatDong],
                    p.[NgayTao],
                    c.[TenDanhMuc],
                    n.[TenNhaCungCap],
                    ISNULL(SUM(t.[SoLuongTon]), 0) AS TongSoLuongTon,
                    ISNULL(SUM(t.[SoLuongDatTruoc]), 0) AS TongSoLuongDatTruoc,
                    ISNULL(SUM(t.[SoLuongKhaDung]), 0) AS TongSoLuongKhaDung
                FROM [dbo].[SanPham] p
                INNER JOIN [dbo].[DanhMucSanPham] c ON p.[MaDanhMuc] = c.[MaDanhMuc]
                LEFT JOIN [dbo].[NhaCungCap] n ON p.[MaNhaCungCap] = n.[MaNhaCungCap]
                LEFT JOIN [dbo].[TonKho] t ON p.[MaSanPham] = t.[MaSanPham]
                WHERE p.[HoatDong] = 1
                GROUP BY 
                    p.[MaSanPham], p.[MaSanPhamCode], p.[TenSanPham], p.[MoTa], 
                    p.[DonViTinh], p.[GiaVon], p.[GiaBan], p.[MucTonKhoToiThieu], 
                    p.[MucTonKhoToiDa], p.[DiemDatHangLai], p.[ThoiGianGiaoHang], 
                    p.[HoatDong], p.[NgayTao], c.[TenDanhMuc], n.[TenNhaCungCap]
                ORDER BY p.[TenSanPham]", connection))
            {
                using (var adapter = new SqlDataAdapter(command))
                {
                    adapter.Fill(dataTable);
                }
            }
            return dataTable;
        }

        public DataTable GetCategories()
        {
            var dataTable = new DataTable();
            using (var connection = new SqlConnection(_connectionString))
            using (var command = new SqlCommand(@"
                SELECT 
                    [MaDanhMuc],
                    [MaDanhMucCode],
                    [TenDanhMuc],
                    [MoTa],
                    [HoatDong]
                FROM [dbo].[DanhMucSanPham]
                WHERE [HoatDong] = 1
                ORDER BY [TenDanhMuc]", connection))
            {
                using (var adapter = new SqlDataAdapter(command))
                {
                    adapter.Fill(dataTable);
                }
            }
            return dataTable;
        }

        public DataTable SearchProducts(string searchTerm)
        {
            var dataTable = new DataTable();
            using (var connection = new SqlConnection(_connectionString))
            using (var command = new SqlCommand(@"
                SELECT 
                    p.[MaSanPham],
                    p.[MaSanPhamCode],
                    p.[TenSanPham],
                    p.[MoTa],
                    p.[DonViTinh],
                    p.[GiaVon],
                    p.[GiaBan],
                    p.[MucTonKhoToiThieu],
                    p.[MucTonKhoToiDa],
                    p.[DiemDatHangLai],
                    p.[ThoiGianGiaoHang],
                    p.[HoatDong],
                    p.[NgayTao],
                    p.[MaDanhMuc],
                    p.[MaNhaCungCap],
                    c.[TenDanhMuc],
                    n.[TenNhaCungCap]
                FROM [dbo].[SanPham] p
                INNER JOIN [dbo].[DanhMucSanPham] c ON p.[MaDanhMuc] = c.[MaDanhMuc]
                LEFT JOIN [dbo].[NhaCungCap] n ON p.[MaNhaCungCap] = n.[MaNhaCungCap]
                WHERE p.[HoatDong] = 1 
                    AND (p.[TenSanPham] LIKE @SearchTerm 
                         OR p.[MaSanPhamCode] LIKE @SearchTerm 
                         OR c.[TenDanhMuc] LIKE @SearchTerm)
                ORDER BY p.[TenSanPham]", connection))
            {
                command.Parameters.Add(new SqlParameter("@SearchTerm", SqlDbType.NVarChar) { Value = "%" + searchTerm + "%" });
                using (var adapter = new SqlDataAdapter(command))
                {
                    adapter.Fill(dataTable);
                }
            }
            return dataTable;
        }

        public DataTable GetAllCategories()
        {
            var dataTable = new DataTable();
            using (var connection = new SqlConnection(_connectionString))
            using (var command = new SqlCommand(@"
                SELECT 
                    [MaDanhMuc],
                    [MaDanhMucCode],
                    [TenDanhMuc],
                    [MoTa],
                    [HoatDong]
                FROM [dbo].[DanhMucSanPham]
                WHERE [HoatDong] = 1
                ORDER BY [TenDanhMuc]", connection))
            {
                using (var adapter = new SqlDataAdapter(command))
                {
                    adapter.Fill(dataTable);
                }
            }
            return dataTable;
        }

        public DataTable GetAllSuppliers()
        {
            var dataTable = new DataTable();
            using (var connection = new SqlConnection(_connectionString))
            using (var command = new SqlCommand(@"
                SELECT 
                    [MaNhaCungCap],
                    [MaNhaCungCapCode],
                    [TenNhaCungCap],
                    [NguoiLienHe],
                    [SoDienThoai],
                    [Email],
                    [HoatDong]
                FROM [dbo].[NhaCungCap]
                WHERE [HoatDong] = 1
                ORDER BY [TenNhaCungCap]", connection))
            {
                using (var adapter = new SqlDataAdapter(command))
                {
                    adapter.Fill(dataTable);
                }
            }
            return dataTable;
        }

        public int AddProduct(string productCode, string productName, int? categoryId, int? supplierId, 
            string description, string unit, decimal costPrice, decimal unitPrice, int userId)
        {
            using (var connection = new SqlConnection(_connectionString))
            {
                connection.Open();
                using (var command = new SqlCommand(@"
                    INSERT INTO [dbo].[SanPham] (
                        [MaSanPhamCode], [TenSanPham], [MaDanhMuc], [MaNhaCungCap], 
                        [MoTa], [DonViTinh], [GiaVon], [GiaBan], [HoatDong], 
                        [NgayTao], [MaNguoiDungTao]
                    ) VALUES (
                        @ProductCode, @ProductName, @CategoryId, @SupplierId, 
                        @Description, @Unit, @CostPrice, @UnitPrice, 1, 
                        GETDATE(), @UserId
                    );
                    SELECT SCOPE_IDENTITY();", connection))
                {
                    command.Parameters.Add(new SqlParameter("@ProductCode", SqlDbType.NVarChar, 50) { Value = productCode });
                    command.Parameters.Add(new SqlParameter("@ProductName", SqlDbType.NVarChar, 200) { Value = productName });
                    command.Parameters.Add(new SqlParameter("@CategoryId", SqlDbType.Int) { Value = (object)categoryId ?? DBNull.Value });
                    command.Parameters.Add(new SqlParameter("@SupplierId", SqlDbType.Int) { Value = (object)supplierId ?? DBNull.Value });
                    command.Parameters.Add(new SqlParameter("@Description", SqlDbType.NVarChar, 1000) { Value = (object)description ?? DBNull.Value });
                    command.Parameters.Add(new SqlParameter("@Unit", SqlDbType.NVarChar, 20) { Value = unit });
                    command.Parameters.Add(new SqlParameter("@CostPrice", SqlDbType.Decimal) { Value = costPrice });
                    command.Parameters.Add(new SqlParameter("@UnitPrice", SqlDbType.Decimal) { Value = unitPrice });
                    command.Parameters.Add(new SqlParameter("@UserId", SqlDbType.Int) { Value = userId });

                    var result = command.ExecuteScalar();
                    return Convert.ToInt32(result);
                }
            }
        }

        public bool UpdateProduct(int productId, string productCode, string productName, int? categoryId, int? supplierId, 
            string description, string unit, decimal costPrice, decimal unitPrice, int userId)
        {
            using (var connection = new SqlConnection(_connectionString))
            {
                connection.Open();
                using (var command = new SqlCommand(@"
                    UPDATE [dbo].[SanPham] SET
                        [MaSanPhamCode] = @ProductCode,
                        [TenSanPham] = @ProductName,
                        [MaDanhMuc] = @CategoryId,
                        [MaNhaCungCap] = @SupplierId,
                        [MoTa] = @Description,
                        [DonViTinh] = @Unit,
                        [GiaVon] = @CostPrice,
                        [GiaBan] = @UnitPrice,
                        [NgaySua] = GETDATE(),
                        [MaNguoiDungSua] = @UserId
                    WHERE [MaSanPham] = @ProductId", connection))
                {
                    command.Parameters.Add(new SqlParameter("@ProductId", SqlDbType.Int) { Value = productId });
                    command.Parameters.Add(new SqlParameter("@ProductCode", SqlDbType.NVarChar, 50) { Value = productCode });
                    command.Parameters.Add(new SqlParameter("@ProductName", SqlDbType.NVarChar, 200) { Value = productName });
                    command.Parameters.Add(new SqlParameter("@CategoryId", SqlDbType.Int) { Value = (object)categoryId ?? DBNull.Value });
                    command.Parameters.Add(new SqlParameter("@SupplierId", SqlDbType.Int) { Value = (object)supplierId ?? DBNull.Value });
                    command.Parameters.Add(new SqlParameter("@Description", SqlDbType.NVarChar, 1000) { Value = (object)description ?? DBNull.Value });
                    command.Parameters.Add(new SqlParameter("@Unit", SqlDbType.NVarChar, 20) { Value = unit });
                    command.Parameters.Add(new SqlParameter("@CostPrice", SqlDbType.Decimal) { Value = costPrice });
                    command.Parameters.Add(new SqlParameter("@UnitPrice", SqlDbType.Decimal) { Value = unitPrice });
                    command.Parameters.Add(new SqlParameter("@UserId", SqlDbType.Int) { Value = userId });

                    var rowsAffected = command.ExecuteNonQuery();
                    return rowsAffected > 0;
                }
            }
        }

        public bool DeleteProduct(int productId)
        {
            using (var connection = new SqlConnection(_connectionString))
            {
                connection.Open();
                using (var command = new SqlCommand(@"
                    UPDATE [dbo].[SanPham] SET
                        [HoatDong] = 0,
                        [NgaySua] = GETDATE()
                    WHERE [MaSanPham] = @ProductId", connection))
                {
                    command.Parameters.Add(new SqlParameter("@ProductId", SqlDbType.Int) { Value = productId });

                    var rowsAffected = command.ExecuteNonQuery();
                    return rowsAffected > 0;
                }
            }
        }

        public DataTable GetProductByCode(string productCode)
        {
            var query = @"
                SELECT MaSanPham, MaSanPhamCode, TenSanPham, HoatDong
                FROM SanPham 
                WHERE MaSanPhamCode = @ProductCode AND HoatDong = 1";
            
            var parameters = new Dictionary<string, object>
            {
                { "@ProductCode", productCode }
            };
            
            return ExecuteQuery(query, parameters);
        }

        public DataTable GetProductsByCategory(int categoryId)
        {
            var query = @"
                SELECT sp.MaSanPham, sp.MaSanPhamCode, sp.TenSanPham, sp.MoTa, sp.DonViTinh, 
                       sp.GiaVon, sp.GiaBan, sp.HoatDong,
                       dm.TenDanhMuc, ncc.TenNhaCungCap
                FROM SanPham sp
                LEFT JOIN DanhMucSanPham dm ON sp.MaDanhMuc = dm.MaDanhMuc
                LEFT JOIN NhaCungCap ncc ON sp.MaNhaCungCap = ncc.MaNhaCungCap
                WHERE sp.MaDanhMuc = @CategoryId AND sp.HoatDong = 1
                ORDER BY sp.TenSanPham";
            
            var parameters = new Dictionary<string, object>
            {
                { "@CategoryId", categoryId }
            };
            
            return ExecuteQuery(query, parameters);
        }

        public DataTable SearchProductsInCategory(string searchTerm, int categoryId)
        {
            var query = @"
                SELECT sp.MaSanPham, sp.MaSanPhamCode, sp.TenSanPham, sp.MoTa, sp.DonViTinh, 
                       sp.GiaVon, sp.GiaBan, sp.HoatDong,
                       dm.TenDanhMuc, ncc.TenNhaCungCap
                FROM SanPham sp
                LEFT JOIN DanhMucSanPham dm ON sp.MaDanhMuc = dm.MaDanhMuc
                LEFT JOIN NhaCungCap ncc ON sp.MaNhaCungCap = ncc.MaNhaCungCap
                WHERE sp.MaDanhMuc = @CategoryId 
                  AND sp.HoatDong = 1
                  AND (sp.MaSanPhamCode LIKE @SearchTerm 
                       OR sp.TenSanPham LIKE @SearchTerm 
                       OR sp.MoTa LIKE @SearchTerm)
                ORDER BY sp.TenSanPham";
            
            var parameters = new Dictionary<string, object>
            {
                { "@CategoryId", categoryId },
                { "@SearchTerm", "%" + searchTerm + "%" }
            };
            
            return ExecuteQuery(query, parameters);
        }

        private DataTable ExecuteQuery(string query, Dictionary<string, object> parameters)
        {
            var dataTable = new DataTable();
            using (var connection = new SqlConnection(_connectionString))
            {
                connection.Open();
                using (var command = new SqlCommand(query, connection))
                {
                    foreach (var param in parameters)
                    {
                        // Xác định kiểu dữ liệu SQL dựa trên kiểu C#
                        SqlDbType sqlType;
                        if (param.Value is int)
                            sqlType = SqlDbType.Int;
                        else if (param.Value is string)
                            sqlType = SqlDbType.NVarChar;
                        else if (param.Value is decimal)
                            sqlType = SqlDbType.Decimal;
                        else
                            sqlType = SqlDbType.NVarChar;
                        
                        command.Parameters.Add(new SqlParameter(param.Key, sqlType) { Value = param.Value });
                    }
                    using (var adapter = new SqlDataAdapter(command))
                    {
                        adapter.Fill(dataTable);
                    }
                }
            }
            return dataTable;
        }
    }
}

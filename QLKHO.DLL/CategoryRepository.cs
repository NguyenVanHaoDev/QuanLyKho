using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace QLKHO.DLL
{
    public class CategoryRepository
    {
        private readonly string _connectionString;

        public CategoryRepository()
        {
            _connectionString = ConfigurationManager.ConnectionStrings["QUANLYKHO_Connection"].ConnectionString;
        }

        public DataTable GetAllCategories()
        {
            var dataTable = new DataTable();
            using (var connection = new SqlConnection(_connectionString))
            using (var command = new SqlCommand(@"
                SELECT 
                    [MaDanhMuc],
                    [MaDanhMucCode] as 'Mã DM',
                    [TenDanhMuc] as 'Tên Danh Mục',
                    [MoTa] as 'Mô Tả',
                    [MaDanhMucCha] as 'Danh Mục Cha',
                    [HoatDong] as 'Hoạt Động',
                    [NgayTao] as 'Ngày Tạo'
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



        public DataTable GetCategoryById(int categoryId)
        {
            var dataTable = new DataTable();
            using (var connection = new SqlConnection(_connectionString))
            using (var command = new SqlCommand(@"
                SELECT 
                    [MaDanhMuc],
                    [MaDanhMucCode],
                    [TenDanhMuc],
                    [MoTa],
                    [MaDanhMucCha],
                    [HoatDong],
                    [NgayTao]
                FROM [dbo].[DanhMucSanPham]
                WHERE [MaDanhMuc] = @CategoryId", connection))
            {
                command.Parameters.Add(new SqlParameter("@CategoryId", SqlDbType.Int) { Value = categoryId });
                using (var adapter = new SqlDataAdapter(command))
                {
                    adapter.Fill(dataTable);
                }
            }
            return dataTable;
        }

        public DataTable GetParentCategories()
        {
            var dataTable = new DataTable();
            using (var connection = new SqlConnection(_connectionString))
            using (var command = new SqlCommand(@"
                SELECT 
                    [MaDanhMuc],
                    [MaDanhMucCode] as 'Mã DM',
                    [TenDanhMuc] as 'Tên Danh Mục'
                FROM [dbo].[DanhMucSanPham]
                WHERE [HoatDong] = 1 AND [MaDanhMucCha] IS NULL
                ORDER BY [TenDanhMuc]", connection))
            {
                using (var adapter = new SqlDataAdapter(command))
                {
                    adapter.Fill(dataTable);
                }
            }
            return dataTable;
        }

        public DataTable GetSubCategories(int parentCategoryId)
        {
            var dataTable = new DataTable();
            using (var connection = new SqlConnection(_connectionString))
            using (var command = new SqlCommand(@"
                SELECT 
                    [MaDanhMuc],
                    [MaDanhMucCode] as 'Mã DM',
                    [TenDanhMuc] as 'Tên Danh Mục',
                    [MoTa] as 'Mô Tả'
                FROM [dbo].[DanhMucSanPham]
                WHERE [HoatDong] = 1 AND [MaDanhMucCha] = @ParentCategoryId
                ORDER BY [TenDanhMuc]", connection))
            {
                command.Parameters.Add(new SqlParameter("@ParentCategoryId", SqlDbType.Int) { Value = parentCategoryId });
                using (var adapter = new SqlDataAdapter(command))
                {
                    adapter.Fill(dataTable);
                }
            }
            return dataTable;
        }

        public DataTable SearchCategories(string searchTerm)
        {
            var dataTable = new DataTable();
            using (var connection = new SqlConnection(_connectionString))
            using (var command = new SqlCommand(@"
                SELECT 
                    [MaDanhMuc],
                    [MaDanhMucCode] as 'Mã DM',
                    [TenDanhMuc] as 'Tên Danh Mục',
                    [MoTa] as 'Mô Tả',
                    [MaDanhMucCha] as 'Danh Mục Cha',
                    [HoatDong] as 'Hoạt Động',
                    [NgayTao] as 'Ngày Tạo'
                FROM [dbo].[DanhMucSanPham]
                WHERE [HoatDong] = 1 
                    AND ([TenDanhMuc] LIKE @SearchTerm 
                         OR [MaDanhMucCode] LIKE @SearchTerm 
                         OR [MoTa] LIKE @SearchTerm)
                ORDER BY [TenDanhMuc]", connection))
            {
                command.Parameters.Add(new SqlParameter("@SearchTerm", SqlDbType.NVarChar) { Value = "%" + searchTerm + "%" });
                using (var adapter = new SqlDataAdapter(command))
                {
                    adapter.Fill(dataTable);
                }
            }
            return dataTable;
        }

        public int AddCategory(string maDanhMucCode, string tenDanhMuc, string moTa, int? maDanhMucCha, int maNguoiDungTao)
        {
            using (var connection = new SqlConnection(_connectionString))
            {
                connection.Open();
                using (var command = new SqlCommand(@"
                    INSERT INTO [dbo].[DanhMucSanPham] 
                    ([MaDanhMucCode], [TenDanhMuc], [MoTa], [MaDanhMucCha], [MaNguoiDungTao])
                    VALUES (@MaDanhMucCode, @TenDanhMuc, @MoTa, @MaDanhMucCha, @MaNguoiDungTao);
                    SELECT SCOPE_IDENTITY();", connection))
                {
                    command.Parameters.Add(new SqlParameter("@MaDanhMucCode", SqlDbType.NVarChar, 20) { Value = maDanhMucCode });
                    command.Parameters.Add(new SqlParameter("@TenDanhMuc", SqlDbType.NVarChar, 100) { Value = tenDanhMuc });
                    command.Parameters.Add(new SqlParameter("@MoTa", SqlDbType.NVarChar, 500) { Value = moTa ?? (object)DBNull.Value });
                    command.Parameters.Add(new SqlParameter("@MaDanhMucCha", SqlDbType.Int) { Value = maDanhMucCha ?? (object)DBNull.Value });
                    command.Parameters.Add(new SqlParameter("@MaNguoiDungTao", SqlDbType.Int) { Value = maNguoiDungTao });

                    return Convert.ToInt32(command.ExecuteScalar());
                }
            }
        }

        public bool UpdateCategory(int maDanhMuc, string maDanhMucCode, string tenDanhMuc, string moTa, int? maDanhMucCha, int maNguoiDungSua)
        {
            using (var connection = new SqlConnection(_connectionString))
            {
                connection.Open();
                using (var command = new SqlCommand(@"
                    UPDATE [dbo].[DanhMucSanPham] 
                    SET [MaDanhMucCode] = @MaDanhMucCode,
                        [TenDanhMuc] = @TenDanhMuc,
                        [MoTa] = @MoTa,
                        [MaDanhMucCha] = @MaDanhMucCha,
                        [NgaySua] = GETDATE(),
                        [MaNguoiDungSua] = @MaNguoiDungSua
                    WHERE [MaDanhMuc] = @MaDanhMuc", connection))
                {
                    command.Parameters.Add(new SqlParameter("@MaDanhMuc", SqlDbType.Int) { Value = maDanhMuc });
                    command.Parameters.Add(new SqlParameter("@MaDanhMucCode", SqlDbType.NVarChar, 20) { Value = maDanhMucCode });
                    command.Parameters.Add(new SqlParameter("@TenDanhMuc", SqlDbType.NVarChar, 100) { Value = tenDanhMuc });
                    command.Parameters.Add(new SqlParameter("@MoTa", SqlDbType.NVarChar, 500) { Value = moTa ?? (object)DBNull.Value });
                    command.Parameters.Add(new SqlParameter("@MaDanhMucCha", SqlDbType.Int) { Value = maDanhMucCha ?? (object)DBNull.Value });
                    command.Parameters.Add(new SqlParameter("@MaNguoiDungSua", SqlDbType.Int) { Value = maNguoiDungSua });

                    return command.ExecuteNonQuery() > 0;
                }
            }
        }

        public bool DeleteCategory(int maDanhMuc)
        {
            using (var connection = new SqlConnection(_connectionString))
            {
                connection.Open();
                using (var command = new SqlCommand(@"
                    UPDATE [dbo].[DanhMucSanPham] 
                    SET [HoatDong] = 0
                    WHERE [MaDanhMuc] = @MaDanhMuc", connection))
                {
                    command.Parameters.Add(new SqlParameter("@MaDanhMuc", SqlDbType.Int) { Value = maDanhMuc });
                    return command.ExecuteNonQuery() > 0;
                }
            }
        }

        public bool IsCategoryCodeExists(string maDanhMucCode, int? excludeCategoryId = null)
        {
            using (var connection = new SqlConnection(_connectionString))
            {
                connection.Open();
                var sql = "SELECT COUNT(*) FROM [dbo].[DanhMucSanPham] WHERE [MaDanhMucCode] = @MaDanhMucCode";
                if (excludeCategoryId.HasValue)
                {
                    sql += " AND [MaDanhMuc] != @ExcludeCategoryId";
                }

                using (var command = new SqlCommand(sql, connection))
                {
                    command.Parameters.Add(new SqlParameter("@MaDanhMucCode", SqlDbType.NVarChar, 20) { Value = maDanhMucCode });
                    if (excludeCategoryId.HasValue)
                    {
                        command.Parameters.Add(new SqlParameter("@ExcludeCategoryId", SqlDbType.Int) { Value = excludeCategoryId.Value });
                    }

                    return Convert.ToInt32(command.ExecuteScalar()) > 0;
                }
            }
        }

        public int GetProductCountByCategory(int categoryId)
        {
            using (var connection = new SqlConnection(_connectionString))
            {
                connection.Open();
                using (var command = new SqlCommand(@"
                    SELECT COUNT(*) FROM [dbo].[SanPham] 
                    WHERE [MaDanhMuc] = @CategoryId AND [HoatDong] = 1", connection))
                {
                    command.Parameters.Add(new SqlParameter("@CategoryId", SqlDbType.Int) { Value = categoryId });
                    return Convert.ToInt32(command.ExecuteScalar());
                }
            }
        }
    }
}

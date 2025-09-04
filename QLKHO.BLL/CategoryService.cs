using System;
using System.Data;
using QLKHO.DLL;

namespace QLKHO.BLL
{
    public class CategoryService
    {
        private readonly CategoryRepository _repository;

        public CategoryService()
        {
            _repository = new CategoryRepository();
        }

        public DataTable GetAllCategories()
        {
            return _repository.GetAllCategories();
        }

        public DataTable GetCategoryById(int categoryId)
        {
            if (categoryId <= 0)
                throw new ArgumentException("ID danh mục không hợp lệ", nameof(categoryId));
                
            return _repository.GetCategoryById(categoryId);
        }

        public DataTable GetParentCategories()
        {
            return _repository.GetParentCategories();
        }

        public DataTable GetSubCategories(int parentCategoryId)
        {
            if (parentCategoryId <= 0)
                throw new ArgumentException("ID danh mục cha không hợp lệ", nameof(parentCategoryId));
                
            return _repository.GetSubCategories(parentCategoryId);
        }

        public DataTable SearchCategories(string searchTerm)
        {
            if (string.IsNullOrWhiteSpace(searchTerm))
                return GetAllCategories();
                
            return _repository.SearchCategories(searchTerm);
        }

        public int AddCategory(string maDanhMucCode, string tenDanhMuc, string moTa, int? maDanhMucCha, int maNguoiDungTao)
        {
            // Validation
            if (string.IsNullOrWhiteSpace(maDanhMucCode))
                throw new ArgumentException("Mã danh mục không được để trống", nameof(maDanhMucCode));
                
            if (string.IsNullOrWhiteSpace(tenDanhMuc))
                throw new ArgumentException("Tên danh mục không được để trống", nameof(tenDanhMuc));
                
            if (maDanhMucCode.Length > 20)
                throw new ArgumentException("Mã danh mục không được vượt quá 20 ký tự", nameof(maDanhMucCode));
                
            if (tenDanhMuc.Length > 100)
                throw new ArgumentException("Tên danh mục không được vượt quá 100 ký tự", nameof(tenDanhMuc));
                
            if (!string.IsNullOrEmpty(moTa) && moTa.Length > 500)
                throw new ArgumentException("Mô tả không được vượt quá 500 ký tự", nameof(moTa));

            // Kiểm tra mã danh mục đã tồn tại chưa
            if (_repository.IsCategoryCodeExists(maDanhMucCode))
                throw new InvalidOperationException("Mã danh mục đã tồn tại trong hệ thống");

            // Kiểm tra danh mục cha có tồn tại không
            if (maDanhMucCha.HasValue)
            {
                var parentCategory = _repository.GetCategoryById(maDanhMucCha.Value);
                if (parentCategory.Rows.Count == 0)
                    throw new InvalidOperationException("Danh mục cha không tồn tại");
            }

            return _repository.AddCategory(maDanhMucCode, tenDanhMuc, moTa, maDanhMucCha, maNguoiDungTao);
        }

        public bool UpdateCategory(int maDanhMuc, string maDanhMucCode, string tenDanhMuc, string moTa, int? maDanhMucCha, int maNguoiDungSua)
        {
            // Validation
            if (maDanhMuc <= 0)
                throw new ArgumentException("ID danh mục không hợp lệ", nameof(maDanhMuc));
                
            if (string.IsNullOrWhiteSpace(maDanhMucCode))
                throw new ArgumentException("Mã danh mục không được để trống", nameof(maDanhMucCode));
                
            if (string.IsNullOrWhiteSpace(tenDanhMuc))
                throw new ArgumentException("Tên danh mục không được để trống", nameof(tenDanhMuc));
                
            if (maDanhMucCode.Length > 20)
                throw new ArgumentException("Mã danh mục không được vượt quá 20 ký tự", nameof(maDanhMucCode));
                
            if (tenDanhMuc.Length > 100)
                throw new ArgumentException("Tên danh mục không được vượt quá 100 ký tự", nameof(tenDanhMuc));
                
            if (!string.IsNullOrEmpty(moTa) && moTa.Length > 500)
                throw new ArgumentException("Mô tả không được vượt quá 500 ký tự", nameof(moTa));

            // Kiểm tra danh mục có tồn tại không
            var existingCategory = _repository.GetCategoryById(maDanhMuc);
            if (existingCategory.Rows.Count == 0)
                throw new InvalidOperationException("Danh mục không tồn tại");

            // Kiểm tra mã danh mục đã tồn tại chưa (trừ danh mục hiện tại)
            if (_repository.IsCategoryCodeExists(maDanhMucCode, maDanhMuc))
                throw new InvalidOperationException("Mã danh mục đã tồn tại trong hệ thống");

            // Kiểm tra danh mục cha có tồn tại không
            if (maDanhMucCha.HasValue)
            {
                if (maDanhMucCha.Value == maDanhMuc)
                    throw new InvalidOperationException("Danh mục không thể là cha của chính nó");
                    
                var parentCategory = _repository.GetCategoryById(maDanhMucCha.Value);
                if (parentCategory.Rows.Count == 0)
                    throw new InvalidOperationException("Danh mục cha không tồn tại");
            }

            return _repository.UpdateCategory(maDanhMuc, maDanhMucCode, tenDanhMuc, moTa, maDanhMucCha, maNguoiDungSua);
        }

        public bool DeleteCategory(int maDanhMuc)
        {
            if (maDanhMuc <= 0)
                throw new ArgumentException("ID danh mục không hợp lệ", nameof(maDanhMuc));

            // Kiểm tra danh mục có tồn tại không
            var existingCategory = _repository.GetCategoryById(maDanhMuc);
            if (existingCategory.Rows.Count == 0)
                throw new InvalidOperationException("Danh mục không tồn tại");

            // Kiểm tra có sản phẩm nào thuộc danh mục này không
            var productCount = _repository.GetProductCountByCategory(maDanhMuc);
            if (productCount > 0)
                throw new InvalidOperationException($"Không thể xóa danh mục vì có {productCount} sản phẩm thuộc danh mục này");

            // Kiểm tra có danh mục con nào không
            var subCategories = _repository.GetSubCategories(maDanhMuc);
            if (subCategories.Rows.Count > 0)
                throw new InvalidOperationException("Không thể xóa danh mục vì có danh mục con");

            return _repository.DeleteCategory(maDanhMuc);
        }



        public bool IsCategoryActive(int categoryId)
        {
            if (categoryId <= 0) return false;
            
            var category = GetCategoryById(categoryId);
            if (category.Rows.Count == 0) return false;
            
            return Convert.ToBoolean(category.Rows[0]["Hoạt Động"]);
        }

        public string GetCategoryFullPath(int categoryId)
        {
            if (categoryId <= 0) return string.Empty;
            
            var category = GetCategoryById(categoryId);
            if (category.Rows.Count == 0) return string.Empty;
            
            var currentCategory = category.Rows[0];
            var path = currentCategory["Tên Danh Mục"].ToString();
            
            var parentId = currentCategory["Danh Mục Cha"];
            if (parentId != DBNull.Value)
            {
                var parentPath = GetCategoryFullPath(Convert.ToInt32(parentId));
                if (!string.IsNullOrEmpty(parentPath))
                {
                    path = parentPath + " > " + path;
                }
            }
            
            return path;
        }
    }
}

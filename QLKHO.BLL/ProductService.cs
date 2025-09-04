using System;
using System.Data;
using QLKHO.DLL;

namespace QLKHO.BLL
{
    public class ProductService
    {
        private readonly ProductRepository _repository;

        public ProductService()
        {
            _repository = new ProductRepository();
        }

        public DataTable GetAllProducts()
        {
            return _repository.GetAllProducts();
        }

        public DataTable GetProductsByCategory(int categoryId)
        {
            return _repository.GetProductsByCategory(categoryId);
        }

        public DataTable GetProductsWithStock()
        {
            return _repository.GetProductsWithStock();
        }

        public DataTable GetAllCategories()
        {
            return _repository.GetAllCategories();
        }

        public DataTable GetAllSuppliers()
        {
            return _repository.GetAllSuppliers();
        }

        public DataTable SearchProducts(string searchTerm)
        {
            if (string.IsNullOrWhiteSpace(searchTerm))
                return GetAllProducts();
                
            return _repository.SearchProducts(searchTerm);
        }

        public int AddProduct(string productCode, string productName, int? categoryId, int? supplierId, 
            string description, string unit, decimal costPrice, decimal unitPrice, int userId)
        {
            // Validation
            if (string.IsNullOrWhiteSpace(productCode))
                throw new ArgumentException("Mã sản phẩm không được để trống");
            
            if (string.IsNullOrWhiteSpace(productName))
                throw new ArgumentException("Tên sản phẩm không được để trống");
            
            if (string.IsNullOrWhiteSpace(unit))
                throw new ArgumentException("Đơn vị tính không được để trống");
            
            if (costPrice < 0)
                throw new ArgumentException("Giá nhập không được âm");
            
            if (unitPrice < 0)
                throw new ArgumentException("Giá bán không được âm");

            return _repository.AddProduct(productCode, productName, categoryId, supplierId, 
                description, unit, costPrice, unitPrice, userId);
        }

        public bool UpdateProduct(int productId, string productCode, string productName, int? categoryId, int? supplierId, 
            string description, string unit, decimal costPrice, decimal unitPrice, int userId)
        {
            // Validation
            if (productId <= 0)
                throw new ArgumentException("ID sản phẩm không hợp lệ");
            
            if (string.IsNullOrWhiteSpace(productCode))
                throw new ArgumentException("Mã sản phẩm không được để trống");
            
            if (string.IsNullOrWhiteSpace(productName))
                throw new ArgumentException("Tên sản phẩm không được để trống");
            
            if (string.IsNullOrWhiteSpace(unit))
                throw new ArgumentException("Đơn vị tính không được để trống");
            
            if (costPrice < 0)
                throw new ArgumentException("Giá nhập không được âm");
            
            if (unitPrice < 0)
                throw new ArgumentException("Giá bán không được âm");

            return _repository.UpdateProduct(productId, productCode, productName, categoryId, supplierId, 
                description, unit, costPrice, unitPrice, userId);
        }

        public bool DeleteProduct(int productId)
        {
            if (productId <= 0)
                throw new ArgumentException("ID sản phẩm không hợp lệ");

            return _repository.DeleteProduct(productId);
        }

        public DataRow GetProductByCode(string productCode)
        {
            if (string.IsNullOrWhiteSpace(productCode))
                throw new ArgumentException("Mã sản phẩm không được để trống");

            var products = _repository.GetProductByCode(productCode);
            if (products != null && products.Rows.Count > 0)
            {
                return products.Rows[0];
            }
            return null;
        }

        public DataTable SearchProductsInCategory(string searchTerm, int categoryId)
        {
            return _repository.SearchProductsInCategory(searchTerm, categoryId);
        }

        public DataTable GetLowStockProducts()
        {
            var allProducts = GetProductsWithStock();
            var lowStockProducts = allProducts.Clone();
            
            foreach (DataRow row in allProducts.Rows)
            {
                var soLuongTon = Convert.ToDecimal(row["TongSoLuongTon"]);
                var mucTonKhoToiThieu = row["MucTonKhoToiThieu"] != DBNull.Value 
                    ? Convert.ToDecimal(row["MucTonKhoToiThieu"]) 
                    : 0;
                var diemDatHangLai = row["DiemDatHangLai"] != DBNull.Value 
                    ? Convert.ToDecimal(row["DiemDatHangLai"]) 
                    : 0;

                if (soLuongTon <= diemDatHangLai)
                {
                    lowStockProducts.ImportRow(row);
                }
            }
            
            return lowStockProducts;
        }

        public DataTable GetProductsByPriceRange(decimal minPrice, decimal maxPrice)
        {
            var allProducts = GetAllProducts();
            var filteredProducts = allProducts.Clone();
            
            foreach (DataRow row in allProducts.Rows)
            {
                var giaBan = row["GiaBan"] != DBNull.Value 
                    ? Convert.ToDecimal(row["GiaBan"]) 
                    : 0;
                
                if (giaBan >= minPrice && giaBan <= maxPrice)
                {
                    filteredProducts.ImportRow(row);
                }
            }
            
            return filteredProducts;
        }
    }
}

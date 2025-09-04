using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using QLKHO.BLL;

namespace QLKHO.GUI
{
    public partial class FrmSanPham : Form
    {
        private ProductService _productService;
        private DataTable _products;
        private int _currentProductId = 0;
        private bool _isEditMode = false;
        private int _currentUserId = 1; // Tạm thời hardcode, sau này sẽ lấy từ login

        public FrmSanPham()
        {
            InitializeComponent();
            _productService = new ProductService();
        }

        private void FrmSanPham_Load(object sender, EventArgs e)
        {
            try
            {
                LoadProducts();
                LoadCategories();
                LoadSuppliers();
                LoadUnits(); // Load đơn vị tính
                SetupDataGridView();
                ClearForm();
                SetupFormValidation();
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi tải dữ liệu sản phẩm: " + ex.Message, "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void SetupFormValidation()
        {
            // Thêm validation cho các textbox
            txtProductCode.MaxLength = 50;
            txtProductName.MaxLength = 200;
            txtDescription.MaxLength = 1000;

            
            // Thêm tooltip
            toolTip1.SetToolTip(txtProductCode, "Mã sản phẩm tối đa 50 ký tự, không được trùng lặp");
            toolTip1.SetToolTip(txtProductName, "Tên sản phẩm tối đa 200 ký tự");
            toolTip1.SetToolTip(txtDescription, "Mô tả tối đa 1000 ký tự (không bắt buộc)");
            toolTip1.SetToolTip(cboCategory, "Chọn danh mục cho sản phẩm");
            toolTip1.SetToolTip(cboSupplier, "Chọn nhà cung cấp cho sản phẩm");
            toolTip1.SetToolTip(cboUnit, "Chọn đơn vị tính cho sản phẩm");
            toolTip1.SetToolTip(txtCostPrice, "Giá nhập vào (số dương)");
            toolTip1.SetToolTip(txtUnitPrice, "Giá bán ra (số dương)");
        }

        private void LoadProducts()
        {
            try
            {
                Cursor = Cursors.WaitCursor;
                _products = _productService.GetAllProducts();
                dataGridView1.DataSource = _products;
                
                // Ẩn các cột nội bộ sau khi set DataSource
                HideInternalColumns();
                
                lblProductCount.Text = $"Tổng: {_products.Rows.Count} sản phẩm";
                
                // Cập nhật trạng thái nút
                UpdateButtonStates();
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi tải danh sách sản phẩm: " + ex.Message, "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            finally
            {
                Cursor = Cursors.Default;
            }
        }

        private void LoadCategories()
        {
            try
            {
                var categories = _productService.GetAllCategories();
                cboCategory.Items.Clear();
                cboCategory.Items.Add(new ProductComboBoxItem { Text = "-- Chọn danh mục --", Value = -1 });
                
                foreach (DataRow row in categories.Rows)
                {
                    cboCategory.Items.Add(new ProductComboBoxItem 
                    { 
                        Text = row["TenDanhMuc"].ToString(), 
                        Value = Convert.ToInt32(row["MaDanhMuc"]) 
                    });
                }
                cboCategory.SelectedIndex = 0;
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi tải danh mục: " + ex.Message, "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void LoadSuppliers()
        {
            try
            {
                var suppliers = _productService.GetAllSuppliers();
                cboSupplier.Items.Clear();
                cboSupplier.Items.Add(new ProductComboBoxItem { Text = "-- Chọn nhà cung cấp --", Value = -1 });
                
                foreach (DataRow row in suppliers.Rows)
                {
                    cboSupplier.Items.Add(new ProductComboBoxItem 
                    { 
                        Text = row["TenNhaCungCap"].ToString(), 
                        Value = Convert.ToInt32(row["MaNhaCungCap"]) 
                    });
                }
                cboSupplier.SelectedIndex = 0;
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi tải nhà cung cấp: " + ex.Message, "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }





        private void LoadUnits()
        {
            try
            {
                cboUnit.Items.Clear();
                cboUnit.Items.Add(new ProductComboBoxItem { Text = "-- Chọn đơn vị --", Value = -1 });
                
                // Danh sách đơn vị tính phổ biến
                var commonUnits = new[] 
                {
                    "Cái", "Chiếc", "Bộ", "Cặp", "Bao", "Gói", "Hộp", "Thùng", "Kg", "Gram", 
                    "Tấn", "Lít", "Ml", "Mét", "Cm", "Mm", "M2", "M3", "Cuộn", "Tờ"
                };
                
                for (int i = 0; i < commonUnits.Length; i++)
                {
                    cboUnit.Items.Add(new ProductComboBoxItem 
                    { 
                        Text = commonUnits[i], 
                        Value = i + 1 
                    });
                }
                
                cboUnit.SelectedIndex = 0;
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi tải danh sách đơn vị tính: " + ex.Message, "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void SetupDataGridView()
        {
            dataGridView1.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill;
            dataGridView1.AllowUserToAddRows = false;
            dataGridView1.AllowUserToDeleteRows = false;
            dataGridView1.ReadOnly = true;
            dataGridView1.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            dataGridView1.MultiSelect = false;
            dataGridView1.SelectionChanged += DataGridView1_SelectionChanged;
        }

        private void HideInternalColumns()
        {
            // Ẩn các cột nội bộ không cần hiển thị
            if (dataGridView1.Columns.Count > 0)
            {
                // Ẩn cột MaSanPham (ID nội bộ)
                if (dataGridView1.Columns.Contains("MaSanPham"))
                {
                    dataGridView1.Columns["MaSanPham"].Visible = false;
                }
                
                // Ẩn cột MaDanhMuc (mã danh mục nội bộ)
                if (dataGridView1.Columns.Contains("MaDanhMuc"))
                {
                    dataGridView1.Columns["MaDanhMuc"].Visible = false;
                }
                
                // Ẩn cột MaNhaCungCap (mã nhà cung cấp nội bộ)
                if (dataGridView1.Columns.Contains("MaNhaCungCap"))
                {
                    dataGridView1.Columns["MaNhaCungCap"].Visible = false;
                }
            }
        }

        private void DataGridView1_SelectionChanged(object sender, EventArgs e)
        {
            if (dataGridView1.SelectedRows.Count > 0)
            {
                var selectedRow = dataGridView1.SelectedRows[0];
                LoadProductToForm(selectedRow);
            }
        }

        private void LoadProductToForm(DataGridViewRow row)
        {
            try
            {
                _currentProductId = Convert.ToInt32(row.Cells["MaSanPham"].Value);
                
                txtProductCode.Text = row.Cells["MaSanPhamCode"].Value.ToString();
                txtProductName.Text = row.Cells["TenSanPham"].Value.ToString();
                txtDescription.Text = row.Cells["MoTa"].Value?.ToString() ?? "";
                // Xử lý đơn vị tính
                var unit = row.Cells["DonViTinh"].Value?.ToString() ?? "";
                if (!string.IsNullOrEmpty(unit))
                {
                    for (int i = 0; i < cboUnit.Items.Count; i++)
                    {
                        var item = cboUnit.Items[i] as ProductComboBoxItem;
                        if (item != null && item.Text == unit)
                        {
                            cboUnit.SelectedIndex = i;
                            break;
                        }
                    }
                }
                else
                {
                    cboUnit.SelectedIndex = 0;
                }
                txtCostPrice.Text = row.Cells["GiaVon"].Value?.ToString() ?? "";
                txtUnitPrice.Text = row.Cells["GiaBan"].Value?.ToString() ?? "";
                
                // Xử lý danh mục
                var categoryId = row.Cells["MaDanhMuc"].Value;
                if (categoryId != DBNull.Value)
                {
                    for (int i = 0; i < cboCategory.Items.Count; i++)
                    {
                        var item = cboCategory.Items[i] as ProductComboBoxItem;
                        if (item != null && item.Value == Convert.ToInt32(categoryId))
                        {
                            cboCategory.SelectedIndex = i;
                            break;
                        }
                    }
                }
                else
                {
                    cboCategory.SelectedIndex = 0;
                }
                
                // Xử lý nhà cung cấp
                var supplierId = row.Cells["MaNhaCungCap"].Value;
                if (supplierId != DBNull.Value)
                {
                    for (int i = 0; i < cboSupplier.Items.Count; i++)
                    {
                        var item = cboSupplier.Items[i] as ProductComboBoxItem;
                        if (item != null && item.Value == Convert.ToInt32(supplierId))
                        {
                            cboSupplier.SelectedIndex = i;
                            break;
                        }
                    }
                }
                else
                {
                    cboSupplier.SelectedIndex = 0;
                }

                _isEditMode = true;
                UpdateButtonStates();
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi tải thông tin sản phẩm: " + ex.Message, "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void UpdateButtonStates()
        {
            btnAdd.Text = _isEditMode ? "Cập nhật" : "Thêm mới";
            btnAdd.BackColor = _isEditMode ? System.Drawing.Color.LightBlue : System.Drawing.Color.LightGreen;
            btnClear.Text = _isEditMode ? "Hủy" : "Làm mới";
            btnDelete.Enabled = _isEditMode;
            
            // Cập nhật tooltip
            toolTip1.SetToolTip(btnAdd, _isEditMode ? "Cập nhật thông tin sản phẩm đã chọn" : "Thêm sản phẩm mới vào hệ thống");
            toolTip1.SetToolTip(btnDelete, "Xóa sản phẩm đã chọn (chỉ xóa được khi không có đơn hàng liên quan)");
        }

        private void btnAdd_Click(object sender, EventArgs e)
        {
            try
            {
                if (ValidateForm())
                {
                    Cursor = Cursors.WaitCursor;
                    
                    var productCode = txtProductCode.Text.Trim();
                    var productName = txtProductName.Text.Trim();
                    var description = txtDescription.Text.Trim();
                    var selectedUnit = cboUnit.SelectedItem as ProductComboBoxItem;
                    string unit = "";
                    if (selectedUnit != null && selectedUnit.Value != -1)
                    {
                        unit = selectedUnit.Text;
                    }
                    
                    decimal costPrice = 0, unitPrice = 0;
                    if (!decimal.TryParse(txtCostPrice.Text.Trim(), out costPrice))
                    {
                        MessageBox.Show("Giá nhập không hợp lệ! Vui lòng nhập số dương.", "Cảnh báo", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                        txtCostPrice.Focus();
                        return;
                    }
                    
                    if (!decimal.TryParse(txtUnitPrice.Text.Trim(), out unitPrice))
                    {
                        MessageBox.Show("Giá bán không hợp lệ! Vui lòng nhập số dương.", "Cảnh báo", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                        txtUnitPrice.Focus();
                        return;
                    }
                    
                    var selectedCategory = cboCategory.SelectedItem as ProductComboBoxItem;
                    int? categoryId = null;
                    if (selectedCategory != null && selectedCategory.Value != -1)
                    {
                        categoryId = selectedCategory.Value;
                    }
                    
                    var selectedSupplier = cboSupplier.SelectedItem as ProductComboBoxItem;
                    int? supplierId = null;
                    if (selectedSupplier != null && selectedSupplier.Value != -1)
                    {
                        supplierId = selectedSupplier.Value;
                    }

                    // Kiểm tra lại một lần nữa để đảm bảo an toàn
                    if (categoryId == null)
                    {
                        MessageBox.Show("Vui lòng chọn danh mục cho sản phẩm!", "Cảnh báo", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                        cboCategory.Focus();
                        return;
                    }

                    if (supplierId == null)
                    {
                        MessageBox.Show("Vui lòng chọn nhà cung cấp cho sản phẩm!", "Cảnh báo", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                        cboSupplier.Focus();
                        return;
                    }

                    if (_isEditMode)
                    {
                        // Cập nhật sản phẩm
                        if (_productService.UpdateProduct(_currentProductId, productCode, productName, categoryId, supplierId, 
                            description, unit, costPrice, unitPrice, _currentUserId))
                        {
                            MessageBox.Show("Cập nhật sản phẩm thành công!", "Thành công", MessageBoxButtons.OK, MessageBoxIcon.Information);
                            LoadProducts();
                            LoadCategories();
                            LoadSuppliers();
                            ClearForm();
                        }
                        else
                        {
                            MessageBox.Show("Cập nhật sản phẩm thất bại! Vui lòng kiểm tra lại thông tin.", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
                        }
                    }
                    else
                    {
                        // Kiểm tra mã sản phẩm trùng lặp trước khi thêm
                        if (IsProductCodeExists(productCode))
                        {
                            MessageBox.Show($"Mã sản phẩm '{productCode}' đã tồn tại trong hệ thống!\n\nVui lòng chọn mã sản phẩm khác.", 
                                "Mã sản phẩm trùng lặp", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                            txtProductCode.Focus();
                            txtProductCode.SelectAll();
                            return;
                        }

                        // Thêm sản phẩm mới
                        var newProductId = _productService.AddProduct(productCode, productName, categoryId, supplierId, 
                            description, unit, costPrice, unitPrice, _currentUserId);
                        if (newProductId > 0)
                        {
                            MessageBox.Show($"Thêm sản phẩm thành công!\n\nMã sản phẩm: {productCode}\nTên sản phẩm: {productName}\nDanh mục: {selectedCategory.Text}\nNhà cung cấp: {selectedSupplier.Text}", 
                                "Thành công", MessageBoxButtons.OK, MessageBoxIcon.Information);
                            LoadProducts();
                            LoadCategories();
                            LoadSuppliers();
                            ClearForm();
                        }
                        else
                        {
                            MessageBox.Show("Thêm sản phẩm thất bại! Vui lòng kiểm tra lại thông tin và thử lại.", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
                        }
                    }
                }
            }
            catch (ArgumentException ex)
            {
                // Xử lý các lỗi validation từ Business Logic Layer
                var errorMessage = ex.Message;
                if (errorMessage.Contains("Mã sản phẩm"))
                {
                    MessageBox.Show($"Lỗi mã sản phẩm: {errorMessage}\n\nVui lòng kiểm tra lại mã sản phẩm.", 
                        "Lỗi dữ liệu", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    txtProductCode.Focus();
                    txtProductCode.SelectAll();
                }
                else if (errorMessage.Contains("Tên sản phẩm"))
                {
                    MessageBox.Show($"Lỗi tên sản phẩm: {errorMessage}\n\nVui lòng kiểm tra lại tên sản phẩm.", 
                        "Lỗi dữ liệu", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    txtProductName.Focus();
                    txtProductName.SelectAll();
                }
                else if (errorMessage.Contains("đơn vị tính"))
                {
                    MessageBox.Show($"Lỗi đơn vị tính: {errorMessage}\n\nVui lòng kiểm tra lại đơn vị tính.", 
                        "Lỗi dữ liệu", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    cboUnit.Focus();
                }
                else if (errorMessage.Contains("Giá"))
                {
                    MessageBox.Show($"Lỗi giá: {errorMessage}\n\nVui lòng kiểm tra lại giá nhập và giá bán.", 
                        "Lỗi dữ liệu", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    txtCostPrice.Focus();
                    txtCostPrice.SelectAll();
                }
                else
                {
                    MessageBox.Show($"Dữ liệu không hợp lệ: {errorMessage}\n\nVui lòng kiểm tra lại thông tin nhập vào.", 
                        "Lỗi dữ liệu", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                }
            }
            catch (InvalidOperationException ex)
            {
                // Xử lý các lỗi nghiệp vụ
                var errorMessage = ex.Message;
                if (errorMessage.Contains("không tồn tại"))
                {
                    MessageBox.Show($"Lỗi nghiệp vụ: {errorMessage}\n\nVui lòng làm mới dữ liệu và thử lại.", 
                        "Lỗi nghiệp vụ", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    LoadProducts();
                    LoadCategories();
                    LoadSuppliers();
                }
                else
                {
                    MessageBox.Show($"Không thể thực hiện thao tác: {errorMessage}\n\nVui lòng kiểm tra lại và thử lại.", 
                        "Lỗi nghiệp vụ", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                }
            }
            catch (Exception ex)
            {
                // Xử lý các lỗi hệ thống không mong muốn
                var errorMessage = ex.Message;
                if (errorMessage.Contains("connection") || errorMessage.Contains("database") || 
                    errorMessage.Contains("network") || errorMessage.Contains("timeout"))
                {
                    MessageBox.Show($"Lỗi kết nối cơ sở dữ liệu!\n\nChi tiết: {errorMessage}\n\nVui lòng kiểm tra kết nối mạng và thử lại.", 
                        "Lỗi kết nối", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
                else
                {
                    MessageBox.Show($"Đã xảy ra lỗi không mong muốn!\n\nChi tiết: {errorMessage}\n\nVui lòng liên hệ quản trị viên để được hỗ trợ.", 
                        "Lỗi hệ thống", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }
            finally
            {
                Cursor = Cursors.Default;
            }
        }

        private bool ValidateForm()
        {
            // Kiểm tra mã sản phẩm
            if (string.IsNullOrWhiteSpace(txtProductCode.Text.Trim()))
            {
                MessageBox.Show("Vui lòng nhập mã sản phẩm!", "Cảnh báo", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                txtProductCode.Focus();
                return false;
            }

            if (txtProductCode.Text.Trim().Length > 50)
            {
                MessageBox.Show("Mã sản phẩm không được vượt quá 50 ký tự!", "Cảnh báo", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                txtProductCode.Focus();
                return false;
            }

            // Kiểm tra tên sản phẩm
            if (string.IsNullOrWhiteSpace(txtProductName.Text.Trim()))
            {
                MessageBox.Show("Vui lòng nhập tên sản phẩm!", "Cảnh báo", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                txtProductName.Focus();
                return false;
            }

            if (txtProductName.Text.Trim().Length > 200)
            {
                MessageBox.Show("Tên sản phẩm không được vượt quá 200 ký tự!", "Cảnh báo", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                txtProductName.Focus();
                return false;
            }

            // Kiểm tra mô tả
            if (txtDescription.Text.Trim().Length > 1000)
            {
                MessageBox.Show("Mô tả không được vượt quá 1000 ký tự!", "Cảnh báo", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                txtDescription.Focus();
                return false;
            }

            // Kiểm tra danh mục
            var selectedCategory = cboCategory.SelectedItem as ProductComboBoxItem;
            if (selectedCategory == null || selectedCategory.Value == -1)
            {
                MessageBox.Show("Vui lòng chọn danh mục cho sản phẩm!", "Cảnh báo", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                cboCategory.Focus();
                return false;
            }

            // Kiểm tra nhà cung cấp
            var selectedSupplier = cboSupplier.SelectedItem as ProductComboBoxItem;
            if (selectedSupplier == null || selectedSupplier.Value == -1)
            {
                MessageBox.Show("Vui lòng chọn nhà cung cấp cho sản phẩm!", "Cảnh báo", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                cboSupplier.Focus();
                return false;
            }

            // Kiểm tra đơn vị tính
            var selectedUnit = cboUnit.SelectedItem as ProductComboBoxItem;
            if (selectedUnit == null || selectedUnit.Value == -1)
            {
                MessageBox.Show("Vui lòng chọn đơn vị tính cho sản phẩm!", "Cảnh báo", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                cboUnit.Focus();
                return false;
            }

            // Kiểm tra giá
            decimal costPrice, unitPrice;
            if (!decimal.TryParse(txtCostPrice.Text.Trim(), out costPrice) || costPrice < 0)
            {
                MessageBox.Show("Giá nhập phải là số dương!", "Cảnh báo", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                txtCostPrice.Focus();
                return false;
            }

            if (!decimal.TryParse(txtUnitPrice.Text.Trim(), out unitPrice) || unitPrice < 0)
            {
                MessageBox.Show("Giá bán phải là số dương!", "Cảnh báo", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                txtUnitPrice.Focus();
                return false;
            }

            // Kiểm tra giá bán phải cao hơn giá nhập
            if (unitPrice <= costPrice)
            {
                MessageBox.Show("Giá bán phải cao hơn giá nhập để có lợi nhuận!", "Cảnh báo", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                txtUnitPrice.Focus();
                txtUnitPrice.SelectAll();
                return false;
            }

            return true;
        }

        private bool IsProductCodeExists(string productCode)
        {
            try
            {
                var existingProduct = _productService.GetProductByCode(productCode);
                if (existingProduct != null)
                {
                    // Truy cập cột MaSanPham thông qua indexer
                    var maSanPham = existingProduct["MaSanPham"];
                    if (maSanPham != DBNull.Value)
                    {
                        return Convert.ToInt32(maSanPham) > 0; // Nếu tìm thấy và có ID, là trùng
                    }
                }
                return false; // Không tìm thấy hoặc không có ID
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi kiểm tra mã sản phẩm trùng lặp: " + ex.Message, "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return false; // Trả về false để tránh lỗi hệ thống
            }
        }

        private void btnDelete_Click(object sender, EventArgs e)
        {
            if (_currentProductId <= 0)
            {
                MessageBox.Show("Vui lòng chọn sản phẩm cần xóa!", "Cảnh báo", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            var result = MessageBox.Show("Bạn có chắc chắn muốn xóa sản phẩm này?\n\nLưu ý: Chỉ có thể xóa sản phẩm không có đơn hàng liên quan.", 
                "Xác nhận xóa", MessageBoxButtons.YesNo, MessageBoxIcon.Question);
            
            if (result == DialogResult.Yes)
            {
                try
                {
                    Cursor = Cursors.WaitCursor;
                    
                    if (_productService.DeleteProduct(_currentProductId))
                    {
                        MessageBox.Show("Xóa sản phẩm thành công!", "Thành công", MessageBoxButtons.OK, MessageBoxIcon.Information);
                        LoadProducts();
                        LoadCategories();
                        LoadSuppliers();
                        ClearForm();
                    }
                    else
                    {
                        MessageBox.Show("Xóa sản phẩm thất bại!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    }
                }
                catch (InvalidOperationException ex)
                {
                    MessageBox.Show("Không thể xóa sản phẩm: " + ex.Message, "Cảnh báo", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                }
                catch (Exception ex)
                {
                    MessageBox.Show("Lỗi: " + ex.Message, "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
                finally
                {
                    Cursor = Cursors.Default;
                }
            }
        }

        private void btnClear_Click(object sender, EventArgs e)
        {
            ClearForm();
        }

        private void ClearForm()
        {
            _currentProductId = 0;
            _isEditMode = false;
            txtProductCode.Clear();
            txtProductName.Clear();
            txtDescription.Clear();
            cboUnit.SelectedIndex = 0;
            txtCostPrice.Clear();
            txtUnitPrice.Clear();
            cboCategory.SelectedIndex = 0;
            cboSupplier.SelectedIndex = 0;
            UpdateButtonStates();
            txtProductCode.Focus();
            
            // Bỏ chọn trong DataGridView
            if (dataGridView1.SelectedRows.Count > 0)
            {
                dataGridView1.ClearSelection();
            }
        }

        private void btnSearch_Click(object sender, EventArgs e)
        {
            try
            {
                var searchTerm = txtSearch.Text.Trim();
                if (string.IsNullOrEmpty(searchTerm))
                {
                    // Nếu không có từ khóa tìm kiếm, hiển thị tất cả sản phẩm
                    LoadProducts();
                    return;
                }

                Cursor = Cursors.WaitCursor;
                
                // Tìm kiếm toàn bộ
                var searchResults = _productService.SearchProducts(searchTerm);
                dataGridView1.DataSource = searchResults;
                
                // Ẩn các cột nội bộ sau khi set DataSource
                HideInternalColumns();
                
                lblProductCount.Text = $"Tìm thấy: {searchResults.Rows.Count} sản phẩm";
                
                if (searchResults.Rows.Count == 0)
                {
                    MessageBox.Show($"Không tìm thấy sản phẩm nào phù hợp với từ khóa '{searchTerm}'.\n\nVui lòng thử từ khóa khác hoặc kiểm tra chính tả.", 
                        "Không tìm thấy", MessageBoxButtons.OK, MessageBoxIcon.Information);
                }
                
                // Cập nhật trạng thái nút
                UpdateButtonStates();
            }
            catch (ArgumentException ex)
            {
                MessageBox.Show($"Từ khóa tìm kiếm không hợp lệ: {ex.Message}\n\nVui lòng nhập từ khóa khác.", 
                    "Từ khóa không hợp lệ", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                txtSearch.Focus();
                txtSearch.SelectAll();
            }
            catch (Exception ex)
            {
                var errorMessage = ex.Message;
                if (errorMessage.Contains("connection") || errorMessage.Contains("database") || 
                    errorMessage.Contains("network") || errorMessage.Contains("timeout"))
                {
                    MessageBox.Show($"Lỗi kết nối cơ sở dữ liệu!\n\nChi tiết: {errorMessage}\n\nVui lòng kiểm tra kết nối mạng và thử lại.", 
                        "Lỗi kết nối", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
                else
                {
                    MessageBox.Show($"Lỗi tìm kiếm: {errorMessage}\n\nVui lòng thử lại hoặc liên hệ quản trị viên.", 
                        "Lỗi tìm kiếm", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }
            finally
            {
                Cursor = Cursors.Default;
            }
        }

        private void btnRefresh_Click(object sender, EventArgs e)
        {
            try
            {
                txtSearch.Clear();
                LoadProducts();
                LoadCategories();
                LoadSuppliers();
                LoadUnits(); // Làm mới đơn vị tính
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi làm mới dữ liệu: " + ex.Message, "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        // Xử lý sự kiện Enter key trong textbox tìm kiếm
        private void txtSearch_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == (char)Keys.Enter)
            {
                e.Handled = true;
                btnSearch_Click(sender, e);
            }
        }

        // Xử lý sự kiện Enter key trong các textbox khác
        private void txtProductCode_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == (char)Keys.Enter)
            {
                e.Handled = true;
                txtProductName.Focus();
            }
        }

        private void txtProductName_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == (char)Keys.Enter)
            {
                e.Handled = true;
                txtDescription.Focus();
            }
        }

        private void txtDescription_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == (char)Keys.Enter)
            {
                e.Handled = true;
                cboCategory.Focus();
            }
        }

        private void cboCategory_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == (char)Keys.Enter)
            {
                e.Handled = true;
                cboSupplier.Focus();
            }
        }

        private void cboSupplier_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == (char)Keys.Enter)
            {
                e.Handled = true;
                cboUnit.Focus();
            }
        }

        private void cboUnit_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == (char)Keys.Enter)
            {
                e.Handled = true;
                txtCostPrice.Focus();
            }
        }

        private void txtCostPrice_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == (char)Keys.Enter)
            {
                e.Handled = true;
                txtUnitPrice.Focus();
            }
        }

        private void txtUnitPrice_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == (char)Keys.Enter)
            {
                e.Handled = true;
                btnAdd_Click(sender, e);
            }
        }


    }

    // Helper class cho ComboBox
    public class ProductComboBoxItem
    {
        public string Text { get; set; }
        public int Value { get; set; }
        public override string ToString()
        {
            return Text;
        }
    }
}

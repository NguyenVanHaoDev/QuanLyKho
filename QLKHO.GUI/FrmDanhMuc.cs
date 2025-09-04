using System;
using System.Data;
using System.Windows.Forms;
using QLKHO.BLL;

namespace QLKHO.GUI
{
    public partial class FrmDanhMuc : Form
    {
        private CategoryService _categoryService;
        private DataTable _categories;
        private int _currentCategoryId = 0;
        private bool _isEditMode = false;
        private int _currentUserId = 1; // Tạm thời hardcode, sau này sẽ lấy từ login

        public FrmDanhMuc()
        {
            InitializeComponent();
            _categoryService = new CategoryService();
        }

        private void FrmDanhMuc_Load(object sender, EventArgs e)
        {
            try
            {
                LoadCategories();
                LoadParentCategories();
                SetupDataGridView();
                ClearForm();
                SetupFormValidation();
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi tải dữ liệu danh mục: " + ex.Message, "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void SetupFormValidation()
        {
            // Thêm validation cho các textbox
            txtCategoryCode.MaxLength = 20;
            txtCategoryName.MaxLength = 100;
            txtDescription.MaxLength = 500;
            
            // Thêm tooltip
            toolTip1.SetToolTip(txtCategoryCode, "Mã danh mục tối đa 20 ký tự, không được trùng lặp");
            toolTip1.SetToolTip(txtCategoryName, "Tên danh mục tối đa 100 ký tự");
            toolTip1.SetToolTip(txtDescription, "Mô tả tối đa 500 ký tự (không bắt buộc)");
            toolTip1.SetToolTip(cboParentCategory, "Chọn danh mục cha nếu muốn tạo danh mục con");
        }

        private void LoadCategories()
        {
            try
            {
                Cursor = Cursors.WaitCursor;
                _categories = _categoryService.GetAllCategories();
                
                // Hiển thị theo chế độ cascade
                DisplayCategoriesInCascade();
                
                lblCategoryCount.Text = $"Tổng: {_categories.Rows.Count} danh mục";
                
                // Cập nhật trạng thái nút
                UpdateButtonStates();
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi tải danh sách danh mục: " + ex.Message, "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            finally
            {
                Cursor = Cursors.Default;
            }
        }

        private void DisplayCategoriesInCascade()
        {
            try
            {
                // Tạo DataTable mới để hiển thị cascade
                var cascadeTable = new DataTable();
                cascadeTable.Columns.Add("MaDanhMuc", typeof(int));
                cascadeTable.Columns.Add("Mã DM", typeof(string));
                cascadeTable.Columns.Add("Tên Danh Mục", typeof(string));
                cascadeTable.Columns.Add("Mô Tả", typeof(string));
                cascadeTable.Columns.Add("Danh Mục Cha", typeof(string));
                cascadeTable.Columns.Add("Hoạt Động", typeof(string));
                cascadeTable.Columns.Add("Ngày Tạo", typeof(DateTime));
                cascadeTable.Columns.Add("Level", typeof(int)); // Cấp độ để hiển thị thụt đầu

                // Lấy danh mục gốc (không có cha)
                var rootCategories = _categories.Select("[Danh Mục Cha] IS NULL OR [Danh Mục Cha] = ''", "[Tên Danh Mục]");
                
                // Đệ quy thêm danh mục con
                foreach (DataRow rootRow in rootCategories)
                {
                    AddCategoryToCascade(cascadeTable, rootRow, 0);
                }

                dataGridView1.DataSource = cascadeTable;
            }
            catch (Exception ex)
            {
                // Nếu có lỗi, hiển thị bình thường
                dataGridView1.DataSource = _categories;
            }
        }

        private void AddCategoryToCascade(DataTable cascadeTable, DataRow categoryRow, int level)
        {
            // Thêm danh mục hiện tại
            var newRow = cascadeTable.NewRow();
            newRow["MaDanhMuc"] = categoryRow["MaDanhMuc"];
            newRow["Mã DM"] = categoryRow["Mã DM"];
            newRow["Tên Danh Mục"] = GetIndentedName(categoryRow["Tên Danh Mục"].ToString(), level);
            newRow["Mô Tả"] = categoryRow["Mô Tả"];
            newRow["Danh Mục Cha"] = GetParentCategoryDisplay(categoryRow["Danh Mục Cha"]);
            newRow["Hoạt Động"] = GetStatusDisplay(Convert.ToInt32(categoryRow["Hoạt Động"]));
            newRow["Ngày Tạo"] = categoryRow["Ngày Tạo"];
            newRow["Level"] = level;
            cascadeTable.Rows.Add(newRow);

            // Tìm và thêm danh mục con
            var childCategories = _categories.Select($"[Danh Mục Cha] = {categoryRow["MaDanhMuc"]}", "[Tên Danh Mục]");
            foreach (DataRow childRow in childCategories)
            {
                AddCategoryToCascade(cascadeTable, childRow, level + 1);
            }
        }

        private string GetIndentedName(string name, int level)
        {
            if (level == 0) return name;
            
            var indent = new string('　', level * 2); // Sử dụng ký tự space đặc biệt để thụt đầu
            return indent + "├─ " + name;
        }

        private string GetParentCategoryDisplay(object parentId)
        {
            if (parentId == DBNull.Value || parentId == null || string.IsNullOrEmpty(parentId.ToString()))
                return "--";
            
            // Tìm tên danh mục cha
            try
            {
                var parentRow = _categories.Select($"[MaDanhMuc] = {parentId}");
                if (parentRow.Length > 0)
                {
                    return parentRow[0]["Mã DM"].ToString();
                }
            }
            catch { }
            
            return parentId.ToString();
        }

        private string GetStatusDisplay(int status)
        {
            return status == 1 ? "✓ Hoạt động" : "✗ Không hoạt động";
        }

        private void LoadParentCategories()
        {
            try
            {
                var parentCategories = _categoryService.GetParentCategories();
                cboParentCategory.Items.Clear();
                cboParentCategory.Items.Add(new ComboBoxItem { Text = "-- Không có --", Value = -1 });
                
                foreach (DataRow row in parentCategories.Rows)
                {
                    cboParentCategory.Items.Add(new ComboBoxItem 
                    { 
                        Text = row["Tên Danh Mục"].ToString(), 
                        Value = Convert.ToInt32(row["MaDanhMuc"]) 
                    });
                }
                cboParentCategory.SelectedIndex = 0;
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi tải danh mục cha: " + ex.Message, "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
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
            
            // Thêm cột hiển thị đường dẫn đầy đủ
            if (dataGridView1.Columns.Count > 0)
            {
                // Ẩn cột MaDanhMuc (ID nội bộ)
                if (dataGridView1.Columns.Contains("MaDanhMuc"))
                {
                    dataGridView1.Columns["MaDanhMuc"].Visible = false;
                }
                
                dataGridView1.Columns["Mã DM"].Width = 100;
                dataGridView1.Columns["Tên Danh Mục"].Width = 200;
                dataGridView1.Columns["Mô Tả"].Width = 250;
                dataGridView1.Columns["Danh Mục Cha"].Width = 120;
                dataGridView1.Columns["Hoạt Động"].Width = 80;
                dataGridView1.Columns["Ngày Tạo"].Width = 120;
            }
        }



        private void DataGridView1_SelectionChanged(object sender, EventArgs e)
        {
            if (dataGridView1.SelectedRows.Count > 0)
            {
                var selectedRow = dataGridView1.SelectedRows[0];
                LoadCategoryToForm(selectedRow);
            }
        }

        private void LoadCategoryToForm(DataGridViewRow row)
        {
            try
            {
                _currentCategoryId = Convert.ToInt32(row.Cells["MaDanhMuc"].Value);
                
                txtCategoryCode.Text = row.Cells["Mã DM"].Value.ToString();
                
                // Lấy tên danh mục gốc (không có thụt đầu)
                var categoryName = row.Cells["Tên Danh Mục"].Value.ToString();
                if (categoryName.Contains("├─ "))
                {
                    categoryName = categoryName.Substring(categoryName.IndexOf("├─ ") + 3);
                }
                txtCategoryName.Text = categoryName.TrimStart('　'); // Loại bỏ space thụt đầu
                
                txtDescription.Text = row.Cells["Mô Tả"].Value?.ToString() ?? "";
                
                // Xử lý danh mục cha
                var parentDisplay = row.Cells["Danh Mục Cha"].Value?.ToString();
                if (parentDisplay != null && parentDisplay != "--")
                {
                    // Tìm danh mục cha trong ComboBox
                    for (int i = 0; i < cboParentCategory.Items.Count; i++)
                    {
                        var item = cboParentCategory.Items[i] as ComboBoxItem;
                        if (item != null && item.Text.Contains(parentDisplay))
                        {
                            cboParentCategory.SelectedIndex = i;
                            break;
                        }
                    }
                }
                else
                {
                    cboParentCategory.SelectedIndex = 0;
                }

                _isEditMode = true;
                UpdateButtonStates();
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi tải thông tin danh mục: " + ex.Message, "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void UpdateButtonStates()
        {
            btnAdd.Text = _isEditMode ? "Cập nhật" : "Thêm mới";
            btnAdd.BackColor = _isEditMode ? System.Drawing.Color.LightBlue : System.Drawing.Color.LightGreen;
            btnClear.Text = _isEditMode ? "Hủy" : "Làm mới";
            btnDelete.Enabled = _isEditMode;
            
            // Cập nhật tooltip
            toolTip1.SetToolTip(btnAdd, _isEditMode ? "Cập nhật thông tin danh mục đã chọn" : "Thêm danh mục mới vào hệ thống");
            toolTip1.SetToolTip(btnDelete, "Xóa danh mục đã chọn (chỉ xóa được khi không có sản phẩm hoặc danh mục con)");
        }

        private void btnAdd_Click(object sender, EventArgs e)
        {
            try
            {
                if (ValidateForm())
                {
                    Cursor = Cursors.WaitCursor;
                    
                    var categoryCode = txtCategoryCode.Text.Trim();
                    var categoryName = txtCategoryName.Text.Trim();
                    var description = txtDescription.Text.Trim();
                    
                    var selectedItem = cboParentCategory.SelectedItem as ComboBoxItem;
                    int? parentCategoryId = null;
                    if (selectedItem != null && selectedItem.Value != -1)
                    {
                        parentCategoryId = selectedItem.Value;
                    }

                    if (_isEditMode)
                    {
                        // Cập nhật danh mục
                        if (_categoryService.UpdateCategory(_currentCategoryId, categoryCode, categoryName, description, parentCategoryId, _currentUserId))
                        {
                            MessageBox.Show("Cập nhật danh mục thành công!", "Thành công", MessageBoxButtons.OK, MessageBoxIcon.Information);
                            LoadCategories();
                            LoadParentCategories();
                            ClearForm();
                        }
                        else
                        {
                            MessageBox.Show("Cập nhật danh mục thất bại!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
                        }
                    }
                    else
                    {
                        // Thêm danh mục mới
                        var newCategoryId = _categoryService.AddCategory(categoryCode, categoryName, description, parentCategoryId, _currentUserId);
                        if (newCategoryId > 0)
                        {
                            MessageBox.Show($"Thêm danh mục thành công! Mã danh mục: {newCategoryId}", "Thành công", MessageBoxButtons.OK, MessageBoxIcon.Information);
                            LoadCategories();
                            LoadParentCategories();
                            ClearForm();
                        }
                        else
                        {
                            MessageBox.Show("Thêm danh mục thất bại!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
                        }
                    }
                }
            }
            catch (ArgumentException ex)
            {
                MessageBox.Show("Dữ liệu không hợp lệ: " + ex.Message, "Cảnh báo", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
            catch (InvalidOperationException ex)
            {
                MessageBox.Show("Không thể thực hiện thao tác: " + ex.Message, "Cảnh báo", MessageBoxButtons.OK, MessageBoxIcon.Warning);
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

        private bool ValidateForm()
        {
            // Kiểm tra mã danh mục
            if (string.IsNullOrWhiteSpace(txtCategoryCode.Text.Trim()))
            {
                MessageBox.Show("Vui lòng nhập mã danh mục!", "Cảnh báo", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                txtCategoryCode.Focus();
                return false;
            }

            if (txtCategoryCode.Text.Trim().Length > 20)
            {
                MessageBox.Show("Mã danh mục không được vượt quá 20 ký tự!", "Cảnh báo", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                txtCategoryCode.Focus();
                return false;
            }

            // Kiểm tra tên danh mục
            if (string.IsNullOrWhiteSpace(txtCategoryName.Text.Trim()))
            {
                MessageBox.Show("Vui lòng nhập tên danh mục!", "Cảnh báo", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                txtCategoryName.Focus();
                return false;
            }

            if (txtCategoryName.Text.Trim().Length > 100)
            {
                MessageBox.Show("Tên danh mục không được vượt quá 100 ký tự!", "Cảnh báo", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                txtCategoryName.Focus();
                return false;
            }

            // Kiểm tra mô tả
            if (txtDescription.Text.Trim().Length > 500)
            {
                MessageBox.Show("Mô tả không được vượt quá 500 ký tự!", "Cảnh báo", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                txtDescription.Focus();
                return false;
            }

            // Kiểm tra danh mục cha
            var selectedItem = cboParentCategory.SelectedItem as ComboBoxItem;
            if (selectedItem != null && selectedItem.Value != -1)
            {
                if (selectedItem.Value == _currentCategoryId)
                {
                    MessageBox.Show("Danh mục không thể là cha của chính nó!", "Cảnh báo", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    cboParentCategory.Focus();
                    return false;
                }
            }

            return true;
        }

        private void btnDelete_Click(object sender, EventArgs e)
        {
            if (_currentCategoryId <= 0)
            {
                MessageBox.Show("Vui lòng chọn danh mục cần xóa!", "Cảnh báo", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            var result = MessageBox.Show("Bạn có chắc chắn muốn xóa danh mục này?\n\nLưu ý: Chỉ có thể xóa danh mục không có sản phẩm và không có danh mục con.", 
                "Xác nhận xóa", MessageBoxButtons.YesNo, MessageBoxIcon.Question);
            
            if (result == DialogResult.Yes)
            {
                try
                {
                    Cursor = Cursors.WaitCursor;
                    
                    if (_categoryService.DeleteCategory(_currentCategoryId))
                    {
                        MessageBox.Show("Xóa danh mục thành công!", "Thành công", MessageBoxButtons.OK, MessageBoxIcon.Information);
                        LoadCategories();
                        LoadParentCategories();
                        ClearForm();
                    }
                    else
                    {
                        MessageBox.Show("Xóa danh mục thất bại!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    }
                }
                catch (InvalidOperationException ex)
                {
                    MessageBox.Show("Không thể xóa danh mục: " + ex.Message, "Cảnh báo", MessageBoxButtons.OK, MessageBoxIcon.Warning);
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
            _currentCategoryId = 0;
            _isEditMode = false;
            txtCategoryCode.Clear();
            txtCategoryName.Clear();
            txtDescription.Clear();
            cboParentCategory.SelectedIndex = 0;
            UpdateButtonStates();
            txtCategoryCode.Focus();
            
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
                    LoadCategories();
                    return;
                }

                Cursor = Cursors.WaitCursor;
                var searchResults = _categoryService.SearchCategories(searchTerm);
                dataGridView1.DataSource = searchResults;
                lblCategoryCount.Text = $"Tìm thấy: {searchResults.Rows.Count} danh mục";
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi tìm kiếm: " + ex.Message, "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
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
                LoadCategories(); // Sẽ tự động hiển thị theo cascade
                LoadParentCategories();
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
        private void txtCategoryCode_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == (char)Keys.Enter)
            {
                e.Handled = true;
                txtCategoryName.Focus();
            }
        }

        private void txtCategoryName_KeyPress(object sender, KeyPressEventArgs e)
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
                cboParentCategory.Focus();
            }
        }

        private void cboParentCategory_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == (char)Keys.Enter)
            {
                e.Handled = true;
                btnAdd_Click(sender, e);
            }
        }
    }

    // Helper class cho ComboBox
    public class ComboBoxItem
    {
        public string Text { get; set; }
        public int Value { get; set; }
        public override string ToString()
        {
            return Text;
        }
    }
}

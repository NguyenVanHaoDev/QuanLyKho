using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace QLKHO.GUI
{
    public partial class FrmMain : Form
    {
        public FrmMain()
        {
            InitializeComponent();
        }

        private void FrmMain_Load(object sender, EventArgs e)
        {
            // Khởi tạo form
            this.WindowState = FormWindowState.Maximized;
            this.Text = "HỆ THỐNG QUẢN LÝ KHO HÀNG";
            
            // Khởi tạo timer để cập nhật thời gian
            Timer timer = new Timer();
            timer.Interval = 1000;
            timer.Tick += Timer_Tick;
            timer.Start();
        }

        private void Timer_Tick(object sender, EventArgs e)
        {
            lblTime.Text = DateTime.Now.ToString("HH:mm:ss");
        }

        private void btnQuanLySanPham_Click(object sender, EventArgs e)
        {
            try
            {
                // Duyệt qua tất cả các form con đang mở
                foreach (Form frm in this.MdiChildren)
                {
                    if (frm is FrmSanPham)
                    {
                        frm.Activate(); // đưa form đã mở lên trên
                        lblStatus.Text = "Form quản lý sản phẩm đã được mở";
                        return;
                    }
                }
                var frmSanPham = new FrmSanPham();
                frmSanPham.MdiParent = this;
                frmSanPham.Show();
                lblStatus.Text = "Đã mở form quản lý sản phẩm";
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi mở form quản lý sản phẩm: " + ex.Message, "Lỗi", 
                    MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void btnQuanLyDanhMuc_Click(object sender, EventArgs e)
        {
            try
            {

                // Duyệt qua tất cả các form con đang mở
                foreach (Form frm in this.MdiChildren)
                {
                    if (frm is FrmDanhMuc)
                    {
                        frm.Activate(); // đưa form đã mở lên trên
                        lblStatus.Text = "Form quản lý danh mục đã được mở";
                        return;
                    }
                }
                var frmDanhMuc = new FrmDanhMuc();
                frmDanhMuc.MdiParent = this;
                frmDanhMuc.Show();
                lblStatus.Text = "Đã mở form quản lý danh mục";
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi mở form quản lý danh mục: " + ex.Message, "Lỗi", 
                    MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void btnThoat_Click(object sender, EventArgs e)
        {
            var result = MessageBox.Show("Bạn có chắc chắn muốn thoát ứng dụng?", "Xác nhận thoát", 
                MessageBoxButtons.YesNo, MessageBoxIcon.Question);
            
            if (result == DialogResult.Yes)
            {
                Application.Exit();
            }
        }

        private void btnCascade_Click(object sender, EventArgs e)
        {
            this.LayoutMdi(MdiLayout.Cascade);
            lblStatus.Text = "Đã sắp xếp form theo kiểu Cascade";
        }

        private void btnTileHorizontal_Click(object sender, EventArgs e)
        {
            this.LayoutMdi(MdiLayout.TileHorizontal);
            lblStatus.Text = "Đã sắp xếp form theo kiểu Tile Horizontal";
        }

        private void btnTileVertical_Click(object sender, EventArgs e)
        {
            this.LayoutMdi(MdiLayout.TileVertical);
            lblStatus.Text = "Đã sắp xếp form theo kiểu Tile Vertical";
        }

        private void btnCloseAll_Click(object sender, EventArgs e)
        {
            foreach (Form childForm in this.MdiChildren)
            {
                childForm.Close();
            }
            lblStatus.Text = "Đã đóng tất cả form con";
        }

        private void btnAbout_Click(object sender, EventArgs e)
        {
            MessageBox.Show(
                "HỆ THỐNG QUẢN LÝ KHO HÀNG\n\n" +
                "Phiên bản: 1.0\n" +
                "Phát triển bởi: QLKHO Team\n\n" +
                "Chức năng:\n" +
                "• Quản lý sản phẩm\n" +
                "• Quản lý danh mục\n" +
                "• Quản lý kho hàng\n\n" +
                "© 2025 QLKHO. All rights reserved.",
                "Thông tin ứng dụng",
                MessageBoxButtons.OK,
                MessageBoxIcon.Information);
        }


    }
}

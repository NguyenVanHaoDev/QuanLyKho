# HƯỚNG DẪN SỬ DỤNG CHỨC NĂNG QUẢN LÝ DANH MỤC

## Tổng quan
Chức năng quản lý danh mục cho phép người dùng thêm, sửa, xóa và tìm kiếm các danh mục sản phẩm trong hệ thống quản lý kho hàng.

## Các tính năng chính

### 1. Thêm danh mục mới
- **Bước 1**: Nhập mã danh mục (tối đa 20 ký tự, không được trùng lặp)
- **Bước 2**: Nhập tên danh mục (tối đa 100 ký tự)
- **Bước 3**: Nhập mô tả (tối đa 500 ký tự, không bắt buộc)
- **Bước 4**: Chọn danh mục cha (nếu muốn tạo danh mục con)
- **Bước 5**: Nhấn nút "Thêm mới"

### 2. Cập nhật danh mục
- **Bước 1**: Chọn danh mục cần sửa từ danh sách
- **Bước 2**: Thông tin sẽ được tự động điền vào form
- **Bước 3**: Sửa đổi thông tin cần thiết
- **Bước 4**: Nhấn nút "Cập nhật"

### 3. Xóa danh mục
- **Bước 1**: Chọn danh mục cần xóa từ danh sách
- **Bước 2**: Nhấn nút "Xóa"
- **Bước 3**: Xác nhận xóa

**Lưu ý**: Chỉ có thể xóa danh mục không có sản phẩm và không có danh mục con.

### 4. Tìm kiếm danh mục
- Nhập từ khóa tìm kiếm vào ô tìm kiếm
- Hệ thống sẽ tìm kiếm theo:
  - Mã danh mục
  - Tên danh mục
  - Mô tả
- Nhấn Enter hoặc nút "Tìm kiếm" để thực hiện tìm kiếm

### 5. Làm mới dữ liệu
- Nhấn nút "Làm mới" để tải lại toàn bộ dữ liệu
- Xóa từ khóa tìm kiếm và hiển thị tất cả danh mục

## Quy tắc validation

### Mã danh mục
- Không được để trống
- Tối đa 20 ký tự
- Không được trùng lặp với danh mục khác

### Tên danh mục
- Không được để trống
- Tối đa 100 ký tự

### Mô tả
- Không bắt buộc
- Tối đa 500 ký tự

### Danh mục cha
- Không bắt buộc
- Không thể chọn chính nó làm cha
- Phải tồn tại trong hệ thống

## Phím tắt

- **Enter** trong ô tìm kiếm: Thực hiện tìm kiếm
- **Enter** trong ô mã danh mục: Chuyển đến ô tên danh mục
- **Enter** trong ô tên danh mục: Chuyển đến ô mô tả
- **Enter** trong ô mô tả: Chuyển đến combobox danh mục cha
- **Enter** trong combobox danh mục cha: Thực hiện thêm/cập nhật

## Giao diện

### Panel 1 (Header)
- Tiêu đề "QUẢN LÝ DANH MỤC"
- Ô tìm kiếm với nút tìm kiếm
- Nút làm mới
- Hiển thị tổng số danh mục

### Panel 2 (Form)
- Form nhập thông tin danh mục
- Các nút thao tác: Thêm mới/Cập nhật, Làm mới/Hủy, Xóa
- Nút Xóa chỉ hoạt động khi đang ở chế độ sửa

### DataGridView
- Hiển thị danh sách tất cả danh mục theo chế độ **Cascade** (phân cấp)
- **Cách hiển thị:**
  - Danh mục gốc (không có cha) hiển thị bình thường
  - Danh mục con được thụt đầu với ký tự "├─ " để thể hiện quan hệ cha-con
  - Cấu trúc phân cấp rõ ràng, dễ nhìn thấy mối quan hệ giữa các danh mục
- **Các cột hiển thị:**
  - **Mã DM**: Mã do người dùng nhập (VD: DM001, DM002)
  - **Tên Danh Mục**: Tên hiển thị của danh mục (có thụt đầu cho danh mục con)
  - **Mô Tả**: Mô tả chi tiết (có thể để trống)
  - **Danh Mục Cha**: Mã danh mục cha (nếu có)
  - **Hoạt Động**: Trạng thái hoạt động (1 = Hoạt động, 0 = Không hoạt động)
  - **Ngày Tạo**: Ngày tạo danh mục
- **Cột ẩn:** MaDanhMuc (ID nội bộ, không hiển thị cho người dùng)
- Click vào dòng để chọn danh mục cần sửa/xóa

## Xử lý lỗi

### Lỗi validation
- Hiển thị thông báo cảnh báo với icon Warning
- Tự động focus vào trường có lỗi

### Lỗi business logic
- Hiển thị thông báo cảnh báo với icon Warning
- Giải thích rõ lý do không thể thực hiện thao tác

### Lỗi hệ thống
- Hiển thị thông báo lỗi với icon Error
- Ghi log lỗi chi tiết

## Tính năng nâng cao

### Tooltip
- Hiển thị hướng dẫn khi hover chuột
- Giải thích chức năng của từng control

### Cursor
- Hiển thị cursor chờ khi thực hiện thao tác
- Cải thiện trải nghiệm người dùng

### Trạng thái nút
- Nút thay đổi màu sắc và text theo chế độ
- Nút Xóa chỉ hoạt động khi cần thiết

## Cấu trúc dữ liệu

### Bảng DanhMucSanPham
- **MaDanhMuc**: Khóa chính, tự động tăng (ID nội bộ, không hiển thị cho người dùng)
- **MaDanhMucCode**: Mã danh mục do người dùng nhập (unique, hiển thị trong giao diện)
- **TenDanhMuc**: Tên danh mục
- **MoTa**: Mô tả (có thể null)
- **MaDanhMucCha**: Tham chiếu đến danh mục cha (có thể null)
- **HoatDong**: Trạng thái hoạt động
- **NgayTao**: Ngày tạo
- **MaNguoiDungTao**: Người tạo
- **NgaySua**: Ngày sửa (có thể null)
- **MaNguoiDungSua**: Người sửa (có thể null)

### Giải thích sự khác biệt
- **MaDanhMuc**: Là khóa chính tự động tăng (1, 2, 3, ...) - chỉ dùng để liên kết dữ liệu
- **MaDanhMucCode**: Là mã do người dùng nhập (DM001, DM002, ...) - hiển thị trong giao diện
- **Ví dụ**: 
  - MaDanhMuc = 1, MaDanhMucCode = "DM001", TenDanhMuc = "Điện tử"
  - MaDanhMuc = 2, MaDanhMucCode = "DM002", TenDanhMuc = "Quần áo"

### Cách hoạt động của hệ thống
- **Hiển thị**: DataGridView chỉ hiển thị thông tin cần thiết cho người dùng (không có MaDanhMuc)
- **Xử lý logic**: Hệ thống sử dụng mapping giữa mã danh mục và ID để thực hiện các thao tác
- **Bảo mật**: ID nội bộ không được hiển thị, tránh người dùng can thiệp vào dữ liệu hệ thống
- **Hiệu suất**: Mapping được xây dựng một lần khi tải dữ liệu, không ảnh hưởng đến hiệu suất

## Bảo mật

- Kiểm tra quyền truy cập theo role
- Ghi log tất cả thao tác
- Validation dữ liệu đầu vào
- Kiểm tra ràng buộc business logic

## Mở rộng

Hệ thống có thể được mở rộng để hỗ trợ:
- Import/Export danh mục từ file Excel
- Quản lý cây danh mục nhiều cấp
- Phân quyền chi tiết theo danh mục
- Backup và restore dữ liệu danh mục
- Báo cáo thống kê danh mục

using DevExpress.Utils;
using DevExpress.XtraEditors;
using DevExpress.XtraGrid.Views.Grid;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace QLNV1
{
    public partial class frmDiem : DevExpress.XtraEditors.XtraForm
    {
        int vitri = 0;
        string macn = "";
        private BindingSource bdsDiem = new BindingSource();
        public frmDiem()
        {
            InitializeComponent();
        }

        private void mONHOCBindingNavigatorSaveItem_Click(object sender, EventArgs e)
        {
            this.Validate();
            this.bdsMonHoc.EndEdit();
            this.tableAdapterManager.UpdateAll(this.DS);

        }

        private void frmDiem_Load(object sender, EventArgs e)
        {
            DS.EnforceConstraints = false;
            this.mONHOCTableAdapter.Connection.ConnectionString = Program.connstr;
            this.mONHOCTableAdapter.Fill(this.DS.MONHOC);
            
            cbKhoa.DataSource = Program.bds_dspm;
            cbKhoa.DisplayMember = "TENCN";
            cbKhoa.ValueMember = "TENSERVER";
            cbKhoa.SelectedIndex = Program.mChinhanh;

            cbMonHoc.DataSource = bdsMonHoc;
            cbMonHoc.DisplayMember = "TENMH";
            cbMonHoc.ValueMember = "TENMH";

            if (Program.mGroup == "KHOA")
            {
                cbKhoa.Enabled = false;
            }
            loadcbNienkhoa();
            cbNienKhoa.SelectedIndex = 0;
        }
        void loadcbNienkhoa()
        {
            DataTable dt = new DataTable();
            string cmd = "EXEC dbo.GetAllNienKhoa";
            dt = Program.ExecSqlDataTable(cmd);

            BindingSource bdsNienKhoa = new BindingSource();
            bdsNienKhoa.DataSource = dt;
            cbNienKhoa.DataSource = bdsNienKhoa;
            cbNienKhoa.DisplayMember = "NIENKHOA";
            cbNienKhoa.ValueMember = "NIENKHOA";
        }
        void loadcbHocKi(string nienkhoa)
        {
            DataTable dt = new DataTable();
            string cmd = "EXEC dbo.GetAllHocKy '" + nienkhoa + "'";
            dt = Program.ExecSqlDataTable(cmd);

            BindingSource bdsHocKi = new BindingSource();
            bdsHocKi.DataSource = dt;
            cbHocKi.DataSource = bdsHocKi;
            cbHocKi.DisplayMember = "HOCKY";
            cbHocKi.ValueMember = "HOCKY";
        }
        void loadNhom(string nienkhoa,string hocki)
        {
            DataTable dt = new DataTable();
            string cmd = "EXEC dbo.GetAllNhom '"+nienkhoa+"', "+hocki;
            dt = Program.ExecSqlDataTable(cmd);

            BindingSource bdsNhom = new BindingSource();
            bdsNhom.DataSource = dt;
            cbNhom.DataSource = bdsNhom;
            cbNhom.DisplayMember = "NHOM";
            cbNhom.ValueMember = "NHOM";
        }
        private void cbKhoa_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (cbKhoa.SelectedValue.ToString() == "System.Data.DataRowView")
                return;
            Program.severname = cbKhoa.SelectedValue.ToString();
            if (cbKhoa.SelectedIndex != Program.mChinhanh)
            {
                Program.mlogin = Program.remotelogin;
                Program.password = Program.remotepassword;
            }
            else
            {
                Program.mlogin = Program.mloginDN;
                Program.password = Program.passwordDN;
            }
            if (Program.KetNoi() == 0)
            {
                MessageBox.Show("Lỗi kết nối về chi nhánh mới", "", MessageBoxButtons.OK);
            }
            else
            {
                loadcbNienkhoa();
                cbNienKhoa.SelectedIndex = 0;
            }
        }
        void loadBDMH()
        {
            string cmd = "EXEC [dbo].[SP_BDMH] '" + cbNienKhoa.Text + "', " + cbHocKi.Text + ", " + cbNhom.Text + ", N'" + cbMonHoc.SelectedValue.ToString() + "'";
            DataTable diemTable = Program.ExecSqlDataTable(cmd);
            this.bdsDiem.DataSource = diemTable;
            this.DiemGridControl.DataSource = this.bdsDiem;
        }
        private void btnBatDau_Click(object sender, EventArgs e)
        {
            loadBDMH();
        }

        private void btnCapNhat_Click(object sender, EventArgs e)
        {
            BindingSource bdsTemp = (BindingSource)this.DiemGridControl.DataSource;
            if(bdsTemp == null)
            {
                MessageBox.Show("Chưa có thông tin để ghi điểm!","",MessageBoxButtons.OK);
                return;
            }
          
            bdsTemp.EndEdit();
            SqlConnection conn = new SqlConnection(Program.connstr);
            // bắt đầu transaction
            SqlTransaction tran;

            conn.Open();
            tran = conn.BeginTransaction();
            try
            {


                for (int i = 0; i < bdsTemp.Count; i++)
                {

                    SqlCommand cmd = new SqlCommand("SP_XULY_DIEM", conn);
                    cmd.Connection = conn;
                    cmd.Transaction = tran;



                    cmd.CommandType = CommandType.StoredProcedure;
                    string masv = ((DataRowView)bdsTemp[i])["MASV"].ToString();
                    cmd.Parameters.Add(new SqlParameter("@MSSV", masv));
                    cmd.Parameters.Add(new SqlParameter("@MALTC", ((DataRowView)bdsTemp[i])["MALC"].ToString()));
                    float diemcc = 0;
                    float diemgk = 0;
                    float diemck = 0;
                    if (((DataRowView)bdsTemp[i])["DIEM_CC"].ToString() != "")
                    {
                        diemcc = float.Parse(((DataRowView)bdsTemp[i])["DIEM_CC"].ToString());
                    }
                    if (((DataRowView)bdsTemp[i])["DIEM_GK"].ToString() != "")
                    {
                        diemgk = float.Parse(((DataRowView)bdsTemp[i])["DIEM_GK"].ToString());
                    }
                    if (((DataRowView)bdsTemp[i])["DIEM_CK"].ToString() != "")
                    {
                        diemck = float.Parse(((DataRowView)bdsTemp[i])["DIEM_CK"].ToString());
                    }
                    if(diemcc < 0 || diemcc > 10|| diemck < 0 || diemck >10 || diemgk <0 || diemgk >10)
                    {
                        tran.Rollback();
                        XtraMessageBox.Show("Điểm số chỉ được nhập từ 0 đến 10! Xin vui lòng nhập lại");
                        conn.Close();
                        loadBDMH();
                        return;
                    }
                    cmd.Parameters.Add(new SqlParameter("@DIEMCC", diemcc));
                    cmd.Parameters.Add(new SqlParameter("@DIEMGK", diemgk));
                    cmd.Parameters.Add(new SqlParameter("@DIEMCK", diemck));
                    cmd.ExecuteNonQuery();


                }


                tran.Commit();
            }
            catch (SqlException sqlex)
            {
                try
                {

                    tran.Rollback();
                    XtraMessageBox.Show("Lỗi ghi toàn bộ điểm vào Database. Bạn hãy xem lại ! " + sqlex.Message, "", MessageBoxButtons.OK);
                    loadBDMH();
                }
                catch (Exception ex2)
                {
                    Console.WriteLine("Rollback Exception Type: {0}", ex2.GetType());
                    Console.WriteLine("  Message: {0}", ex2.Message);
                }
                conn.Close();
                return;
            }
            finally
            {
                conn.Close();
            }
            XtraMessageBox.Show("Thao tác thành công!", "", MessageBoxButtons.OK);
            string cmd1 = "EXEC [dbo].[SP_BDMH] '" + cbNienKhoa.Text + "', " + cbHocKi.Text + ", " + cbNhom.Text + ", N'" + cbMonHoc.SelectedValue.ToString() + "'";
            DataTable diemTable = Program.ExecSqlDataTable(cmd1);
            this.bdsDiem.DataSource = diemTable;
            this.DiemGridControl.DataSource = this.bdsDiem;
            return;
        }

        private void gridView1_RowCellStyle(object sender, DevExpress.XtraGrid.Views.Grid.RowCellStyleEventArgs e)
        {
            GridView view = sender as GridView;
            if (e.RowHandle == view.FocusedRowHandle)
            {
                e.Appearance.BackColor = Color.LawnGreen;
            }
        }

        private void gridView1_CustomDrawRowIndicator(object sender, DevExpress.XtraGrid.Views.Grid.RowIndicatorCustomDrawEventArgs e)
        {
            e.Handled = true;
            SolidBrush brush = new SolidBrush(Color.FromArgb(0xC6, 0x64, 0xFF));
            e.Graphics.FillRectangle(brush, e.Bounds);
            e.Graphics.DrawRectangle(Pens.Black, new Rectangle(e.Bounds.X, e.Bounds.Y, e.Bounds.Width - 1, e.Bounds.Height));
            Size size = ImageCollection.GetImageListSize(e.Info.ImageCollection);
            Rectangle r = e.Bounds;
            ImageCollection.DrawImageListImage(e.Cache, e.Info.ImageCollection, e.Info.ImageIndex,
                    new Rectangle(r.X + (r.Width - size.Width) / 2, r.Y + (r.Height - size.Height) / 2, size.Width, size.Height));
            brush.Dispose();
        }

        private void btnThoat_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void cbHocKi_SelectedIndexChanged(object sender, EventArgs e)
        {
            
            loadNhom(cbNienKhoa.Text,cbHocKi.Text);
            cbNhom.SelectedIndex = 0;
        }

        private void cbNienKhoa_SelectedIndexChanged(object sender, EventArgs e)
        {
            
            loadcbHocKi(cbNienKhoa.Text);
            cbHocKi.SelectedIndex = 0;
        }
    }
}
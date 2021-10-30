using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;

namespace reserve
{
    public partial class notes : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Request.QueryString["cat"] != null) txtHdnCat.Value = Request.QueryString["cat"].ToString();
            if (Request.QueryString["comp"] != null) txtHdnComp.Value = Request.QueryString["comp"].ToString();

            if (txtHdnType.Value == "del") delImg();
            if (txtHdnType.Value == "update") updateComment();
        }

        protected void btnUpload_Click(object sender, EventArgs e)
        {
            byte[] data;

            if (flUp.FileContent.Length>0)
            {
                System.Drawing.Image image_file = System.Drawing.Image.FromStream(flUp.PostedFile.InputStream);
                int image_height = image_file.Height;
                int image_width = image_file.Width;
                int max_height = 240;
                int max_width = 320;


                image_height = (image_height * max_width) / image_width;
                image_width = max_width;

                if (image_height > max_height)
                {
                    image_width = (image_width * max_height) / image_height;
                    image_height = max_height;
                }

                Bitmap bitmap_file = new Bitmap(image_file, image_width, image_height);
                System.IO.MemoryStream stream = new System.IO.MemoryStream();

                bitmap_file.Save(stream, System.Drawing.Imaging.ImageFormat.Png);
                stream.Position = 0;

                data = new byte[stream.Length + 1];
                stream.Read(data, 0, data.Length);
            }
            else
            {
                data = new byte[0];
            }


            var conn = Fn_enc.getconn();
            string sql = "insert into info_components_images (firm_id, project_id, category_id, component_id, image_id, image_bytes, image_comments, last_updated_by, last_updated_date) select @Param1, @Param2, @Param3, @Param4, isnull((select max(image_id) from info_components_images where firm_id=@Param1 and project_id=@Param2 and category_id=@Param3 and component_id=@Param4),0)+1, @Param5, @Param6, @Param7, GetDate()";
            SqlCommand cmd = new SqlCommand(sql, conn);
            cmd.CommandType = CommandType.Text;
            cmd.Parameters.AddWithValue("@Param1", Session["firmid"]);
            cmd.Parameters.AddWithValue("@Param2", Session["projectid"]);
            cmd.Parameters.AddWithValue("@Param3", txtHdnCat.Value);
            cmd.Parameters.AddWithValue("@Param4", txtHdnComp.Value);
            //cmd.Parameters.AddWithValue("@Param5", buffer);
            cmd.Parameters.Add("@Param5", SqlDbType.VarBinary);
            if (flUp.FileContent.Length > 0)
            {
                cmd.Parameters["@Param5"].Value = data;
            }
            else
            {
                cmd.Parameters["@Param5"].Value = DBNull.Value;
            }
            cmd.Parameters.AddWithValue("@Param6", txtComments.Value);
            cmd.Parameters.AddWithValue("@Param7", Session["userid"].ToString());
            conn.Open();
            cmd.ExecuteNonQuery();
            conn.Close();

            if (flUp.FileContent.Length > 0) {
                lblStatus.InnerHtml = "Successfully added note.";
            }
            else
            {
                lblStatus.InnerHtml = "Successfully added image and note to component.";
            }
        }

        protected void delImg()
        {
            Fn_enc.ExecuteNonQuery("delete from info_components_images where firm_id=@Param1 and project_id=@Param2 and category_id=@Param3 and component_id=@Param4 and image_id=@Param5", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString(), txtHdnCat.Value, txtHdnComp.Value, txtHdnDel.Value });
            lblStatus.InnerHtml = "Successfully removed image.";
            txtHdnDel.Value = "";
            txtHdnType.Value = "";
        }

        protected void updateComment()
        {
            Fn_enc.ExecuteNonQuery("update info_components_images set image_comments=@Param1 where firm_id=@Param2 and project_id=@Param3 and category_id=@Param4 and component_id=@Param5 and image_id=@Param6", new string[] { Request.Form["txtComments" + txtHdnID.Value].ToString(), Session["firmid"].ToString(), Session["projectid"].ToString(), txtHdnCat.Value, txtHdnComp.Value, txtHdnID.Value });
            lblStatus.InnerHtml = "Successfully updated comment.";
            txtHdnDel.Value = "";
            txtHdnType.Value = "";
        }
    }
}
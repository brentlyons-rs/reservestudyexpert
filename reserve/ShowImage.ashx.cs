using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.IO;
using System.Data;
using System.Data.SqlClient;
using System.Web.SessionState;

namespace reserve
{
    public class ShowImage : IHttpHandler, IRequiresSessionState
    {

        public void ProcessRequest(HttpContext context)
        {
            int cat_id; int comp_id; int image_id;

            if (context.Request.QueryString["cat"] != null)
                cat_id = Convert.ToInt32(context.Request.QueryString["cat"].ToString());
            else
                throw new ArgumentException("No category parameter specified");

            if (context.Request.QueryString["comp"] != null)
                comp_id = Convert.ToInt32(context.Request.QueryString["comp"].ToString());
            else
                throw new ArgumentException("No component parameter specified");

            if (context.Request.QueryString["img"] != null)
                image_id = Convert.ToInt32(context.Request.QueryString["img"]);
            else
                throw new ArgumentException("No image parameter specified");

            context.Response.ContentType = "image/jpeg";
            Stream strm = ShowEmpImage(cat_id, comp_id, image_id);
            byte[] buffer = new byte[4096];
            int byteSeq = strm.Read(buffer, 0, 4096);

            while (byteSeq > 0)
            {
                context.Response.OutputStream.Write(buffer, 0, byteSeq);
                byteSeq = strm.Read(buffer, 0, 4096);
            }
        }


        public Stream ShowEmpImage(int cat_id, int comp_id, int image_id)
        {
            var conn = Fn_enc.getconn();
            string sql = "select image_bytes from info_components_images where firm_id=@Param1 and project_id=@Param2 and category_id=@Param3 and component_id=@Param4 and image_id=@Param5";
            SqlCommand cmd = new SqlCommand(sql, conn);
            cmd.CommandType = CommandType.Text;
            cmd.Parameters.AddWithValue("@Param1", HttpContext.Current.Session["firmid"]);
            cmd.Parameters.AddWithValue("@Param2", HttpContext.Current.Session["projectid"]);
            cmd.Parameters.AddWithValue("@Param3", cat_id);
            cmd.Parameters.AddWithValue("@Param4", comp_id);
            cmd.Parameters.AddWithValue("@Param5", image_id);
            conn.Open();

            object img = cmd.ExecuteScalar();
            try
            {
                return new MemoryStream((byte[])img);
            }
            catch
            {
                return null;
            }
            finally
            {
                conn.Close();
            }
        }

        public bool IsReusable
        {
            get
            {
                return false;
            }
        }
    }
}
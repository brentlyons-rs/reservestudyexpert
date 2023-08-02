using System;
using System.Data.SqlClient;
using System.IO;
using System.Web;

namespace reserve
{
    public class GenerateInfoBalloons : System.Web.UI.Page
    {
        public static string GenerateInfoBalloonScript(string pageId)
        {
            var script = "";
            SqlDataReader dr = Fn_enc.ExecuteReader("select info_id, info_description from lkup_information_balloons where info_page_id=@Param1", new string[] { pageId });
            while (dr.Read())
            {
                script += $"balloons[{dr["info_id"]}] = '{dr["info_description"].ToString().Replace("'", "&quot;")}';";
            }
            dr.Close();

            return script;
        }

        public static string GetIcon(int id, string field, string color)
        {
            string html;
            if (HttpContext.Current.Session["superadmin"].ToString() == "1")
            {
                html = $"<i class=\"fa fa-info-circle\" style=\"color: {color}\" onclick=\"showBalloonAdmin(this, {id}, '{field}')\">&nbsp;</i>";
            }
            else
            {
                html = $"<i class=\"fa fa-info-circle\" style=\"color: {color}\" onmouseover=\"showBalloon(this, {id})\" onmouseout=\"hideBalloon()\">&nbsp;</i>";
            }

            return html;
        }
    }
}
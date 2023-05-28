using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Data.SqlClient;

namespace reserve
{
    public partial class rvw_exp : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["firmid"] == null) Response.Redirect("default.aspx?Timeout=1");
            
            if (lblProject.InnerHtml == "")
            {
                SqlDataReader dr = Fn_enc.ExecuteReader("select * from info_projects where firm_id=@Param1 and project_id=@Param2", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString() });

                if (dr.Read())
                {
                    lblProject.InnerHtml = dr["project_name"].ToString();
                }
                dr.Close();
            }

            if (Session["revisionid"] != null && lblRevision.InnerHtml == "")
            {
                SqlDataReader dr = Fn_enc.ExecuteReader("sp_app_revision_info @Param1, @Param2, @Param3", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString(), Session["revisionid"].ToString() });

                if (dr.Read())
                {
                    lblRevision.InnerHtml = $"{Session["revisionid"]}: {DateTime.Parse(dr["revision_created_date"].ToString()).ToString("MM/dd/yyyy")}";
                }
                dr.Close();
            }
        }
    }
}
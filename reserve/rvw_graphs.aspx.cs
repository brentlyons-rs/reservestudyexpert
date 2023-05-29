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
    public partial class rvw_graphs : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["firmid"] == null) Response.Redirect("default.aspx?Timeout=1");

            SqlDataReader dr;

            if (lblProject.InnerHtml == "")
            {
                dr = Fn_enc.ExecuteReader("select * from info_projects where firm_id=@Param1 and project_id=@Param2", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString() });

                if (dr.Read())
                {
                    lblProject.InnerHtml = dr["project_name"].ToString();
                }
                dr.Close();
            }


            if (Session["revisionid"] != null && lblRevision.InnerHtml == "")
            {
                dr = Fn_enc.ExecuteReader("sp_app_revision_info @Param1, @Param2, @Param3", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString(), Session["revisionid"].ToString() });

                if (dr.Read())
                {
                    lblRevision.InnerHtml = $"{Session["revisionid"]}: {DateTime.Parse(dr["revision_created_date"].ToString()).ToString("MM/dd/yyyy")}";
                }
                dr.Close();
            }

            if ((txtHdnType.Value=="Interest") || (txtHdnType.Value=="Inflation"))
            {
                UpdateII();
            }

            dr = Fn_enc.ExecuteReader("select interest, inflation from info_project_info where firm_id=@Param1 and project_id=@Param2 and revision_id=@Param3", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString(), Session["revisionid"].ToString() });
            if (dr.Read())
            {
                txtInt.Value = dr["interest"].ToString();
                txtInfl.Value = dr["inflation"].ToString();
            }
            dr.Close();
        }

        public void UpdateII()
        {
            if (txtHdnType.Value=="Interest")
            {
                Fn_enc.ExecuteNonQuery("update info_project_info set interest=@Param1 where firm_id=@Param2 and project_id=@Param3 and revision_id=@Param4", new string[] { txtInt.Value, Session["firmid"].ToString(), Session["projectid"].ToString(), Session["revisionid"].ToString() });
                GoalSeek.GenerateProjections(Session["firmid"].ToString(), Session["projectid"].ToString(), Session["revisionid"].ToString(), Session["userid"].ToString());
                lblInt.InnerHtml = "Successfully updated interest.";
                lblInfl.InnerHtml = "";
            }
            if (txtHdnType.Value=="Inflation")
            {
                Fn_enc.ExecuteNonQuery("update info_project_info set inflation=@Param1 where firm_id=@Param2 and project_id=@Param3 and revision_id=@Param4", new string[] { txtInfl.Value, Session["firmid"].ToString(), Session["projectid"].ToString(), Session["revisionid"].ToString() });
                GoalSeek.GenerateProjections(Session["firmid"].ToString(), Session["projectid"].ToString(), Session["revisionid"].ToString(), Session["userid"].ToString());
                lblInfl.InnerHtml = "Successfully updated inflation.";
                lblInt.InnerHtml = "";
            }
        }
    }
}
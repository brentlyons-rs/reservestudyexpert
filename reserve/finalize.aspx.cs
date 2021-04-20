using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Text;

namespace reserve
{
    public partial class finalize : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["firmid"] == null) Response.Redirect("default.aspx?Timeout=1");

            SqlDataReader dr;

            //Response.Write(Directory.GetCurrentDirectory());

            if (lblProject.InnerHtml == "")
            {
                dr = Fn_enc.ExecuteReader("select * from info_projects where firm_id=@Param1 and project_id=@Param2", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString() });

                if (dr.Read())
                {
                    lblProject.InnerHtml = dr["project_name"].ToString();
                }
                dr.Close();
            }

            dr = Fn_enc.ExecuteReader("sp_app_pre_finalize @Param1, @Param2", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString() });
            if (dr.Read())
            {
                bool blIssue = false;
                string docLoc;

                if (HttpContext.Current.Request.IsLocal)
                    docLoc = @"c:\data\";
                else if (HttpContext.Current.Request.Url.Host.IndexOf("test.reservestudyplus.com") >= 0)
                {
                    docLoc = @"D:\Inetpub\vhosts\reservestudyplus.com\test.reservestudyplus.com\clienttemplates\";
                }
                else
                {
                    docLoc = @"D:\Inetpub\vhosts\reservestudyplus.com\clienttemplates\";
                }

                docLoc += dr["template_name"].ToString();

                if (!File.Exists(docLoc.ToString()))
                {
                    icoTR.Attributes["class"] = "fa fa-exclamation-circle";
                    icoTR.Style.Add("color", "red");
                    blIssue = true;
                }
                if (dr["project_info"].ToString()=="Missing")
                {
                    icoPI.Attributes["class"] = "fa fa-exclamation-circle";
                    icoPI.Style.Add("color", "red");
                    blIssue = true;
                }
                if (dr["component_info"].ToString() == "Missing")
                {
                    icoCE.Attributes["class"] = "fa fa-exclamation-circle";
                    icoCE.Style.Add("color", "red");
                    blIssue = true;
                }
                if (dr["projection_info"].ToString() == "Missing")
                {
                    icoPDG.Attributes["class"] = "fa fa-exclamation-circle";
                    icoPDG.Style.Add("color", "red");
                    blIssue = true;
                }
                if (blIssue)
                {
                    lblStatus.InnerHtml = "One or more items require your attention before you can generate the final report.";
                    lblStatus.Style.Add("color", "red");
                    downloadLink.Visible = false;
                }
            }
            else
            {
                lblStatus.Attributes["class"] = "frm-text-red";
                lblStatus.InnerHtml = "There was a problem identifying your project information. Please notify an administrator.";
                downloadLink.Visible = false;

                icoPI.Attributes["class"] = "fa fa-exclamation-circle";
                icoPI.Style.Add("color", "red");

                icoCE.Attributes["class"] = "fa fa-exclamation-circle";
                icoCE.Style.Add("color", "red");

                icoPDG.Attributes["class"] = "fa fa-exclamation-circle";
                icoPDG.Style.Add("color", "red");
            }
            dr.Close();
        }
    }
}
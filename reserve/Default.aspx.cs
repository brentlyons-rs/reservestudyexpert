using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace reserve
{
    public partial class _Default : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack)
            {
                SqlDataReader p;
                if (Request.Form["txtHdnType"]=="Client")
                {
                    p = Fn_enc.ExecuteReader("sp_app_auth_user @Param1, @Param2, @Param3", new string[] { Request.Form["txtHdnType"], txtEMClient.Value, txtPWClient.Value });
                }
                else
                {
                    p = Fn_enc.ExecuteReader("sp_app_auth_user @Param1, @Param2, @Param3", new string[] { Request.Form["txtHdnType"], txtEM.Value, txtPW.Value });
                }
                if (p.Read())
                    switch (p["rslt"].ToString())
                    {
                        case "NoUser":
                            {
                                if (Request.Form["txtHdnType"] == "Client")
                                {
                                    lblStatusClient.InnerHtml = "Could not locate your email address in our system. Please try again.";
                                }
                                else
                                {
                                    lblStatus.InnerHtml = "Could not locate your email address in our system. Please try again.";
                                }
                                break;
                            }
                        case "BadPW":
                            {
                                if (Request.Form["txtHdnType"] == "Client")
                                {
                                    lblStatusClient.InnerHtml = "The email/password combination did not match our accounts. Please try again.";
                                }
                                else
                                {
                                    lblStatus.InnerHtml = "The email/password combination did not match our accounts. Please try again.";
                                }
                                break;
                            }
                        case "Success":
                            {
                                Session.Timeout = 30;
                                Session["firmid"] = p["client_id"];
                                Session["userid"] = p["user_id"];
                                Session["realname"] = p["real_name"];
                                Session["firmname"] = p["firm_name"];
                                Session["email"] = txtEM.Value;
                                Session["client"] = "0";
                                Session["superadmin"] = Convert.ToBoolean(p["super_admin"]) ? "1" : "0";
                                if (Convert.ToInt32(p["multi"].ToString()) > 1)
                                {
                                    Session["multi"] = "1";
                                }
                                else
                                {
                                    Session["multi"] = "0";
                                }
                                p.Close();
                                p = Fn_enc.ExecuteReader("sp_appver", new string[] { });
                                if (p.Read()) { Session["appver"] = p["appver"]; }
                                p.Close();
                                Fn_enc.ExecuteNonQuery("update app_users set last_login=getdate() where firm_id=@Param1 and user_id=@Param2", new string[] { Session["firmid"].ToString(), Session["userid"].ToString() });
                                Response.Redirect("main.aspx");
                                break;
                            }
                        case "ClientSuccess":
                            {
                                Session.Timeout = 30;
                                Session["firmid"] = p["client_id"];
                                Session["userid"] = p["user_id"];
                                Session["realname"] = p["real_name"];
                                Session["firmname"] = p["firm_name"];
                                Session["client"] = "1";
                                Session["projectid"] = "C" + txtPWClient.Value;
                                Session["oldprojectid"] = txtPWClient.Value;
                                Session["multi"] = 0;
                                p.Close();
                                p = Fn_enc.ExecuteReader("sp_appver", new string[] { });
                                if (p.Read()) { Session["appver"] = p["appver"]; }
                                p.Close();
                                Fn_enc.ExecuteNonQuery("update info_projects_client_invites set last_login=getdate(), num_logins=isnull(num_logins,0)+1 where firm_id=@Param1 and project_id=@Param2 and client_email=@Param3", new string[] { Session["firmid"].ToString(), txtPWClient.Value, txtEMClient.Value });
                                Response.Redirect("main.aspx");
                                break;
                            }
                        default:
                            {
                                lblStatus.InnerHtml = "Oops! Something went wrong on our side. Please try again, and if the problem persists, please notify an administrator.";
                                break;
                            }
                    }
                else
                    Response.Write("Oops! Something went wrong on our side. Please try again, and if the problem persists, please notify an administrator.");

                p.Close();
            }
            else if (Request.QueryString["lo"]=="1")
            {
                Session.Abandon();
                Session.Clear();
            }
        }
        
    }
}
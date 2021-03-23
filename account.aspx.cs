using System;


namespace reserve
{
    public partial class account : System.Web.UI.Page
    {
        private void Page_Load(object sender, System.EventArgs e)
        {
            if (Session["firmid"] == null) Response.Redirect("default.aspx?Timeout=1");
        }

        protected void cmdSave_Click(object sender, System.EventArgs e)
        {
            Fn_enc.ExecuteNonQuery("update app_users set user_pwd=@Param1, force_pw_reset=0 where email_addr=@Param2", txtNew.Value + "||" + System.Web.UI.Page.Session["email"]);
            //System.Web.UI.Page.Session["ForcePWReset"] = "";
            //System.Web.UI.Page.Server.Transfer("reports.aspx");
        }
    }
}

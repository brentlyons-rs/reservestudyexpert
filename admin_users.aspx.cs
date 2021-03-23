using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Runtime.CompilerServices;
using System.Security;
using System.Text;
using System.Threading.Tasks;
using Microsoft.VisualBasic;
using System.Data;
using System.Data.SqlClient;

public partial class admin_users : System.Web.UI.Page
{
    protected bool CheckDate(String date)
    {
        try
        {
            DateTime dt = DateTime.Parse(date);
            return true;
        }
        catch
        {
            return false;
        }
    }

    public SqlParameter fp(int iParam, object strVal, bool blCB = false)
    {
        SqlParameter sp;

        if (blCB)
        {
            if (!CheckDate(strVal.ToString()))
                sp = new SqlParameter("Param" + iParam, DBNull.Value);
            else
                sp = new SqlParameter("Param" + iParam, Convert.ToDateTime(strVal.ToString().Replace(",", "")));
        }
        else if (strVal.ToString() == "" | (strVal.ToString().ToLower() == "n/a"))
            sp = new SqlParameter("Param" + iParam, DBNull.Value);
        else
            sp = new SqlParameter("Param" + iParam, strVal.ToString());

        return sp;
    }

    protected void Page_Load(object sender, System.EventArgs e)
    {
        SqlDataReader dr;
        //int i = -1;

        //if (System.Web.UI.Page.Session["UserID"] == "")
        //    System.Web.UI.Page.Response.Redirect("default.aspx?Timeout=1");
        //else if (System.Web.UI.Page.Session["UserID"] != "" & System.Web.UI.Page.Session["ForcePWReset"] == "Yes")
        //    System.Web.UI.Page.Response.Redirect("account.aspx");

        //if (txtHdnOp.Value == "SaveGen")
        //{
        //    SqlConnection conn = new SqlConnection(System.Configuration.ConfigurationManager.AppSettings("ConnStr"));
        //    SqlCommand command;
        //    if (lstUsers.SelectedIndex == 0)
        //    {
        //        conn.Open();
        //        // Make sure there isn't already an account with this email address
        //        dr = prs("select * from app_users where client_id=@Param1 and email_addr=@Param2", System.Web.UI.Page.Session["ClientID"] + "||" + txtEM.Value);
        //        if (dr.Read())
        //            lblStatus.InnerText = "Could not add account: an account already exists with the e-mail address you entered.";
        //        else
        //        {
        //            dr.Close();
        //            command = new SqlCommand("insert into app_users (client_id, user_id, email_addr, first_name, last_name, user_pwd, disabled, force_pw_reset, last_updated_by, last_updated_date) select @Param1, isnull((select max(user_id) from app_users where client_id=@Param2),0)+1, @Param3, @Param4, @Param5, @Param6, @Param8, @Param9, @Param10, getdate()", conn);
        //            command.Parameters.Add(new SqlParameter("Param1", System.Web.UI.Page.Session["ClientID"]));
        //            command.Parameters.Add(new SqlParameter("Param2", System.Web.UI.Page.Session["ClientID"]));
        //            command.Parameters.Add(new SqlParameter("Param3", txtEM.Value));
        //            command.Parameters.Add(new SqlParameter("Param4", txtFN.Value));
        //            command.Parameters.Add(new SqlParameter("Param5", txtLN.Value));
        //            command.Parameters.Add(new SqlParameter("Param6", txtNewPW.Value));
        //            if (chkDis.Checked)
        //                command.Parameters.Add(new SqlParameter("Param8", true));
        //            else
        //                command.Parameters.Add(new SqlParameter("Param8", false));
        //            if (chkFPWR.Checked)
        //                command.Parameters.Add(new SqlParameter("Param9", true));
        //            else
        //                command.Parameters.Add(new SqlParameter("Param9", false));
        //            command.Parameters.Add(new SqlParameter("Param10", System.Web.UI.Page.Session["UserID"]));
        //            command.ExecuteNonQuery();
        //            lblStatus.InnerText = "Successfully added user account.";
        //        }
        //        conn.Close();
        //    }
        //    else
        //    {
        //        conn.Open();
        //        if (txtNewPW.Value != "")
        //            command = new SqlCommand("update app_users set first_name=@Param1, last_name=@Param2, email_addr=@Param3, user_pwd=@Param4, disabled=@Param6, force_pw_reset=@Param7, last_updated_by=@Param8, last_updated_date=getdate() where client_id=@Param9 and user_id=@Param10", conn);
        //        else
        //            command = new SqlCommand("update app_users set first_name=@Param1, last_name=@Param2, email_addr=@Param3, disabled=@Param6, force_pw_reset=@Param7, last_updated_by=@Param8, last_updated_date=getdate() where client_id=@Param9 and user_id=@Param10", conn);
        //        command.Parameters.Add(new SqlParameter("Param1", txtFN.Value));
        //        command.Parameters.Add(new SqlParameter("Param2", txtLN.Value));
        //        command.Parameters.Add(new SqlParameter("Param3", txtEM.Value));
        //        if (txtNewPW.Value != "")
        //            command.Parameters.Add(new SqlParameter("Param4", txtNewPW.Value));
        //        if (chkDis.Checked)
        //            command.Parameters.Add(new SqlParameter("Param6", true));
        //        else
        //            command.Parameters.Add(new SqlParameter("Param6", false));
        //        if (chkFPWR.Checked)
        //            command.Parameters.Add(new SqlParameter("Param7", true));
        //        else
        //            command.Parameters.Add(new SqlParameter("Param7", false));
        //        command.Parameters.Add(new SqlParameter("Param8", System.Web.UI.Page.Session["UserID"]));
        //        command.Parameters.Add(new SqlParameter("Param9", System.Web.UI.Page.Session["ClientID"]));
        //        command.Parameters.Add(new SqlParameter("Param10", lstUsers.Items(lstUsers.SelectedIndex).Value));
        //        command.ExecuteNonQuery();
        //        if (txtNewPW.Value != "")
        //        {
        //            command = new SqlCommand("update app_users set user_pwd=@Param1 where email_addr=@Param2", conn);
        //            command.Parameters.Add(new SqlParameter("Param1", txtNewPW.Value));
        //            command.Parameters.Add(new SqlParameter("Param2", txtEM.Value));
        //            command.ExecuteNonQuery();
        //        }
        //        lblStatus.InnerText = "Successfully updated user account.";
        //        conn.Close();
        //    }
        //}
        //else if (txtHdnOp.Value == "SaveRoles")
        //{
        //    prse("delete from app_users_roles where client_id=@Param1 and user_id=@Param2", System.Web.UI.Page.Session["ClientID"] + "||" + lstUsers.Items(lstUsers.SelectedIndex).Value);

        //    for (i = 0; i <= lstRoles.Items.Count - 1; i++)
        //    {
        //        if (lstRoles.Items(i).Selected)
        //            prse("insert into app_users_roles (client_id, user_id, role_id) select @Param1, @Param2, @Param3", System.Web.UI.Page.Session["ClientID"] + "||" + lstUsers.Items(lstUsers.SelectedIndex).Value + "||" + lstRoles.Items(i).Value);
        //    }

        //    lblRoles.InnerHtml = "Successfully saved roles.";
        //}

        //cmdSave.Attributes.Add("onclick", "CheckSaveGen(); return false;");
        //clearFields();
        //if (lstUsers.SelectedIndex > -1)
        //    i = lstUsers.Items(lstUsers.SelectedIndex).Value;
        //lstUsers.Items.Clear();
        //lstUsers.Items.Add(new ListItem("** New User **", -1));
        //if (i == -1)
        //    lstUsers.Items(0).Selected = true;
        //dr = prs("select user_id, first_name, last_name from app_users where client_id=@Param1 order by last_name", System.Web.UI.Page.Session["ClientID"]);
        //while (dr.Read())
        //{
        //    lstUsers.Items.Add(new ListItem(dr["last_name"] + ", " + dr["first_name"], dr["user_id"]));
        //    if (i == dr["user_id"])
        //        lstUsers.Items(lstUsers.Items.Count - 1).Selected = true;
        //}
        //dr.Close();

        //if (lstUsers.SelectedIndex > 0)
        //{
        //    dr = prs("select * from app_users where client_id=@Param1 and user_id=@Param2", System.Web.UI.Page.Session["ClientID"] + "||" + lstUsers.Items(lstUsers.SelectedIndex).Value);
        //    if (dr.Read())
        //    {
        //        txtFN.Value = dr["first_name"];
        //        txtLN.Value = dr["last_name"];
        //        txtEM.Value = dr["email_addr"];
        //        if (!Information.IsDBNull(dr["disabled"]) && dr["disabled"])
        //            chkDis.Checked = true;
        //        if (!Information.IsDBNull(dr["force_pw_reset"]) && dr["force_pw_reset"])
        //            chkFPWR.Checked = true;
        //    }
        //    dr.Close();
        //    // Roles
        //    lstRoles.Items.Clear();
        //    dr = prs("select lr.role_id, lr.role_desc, aur.client_id as isthere from lkup_roles lr left join app_users_roles aur on aur.client_id=lr.client_id and aur.role_id=lr.role_id and aur.user_id=@Param1 where lr.client_id=@Param2", lstUsers.Items(lstUsers.SelectedIndex).Value + "||" + System.Web.UI.Page.Session["ClientID"]);
        //    while (dr.Read())
        //    {
        //        lstRoles.Items.Add(new ListItem(dr["role_desc"], dr["role_id"]));
        //        if (!Information.IsDBNull(dr["isthere"]))
        //            lstRoles.Items(lstRoles.Items.Count - 1).Selected = true;
        //    }
        //    dr.Close();
        //    cmdSave.CssClass = "input_button_green";
        //    cmdSave.Enabled = true;
        //    divNewPW.InnerText = "(New password information is optional)";
        //    divNewPW.Attributes.Add("class", "gridcol_blue");
        //    divInfo.Visible = true;
        //}
        //else
        //{
        //    // divInfo.Visible = False
        //    cmdSave.CssClass = "input_button_grey";
        //    cmdSave.Enabled = false;
        //    divNewPW.InnerText = "Please enter a new password.";
        //    divNewPW.Attributes.Add("class", "gridcol_red");
        //}
    }

    private void clearFields()
    {
        //txtFN.Value = "";
        //txtLN.Value = "";
        //txtEM.Value = "";
        //chkDis.Checked = false;
        //chkFPWR.Checked = false;
    }
}

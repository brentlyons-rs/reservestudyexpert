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
using System.Web.UI.WebControls;

namespace reserve
{
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

        private void clearFields()
        {
            txtFN.Value = "";
            txtLN.Value = "";
            txtEM.Value = "";
            chkDis.Checked = false;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            int i = -1;

            if (Session["firmid"] == null) Response.Redirect("default.aspx?Timeout=1");

            if (txtHdnOp.Value == "SaveGen")
            {
                if (lstUsers.SelectedIndex == 0)
                {
                    // Make sure there isn't already an account with this email address
                    SqlDataReader dr2 = Fn_enc.ExecuteReader("select * from app_users where firm_id=@Param1 and email_addr=@Param2", new string[] { Session["FirmID"].ToString(), txtEM.Value });
                    if (dr2.Read())
                        lblStatus.InnerText = "Could not add account: an account already exists with the e-mail address you entered.";
                    else
                    {
                        dr2.Close();
                        Fn_enc.ExecuteNonQuery("insert into app_users (firm_id, user_id, email_addr, first_name, last_name, pwrd, disabled) select @Param1, isnull((select max(user_id) from app_users where firm_id=@Param1),0)+1, @Param2, @Param3, @Param4, @Param5, @Param6", new string[] { Session["firmid"].ToString(), txtEM.Value, txtFN.Value, txtLN.Value, txtNewPW.Value, chkDis.Checked ? "1" : "0" });
                        lblStatus.InnerText = "Successfully added user account.";
                    }
                }
                else
                {
                    if (txtNewPW.Value != "")
                        Fn_enc.ExecuteNonQuery("update app_users set first_name=@Param1, last_name=@Param2, email_addr=@Param3, user_pwd=@Param4, disabled=@Param5 where firm_id=@Param6 and user_id=@Param7", new string[] { txtFN.Value, txtLN.Value, txtEM.Value, txtNewPW.Value, chkDis.Checked ? "1" : "0", Session["firmid"].ToString(), lstUsers.Items[lstUsers.SelectedIndex].Value });
                    else
                        Fn_enc.ExecuteNonQuery("update app_users set first_name=@Param1, last_name=@Param2, email_addr=@Param3, disabled=@Param4 where firm_id=@Param5 and user_id=@Param6", new string[] { txtFN.Value, txtLN.Value, txtEM.Value, chkDis.Checked ? "1" : "0", Session["firmid"].ToString(), lstUsers.Items[lstUsers.SelectedIndex].Value });

                    lblStatus.InnerText = "Successfully updated user account.";
                }
            }

            cmdSave.Attributes.Add("onclick", "CheckSaveGen(); return false;");
            clearFields();
            if (lstUsers.SelectedIndex > -1) i = Convert.ToInt32( lstUsers.Items[lstUsers.SelectedIndex].Value);
            lstUsers.Items.Clear();
            lstUsers.Items.Add(new ListItem("** New User **", "-1"));
            if (i == -1) lstUsers.Items[0].Selected = true;
            SqlDataReader dr = Fn_enc.ExecuteReader("select user_id, first_name, last_name from app_users where firm_id=@Param1 order by last_name", new string[] { Session["FirmID"].ToString() });
            while (dr.Read())
            {
                lstUsers.Items.Add(new ListItem(dr["last_name"] + ", " + dr["first_name"], dr["user_id"].ToString()));
                if (i.ToString() == dr["user_id"].ToString())
                    lstUsers.Items[lstUsers.Items.Count - 1].Selected = true;
            }
            dr.Close();

            if (lstUsers.SelectedIndex > 0)
            {
                SqlDataReader dr2 = Fn_enc.ExecuteReader("select * from app_users where firm_id=@Param1 and user_id=@Param2", new string[] { Session["FirmID"].ToString(), lstUsers.Items[lstUsers.SelectedIndex].Value });
                if (dr2.Read())
                {
                    txtFN.Value = dr2["first_name"].ToString();
                    txtLN.Value = dr2["last_name"].ToString();
                    txtEM.Value = dr2["email_addr"].ToString();
                    if ((dr2["disabled"]!=null) && (dr2["disabled"].ToString().ToLower()=="true")) chkDis.Checked = true;
                }
                dr2.Close();
                cmdSave.CssClass = "btn btn-success";
                cmdSave.Enabled = true;
                divNewPW.InnerText = "(Optional)";
                divNewPW.Attributes.Add("class", "gridcol_blue");
                divInfo.Visible = true;
            }
            else
            {
                // divInfo.Visible = False
                cmdSave.CssClass = "btn btn-success";
                cmdSave.Enabled = false;
                divNewPW.InnerText = "(Required)";
                divNewPW.Attributes.Add("class", "gridcol_red");
            }
            txtNewPW.Value = "";
            txtConfirmPW.Value = "";
        }
    }
}
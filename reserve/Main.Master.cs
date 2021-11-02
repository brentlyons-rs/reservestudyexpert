using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace reserve
{
    public partial class Main : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                if (Session["client"].ToString() == "1")
                {
                    liAdmin.Visible = false;
                }
                if (Session["multi"].ToString()=="1")
                {
                    cboMulti.Visible = true;
                    cboMulti.Items.Clear();
                    lblName.InnerText = Session["realname"].ToString();
                    var dr = Fn_enc.ExecuteReader("select lf.firm_id, lf.firm_name from lkup_firms lf inner join app_users au on lf.firm_id=au.firm_id where au.email_addr=@Param1", new string[] { Session["email"].ToString() });
                    while (dr.Read())
                    {
                        cboMulti.Items.Add(new ListItem(dr["firm_name"].ToString(), dr["firm_id"].ToString(), dr["firm_id"].ToString()==Session["firmid"].ToString()));
                    }
                    dr.Close();
                }
                else
                {
                    cboMulti.Visible = false;
                    lblName.InnerText = $"{Session["realname"]} - {Session["firmname"]}";
                }
            }
            catch (Exception ex)
            {
                Response.Write(ex.ToString());
            }

        }
    }
}
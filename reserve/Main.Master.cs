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
                if ((Request.Form["txtHdnToggle"]!=null) && (Request.Form["txtHdnToggle"]!="")) //Change firms
                {
                    var dr = Fn_enc.ExecuteReader("select au.firm_id, lf.firm_name, au.email_addr, au.user_id from app_users au inner join lkup_firms lf on au.firm_id=lf.firm_id where au.firm_id=@Param1 and au.email_addr=@Param2", new string[] { Request.Form["txtHdnToggle"], Session["email"].ToString() });
                    if (dr.Read())
                    {
                        Session["firmid"] = dr["firm_id"];
                        Session["userid"] = dr["user_id"];
                        Session["firmname"] = dr["firm_name"];
                        Session["client"] = "0";
                        //lblToggle.InnerText = "Successfully switched firms.";
                    }
                    else
                    {
                        //lblToggle.InnerText = "Unable to switch: could not find your email address.";
                    }
                    dr.Close();
                }

                if (Session["client"].ToString() == "1")
                {
                    liAdmin.Visible = false;
                }
                if (Session["multi"].ToString()=="1")
                {
                    //cboMulti.Visible = true;
                    //cboMulti.Items.Clear();
                    lblName.InnerText = Session["realname"].ToString();
                    var dr = Fn_enc.ExecuteReader("select lf.firm_id, lf.firm_name from lkup_firms lf inner join app_users au on lf.firm_id=au.firm_id where au.email_addr=@Param1", new string[] { Session["email"].ToString() });
                    while (dr.Read())
                    {
                        //cboMulti.Items.Add(new ListItem(dr["firm_name"].ToString(), dr["firm_id"].ToString()));
                        if (dr["firm_id"].ToString() == Session["firmid"].ToString())
                        {
                            //cboMulti.SelectedIndex = cboMulti.Items.Count - 1;
                        }
                    }
                    dr.Close();
                }
                else
                {
                    //cboMulti.Visible = false;

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
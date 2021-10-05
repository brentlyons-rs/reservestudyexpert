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
            }
            catch (Exception ex)
            {
                Response.Write(ex.ToString());
            }

        }
    }
}
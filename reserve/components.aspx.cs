using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Data.SqlClient;
using System.Web.Services;

namespace reserve
{
    public partial class components : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["firmid"] == null) Response.Redirect("default.aspx?Timeout=1");

            if (lblProject.InnerHtml=="")
            {
                SqlDataReader dr = Fn_enc.ExecuteReader("select * from info_projects where firm_id=@Param1 and project_id=@Param2", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString() });

                if (dr.Read())
                {
                    lblProject.InnerHtml = dr["project_name"].ToString();
                }
                dr.Close();
            }

            if (txtHdnProjType.Value=="")
            {
                SqlDataReader dr = Fn_enc.ExecuteReader("select project_type_id from info_project_info where firm_id=@Param1 and project_id=@Param2", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString() });

                if (dr.Read())
                {
                    txtHdnProjType.Value = dr["project_type_id"].ToString();
                }
                dr.Close();
            }


            if (txtHdnType.Value=="DelCat")
            {
                DelCat();
            }
            else if (txtHdnType.Value=="SaveCat")
            {
                //cboCC.Items.Clear();
                SaveCat();
            }
            else if (txtHdnType.Value == "SaveNewRow")
            {
                SaveNewComponent();
            }
            else if (txtHdnType.Value=="Del")
            {
                DelComponent();
            }
            else if (cboCC.SelectedIndex>0)
            {
                LoadCategory();
            }
            else if (cboCC.Items.Count==0)
            {
                LoadCats();
            }

            if (cboYear.Items.Count==0)
            {
                LoadYears();
            }
        }

        public void LoadYears()
        {

            SqlDataReader dr = Fn_enc.ExecuteReader("select year(report_effective) as yr from info_project_info where firm_id=@Param1 and project_id=@Param2", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString() });
            if (dr.Read())
            {
                for (var i=0; i<31; i++)
                {
                    cboYear.Items.Add(new ListItem((Convert.ToInt16(dr["yr"].ToString()) + i).ToString() + " (Year " + (i+1).ToString() + ")", (i+1).ToString()));
                }
            }
            dr.Close();
        }

        public void DelCat()
        {
            Fn_enc.ExecuteNonQuery("delete from info_component_categories where firm_id=@Param1 and project_id=@Param2 and category_id=@Param3",  new string[] { Session["firmid"].ToString(), Session["projectid"].ToString(), cboCC.Value });
            Fn_enc.ExecuteNonQuery("delete from info_components where firm_id=@Param1 and project_id=@Param2 and category_id=@Param3", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString(), cboCC.Value });
            Fn_enc.ExecuteNonQuery("delete from info_components_images where firm_id=@Param1 and project_id=@Param2 and category_id=@Param3", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString(), cboCC.Value });
            txtCatName.Value = "";
            cboCC.Items.Clear();
            LoadCats();
            ClearLabels();
            lblSaveStatus.InnerHtml = "Successfully deleted category.";
        }

        public void SaveCat()
        {
            if (cboCC.SelectedIndex==0) //New category
            {
                Fn_enc.ExecuteNonQuery("insert into info_component_categories (firm_id, project_id, category_id, category_desc) select @Param1, @Param2, isnull((select max(category_id) from info_component_categories where firm_id=@Param1 and project_id=@Param2),0)+1, @Param3", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString(), txtCatName.Value });
                cboCC.Items.Clear();
                LoadCats();
                cboCC.Value = txtCatName.Value;
                ClearLabels();
                lblSaveStatus.InnerHtml = "Successfully added new category.";
            }
            else
            {
                var iCatID = cboCC.SelectedIndex;
                Fn_enc.ExecuteNonQuery("update info_component_categories set category_desc=@Param1 where firm_id=@Param2 and project_id=@Param3 and category_id=@Param4", new string[] { txtCatName.Value, Session["firmid"].ToString(), Session["projectid"].ToString(), cboCC.Value });
                cboCC.Items.Clear();
                LoadCats();
                //cboCC.Value = txtCatName.Value;
                cboCC.SelectedIndex = iCatID;
                ClearLabels();
                lblSaveStatus.InnerHtml = "Successfully updated category description.";
            }
        }

        public void LoadCategory()
        {
            txtCatName.Value = cboCC.Items[cboCC.SelectedIndex].Text;
            //SqlDataReader dr = Fn_enc.ExecuteReader("select ic.*, icc.category_name from info_components ic inner join info_component_categories icc on ic.firm_id=icc.firm_id and ic.project_id=icc.project_id and ic.category_id=icc.category_id where ic.firm_id=@Param1 and ic.project_id=@Param2 and ic.category_id=@Param3", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString(), cboCC.Value });

        }

        public void DelComponent()
        {
            try
            {
                var sql = $@"insert into hist_info_components_deletes (firm_id, project_id,category_id,component_id,del_id,component_desc,comp_quantity,comp_unit,base_unit_cost,geo_factor,unit_cost,est_useful_life,est_remain_useful_life,comp_note,comp_value,comp_comments,deleted_by,deleted_date,plus_pct)
                            select firm_id, project_id, category_id, component_id, isnull((select max(del_id) from hist_info_components_deletes where firm_id = @Param1 and project_id = @Param2 and year_id = @Param3 and {txtHdnDel.Value}),0)+1,component_desc,comp_quantity,comp_unit,base_unit_cost,geo_factor,unit_cost,est_useful_life,est_remain_useful_life,comp_note,comp_value,comp_comments,{Session["userid"].ToString()},getdate(),plus_pct
                            from info_components where firm_id = @Param1 and project_id = @Param2 and year_id = @Param3 and {txtHdnDel.Value}";
                Fn_enc.ExecuteNonQuery(sql, new string[] { Session["firmid"].ToString(), Session["projectid"].ToString(), cboYear.Value });

                Fn_enc.ExecuteNonQuery("delete from info_components where firm_id=@Param1 and project_id=@Param2 and year_id>=@Param3 and " + txtHdnDel.Value, new string[] { Session["firmid"].ToString(), Session["projectid"].ToString(), cboYear.Value });
                Fn_enc.ExecuteNonQuery("delete from info_components_images where firm_id=@Param1 and project_id=@Param2 and " + txtHdnDel.Value, new string[] { Session["firmid"].ToString(), Session["projectid"].ToString(), cboYear.Value });
            }
            catch (Exception ex)
            {
                lblStatus.InnerHtml = $"Unable to log deletion history. Please notify an administrator. Error: {ex}";
            }
            txtHdnDel.Value = "";
            ClearLabels();
            lblStatus.InnerHtml = "Successfully deleted component.";
        }

        public void LoadCats()
        {
            SqlDataReader dr;

            if (Session["client"].ToString() != "1") { cboCC.Items.Add(new ListItem("New Category", "-1")); }
            dr = Fn_enc.ExecuteReader("select category_id, category_desc from info_component_categories where firm_id=@Param1 and project_id=@Param2", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString() });
            while (dr.Read())
            {
                cboCC.Items.Add(new ListItem(dr["category_desc"].ToString(), dr["category_id"].ToString()));
            }
            dr.Close();
        }

        public void SaveNewComponent()
        {
            Fn_enc.ExecuteNonQuery("insert into info_components (firm_id, project_id, year_id, category_id, component_id, order_id, component_desc, comp_quantity, plus_pct, comp_unit, base_unit_cost, geo_factor, unit_cost, est_useful_life, est_remain_useful_life, comp_note, comp_value, comp_comments, last_updated_by, last_updated_date) select @Param1, @Param2, @Param3, @Param4, isnull((select max(component_id) from info_components where firm_id=@Param1 and project_id=@Param2 and category_id=@Param4),0)+1, isnull((select max(component_id) from info_components where firm_id=@Param1 and project_id=@Param2 and category_id=@Param4),0)+1, @Param5, @Param6, @Param7, @Param8, @Param9, @Param10, @Param11, @Param12, @Param13, @Param14, @Param15, @Param16, @Param17, GetDate()", new string[17] { Session["firmid"].ToString(), Session["projectid"].ToString(), cboYear.Value, cboCC.Value, Request.Form["txt0_0"], Request.Form["txt0_1"], Request.Form["chkPP_0"] == "on" ? Request.Form["txt0_2"] : "0", Request.Form["txt0_3"], Request.Form["txt0_4"], Request.Form["txt0_5"] == "on" ? "1" : "0", Request.Form["txt0_6"], Request.Form["txt0_7"], Request.Form["txt0_8"], Request.Form["txt0_9"], Request.Form["txt0_10"] == "on" ? "1" : "0", Request.Form["txt0_11"], Session["userid"].ToString() });
            ClearLabels();
            lblSaveNew.InnerHtml = "Successfully added new component.";
            txtHdnType.Value = "";
        }

        public void ClearLabels()
        {
            lblSaveNew.InnerHtml = "";
            lblStatus.InnerHtml = "";
            lblSaveStatus.InnerHtml = "";
        }

        [WebMethod(enableSession: true)]
        public static List<string> Prefill(string component)
        {
            List<string> emp = new List<string>();
            if (HttpContext.Current.Session["firmid"] != null)
            {
                var dr = Fn_enc.ExecuteReader("select component_desc, base_unit_cost, geo_factor, estd_useful_life, estd_useful_life_remaining from lkup_component_prefills where firm_id=@Param1 and component_desc like '%' + @Param2 + '%'", new string[] { HttpContext.Current.Session["firmid"].ToString(), component });
                while (dr.Read())
                {
                    emp.Add(string.Format("{0}|{1}|{2}|{3}|{4}", dr["component_desc"], dr["base_unit_cost"], dr["geo_factor"], dr["estd_useful_life"], dr["estd_useful_life_remaining"]));
                }
                dr.Close();
            }
            return emp;
        }
    }
}
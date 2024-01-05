using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Data.SqlClient;
using System.Text;

namespace reserve
{
    public partial class admin_import_project : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["firmid"] == null) Response.Redirect("default.aspx?Timeout=1");
        }

        protected void cmdSave_Click(object sender, EventArgs e)
        {
            var conn = new SqlConnection();
            conn.ConnectionString = System.Configuration.ConfigurationManager.AppSettings["connstr"]; //production

            SqlCommand cmd = new SqlCommand("select project_id, project_name from info_projects where project_id = @Param1", conn);
            cmd.Parameters.Add(new SqlParameter("Param1", txtProjectNum.Value));

            conn.Open();
            SqlDataReader dr = cmd.ExecuteReader();
            if (dr.Read())
            {
                lblProject.InnerHtml = dr["project_name"].ToString();
            }
            dr.Close();
            conn.Close();
        }

        protected void cmdImport_Click(object sender, EventArgs e)
        {
            var conn = new SqlConnection();
            conn.ConnectionString = System.Configuration.ConfigurationManager.AppSettings["connstr"]; //production
            conn.Open();

            var ds = new DataSet();
            var l = new List<string>();
            l.Add("info_projects");
            l.Add("info_projects_revisions");
            l.Add("info_project_info");
            l.Add("info_component_categories");
            l.Add("info_components");
            l.Add("info_components_images");
            l.Add("info_projections");
            l.Add("info_projections_intervals");

            for (var i=0; i<l.Count;i++)
            {
                var tbl = l[i].ToString();
                var adapter = new SqlDataAdapter($"select * from {tbl} where project_id='{txtProjectNum.Value}'",conn);
                adapter.Fill(ds, tbl);
                //Values
                for (var row = 0; row < ds.Tables[tbl].Rows.Count; row++)
                {
                    var sb = new StringBuilder();
                    sb.Append($"insert into {tbl} (");
                    //Column names
                    for (var j = 0; j < ds.Tables[tbl].Columns.Count; j++)
                    {
                        sb.Append(ds.Tables[tbl].Columns[j].ColumnName);
                        if (j < ds.Tables[tbl].Columns.Count - 1) sb.Append(",");
                    }
                    sb.Append(") select ");
                    //values
                    for (var j = 0; j < ds.Tables[tbl].Columns.Count; j++)
                    {
                        var val = ds.Tables[tbl].Rows[row][j].ToString();
                        if (ds.Tables[tbl].Columns[j].ColumnName == "image_bytes")
                        {
                            sb.Append($"convert(varbinary,'{val}')");
                        }
                        else
                        {
                            val = val.Replace("'", "''");
                            sb.Append($"'{val}'");
                        }
                        if (j < ds.Tables[tbl].Columns.Count - 1) sb.Append(",");
                    }
                    Fn_enc.ExecuteNonQuery(sb.ToString(), new string[0]);
                }

            }

            conn.Close();
        }
    }
}
using System;
using System.Web.Services;
using System.Data;
using System.Text;

namespace reserve.api
{
    /// <summary>
    /// Summary description for main
    /// </summary>
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [System.ComponentModel.ToolboxItem(false)]
    // To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
    // [System.Web.Script.Services.ScriptService]
    public class main : System.Web.Services.WebService
    {
        [WebMethod(enableSession: true)]
        public DataSet SaveAvailableClientRevisions(string availableRevs)
        {
            var conn = Fn_enc.getconn();
            DataSet ds = new DataSet();
            DataRow row;

            try
            {
                //Create the results table
                ds.Tables.Add("Results");
                ds.Tables["Results"].Columns.Add("r_type");
                ds.Tables["Results"].Columns.Add("r_desc");

                conn.Open();

                try
                {
                    // The order of operations is that we will add what we need to this table, then we will
                    // call sp_app_add_revisions_to_client, which will propagate all revision data to all other
                    // tables
                    Fn_enc.ExecuteNonQuery("delete from info_projects_client_invites_revisions where firm_id=@Param1 and project_id=@Param2", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString() });
                    Fn_enc.ExecuteNonQuery($"insert into info_projects_client_invites_revisions (firm_id, project_id, revision_id) select firm_id, project_id, revision_id from info_projects_revisions where firm_id=@Param1 and project_id=@Param2 and revision_id in ({availableRevs})", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString() });
                    Fn_enc.ExecuteNonQuery("sp_app_add_revisions_to_client @Param1, @Param2, @Param3", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString(), Session["userid"].ToString() });
                }
                catch (Exception ex)
                {
                    conn.Close();
                    row = ds.Tables["Results"].NewRow();
                    row["r_type"] = "Error";
                    row["r_desc"] = ex.ToString();
                    ds.Tables["Results"].Rows.Add(row);
                    return ds;
                }
                conn.Close();

                row = ds.Tables["Results"].NewRow();
                row["r_type"] = "Success";
                row["r_desc"] = "";
                ds.Tables["Results"].Rows.Add(row);
            }
            catch (Exception ex)
            {
                try
                {
                    conn.Close();
                }
                catch { }
                row = ds.Tables["Results"].NewRow();
                row["r_type"] = "Error";
                row["r_desc"] = ex.ToString();
                ds.Tables["Results"].Rows.Add(row);
            }

            return ds;
        }

        [WebMethod(enableSession: true)]
        public DataSet DeleteRevision(string revId, int iRow)
        {
            var conn = Fn_enc.getconn();
            DataSet ds = new DataSet();
            DataRow row;

            try
            {
                //Create the results table
                ds.Tables.Add("Results");
                ds.Tables["Results"].Columns.Add("iRow");
                ds.Tables["Results"].Columns.Add("r_type");
                ds.Tables["Results"].Columns.Add("r_desc");

                conn.Open();

                try
                {
                    Fn_enc.ExecuteNonQuery("sp_app_delete_project_revision @Param1, @Param2, @Param3", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString(), revId });
                }
                catch (Exception ex)
                {
                    conn.Close();
                    row = ds.Tables["Results"].NewRow();
                    row["r_type"] = "Error";
                    row["r_desc"] = ex.ToString();
                    ds.Tables["Results"].Rows.Add(row);
                    return ds;
                }
                conn.Close();

                row = ds.Tables["Results"].NewRow();
                row["iRow"] = iRow;
                row["r_type"] = "Success";
                row["r_desc"] = "";
                ds.Tables["Results"].Rows.Add(row);
            }
            catch (Exception ex)
            {
                try
                {
                    conn.Close();
                }
                catch { }
                row = ds.Tables["Results"].NewRow();
                row["r_type"] = "Error";
                row["r_desc"] = ex.ToString();
                ds.Tables["Results"].Rows.Add(row);
            }

            return ds;
        }
    }
}

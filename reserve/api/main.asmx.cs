using System;
using System.Web.Services;
using System.Data;
using System.Text;
using System.Collections.Generic;

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

        [WebMethod(enableSession: true)]
        public DataSet SaveProjectInfo(string fieldName, string fieldDesc, string fieldVal, string elemId)
        {
            DataSet ds = new DataSet();
            DataRow row;

            try
            {
                //Create the results table
                ds.Tables.Add("Results");
                ds.Tables["Results"].Columns.Add("iRow");
                ds.Tables["Results"].Columns.Add("r_type");
                ds.Tables["Results"].Columns.Add("r_desc");
                ds.Tables["Results"].Columns.Add("r_field_desc");

                // Project name is located in the info_projects table
                if (fieldName=="pna")
                {
                    Fn_enc.ExecuteNonQuery($"update info_projects set project_name=@Param1, last_updated_by=@Param2, last_updated_date=GetDate() where firm_id=@Param3 and project_id=@Param4", new string[] { fieldVal, Session["userid"].ToString(), Session["firmid"].ToString(), Session["projectid"].ToString() });
                }
                // Makes contact address info same as site
                else if (fieldName=="sameassite")
                {
                    if (elemId=="1")
                    {
                        Fn_enc.ExecuteNonQuery($"update info_project_info set client_addr1=site_addr1, client_addr2=site_addr2, client_state=site_state, client_city=site_city, client_zip=site_zip, last_updated_by=@Param1, last_updated_date=GetDate() where firm_id=@Param2 and project_id=@Param3 and revision_id=@Param4", new string[] { Session["userid"].ToString(), Session["firmid"].ToString(), Session["projectid"].ToString(), Session["revisionid"].ToString() });
                    }
                    else
                    {
                        Fn_enc.ExecuteNonQuery($"update info_project_info set client_addr1=null, client_addr2=null, client_state=null, client_city=null, client_zip=null, last_updated_by=@Param1, last_updated_date=GetDate() where firm_id=@Param2 and project_id=@Param3 and revision_id=@Param4", new string[] { Session["userid"].ToString(), Session["firmid"].ToString(), Session["projectid"].ToString(), Session["revisionid"].ToString() });
                    }
                    // We need to return this because we use r_desc in the javascript to
                    // call the SameAsSite function.
                    row = ds.Tables["Results"].NewRow();
                    row["iRow"] = elemId;
                    row["r_type"] = "Success";
                    row["r_desc"] = fieldName;
                    row["r_field_desc"] = fieldDesc;
                    ds.Tables["Results"].Rows.Add(row);
                    return ds;
                }
                // Makes source names same as contact
                else if (fieldName=="sameascontact")
                {
                    // 1=checked, 0=unchecked
                    if (elemId=="1")
                    {
                        Fn_enc.ExecuteNonQuery($"update info_project_info set source_prefix=contact_prefix, source_name=contact_name, source_title=contact_title, last_updated_by=@Param1, last_updated_date=GetDate() where firm_id=@Param2 and project_id=@Param3 and revision_id=@Param4", new string[] { Session["userid"].ToString(), Session["firmid"].ToString(), Session["projectid"].ToString(), Session["revisionid"].ToString() });
                    }
                    else
                    {
                        Fn_enc.ExecuteNonQuery($"update info_project_info set source_prefix=null, source_name=null, source_title=null, last_updated_by=@Param1, last_updated_date=GetDate() where firm_id=@Param2 and project_id=@Param3 and revision_id=@Param4", new string[] { Session["userid"].ToString(), Session["firmid"].ToString(), Session["projectid"].ToString(), Session["revisionid"].ToString() });
                    }
                    // We need to return this because we use r_desc in the javascript to
                    // call the SameAsClient function.
                    row = ds.Tables["Results"].NewRow();
                    row["iRow"] = elemId;
                    row["r_type"] = "Success";
                    row["r_desc"] = fieldName;
                    row["r_field_desc"] = fieldDesc;
                    ds.Tables["Results"].Rows.Add(row);
                    return ds;
                }
                // All other fields are located in the info_project_info table
                else
                {
                    // Get the field mapping from the abbreviation we passed in
                    var fm = GetFieldName(fieldName);
                    if (string.IsNullOrEmpty(fm))
                    {
                        row = ds.Tables["Results"].NewRow();
                        row["r_type"] = "Error";
                        row["r_desc"] = "Could not find field mapping.";
                        row["r_field_desc"] = fieldDesc;
                        ds.Tables["Results"].Rows.Add(row);
                        return ds;
                    }

                    Fn_enc.ExecuteNonQuery($"update info_project_info set {fm}=@Param1, last_updated_by=@Param2, last_updated_date=GetDate() where firm_id=@Param3 and project_id=@Param4 and revision_id=@Param5", new string[] { fieldVal, Session["userid"].ToString(), Session["firmid"].ToString(), Session["projectid"].ToString(), Session["revisionid"].ToString() });
                    // Geo factor change requires that we call a stored proc
                    if (fieldName=="gfa")
                    {
                        try
                        {
                            Fn_enc.ExecuteNonQuery("sp_app_project_geofactor @Param1, @Param2, @Param3, @Param4", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString(), Session["revisionid"].ToString(), fieldVal });
                        }
                        catch (Exception ex)
                        {
                            row = ds.Tables["Results"].NewRow();
                            row["r_type"] = "Error";
                            row["r_desc"] = "Successfully saved geo factor, but error updating projections: " + ex.ToString();
                            row["r_field_desc"] = fieldDesc;
                            ds.Tables["Results"].Rows.Add(row);
                            return ds;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                row = ds.Tables["Results"].NewRow();
                row["r_type"] = "Error";
                row["r_desc"] = ex.ToString();
                row["r_field_desc"] = fieldDesc;
                ds.Tables["Results"].Rows.Add(row);
                return ds;
            }
            // FieldVal is returned so we can update the javascript array with the new value.
            // FieldDesc is returned so we can update the status with the friendly field name.
            row = ds.Tables["Results"].NewRow();
            row["iRow"] = elemId;
            row["r_type"] = "Success";
            row["r_desc"] = fieldVal;
            row["r_field_desc"] = fieldDesc;
            ds.Tables["Results"].Rows.Add(row);
            return ds;
        }

        private string GetFieldName(string fieldAbbr)
        {
            var fm = new Dictionary<string, string>()
            {
                { "aco", "age_community" },
                { "ana", "association_name" },
                { "bba", "begin_balance" },
                { "bfu", "baseline_funding_hidden" },
                { "bpc", "baseline_pct_funded_hidden" },
                { "ca1", "client_addr1" },
                { "ca2", "client_addr2" },
                { "cco", "current_contrib" },
                { "cci", "client_city" },
                { "cem", "contact_email" },
                { "cfu", "current_funding_hidden" },
                { "cna", "contact_name" },
                { "cpc", "current_pct_funded_hidden" },
                { "cpr", "contact_prefix" },
                { "cph", "contact_phone" },
                { "cst", "client_state" },
                { "cti", "contact_title" },
                { "cva", "contract_value" },
                { "czi", "client_zip" },
                { "dma", "dept_mgr" },
                { "ffu", "full_funding_hidden" },
                { "fpc", "full_pct_funded_hidden" },
                { "gfa", "geo_factor" },
                { "ida", "inspection_date" },
                { "inf", "inflation" },
                { "int", "interest" },
                { "nbl", "num_bldgs" },
                { "nfl", "num_floors" },
                { "nun", "num_units" },
                { "pmg", "project_mgr" },
                { "pna", "project_name" },
                { "ppr", "prev_preparer" },
                { "pre", "prev_recomm_cont" },
                { "pst", "prev_date" },
                { "pty", "project_type_id" },
                { "ref", "report_effective" },
                { "sa1", "site_addr1" },
                { "sa2", "site_addr2" },
                { "sbe", "source_begin_balance" },
                { "sci", "site_city" },
                { "sna", "source_name" },
                { "spr", "source_prefix" },
                { "sst", "site_state" },
                { "sti", "source_title" },
                { "szi", "site_zip" },
                { "t1u", "threshold1_used" },
                { "t1v", "threshold1_value" },
                { "t2u", "threshold2_used" },
                { "tp1", "threshold1_pct_funded_hidden" },
                { "tp2", "threshold2_pct_funded_hidden" }
            };

            return fm[fieldAbbr];
        }

        [WebMethod(enableSession: true)]
        public DataSet CreateProject(string projectId, string projectName, string reportEffective)
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
                    var dr = Fn_enc.ExecuteReader("sp_app_create_project @Param1, @Param2, @Param3, @Param4, @Param5", new string[] { Session["firmid"].ToString(), projectId, projectName, reportEffective, Session["userid"].ToString() });
                    if (dr.Read())
                    {
                        if (dr["result"].ToString()=="ProjectValidationError")
                        {
                            row = ds.Tables["Results"].NewRow();
                            row["r_type"] = "Error";
                            row["r_desc"] = dr["error"];
                            ds.Tables["Results"].Rows.Add(row);
                            return ds;
                        }
                        else
                        {
                            row = ds.Tables["Results"].NewRow();
                            row["r_type"] = "Success";
                            row["r_desc"] = "";
                            ds.Tables["Results"].Rows.Add(row);
                            return ds;
                        }
                    }
                    else
                    {
                        row = ds.Tables["Results"].NewRow();
                        row["r_type"] = "Error";
                        row["r_desc"] = "The projection creation returned no results. Please try again, and if the problem persists, please notify an administrator.";
                        ds.Tables["Results"].Rows.Add(row);
                        return ds;
                    }
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
    }
}

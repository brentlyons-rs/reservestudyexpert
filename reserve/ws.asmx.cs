using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.Script.Services;
using System.Web.Script.Serialization;
using Newtonsoft.Json;

namespace reserve
{
    /// <summary>
    /// Summary description for ws
    /// </summary>
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [System.ComponentModel.ToolboxItem(false)]
    // To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
    [System.Web.Script.Services.ScriptService]
    public class ws : System.Web.Services.WebService
    {
        //iRow,cid,desc,qty,pp,unit,buc,geo,uc,eul,erul,note,val,comm,pd
        [WebMethod(enableSession: true)]
        public DataSet AddComponent(string iRow, string iCol, string cYr, string cCat, string cID, string cDesc, string cQty, string cPP, string cUnit, string cBuc, string cGeo, string cUc, string cEul, string cErul, string cNote, string cVal, string cComm, string pd)
        {
            var conn = Fn_enc.getconn();
            SqlCommand command;
            SqlDataReader dr;
            DataSet ds = new DataSet();
            DataRow row;
            var sqlUpdate = new StringBuilder();


            try
            {
                //Create the results table
                ds.Tables.Add("Results");
                ds.Tables["Results"].Columns.Add("i_row");
                ds.Tables["Results"].Columns.Add("i_col");
                ds.Tables["Results"].Columns.Add("r_field");
                ds.Tables["Results"].Columns.Add("r_type");
                ds.Tables["Results"].Columns.Add("r_desc");

                conn.Open();

                try
                {
                    sqlUpdate.Append("insert into info_components (firm_id, project_id, year_id, category_id, component_id, order_id, component_desc, comp_quantity, plus_pct, comp_unit, base_unit_cost, geo_factor, unit_cost, est_useful_life, est_remain_useful_life, comp_note, comp_value, comp_comments, last_updated_by, last_updated_date)");
                    sqlUpdate.Append("select @Param1, @Param2, @Param3, @Param4, @Param5, @Param6, @Param7, @Param8, @Param9, @Param10, @Param11, @Param12, @Param13, @Param14, @Param15, @Param16, @Param17, @Param18, @Param19, getdate()");

                    Fn_enc.ExecuteNonQuery(sqlUpdate.ToString(), new string[19] { Session["firmid"].ToString(), Session["projectid"].ToString(), cYr, cCat, cID, cID, cDesc, cQty, cPP, cUnit, cBuc, cGeo, cUc, cEul, cErul, cNote, cVal, cComm, Session["userid"].ToString() });
                }
                catch (Exception ex)
                {
                    conn.Close();
                    row = ds.Tables["Results"].NewRow();
                    row["i_row"] = iRow;
                    row["i_col"] = iCol;
                    row["r_type"] = "Error";
                    row["r_desc"] = ex.ToString() + ", SQL: " + sqlUpdate;
                    ds.Tables["Results"].Rows.Add(row);
                    return ds;
                }
                conn.Close();

                row = ds.Tables["Results"].NewRow();
                row["i_row"] = iRow;
                row["i_col"] = iCol;
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
                row["i_row"] = iRow;
                row["i_col"] = iCol;
                row["r_type"] = "Error";
                row["r_desc"] = ex.ToString();
                ds.Tables["Results"].Rows.Add(row);
            }

            return ds;
        }

        [WebMethod(enableSession:true)]
        public DataSet SaveThreshold(string sThreshold)
        {
            DataSet ds = new DataSet();
            DataRow row;

            try
            {
                //Create the results table
                ds.Tables.Add("Results");
                ds.Tables["Results"].Columns.Add("r_type");
                ds.Tables["Results"].Columns.Add("r_desc");

                try
                {
                    if (sThreshold=="true")
                    {
                        Fn_enc.ExecuteNonQuery("update info_project_info set threshold_used=1 where firm_id=@Param1 and project_id=@Param2", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString() });
                    }
                    else
                    {
                        Fn_enc.ExecuteNonQuery("update info_project_info set threshold_used=0 where firm_id=@Param1 and project_id=@Param2", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString() });
                    }
                }
                catch (Exception ex)
                {
                    row = ds.Tables["Results"].NewRow();
                    row["r_type"] = "Error";
                    row["r_desc"] = ex.ToString();
                    ds.Tables["Results"].Rows.Add(row);
                    return ds;
                }

                row = ds.Tables["Results"].NewRow();
                row["r_type"] = "Success";
                row["r_desc"] = "";
                ds.Tables["Results"].Rows.Add(row);
            }
            catch (Exception ex)
            {
                row = ds.Tables["Results"].NewRow();
                row["r_type"] = "Error";
                row["r_desc"] = ex.ToString();
                ds.Tables["Results"].Rows.Add(row);
            }

            return ds;
        }

        [WebMethod(enableSession: true)]
        public DataSet SaveChkDisp(int iField, string sVal)
        {
            DataSet ds = new DataSet();
            DataRow row;
            string sField="";

            try
            {
                //Create the results table
                ds.Tables.Add("Results");
                ds.Tables["Results"].Columns.Add("r_type");
                ds.Tables["Results"].Columns.Add("r_desc");
                ds.Tables["Results"].Columns.Add("i_field");

                switch (iField)
                {
                    case 1:
                        sField = "current_funding_hidden";
                        break;
                    case 2:
                        sField = "full_funding_hidden";
                        break;
                    case 3:
                        sField = "baseline_funding_hidden";
                        break;
                }
                try
                {
                    Fn_enc.ExecuteNonQuery("update info_project_info set " + sField + "=" + sVal + " where firm_id=@Param1 and project_id=@Param2", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString() });
                }
                catch (Exception ex)
                {
                    row = ds.Tables["Results"].NewRow();
                    row["r_type"] = "Error";
                    row["r_desc"] = ex.ToString();
                    row["i_field"] = iField;
                    ds.Tables["Results"].Rows.Add(row);
                    return ds;
                }

                row = ds.Tables["Results"].NewRow();
                row["r_type"] = "Success";
                row["r_desc"] = "";
                row["i_field"] = iField;
                ds.Tables["Results"].Rows.Add(row);
            }
            catch (Exception ex)
            {
                row = ds.Tables["Results"].NewRow();
                row["r_type"] = "Error";
                row["r_desc"] = ex.ToString();
                row["i_field"] = iField;
                ds.Tables["Results"].Rows.Add(row);
            }

            return ds;
        }

        [WebMethod(enableSession: true)]
        public DataSet SaveGraphThreshold(int iYear, string sVal)
        {
            DataSet ds = new DataSet();
            DataRow row;

            try
            {
                //Create the results table
                ds.Tables.Add("Results");
                ds.Tables["Results"].Columns.Add("r_type");
                ds.Tables["Results"].Columns.Add("r_desc");
                var conn = Fn_enc.getconn();

                try
                {
                    conn.Open();
                    SqlDataAdapter adapter = new SqlDataAdapter("sp_app_rvw_graph_threshold @Param1, @Param2, @Param3, @Param4", conn);
                    adapter.SelectCommand.Parameters.AddWithValue("Param1", Session["firmid"].ToString());
                    adapter.SelectCommand.Parameters.AddWithValue("Param2", Session["projectid"].ToString());
                    adapter.SelectCommand.Parameters.AddWithValue("Param3", iYear.ToString());
                    adapter.SelectCommand.Parameters.AddWithValue("Param4", sVal);
                    adapter.Fill(ds, "Threshold");

                    row = ds.Tables["Results"].NewRow();
                    row["r_type"] = "Success";
                    row["r_desc"] = "";
                    ds.Tables["Results"].Rows.Add(row);
                }
                catch (Exception ex)
                {
                    row = ds.Tables["Results"].NewRow();
                    row["r_type"] = "Error";
                    row["r_desc"] = ex.ToString();
                    ds.Tables["Results"].Rows.Add(row);
                }
                finally
                {
                    conn.Close();
                }
                return ds;
            }
            catch (Exception ex)
            {
                row = ds.Tables["Results"].NewRow();
                row["r_type"] = "Error";
                row["r_desc"] = ex.ToString();
                ds.Tables["Results"].Rows.Add(row);
            }

            return ds;
        }

        [WebMethod(enableSession: true)]
        public DataSet SaveReview(string sTable, string sCrit, string sField, string sVal, int iRow, int iCol, string pd)
        {
            var conn = Fn_enc.getconn();

            SqlCommand command;
            DataSet ds = new DataSet();
            DataRow row;
            var sqlUpdate = new StringBuilder();
            var sNewVal = new StringBuilder();
            string sSQLTable;


            try
            {
                switch (sTable)
                {
                    case "proj":
                        {
                            sSQLTable = "info_projections";
                            break;
                        }
                    default:
                        {
                            sSQLTable = "";
                            break;
                        }
                }
                //Create the results table
                ds.Tables.Add("Results");
                ds.Tables["Results"].Columns.Add("i_row");
                ds.Tables["Results"].Columns.Add("i_col");
                ds.Tables["Results"].Columns.Add("r_field");
                ds.Tables["Results"].Columns.Add("r_type");
                ds.Tables["Results"].Columns.Add("r_desc");

                conn.Open();

                try
                {
                    sNewVal.Append(sVal.ToString().Replace("'", "''"));
                    sNewVal.Replace("$", "");
                    sNewVal.Replace(",", "");
                    if (sField=="pct_increase_all")
                        sqlUpdate.Append("update info_projections set tfa2_annual_contr_user_entered=null, generated_by=" + Session["userid"].ToString() + ", generated_date=GetDate(), pct_increase='" + sNewVal + "' where firm_id=" + Session["firmid"] + " and project_id='" + Session["projectid"] + "'");
                    else if (sField == "cfa_annual_contrib")
                        sqlUpdate.Append("update " + sSQLTable + " set cfa_annual_contrib_user_entered=1, generated_by=" + Session["userid"].ToString() + ", generated_date=GetDate(), " + sField + "='" + sNewVal + "' where firm_id=" + Session["firmid"] + " and project_id='" + Session["projectid"] + "' and " + sCrit);
                    else if (sField== "tfa2_annual_contr")
                        sqlUpdate.Append("update " + sSQLTable + " set tfa2_annual_contr_user_entered=1, generated_by=" + Session["userid"].ToString() + ", generated_date=GetDate(), " + sField + "='" + sNewVal + "', pct_increase=null where firm_id=" + Session["firmid"] + " and project_id='" + Session["projectid"] + "' and " + sCrit);
                    else if (sField == "pct_increase")
                        sqlUpdate.Append("update " + sSQLTable + " set tfa2_annual_contr_user_entered=null, generated_by=" + Session["userid"].ToString() + ", generated_date=GetDate(), " + sField + "='" + sNewVal + "' where firm_id=" + Session["firmid"] + " and project_id='" + Session["projectid"] + "' and " + sCrit.Replace("year_id=","year_id>="));
                    else
                        sqlUpdate.Append("update " + sSQLTable + " set generated_by=" + Session["userid"].ToString() + ", generated_date=GetDate(), " + sField + "='" + sNewVal + "' where firm_id=" + Session["firmid"] + " and project_id='" + Session["projectid"] + "' and " + sCrit);
                    command = new SqlCommand(sqlUpdate.ToString(), conn);
                    command.ExecuteNonQuery();
                    //If CFA is being updated, we need to update all the reserve fund balances, then return updated data
                    if (sField=="cfa_annual_contrib")
                    {
                        SqlDataAdapter adapter = new SqlDataAdapter("sp_app_proj_cfa " + Session["firmid"].ToString() + ",'" + Session["projectid"].ToString() + "'", conn);
                        adapter.Fill(ds, "cfa");
                    }
                    //If an adjusted threshold field is being updated, we need to update all the numbers for those columns, then return updated data.
                    else if ((sField=="tfa2_annual_contr") || (sField=="pct_increase") || (sField=="pct_increase_all") || (sField=="tfa2_reserve_fund_bal"))
                    {
                        SqlDataAdapter adapter = new SqlDataAdapter("sp_app_proj_adj_threshold " + Session["firmid"].ToString() + ",'" + Session["projectid"].ToString() + "'", conn);
                        adapter.Fill(ds, "adjthresh");
                    }
                }
                catch (Exception ex)
                {
                    row = ds.Tables["Results"].NewRow();
                    row["i_row"] = iRow;
                    row["i_col"] = iCol;
                    row["r_field"] = sField;
                    row["r_type"] = "Error";
                    row["r_desc"] = ex.ToString() + ", SQL: " + sqlUpdate;
                    ds.Tables["Results"].Rows.Add(row);
                    return ds;
                }
                conn.Close();

                row = ds.Tables["Results"].NewRow();
                row["i_row"] = iRow;
                row["i_col"] = iCol;
                row["r_field"] = sField;
                row["r_type"] = "Success";
                row["r_desc"] = sVal;
                ds.Tables["Results"].Rows.Add(row);
            }
            catch (Exception ex)
            {
                row = ds.Tables["Results"].NewRow();
                row["i_row"] = iRow;
                row["i_col"] = iCol;
                row["r_field"] = sField;
                row["r_type"] = "Error";
                row["r_desc"] = ex.ToString();
                ds.Tables["Results"].Rows.Add(row);
            }

            return ds;
        }

        [WebMethod(enableSession: true)]
        public DataSet SaveComponent(string sCrit, string sField, string sVal, int iRow, int iCol, string pd)
        {
            var conn = Fn_enc.getconn();

            SqlCommand command;
            SqlDataReader dr;
            DataSet ds = new DataSet();
            DataRow row;
            var sqlUpdate = new StringBuilder();


            try
            {
                //Create the results table
                ds.Tables.Add("Results");
                ds.Tables["Results"].Columns.Add("i_row");
                ds.Tables["Results"].Columns.Add("i_col");
                ds.Tables["Results"].Columns.Add("r_field");
                ds.Tables["Results"].Columns.Add("r_type");
                ds.Tables["Results"].Columns.Add("r_desc");

                conn.Open();

                try
                {
                    if (sField == "base_unit_cost") //If base unit cost changes, then update the unit cost based on geo factor selection
                    {
                        var baseUnitCost = sVal.Replace("'", "").Replace(",", "").Replace("$", "");
                        var unitCost = baseUnitCost;
                        dr = Fn_enc.ExecuteReader("select geo_factor, isnull((select geo_factor from info_components where firm_id=@Param1 and project_id=@Param2 and  " + sCrit + "),0) as geo_factor_used from info_project_info where firm_id=@Param1 and project_id=@Param2", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString() });
                        if ((dr.Read()) && (!dr.IsDBNull(0)) && (dr["geo_factor_used"].ToString()=="True")) unitCost = (Convert.ToDouble(baseUnitCost) * Convert.ToDouble(dr["geo_factor"].ToString())).ToString();
                        dr.Close();

                        sqlUpdate.Append("update info_components set last_updated_by=" + Session["userid"].ToString() + ", last_updated_date=GetDate(), base_unit_cost=" + baseUnitCost + ", unit_cost='" + unitCost + "' where firm_id=" + Session["firmid"] + " and project_id='" + Session["projectid"] + "' and " + sCrit);
                        command = new SqlCommand(sqlUpdate.ToString(), conn);
                        command.ExecuteNonQuery();

                        row = ds.Tables["Results"].NewRow();
                        row["i_row"] = iRow;
                        row["i_col"] = 6;
                        row["r_field"] = "unit_cost";
                        row["r_type"] = "Success";
                        row["r_desc"] = string.Format("{0:n}", Convert.ToDouble(unitCost));
                        ds.Tables["Results"].Rows.Add(row);
                    }
                    else if (sField == "geo_factor") //If geo factor changes, update unit cost
                    {
                        dr = Fn_enc.ExecuteReader("select geo_factor, isnull((select base_unit_cost from info_components where firm_id=@Param1 and project_id=@Param2 and " + sCrit + "),0) as base_unit_cost from info_project_info where firm_id=@Param1 and project_id=@Param2", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString() });
                        var dataPresent = dr.Read();

                        var unitCost ="";
                        if (sVal=="0")
                        {
                            if (dataPresent) unitCost = dr["base_unit_cost"].ToString();
                        }
                        else
                        {
                            if (dataPresent) unitCost = (Convert.ToDouble(dr["base_unit_cost"].ToString()) * Convert.ToDouble(dr["geo_factor"].ToString())).ToString();
                        }
                        dr.Close();
                        sqlUpdate.Append("update info_components set last_updated_by=" + Session["userid"].ToString() + ", last_updated_date=GetDate(), geo_factor='" + sVal + "', unit_cost=" + unitCost + " where firm_id=" + Session["firmid"] + " and project_id='" + Session["projectid"] + "' and " + sCrit);
                        command = new SqlCommand(sqlUpdate.ToString(), conn);
                        command.ExecuteNonQuery();

                        row = ds.Tables["Results"].NewRow();
                        row["i_row"] = iRow;
                        row["i_col"] = 6;
                        row["r_field"] = "unit_cost";
                        row["r_type"] = "Success";
                        row["r_desc"] = string.Format("{0:n}", Convert.ToDouble(unitCost));
                        ds.Tables["Results"].Rows.Add(row);
                    }
                    else if (sField=="order_id") //User dragged-dropped a component
                    {
                        command = new SqlCommand("update info_components set order_id = order_id+1 where firm_id=" + Session["firmid"] + " and project_id='" + Session["projectid"] + "' and order_id>=" + sVal.ToString() + " and " + sCrit.Substring(1, sCrit.IndexOf("and component_id")-1), conn);
                        command.ExecuteNonQuery();
                        command = new SqlCommand("update info_components set last_updated_by = " + Session["userid"].ToString() + ", last_updated_date = GetDate(), order_id = " + sVal.ToString() + " where firm_id=" + Session["firmid"] + " and project_id='" + Session["projectid"] + "' and " + sCrit, conn);
                        command.ExecuteNonQuery();
                    }
                    else
                    {
                        sqlUpdate.Append("update info_components set last_updated_by=" + Session["userid"].ToString() + ", last_updated_date=GetDate(), " + sField + "='" + sVal.ToString().Replace("'", "''").Replace(",","") + "' where firm_id=" + Session["firmid"] + " and project_id='" + Session["projectid"] + "' and " + sCrit);
                        command = new SqlCommand(sqlUpdate.ToString(), conn);
                        command.ExecuteNonQuery();
                    }
                    row = ds.Tables["Results"].NewRow();
                    row["i_row"] = iRow;
                    row["i_col"] = iCol;
                    row["r_field"] = sField;
                    row["r_type"] = "Success";
                    row["r_desc"] = sVal;
                    ds.Tables["Results"].Rows.Add(row);
                }
                catch (Exception ex)
                {
                    row = ds.Tables["Results"].NewRow();
                    row["i_row"] = iRow;
                    row["i_col"] = iCol;
                    row["r_field"] = sField;
                    row["r_type"] = "Error";
                    row["r_desc"] = ex.ToString() + ", SQL: " + sqlUpdate;
                    ds.Tables["Results"].Rows.Add(row);
                    return ds;
                }
                conn.Close();
            }
            catch (Exception ex)
            {
                row = ds.Tables["Results"].NewRow();
                row["i_row"] = iRow;
                row["i_col"] = iCol;
                row["r_field"] = sField;
                row["r_type"] = "Error";
                row["r_desc"] = ex.ToString();
                ds.Tables["Results"].Rows.Add(row);
            }

            return ds;
        }

        [WebMethod]
        public DataSet GetComponents(int fid, string p, int cid)
        {

            var conn = Fn_enc.getconn();
            StringBuilder project = new StringBuilder(p);
            project.Replace("'", "''");
            project.Replace("@", "");
            project.Replace("--", "");

            conn.Open();
            DataSet ds = new DataSet();
            SqlDataAdapter adapter = new SqlDataAdapter("select component_id, component_desc from info_components where firm_id=@Param1 and project_id=@Param2 and category_id=@Param3 order by order_id", conn);
            adapter.SelectCommand.Parameters.AddWithValue("@Param1", fid);
            adapter.SelectCommand.Parameters.AddWithValue("@Param2", project.ToString());
            adapter.SelectCommand.Parameters.AddWithValue("@Param3", cid);
            adapter.Fill(ds, "Components");
            conn.Close();

            return ds;

        }

        [WebMethod]
        public DataSet GetCompCats(int fid, string p)
        {

            var conn = Fn_enc.getconn();
            StringBuilder project = new StringBuilder(p);
            project.Replace("'", "''");
            project.Replace("@", "");
            project.Replace("--", "");

            conn.Open();
            DataSet ds = new DataSet();
            SqlDataAdapter adapter = new SqlDataAdapter("select category_id, category_desc from info_component_categories where firm_id=@Param1 and project_id=@Param2", conn);
            adapter.SelectCommand.Parameters.AddWithValue("@Param1", fid);
            adapter.SelectCommand.Parameters.AddWithValue("@Param2", project.ToString());
            adapter.Fill(ds, "Categories");
            conn.Close();

            return ds;

        }

        [WebMethod]
        public DataSet GetProjects(int fid, string p)
        {

            var conn = Fn_enc.getconn();
            StringBuilder search = new StringBuilder(p);
            search.Replace("'", "''");
            search.Replace("@", "");
            search.Replace("--", "");

            conn.Open();
            DataSet ds = new DataSet();
            SqlDataAdapter adapter = new SqlDataAdapter("select project_id, project_name from info_projects where firm_id=@Param1 and project_name like @Param2", conn);
            adapter.SelectCommand.Parameters.AddWithValue("@Param1", fid);
            adapter.SelectCommand.Parameters.AddWithValue("@Param2", "%" + search + "%");
            adapter.Fill(ds, "results");
            conn.Close();

            return ds;

        }

        [WebMethod(enableSession: true)]
        public DataSet SaveTM(int iTbl, string sCrit, string sField, string sVal, int iRow, int iCol, string pd)
        {
            var conn = Fn_enc.getconn();
            SqlCommand command;
            SqlDataReader dr;
            DataSet ds = new DataSet();
            DataRow row;
            String sTbl;
            var sqlUpdate = new StringBuilder();


            try
            {
                //Create the results table
                ds.Tables.Add("Results");
                ds.Tables["Results"].Columns.Add("i_row");
                ds.Tables["Results"].Columns.Add("i_col");
                ds.Tables["Results"].Columns.Add("r_field");
                ds.Tables["Results"].Columns.Add("r_type");
                ds.Tables["Results"].Columns.Add("r_desc");

                conn.Open();

                dr = Fn_enc.ExecuteReader("select table_name_real from lkup_tm_tables where firm_id=@Param1 and table_id=@Param2", new string[] { HttpContext.Current.Session["firmid"].ToString(), iTbl.ToString() });
                if (dr.Read())
                {
                    sTbl = dr["table_name_real"].ToString();
                }
                else
                {
                    row = ds.Tables["Results"].NewRow();
                    row["i_row"] = iRow;
                    row["i_col"] = iCol;
                    row["r_field"] = sField;
                    row["r_type"] = "Error";
                    row["r_desc"] = "Could not locate the table_id. Please contact an administrator.";
                    ds.Tables["Results"].Rows.Add(row);
                    return ds;
                }
                dr.Close();

                try
                {
                    sqlUpdate.Append("update " + sTbl + " set " + sField + "='" + sVal.ToString().Replace("'", "''") + "'");
                    dr = Fn_enc.ExecuteReader("select field_type,field_name from lkup_tm_tables_fields where firm_id=@Param1 and table_id=@Param2 and field_type in ('lub','lud')", new string[] { HttpContext.Current.Session["firmid"].ToString(), iTbl.ToString() });
                    while (dr.Read())
                    {
                        if (dr["field_type"].ToString() == "lub") sqlUpdate.Append("," + dr["field_name"].ToString() + "=" + HttpContext.Current.Session["userid"].ToString());
                        else if (dr["field_type"].ToString() == "lud") sqlUpdate.Append("," + dr["field_name"].ToString() + "=GetDate()");
                    }
                    dr.Close();
                    sqlUpdate.Append(" where firm_id=" + HttpContext.Current.Session["firmid"].ToString() + " and " + sCrit);
                    command = new SqlCommand(sqlUpdate.ToString(), conn);
                    command.ExecuteNonQuery();
                }
                catch (Exception ex)
                {
                    row = ds.Tables["Results"].NewRow();
                    row["i_row"] = iRow;
                    row["i_col"] = iCol;
                    row["r_field"] = sField;
                    row["r_type"] = "Error";
                    row["r_desc"] = ex.ToString() + ", SQL: " + sqlUpdate;
                    ds.Tables["Results"].Rows.Add(row);
                    return ds;
                }
                conn.Close();

                row = ds.Tables["Results"].NewRow();
                row["i_row"] = iRow;
                row["i_col"] = iCol;
                row["r_field"] = sField;
                row["r_type"] = "Success";
                row["r_desc"] = sVal;
                ds.Tables["Results"].Rows.Add(row);
            }
            catch (Exception ex)
            {
                row = ds.Tables["Results"].NewRow();
                row["i_row"] = iRow;
                row["i_col"] = iCol;
                row["r_field"] = sField;
                row["r_type"] = "Error";
                row["r_desc"] = ex.ToString();
                ds.Tables["Results"].Rows.Add(row);
            }

            return ds;
        }
    }

}

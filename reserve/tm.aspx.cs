using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Services;
using System.Data;
using System.Data.SqlClient;
using System.Text;

namespace reserve
{
    public partial class tm : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

            SqlDataReader dr;

            if (Session["firmid"] == null) Response.Redirect("default.aspx?Timeout=1");

            if (cboTable.Value != "") {
                if (cboFilter.Items.Count==0)
                {
                    dr = Fn_enc.ExecuteReader("select param_id, param_name from lkup_tm_tables_params where firm_id=@Param1 and table_id=@Param2", new string[] { Session["firmid"].ToString(), cboTable.Value });
                    while (dr.Read())
                    {
                        cboFilter.Items.Add(new ListItem(dr["param_name"].ToString(), dr["param_id"].ToString()));
                        if (cboFilter.Value == dr["param_id"].ToString()) cboFilter.Items[cboFilter.Items.Count - 1].Selected = true;
                    }
                    dr.Close();
                }
            }
            else if (cboTable.Items.Count==0)
            {
                dr = Fn_enc.ExecuteReader("select * from lkup_tm_tables where firm_id=@Param1", new string[] { Session["firmid"].ToString() });
                while (dr.Read())
                {
                    cboTable.Items.Add(new ListItem(dr["table_name_display"].ToString(), dr["table_id"].ToString()));
                }
                dr.Close();
            }

            if (txtHdnType.Value == "Add") addNew();
            else if (txtHdnType.Value == "Del") delRow();
        }



        public void popCbo(DataTable dt, string dft) { 
            for (var i = 0; i<dt.Rows.Count - 1; i++) {
                if (dft == dt.Rows[i]["opt_id"].ToString()) {
                    Response.Write("<option selected value=\"" + dt.Rows[i]["opt_id"].ToString() + "\">" + dt.Rows[i]["opt_text"].ToString() + "</option>");
                } else {
                    Response.Write("<option value=\"" + dt.Rows[i]["opt_id"].ToString() + "\">" + dt.Rows[i]["opt_text"].ToString() + "</option>");
                }
            }
        }

        public void delRow()
        {
            string strTable = "";
            var drtemp = reserve.Fn_enc.ExecuteReader("select table_name_real, allow_deletes from lkup_tm_tables where firm_id=@Param1 and table_id=@Param2", new string[] { Session["firmid"].ToString(), cboTable.Value });
            if (drtemp.Read())
            {
                strTable = drtemp["table_name_real"].ToString();
            }
            drtemp.Close();

            Fn_enc.ExecuteNonQuery("sp_app_tm_del @Param1,@Param2,@Param3", new string[] { Session["firmid"].ToString(), strTable , txtHdnDel.Value });
            txtHdnType.Value = "";
            lblStatus.InnerHtml = "Successfully deleted record.";
        }

        public void addNew()
        {
            var connadd = Fn_enc.getconn();
            var sql = new StringBuilder(); var tbl = ""; List<string> parms = new List<string>(); int iCol;

            SqlDataReader drt; DataSet ds = new DataSet(); SqlDataAdapter adapter;

            connadd.Open();
            drt = Fn_enc.ExecuteReader("select table_sql, table_name_real from lkup_tm_tables where firm_id=@Param1 and table_id=@Param2", new string[] { Session["firmid"].ToString(), cboTable.Value });
            if (drt.Read())
            {
                adapter = new SqlDataAdapter("select * from lkup_tm_tables_fields where field_type in ('lub','lud') and firm_id=" + Session["firmid"].ToString() + " and table_id=" + cboTable.Value, connadd);
                adapter.Fill(ds, "table");
                DataView dvw = new DataView(ds.Tables["table"]);

                tbl = drt["table_name_real"].ToString();

                sql.Append(drt["table_sql"].ToString().Replace("select", "select top 1"));
                drt.Close();
                drt = Fn_enc.ExecuteReader(sql.ToString(), null);
                sql.Clear();
                sql.Append("insert into " + tbl + " (");
                for (iCol = 0; iCol < drt.FieldCount; iCol++)
                {
                    sql.Append(drt.GetName(iCol));
                    if (iCol < drt.FieldCount - 1) sql.Append(",");
                }
                sql.Append(") select ");
                for (iCol = 0; iCol < drt.FieldCount; iCol++)
                {
                    sql.Append("@Param" + (iCol + 1).ToString());
                    if (iCol < drt.FieldCount - 1) sql.Append(",");

                    dvw.RowFilter = "field_name='" + drt.GetName(iCol) + "'";
                    if (dvw.Count > 0)
                    {
                        switch (dvw.ToTable().Rows[0]["field_type"].ToString())
                        {
                            case "lud":
                                parms.Add(DateTime.Now.ToString());
                                break;
                            case "lub":
                                parms.Add(Session["userid"].ToString());
                                break;
                            default:
                                parms.Add("Null");
                                break;
                        }
                    }
                    else
                    {
                        if (drt.GetDataTypeName(iCol).ToString() == "bit")
                        {
                            if (Request.Form["txtNew" + iCol] == "on") parms.Add("1");
                            else parms.Add("0");
                        }
                        else if ((drt.GetDataTypeName(iCol).ToString() == "smallint") || (drt.GetDataTypeName(iCol).ToString() == "double") || (drt.GetDataTypeName(iCol).ToString() == "float")) parms.Add(Request.Form["txtNew" + iCol]);
                        else if (Request.Form["txtNew" + iCol].ToString() != "") parms.Add(Request.Form["txtNew" + iCol].ToString());
                        else parms.Add("Null");
                    }
                }
                drt.Close();
                Fn_enc.ExecuteNonQuery(sql.ToString(), parms.ToArray());
            }
            connadd.Close();
            txtHdnType.Value = "";
            lblStatus.InnerHtml = "Successfully added record.";
        }

    }
}
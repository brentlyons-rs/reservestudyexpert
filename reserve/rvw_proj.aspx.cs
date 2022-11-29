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
    public partial class rvw_proj : System.Web.UI.Page
    {
        public void GenerateProjections_OLD()
        {
            //Step 1: generate the initial numbers from the db.
            //Fn_enc.ExecuteNonQuery("sp_app_rvw_proj1 @Param1, @Param2", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString() });

            //double beginBal = 0;
            //double thresholdValue = 0;
            //double inflation = 0;
            //double curContrib = 0;
            //Boolean blThreshold = false;
            //var conn = new SqlConnection();
            //if (HttpContext.Current.Request.IsLocal)
            //    conn.ConnectionString = System.Configuration.ConfigurationManager.AppSettings["connstr_dev"];
            //else
            //    conn.ConnectionString = System.Configuration.ConfigurationManager.AppSettings["connstr"];

            //conn.Open();
            //SqlDataAdapter adapter = new SqlDataAdapter("select firm_id, project_id, year_id, annual_exp, pct_increase, cfa_annual_contrib, cfa_reserve_fund_bal, ffa_req_annual_contr, ffa_avg_req_annual_contr, isnull(ffa_res_fund_bal,0) as ffa_res_fund_bal, bfa_annual_contr, ext_res_cur_year, bfa_res_fund_bal, tfa_annual_contr, tfa_res_fund_bal, generated_by, generated_date from info_projections where firm_id=" + Session["firmid"].ToString() + " and project_id='" + Session["projectid"].ToString() + "'", conn);
            //DataSet ds = new DataSet();
            //adapter.Fill(ds, "Projection");
            //conn.Close();

            //SqlDataReader dr = reserve.Fn_enc.ExecuteReader("select begin_balance, isnull(threshold_used,0) as threshold_used, threshold_value, inflation, current_contrib from info_project_info where firm_id=@Param1 and project_id=@Param2", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString() });
            //if (dr.Read())
            //{
            //    beginBal = Convert.ToDouble(dr["begin_balance"].ToString());
            //    if (dr["inflation"].ToString() != "") inflation = Convert.ToDouble(dr["inflation"].ToString());
            //    if (dr["threshold_used"].ToString() == "True")
            //    {
            //        thresholdValue = Convert.ToDouble(dr["threshold_value"].ToString());
            //        blThreshold = true;
            //        curContrib = Convert.ToDouble(dr["current_contrib"].ToString());
            //    }
            //}
            //dr.Close();

            //ds = reserve.GoalSeek.Baseline(ds, beginBal, "baseline", inflation, curContrib);
            //if (blThreshold) ds = reserve.GoalSeek.Baseline(ds, beginBal, "threshold", inflation, curContrib, thresholdValue);
            //if (blThreshold) ds = reserve.GoalSeek.Threshold(ds, beginBal, "threshold", inflation, curContrib, thresholdValue);
            //If intervals exist, we need to re-do the baseline and threshold annual contributions. Take the total of baseline annual contributions, divide that by full funding contributions to get a percentage.
            //Then just multiply each year's full funding annual contribution to get the appropriate baseline or threshold contribution.
            //if (chkIntervals.Checked == true)
            //{
            //    adapter = new SqlDataAdapter("select interval_value from info_projections_intervals where firm_id=" + Session["firmid"].ToString() + " and project_id='" + Session["projectid"].ToString() + "' union select 30", conn);
            //    adapter.Fill(ds, "Intervals");

            //    double iGSPct = sumCol(ds, 9) / sumCol(ds, 6);
            //    var iPrev = 0;
            //    double iSum;
            //    var iRows = 0;
            //    for (var iInt = 0; iInt < ds.Tables[1].Rows.Count; iInt++)
            //    {
            //        iSum = 0;
            //        iRows = 0;
            //        //Get the sum of ffa_req_annual_contr from the next interval of records
            //        for (var j = iPrev; j < Convert.ToInt16(ds.Tables[1].Rows[iInt]["interval_value"].ToString()); j++)
            //        {
            //            iSum += Convert.ToDouble(ds.Tables[0].Rows[j]["ffa_req_annual_contr"].ToString());
            //            iRows++;
            //        }
            //        //Now update the records based on the new average for this interval
            //        for (var j = iPrev; j < Convert.ToInt16(ds.Tables[1].Rows[iInt]["interval_value"].ToString()); j++)
            //        {
            //            ds.Tables[0].Rows[j]["ffa_avg_req_annual_contr"] = (iSum / iRows);
            //            if (j == 0)
            //            {
            //                ds.Tables[0].Rows[j]["ffa_res_fund_bal"] = beginBal + (iSum / iRows) - Convert.ToDouble(ds.Tables[0].Rows[j]["annual_exp"].ToString());
            //            }
            //            else
            //            {
            //                ds.Tables[0].Rows[j]["ffa_res_fund_bal"] = Convert.ToDouble(ds.Tables[0].Rows[j - 1]["ffa_res_fund_bal"].ToString()) + (iSum / iRows) - Convert.ToDouble(ds.Tables[0].Rows[j]["annual_exp"].ToString());
            //            }
            //        }
            //        //Make sure we get from the last interval -> year 30
            //        iPrev = Convert.ToInt16(ds.Tables[1].Rows[iInt]["interval_value"].ToString());
            //    }
            //    ds = reserve.GoalSeek.Baseline(ds, beginBal, "baseline", inflation, curContrib);
            //    if (blThreshold) ds = reserve.GoalSeek.Baseline(ds, beginBal, "threshold", inflation, curContrib, thresholdValue);
            //}

            //for (var i = 0; i < ds.Tables[0].Rows.Count; i++)
            //{
            //    Fn_enc.ExecuteNonQuery("update info_projections set ffa_res_fund_bal=@Param1, ffa_avg_req_annual_contr=@Param2, bfa_annual_contr=@Param3, bfa_res_fund_bal=@Param4, generated_by=@Param5, tfa_annual_contr=@Param6, tfa2_annual_contr=@Param6, tfa_res_fund_bal=@Param7, tfa2_res_fund_bal=@Param7, generated_date=getdate() where firm_id=@Param8 and project_id=@Param9 and year_id=@Param10", new string[] { ds.Tables[0].Rows[i]["ffa_res_fund_bal"].ToString(), ds.Tables[0].Rows[i]["ffa_avg_req_annual_contr"].ToString(), ds.Tables[0].Rows[i]["bfa_annual_contr"].ToString(), ds.Tables[0].Rows[i]["bfa_res_fund_bal"].ToString(), Session["userid"].ToString(), ds.Tables[0].Rows[i]["tfa_annual_contr"].ToString(), ds.Tables[0].Rows[i]["tfa_res_fund_bal"].ToString(), Session["firmid"].ToString(), Session["projectid"].ToString(), ds.Tables[0].Rows[i]["year_id"].ToString() });
            //}

            txtHdnType.Value = "";
            lblStatus.InnerHtml = "Successfully generated projection data.";
        }

        public double sumCol(DataSet ds, int iCol)
        {
            double iSum = 0;

            for (var i=0; i<ds.Tables[0].Rows.Count; i++)
            {
                if (ds.Tables[0].Rows[i][iCol].ToString() != "") { iSum += Convert.ToDouble(ds.Tables[0].Rows[i][iCol].ToString()); }
            }
            return iSum;
        }

        public void SaveIntervals()
        {
            StringBuilder sVal = new StringBuilder();
            Fn_enc.ExecuteNonQuery("delete from info_projections_intervals where firm_id=@Param1 and project_id=@Param2", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString() });
            if (chkIntervals.Checked)
            {
                for (var i = 1; i <= Convert.ToInt16(cboIntervals.Value); i++)
                {
                    sVal.Clear();
                    if (i == 1) sVal.Append(cboI1.Value);
                    if (i == 2) sVal.Append(cboI2.Value);
                    if (i == 3) sVal.Append(cboI3.Value);
                    if (i == 4) sVal.Append(cboI4.Value);
                    if (i == 5) sVal.Append(cboI5.Value);
                    if (i == 6) sVal.Append(cboI6.Value);

                    Fn_enc.ExecuteNonQuery("insert into info_projections_intervals (firm_id, project_id, interval_id, interval_value) select @Param1, @Param2, @Param3, @Param4", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString(), i.ToString(), sVal.ToString() });
                }
            }
            lblIntStatus.InnerHtml = "Successfully updated intervals.";
            txtHdnType.Value = "Gen";
        }

        public void LoadDisplayOptions()
        {
            //chkDisp1.Checked = false;
            //chkDisp2.Checked = false;
            //chkDisp3.Checked = false;
            SqlDataReader dr = Fn_enc.ExecuteReader("select current_funding_hidden, full_funding_hidden, baseline_funding_hidden, current_pct_funded_hidden, baseline_pct_funded_hidden, threshold1_pct_funded_hidden, threshold2_pct_funded_hidden from info_project_info where firm_id=@Param1 and project_id=@Param2", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString() });
            if (dr.Read())
            {
                if ((dr["current_funding_hidden"] != null) && (dr["current_funding_hidden"].ToString().ToLower() == "true")) chkDisp1.Checked = false;
                if ((dr["full_funding_hidden"] != null) && (dr["full_funding_hidden"].ToString().ToLower() == "true")) chkDisp2.Checked = false;
                if ((dr["baseline_funding_hidden"] != null) && (dr["baseline_funding_hidden"].ToString().ToLower() == "true")) chkDisp3.Checked = false;

                if ((dr["current_pct_funded_hidden"] != null) && (dr["current_pct_funded_hidden"].ToString().ToLower() == "true")) chkPctFunded1.Checked = false;
                if ((dr["baseline_pct_funded_hidden"] != null) && (dr["baseline_pct_funded_hidden"].ToString().ToLower() == "true")) chkPctFunded2.Checked = false;
                if ((dr["threshold1_pct_funded_hidden"] != null) && (dr["threshold1_pct_funded_hidden"].ToString().ToLower() == "true")) chkPctFunded3.Checked = false;
                if ((dr["threshold2_pct_funded_hidden"] != null) && (dr["threshold2_pct_funded_hidden"].ToString().ToLower() == "true")) chkPctFunded4.Checked = false;
            }
            dr.Close();
        }

        public void LoadIntervals()
        {
            var iPrev = 1;
            var blExists = false;
            var iTot = 0;
            cboIntervals.Items.Clear();
            cboI1.Items.Clear();
            cboI2.Items.Clear();
            cboI3.Items.Clear();
            cboI4.Items.Clear();
            cboI5.Items.Clear();
            cboI6.Items.Clear();
            for (var i=1; i<7; i++)
            {
                cboIntervals.Items.Add(new ListItem(i.ToString(), i.ToString()));
            }
            for (var i=1; i<31; i++)
            {
                cboI1.Items.Add(new ListItem("Year " + i.ToString(), i.ToString()));
                if (i>1) cboI2.Items.Add(new ListItem("Year " + i.ToString(), i.ToString()));
                if (i>2) cboI3.Items.Add(new ListItem("Year " + i.ToString(), i.ToString()));
                if (i>3) cboI4.Items.Add(new ListItem("Year " + i.ToString(), i.ToString()));
                if (i>4) cboI5.Items.Add(new ListItem("Year " + i.ToString(), i.ToString()));
                if (i>5) cboI6.Items.Add(new ListItem("Year " + i.ToString(), i.ToString()));
            }
            SqlDataReader dr = Fn_enc.ExecuteReader("select * from info_projections_intervals where firm_id=@Param1 and project_id=@Param2", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString() });
            while (dr.Read())
            {
                if (dr["interval_id"].ToString() == "1") cboI1.Value = dr["interval_value"].ToString();
                if (dr["interval_id"].ToString() == "2") cboI2.Value = dr["interval_value"].ToString();
                if (dr["interval_id"].ToString() == "3") cboI3.Value = dr["interval_value"].ToString();
                if (dr["interval_id"].ToString() == "4") cboI4.Value = dr["interval_value"].ToString();
                if (dr["interval_id"].ToString() == "5") cboI5.Value = dr["interval_value"].ToString();
                if (dr["interval_id"].ToString() == "6") cboI6.Value = dr["interval_value"].ToString();
                blExists = true;
                iTot++;
            }
            dr.Close();
            if (blExists)
            {
                cboIntervals.Value = iTot.ToString();
                chkIntervals.Checked = true;
            }

        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["firmid"] == null) Response.Redirect("default.aspx?Timeout=1");

            if (lblProject.InnerHtml == "")
            {
                SqlDataReader dr = Fn_enc.ExecuteReader("select * from info_projects where firm_id=@Param1 and project_id=@Param2", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString() });

                if (dr.Read())
                {
                    lblProject.InnerHtml = dr["project_name"].ToString();
                }
                dr.Close();
            }

            if (txtHdnType.Value=="Intervals") SaveIntervals();

            LoadIntervals();
            LoadDisplayOptions();

            if (txtHdnType.Value == "Gen")
            {
                if ((txtInflation.Value != "") || (txtInterest.Value != ""))
                {
                    var inflation = new StringBuilder("");
                    var interest = new StringBuilder("");
                    if (txtInterest.Value != "")
                        interest.Append(txtInterest.Value);
                    else
                        interest.Append("0");
                    if (txtInflation.Value != "")
                        inflation.Append(txtInflation.Value);
                    else
                        inflation.Append("0");
                    Fn_enc.ExecuteNonQuery("update info_project_info set interest=" + interest.ToString() + ", inflation=" + inflation.ToString() + " where firm_id=@Param1 and project_id=@Param2", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString() });
                }
                GoalSeek.GenerateProjections(Session["firmid"].ToString(), Session["projectid"].ToString(), Session["userid"].ToString());
            }

            if (txtHdnType.Value == "Threshold1")
            {
                Fn_enc.ExecuteNonQuery($"update info_project_info set threshold1_used=1, threshold1_value=@Param1 where firm_id=@Param2 and project_id=@Param3", new string[] { txtThreshold1Val.Value, Session["firmid"].ToString(), Session["projectid"].ToString() });
                GoalSeek.GenerateThresholdType1(Session["firmid"].ToString(), Session["projectid"].ToString(), Session["userid"].ToString());
            }
        }

        public string FullFund(string fullFund, string resFund)
        {
            if (string.IsNullOrEmpty(resFund) || string.IsNullOrEmpty(fullFund) || fullFund=="0")
            {
                return "-";
            }
            else
            {
                return string.Format("{0:0}%", (Convert.ToDouble(resFund) / Convert.ToDouble(fullFund)) * 100);
            }
        }
    }
}
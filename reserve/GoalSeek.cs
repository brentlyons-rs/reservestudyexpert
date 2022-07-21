using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data;
using System.Data.SqlClient;

namespace reserve
{
    public class GoalSeek
    {
        public int year { get; set; }
        public double expenditures { get; set; }
        public double balance { get; set; }
        public double new_avg_contr { get; set; }
        public double interest { get; set; }


        public GoalSeek(int year, double expenditures, double balance, double new_avg_contr, double interest)
        {
            this.year = year;
            this.expenditures = expenditures;
            this.balance = balance;
            this.new_avg_contr = new_avg_contr;
            //this.inflation = inflation;
        }

        /// <summary>
        /// Sets the threshold type 1 scenario (where a bottom threshold is specified)
        /// after all other numbers have been generated.
        /// </summary>
        /// <param name="firmID"></param>
        /// <param name="projectID"></param>
        /// <param name="userID"></param>
        public static void GenerateThresholdType1(string firmID, string projectID, string userID)
        {
            //Step 1: create a dataset that we can update locally
            double beginBal = 0;
            double threshold1Value = 0;
            bool threshold1Used = false;
            double interest = 0;
            double curContrib = 0;

            var conn = Fn_enc.getconn();
            conn.Open();
            //SqlDataAdapter adapter = new SqlDataAdapter("select firm_id, project_id, year_id, annual_exp, ffa_avg_req_annual_contr, pct_increase, ffa_res_fund_bal, bfa_annual_contr, bfa_res_fund_bal, tfa_annual_contr, tfa_res_fund_bal from info_projections where firm_id=" + firmID + " and project_id='" + projectID + "'", conn);
            SqlDataAdapter adapter = new SqlDataAdapter("select firm_id, project_id, year_id, annual_exp, pct_increase, cfa_annual_contrib, cfa_reserve_fund_bal, ffa_req_annual_contr, ffa_avg_req_annual_contr, isnull(ffa_res_fund_bal,0) as ffa_res_fund_bal, bfa_annual_contr, ext_res_cur_year, bfa_res_fund_bal, tfa_annual_contr, tfa_res_fund_bal, generated_by, generated_date from info_projections where firm_id=" + firmID + " and project_id='" + projectID + "'", conn);
            DataSet ds = new DataSet();
            adapter.Fill(ds, "Projection");
            //Step 2b: populate local variables
            SqlDataReader dr = reserve.Fn_enc.ExecuteReader("select isnull((select top 1 firm_id from info_projections_intervals where firm_id=@Param1 and project_id=@Param2),-1) as intervals, begin_balance, isnull(threshold1_used,0) as threshold1_used, threshold1_value, threshold2_used, interest, current_contrib from info_project_info where firm_id=@Param1 and project_id=@Param2", new string[] { firmID, projectID });
            if (dr.Read())
            {
                beginBal = Convert.ToDouble(dr["begin_balance"].ToString());
                if (dr["interest"].ToString() != "") interest = Convert.ToDouble(dr["interest"].ToString());
                if (dr["threshold1_used"].ToString() == "True")
                {
                    threshold1Used = true;
                    threshold1Value = Convert.ToDouble(dr["threshold1_value"].ToString());
                    curContrib = Convert.ToDouble(dr["current_contrib"].ToString());
                }
            }
            dr.Close();
            //Step 3: update the local dataset by calling the Goalseek functions
            ds = Baseline(ds, beginBal, "baseline", interest, curContrib);
            if (threshold1Used) ds = Baseline(ds, beginBal, "threshold", interest, curContrib, threshold1Value);

            using (conn)
            {
                var cmd = new SqlCommand();
                cmd.CommandText = "sp_add_projections_threshold1_highspeed";
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Connection = conn;
                //Add table as a parameter
                var param = new SqlParameter();
                param.ParameterName = "@ProjectionData";
                param.SqlDbType = SqlDbType.Structured;
                cmd.Parameters.Add(param);
                cmd.Parameters["@ProjectionData"].Value = ds.Tables[0];
                cmd.ExecuteNonQuery();
            }
            conn.Close();
        }

        public static void GenerateProjections(string firmID, string projectID, string userID, string blSaveOldThreshold)
        {
            //Step 1a: check if intervals exist
            bool blIntervals = false;
            
            //Step 1: execute the stored proc to generate all the initial numbers
            Fn_enc.ExecuteNonQuery("sp_app_rvw_proj1 @Param1, @Param2, @Param3", new string[] { firmID, projectID, blSaveOldThreshold });
            //Step 2a: create a dataset that we can update locally
            double beginBal = 0;
            double threshold1Value = 0;
            bool threshold1Used = false;
            bool threshold2Used = false;
            double interest = 0;
            double curContrib = 0;

            var conn = Fn_enc.getconn();
            conn.Open();
            SqlDataAdapter adapter = new SqlDataAdapter("select firm_id, project_id, year_id, annual_exp, pct_increase, cfa_annual_contrib, cfa_reserve_fund_bal, ffa_req_annual_contr, ffa_avg_req_annual_contr, isnull(ffa_res_fund_bal,0) as ffa_res_fund_bal, bfa_annual_contr, ext_res_cur_year, bfa_res_fund_bal, tfa_annual_contr, tfa_res_fund_bal, generated_by, generated_date from info_projections where firm_id=" + firmID + " and project_id='" + projectID + "'", conn);
            DataSet ds = new DataSet();
            adapter.Fill(ds, "Projection");
            //Step 2b: populate some local variables we'll need later
            SqlDataReader dr = reserve.Fn_enc.ExecuteReader("select isnull((select top 1 firm_id from info_projections_intervals where firm_id=@Param1 and project_id=@Param2),-1) as intervals, begin_balance, isnull(threshold1_used,0) as threshold1_used, threshold1_value, threshold2_used, interest, current_contrib from info_project_info where firm_id=@Param1 and project_id=@Param2", new string[] { firmID, projectID });
            if (dr.Read())
            {
                beginBal = Convert.ToDouble(dr["begin_balance"].ToString());
                if (dr["interest"].ToString() != "") interest = Convert.ToDouble(dr["interest"].ToString());
                if (dr["threshold1_used"].ToString() == "True")
                {
                    threshold1Used = true;
                    threshold1Value = Convert.ToDouble(dr["threshold1_value"].ToString());
                    curContrib = Convert.ToDouble(dr["current_contrib"].ToString());
                }
                if (dr["threshold2_used"].ToString() == "True")
                {
                    threshold2Used = true;
                }
                if (dr["intervals"].ToString() != "-1") blIntervals = true;
            }
            dr.Close();
            //Step 3: update the local dataset by calling the Goalseek functions
            ds = Baseline(ds, beginBal, "baseline", interest, curContrib);
            if (threshold1Used) ds = Baseline(ds, beginBal, "threshold", interest, curContrib, threshold1Value);
            //Step 4: run a different kind of averaging if intervals have been configured
            if (blIntervals)
            {
                adapter = new SqlDataAdapter("select interval_value from info_projections_intervals where firm_id=" + firmID + " and project_id='" + projectID + "' union select 30", conn);
                adapter.Fill(ds, "Intervals");

                double iGSPct = sumCol(ds, 9) / sumCol(ds, 6);
                var iPrev = 0;
                double iSum;
                var iRows = 0;
                for (var iInt = 0; iInt < ds.Tables[1].Rows.Count; iInt++)
                {
                    iSum = 0;
                    iRows = 0;
                    //Get the sum of ffa_req_annual_contr from the next interval of records
                    for (var j = iPrev; j < Convert.ToInt16(ds.Tables[1].Rows[iInt]["interval_value"].ToString()); j++)
                    {
                        iSum += Convert.ToDouble(ds.Tables[0].Rows[j]["ffa_req_annual_contr"].ToString());
                        iRows++;
                    }
                    //Now update the records based on the new average for this interval
                    for (var j = iPrev; j < Convert.ToInt16(ds.Tables[1].Rows[iInt]["interval_value"].ToString()); j++)
                    {
                        ds.Tables[0].Rows[j]["ffa_avg_req_annual_contr"] = (iSum / iRows);
                        if (j == 0)
                        {
                            ds.Tables[0].Rows[j]["ffa_res_fund_bal"] = beginBal + (iSum / iRows) - Convert.ToDouble(ds.Tables[0].Rows[j]["annual_exp"].ToString());
                        }
                        else
                        {
                            ds.Tables[0].Rows[j]["ffa_res_fund_bal"] = Convert.ToDouble(ds.Tables[0].Rows[j - 1]["ffa_res_fund_bal"].ToString()) + (iSum / iRows) - Convert.ToDouble(ds.Tables[0].Rows[j]["annual_exp"].ToString());
                        }
                        ds.Tables[0].Rows[j]["ffa_res_fund_bal"] = (double)ds.Tables[0].Rows[j]["ffa_res_fund_bal"] * (1 + (interest / 100));
                    }
                    //Make sure we get from the last interval -> year 30
                    iPrev = Convert.ToInt16(ds.Tables[1].Rows[iInt]["interval_value"].ToString());
                }
                ds = Baseline(ds, beginBal, "baseline", interest, curContrib);
                if (threshold1Used) ds = Baseline(ds, beginBal, "threshold", interest, curContrib, threshold1Value);
            }

            using (conn)
            {
                var cmd = new SqlCommand();
                cmd.CommandText = "sp_add_projections_highspeed";
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Connection = conn;
                //Add table as a parameter
                var param = new SqlParameter();
                param.ParameterName = "@ProjectionData";
                param.SqlDbType = SqlDbType.Structured;
                cmd.Parameters.Add(param);
                cmd.Parameters["@ProjectionData"].Value = ds.Tables[0];
                //Add interest
                param = new SqlParameter();
                param.ParameterName = "@interest";
                param.SqlDbType = SqlDbType.Float;
                cmd.Parameters.Add(param);
                cmd.Parameters["@interest"].Value = interest;
                //Add parameter for whether we should save the old threshold calcs or not
                param = new SqlParameter();
                param.ParameterName = "@saveOldThreshold";
                param.SqlDbType = SqlDbType.NVarChar;
                cmd.Parameters.Add(param);
                cmd.Parameters["@saveOldThreshold"].Value = blSaveOldThreshold;

                cmd.ExecuteNonQuery();
            }
            conn.Close();
            //If threshold scenario type 2 is selected, run the stored proc specific to the Projected Threshold Fund data
            if (threshold2Used)
            {
                Fn_enc.ExecuteNonQuery("update info_projections set tfa2_annual_contr=cfa_annual_contrib, tfa2_annual_contr_user_entered=1 where firm_id=@Param1 and project_id=@Param2 and year_id=(select min(year_id) from info_projections where firm_id=@Param1 and project_id=@Param2)", new string[] { firmID, projectID });
                Fn_enc.ExecuteNonQuery("sp_app_proj_adj_threshold @Param1, @Param2", new string[] { firmID, projectID });
            }
            //for (var i = 0; i < ds.Tables[0].Rows.Count; i++)
            //{
            //    Fn_enc.ExecuteNonQuery("update info_projections set ffa_res_fund_bal=@Param1, ffa_avg_req_annual_contr=@Param2, bfa_annual_contr=@Param3, bfa_res_fund_bal=@Param4, generated_by=@Param5, tfa_annual_contr=@Param6, tfa2_annual_contr=@Param6, tfa_res_fund_bal=@Param7, tfa2_res_fund_bal=@Param7, generated_date=getdate() where firm_id=@Param8 and project_id=@Param9 and year_id=@Param10", new string[] { ds.Tables[0].Rows[i]["ffa_res_fund_bal"].ToString(), ds.Tables[0].Rows[i]["ffa_avg_req_annual_contr"].ToString(), ds.Tables[0].Rows[i]["bfa_annual_contr"].ToString(), ds.Tables[0].Rows[i]["bfa_res_fund_bal"].ToString(), userID, ds.Tables[0].Rows[i]["tfa_annual_contr"].ToString(), ds.Tables[0].Rows[i]["tfa_res_fund_bal"].ToString(), firmID, projectID, ds.Tables[0].Rows[i]["year_id"].ToString() });
            //}
        }



        public static double sumCol(DataSet ds, int iCol)
        {
            double iSum = 0;

            for (var i = 0; i < ds.Tables[0].Rows.Count; i++)
            {
                if (ds.Tables[0].Rows[i][iCol].ToString() != "") { iSum += Convert.ToDouble(ds.Tables[0].Rows[i][iCol].ToString()); }
            }
            return iSum;
        }

        public static DataSet Threshold(DataSet ds, double beginBal, string strType, double interest, double curContrib, double threshold = -1)
        {
            List<GoalSeek> gs = new List<GoalSeek>();
            GoalSeek row;
            int iIter = 0;
            double iThreshold = 0;
            bool blThreshold = true;

            for (var i = 0; i < ds.Tables[0].Rows.Count; i++)
            {
                row = new GoalSeek(Convert.ToInt16(ds.Tables[0].Rows[i]["year_id"].ToString()), Convert.ToDouble(ds.Tables[0].Rows[i]["annual_exp"].ToString()), Convert.ToDouble(ds.Tables[0].Rows[i]["cfa_reserve_fund_bal"].ToString()), curContrib, interest);
                gs.Add(row);
            }

            var curLB = GoalSeek.LowestBal(gs);
            //double curReduction = Convert.ToDouble((curLB - iThreshold) / 100); //Reduce contributions by 1/100th of whatever the current lowest balance is.
            double curReduction = 100;

            //double newLB = double.MaxValue;
            double newLB = curLB;

            if (newLB < iThreshold) //Currently, the lowest balance is less than the threshold. That means we need to *increase* the contributions.
            {
                while (newLB < iThreshold)
                {
                    GoalSeek.ChangeContribution(gs, curReduction, beginBal, interest, blThreshold); //might need to change this
                    newLB = GoalSeek.LowestBal(gs);
                    //curReduction = Convert.ToDouble((newLB - iThreshold) / 100);
                    if (curReduction > -.01) curReduction = -.01;
                    iIter++;
                    if (iIter > 1000)
                    {
                        break;
                    }
                }
            }
            else //Currently, the lowest balance is greater than $0. That means we need to *decrease* the contributions, so they aren't wasting their money in reserves.
            {
                while (newLB > iThreshold)
                {
                    GoalSeek.ChangeContribution(gs, curReduction, beginBal, interest, blThreshold);
                    newLB = GoalSeek.LowestBal(gs);
                    curReduction = Convert.ToDouble((newLB - iThreshold) / 100);
                    if (curReduction < .01) curReduction = .01;
                    iIter++;
                }
            }

            if (newLB < iThreshold)
            {
                ChangeContribution(gs, curReduction * -1, beginBal, interest, blThreshold);
            }

            for (var i = 0; i < ds.Tables[0].Rows.Count; i++)
            {
                ds.Tables[0].Rows[i]["tfa_annual_contr"] = gs[i].new_avg_contr;
                ds.Tables[0].Rows[i]["tfa_res_fund_bal"] = gs[i].balance;
            }

            return ds;
        }

        public static DataSet Baseline(DataSet ds, double beginBal, string strType, double interest, double curContrib, double threshold=-1)
        {
            List<GoalSeek> gs = new List<GoalSeek>();
            GoalSeek row;
            int iIter = 0;
            double iThreshold = 0;
            bool blThreshold = false;

            if (strType == "threshold")
            {
                iThreshold = threshold;
                blThreshold = true;
            }

            for (var i=0; i<ds.Tables[0].Rows.Count; i++)
            {
                row = new GoalSeek(Convert.ToInt16(ds.Tables[0].Rows[i]["year_id"].ToString()), Convert.ToDouble(ds.Tables[0].Rows[i]["annual_exp"].ToString()), Convert.ToDouble(ds.Tables[0].Rows[i]["ffa_res_fund_bal"].ToString()), Convert.ToDouble(ds.Tables[0].Rows[i]["ffa_avg_req_annual_contr"].ToString()), interest);
                gs.Add(row);
            }

            var curLB = GoalSeek.LowestBal(gs);
            double curReduction = Convert.ToDouble((curLB-iThreshold) / 100); //Reduce contributions by 1/100th of whatever the current lowest balance is.

            //double newLB = double.MaxValue;
            double newLB = curLB;

            if (newLB<iThreshold) //Currently, the lowest balance is less than the threshold. That means we need to *increase* the contributions.
            {
                while (newLB < iThreshold)
                {
                    GoalSeek.ChangeContribution(gs, curReduction, beginBal, interest, blThreshold); //might need to change this
                    newLB = GoalSeek.LowestBal(gs);
                    curReduction = Convert.ToDouble((newLB - iThreshold) / 100);
                    if (curReduction > -.01) curReduction = -.01;
                    iIter++;
                }
            }
            else //Currently, the lowest balance is greater than $0. That means we need to *decrease* the contributions, so they aren't wasting their money in reserves.
            {
                while (newLB > iThreshold)
                {
                    GoalSeek.ChangeContribution(gs, curReduction, beginBal, interest, blThreshold);
                    newLB = GoalSeek.LowestBal(gs);
                    curReduction = Convert.ToDouble((newLB - iThreshold) / 100);
                    if (curReduction < .01) curReduction = .01;
                    iIter++;
                }
            }

            if (newLB < iThreshold)
            {
                ChangeContribution(gs, curReduction * -1, beginBal, interest, blThreshold);
            }


            for (var i=0; i<ds.Tables[0].Rows.Count; i++)
            {
                if (strType=="threshold")
                {
                    ds.Tables[0].Rows[i]["tfa_annual_contr"] = gs[i].new_avg_contr;
                    ds.Tables[0].Rows[i]["tfa_res_fund_bal"] = gs[i].balance;
                }
                else
                {
                    ds.Tables[0].Rows[i]["bfa_annual_contr"] = gs[i].new_avg_contr;
                    ds.Tables[0].Rows[i]["bfa_res_fund_bal"] = gs[i].balance;
                }
            }

            return ds;
        }

        public static int LowestYear(List<GoalSeek> gs)
        {
            var lb = double.MaxValue;
            var ly = 0;
            foreach (GoalSeek g in gs)
            {
                if (g.balance < lb)
                {
                    lb = g.balance;
                    ly = g.year;
                }
            }
            return ly;
        }

        public static double LowestBal(List<GoalSeek> gs)
        {
            var lb = double.MaxValue;
            foreach (GoalSeek g in gs)
            {
                if (g.balance < lb)
                {
                    lb = g.balance;
                }
            }
            return lb;
        }

        public static List<GoalSeek> ChangeContribution(List<GoalSeek> gs, double curReduction, double beginBal, double interest, bool blThreshold)
        {
            for (int i = 0; i < gs.Count; i++)
            {
                gs[i].new_avg_contr = gs[i].new_avg_contr - curReduction;
                if (i == 0)
                {
                    gs[i].balance = beginBal + (gs[i].new_avg_contr) - gs[i].expenditures;
                }
                else
                {
                    gs[i].balance = gs[i - 1].balance + (gs[i].new_avg_contr) - gs[i].expenditures;
                }
                //Account for inflation
                //if (gs[i].inflation>0) gs[i].balance = gs[i].balance + (gs[i].balance * (gs[i].inflation/100));
                if (interest > 0) gs[i].balance = gs[i].balance * (1 + (interest / 100));
            }

            return gs;
        }

    }
}
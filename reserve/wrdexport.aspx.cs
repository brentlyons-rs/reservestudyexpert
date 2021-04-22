using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;
using DocumentFormat.OpenXml;
using DocumentFormat.OpenXml.Packaging;
using DocumentFormat.OpenXml.Wordprocessing;
using A = DocumentFormat.OpenXml.Drawing;
using DW = DocumentFormat.OpenXml.Drawing.Wordprocessing;
using PIC = DocumentFormat.OpenXml.Drawing.Pictures;
using System.Data.SqlClient;
using System.Text;
using System.Security.Policy;
using DocumentFormat.OpenXml.Drawing.Charts;
using DocumentFormat.OpenXml.Spreadsheet;
using Text = DocumentFormat.OpenXml.Wordprocessing.Text;
using System.Data;
using DocumentFormat.OpenXml.Drawing.Wordprocessing;

namespace reserve
{
    public partial class wrdexport : System.Web.UI.Page
    {
        public WordprocessingDocument wordDoc;
        public bool blDetailedStudy = false;

        public void chgHeaderOLD(string strFind, string strNew)
        {
            foreach (HeaderPart hdPart in wordDoc.MainDocumentPart.HeaderParts)
            {
                var t = hdPart.Header.Descendants<SdtElement>().ToList().FindAll(sdt => sdt.SdtProperties.GetFirstChild<Tag>()?.Val == strFind);
                for (var i = 0; i < t.Count; i++)
                {
                    t[i].Descendants<DocumentFormat.OpenXml.Wordprocessing.Text>().FirstOrDefault().Text = strNew;
                }

            }
        }

        public void chgHeader(string strFind, string strNew)
        {
            foreach (HeaderPart hdPart in wordDoc.MainDocumentPart.HeaderParts)
            {
                foreach (var currentText in hdPart.RootElement.Descendants<DocumentFormat.OpenXml.Wordprocessing.Text>())
                {
                    currentText.Text = currentText.Text.Replace(strFind, strNew);
                }
            }
        }
        public void chgFooterOLD(string strFind, string strNew)
        {
            foreach (FooterPart ftPart in wordDoc.MainDocumentPart.FooterParts)
            {
                var t = ftPart.Footer.Descendants<SdtElement>().ToList().FindAll(sdt => sdt.SdtProperties.GetFirstChild<Tag>()?.Val == strFind);
                for (var i = 0; i < t.Count; i++)
                {
                    t[i].Descendants<DocumentFormat.OpenXml.Wordprocessing.Text>().FirstOrDefault().Text = strNew;
                }

            }
        }


        public void chgFooter(string strFind, string strNew)
        {
            foreach (FooterPart ftPart in wordDoc.MainDocumentPart.FooterParts)
            {
                foreach (var currentText in ftPart.RootElement.Descendants<DocumentFormat.OpenXml.Wordprocessing.Text>())
                {
                    currentText.Text = currentText.Text.Replace(strFind, strNew);
                }
            }
        }


        public void chgTextOLD(string strFind, string strNew)
        {
            var t = wordDoc.MainDocumentPart.Document.Body.Descendants<SdtElement>().ToList().FindAll(sdt => sdt.SdtProperties.GetFirstChild<Tag>()?.Val == strFind);
            for (var i=0; i<t.Count; i++)
            {
                t[i].Descendants<DocumentFormat.OpenXml.Wordprocessing.Text>().FirstOrDefault().Text = strNew;
            }
        }

        public void chgText(string strFind, string strNew)
        {

            foreach (var text in wordDoc.MainDocumentPart.Document.Body.Descendants<Text>())
            {
                if (text.Text.Contains(strFind))
                {
                    text.Text = text.Text.Replace(strFind, strNew);
                }
            }
        }

        public static void CopyStream(Stream input, Stream output)
        {
            byte[] buffer = new byte[32768];
            while (true)
            {
                int read = input.Read(buffer, 0, buffer.Length);
                if (read <= 0)
                    return;
                output.Write(buffer, 0, read);
            }
        }

        public StringBuilder longdt(DateTime dt)
        {
            StringBuilder sb = new StringBuilder();
            sb.Append(dt.ToString("MMMM") + " ");
            sb.Append(dt.Day.ToString() + ", " + dt.Year.ToString());
            return sb;
        }

        public void createDoc()
        {
            SqlDataReader dr;
            SqlConnection conn;
            try
            {
                string docLoc;

                if (HttpContext.Current.Request.IsLocal)
                    docLoc = @"c:\data\";
                else if (HttpContext.Current.Request.Url.Host.IndexOf("test.reservestudyplus.com") >= 0)
                {
                    docLoc = @"D:\Inetpub\vhosts\reservestudyplus.com\test.reservestudyplus.com\clienttemplates\";
                }
                else
                {
                    docLoc = @"D:\Inetpub\vhosts\reservestudyplus.com\clienttemplates\";
                }

                dr = Fn_enc.ExecuteReader("sp_app_create_word @Param1, @Param2", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString() });
                if (dr.Read())
                {
                    docLoc += dr["template_name"];
                }

                byte[] byteArray = File.ReadAllBytes(docLoc);
                using (var stream = new MemoryStream())
                {
                    stream.Write(byteArray, 0, byteArray.Length);
                    using (wordDoc = WordprocessingDocument.Open(stream, true))
                    {
                        //Remove stuff not applicable to certain project types
                        if ((dr["project_type_id"].ToString() == "1") || (dr["project_type_id"].ToString() == "6") || (dr["project_type_id"].ToString() == "8"))
                        {
                            RemoveText("Study Being Updated Prepared By");
                            RemoveText("Date of Study Being Updated");
                            RemoveText("Previous preparer of the study");
                            RemoveText("Dated @@previous_date");
                            RemoveText("Previous Preparer");
                        }

                        if (dr["project_type_desc"].ToString().ToLower().IndexOf("detailed") > -1) blDetailedStudy = true;
                        chgFooter("@@copyright", "1992-" + DateTime.Today.Year.ToString());
                        chgHeader("@@project_type", dr["project_type_desc"].ToString());
                        chgHeader("@@project_name", dr["project_name"].ToString());
                        chgHeader("@@project_number", dr["project_id"].ToString());
                        chgHeader("@@created_date_short", longdt(DateTime.Now).ToString());

                        chgText("@@created_date_short", longdt(DateTime.Now).ToString());
                        chgText("@@created_date", longdt(DateTime.Now).ToString());
                        chgText("@@project_manager", dr["project_mgr"].ToString());
                        chgText("@@prefix", dr["contact_prefix"].ToString());
                        chgText("@@client_full_name", dr["contact_name"].ToString());
                        chgText("@@client_last_name", dr["contact_name"].ToString());
                        chgText("@@client_title", dr["contact_title"].ToString());
                        chgText("@@client_company", dr["association_name"].ToString());
                        chgText("@@client_address", dr["client_addr1"].ToString());
                        chgText("@@client_city", dr["client_city"].ToString());
                        chgText("@@client_state", dr["client_state"].ToString());
                        chgText("@@client_zip", dr["client_zip"].ToString());

                        chgText("@@project_city", dr["site_city"].ToString());
                        chgText("@@project_state", dr["site_state"].ToString());
                        chgText("@@project_name", dr["project_name"].ToString());
                        chgText("@@project_type", dr["project_type_desc"].ToString());
                        chgText("@@project_number", dr["project_id"].ToString());

                        chgText("@@community_age", dr["age_community"].ToString());
                        chgText("@@numunits", dr["num_units"].ToString());

                        chgText("@@num_buildings", dr["num_bldgs"].ToString());
                        chgText("@@num_floors", dr["num_floors"].ToString());
                        chgText("@@inspection_dates", longdt(Convert.ToDateTime(dr["inspection_date"].ToString())).ToString());
                        chgText("@@previous_preparer", dr["prev_preparer"].ToString());
                        if (dr["prev_date"].ToString() == "")
                        {
                            chgText("@@previous_date", "");
                        }
                        else
                        {
                            chgText("@@previous_date", longdt(Convert.ToDateTime(dr["prev_date"].ToString())).ToString());
                        }
                        chgText("@@beginning_balance_source", dr["source_begin_balance"].ToString());
                        chgText("@@effective_date", longdt(Convert.ToDateTime(dr["report_effective"].ToString())).ToString());

                        chgText("@@current_contribution", Convert.ToDouble(dr["current_contrib"]).ToString("C0"));
                        chgText("@@recommended_contribution", Convert.ToDouble(dr["ffa_avg_req_annual_contr"]).ToString("C0"));
                        chgText("@@beginning_balance", Convert.ToDouble(dr["begin_balance"]).ToString("C0"));
                        chgText("@@pct_funded", (Convert.ToDouble(dr["begin_balance"].ToString())/Convert.ToDouble(dr["full_fund_bal"].ToString())).ToString("P2"));
                        chgText("@@prev_rec_annual_contr", dr["prev_recomm_cont"].ToString());
                        chgText("@@interest", dr["interest"].ToString());
                        chgText("@@inflation", dr["inflation"].ToString());

                        if (Convert.ToDouble(dr["cfa_annual_contrib"].ToString()) == Convert.ToDouble(dr["ffa_avg_req_annual_contr"].ToString()))
                        {
                            chgText("@@indication", "adequate");
                        }
                        else if (Convert.ToDouble(dr["cfa_annual_contrib"].ToString()) > Convert.ToDouble(dr["ffa_avg_req_annual_contr"].ToString()))
                        {
                            chgText("@@indication", "overfunded");
                        }
                        else if (Convert.ToDouble(dr["cfa_annual_contrib"].ToString()) < Convert.ToDouble(dr["ffa_avg_req_annual_contr"].ToString()))
                        {
                            chgText("@@indication", "underfunded");
                        }

                        //Show/hide funding scenarios
                        if (Convert.ToBoolean(dr["threshold_used"].ToString())==true)
                        {
                            chgText("@@funding_scenarios", "four (4)");
                            //chgText("@@threshold_text", "The fourth funding scenario, entitled Threshold Funding, is based on keeping the Reserve Fund Balance above a specified threshold value at all times over the 30 year time frame. In this scenario, 7.5% of the Reserve Requirement Present Dollars (" + Convert.ToDouble(dr["threshold_value"]).ToString("C0") + ") was used as the minimum threshold balance.");
                            chgText("@@threshold_text", "The fourth funding scenario, entitled Threshold Funding, is based on keeping the Reserve Fund Balance above a specified threshold value at all times over the 30 year time frame.");
                            //chgText("@@threshold_value1", Convert.ToDouble(dr["tfa2_annual_contr"]).ToString("C0") + " (Threshold Funding - " + (Convert.ToDouble(dr["threshold_value"].ToString()) / Convert.ToDouble(dr["current_contrib"].ToString())).ToString("P1") + " of Reserve Requirement Present Dollars)");
                            chgText("@@tfa", Convert.ToDouble(dr["tfa2_annual_contr"]).ToString("C0"));
                        }
                        else
                        {
                            chgText("@@funding_scenarios", "three (3)");
                            chgText("@@threshold_text", "");
                            chgText("@@threshold_value1", "");
                        }
                        //*******************************************************NEED TO FIX THIS*****************************************
                        if (Convert.ToBoolean(dr["full_funding_hidden"].ToString()))
                        {
                            chgText("@@full_funding_text", "");
                            chgText("@@ffa", "N/A");
                            chgText("@@ffa_min", "N/A");
                        }
                        else
                        {
                            chgText("@@ffa", Convert.ToDouble(dr["ffa_avg_req_annual_contr"]).ToString("C0"));
                            chgText("@@ffa_min", Convert.ToDouble(dr["min_ffa_bal"]).ToString("C0"));
                        }
                        if (Convert.ToBoolean(dr["current_funding_hidden"].ToString()))
                        {
                            chgText("@@current_funding_text", "");
                            chgText("@@cfa", "N/A");
                            chgText("@@cfa_min", "N/A");
                        }
                        else
                        {
                            chgText("@@cfa", Convert.ToDouble(dr["cfa_annual_contrib"]).ToString("C0"));
                            chgText("@@cfa_min", Convert.ToDouble(dr["min_cfa_bal"]).ToString("C0"));
                        }
                        if (Convert.ToBoolean(dr["baseline_funding_hidden"].ToString()))
                        {
                            chgText("@@baseline_funding_text", "");
                            chgText("@@bfa", "N/A");
                        }
                        else
                        {
                            chgText("@@bfa", Convert.ToDouble(dr["bfa_annual_contr"]).ToString("C0"));
                        }

                        chgText("@@year_2", dr["year2"].ToString());
                        chgText("@@year_30_contribution", Convert.ToDouble(dr["year30contr"]).ToString("C0"));
                        chgText("@@year_30", dr["year30"].ToString());


                        if (Convert.ToDouble(dr["year30contr"].ToString())==Convert.ToDouble(dr["year29contr"].ToString()))
                        {
                            chgText("@@increase_decrease", "remains constant at");
                            chgText("@@underfunding_overfunding", "");
                        }
                        else if (Convert.ToDouble(dr["year30contr"].ToString()) > Convert.ToDouble(dr["year29contr"].ToString()))
                        {
                            chgText("@@increase_decrease", "increases");
                            chgText("@@underfunding_overfunding", "This is indicative of an overfunding taking place.");
                        }
                        else
                        {
                            chgText("@@increase_decrease", "decreases");
                            chgText("@@underfunding_overfunding", "This is indicative of an underfunding taking place.");
                        }

                        ChartReference cr = wordDoc.MainDocumentPart.Document.Body.Descendants<ChartReference>().FirstOrDefault();
                        ChartPart cp = (ChartPart)wordDoc.MainDocumentPart.Parts.Where(pt => pt.RelationshipId == cr.Id).FirstOrDefault().OpenXmlPart;
                        //***Below commented section is supposed to work for the excel data behind the chart, but doesn't seem to be committing.
                        //***Commented section changes the "cached" values, which is what the user will see. If the user clicks the "edit data" option though, 
                        //***data will revert to the blanked-out data in excel.
                        ////ChartPart cp = wordDoc.MainDocumentPart.ChartParts.ElementAt(0);
                        ////Chart chart = cp.ChartSpace.Descendants<Chart>().FirstOrDefault();
                        //ExternalData ed = cp.ChartSpace.Elements<ExternalData>().FirstOrDefault();
                        //EmbeddedPackagePart epp = (EmbeddedPackagePart)cp.Parts.Where(pt => pt.RelationshipId == ed.Id).FirstOrDefault().OpenXmlPart;

                        //using (Stream str = epp.GetStream())
                        //using (MemoryStream ms = new MemoryStream())
                        //{
                        //    CopyStream(str, ms);
                        //    using (SpreadsheetDocument spreadsheetDoc = SpreadsheetDocument.Open(ms,true))
                        //    {
                        //        Sheet ws = (Sheet)spreadsheetDoc.WorkbookPart.Workbook.Sheets.FirstOrDefault();

                        //        WorksheetPart wsp = (WorksheetPart)spreadsheetDoc.WorkbookPart.Parts.Where(pt => pt.RelationshipId == ws.Id).FirstOrDefault().OpenXmlPart;
                        //        SheetData sd = wsp.Worksheet.Elements<SheetData>().FirstOrDefault();

                        //        Row secondRow = sd.Elements<Row>().Skip(1).FirstOrDefault();
                        //        if (secondRow != null)
                        //        {
                        //            secondRow.Elements<Cell>().ElementAt(1).Elements<CellValue>().FirstOrDefault().Text = "123456";
                        //        }
                        //        using (Stream s = epp.GetStream())
                        //            ms.WriteTo(s);

                        //        spreadsheetDoc.WorkbookPart.Workbook.Save();
                        //    }
                        //}

                        conn = Fn_enc.getconn();
                        conn.Open();
                        //Table for projections
                        SqlDataAdapter adapter = new SqlDataAdapter("select * from info_projections where firm_id=" + Session["firmid"].ToString() + " and project_id='" + Session["projectid"].ToString() + "'", conn);
                        DataSet ds = new DataSet();
                        adapter.Fill(ds, "Projection");
                        //Table for summary
                        adapter = new SqlDataAdapter("sp_app_rvw_comp1 " + Session["firmid"].ToString() + ", '" + Session["projectid"].ToString() + "', 0", conn);
                        adapter.Fill(ds, "Summary");

                        Chart chart = cp.ChartSpace.Elements<Chart>().First();
                        LineChart lc = chart.Descendants<LineChart>().FirstOrDefault();
                        
                        

                        if (lc != null)
                        {
                            //LineChartSeries lcs = lc.Elements<LineChartSeries>().FirstOrDefault();
                            LineChartSeries lcs = lc.Elements<LineChartSeries>().Skip(1).FirstOrDefault();
                            //Begin with the beginning balance
                            lcs.Elements<CategoryAxisData>().FirstOrDefault().FirstChild.ElementAt(1).ElementAt(2).Elements<NumericValue>().FirstOrDefault().Text = (Convert.ToDateTime(dr["report_effective"].ToString()).Year - 1).ToString();
                            if (!Convert.ToBoolean(dr["full_funding_hidden"].ToString())) lc.Elements<LineChartSeries>().Skip(0).FirstOrDefault().Descendants<DocumentFormat.OpenXml.Drawing.Charts.Values>().First().Descendants<NumberingCache>().First().Elements<NumericPoint>().ElementAt(0).Elements<NumericValue>().FirstOrDefault().Text = dr["begin_balance"].ToString();
                            if (!Convert.ToBoolean(dr["current_funding_hidden"].ToString())) lc.Elements<LineChartSeries>().Skip(1).FirstOrDefault().Descendants<DocumentFormat.OpenXml.Drawing.Charts.Values>().First().Descendants<NumberingCache>().First().Elements<NumericPoint>().ElementAt(0).Elements<NumericValue>().FirstOrDefault().Text = dr["begin_balance"].ToString();
                            if (!Convert.ToBoolean(dr["baseline_funding_hidden"].ToString())) lc.Elements<LineChartSeries>().Skip(2).FirstOrDefault().Descendants<DocumentFormat.OpenXml.Drawing.Charts.Values>().First().Descendants<NumberingCache>().First().Elements<NumericPoint>().ElementAt(0).Elements<NumericValue>().FirstOrDefault().Text = dr["begin_balance"].ToString();
                            if (Convert.ToBoolean(dr["threshold_used"].ToString())) lc.Elements<LineChartSeries>().Skip(3).FirstOrDefault().Descendants<DocumentFormat.OpenXml.Drawing.Charts.Values>().First().Descendants<NumberingCache>().First().Elements<NumericPoint>().ElementAt(0).Elements<NumericValue>().FirstOrDefault().Text = dr["begin_balance"].ToString();
                            //Populate each series
                            for (var i=0; i<ds.Tables[0].Rows.Count; i++)
                            {
                                //Change the year
                                lcs.Elements<CategoryAxisData>().FirstOrDefault().FirstChild.ElementAt(1).ElementAt(i+3).Elements<NumericValue>().FirstOrDefault().Text = ds.Tables[0].Rows[i]["year_id"].ToString();
                                //Change the data points for that year
                                if (!Convert.ToBoolean(dr["full_funding_hidden"].ToString())) lc.Elements<LineChartSeries>().Skip(0).FirstOrDefault().Descendants<DocumentFormat.OpenXml.Drawing.Charts.Values>().First().Descendants<NumberingCache>().First().Elements<NumericPoint>().ElementAt(i+1).Elements<NumericValue>().FirstOrDefault().Text = ds.Tables[0].Rows[i]["ffa_res_fund_bal"].ToString();
                                if (!Convert.ToBoolean(dr["current_funding_hidden"].ToString())) lc.Elements<LineChartSeries>().Skip(1).FirstOrDefault().Descendants<DocumentFormat.OpenXml.Drawing.Charts.Values>().First().Descendants<NumberingCache>().First().Elements<NumericPoint>().ElementAt(i+1).Elements<NumericValue>().FirstOrDefault().Text = ds.Tables[0].Rows[i]["cfa_reserve_fund_bal"].ToString();
                                if (!Convert.ToBoolean(dr["baseline_funding_hidden"].ToString())) lc.Elements<LineChartSeries>().Skip(2).FirstOrDefault().Descendants<DocumentFormat.OpenXml.Drawing.Charts.Values>().First().Descendants<NumberingCache>().First().Elements<NumericPoint>().ElementAt(i+1).Elements<NumericValue>().FirstOrDefault().Text = ds.Tables[0].Rows[i]["bfa_res_fund_bal"].ToString();
                                if (Convert.ToBoolean(dr["threshold_used"].ToString())) lc.Elements<LineChartSeries>().Skip(3).FirstOrDefault().Descendants<DocumentFormat.OpenXml.Drawing.Charts.Values>().First().Descendants<NumberingCache>().First().Elements<NumericPoint>().ElementAt(i+1).Elements<NumericValue>().FirstOrDefault().Text = ds.Tables[0].Rows[i]["tfa2_res_fund_bal"].ToString();
                            }
                            //Remove from the legend if hidden
                            if (!Convert.ToBoolean(dr["threshold_used"].ToString())) lc.ElementAt(FindLCPos(lc, "threshold")).Remove(); //Threshold
                            if (Convert.ToBoolean(dr["baseline_funding_hidden"].ToString())) lc.ElementAt(FindLCPos(lc, "baseline")).Remove(); //Baseline
                            if (Convert.ToBoolean(dr["current_funding_hidden"].ToString())) lc.ElementAt(FindLCPos(lc, "current")).Remove(); //Current
                            if (Convert.ToBoolean(dr["full_funding_hidden"].ToString())) lc.ElementAt(FindLCPos(lc, "full")).Remove(); //Full funding FindLCPos
                        }

                        //Cashflow table
                        double[] ttl;
                        DocumentFormat.OpenXml.Wordprocessing.TableRow tr;
                        IEnumerable<TableProperties> tableProperties = wordDoc.MainDocumentPart.Document.Body.Descendants<TableProperties>().Where(tp => tp.TableCaption != null);
                        foreach (TableProperties tProp in tableProperties)
                        {
                            if (tProp.TableCaption.Val=="Graph Metrics")
                            {
                                DocumentFormat.OpenXml.Wordprocessing.Table tbl = (DocumentFormat.OpenXml.Wordprocessing.Table)tProp.Parent;
                                if (Convert.ToBoolean(dr["current_funding_hidden"].ToString())) tbl.Descendants<DocumentFormat.OpenXml.Wordprocessing.TableRow>().ElementAt(2).Remove();
                                if (Convert.ToBoolean(dr["baseline_funding_hidden"].ToString())) tbl.Descendants<DocumentFormat.OpenXml.Wordprocessing.TableRow>().ElementAt(1).Remove();
                                if (Convert.ToBoolean(dr["full_funding_hidden"].ToString())) tbl.Descendants<DocumentFormat.OpenXml.Wordprocessing.TableRow>().ElementAt(0).Remove();
                            }
                            else if (tProp.TableCaption.Val=="Funding")
                            {
                                DocumentFormat.OpenXml.Wordprocessing.Table tbl = (DocumentFormat.OpenXml.Wordprocessing.Table)tProp.Parent;
                                if (Convert.ToBoolean(dr["baseline_funding_hidden"].ToString())) tbl.Descendants<DocumentFormat.OpenXml.Wordprocessing.TableRow>().ElementAt(3).Remove();
                                if (Convert.ToBoolean(dr["full_funding_hidden"].ToString())) tbl.Descendants<DocumentFormat.OpenXml.Wordprocessing.TableRow>().ElementAt(2).Remove();
                                if (Convert.ToBoolean(dr["current_funding_hidden"].ToString())) tbl.Descendants<DocumentFormat.OpenXml.Wordprocessing.TableRow>().ElementAt(1).Remove();
                            }
                            else if (tProp.TableCaption.Val == "Cashflow")
                            {
                                ttl = new double[5] { 0, 0, 0, 0, 0 };
                                DocumentFormat.OpenXml.Wordprocessing.Table tbl = (DocumentFormat.OpenXml.Wordprocessing.Table)tProp.Parent;

                                if (!Convert.ToBoolean(dr["threshold_used"].ToString())) RemoveTblCols(tbl, "threshold");
                                if (Convert.ToBoolean(dr["baseline_funding_hidden"].ToString())) RemoveTblCols(tbl, "baseline");
                                if (Convert.ToBoolean(dr["full_funding_hidden"].ToString())) RemoveTblCols(tbl, "full");
                                if (Convert.ToBoolean(dr["current_funding_hidden"].ToString())) RemoveTblCols(tbl, "current");

                                //Find the lowest threshold year
                                int lowestTFYear = -1; double lowestTFAmt=0;
                                int lowestBFYear = -1; double lowestBFAmt=0;

                                if (Convert.ToBoolean(dr["threshold_used"].ToString())) lowestTFAmt = Convert.ToDouble(ds.Tables[0].Rows[0]["tfa2_res_fund_bal"].ToString());
                                if (!Convert.ToBoolean(dr["baseline_funding_hidden"].ToString())) lowestBFAmt = Convert.ToDouble(ds.Tables[0].Rows[0]["bfa_res_fund_bal"].ToString());
                                for (var i=0; i<ds.Tables[0].Rows.Count; i++)
                                {
                                    if (Convert.ToBoolean(dr["threshold_used"].ToString()) && (Convert.ToDouble(ds.Tables[0].Rows[i]["tfa2_res_fund_bal"].ToString())<lowestTFAmt))
                                    {
                                        lowestTFYear= Convert.ToInt32(ds.Tables[0].Rows[i]["year_id"].ToString());
                                        lowestTFAmt= Convert.ToDouble(ds.Tables[0].Rows[i]["tfa2_res_fund_bal"].ToString()); 
                                    }
                                    if (!Convert.ToBoolean(dr["baseline_funding_hidden"].ToString()) && (Convert.ToDouble(ds.Tables[0].Rows[i]["bfa_res_fund_bal"].ToString()) < lowestBFAmt))
                                    {
                                        lowestBFYear = Convert.ToInt32(ds.Tables[0].Rows[i]["year_id"].ToString());
                                        lowestBFAmt = Convert.ToDouble(ds.Tables[0].Rows[i]["bfa_res_fund_bal"].ToString());
                                    }
                                }

                                for (var i=0; i<ds.Tables[0].Rows.Count; i++)
                                {
                                    tr = new DocumentFormat.OpenXml.Wordprocessing.TableRow();
                                    tr.Append(MakeCell(ds.Tables[0].Rows[i]["year_id"].ToString(),false,false,"","276"));
                                    tr.Append(MakeCell(Convert.ToDouble(ds.Tables[0].Rows[i]["annual_exp"]).ToString("C0"),false,false,"","276"));
                                    if (!Convert.ToBoolean(dr["current_funding_hidden"].ToString())) tr.Append(MakeCell(Convert.ToDouble(ds.Tables[0].Rows[i]["cfa_annual_contrib"]).ToString("C0"), false, true,"","276"));
                                    if (!Convert.ToBoolean(dr["current_funding_hidden"].ToString())) tr.Append(MakeCell(Convert.ToDouble(ds.Tables[0].Rows[i]["cfa_reserve_fund_bal"]).ToString("C0"), false, true, "", "276"));
                                    if (!Convert.ToBoolean(dr["full_funding_hidden"].ToString())) tr.Append(MakeCell(Convert.ToDouble(ds.Tables[0].Rows[i]["ffa_req_annual_contr"]).ToString("C0"), false, true, "", "276"));
                                    if (!Convert.ToBoolean(dr["full_funding_hidden"].ToString())) tr.Append(MakeCell(Convert.ToDouble(ds.Tables[0].Rows[i]["ffa_avg_req_annual_contr"]).ToString("C0"), false, true, "", "276"));
                                    if (!Convert.ToBoolean(dr["full_funding_hidden"].ToString())) tr.Append(MakeCell(Convert.ToDouble(ds.Tables[0].Rows[i]["ffa_res_fund_bal"]).ToString("C0"), false, true, "", "276"));
                                    if (!Convert.ToBoolean(dr["baseline_funding_hidden"].ToString())) tr.Append(MakeCell(Convert.ToDouble(ds.Tables[0].Rows[i]["bfa_annual_contr"]).ToString("C0"), false, true, "", "276"));
                                    if (!Convert.ToBoolean(dr["baseline_funding_hidden"].ToString()))
                                    {
                                        if (Convert.ToDouble(ds.Tables[0].Rows[i]["year_id"].ToString()) == lowestBFYear)
                                        {
                                            tr.Append(MakeCell(Convert.ToDouble(ds.Tables[0].Rows[i]["bfa_res_fund_bal"]).ToString("C0"), false, false, "92D050", "276"));
                                        }
                                        else
                                        {
                                            tr.Append(MakeCell(Convert.ToDouble(ds.Tables[0].Rows[i]["bfa_res_fund_bal"]).ToString("C0"), false, true, "", "276"));
                                        }
                                    }
                                    if ((Convert.ToBoolean(dr["threshold_used"].ToString()) == true) && (ds.Tables[0].Rows[i]["tfa2_annual_contr"].ToString()==""))
                                        tr.Append(MakeCell("-", false,false,"","276"));
                                    else if (Convert.ToBoolean(dr["threshold_used"].ToString()) == true)
                                        tr.Append(MakeCell(Convert.ToDouble(ds.Tables[0].Rows[i]["tfa2_annual_contr"]).ToString("C0"), false, true, "", "276"));

                                    if ((Convert.ToBoolean(dr["threshold_used"].ToString()) == true) && (ds.Tables[0].Rows[i]["tfa2_res_fund_bal"].ToString()==""))
                                        tr.Append(MakeCell("-", false,false,"","276"));
                                    else if (Convert.ToBoolean(dr["threshold_used"].ToString()) == true)
                                    {
                                        if (Convert.ToDouble(ds.Tables[0].Rows[i]["year_id"].ToString())==lowestTFYear) {
                                            tr.Append(MakeCell(Convert.ToDouble(ds.Tables[0].Rows[i]["tfa2_res_fund_bal"]).ToString("C0"), false, false, "92D050","276"));
                                        }
                                        else
                                        {
                                            tr.Append(MakeCell(Convert.ToDouble(ds.Tables[0].Rows[i]["tfa2_res_fund_bal"]).ToString("C0"), false, true,"","276"));
                                        }
                                    }

                                    tbl.Append(tr);

                                    if (!Convert.ToBoolean(dr["current_funding_hidden"].ToString())) ttl[0] += Convert.ToDouble(ds.Tables[0].Rows[i]["cfa_annual_contrib"].ToString());
                                    if (!Convert.ToBoolean(dr["full_funding_hidden"].ToString())) ttl[1] += Convert.ToDouble(ds.Tables[0].Rows[i]["ffa_req_annual_contr"].ToString());
                                    if (!Convert.ToBoolean(dr["full_funding_hidden"].ToString())) ttl[2] += Convert.ToDouble(ds.Tables[0].Rows[i]["ffa_avg_req_annual_contr"].ToString());
                                    if (!Convert.ToBoolean(dr["baseline_funding_hidden"].ToString())) ttl[3] += Convert.ToDouble(ds.Tables[0].Rows[i]["bfa_annual_contr"].ToString());
                                    if ((Convert.ToBoolean(dr["threshold_used"].ToString()) == true) && (ds.Tables[0].Rows[i]["tfa2_annual_contr"].ToString()!="")) ttl[4] += Convert.ToDouble(ds.Tables[0].Rows[i]["tfa2_annual_contr"].ToString());
                                }

                                tr = new DocumentFormat.OpenXml.Wordprocessing.TableRow();
                                tr.Append(MakeCell("TOTAL", true,false,"","276"));
                                tr.Append(MakeCell("", true,false,"","276"));
                                if (!Convert.ToBoolean(dr["current_funding_hidden"].ToString())) tr.Append(MakeCell(ttl[0].ToString("C0"), true, true, "", "276"));
                                if (!Convert.ToBoolean(dr["current_funding_hidden"].ToString())) tr.Append(MakeCell("", true, false,"", "276"));
                                if (!Convert.ToBoolean(dr["full_funding_hidden"].ToString())) tr.Append(MakeCell(ttl[1].ToString("C0"), true, true, "", "276"));
                                if (!Convert.ToBoolean(dr["full_funding_hidden"].ToString())) tr.Append(MakeCell(ttl[2].ToString("C0"), true, true, "", "276"));
                                if (!Convert.ToBoolean(dr["full_funding_hidden"].ToString())) tr.Append(MakeCell("", true, true, "", "276"));
                                if (!Convert.ToBoolean(dr["baseline_funding_hidden"].ToString())) tr.Append(MakeCell(ttl[3].ToString("C0"), true, true, "", "276"));
                                if (!Convert.ToBoolean(dr["baseline_funding_hidden"].ToString())) tr.Append(MakeCell("", true, true, "", "276"));
                                if (Convert.ToBoolean(dr["threshold_used"].ToString()))
                                {
                                    tr.Append(MakeCell(ttl[4].ToString("C0"), true, true, "", "276"));
                                    tr.Append(MakeCell("", true,false,"","276"));
                                }
                                tbl.Append(tr);

                                //EditTblCell(tbl, 3, 3,"here");
                                if (!Convert.ToBoolean(dr["current_funding_hidden"].ToString())) tbl.Descendants<DocumentFormat.OpenXml.Wordprocessing.TableRow>().ElementAt(3).Descendants<DocumentFormat.OpenXml.Wordprocessing.TableCell>().ElementAt(FindTblCol(tbl,"current", Convert.ToBoolean(dr["full_funding_hidden"].ToString()))).Elements<Paragraph>().First().Elements<DocumentFormat.OpenXml.Wordprocessing.Run>().First().Elements<Text>().First().Text = Convert.ToDouble(dr["begin_balance"]).ToString("C0");
                                if (!Convert.ToBoolean(dr["full_funding_hidden"].ToString())) tbl.Descendants<DocumentFormat.OpenXml.Wordprocessing.TableRow>().ElementAt(3).Descendants<DocumentFormat.OpenXml.Wordprocessing.TableCell>().ElementAt(FindTblCol(tbl, "full", Convert.ToBoolean(dr["full_funding_hidden"].ToString()))).Elements<Paragraph>().First().Elements<DocumentFormat.OpenXml.Wordprocessing.Run>().First().Elements<Text>().First().Text = Convert.ToDouble(dr["begin_balance"]).ToString("C0");
                                if (!Convert.ToBoolean(dr["baseline_funding_hidden"].ToString())) tbl.Descendants<DocumentFormat.OpenXml.Wordprocessing.TableRow>().ElementAt(3).Descendants<DocumentFormat.OpenXml.Wordprocessing.TableCell>().ElementAt(FindTblCol(tbl, "baseline", Convert.ToBoolean(dr["full_funding_hidden"].ToString()))).Elements<Paragraph>().First().Elements<DocumentFormat.OpenXml.Wordprocessing.Run>().First().Elements<Text>().First().Text = Convert.ToDouble(dr["begin_balance"]).ToString("C0");
                                if (Convert.ToBoolean(dr["threshold_used"].ToString()) == true) tbl.Descendants<DocumentFormat.OpenXml.Wordprocessing.TableRow>().ElementAt(3).Descendants<DocumentFormat.OpenXml.Wordprocessing.TableCell>().ElementAt(FindTblCol(tbl, "threshold", Convert.ToBoolean(dr["full_funding_hidden"].ToString()))).Elements<Paragraph>().First().Elements<DocumentFormat.OpenXml.Wordprocessing.Run>().First().Elements<Text>().First().Text = Convert.ToDouble(dr["begin_balance"]).ToString("C0");

                                if (!Convert.ToBoolean(dr["baseline_funding_hidden"].ToString())) tbl.Descendants<DocumentFormat.OpenXml.Wordprocessing.TableRow>().ElementAt(2).Descendants<DocumentFormat.OpenXml.Wordprocessing.TableCell>().ElementAt(FindTblCol(tbl, "baseline", Convert.ToBoolean(dr["full_funding_hidden"].ToString()))).Elements<Paragraph>().First().Elements<DocumentFormat.OpenXml.Wordprocessing.Run>().First().Elements<Text>().First().Text = (ttl[3] / ttl[1]).ToString("P2");
                                if (Convert.ToBoolean(dr["threshold_used"].ToString()) == true) tbl.Descendants<DocumentFormat.OpenXml.Wordprocessing.TableRow>().ElementAt(2).Descendants<DocumentFormat.OpenXml.Wordprocessing.TableCell>().ElementAt(FindTblCol(tbl, "threshold", Convert.ToBoolean(dr["full_funding_hidden"].ToString()))).Elements<Paragraph>().First().Elements<DocumentFormat.OpenXml.Wordprocessing.Run>().First().Elements<Text>().First().Text = (ttl[4] / ttl[1]).ToString("P2");

                                //tbl.Descendants<DocumentFormat.OpenXml.Wordprocessing.TableRow>().ElementAt(4).Remove();
                                //tbl.Descendants<DocumentFormat.OpenXml.Wordprocessing.Column>().ElementAt(9).Remove();
                                
                            }
                            else if (tProp.TableCaption.Val == "Summary")
                            {
                                ttl = new double[5] { 0, 0, 0, 0, 0 };
                                TableCellProperties tcp;
                                DocumentFormat.OpenXml.Wordprocessing.Table tbl = (DocumentFormat.OpenXml.Wordprocessing.Table)tProp.Parent;

                                TableProperties props = new TableProperties();
                                tbl.AppendChild<TableProperties>(props);
                                TableLayout tl = new TableLayout() { Type = TableLayoutValues.Fixed };

                                for (var i = 0; i < ds.Tables[1].Rows.Count; i++)
                                {
                                    tr = new DocumentFormat.OpenXml.Wordprocessing.TableRow();
                                    tr.Append(MakeCell(ds.Tables[1].Rows[i]["category_desc"].ToString() + " totals", false));
                                    tr.Append(MakeCell(Convert.ToDouble(ds.Tables[1].Rows[i]["res_req_pres_dols"]).ToString("C0"), false));
                                    tr.Append(MakeCell(Convert.ToDouble(ds.Tables[1].Rows[i]["begin_bal"]).ToString("C0"), false));
                                    tr.Append(MakeCell((Convert.ToDouble(ds.Tables[1].Rows[i]["res_req_pres_dols"].ToString())- Convert.ToDouble(ds.Tables[1].Rows[i]["begin_bal"].ToString())).ToString("C0"), false));
                                    tr.Append(MakeCell(Convert.ToDouble(ds.Tables[1].Rows[i]["annual_res_fund_req"]).ToString("C0"), false));
                                    tr.Append(MakeCell(Convert.ToDouble(ds.Tables[1].Rows[i]["full_fund_bal"]).ToString("C0"), false));
                                    if (i == 0)
                                    {
                                        tr.Append(MakeCell("The Percent Funded and Funding Goal are based on fully funding each component within the schedule. Please review the report for various funding strategies", false));

                                        tcp = new TableCellProperties();
                                        tcp.Append(new VerticalMerge() { Val = MergedCellValues.Restart });
                                        tr.Descendants<DocumentFormat.OpenXml.Wordprocessing.TableCell>().ElementAt(6).Append(tcp);
                                    }
                                    else
                                    {
                                        tr.Append(MakeCell("", false));

                                        tcp = new TableCellProperties();
                                        tcp.Append(new VerticalMerge() { Val = MergedCellValues.Continue });
                                        tr.Descendants<DocumentFormat.OpenXml.Wordprocessing.TableCell>().ElementAt(6).Append(tcp);
                                    }
                                    tbl.Append(tr);

                                    ttl[0] += Convert.ToDouble(ds.Tables[1].Rows[i]["res_req_pres_dols"].ToString());
                                    ttl[1] += Convert.ToDouble(ds.Tables[1].Rows[i]["begin_bal"].ToString());
                                    ttl[2] += (Convert.ToDouble(ds.Tables[1].Rows[i]["res_req_pres_dols"].ToString()) - Convert.ToDouble(ds.Tables[1].Rows[i]["begin_bal"].ToString()));
                                    ttl[3] += Convert.ToDouble(ds.Tables[1].Rows[i]["annual_res_fund_req"].ToString());
                                    ttl[4] += Convert.ToDouble(ds.Tables[1].Rows[i]["full_fund_bal"].ToString());
                                }

                                tbl.Descendants<DocumentFormat.OpenXml.Wordprocessing.TableRow>().ElementAt(1).Remove();

                                tr = new DocumentFormat.OpenXml.Wordprocessing.TableRow();
                                tr.Append(MakeCell("GRAND TOTALS", true));
                                tr.Append(MakeCell(ttl[0].ToString("C0"), true));
                                tr.Append(MakeCell(ttl[1].ToString("C0"), true));
                                tr.Append(MakeCell(ttl[2].ToString("C0"), true));
                                tr.Append(MakeCell(ttl[3].ToString("C0"), true));
                                tr.Append(MakeCell(ttl[4].ToString("C0"), true));
                                tr.Append(MakeCell((ttl[1]/ttl[4]).ToString("P2"), true));
                                tbl.Append(tr);

                            }
                        }
                        dr.Close();
                        conn.Close();
                        
                        //MakeComponents();
                        //var text = wordDoc.MainDocumentPart.RootElement.Descendants<Text>().FirstOrDefault(e => e.Text == "***components***");
                        //Paragraph p = (DocumentFormat.OpenXml.Wordprocessing.Paragraph)text.Parent.Parent;
                        //if (text != null)
                        //{
                        //    text.Text = "";
                        //    MakeComponents(p);
                        //    MakeExpenditures(p);
                        //}

                        MakeComponents();
                        MakeNotes();
                        MakeExpenditures();


                        wordDoc.MainDocumentPart.DocumentSettingsPart.Settings.Append(new UpdateFieldsOnOpen() { Val = true });
                        //wordDoc.MainDocumentPart.Document.Append(MakeRun("asdf", false));
                        wordDoc.MainDocumentPart.Document.Save(); // won't update the original file 
                    }
                    Response.ContentType = "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
                    Response.AppendHeader("Content-Disposition", "attachment;filename=reserve.docx");
                    stream.Position = 0;
                    stream.CopyTo(Response.OutputStream);
                    Response.Cookies["downloadStarted"].Value = "1";
                    Response.Flush();
                    Response.End();
                }

            }
            catch (Exception ex)
            {
                if (ex.GetType().IsAssignableFrom(typeof(System.Threading.ThreadAbortException)))
                {
                    //what you want to do when ThreadAbortException occurs         
                }
                else
                {
                    Response.Write("<p style='color: blue'>Drat! Something went wrong generating your document. Please either (1) Click the 'Back' button on your browser and try again, or (2) If the problem persists, copy and paste the below error message and send to an admininistrator. We apologize for the inconvenience!");
                    Response.Write(ex.ToString());
                    Response.Cookies["downloadStarted"].Value = "1";
                }
            }
            finally
            {
                dr = null;
                conn = null;
            }

        }

        public int FindTblCol(DocumentFormat.OpenXml.Wordprocessing.Table tbl, string strCat, bool blFullHidden)
        {
            var x = -1;
            for (var i=0;i< tbl.Descendants<DocumentFormat.OpenXml.Wordprocessing.TableRow>().ElementAt(0).Count(); i++)
            {
                if (tbl.Elements<DocumentFormat.OpenXml.Wordprocessing.TableRow>().ElementAt(0).Elements<DocumentFormat.OpenXml.Wordprocessing.TableCell>().ElementAt(i).InnerText.ToLower().IndexOf(strCat) > -1)
                {
                    x = i;
                    break;
                }
            }
            if (strCat == "full") x = (x * 2) + 2;
            else x = (x * 2) + 1;
            if ((!blFullHidden) && ((strCat == "baseline") || (strCat == "threshold"))) x++;
            return x;
        }

        public DocumentFormat.OpenXml.Wordprocessing.Table RemoveTblCols(DocumentFormat.OpenXml.Wordprocessing.Table tbl, string strCat)
        {
            if (strCat=="threshold")
            {
                tbl.Elements<DocumentFormat.OpenXml.Wordprocessing.TableRow>().ElementAt(3).Elements<DocumentFormat.OpenXml.Wordprocessing.TableCell>().ElementAt(10).Remove();
                tbl.Elements<DocumentFormat.OpenXml.Wordprocessing.TableRow>().ElementAt(3).Elements<DocumentFormat.OpenXml.Wordprocessing.TableCell>().ElementAt(9).Remove();
                tbl.Elements<DocumentFormat.OpenXml.Wordprocessing.TableRow>().ElementAt(2).Elements<DocumentFormat.OpenXml.Wordprocessing.TableCell>().ElementAt(10).Remove();
                tbl.Elements<DocumentFormat.OpenXml.Wordprocessing.TableRow>().ElementAt(2).Elements<DocumentFormat.OpenXml.Wordprocessing.TableCell>().ElementAt(9).Remove();
                tbl.Elements<DocumentFormat.OpenXml.Wordprocessing.TableRow>().ElementAt(1).Elements<DocumentFormat.OpenXml.Wordprocessing.TableCell>().ElementAt(10).Remove();
                tbl.Elements<DocumentFormat.OpenXml.Wordprocessing.TableRow>().ElementAt(1).Elements<DocumentFormat.OpenXml.Wordprocessing.TableCell>().ElementAt(9).Remove();
                tbl.Elements<DocumentFormat.OpenXml.Wordprocessing.TableRow>().ElementAt(0).Elements<DocumentFormat.OpenXml.Wordprocessing.TableCell>().ElementAt(4).Remove();
            }

            if (strCat == "baseline")
            {
                tbl.Elements<DocumentFormat.OpenXml.Wordprocessing.TableRow>().ElementAt(3).Elements<DocumentFormat.OpenXml.Wordprocessing.TableCell>().ElementAt(8).Remove();
                tbl.Elements<DocumentFormat.OpenXml.Wordprocessing.TableRow>().ElementAt(3).Elements<DocumentFormat.OpenXml.Wordprocessing.TableCell>().ElementAt(7).Remove();
                tbl.Elements<DocumentFormat.OpenXml.Wordprocessing.TableRow>().ElementAt(2).Elements<DocumentFormat.OpenXml.Wordprocessing.TableCell>().ElementAt(8).Remove();
                tbl.Elements<DocumentFormat.OpenXml.Wordprocessing.TableRow>().ElementAt(2).Elements<DocumentFormat.OpenXml.Wordprocessing.TableCell>().ElementAt(7).Remove();
                tbl.Elements<DocumentFormat.OpenXml.Wordprocessing.TableRow>().ElementAt(1).Elements<DocumentFormat.OpenXml.Wordprocessing.TableCell>().ElementAt(8).Remove();
                tbl.Elements<DocumentFormat.OpenXml.Wordprocessing.TableRow>().ElementAt(1).Elements<DocumentFormat.OpenXml.Wordprocessing.TableCell>().ElementAt(7).Remove();
                tbl.Elements<DocumentFormat.OpenXml.Wordprocessing.TableRow>().ElementAt(0).Elements<DocumentFormat.OpenXml.Wordprocessing.TableCell>().ElementAt(3).Remove();
            }

            //Remove full funding columns if need be
            if (strCat=="full")
            {
                tbl.Elements<DocumentFormat.OpenXml.Wordprocessing.TableRow>().ElementAt(3).Elements<DocumentFormat.OpenXml.Wordprocessing.TableCell>().ElementAt(6).Remove();
                tbl.Elements<DocumentFormat.OpenXml.Wordprocessing.TableRow>().ElementAt(3).Elements<DocumentFormat.OpenXml.Wordprocessing.TableCell>().ElementAt(5).Remove();
                tbl.Elements<DocumentFormat.OpenXml.Wordprocessing.TableRow>().ElementAt(3).Elements<DocumentFormat.OpenXml.Wordprocessing.TableCell>().ElementAt(4).Remove();
                tbl.Elements<DocumentFormat.OpenXml.Wordprocessing.TableRow>().ElementAt(2).Elements<DocumentFormat.OpenXml.Wordprocessing.TableCell>().ElementAt(6).Remove();
                tbl.Elements<DocumentFormat.OpenXml.Wordprocessing.TableRow>().ElementAt(2).Elements<DocumentFormat.OpenXml.Wordprocessing.TableCell>().ElementAt(5).Remove();
                tbl.Elements<DocumentFormat.OpenXml.Wordprocessing.TableRow>().ElementAt(2).Elements<DocumentFormat.OpenXml.Wordprocessing.TableCell>().ElementAt(4).Remove();
                tbl.Elements<DocumentFormat.OpenXml.Wordprocessing.TableRow>().ElementAt(1).Elements<DocumentFormat.OpenXml.Wordprocessing.TableCell>().ElementAt(6).Remove();
                tbl.Elements<DocumentFormat.OpenXml.Wordprocessing.TableRow>().ElementAt(1).Elements<DocumentFormat.OpenXml.Wordprocessing.TableCell>().ElementAt(5).Remove();
                tbl.Elements<DocumentFormat.OpenXml.Wordprocessing.TableRow>().ElementAt(1).Elements<DocumentFormat.OpenXml.Wordprocessing.TableCell>().ElementAt(4).Remove();
                tbl.Elements<DocumentFormat.OpenXml.Wordprocessing.TableRow>().ElementAt(0).Elements<DocumentFormat.OpenXml.Wordprocessing.TableCell>().ElementAt(2).Remove();
            }

            //Remove current funding columns if need be
            if (strCat=="current")
            {
                tbl.Elements<DocumentFormat.OpenXml.Wordprocessing.TableRow>().ElementAt(3).Elements<DocumentFormat.OpenXml.Wordprocessing.TableCell>().ElementAt(3).Remove();
                tbl.Elements<DocumentFormat.OpenXml.Wordprocessing.TableRow>().ElementAt(3).Elements<DocumentFormat.OpenXml.Wordprocessing.TableCell>().ElementAt(2).Remove();
                tbl.Elements<DocumentFormat.OpenXml.Wordprocessing.TableRow>().ElementAt(2).Elements<DocumentFormat.OpenXml.Wordprocessing.TableCell>().ElementAt(3).Remove();
                tbl.Elements<DocumentFormat.OpenXml.Wordprocessing.TableRow>().ElementAt(2).Elements<DocumentFormat.OpenXml.Wordprocessing.TableCell>().ElementAt(2).Remove();
                tbl.Elements<DocumentFormat.OpenXml.Wordprocessing.TableRow>().ElementAt(1).Elements<DocumentFormat.OpenXml.Wordprocessing.TableCell>().ElementAt(3).Remove();
                tbl.Elements<DocumentFormat.OpenXml.Wordprocessing.TableRow>().ElementAt(1).Elements<DocumentFormat.OpenXml.Wordprocessing.TableCell>().ElementAt(2).Remove();
                tbl.Elements<DocumentFormat.OpenXml.Wordprocessing.TableRow>().ElementAt(0).Elements<DocumentFormat.OpenXml.Wordprocessing.TableCell>().ElementAt(1).Remove();
            }


            return tbl;
        }

        public int FindLCPos (LineChart lc, string strSearchText)
        {
            int iPos = -1;
            for (var i=0; i<lc.Count(); i++)
            {
                if (lc.ElementAt(i).InnerText.ToLower().IndexOf(strSearchText)>-1)
                {
                    iPos = i;
                    return iPos;
                }
            }
            return iPos;
        }
        public void MakeExpenditures()
        {
            var text = wordDoc.MainDocumentPart.RootElement.Descendants<Text>().FirstOrDefault(e => e.Text == "***expenditures***");
            if (text==null) { return; }
            Paragraph pMarker = (DocumentFormat.OpenXml.Wordprocessing.Paragraph)text.Parent.Parent;
            if (text != null) text.Text = "";

            var p = new Paragraph();
            p.ParagraphProperties = new ParagraphProperties(new ParagraphStyleId() { Val = "Heading1" });
            p.Append(new DocumentFormat.OpenXml.Wordprocessing.Run(new Text("Expenditures List by Year")));
            pMarker.InsertBeforeSelf(p);

            DocumentFormat.OpenXml.Wordprocessing.Table table = new DocumentFormat.OpenXml.Wordprocessing.Table();

            TableProperties tblProp = new TableProperties(
                new TableBorders(
                    new DocumentFormat.OpenXml.Wordprocessing.BottomBorder() { Val = new EnumValue<BorderValues>(BorderValues.Single), Size = 1 },
                    new DocumentFormat.OpenXml.Wordprocessing.TopBorder() { Val = new EnumValue<BorderValues>(BorderValues.Single), Size = 1 },
                    new DocumentFormat.OpenXml.Wordprocessing.LeftBorder() { Val = new EnumValue<BorderValues>(BorderValues.Single), Size = 1 },
                    new DocumentFormat.OpenXml.Wordprocessing.RightBorder() { Val = new EnumValue<BorderValues>(BorderValues.Single), Size = 1 },
                    new DocumentFormat.OpenXml.Wordprocessing.InsideHorizontalBorder() { Val = new EnumValue<BorderValues>(BorderValues.Single), Size = 1 }
                )
            );
            table.AppendChild<TableProperties>(tblProp);

            Int16 beginYear = 0;
            SqlDataReader dr = reserve.Fn_enc.ExecuteReader("select year(report_effective) as yr from info_project_info where firm_id=@Param1 and project_id=@Param2", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString() });
            if (dr.Read()) beginYear = Convert.ToInt16(dr["yr"].ToString());
            dr.Close();

            var conn = Fn_enc.getconn();
            conn.Open();
            SqlDataAdapter adapter = new SqlDataAdapter("sp_app_rvw_expend " + Session["firmid"].ToString() + ", '" + Session["projectid"].ToString() + "'", conn);
            DataSet ds = new DataSet();
            System.Data.DataTable dt;
            conn.Close();
            adapter.Fill(ds, "Recs");
            adapter.Dispose();
            DocumentFormat.OpenXml.Wordprocessing.TableRow tr = new DocumentFormat.OpenXml.Wordprocessing.TableRow();
            double ttl;

            for (var i=1; i<31; i++)
            {
                var tblComps = new DocumentFormat.OpenXml.Wordprocessing.Table();
                var tc = new DocumentFormat.OpenXml.Wordprocessing.TableCell();
                DocumentFormat.OpenXml.Wordprocessing.TableRow trComp;
                TableCellProperties tcp = new TableCellProperties();
                tcp.Append(new TableCellMargin(new LeftMargin() { Width = "0" }), new TableCellMargin(new RightMargin() { Width = "0" }));
                tc.Append(tcp);
                if ((i%2)==1) { tr = new DocumentFormat.OpenXml.Wordprocessing.TableRow(); }
                tr.Append(MakeExpCell(new DocumentFormat.OpenXml.Wordprocessing.Shading() { Color = "auto", Fill = "E98300", Val = ShadingPatternValues.Clear }, new DocumentFormat.OpenXml.Wordprocessing.Color() { ThemeColor = ThemeColorValues.Background1 }, true, (beginYear + i - 1).ToString(), ".87in"));
                //****
                ds.Tables[0].DefaultView.RowFilter = "year_id=" + (i + 1);
                dt = (ds.Tables[0].DefaultView).ToTable();
                ttl = new double();
                for (var j = 0; j < dt.Rows.Count; j++)
                {
                    trComp = new DocumentFormat.OpenXml.Wordprocessing.TableRow();
                    if (j % 2 == 0)
                    {
                        trComp.Append(MakeExpCell(new DocumentFormat.OpenXml.Wordprocessing.Shading() { Color = "auto", Fill = "E7E6E6", Val = ShadingPatternValues.Clear }, new DocumentFormat.OpenXml.Wordprocessing.Color() { ThemeColor = ThemeColorValues.Text1 }, false, dt.Rows[j]["component_desc"].ToString(), "1.95in"));
                        trComp.Append(MakeExpCell(new DocumentFormat.OpenXml.Wordprocessing.Shading() { Color = "auto", Fill = "E7E6E6", Val = ShadingPatternValues.Clear }, new DocumentFormat.OpenXml.Wordprocessing.Color() { ThemeColor = ThemeColorValues.Text1 }, false, Convert.ToDouble(dt.Rows[j]["ttl"]).ToString("C0"), ".93in"));
                    }
                    else
                    {
                        trComp.Append(MakeExpCell(new DocumentFormat.OpenXml.Wordprocessing.Shading() { Color = "auto", Fill = "FFFFFF", Val = ShadingPatternValues.Clear }, new DocumentFormat.OpenXml.Wordprocessing.Color() { ThemeColor = ThemeColorValues.Text1 }, false, dt.Rows[j]["component_desc"].ToString(), "1.95in"));
                        trComp.Append(MakeExpCell(new DocumentFormat.OpenXml.Wordprocessing.Shading() { Color = "auto", Fill = "FFFFFF", Val = ShadingPatternValues.Clear }, new DocumentFormat.OpenXml.Wordprocessing.Color() { ThemeColor = ThemeColorValues.Text1 }, false, Convert.ToDouble(dt.Rows[j]["ttl"]).ToString("C0"), ".93in"));
                    }
                    tblComps.Append(trComp);
                    ttl += Convert.ToDouble(dt.Rows[j]["ttl"].ToString());
                }
                //Totals
                trComp = new DocumentFormat.OpenXml.Wordprocessing.TableRow();
                trComp.Append(MakeExpCell(new DocumentFormat.OpenXml.Wordprocessing.Shading() { Color = "auto", Fill = "BFBFBF", Val = ShadingPatternValues.Clear }, new DocumentFormat.OpenXml.Wordprocessing.Color() { ThemeColor = ThemeColorValues.Text1 }, true, "TOTALS", "1.95in"));
                trComp.Append(MakeExpCell(new DocumentFormat.OpenXml.Wordprocessing.Shading() { Color = "auto", Fill = "BFBFBF", Val = ShadingPatternValues.Clear }, new DocumentFormat.OpenXml.Wordprocessing.Color() { ThemeColor = ThemeColorValues.Text1 }, true, ttl.ToString("C0"), ".93in"));
                tblComps.Append(trComp);
                tc.Append(tblComps);
                tc.Append(new Paragraph());
                tr.Append(tc);
                //****
                if ((i%2)==0) { table.Append(tr); }
            }
            pMarker.InsertBeforeSelf(table);
        }

        public DocumentFormat.OpenXml.Wordprocessing.TableCell MakeExpCell(DocumentFormat.OpenXml.Wordprocessing.Shading bkg, DocumentFormat.OpenXml.Wordprocessing.Color fg, bool bold, string str, string len)
        {
            var c = new DocumentFormat.OpenXml.Wordprocessing.TableCell();
            var p = new Paragraph();
            SpacingBetweenLines spacing = new SpacingBetweenLines() { Line = "240", LineRule = LineSpacingRuleValues.Auto, Before = "0", After = "0" };
            ParagraphProperties paragraphProperties = new ParagraphProperties();
            paragraphProperties.Append(spacing);
            p.Append(paragraphProperties);

            DocumentFormat.OpenXml.Wordprocessing.RunProperties rp = new DocumentFormat.OpenXml.Wordprocessing.RunProperties();
            rp.Append(fg);

            DocumentFormat.OpenXml.Wordprocessing.TableCellProperties tcp = new DocumentFormat.OpenXml.Wordprocessing.TableCellProperties();
            tcp.Append(new TableCellVerticalAlignment() { Val = TableVerticalAlignmentValues.Top });
            tcp.Append(new TableCellWidth() { Type = TableWidthUnitValues.Dxa, Width = len });
            tcp.Append(new TableCellMargin(new LeftMargin() { Width = "0" }),new TableCellMargin(new RightMargin() { Width = "0" }));

            tcp.Append(bkg);


            //Run properties
            DocumentFormat.OpenXml.Wordprocessing.RunFonts runFont = new DocumentFormat.OpenXml.Wordprocessing.RunFonts() { Ascii = "Arial" };
            DocumentFormat.OpenXml.Wordprocessing.FontSize fs = new DocumentFormat.OpenXml.Wordprocessing.FontSize() { Val = "14" };
            rp.Append(runFont);
            rp.Append(fs);
            if (bold) rp.Append(new DocumentFormat.OpenXml.Wordprocessing.Bold());

            var run = new DocumentFormat.OpenXml.Wordprocessing.Run(rp, new Text(str));
            p.Append(run);
            c.Append(tcp);
            c.Append(p);

            return c;
        }

        public void MakeNotes()
        {
            var text = wordDoc.MainDocumentPart.RootElement.Descendants<Text>().FirstOrDefault(e => e.Text == "***notes***");
            Paragraph pMarker = (DocumentFormat.OpenXml.Wordprocessing.Paragraph)text.Parent.Parent;
            if (text != null) text.Text = "";

            int imgId = 1;

            DocumentFormat.OpenXml.Wordprocessing.RunProperties rp2 = new DocumentFormat.OpenXml.Wordprocessing.RunProperties();
            RunFonts rf = new RunFonts() { Ascii = "Verdana" };
            DocumentFormat.OpenXml.Wordprocessing.FontSize fs2 = new DocumentFormat.OpenXml.Wordprocessing.FontSize() { Val = "36" };
            DocumentFormat.OpenXml.Wordprocessing.Color c2 = new DocumentFormat.OpenXml.Wordprocessing.Color() { ThemeColor = ThemeColorValues.Accent6 };
            rp2.Append(rf);
            rp2.Append(fs2);
            rp2.Append(new DocumentFormat.OpenXml.Wordprocessing.Bold());
            rp2.Append(c2);
            var run2 = new DocumentFormat.OpenXml.Wordprocessing.Run(rp2, new Text("Notes"));
            var p3 = new Paragraph(run2);
            pMarker.InsertBeforeSelf(p3);
            
            var dr2 = Fn_enc.ExecuteReader("select top 1 firm_id from info_components_images where firm_id=@Param1 and project_id=@Param2", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString() });
            if (dr2.Read())
            {
                var conn = Fn_enc.getconn();
                conn.Open();
                DocumentFormat.OpenXml.Wordprocessing.Table imgtable = new DocumentFormat.OpenXml.Wordprocessing.Table();
                TableProperties tableProp = new TableProperties();
                TableWidth tableWidth = new TableWidth() { Width = "5000", Type = TableWidthUnitValues.Pct };
                tableProp.Append(tableWidth);
                imgtable.AppendChild(tableProp);

                ImagePart ip;
                SqlCommand cmd = new SqlCommand("sp_app_notes " + Session["firmid"].ToString() + ", '" + Session["projectid"].ToString() + "', -1", conn);
                var img = cmd.ExecuteReader();
                DocumentFormat.OpenXml.Wordprocessing.TableRow tr;
                while (img.Read())
                {
                    if ((blDetailedStudy) && (img[2].ToString() != "0"))
                    {
                        ip = wordDoc.MainDocumentPart.AddImagePart(ImagePartType.Jpeg, "img" + imgId.ToString());
                        MemoryStream ms = new MemoryStream((byte[])img[0]);
                        ip.FeedData(ms);

                        tr = new DocumentFormat.OpenXml.Wordprocessing.TableRow();

                        tr.Append(MakeNoteCell("", img[3].ToString() + ". " + img[1].ToString(), true));
                        tr.Append(MakeNoteCell(wordDoc.MainDocumentPart.GetIdOfPart(ip), "", true));
                        //System.Diagnostics.Debug.WriteLine(wordDoc.MainDocumentPart.GetIdOfPart(ip));
                        imgId++;
                        ms.Dispose();
                    }
                    else
                    {
                        tr = new DocumentFormat.OpenXml.Wordprocessing.TableRow();
                        tr.Append(MakeNoteCell("", img[3].ToString() + ". " + img[1].ToString() + "", false));
                    }
                    imgtable.Append(tr);
                }
                img.Close();
                conn.Close();

                pMarker.InsertBeforeSelf(imgtable);
            }
            dr2.Close();
        }

        public void RemoveText(string strText)
        {
            try
            {
                foreach (var text in wordDoc.MainDocumentPart.Document.Body.Descendants<Text>())
                {
                    if (text.Text.Contains(strText))
                    {
                        Paragraph p = (DocumentFormat.OpenXml.Wordprocessing.Paragraph)text.Parent.Parent;
                        p.Remove();
                    }
                }
            }
            finally { }
        }

        public void MakeComponents()
        {
            var text = wordDoc.MainDocumentPart.RootElement.Descendants<Text>().FirstOrDefault(e => e.Text == "***components***");
            Paragraph pMarker = (DocumentFormat.OpenXml.Wordprocessing.Paragraph)text.Parent.Parent;
            if (text != null) text.Text = "";

            Paragraph pReturn = new Paragraph();
            double[] ttl = new double[4] { 0, 0, 0, 0 };
            SqlDataReader dr = Fn_enc.ExecuteReader("select ipi.project_type_id, icc.* from info_component_categories icc inner join info_project_info ipi on icc.firm_id=ipi.firm_id and icc.project_id=ipi.project_id where icc.firm_id=@Param1 and icc.project_id=@Param2", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString() });
            SqlDataReader dr2;
            DocumentFormat.OpenXml.Wordprocessing.TableCell tc;
            int i = 0;
            Paragraph p;


            while (dr.Read())
            {
                p = new Paragraph();
                p.Append(new DocumentFormat.OpenXml.Wordprocessing.Run(new DocumentFormat.OpenXml.Wordprocessing.Break() { Type = BreakValues.Page }));
                pMarker.InsertBeforeSelf(p);

                DocumentFormat.OpenXml.Wordprocessing.RunProperties rp = new DocumentFormat.OpenXml.Wordprocessing.RunProperties();

                RunFonts runFont = new RunFonts() { Ascii = "Verdana" };
                DocumentFormat.OpenXml.Wordprocessing.FontSize fs = new DocumentFormat.OpenXml.Wordprocessing.FontSize() { Val = "36" };
                DocumentFormat.OpenXml.Wordprocessing.Color c = new DocumentFormat.OpenXml.Wordprocessing.Color() { ThemeColor = ThemeColorValues.Accent6 };
                rp.Append(runFont);
                rp.Append(fs);
                rp.Append(new DocumentFormat.OpenXml.Wordprocessing.Bold());
                rp.Append(c);

                var run = new DocumentFormat.OpenXml.Wordprocessing.Run(rp, new Text(dr["category_desc"].ToString()));

                p = new Paragraph();
                p.Append(run);
                pMarker.InsertBeforeSelf(p);

                DocumentFormat.OpenXml.Wordprocessing.Table table = new DocumentFormat.OpenXml.Wordprocessing.Table();

                TableBorders tblBorders = new TableBorders();
                var topBorder = new DocumentFormat.OpenXml.Wordprocessing.TopBorder();
                topBorder.Val = new EnumValue<BorderValues>(BorderValues.Thick);
                topBorder.Color = "000000";
                tblBorders.AppendChild(topBorder);

                var insideHBorder = new DocumentFormat.OpenXml.Wordprocessing.InsideHorizontalBorder();
                insideHBorder.Val = new EnumValue<BorderValues>(BorderValues.Thick);
                insideHBorder.Color = "000000";
                tblBorders.AppendChild(insideHBorder);

                // Create a TableProperties object and specify its border information.
                TableProperties tblProp = new TableProperties(
                    new TableBorders(
                        new DocumentFormat.OpenXml.Wordprocessing.BottomBorder() { Val = new EnumValue<BorderValues>(BorderValues.Single), Size = 1 }
                    ),
                    new TableWidth() { Width = "5000", Type = TableWidthUnitValues.Pct }
                );

                tblProp.AppendChild(tblBorders);

                TableLayout tl = new TableLayout() { Type = TableLayoutValues.Fixed };
                tblProp.TableLayout = tl;

                // Append the TableProperties object to the empty table.
                table.AppendChild(tblProp);

                var tr = new DocumentFormat.OpenXml.Wordprocessing.TableRow();
                tr.Append(MakeComponentCell("Component", false, true, JustificationValues.Left, "1.75in"));
                tr.Append(MakeComponentCell("Quantity", false, true, JustificationValues.Center, ".62in"));
                tr.Append(MakeComponentCell("Unit Cost", false, true, JustificationValues.Center, ".73in"));
                tr.Append(MakeComponentCell("Reserve Requirement Present Dollars", false, true, JustificationValues.Center, ".67in"));
                tr.Append(MakeComponentCell("Beginning Balance", false, true, JustificationValues.Center, ".64in"));
                tr.Append(MakeComponentCell("Estimated Useful Life", false, true, JustificationValues.Center, ".64in"));
                tr.Append(MakeComponentCell("Estimated Remaining Useful Life", false, true, JustificationValues.Center, ".63in"));
                tr.Append(MakeComponentCell("Annual Reserve Funding Required", false, true, JustificationValues.Center, ".68in"));
                tr.Append(MakeComponentCell("Full Funding Balance", false, true, JustificationValues.Center, ".68in"));
                tr.Append(MakeComponentCell("Notes", false, true, JustificationValues.Center, ".43in"));
                table.Append(tr);

                ttl = new double[4] { 0, 0, 0, 0 };
                dr2 = Fn_enc.ExecuteReader("sp_app_rvw_comp1 @Param1, @Param2, 1, @Param3", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString(), dr["category_id"].ToString() });
                while (dr2.Read())
                {
                    tr = new DocumentFormat.OpenXml.Wordprocessing.TableRow();
                    tr.Append(MakeComponentCell(dr2["component_desc"].ToString(), false, false, JustificationValues.Left, "1.75in"));
                    tr.Append(MakeComponentCell(String.Format("{0:#,0}", Convert.ToDouble(dr2["comp_quantity"])).ToString() + " " + dr2["comp_unit"].ToString(), false, false, JustificationValues.Center, ".62in"));
                    tr.Append(MakeComponentCell(Convert.ToDouble(dr2["unit_cost"]).ToString("C2"), false, false, JustificationValues.Center, ".73in"));
                    tr.Append(MakeComponentCell(Convert.ToDouble(dr2["res_req_pres_dols"]).ToString("C0"), false, false, JustificationValues.Center, ".67in"));
                    tr.Append(MakeComponentCell(Convert.ToDouble(dr2["begin_bal_calcd"]).ToString("C0"), false, false, JustificationValues.Center, ".64in"));
                    tr.Append(MakeComponentCell(dr2["est_useful_life"].ToString(), false, false, JustificationValues.Center, ".64in"));
                    tr.Append(MakeComponentCell(dr2["est_rem_useful_life"].ToString(), false, false, JustificationValues.Center, ".63in"));
                    tr.Append(MakeComponentCell(Convert.ToDouble(dr2["annual_res_fund_req"]).ToString("C0"), false, false, JustificationValues.Center, ".68in"));
                    tr.Append(MakeComponentCell(Convert.ToDouble(dr2["full_fund_bal"]).ToString("C0"), false, false, JustificationValues.Center, ".68in"));
                    tr.Append(MakeComponentCell(dr2["comp_note"].ToString(), false, false, JustificationValues.Center, ".43in"));
                    table.Append(tr);
                    ttl[0] += Convert.ToDouble(dr2["res_req_pres_dols"].ToString());
                    ttl[1] += Convert.ToDouble(dr2["begin_bal_calcd"].ToString());
                    ttl[2] += Convert.ToDouble(dr2["annual_res_fund_req"].ToString());
                    ttl[3] += Convert.ToDouble(dr2["full_fund_bal"].ToString());
                }
                dr2.Close();

                tr = new DocumentFormat.OpenXml.Wordprocessing.TableRow();
                tr.Append(MakeComponentCell("TOTALS", true, false, JustificationValues.Left, "1.75in"));
                tr.Append(MakeComponentCell("", false, false, JustificationValues.Center, ".62in"));
                tr.Append(MakeComponentCell("", false, false, JustificationValues.Center, ".73in"));
                tr.Append(MakeComponentCell(ttl[0].ToString("C0"), true, false, JustificationValues.Center, ".67in"));
                tr.Append(MakeComponentCell(ttl[1].ToString("C0"), true, false, JustificationValues.Center, ".64in"));
                tr.Append(MakeComponentCell("", false, false, JustificationValues.Center, ".64in"));
                tr.Append(MakeComponentCell("", false, false, JustificationValues.Center, ".63in"));
                tr.Append(MakeComponentCell(ttl[2].ToString("C0"), true, false, JustificationValues.Center, ".68in"));
                tr.Append(MakeComponentCell(ttl[3].ToString("C0"), true, false, JustificationValues.Center, ".68in"));
                tr.Append(MakeComponentCell("", false, false, JustificationValues.Center, ".43in"));
                table.Append(tr);

                pMarker.InsertBeforeSelf(table);

                i++;
            }

            //if (blPaperUpdate) //If it's a paper update, put all notes here
            //{
            //    dr2 = Fn_enc.ExecuteReader("select top 1 firm_id from info_components_images where firm_id=@Param1 and project_id=@Param2", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString() });
            //    if (dr2.Read())
            //    {
            //        var tr = new DocumentFormat.OpenXml.Wordprocessing.TableRow();
            //        var conn = Fn_enc.getconn();
            //        conn.Open();
            //        var imgtable = new DocumentFormat.OpenXml.Wordprocessing.Table();
            //        TableProperties tableProp = new TableProperties();
            //        TableWidth tableWidth = new TableWidth() { Width = "5000", Type = TableWidthUnitValues.Pct };
            //        tableProp.Append(tableWidth);
            //        imgtable.AppendChild(tableProp);

            //        SqlCommand cmd = new SqlCommand("sp_app_notes " + Session["firmid"].ToString() + ", '" + Session["projectid"].ToString() + "', -1", conn);
            //        var img = cmd.ExecuteReader();
            //        while (img.Read())
            //        {
            //            tr = new DocumentFormat.OpenXml.Wordprocessing.TableRow();

            //            tr.Append(MakeNoteCell("", img[3].ToString() + ". " + img[1].ToString(), false));
            //            imgtable.Append(tr);
            //        }
            //        img.Close();
            //        conn.Close();
            //        pMarker.InsertBeforeSelf(imgtable);
            //    }
            //    dr2.Close();
            //}
            dr.Close();
        }

        /// <summary>
        /// Will create a section properties
        /// </summary>
        /// <param name="orientation">The wanted orientation (landscape or portrai)</param>
        /// <returns>A section properties element</returns>
        public static SectionProperties CreateSectionProperties(PageOrientationValues orientation)
        {
            // create the section properties
            SectionProperties properties = new SectionProperties();
            // create the height and width
            UInt32Value height = orientation == (PageOrientationValues.Portrait) ? 16839U : 11907U;
            UInt32Value width = orientation != (PageOrientationValues.Portrait) ? 16839U : 11907U;
            // create the page size and insert the wanted orientation
            PageSize pageSize = new PageSize()
            {
                Width = width,
                Height = height,
                Code = (UInt16Value)9U,
                // insert the orientation
                Orient = orientation
            };
            // create the page margin
            PageMargin pageMargin = new PageMargin()
            {
                Top = 1417,
                Right = (UInt32Value)1417U,
                Bottom = 1417,
                Left = (UInt32Value)1417U,
                Header = (UInt32Value)708U,
                Footer = (UInt32Value)708U,
                Gutter = (UInt32Value)0U
            };
            var columns = new DocumentFormat.OpenXml.Wordprocessing.Columns() { Space = "720" };
            DocGrid docGrid = new DocGrid() { LinePitch = 360 };
            // appen the page size and margin
            properties.Append(pageSize, pageMargin, columns, docGrid);
            return properties;
        }

        public Paragraph OrientedParagraph(string sOrientation)
        {
            Paragraph p;
            ParagraphProperties pPr = new ParagraphProperties();
            SectionProperties sPr = new SectionProperties();



            if (sOrientation=="Portrait")
            {
                p = new Paragraph(new SectionProperties(
                    new PageSize() { Width = (UInt32Value)12240U, Height = (UInt32Value)15840U, Orient = PageOrientationValues.Portrait },
                    new PageMargin() { Top = 720, Right = Convert.ToUInt32(1 * 1440.0), Bottom = 360, Left = Convert.ToUInt32(1 * 1440.0), Header = (UInt32Value)450U, Footer = (UInt32Value)720U, Gutter = (UInt32Value)0U }));
            }
            else
            {
                p = new Paragraph(new SectionProperties(
                    new PageSize() { Width = (UInt32Value)15840U, Height = (UInt32Value)12240U, Orient = PageOrientationValues.Landscape },
                    new PageMargin() { Top = 720, Right = Convert.ToUInt32(1 * 1440.0), Bottom = 360, Left = Convert.ToUInt32(1 * 1440.0), Header = (UInt32Value)450U, Footer = (UInt32Value)720U, Gutter = (UInt32Value)0U }));

            }
            SectionType sT = new SectionType() { Val = SectionMarkValues.NextPage };

            sPr.Append(sT);
            pPr.Append(sPr);
            p.Append(pPr);

            return p;
        }

        public static void InsertAPicture(string document, string fileName)
        {
            using (WordprocessingDocument wordprocessingDocument =
                WordprocessingDocument.Open(document, true))
            {
                MainDocumentPart mainPart = wordprocessingDocument.MainDocumentPart;

                ImagePart imagePart = mainPart.AddImagePart(ImagePartType.Jpeg);

                using (FileStream stream = new FileStream(fileName, FileMode.Open))
                {
                    imagePart.FeedData(stream);
                }

                AddImageToBody(wordprocessingDocument, mainPart.GetIdOfPart(imagePart));
            }
        }

        private static void AddImageToBody(WordprocessingDocument wordDoc, string relationshipId)
        {
            // Define the reference of the image.
            var element =
                 new DocumentFormat.OpenXml.Wordprocessing.Drawing(
                     new DW.Inline(
                         new DW.Extent() { Cx = 990000L, Cy = 792000L },
                         new DW.EffectExtent()
                         {
                             LeftEdge = 0L,
                             TopEdge = 0L,
                             RightEdge = 0L,
                             BottomEdge = 0L
                         },
                         new DW.DocProperties()
                         {
                             Id = (UInt32Value)1U,
                             Name = "Picture 1"
                         },
                         new DW.NonVisualGraphicFrameDrawingProperties(
                             new A.GraphicFrameLocks() { NoChangeAspect = true }),
                         new A.Graphic(
                             new A.GraphicData(
                                 new PIC.Picture(
                                     new PIC.NonVisualPictureProperties(
                                         new PIC.NonVisualDrawingProperties()
                                         {
                                             Id = (UInt32Value)0U,
                                             Name = "New Bitmap Image.jpg"
                                         },
                                         new PIC.NonVisualPictureDrawingProperties()),
                                     new PIC.BlipFill(
                                         new A.Blip(
                                             new A.BlipExtensionList(
                                                 new A.BlipExtension()
                                                 {
                                                     Uri =
                                                        "{28A0092B-C50C-407E-A947-70E740481C1C}"
                                                 })
                                         )
                                         {
                                             Embed = relationshipId,
                                             CompressionState =
                                             A.BlipCompressionValues.Print
                                         },
                                         new A.Stretch(
                                             new A.FillRectangle())),
                                     new PIC.ShapeProperties(
                                         new A.Transform2D(
                                             new A.Offset() { X = 0L, Y = 0L },
                                             new A.Extents() { Cx = 990000L, Cy = 792000L }),
                                         new A.PresetGeometry(
                                             new A.AdjustValueList()
                                         )
                                         { Preset = A.ShapeTypeValues.Rectangle }))
                             )
                             { Uri = "http://schemas.openxmlformats.org/drawingml/2006/picture" })
                     )
                     {
                         DistanceFromTop = (UInt32Value)0U,
                         DistanceFromBottom = (UInt32Value)0U,
                         DistanceFromLeft = (UInt32Value)0U,
                         DistanceFromRight = (UInt32Value)0U,
                         EditId = "50D07946"
                     });

            // Append the reference to body, the element should be in a Run.
            wordDoc.MainDocumentPart.Document.Body.AppendChild(new Paragraph(new DocumentFormat.OpenXml.Wordprocessing.Run(element)));
        }

        public DocumentFormat.OpenXml.Wordprocessing.Paragraph MakeRun(string str, bool bld)
        {
            var p = new Paragraph();
            SpacingBetweenLines spacing = new SpacingBetweenLines() { Line = "360", LineRule = LineSpacingRuleValues.Auto, Before = "0", After = "0" };
            ParagraphProperties paragraphProperties = new ParagraphProperties();

            paragraphProperties.Append(spacing);
            p.Append(paragraphProperties);

            DocumentFormat.OpenXml.Wordprocessing.RunProperties rp = new DocumentFormat.OpenXml.Wordprocessing.RunProperties();
            
            RunFonts runFont = new RunFonts() { Ascii = "Arial" };
            DocumentFormat.OpenXml.Wordprocessing.FontSize fs = new DocumentFormat.OpenXml.Wordprocessing.FontSize() { Val = "14" };
            rp.Append(runFont);
            rp.Append(fs);
            if (bld) rp.Append(new DocumentFormat.OpenXml.Wordprocessing.Bold());
            rp.Append(new Justification() { Val = JustificationValues.Center });

            var run = new DocumentFormat.OpenXml.Wordprocessing.Run(rp, new Text(str));
            p.Append(run);

            return p;
        }


        public DocumentFormat.OpenXml.Wordprocessing.TableCell MakeCell(string str, bool bld, bool chkNegative=false, string sBackColor="", string lineSize="360")
        {
            var c = new DocumentFormat.OpenXml.Wordprocessing.TableCell();
            var p = new Paragraph();
            SpacingBetweenLines spacing = new SpacingBetweenLines() { Line = lineSize, LineRule = LineSpacingRuleValues.Auto, Before = "0", After = "0" };
            ParagraphProperties paragraphProperties = new ParagraphProperties();

            paragraphProperties.Append(spacing);
            paragraphProperties.Append(new Justification() { Val = JustificationValues.Center });
            p.Append(paragraphProperties);

            DocumentFormat.OpenXml.Wordprocessing.RunProperties rp = new DocumentFormat.OpenXml.Wordprocessing.RunProperties();

            RunFonts runFont = new RunFonts() { Ascii = "Arial" };
            DocumentFormat.OpenXml.Wordprocessing.FontSize fs = new DocumentFormat.OpenXml.Wordprocessing.FontSize() { Val = "14" };
            rp.Append(runFont);
            rp.Append(fs);

            //If the value is negative and we want to check for that, make the color red
            if (chkNegative)
            {
                try
                {
                    DocumentFormat.OpenXml.Wordprocessing.Color fc = new DocumentFormat.OpenXml.Wordprocessing.Color { Val = "FF0000" };
                    if (double.Parse(str, System.Globalization.NumberStyles.Currency) < 0) rp.Append(fc);
                }
                catch { }
            }

            //Change the background color of the cell
            if (sBackColor!="")
            {
                try
                {
                    TableCellProperties tcp = new TableCellProperties(new TableCellWidth { Type = TableWidthUnitValues.Auto, });
                    // Create the Shading object
                    DocumentFormat.OpenXml.Wordprocessing.Shading shading =
                        new DocumentFormat.OpenXml.Wordprocessing.Shading()
                        {
                            Color = "auto",
                            Fill = sBackColor,
                            Val = ShadingPatternValues.Clear
                        };
                    // Add the Shading object to the TableCellProperties object
                    tcp.Append(shading);
                    c.Append(tcp);
                }
                catch { }
            }

            if (bld) rp.Append(new DocumentFormat.OpenXml.Wordprocessing.Bold());
            rp.Append(new Justification() { Val = JustificationValues.Center });

            var run = new DocumentFormat.OpenXml.Wordprocessing.Run(rp, new Text(str));
            p.Append(run);
            c.Append(p);

            return c;
        }

        public DocumentFormat.OpenXml.Wordprocessing.TableCell MakeComponentCell(string str, bool bld, bool blHdr, JustificationValues jv, string len)
        {
            var c = new DocumentFormat.OpenXml.Wordprocessing.TableCell();
            var p = new Paragraph();
            SpacingBetweenLines spacing = new SpacingBetweenLines() { Line = "240", LineRule = LineSpacingRuleValues.Auto, Before = "0", After = "0" };
            ParagraphProperties paragraphProperties = new ParagraphProperties();
            paragraphProperties.Append(spacing);

            DocumentFormat.OpenXml.Wordprocessing.RunProperties rp = new DocumentFormat.OpenXml.Wordprocessing.RunProperties();

            var tcp = new DocumentFormat.OpenXml.Wordprocessing.TableCellProperties();
            tcp.Append(new TableCellVerticalAlignment() { Val = TableVerticalAlignmentValues.Bottom });
            tcp.Append(new TableBorders(new DocumentFormat.OpenXml.Wordprocessing.BottomBorder() { Val = new EnumValue<BorderValues>(BorderValues.Single), Size = 1 }));
            tcp.Append(new TableCellWidth() { Type = TableWidthUnitValues.Dxa, Width = len });

            paragraphProperties.Append(new Justification() { Val = jv });
            p.Append(paragraphProperties);

            if (blHdr)
            {
                DocumentFormat.OpenXml.Wordprocessing.Shading shading = new DocumentFormat.OpenXml.Wordprocessing.Shading() { Color = "auto", Fill = "E98300", Val = ShadingPatternValues.Clear };
                tcp.Append(shading);
                rp.Append(new DocumentFormat.OpenXml.Wordprocessing.Color() { ThemeColor = ThemeColorValues.Background1 });
            }

            //Run properties
            if (blHdr)
            {
                DocumentFormat.OpenXml.Wordprocessing.RunFonts runFont = new DocumentFormat.OpenXml.Wordprocessing.RunFonts() { Ascii = "Arial Black" };
                DocumentFormat.OpenXml.Wordprocessing.FontSize fs = new DocumentFormat.OpenXml.Wordprocessing.FontSize() { Val = "14" };
                rp.Append(runFont);
                rp.Append(fs);
            }
            else
            {
                DocumentFormat.OpenXml.Wordprocessing.RunFonts runFont = new DocumentFormat.OpenXml.Wordprocessing.RunFonts() { Ascii = "Arial" };
                DocumentFormat.OpenXml.Wordprocessing.FontSize fs = new DocumentFormat.OpenXml.Wordprocessing.FontSize() { Val = "14" };
                rp.Append(runFont);
                rp.Append(fs);
            }
            if (bld) rp.Append(new DocumentFormat.OpenXml.Wordprocessing.Bold());
            rp.Append(new Justification() { Val = JustificationValues.Center });

            var run = new DocumentFormat.OpenXml.Wordprocessing.Run(rp, new Text(str));
            p.Append(run);
            c.Append(tcp);
            c.Append(p);

            return c;
        }
        protected void Page_Load(object sender, EventArgs e)
        {
            Response.Cookies.Add(new HttpCookie("downloadStarted", "1") { Expires = DateTime.Now.AddSeconds(20) });
            try
            {
                DateTime dt_start = DateTime.Now;
                //Session["projectid"] = "10000-07";
                createDoc();
                //Response.Write((DateTime.Now - dt_start).TotalSeconds);
            }
            catch
            {
                Response.Cookies["downloadStarted"].Value = "error";
            }
        }

        private static DocumentFormat.OpenXml.Wordprocessing.Drawing GetImageElement(
            string imagePartId,
            string fileName,
            string pictureName,
            double width,
            double height,
            string id)
        {
            double englishMetricUnitsPerInch = 914400;
            double pixelsPerInch = 96;

            //calculate size in emu
            double emuWidth = width * englishMetricUnitsPerInch / pixelsPerInch;
            double emuHeight = height * englishMetricUnitsPerInch / pixelsPerInch;

            var element = new DocumentFormat.OpenXml.Wordprocessing.Drawing(
                new Inline(
                    new Extent { Cx = (Int64Value)emuWidth, Cy = (Int64Value)emuHeight },
                    new EffectExtent { LeftEdge = 0L, TopEdge = 0L, RightEdge = 0L, BottomEdge = 0L },
                    new DocProperties { Id = 1U, Name = pictureName },
                    new NonVisualGraphicFrameDrawingProperties(
                    new A.GraphicFrameLocks { NoChangeAspect = true }),
                    new A.Graphic(
                        new A.GraphicData(
                            new PIC.Picture(
                                new PIC.NonVisualPictureProperties(
                                    new PIC.NonVisualDrawingProperties { Id = 0U, Name = pictureName },
                                    new PIC.NonVisualPictureDrawingProperties()),
                                new PIC.BlipFill(
                                    new A.Blip(
                                        new A.BlipExtensionList(
                                            new A.BlipExtension { Uri = "{28A0092B-C50C-407E-A947-70E740481C1C}" }))
                                    {
                                        Embed = imagePartId,
                                        CompressionState = A.BlipCompressionValues.Print
                                    },
                                            new A.Stretch(new A.FillRectangle())),
                                new PIC.ShapeProperties(
                                    new A.Transform2D(
                                        new A.Offset { X = 0L, Y = 0L },
                                        new A.Extents { Cx = (Int64Value)emuWidth, Cy = (Int64Value)emuHeight }),
                                    new A.PresetGeometry(
                                        new A.AdjustValueList())
                                    { Preset = A.ShapeTypeValues.Rectangle })))
                        {
                            Uri = "http://schemas.openxmlformats.org/drawingml/2006/picture"
                        }))
                {
                    DistanceFromTop = (UInt32Value)0U,
                    DistanceFromBottom = (UInt32Value)0U,
                    DistanceFromLeft = (UInt32Value)0U,
                    DistanceFromRight = (UInt32Value)0U,
                    EditId = "50D07946"
                });
            return element;
        }

        private DocumentFormat.OpenXml.Wordprocessing.TableCell MakeNoteCell(string relationshipId, string str, bool blBorder)
        {
            DocumentFormat.OpenXml.Wordprocessing.TableCell tc = new DocumentFormat.OpenXml.Wordprocessing.TableCell();
            tc.RemoveAllChildren<Paragraph>();
            if (relationshipId=="")
            {
                var p = new Paragraph();
                //Paragraph properties
                ParagraphProperties paragraphProperties = new ParagraphProperties();
                SpacingBetweenLines spacing = new SpacingBetweenLines() { Before = "0", After = "240" };
                paragraphProperties.Append(spacing);
                DocumentFormat.OpenXml.Wordprocessing.RunProperties rp = new DocumentFormat.OpenXml.Wordprocessing.RunProperties();
                p.Append(paragraphProperties);
                //Cell properties
                DocumentFormat.OpenXml.Wordprocessing.TableCellProperties tcp = new DocumentFormat.OpenXml.Wordprocessing.TableCellProperties();
                tcp.Append(new TableCellMargin(new BottomMargin() { Width = "0" }));
                tcp.Append(new TableCellVerticalAlignment() { Val = TableVerticalAlignmentValues.Top });
                tcp.Append(new TableCellWidth() { Type = TableWidthUnitValues.Dxa, Width = "4.01in" } );
                //Run properties
                DocumentFormat.OpenXml.Wordprocessing.RunFonts runFont = new DocumentFormat.OpenXml.Wordprocessing.RunFonts() { Ascii = "Verdana" };
                DocumentFormat.OpenXml.Wordprocessing.FontSize fs = new DocumentFormat.OpenXml.Wordprocessing.FontSize() { Val = "20" };
                rp.Append(runFont);
                rp.Append(fs);

                var run = new DocumentFormat.OpenXml.Wordprocessing.Run(rp, new Text(str));
                p.Append(run);
                tc.Append(tcp);
                tc.Append(p);
            }
            else {
                var element = GetImageElement(relationshipId, "", "picture", 300, 200, "1U");
                var p = new Paragraph();
                var r = new DocumentFormat.OpenXml.Wordprocessing.Run();
                ParagraphProperties paragraphProperties = new ParagraphProperties();
                SpacingBetweenLines spacing = new SpacingBetweenLines() { Before = "0", After = "0" };
                paragraphProperties.Append(spacing);
                p.Append(paragraphProperties);
                r.Append(element);
                p.Append(r);
                tc.AppendChild(p);
            }
            return tc;
        }

    }
}
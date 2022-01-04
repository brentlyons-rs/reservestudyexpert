<%@ Page Language="C#" MasterPageFile="~/Main.Master" AutoEventWireup="true" CodeBehind="rvw_proj.aspx.cs" Inherits="reserve.rvw_proj" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

<script src="https://ajax.aspnetcdn.com/ajax/jquery/jquery-1.8.0.js"></script>
<script src="https://ajax.aspnetcdn.com/ajax/jquery.ui/1.8.22/jquery-ui.js"></script>
<script src="assets/js/jquery.mask.min.js"></script>
<script src="Scripts/accounting.js"></script>
<link href="https://ajax.aspnetcdn.com/ajax/jquery.ui/1.8.10/themes/redmond/jquery-ui.css" rel="stylesheet" />
<link href="css/style.css" rel="stylesheet" />

<style>
    body:
    {
        line-height: 20px !important;
    }
    iframe { display:block; }
    .bb {
        border-bottom: 1px solid #000000;
        padding: 1px;
    } 
    .threshold1 {
        display: none;
    }
</style>
<script src="Scripts/rvw_proj.js"></script>
    <script>
        function isNumber(evt) {
            evt = (evt) ? evt : window.event;
            var charCode = (evt.which) ? evt.which : evt.keyCode;
            if (charCode != 46 && charCode > 31 && (charCode < 48 || charCode > 57)) {
                return false;
            }
            return true;
        }

        function toggleChkDisp(iField) {
            sVal = "1";
            if (document.getElementById('MainContent_chkDisp' + iField).checked) sVal = "0";
            sendChkDisp(iField, sVal);
        }

        function toggleInterval(iUserSent) {
            if (document.getElementById('MainContent_chkIntervals').checked == true) {
                document.getElementById('tblIntervals').style.display = 'block';
                showIntervals();
            }
            else if (iUserSent == 1) {
                if (confirm("De-selecting the intervals will require a re-calculation of projection data. Are you sure you want to continue?") == 1) {
                    document.getElementById('tblIntervals').style.display = 'none';
                    document.getElementById('MainContent_txtHdnType').value = 'Intervals';
                    document.forms[0].submit();
                }
                else {
                    document.getElementById('MainContent_chkIntervals').checked = true;
                }
            }
            else {
                document.getElementById('tblIntervals').style.display = 'none';
            }
        }

        function showIntervals() {
            for (var i = 1; i < 7; i++) {
                document.getElementById('trI' + i).style.display = 'none';
            }
            for (var i = 1; i <= parseFloat(document.getElementById('MainContent_cboIntervals').value); i++) {
                document.getElementById('trI' + i).style.display = 'block';
            }
        }

        function updateIntervals() {
            var iPrev = parseFloat(document.getElementById('MainContent_cboI' + iStart).value);

            for (var i = iStart + 1; i < 7; i++) {
                //Clear out the options
                for (var x = 30; x >= 0; x--) {
                    document.getElementById('MainContent_cboI' + i).remove(x);
                }
                //Add the appropriate ones
                for (var x = iPrev+1; x < 31; x++) {
                    var opt = document.createElement("option");
                    opt.text = "Year " + x;
                    opt.value = x;
                    document.getElementById('MainContent_cboI' + i).options.add(opt);
                }
                iPrev++;
            }
        }

        function trimIntervalFat() {
            var iPrev = 0;
            for (var i = 2; i <= parseFloat(document.getElementById('MainContent_cboIntervals').value); i++) {
                iPrev = parseFloat(document.getElementById('MainContent_cboI' + (i - 1)).value);
                for (x = document.getElementById('MainContent_cboI' + i).options.length-1; x >= 0; x--) {
                    if (parseFloat(document.getElementById('MainContent_cboI' + i).options[x].value) <= iPrev) {
                        document.getElementById('MainContent_cboI' + i).remove(x);
                    }
                }
            }
        }
    </script>
<form id="frmProject" method="post" runat="server" class="needs-validation">
    <div class="container_fluid" style="width: 100%; max-width: 100%">
        <div class="row float-right" style="margin-top: -4px; margin-left: -2px;">
            <div class="page-top-tab col-lg-3 float-right">
                <p class="panel-title-fd">Review&nbsp;<label id="lblProject" runat="server" class="frm-text"></label></p>
            </div>
        </div>
    </div>
    <% if (Session["projectid"].ToString() == "")
        { %>
    <div class="frm-text-red">Please select a project on the Projects tab first.</div>
    <% }
    else { 
            %>
    <div style="margin-top: 5px">
        <ul class="nav nav-tabs">
            <li class="frm-text">
                <a href="rvw_summ.aspx">Summary</a>
            </li>
            <li class="frm-text">
                <a href="rvw_comp.aspx">Components</a>
            </li>
            <li class="active frm-text">
                <a href="rvw_proj.aspx">Projection</a>
            </li>
            <li class="frm-text">
                <a href="rvw_exp.aspx">Expenditures</a>
            </li>
            <li class="frm-text">
                <a href="rvw_graphs.aspx">Graphs</a>
            </li>
        </ul>
        <table style="margin-top: 10px; margin-bottom: 20px">
            <tr>
                <td valign="top" style="vertical-align: top; border-top: 1px solid #aaaaaa; border-right: 1px solid #aaaaaa">
                    <table>
                        <tr>
                            <td style="background-color: #eeeeee; padding: 5px;" class="frm-text text-left">
                                <%
                                    Boolean blGen = false;
                                    string sStatus;

                                    SqlDataReader dr = reserve.Fn_enc.ExecuteReader("select top 1 isnull(au.first_name + ' ' + au.last_name,'') as gen_by, ip.generated_date from info_projections ip left join app_users au on ip.firm_id=au.firm_id and ip.generated_by=au.user_id where ip.firm_id=@Param1 and ip.project_id=@Param2", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString() });
                                    if (dr.Read())
                                    {
                                        blGen = true;
                                        if (dr["gen_by"].ToString()=="")
                                        {
                                            sStatus = "Report data last generated at " + dr["generated_date"].ToString() + ".";
                                        }
                                        else
                                        {
                                            sStatus = "Report data last generated by " + dr["gen_by"].ToString() + " at " + dr["generated_date"].ToString() + ".";
                                        }
                                    }
                                    else
                                    {
                                        blGen = false;
                                        sStatus = "Report data has not yet been generated. Please click the 'Generate Button' to generate projection data.";
                                    }
                                    dr.Close();

                                    dr = reserve.Fn_enc.ExecuteReader("select isnull(threshold1_used,0) as threshold1_used, threshold1_value, isnull(threshold2_used,0) as threshold2_used, interest, inflation from info_project_info where firm_id=@Param1 and project_id=@Param2", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString() });
                                    if (dr.Read()) {
                                        if (dr["threshold1_used"].ToString()=="True") {
                                            chkThreshold1.Checked = true;
                                            txtThreshold1Val.Value = dr["threshold1_value"].ToString();
                                        }
                                        if (dr["threshold2_used"].ToString()=="True") {
                                            chkThreshold2.Checked = true;
                                        }
                                        txtInterest.Value = dr["interest"].ToString();
                                        txtInflation.Value = dr["inflation"].ToString();
                                    }
                                    dr.Close();
                                %>
                                <button type="button" class="btn btn-primary" onclick="checkExisting('<%=blGen %>')">Generate Projections</button><br />
                                <table>
                                    <tr>
                                        <td>Interest:&nbsp;</td>
                                        <td class="frm-text form-inline" nowrap>%<input type="text" runat="server" id="txtInterest" class="form-control" style="width: 100px" placeholder="0.00" onkeypress="return isNumber(event)" /></td>
                                    </tr>
                                    <tr>
                                        <td>Inflation:&nbsp;</td>
                                        <td class="frm-text form-inline" nowrap>%<input type="text" runat="server" id="txtInflation" class="form-control" style="width: 100px" placeholder="0.00" onkeypress="return isNumber(event)" /></td>
                                    </tr>
                                </table>
                                
                            </td>
                        </tr>
                        <tr>
                            <td class="frm-text text-left" style="padding: 5px; background-color: #eeeeee">
                                <%=sStatus %>
                            </td>
                        </tr>
                        <tr>
                            <td class="frm-text text-left" style="padding: 5px; background-color: #eeeeee">
                                <label id="lblStatus" class="frm-text-red" runat="server"></label>
                            </td>
                        </tr>
                        <% if (blGen)
                            { %>
                        <!--Display Options-->
                        <tr><td class="text-left frm-text-blue-bold" style="background-color: #dddddd; height: 30px; border-top: 1px solid #aaaaaa; padding-left: 5px">Display Options</td></tr>
                        <tr>
                            <td class="frm-text text-left" style="padding: 5px; background-color: #eeeeee; border-top: 1px solid #aaaaaa">
                                <table>
                                    <tr>
                                        <td width="1%" style="text-wrap: none" nowrap><input type="checkbox" id="chkDisp1" name="chkDisp1" runat="server" checked onclick="toggleChkDisp(1)"><label id="lblChkDisp1" for="MainContent_chkDisp1" class="frm-text">&nbsp;Current Funding</label></td>
                                        <td><img src="images/ajax_snake.gif" border=0 align="absmiddle" id="imgChkDisp1" style="display: none"></td>
                                    </tr>
                                    <tr>
                                        <td style="text-wrap: none" nowrap><input type="checkbox" id="chkDisp2" name="chkDisp2" runat="server" checked onclick="toggleChkDisp(2)"><label id="lblChkDisp2" for="MainContent_chkDisp2" class="frm-text">&nbsp;Full Funding</label></td>
                                        <td><img src="images/ajax_snake.gif" border=0 align="absmiddle" id="imgChkDisp2" style="display: none"></td>
                                    </tr>
                                    <tr>
                                        <td style="text-wrap: none" nowrap><input type="checkbox" id="chkDisp3" name="chkDisp3" runat="server" checked onclick="toggleChkDisp(3)"><label id="lblChkDisp3" for="MainContent_chkDisp3" class="frm-text">&nbsp;Baseline Funding</label></td>
                                        <td><img src="images/ajax_snake.gif" border=0 align="absmiddle" id="imgChkDisp3" style="display: none"></td>
                                    </tr>
                                    <tr>
                                        <td width="1%" style="text-wrap: none" nowrap>
                                            <input type="checkbox" id="chkThreshold1" name="chkThreshold1" runat="server"><label id="lblThreshold1" for="MainContent_chkThreshold1" class="frm-text">&nbsp;Threshold Scenario 1</label>:
                                            $<input type="text" id="txtThreshold1Val" class="frm-text" style="border: 1px solid #dddddd; border-radius: 5px; height: 25px" size="10" runat="server" onkeypress="return isNumber(event)" />
                                            <button type="button" class="btn btn-primary" style="height: 25px !important; padding-top: 2px" onclick="sendThreshold1(1,document.getElementById('MainContent_txtThreshold1Val').value)">Save</button>
                                        </td>
                                        <td><img src="images/ajax_snake.gif" border=0 align="absmiddle" id="imgThreshold1" style="display: none"></td>
                                    </tr>
                                    <tr>
                                        <td width="1%" style="text-wrap: none" nowrap><input type="checkbox" id="chkThreshold2" name="chkThreshold2" runat="server"><label id="lblThreshold2" for="MainContent_chkThreshold2" class="frm-text">&nbsp;Threshold Scenario 2</label></td>
                                        <td><img src="images/ajax_snake.gif" border=0 align="absmiddle" id="imgThreshold2" style="display: none"></td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <!--Internal Averages-->
                        <tr><td class="text-left frm-text-blue-bold" style="background-color: #dddddd; height: 30px; border-top: 1px solid #aaaaaa; padding-left: 5px">Interval Averages</td></tr>
                        <tr>
                            <td class="frm-text text-left" style="padding: 5px; background-color: #eeeeee; border-top: 1px solid #aaaaaa">
                                <input 
                                <input type="checkbox" id="chkIntervals" name="chkIntervals" runat="server" onclick="toggleInterval(1); trimIntervalFat()"><label id="lblIntervals" for="MainContent_chkIntervals" class="frm-text">&nbsp;Use Intervals</label>
                                <table id="tblIntervals" style="display: none">
                                    <tr style="padding: 1px"><td class="frm-text">Intervals: <select id="cboIntervals" name="cboIntervals" runat="server" onchange="showIntervals(); trimIntervalFat()"></select></td></tr>
                                    <tr id="trI1" style="padding: 1px"><td class="frm-text">Interval 1: <select id="cboI1" name="cboI1" runat="server" onchange="updateIntervals(1)"></select></td></tr>
                                    <tr id="trI2" style="padding: 1px"><td class="frm-text">Interval 2: <select id="cboI2" name="cboI2" runat="server" onchange="updateIntervals(2)"></select></td></tr>
                                    <tr id="trI3" style="padding: 1px"><td class="frm-text">Interval 3: <select id="cboI3" name="cboI3" runat="server" onchange="updateIntervals(3)"></select></td></tr>
                                    <tr id="trI4" style="padding: 1px"><td class="frm-text">Interval 4: <select id="cboI4" name="cboI4" runat="server" onchange="updateIntervals(4)"></select></td></tr>
                                    <tr id="trI5" style="padding: 1px"><td class="frm-text">Interval 5: <select id="cboI5" name="cboI5" runat="server" onchange="updateIntervals(5)"></select></td></tr>
                                    <tr id="trI6" style="padding: 1px"><td class="frm-text">Interval 6: <select id="cboI6" name="cboI6" runat="server"></select></td></tr>
                                    <tr style="padding: 1px"><td><a href="#" class="btn btn-primary" id="cmdIntervals" data-loading-text="<i class='fa fa-circle-o-notch fa-spin'></i> Saving...">Update Intervals</a></td></tr>
                                    <tr style="padding: 1px"><td><label id="lblIntStatus" class="frm-text-red" runat="server"></label></td></tr>
                                </table>
                            </td>
                        </tr>
                        <% } %>
                    </table>
                </td>
                <td>
                    <table style="margin: 0 auto;">
                        <% if (blGen)
                                
                        { %>
                        <tr style="background-color: #E98300;">
                            <td class="frm-text" style="background-color: #ffffff">&nbsp;</td>
                            <td class="frm-text" style="color: #ffffff;">&nbsp;</td>
                            <td class="frm-text" style="color: #ffffff">&nbsp;</td>
                            <td style="background-color: #ffffff; width: 10px">&nbsp;</td>

                            <td class="frm-text current" style="color: #ffffff; padding: 10px" colspan="2">CURRENT FUNDING ANALYSIS</td>
                            <td class="current" style="background-color: #ffffff; width: 10px">&nbsp;</td>

                            <td class="frm-text full" style="color: #ffffff; padding: 10px" colspan="3">FULL FUNDING ANALYSIS</td>
                            <td class="full" style="background-color: #ffffff; width: 10px">&nbsp;</td>

                            <td class="frm-text baseline" style="color: #ffffff; padding: 10px" colspan="2">BASELINE FUNDING ANALYSIS</td>
                            <td class="baseline" style="background-color: #ffffff; width: 10px">&nbsp;</td>

                            <td class="frm-text threshold1" style="color: #ffffff; padding: 10px" colspan="2">THRESHOLD FUNDING ANALYSIS (SCENARIO 1)</td>
                            <td class="threshold1" style="background-color: #ffffff; width: 10px">&nbsp;</td>

                            <td class="frm-text threshold2" style="color: #ffffff; padding: 10px" colspan="3">THRESHOLD FUNDING ANALYSIS (SCENARIO 2)</td>
                        </tr>
                        <tr style="background-color: #E98300; padding: 5px">
                            <td class="frm-text" style="background-color: #ffffff !important">&nbsp;</td>
                            <td class="frm-text" style="color: #ffffff; padding: 5px; word-wrap:break-word">YEAR<br />BEGINNING</td>
                            <td class="frm-text" style="color: #ffffff; padding: 5px">ANNUAL<br />EXPENDITURE</td>
                            <td style="background-color: #ffffff"></td>

                            <td class="frm-text current" style="color: #ffffff; padding: 5px;">ANNUAL<br />CONTRIBUTION</td>
                            <td class="frm-text current" style="color: #ffffff; padding: 5px;">RESERVE<br />FUND<br />BALANCE</td>
                            <td class="current" style="background-color: #ffffff"></td>

                            <td class="frm-text full" style="color: #ffffff; padding: 5px;">REQUIRED<br />ANNUAL<br />CONTRIBUTION</td>
                            <td class="frm-text full" style="color: #ffffff; padding: 5px;">ADJUSTED<br />ANNUAL<br />REQUIRED<br />CONTRIBUTION</td>
                            <td class="frm-text full" style="color: #ffffff; padding: 5px;">RESERVE<br />FUND<br />BALANCE</td>
                            <td class="full" style="background-color: #ffffff"></td>

                            <td class="frm-text baseline" style="color: #ffffff; padding: 5px;">ANNUAL<br />CONTRIBUTION</td>
                            <td class="frm-text baseline" style="color: #ffffff; padding: 5px;">RESERVE<br />FUND<br />BALANCE</td>
                            <td class="baseline" style="background-color: #ffffff"></td>

                            <td class="frm-text threshold1" style="color: #ffffff; padding: 5px;">ANNUAL<br />CONTRIBUTION</td>
                            <td class="frm-text threshold1" style="color: #ffffff; padding: 5px;">RESERVE<br />FUND<br />BALANCE</td>
                            <td class="threshold1" style="background-color: #ffffff"></td>

                            <td class="frm-text threshold2" style="color: #ffffff; padding: 5px;">%<br />inc.</td>
                            <td class="frm-text threshold2" style="color: #ffffff; padding: 5px;">ANNUAL<br />CONTRIBUTION</td>
                            <td class="frm-text threshold2" style="color: #ffffff; padding: 5px;">RESERVE<br />FUND<br />BALANCE</td>
                        </tr>
                        <tr style="background-color: #eeeeee">
                            <%
                            dr = reserve.Fn_enc.ExecuteReader("select year(report_effective)-1 as yr, begin_balance from info_project_info where firm_id=@Param1 and project_id=@Param2", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString() });
                                dr.Read();
                                %>
                            <!--Years-->
                            <td class="frm-text" style="background-color: #ffffff; padding-top: 3px; padding-bottom: 3px !important">&nbsp;</td>
                            <td class="frm-text" style="text-align: left"><%=dr["yr"].ToString() %></td>
                            <td></td>
                            <td style="background-color: #ffffff"></td>
                            <!--Current Funding-->
                            <td class="current"></td>
                            <td class="frm-text current" style="text-align: left; font-size: 8pt; padding-left: 3px"><%=Convert.ToDouble(dr["begin_balance"]).ToString("C0") %></td>
                            <td class="current" style="background-color: #ffffff"></td>
                            <!--Full Funding-->
                            <td class="full"></td>
                            <td class="full"></td>
                            <td class="frm-text full" style="text-align: left; font-size: 8pt; padding-left: 3px"><%=Convert.ToDouble(dr["begin_balance"]).ToString("C0") %></td>
                            <td class="full" style="background-color: #ffffff"></td>
                            <!--Baseline Funding-->
                            <td class="baseline"></td>
                            <td class="frm-text baseline" style="text-align: left; font-size: 8pt; padding-left: 3px"><%=Convert.ToDouble(dr["begin_balance"]).ToString("C0") %></td>
                            <td class="baseline" style="background-color: #ffffff"></td>
                            <!--threshold1-->
                            <td class="frm-text threshold1"></td>
                            <td class="threshold1" style="text-align: left; font-size: 8pt; padding-left: 3px"><%=Convert.ToDouble(dr["begin_balance"]).ToString("C0") %></td>
                            <td class="threshold1" style="background-color: #ffffff"></td>
                            <!--Adjusted threshold1-->
                            <td class="threshold2">
                                <input type="text" ID="txt1_10" name="txt1_10" value="0.00" class="gridrow_txtbox2 Component" onblur="CheckPctIncAllChanged()"  onkeydown="chkKeybd(this, event,1,10)"  style="width: 50px !important" />
                                <input type="hidden" ID="hdnAnswer1_10" name="hdnAnswer1_10" value="0.00" class="gridrow_txtbox2 Component" />
                            </td>
                            <td class="threshold2"></td>
                            <td class="frm-text threshold2" style="text-align: left; font-size: 8pt; padding-left: 3px"><%=Convert.ToDouble(dr["begin_balance"]).ToString("C0") %></td>
                        </tr>
                        <%
                            dr.Close();
                            var iRow = 1; string fmt1 = "$#,##0";
                            StringBuilder sql = new StringBuilder();
                            dr = reserve.Fn_enc.ExecuteReader("select i.year_id, i.annual_exp, isnull(i.pct_increase,0) as pct_increase, isnull(i.cfa_annual_contrib,0) as cfa_annual_contrib, isnull(i.cfa_reserve_fund_bal,0) as cfa_reserve_fund_bal, isnull(i.ffa_req_annual_contr,0) as ffa_req_annual_contr, isnull(i.ffa_avg_req_annual_contr,0) as ffa_avg_req_annual_contr, isnull(i.ffa_res_fund_bal,0) as ffa_res_fund_bal, isnull(i.bfa_annual_contr,0) as bfa_annual_contr, isnull(i.bfa_res_fund_bal,0) as bfa_res_fund_bal, isnull(i.tfa_annual_contr,0) as tfa_annual_contr, isnull(i.tfa_res_fund_bal,0) as tfa_res_fund_bal, isnull(i.tfa2_annual_contr,0) as tfa2_annual_contr, isnull(i.tfa2_res_fund_bal,0) as tfa2_res_fund_bal from info_projections i where i.firm_id=@Param1 and i.project_id=@Param2", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString() });
                            while (dr.Read())
                            {
                                sql.Clear();
                                sql.Append("year_id=" + dr["year_id"].ToString());
                                %>
                        <tr>
                            <td nowrap bgcolor=#ffffff align=center style="width: 17px" nowrap id="rowHdr<%=iRow %>"></td>
                            <td class="frm-text text-left bb"><%=dr["year_id"].ToString() %></td>
                            <td class="frm-text bb">
                                <input type="text" ID="txt<%=iRow %>_0" name="txt<%=iRow %>_0" value="<%=Convert.ToDouble(dr["annual_exp"]).ToString(fmt1) %>" class="gridrow_txtbox2 Component" onkeydown="chkKeybd(this, event,<%=iRow %>,0)" onfocus="UpdateRowHeader(<%=iRow %>,'Edit')" onblur="UpdateRowHeader(<%=iRow %>,'None'); CheckRowChanges('annual_exp','textbox',<%=iRow %>, 0)" />
                                <input type="hidden" id="hdnAnswer<%=iRow %>_0" name="hdnAnswer<%=iRow %>_0" value="<%=Convert.ToDouble(dr["annual_exp"]).ToString(fmt1) %>" />
                            </td>
                            <td style="background-color: #ffffff; border-bottom: none !important;"></td>
                            <!--Current Funding-->
                            <td class="frm-text bb current">
                                <input type="text" ID="txt<%=iRow %>_1" name="txt<%=iRow %>_1" value="<%=Convert.ToDouble(dr["cfa_annual_contrib"]).ToString(fmt1) %>" class="gridrow_txtbox2 Component" onkeydown="chkKeybd(this, event,<%=iRow %>,1)" onfocus="UpdateRowHeader(<%=iRow %>,'Edit')" onblur="UpdateRowHeader(<%=iRow %>,'None'); CheckRowChanges('cfa_annual_contrib','textbox',<%=iRow %>, 1)" />
                                <input type="hidden" id="hdnAnswer<%=iRow %>_1" name="hdnAnswer<%=iRow %>_1" value="<%=Convert.ToDouble(dr["cfa_annual_contrib"]).ToString(fmt1) %>" />
                            </td>
                            <td class="frm-text bb current">
                                <input type="text" ID="txt<%=iRow %>_2" name="txt<%=iRow %>_2" value="<%=Convert.ToDouble(dr["cfa_reserve_fund_bal"]).ToString(fmt1) %>" class="gridrow_txtbox2 Component" onkeydown="chkKeybd(this, event,<%=iRow %>,2)" onfocus="UpdateRowHeader(<%=iRow %>,'Edit')" onblur="UpdateRowHeader(<%=iRow %>,'None'); CheckRowChanges('cfa_reserve_fund_bal','textbox',<%=iRow %>, 2)" />
                                <input type="hidden" id="hdnAnswer<%=iRow %>_2" name="hdnAnswer<%=iRow %>_2" value="<%=Convert.ToDouble(dr["cfa_reserve_fund_bal"]).ToString(fmt1) %>" />
                            </td>
                            <td class="current" style="background-color: #ffffff; border-bottom: none !important;"></td>
                            <!--Full Funding-->
                            <td class="frm-text bb full">
                                <input type="text" ID="txt<%=iRow %>_3" name="txt<%=iRow %>_3" value="<%=Convert.ToDouble(dr["ffa_req_annual_contr"]).ToString(fmt1) %>" class="gridrow_txtbox2 Component" onkeydown="chkKeybd(this, event,<%=iRow %>,3)" onfocus="UpdateRowHeader(<%=iRow %>,'Edit')" onblur="UpdateRowHeader(<%=iRow %>,'None'); CheckRowChanges('ffa_req_annual_contr','textbox',<%=iRow %>, 3)" />
                                <input type="hidden" id="hdnAnswer<%=iRow %>_3" name="hdnAnswer<%=iRow %>_3" value="<%=Convert.ToDouble(dr["ffa_req_annual_contr"]).ToString(fmt1) %>" />
                            </td>
                            <td class="frm-text bb full">
                                <input type="text" ID="txt<%=iRow %>_4" name="txt<%=iRow %>_4" value="<%=Convert.ToDouble(dr["ffa_avg_req_annual_contr"]).ToString(fmt1) %>" class="gridrow_txtbox2 Component" onkeydown="chkKeybd(this, event,<%=iRow %>,4)" onfocus="UpdateRowHeader(<%=iRow %>,'Edit')" onblur="UpdateRowHeader(<%=iRow %>,'None'); CheckRowChanges('ffa_avg_req_annual_contr','textbox',<%=iRow %>, 4)" />
                                <input type="hidden" id="hdnAnswer<%=iRow %>_4" name="hdnAnswer<%=iRow %>_4" value="<%=Convert.ToDouble(dr["ffa_avg_req_annual_contr"]).ToString(fmt1) %>" />
                            </td>
                            <td class="frm-text bb full">
                                <input type="text" ID="txt<%=iRow %>_5" name="txt<%=iRow %>_5" value="<%=Convert.ToDouble(dr["ffa_res_fund_bal"]).ToString(fmt1) %>" class="gridrow_txtbox2 Component" onkeydown="chkKeybd(this, event,<%=iRow %>,5)" onfocus="UpdateRowHeader(<%=iRow %>,'Edit')" onblur="UpdateRowHeader(<%=iRow %>,'None'); CheckRowChanges('ffa_res_fund_bal','textbox',<%=iRow %>, 5)" />
                                <input type="hidden" id="hdnAnswer<%=iRow %>_5" name="hdnAnswer<%=iRow %>_5" value="<%=Convert.ToDouble(dr["ffa_res_fund_bal"]).ToString(fmt1) %>" />
                            </td>
                            <td class="full" style="background-color: #ffffff; border-bottom: none !important;"></td>
                            <!--Baseline Funding-->
                            <td class="frm-text bb baseline">
                                <input type="text" ID="txt<%=iRow %>_6" name="txt<%=iRow %>_6" value="<%=Convert.ToDouble(dr["bfa_annual_contr"]).ToString(fmt1) %>" class="gridrow_txtbox2 Component" onkeydown="chkKeybd(this, event,<%=iRow %>,6)" onfocus="UpdateRowHeader(<%=iRow %>,'Edit')" onblur="UpdateRowHeader(<%=iRow %>,'None'); CheckRowChanges('bfa_annual_contr','textbox',<%=iRow %>, 6)" />
                                <input type="hidden" id="hdnAnswer<%=iRow %>_6" name="hdnAnswer<%=iRow %>_6" value="<%=Convert.ToDouble(dr["bfa_annual_contr"]).ToString(fmt1) %>" />
                            </td>
                            <td class="frm-text bb baseline">
                                <input type="text" ID="txt<%=iRow %>_7" name="txt<%=iRow %>_7" value="<%=Convert.ToDouble(dr["bfa_res_fund_bal"]).ToString(fmt1) %>" class="gridrow_txtbox2 Component" onkeydown="chkKeybd(this, event,<%=iRow %>,7)" onfocus="UpdateRowHeader(<%=iRow %>,'Edit')" onblur="UpdateRowHeader(<%=iRow %>,'None'); CheckRowChanges('bfa_res_fund_bal','textbox',<%=iRow %>, 7)" />
                                <input type="hidden" id="hdnAnswer<%=iRow %>_7" name="hdnAnswer<%=iRow %>_7" value="<%=Convert.ToDouble(dr["bfa_res_fund_bal"]).ToString(fmt1) %>" />
                                <input type="hidden" id="txtHdnCrit<%=iRow %>" name="txtHdnCrit<%=iRow %>" value="<%=sql %>">
                            </td>
                            <td class="baseline" style="background-color: #ffffff; border-bottom: none !important;"></td>
                            <!--threshold1 Funding-->
                            <td class="frm-text bb threshold1">
                                <input type="text" ID="txt<%=iRow %>_8" name="txt<%=iRow %>_8" value="<%=Convert.ToDouble(dr["tfa_annual_contr"]).ToString(fmt1) %>" class="gridrow_txtbox2 Component" onkeydown="chkKeybd(this, event,<%=iRow %>,8)" onfocus="UpdateRowHeader(<%=iRow %>,'Edit')" onblur="UpdateRowHeader(<%=iRow %>,'None'); CheckRowChanges('tfa_annual_contr','textbox',<%=iRow %>, 8)" />
                                <input type="hidden" id="hdnAnswer<%=iRow %>_8" name="hdnAnswer<%=iRow %>_8" value="<%=Convert.ToDouble(dr["tfa_annual_contr"]).ToString(fmt1) %>" />
                            </td>
                            <td class="frm-text bb threshold1">
                                <input type="text" ID="txt<%=iRow %>_9" name="txt<%=iRow %>_9" value="<%=Convert.ToDouble(dr["tfa_res_fund_bal"]).ToString(fmt1) %>" class="gridrow_txtbox2 Component" onkeydown="chkKeybd(this, event,<%=iRow %>,9)" onfocus="UpdateRowHeader(<%=iRow %>,'Edit')" onblur="UpdateRowHeader(<%=iRow %>,'None'); CheckRowChanges('tfa_res_fund_bal','textbox',<%=iRow %>, 9)" />
                                <input type="hidden" id="hdnAnswer<%=iRow %>_9" name="hdnAnswer<%=iRow %>_9" value="<%=Convert.ToDouble(dr["tfa_res_fund_bal"]).ToString(fmt1) %>" />
                            </td>
                            <td class="threshold1" style="background-color: #ffffff; border-bottom: none !important;"></td>
                            <!--Adjusted threshold1-->
                            <td class="frm-text bb threshold2" style="text-wrap: none">
                                <% if (iRow != 1)
                                    { %>
                                <input type="text" ID="txt<%=iRow %>_10" name="txt<%=iRow %>_10" value="<%=Convert.ToDouble(dr["pct_increase"]).ToString("0.00") %>" class="gridrow_txtbox2 Component pctinc" onkeydown="chkKeybd(this, event,<%=iRow %>,10)" onfocus="UpdateRowHeader(<%=iRow %>,'Edit')" onblur="UpdateRowHeader(<%=iRow %>,'None'); CheckRowChanges('pct_increase','textbox',<%=iRow %>, 10)" style="width: 50px !important" />
                                <input type="hidden" id="hdnAnswer<%=iRow %>_10" name="hdnAnswer<%=iRow %>_10" value="<%=Convert.ToDouble(dr["pct_increase"]).ToString("0.00") %>" />
                                <% } %>
                            </td>
                            <td class="frm-text bb threshold2">
                                <input type="text" ID="txt<%=iRow %>_11" name="txt<%=iRow %>_11" value="<%=Convert.ToDouble(dr["tfa2_annual_contr"]).ToString(fmt1) %>" class="gridrow_txtbox2 Component" onkeydown="chkKeybd(this, event,<%=iRow %>,11)" onfocus="UpdateRowHeader(<%=iRow %>,'Edit')" onblur="UpdateRowHeader(<%=iRow %>,'None'); CheckRowChanges('tfa2_annual_contr','textbox',<%=iRow %>, 11)" />
                                <input type="hidden" id="hdnAnswer<%=iRow %>_11" name="hdnAnswer<%=iRow %>_11" value="<%=Convert.ToDouble(dr["tfa2_annual_contr"]).ToString(fmt1) %>" />
                            </td>
                            <td class="frm-text bb threshold2">
                                <input type="text" ID="txt<%=iRow %>_12" name="txt<%=iRow %>_12" value="<%=Convert.ToDouble(dr["tfa2_res_fund_bal"]).ToString(fmt1) %>" class="gridrow_txtbox2 Component" onkeydown="chkKeybd(this, event,<%=iRow %>,12)" onfocus="UpdateRowHeader(<%=iRow %>,'Edit')" onblur="UpdateRowHeader(<%=iRow %>,'None'); CheckRowChanges('tfa2_res_fund_bal','textbox',<%=iRow %>, 12)" />
                                <input type="hidden" id="hdnAnswer<%=iRow %>_12" name="hdnAnswer<%=iRow %>_12" value="<%=Convert.ToDouble(dr["tfa2_res_fund_bal"]).ToString(fmt1) %>" />
                            </td>
                        </tr>
                        <% 
                            iRow++;
                        }
                            dr.Close();
                        %>
                        <tr>
                            <td></td>
                            <td class="frm-text-bold text-left">TOTAL</td>
                            <td colspan="2"><div id="divTtl0" class="frm-text-bold text-left"></td>
                            <!--Current Funding-->
                            <td class="current"><div id="divTtl1" class="frm-text-bold text-left"></div></td>
                            <td class="current" colspan="2"></td>
                            <!--Full Funding-->
                            <td class="full"><div id="divTtl2" class="frm-text-bold text-left"></div></td>
                            <td class="full"><div id="divTtl3" class="frm-text-bold text-left"></div></td>
                            <td class="full" colspan="2"></td>
                            <!--Baseline Funding-->
                            <td class="baseline"><div id="divTtl4" class="frm-text-bold text-left"></div></td>
                            <td class="baseline"></td>
                            <td class="baseline"></td>
                            <!--threshold1 Funding-->
                            <td class="threshold1"><div id="divTtl5" class="frm-text-bold text-left"></div></td>
                            <td class="threshold1"></td>
                            <td class="threshold1"></td>
                            <td class="threshold2"></td>
                            <td class="threshold2"><div id="divTtl6" class="frm-text-bold text-left"></div></td>
                            <td class="threshold2"></td>
                        </tr>
                        <script>calcTotals();</script>
                        <% } %>
                    </table>
                </td>
            </tr>
        </table>
    </div>
    <script>
        toggleInterval(0);
        if (document.getElementById('MainContent_chkThreshold2').checked == true) trimIntervalFat();

        $("#MainContent_chkThreshold1").click(function () {
            if (!$(this).is(":checked")) {
                document.forms[0].disabled = false;
                sendThreshold1(0,'');
                $(".threshold1").hide();
            }

            else {
                if (document.getElementById('MainContent_txtThreshold1Val').value == '') {
                    document.getElementById('MainContent_txtThreshold1Val').value = "0";
                }
                document.forms[0].disabled = false;
                sendThreshold1(1,document.getElementById('MainContent_txtThreshold1Val').value);
                $(".threshold1").show();
            }
        });

        $("#MainContent_chkThreshold2").click(function () {
            if ($(this).is(":checked")) {
                document.forms[0].disabled = false;
                sendThreshold2('true');
                $(".threshold2").show();
            }
            else {
                document.forms[0].disabled = false;
                sendThreshold2('false');
                $(".threshold2").hide();
            }
        });

        $("#MainContent_chkDisp1").click(function () {
            if ($(this).prop("checked") == true) {
                $(".current").show();
            }
            else {
                $(".current").hide();
            }
        });

        $("#MainContent_chkDisp2").click(function () {
            if ($(this).prop("checked") == true) {
                $(".full").show();
            }
            else {
                $(".full").hide();
            }
        });

        $("#MainContent_chkDisp3").click(function () {
            if ($(this).prop("checked") == true) {
                $(".baseline").show();
            }
            else {
                $(".baseline").hide();
            }
        });

        $(document).ready(function () {
            if ($("#MainContent_chkThreshold1").prop("checked") == false) { $(".threshold1").hide(); } else { $(".threshold1").show() }
            if ($("#MainContent_chkThreshold2").prop("checked") == false) { $(".threshold2").hide(); }
            if ($("#MainContent_chkDisp1").prop("checked") == false) { $(".current").hide(); }
            if ($("#MainContent_chkDisp2").prop("checked") == false) { $(".full").hide(); }
            if ($("#MainContent_chkDisp3").prop("checked") == false) { $(".baseline").hide(); }
        });

        $('#cmdIntervals').on('click', function () {
            var $this = $(this); $this.button('loading');
            document.getElementById('MainContent_txtHdnType').value = 'Intervals';
            document.forms[0].submit();
            $('#frmProject').submit();
        });
    </script>
    <% } %>
    <input type="hidden" id="txtHdnType" name="txtHdnType" runat="server" />
</form>

</asp:content>

<%@ Page Language="C#" MasterPageFile="~/Main.Master" AutoEventWireup="true" CodeBehind="rvw_graphs.aspx.cs" Inherits="reserve.rvw_graphs" %>

<%@ Register Assembly="System.Web.DataVisualization, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" Namespace="System.Web.UI.DataVisualization.Charting" TagPrefix="asp" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

<script src="https://ajax.aspnetcdn.com/ajax/jquery/jquery-1.8.0.js"></script>
<script src="https://ajax.aspnetcdn.com/ajax/jquery.ui/1.8.22/jquery-ui.js"></script>
<script src="assets/js/jquery.mask.min.js"></script>
<link href="https://ajax.aspnetcdn.com/ajax/jquery.ui/1.8.10/themes/redmond/jquery-ui.css" rel="stylesheet" />
<link href="css/style.css" rel="stylesheet" />

<style>
    body:
    {
        line-height: 20px !important;
    }
    iframe { display:block; }
    .mask {
      display: block;
      width: 100%;
      height: 100%;
      position: relative; /*required for z-index*/
      z-index: 1000; /*puts on top of everything*/
      opacity: .4;
    }

</style>
<script src="Scripts/rvw_graph_thresh.js"></script>
<form id="frmProject" method="post" runat="server" class="needs-validation">
    <div class="container_fluid" style="width: 100%; max-width: 100%">
        <div class="row float-right" style="margin-top: -4px; margin-left: -2px;">
            <div class="page-top-tab-project col-lg-3 float-right">
                <p class="panel-title-fd">Review<br /><label id="lblProject" runat="server" class="frm-text"></label></p>
            </div>
            <div id="divPnRevisions" runat="server" class="page-top-tab-revision col-lg-2 float-right">
                <p class="panel-title-fd">
                    Revision:<br />
                    <label id="lblRevision" runat="server" class="frm-text"></label>
                </p>
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
            <li class="frm-text">
                <a href="rvw_proj.aspx">Projection</a>
            </li>
            <li class="frm-text">
                <a href="rvw_exp.aspx">Expenditures</a>
            </li>
            <li class="active frm-text">
                <a href="rvw_graphs.aspx">Graphs</a>
            </li>
        </ul>
    </div>
    <%
        double beginBal=0; double inflation=0; double interest=0;
        int firstYear = 0;
        Boolean blThreshold1 = false; Boolean blThreshold2 = false; Boolean blHideCF = false; Boolean blHideFF = false; Boolean blHideBF = false;
        string tfa1_bal=""; string tfa2_bal = "";

        var conn = reserve.Fn_enc.getconn();
        conn.Open();
        SqlDataAdapter adapter = new SqlDataAdapter("select * from info_projections where firm_id=" + Session["firmid"].ToString() + " and project_id='" + Session["projectid"].ToString() + "' and revision_id=" + Session["revisionid"].ToString(), conn);
        DataSet ds = new DataSet();
        adapter.Fill(ds,"Projection");
        conn.Close();

        SqlDataReader dr = reserve.Fn_enc.ExecuteReader("select begin_balance, isnull(threshold1_used,0) as threshold1_used, isnull(threshold2_used,0) as threshold2_used, isnull(current_funding_hidden,convert(bit,0)) as current_funding_hidden, isnull(full_funding_hidden,convert(bit,0)) as full_funding_hidden, isnull(baseline_funding_hidden,convert(bit,0)) as baseline_funding_hidden, year(report_effective) as yr, isnull(interest,0) as interest, isnull(inflation,0) as inflation from info_project_info ipi where firm_id=@Param1 and project_id=@Param2 and revision_id=@Param3", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString(), Session["revisionid"].ToString() });
        if (dr.Read()) {
            firstYear = Convert.ToInt32(dr["yr"].ToString());
            beginBal = Convert.ToDouble(dr["begin_balance"].ToString());
            blThreshold1 = Convert.ToBoolean(dr["threshold1_used"].ToString());
            blThreshold2 = Convert.ToBoolean(dr["threshold2_used"].ToString());
            blHideCF = Convert.ToBoolean(dr["current_funding_hidden"].ToString());
            blHideFF = Convert.ToBoolean(dr["full_funding_hidden"].ToString());
            blHideBF = Convert.ToBoolean(dr["baseline_funding_hidden"].ToString());
            interest = Convert.ToDouble(dr["interest"].ToString());
            inflation = Convert.ToDouble(dr["inflation"].ToString());
        }
        dr.Close();

        DataRow dataRow = ds.Tables[0].NewRow();
        dataRow["year_id"] = firstYear-1;
        dataRow["cfa_reserve_fund_bal"] = beginBal;
        dataRow["ffa_res_fund_bal"] = beginBal;
        dataRow["bfa_res_fund_bal"] = beginBal;
        dataRow["tfa_res_fund_bal"] = beginBal;
        dataRow["tfa_annual_contr"] = beginBal;
        dataRow["tfa2_res_fund_bal"] = beginBal;
        dataRow["tfa2_annual_contr"] = beginBal;

        ds.Tables[0].Rows.InsertAt(dataRow, 0);

        string years = "'" + string.Join("', '", ds.Tables[0].Rows.OfType<DataRow>().Select(r => r["year_id"].ToString())) + "'";
        string cfa_bal = string.Join(", ", ds.Tables[0].Rows.OfType<DataRow>().Select(r => Convert.ToInt32(r["cfa_reserve_fund_bal"]).ToString()));
        string ffa_bal = string.Join(", ", ds.Tables[0].Rows.OfType<DataRow>().Select(r => Convert.ToInt32(r["ffa_res_fund_bal"]).ToString()));
        string bfa_bal = string.Join(", ", ds.Tables[0].Rows.OfType<DataRow>().Select(r => Convert.ToInt32(r["bfa_res_fund_bal"]).ToString()));
        if (blThreshold1) tfa1_bal = string.Join(", ", ds.Tables[0].Rows.OfType<DataRow>().Select(r => Convert.ToInt32(r["tfa_res_fund_bal"]).ToString()));
        if (blThreshold2) tfa2_bal = string.Join(", ", ds.Tables[0].Rows.OfType<DataRow>().Select(r => Convert.ToInt32(r["tfa2_res_fund_bal"]).ToString()));

        %>
    <canvas id="myChart" width="600px" height="150px"></canvas>
    <script src="https://cdn.jsdelivr.net/npm/chart.js@2.8.0"></script>
    <script>
    Chart.defaults.global.legend.labels.usePointStyle = true;
    var ctx = document.getElementById('myChart').getContext('2d');
    var chart = new Chart(ctx, {
        // The type of chart we want to create
        type: 'line',

        // The data for our dataset
        data: {
            labels: [<%=years%>],
            datasets: [
                <% if (blThreshold1) { %>
                {
                    label: 'Reserve Fund Balance - Projected Threshold Scenario 1',
                    fill: false,
                    pointStyle: 'rectRot',
                    pointRadius: 6,
                    pointHoverRadius: 6,
                    borderColor: 'rgb(241, 133, 43)',
                    borderWidth: 4,
                    data: [<%=tfa1_bal%>]
                },
                <% }
                if (blThreshold2) { %>
                {
                    label: 'Reserve Fund Balance - Projected Threshold Scenario 2',
                    fill: false,
                    pointStyle: 'rectRot',
                    pointRadius: 6,
                    pointHoverRadius: 6,
                    borderColor: 'rgb(241, 133, 43)',
                    borderWidth: 4,
                    data: [<%=tfa2_bal%>]
                },
                <% }
                if (!blHideCF)
                {
                %>
                {
                    label: 'Reserve Fund Balance - Current Funding',
                    fill: false,
                    pointStyle: 'circle',
                    pointRadius: 6,
                    pointHoverRadius: 6,
                    borderColor: 'rgb(255, 99, 132)',
                    data: [<%=cfa_bal%>]
                },
                <% }
                if (!blHideFF) { %>
                {
                    label: 'Reserve Fund Balance - Full Funding',
                    fill: false,
                    pointStyle: 'triangle',
                    pointRadius: 6,
                    pointHoverRadius: 6,
                    borderColor: 'rgb(99, 102, 255)',
                    data: [<%=ffa_bal%>]
                },
                <% }
                if (!blHideBF) {
                %>
                {
                    label: 'Reserve Fund Balance - Baseline Funding',
                    pointStyle: 'rect',
                    pointRadius: 6,
                    pointHoverRadius: 6,
                    fill: false,
                    borderColor: 'rgb(31, 237, 45)',
                    data: [<%=bfa_bal%>]
                },
                <% } %>
                {
                    data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                    label: 'x',
                    borderColor: '#999999',
                    borderSolid: [10, 10],
                    pointBorderWidth: 0,
                    pointHoverRadius: 0,
                    pointHoverBackgroundColor: "rgba(75,192,192,1)",
                    pointHoverBorderColor: "rgba(220,220,220,1)",
                    pointHoverBorderWidth: 0,
                    pointRadius: 0,
                    pointHitRadius: 0,
                }
            ]
        },

        // Configuration options go here
        options: {
            legend: {
                labels: {
                    filter: function (item, chart) {
                        // Logic to remove a particular legend item goes here
                        return !item.text.includes('x');
                    }
                }
            },
            elements: {
                line: {
                    tension: 0
                }
            },
            tooltips: {
               callbacks: {
                   label: function(tooltipItem, data) {
                       return '$' + tooltipItem.yLabel.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ","); }, },
            },
            scales: {
                xAxes: [{
                    scaleLabel: {
                        display: true,
                        labelString: 'Year'
                    }
                }],
                yAxes: [{
                  ticks: {
                    beginAtZero: true,
                    precision: 0,
                        callback: function (value, index, values) {
                            var v = value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
                            return '$' + v;
                      //var v = value.toFixed(0);
                      //return v.toLocaleString("en-US",{style:"currency", currency:"USD"});
                    }
                  },
                  scaleLabel: {
                     display: true,
                     labelString: 'Reserve Fund Balance'
                  }
                }]
              }
            }
        });

        function checkII(sType) {
            if (sType == "Interest") {
                if (isNaN(document.getElementById('MainContent_txtInt').value)) {
                    alert("Please enter a numeric interest value.");
                    return false;
                }
                document.getElementById('MainContent_lblInt').innerHTML = "Updating, please wait...";
                document.getElementById('MainContent_lblInfl').innerHTML = "";
                document.getElementById('cmdInt').disabled = true;
            }
            if (sType == "Inflation") {
                if (isNaN(document.getElementById('MainContent_txtInfl').value)) {
                    alert("Please enter a numeric inflation value.");
                    return false;
                }
                document.getElementById('MainContent_lblInfl').innerHTML = "Updating, please wait...";
                document.getElementById('MainContent_lblInt').innerHTML = "";
                document.getElementById('cmdInfl').disabled = true;
            }
            document.getElementById('MainContent_txtHdnType').value = sType;
            document.forms[0].submit();
        }
    </script>
    <% if (blThreshold2)
        { %>
    <table style="width: 100%" id="tblThresh">
        <tr>
            <td style="width: 80px"></td>
            <% for (var i = 0; i < ds.Tables[0].Rows.Count; i++)
                           { %>
            <td style="background-color: #eeeeee" class="grid_tbl_hdr frm-text" style="width: 45"><%=ds.Tables[0].Rows[i]["year_id"].ToString() %></td>
            <% } %>
        </tr>
        <tr>
            <td class="frm-text" style="text-align: right">Contribution:&nbsp;</td>
            <% StringBuilder sbColor = new StringBuilder();
                           for (var i = 0; i < ds.Tables[0].Rows.Count; i++)
                           {
                               sbColor.Clear();
                               if (i == 0) sbColor.Append("#eeeeee");
                               else sbColor.Append("#ffffff");

                               var iYear = ds.Tables[0].Rows[i]["year_id"].ToString();
                    %>
            <td class="frm-text" style="background-color: <%=sbColor.ToString()%>">
                <% if (i == 0)
                    { %>
                <div style="font-size: 10px"><%=Convert.ToDouble(ds.Tables[0].Rows[i]["tfa2_annual_contr"]).ToString("C0") %></div>
                <% }
                else
                { %>
                <input type="text" class="gridrow_txtbox2 small" style="background-color: <%=sbColor.ToString()%>; font-size: 10px; text-align: center" id="txt1_<%=iYear %>" name="txt1_<%=iYear %>" value="<% if (ds.Tables[0].Rows[i]["tfa2_annual_contr"].ToString() != "") Response.Write(Convert.ToDouble(ds.Tables[0].Rows[i]["tfa2_annual_contr"]).ToString("C0")); %>" onkeydown="chkKeybd(this, event, 1, <%=iYear %>)" onblur="CheckRowChanges('tfa2_annual_contr','textbox',1,<%=iYear %>)" />
                <input type="hidden" class="gridrow_txtbox2 Component small" id="hdn1_<%=iYear %>" name="hdn1_<%=iYear %>" value="<%if (ds.Tables[0].Rows[i]["tfa2_annual_contr"].ToString() != "") Response.Write(Convert.ToDouble(ds.Tables[0].Rows[i]["tfa2_annual_contr"]).ToString("C0")); %>" />
                <% } %>
            </td>
            <% } %>
        </tr>
        <tr>
            <td class="frm-text" style="text-align: right">% Increase:&nbsp;</td>
            <% sbColor = new StringBuilder();
                           for (var i = 0; i < ds.Tables[0].Rows.Count; i++)
                           {
                               sbColor.Clear();
                               if (i == 0) sbColor.Append("#eeeeee");
                               else sbColor.Append("#ffffff");

                               var iYear = ds.Tables[0].Rows[i]["year_id"].ToString();
                    %>
            <td class="frm-text" style="background-color: <%=sbColor.ToString()%>">
                <% if (i == 0)
                    { %>
                <div style="font-size: 10px"><% if (!ds.Tables[0].Rows[i].IsNull("pct_increase")) Response.Write(Convert.ToDouble(ds.Tables[0].Rows[i]["pct_increase"]).ToString("C0")); %></div>
                <% }
                else
                { %>
                <input type="text" class="gridrow_txtbox2 small" style="background-color: <%=sbColor.ToString()%>; font-size: 10px; text-align: center" id="txt2_<%=iYear %>" name="txt2_<%=iYear %>" value="<% if (ds.Tables[0].Rows[i]["pct_increase"].ToString() != "") Response.Write(String.Format("{0:0.00}", Convert.ToDouble(ds.Tables[0].Rows[i]["pct_increase"].ToString()))); else Response.Write("0.00"); %>" onkeydown="chkKeybd(this, event, 2, <%=iYear %>)" onblur="CheckRowChanges('pct_increase','textbox',2,<%=iYear %>)" />
                <input type="hidden" class="gridrow_txtbox2 Component small" id="hdn2_<%=iYear %>" name="hdn2_<%=iYear %>" value="<% if (ds.Tables[0].Rows[i]["pct_increase"].ToString() != "") Response.Write(String.Format("{0:0.00}", Convert.ToDouble(ds.Tables[0].Rows[i]["pct_increase"].ToString()))); else Response.Write("0.00"); %>" />
                <% } %>
            </td>
            <% } %>
        </tr>
        <tr>
            <td class="frm-text" style="text-align: right">Interest:&nbsp;</td>
            <td colspan="2" style="text-align: left"><input type="text" id="txtInt" name="txtInt" class="gridrow_txtbox2" runat="server" /></td>
            <td colspan="2"><input type="button" id="cmdInt" class="gridbtn" value="Update Interest" onclick="checkII('Interest')" /></td>
            <td colspan="5" style="text-align: left"><label id="lblInt" class="gridcol_red" runat="server"></label></td>
            <td colspan="<%=ds.Tables[0].Rows.Count-8 %>"></td>
        </tr>
        <tr>
            <td class="frm-text" style="text-align: right">Inflation:&nbsp;</td>
            <td colspan="2" style="text-align: left"><input type="text" id="txtInfl" name="txtInfl" class="gridrow_txtbox2" runat="server" /></td>
            <td colspan="2"><input type="button" id="cmdInfl" class="gridbtn" value="Update Inflation" onclick="checkII('Inflation')" /></td>
            <td colspan="5" style="text-align: left"><label id="lblInfl" class="gridcol_red" runat="server"></label></td>
            <td colspan="<%=ds.Tables[0].Rows.Count-8 %>"></td>
        </tr>
    </table>
    <input type="hidden" id="txtHdnType" name="txtHdnType" runat="server" />
    <% 
            }
            else
            {
                %>
    <div class="frm-text">(Threshold is not yet configured. To modify threshold balances, please configure this on the <a href="rvw_proj.aspx" style="color: blue">Projections</a> tab.)</div>
    <%
            }
        }
        %>
</form>

</asp:content>

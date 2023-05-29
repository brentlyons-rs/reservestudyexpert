<%@ Page Language="C#" MasterPageFile="~/Main.Master" AutoEventWireup="true" CodeBehind="rvw_summ.aspx.cs" Inherits="reserve.rvw_summ" %>
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
    table, tr, td { padding: 5px }
    iframe { display:block; }
</style>

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
    else { %>
    <div style="margin-top: 5px">
        <ul class="nav nav-tabs">
            <li class="active frm-text">
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
            <li class="frm-text">
                <a href="rvw_graphs.aspx">Graphs</a>
            </li>
        </ul>
        <h4>
            <%=lblProject.InnerHtml %><br />
            Component Schedule<br />
            Summary of Replacement Reserve Needs<br /><br />
        </h4>
        <h5>
            Effective Date:
            <%
                var iRow = 0;
                string sTotRows="";

                SqlDataReader dr = reserve.Fn_enc.ExecuteReader("select report_effective from info_project_info where firm_id=@Param1 and project_id=@Param2 and revision_id=@Param3", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString(), Session["revisionid"].ToString() });
                if (dr.Read()) Response.Write(string.Format("{0:MMMM d, yyyy}", dr["report_effective"]));
                dr.Close();

                dr = reserve.Fn_enc.ExecuteReader("select count(*) as ttl from info_component_categories where firm_id=@Param1 and project_id=@Param2 and revision_id=@Param3", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString(), Session["revisionid"].ToString() });
                if (dr.Read()) sTotRows = dr["ttl"].ToString();
                dr.Close();
                %>
            
        </h5>
        <% var iBalloonPage = "30"; %>
        <script>var iBalloonPage = <%= iBalloonPage %>;</script>
        <!-- #Include virtual="info_balloons.aspx" -->
        <table border="0" style="margin: 0 auto;">
            <tr style="background-color: #E98300">
                <td class="frm-text" style="color: #ffffff; width: 28%">CATEGORY</td>
                <td class="frm-text" style="color: #ffffff; width: 12%"><%= reserve.GenerateInfoBalloons.GetIcon(1,"Present Dollars","#ffffff") %>RESERVE REQUIREMENT PRESENT DOLLARS</td>
                <td class="frm-text" style="color: #ffffff; width: 12%"><%= reserve.GenerateInfoBalloons.GetIcon(2,"Begin Balance","#ffffff") %>BEGINNING BALANCE</td>
                <td class="frm-text" style="color: #ffffff; width: 12%"><%= reserve.GenerateInfoBalloons.GetIcon(3,"Balance Req Funding","#ffffff") %>BALANCE REQUIRING FUNDING</td>
                <td class="frm-text" style="color: #ffffff; width: 12%"><%= reserve.GenerateInfoBalloons.GetIcon(4,"Annual Reserve Funding","#ffffff") %>ANNUAL RESERVE FUNDING REQUIRED</td>
                <td class="frm-text" style="color: #ffffff; width: 12%"><%= reserve.GenerateInfoBalloons.GetIcon(5,"Full Funding","#ffffff") %>FULL FUNDING BALANCE</td>
                <td class="frm-text" style="color: #ffffff; width: 12%"><%= reserve.GenerateInfoBalloons.GetIcon(6,"Pct Funded","#ffffff") %>PERCENT FUNDED</td>
            </tr>
            <%
                double[] arrTotals = new double[] { 0,0,0,0,0 } ;
                dr = reserve.Fn_enc.ExecuteReader("sp_app_rvw_comp1 @Param1, @Param2, @Param3, 0", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString(), Session["revisionid"].ToString() });
                while (dr.Read()) {
                        %>
            <tr style="border-bottom: 1px solid #000000">
                <td class="frm-text text-left"><%=dr["category_desc"].ToString() %> Totals</td>
                <td class="frm-text"><%= Convert.ToDouble(dr["res_req_pres_dols"].ToString()).ToString("C0") %></td>
                <td class="frm-text"><%= Convert.ToDouble(dr["begin_bal"].ToString()).ToString("C0") %></td>
                <td class="frm-text"><%= Convert.ToDouble(Convert.ToDouble(dr["res_req_pres_dols"].ToString()) - Convert.ToDouble(dr["begin_bal"].ToString())).ToString("C0") %></td>
                <td class="frm-text"><%= Convert.ToDouble(dr["annual_res_fund_req"].ToString()).ToString("C0") %></td>
                <td class="frm-text"><%= Convert.ToDouble(dr["full_fund_bal"].ToString()).ToString("C0") %></td>
                <% if (iRow == 0){ %> <td rowspan="<%=sTotRows %>" class="frm-text">The Percent Funded and Funding Goal are based on fully funding each component within the schedule.  Please review the report for various funding strategies.</td>  <% } %>
            </tr>
            <%
                    arrTotals[0] += Convert.ToDouble(dr["res_req_pres_dols"].ToString());
                    arrTotals[1] += Convert.ToDouble(dr["begin_bal"].ToString());
                    arrTotals[2] += (Convert.ToDouble(dr["res_req_pres_dols"].ToString()) - Convert.ToDouble(dr["begin_bal"].ToString()));
                    arrTotals[3] += Convert.ToDouble(dr["annual_res_fund_req"].ToString());
                    arrTotals[4] += Convert.ToDouble(dr["full_fund_bal"].ToString());

                    iRow++;
                }
                dr.Close();
                %>
            <tr><td colspan="7"></td></tr>
            <tr><td colspan="7"></td></tr>
            <tr><td colspan="7"></td></tr>
            <tr style="border-bottom: 1px solid #000000">
                <td class="frm-text-bold text-left">GRAND TOTALS</td>
                <td class="frm-text-bold"><%= arrTotals[0].ToString("C0") %></td>
                <td class="frm-text-bold"><%= arrTotals[1].ToString("C0") %></td>
                <td class="frm-text-bold"><%= arrTotals[2].ToString("C0") %></td>
                <td class="frm-text-bold"><%= arrTotals[3].ToString("C0") %></td>
                <td class="frm-text-bold"><%= arrTotals[4].ToString("C0") %></td>
                <td class="frm-text-bold"><% if (arrTotals[4] != 0) { Response.Write((arrTotals[1] / arrTotals[4]).ToString("P2")); } 
                                             else if (arrTotals[4] == 0 && arrTotals[1] == 0) { Response.Write("100%"); }
                                              else { Response.Write("% FUNDED"); } %></td>
            </tr>
        </table>
    </div>
    <% } %>
</form>

</asp:content>

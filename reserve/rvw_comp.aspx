<%@ Page Language="C#" MasterPageFile="~/Main.Master" AutoEventWireup="true" CodeBehind="rvw_comp.aspx.cs" Inherits="reserve.rvw_comp" %>
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
        margin-left: 5px !important;
        line-height: 20px !important;
    }
        table, tr, td { padding: 3px }

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
            <li class="frm-text">
                <a href="rvw_summ.aspx">Summary</a>
            </li>
            <li class="active frm-text">
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
    </div>
    <% } %>
    <div style="padding: 10px">
    <%
        SqlDataReader dr;
        SqlDataReader drcats = reserve.Fn_enc.ExecuteReader("select icc.category_id, icc.category_desc from info_component_categories icc where icc.firm_id=@Param1 and icc.project_id=@Param2 and icc.revision_id=@Param3", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString(), Session["revisionid"].ToString() });
        while (drcats.Read())
        {
            %>
        <table style="border: 1px solid #000000; margin-top: 10px; margin-bottom: 20px; width: 100%">
            <tr>
                <td style="padding: 5px">
                    <table border="0" style="margin: 0 auto;">
                        <tr>
                            <td colspan="10" class="rvwtbl_cat"><b><%=drcats["category_desc"].ToString() %></b></td>
                        </tr>
                        <tr style="background-color: #f7a539; border-bottom: 3px solid #E98300">
                            <td class="rvwtbl_hdr" style="width:30%">COMPONENT</td>
                            <td class="rvwtbl_hdr" style="width:5%">QUANTITY</td>
                            <td class="rvwtbl_hdr" style="width:5%">UNIT COST</td>
                            <td class="rvwtbl_hdr" style="width:10%">RESERVE REQUIREMENT PRESENT DOLLARS</td>
                            <td class="rvwtbl_hdr" style="width:10%">BEGINNING BALANCE</td>
                            <td class="rvwtbl_hdr" style="width:5%">ESTIMATED USEFUL LIFE</td>
                            <td class="rvwtbl_hdr" style="width:10%">ESTIMATED REMAINING USEFUL LIFE</td>
                            <td class="rvwtbl_hdr" style="width:10%">ANNUAL RESERVE FUNDING REQUIRED</td>
                            <td class="rvwtbl_hdr" style="width:10%">FULL FUNDING BALANCE</td>
                            <td class="rvwtbl_hdr" style="width:5%">NOTES</td>
                        </tr>
                    <%
                        int iRow = 0;
                        double[] arrTotals = new double[] { 0,0,0,0 } ;
                        dr = reserve.Fn_enc.ExecuteReader("sp_app_rvw_comp1 @Param1, @Param2, @Param3, 1, @Param4", new string[] { Session["firmid"].ToString(),Session["projectid"].ToString(),Session["revisionid"].ToString(), drcats["category_id"].ToString() });
                        while (dr.Read())
                        {%>
                        <tr style="border-bottom: 1px solid #dddddd">
                            <td class="rvwtbl text-left" style=" padding: 5px 5px 5px 5px"><%=dr["component_desc"].ToString() %> Totals</td>
                            <td class="rvwtbl"><%=dr["comp_quantity"].ToString() + " " + dr["comp_unit"].ToString() %></td>
                            <td class="rvwtbl"><%= Convert.ToDouble(dr["unit_cost"].ToString()).ToString("C0") %></td>
                            <td class="rvwtbl"><%= Convert.ToDouble(dr["res_req_pres_dols"].ToString()).ToString("C0") %></td>
                            <td class="rvwtbl"><%= Convert.ToDouble(dr["begin_bal_calcd"].ToString()).ToString("C0") %></td>

                            <td class="rvwtbl"><%= dr["est_useful_life"].ToString() %></td>
                            <td class="rvwtbl"><%= dr["est_rem_useful_life"].ToString() %></td>

                            <td class="rvwtbl"><%= Convert.ToDouble(dr["annual_res_fund_req"].ToString()).ToString("C0") %></td>
                            <td class="rvwtbl"><%= Convert.ToDouble(dr["full_fund_bal"].ToString()).ToString("C0") %></td>
                            <td class="rvwtbl"><%= dr["comp_note"].ToString() %></td>
                        </tr>
                        <%
                                arrTotals[0] += Convert.ToDouble(dr["res_req_pres_dols"].ToString());
                                arrTotals[1] += Convert.ToDouble(dr["begin_bal_calcd"].ToString());
                                arrTotals[2] += Convert.ToDouble(dr["annual_res_fund_req"].ToString());
                                arrTotals[3] += Convert.ToDouble(dr["full_fund_bal"].ToString());

                                iRow++;
                            }
                            dr.Close();
                            %>
                        <tr><td colspan="10">&nbsp;</td></tr>
                        <tr style="border-bottom: 1px solid #000000; margin-top: 10px">
                            <td class="rvwtbl_ttl text-left" colspan="3">TOTALS</td>
                            <td class="rvwtbl_ttl"><%= arrTotals[0].ToString("C0") %></td>
                            <td class="rvwtbl_ttl"><%= arrTotals[1].ToString("C0") %></td>
                            <td colspan="2"></td>
                            <td class="rvwtbl_ttl"><%= arrTotals[2].ToString("C0") %></td>
                            <td class="rvwtbl_ttl"><%= arrTotals[3].ToString("C0") %></td>
                            <td></td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
    <%
        }
        drcats.Close();
        %>
    </div>
</form>

</asp:content>

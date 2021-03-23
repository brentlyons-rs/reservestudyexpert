<%@ Page Language="C#" MasterPageFile="~/Main.Master" AutoEventWireup="true" CodeBehind="rvw_future.aspx.cs" Inherits="reserve.rvw_future" %>

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
</style>

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
    else { %>
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
            <li class="frm-text">
                <a href="rvw_graphs.aspx">Graphs</a>
            </li>
            <li class="active frm-text">
                <a href="rvw_future.aspx">Future Years</a>
            </li>
        </ul>
    </div>
    <% } %>
</form>

</asp:content>

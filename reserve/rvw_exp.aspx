<%@ Page Language="C#" MasterPageFile="~/Main.Master" AutoEventWireup="true" CodeBehind="rvw_exp.aspx.cs" Inherits="reserve.rvw_exp" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Text" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

<script src="https://ajax.aspnetcdn.com/ajax/jquery/jquery-1.8.0.js"></script>
<script src="https://ajax.aspnetcdn.com/ajax/jquery.ui/1.8.22/jquery-ui.js"></script>
<script src="assets/js/jquery.mask.min.js"></script>
<link href="https://ajax.aspnetcdn.com/ajax/jquery.ui/1.8.10/themes/redmond/jquery-ui.css" rel="stylesheet" />
<link href="css/style.css" rel="stylesheet" />

<style>
    body { line-height: 20px !important; }
    iframe { display:block; }

    .exp_year_hdr {
        font-family: 'Open Sans', Helvetica, sans-serif;
        background: #39b1cc;
        background: -moz-linear-gradient(top, #dbf3fe 0%, #bdeaff 100%);
        background: -webkit-gradient(linear, left top, left bottom, color-stop(0%, #dbf3fe), color-stop(100%, #bdeaff));
        background: -webkit-linear-gradient(top, #dbf3fe 0%, #bdeaff 100%);
        background: -o-linear-gradient(top, #dbf3fe 0%, #bdeaff 100%);
        background: -ms-linear-gradient(top, #dbf3fe 0%, #bdeaff 100%);
        background: linear-gradient(to bottom, #005eab 0%, #499de3 100%);
        color: #ffffff;
        padding: 5px 0px 2px 5px;
        border-top: 1px solid #003969;
        border-left: 1px solid #003969;
        border-right: 1px solid #003969;
    }

    .exp_year_body {
        padding: 5px 0px 2px 5px;
        border-bottom-left-radius: 5px;
        border-bottom-right-radius: 5px;
        border-top: 1px solid #003969;
        border-bottom: 1px solid #003969;
        border-left: 1px solid #003969;
        border-right: 1px solid #003969;
        height: 100% !important;
        margin-bottom: -99999px;
        padding-bottom: 99999px;
    }

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
            <li class="frm-text">
                <a href="rvw_comp.aspx">Components</a>
            </li>
            <li class="frm-text">
                <a href="rvw_proj.aspx">Projection</a>
            </li>
            <li class="active frm-text">
                <a href="rvw_exp.aspx">Expenditures</a>
            </li>
            <li class="frm-text">
                <a href="rvw_graphs.aspx">Graphs</a>
            </li>
        </ul>
        <table style="width: 99%; margin-top: 5px; margin-left: 5px">
            <%
                var conn = reserve.Fn_enc.getconn();
                Int16 beginYear = 0;
                double ttl = 0;

                SqlDataReader dr = reserve.Fn_enc.ExecuteReader("select year(report_effective) as yr from info_project_info where firm_id=@Param1 and project_id=@Param2 and revision_id=@Param3", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString(), Session["revisionid"].ToString() });
                if (dr.Read()) beginYear = Convert.ToInt16(dr["yr"].ToString());
                dr.Close();

                conn.Open();

                DataSet ds = new DataSet();
                DataTable dt;
                StringBuilder sb = new StringBuilder();
                SqlDataAdapter adapter = new SqlDataAdapter("sp_app_rvw_expend " + Session["firmid"].ToString() + ", '" + Session["projectid"].ToString() + "', " + Session["revisionid"].ToString(), conn);
                adapter.Fill(ds, "Expenditures");
                conn.Close();

                for (var i=1; i<31; i++)
                {
            %>
            <tr>
                <td style="width: 33%" class="rvwtbl_cat_exp"><%=beginYear + i - 1 %>: <label id="lblY<%=i - 1 %>"></label></td>
                <td style="width: 5px"></td>
                <td style="width: 33%" class="rvwtbl_cat_exp"><%=beginYear + i %>: <label id="lblY<%=i %>"></label></td>
                <td style="width: 5px"></td>
                <td style="width: 33%" class="rvwtbl_cat_exp"><%=beginYear + i + 1 %>: <label id="lblY<%=i+1 %>"></label></td>
            </tr>
            <tr>
                <td style="border: 1px solid #f7a539; vertical-align: top">
                    <table style="width: 100%">
                        <tr><td class="rvwtbl_hdr text-left" style="padding: 3px; background-color: #cccccc">Component</td><td class="rvwtbl_hdr" style="background-color: #cccccc">Cost</td></tr>
                    <%
                        ttl = 0;
                        ds.Tables[0].DefaultView.RowFilter = "year_id=" + (i + 1).ToString();
                        dt = (ds.Tables[0].DefaultView).ToTable();
                        for (var j=0; j<dt.Rows.Count; j++)
                        {
                            if ((j+1)%2==0) { sb.Append(";background-color: #eeeeee"); }
                            else { sb.Clear(); }
                            Response.Write("<tr><td class=\"rvwtbl text-left\" style=\"padding: 3px" + sb.ToString() + "\">" + dt.Rows[j]["component_desc"].ToString() + "</td>");
                            Response.Write("<td class=\"rvwtbl\" style=\"" + sb.ToString() + "\">" + Convert.ToDouble(dt.Rows[j]["ttl"].ToString()).ToString("C0") + "</td></tr>");
                            ttl+=Convert.ToDouble(dt.Rows[j]["ttl"].ToString());
                        }
                    %>
                        
                    </table>
                    <script>document.getElementById('lblY<%=i-1%>').innerHTML='<%=ttl.ToString("C0") %>';</script>
                </td>
                <td style="width: 5px"></td>
                <td style="border: 1px solid #f7a539; vertical-align: top">
                    <table style="width: 100%">
                        <tr><td class="rvwtbl_hdr text-left" style="padding: 3px; background-color: #cccccc">Component</td><td class="rvwtbl_hdr" style="background-color: #cccccc">Cost</td></tr>
                    <%
                        ttl = 0;
                        ds.Tables[0].DefaultView.RowFilter = "year_id=" + (i+2).ToString();
                        dt = (ds.Tables[0].DefaultView).ToTable();
                        for (var j=0; j<dt.Rows.Count; j++)
                        {
                            if ((j+1)%2==0) { sb.Append(";background-color: #eeeeee"); }
                            else { sb.Clear(); }
                            Response.Write("<tr><td class=\"rvwtbl text-left\" style=\"padding: 3px" + sb.ToString() + "\">" + dt.Rows[j]["component_desc"].ToString() + "</td>");
                            Response.Write("<td class=\"rvwtbl\" style=\"" + sb.ToString() + "\">" + Convert.ToDouble(dt.Rows[j]["ttl"].ToString()).ToString("C0") + "</td></tr>");
                            ttl+=Convert.ToDouble(dt.Rows[j]["ttl"].ToString());
                        }
                    %>
                    </table>
                    <script>document.getElementById('lblY<%=i%>').innerHTML='<%=ttl.ToString("C0") %>';</script>
                </td>
                <td style="width: 5px"></td>
                <td style="border: 1px solid #f7a539; vertical-align: top">
                    <table style="width: 100%">
                        <tr><td class="rvwtbl_hdr text-left" style="padding: 3px; background-color: #cccccc">Component</td><td class="rvwtbl_hdr" style="background-color: #cccccc">Cost</td></tr>
                    <%
                        ttl = 0;
                        ds.Tables[0].DefaultView.RowFilter = "year_id=" + (i+3).ToString();
                        dt = (ds.Tables[0].DefaultView).ToTable();
                        for (var j=0; j<dt.Rows.Count; j++)
                        {
                            if ((j+1)%2==0) { sb.Append(";background-color: #eeeeee"); }
                            else { sb.Clear(); }
                            Response.Write("<tr><td class=\"rvwtbl text-left\" style=\"padding: 3px" + sb.ToString() + "\">" + dt.Rows[j]["component_desc"].ToString() + "</td>");
                            Response.Write("<td class=\"rvwtbl\" style=\"" + sb.ToString() + "\">" + Convert.ToDouble(dt.Rows[j]["ttl"].ToString()).ToString("C0") + "</td></tr>");
                            ttl+=Convert.ToDouble(dt.Rows[j]["ttl"].ToString());
                        }
                    %>
                    </table>
                    <script>document.getElementById('lblY<%=i+1%>').innerHTML='<%=ttl.ToString("C0") %>';</script>
                </td>
            </tr>
            <tr><td style="height: 10px"></td></tr>
            <% 
                    i = i + 2;
                } %>
        </table>

    </div>
    <% } %>
</form>

</asp:content>

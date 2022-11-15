<%@ Page Title="" Language="C#" MasterPageFile="~/Main.Master" AutoEventWireup="true" CodeBehind="tm.aspx.cs" Inherits="reserve.tm" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ import Namespace="System.Text" %>
    
<script src="Scripts/jquery-ui.js"></script>
<script src="Scripts/jquery-3.3.1.js"></script>
<script src="Scripts/wg_ajax.js"></script>
<style>
.ui-autocomplete-loading
{
    background: white url("images/ajax_load.gif") right center no-repeat;    
}
body
{
    line-height: 20px !important;
}
</style>
<link href="css/style.css" rel="stylesheet" />
<%
    bool blDels=false;
    string strTable="";

    if (cboTable.Value != "") {
        var drtemp = reserve.Fn_enc.ExecuteReader("select table_name_real, allow_deletes from lkup_tm_tables where firm_id=@Param1 and table_id=@Param2", new string[] { Session["firmid"].ToString(), cboTable.Value });
        if (drtemp.Read()) {
            strTable = drtemp["table_name_real"].ToString();
            if (drtemp["allow_deletes"] != DBNull.Value) blDels = bool.Parse(drtemp["allow_deletes"].ToString());
        }
        drtemp.Close();
    }
%>
<LINK rel="stylesheet" type="text/css" href="Styles/site.css">
<script src="scripts/masked_input_1.3.js" type="text/javascript"></script>
<script language=javascript>
    var iTotalRows = 0;

    function UpdateRowHeader(iRow, sType) {
        if (sType == 'Edit') {
            document.getElementById('rowHdr' + iRow).innerHTML = '<img src="images/wg_edit.jpg" border=0 align="absmiddle">';
        }
        else if (sType == 'Load') {
            document.getElementById('rowHdr' + iRow).innerHTML = '<img src="images/ajax_snake.gif" border=0 align="absmiddle">';
        }
        else if (sType == 'None') {
            document.getElementById('rowHdr' + iRow).innerHTML = '';
        }
    }

    function CheckRowChanges(sSqlField, sType, iRow, iCol) {
        var sVal = "";
        var iChg = 0;
        if (sType == 'textbox') {
            if (document.getElementById('txt' + iRow + '_' + iCol).value != document.getElementById('hdnAnswer' + iRow + '_' + iCol).value) {
                sVal = document.getElementById('txt' + iRow + '_' + iCol).value;
                iChg = 1;
            }
        }
        else if (sType == 'dropdown') {
            if (document.getElementById('txt' + iRow + '_' + iCol).options[document.getElementById('txt' + iRow + '_' + iCol).selectedIndex].value != document.getElementById('hdnAnswer' + iRow + '_' + iCol).value) {
                sVal = document.getElementById('txt' + iRow + '_' + iCol).options[document.getElementById('txt' + iRow + '_' + iCol).selectedIndex].value;
                iChg = 1;
            }
        }
        else if (sType == 'checkbox') {
            if (document.getElementById('txt' + iRow + '_' + iCol).checked && (document.getElementById('hdnAnswer' + iRow + '_' + iCol).value == '0' || document.getElementById('hdnAnswer' + iRow + '_' + iCol).value == '')) {
                sVal = 1;
                iChg = 1;
            }
            else if (document.getElementById('txt' + iRow + '_' + iCol).checked == false && document.getElementById('hdnAnswer' + iRow + '_' + iCol).value == '1') {
                sVal = 0;
                iChg = 1;
            }
        }

        if (iChg == 1) {
            UpdateRowHeader(iRow, 'Load');
            document.forms[0].disabled = true;
            sendTM(document.getElementById('MainContent_cboTable').options[document.getElementById('MainContent_cboTable').selectedIndex].value, document.getElementById('txtHdnCrit' + iRow).value, sSqlField, sVal, iRow, iCol);
        }
        else {
            UpdateRowHeader('None');
            //return false;
        }
    }

    function checkDel(iRow) {
        <% if (!blDels) { %>
        alert("The administrator has disabled deletes for this table. if you believe this is in error, please contact a technical administrator.");
        <% }
        else
        {
        %>
        if (confirm("Are you sure you want to PERMANENTLY delete this row?") == 1) {
            document.getElementById('MainContent_txtHdnType').value = "Del";
            document.getElementById('MainContent_txtHdnDel').value = document.getElementById('txtHdnCrit' + iRow).value;
            document.forms[0].submit();
        }
        <% } %>
    }

    function isTextSelected(input) {
        if (typeof input.selectionStart == "number") {
            return input.selectionStart == 0 && input.selectionEnd == input.value.length;
        } else if (typeof document.selection != "undefined") {
            input.focus();
            return document.selection.createRange().text == input.value;
        }
    }

    function getCaretPosition(oField) {

        // Initialize
        var iCaretPos = 0;

        // IE Support
        if (document.selection) {

            // Set focus on the element
            oField.focus();

            // To get cursor position, get empty selection range
            var oSel = document.selection.createRange();

            // Move selection start to 0 position
            oSel.moveStart('character', -oField.value.length);

            // The caret position is selection length
            iCaretPos = oSel.text.length;
        }

        // Firefox support
        else if (oField.selectionStart || oField.selectionStart == '0')
            iCaretPos = oField.selectionStart;

        // Return results
        return (iCaretPos);
    }

    function chkKeybd(sender, e, iRow, iCol) {
        var key = e.which ? e.which : e.keyCode;

        if (key == 37) { //left
            if (document.getElementById('txt' + iRow + '_' + (iCol - 1)) != null) {
                if (getCaretPosition(sender) >= 0) document.getElementById('txt' + iRow + '_' + (iCol - 1)).focus();
            }
        }
        else if ((sender.type !== 'select-one') && (key == 38)) { //up
            if (document.getElementById('txt' + (iRow - 1) + '_' + iCol) != null) { document.getElementById('txt' + (iRow - 1) + '_' + iCol).focus(); }
        }
        else if (key == 39) { //right
            if (document.getElementById('txt' + iRow + '_' + (iCol + 1)) != null) {
                if ((sender.type == 'select-one') || (sender.value.length == getCaretPosition(sender))) { document.getElementById('txt' + iRow + '_' + (iCol + 1)).focus(); }
            }
        }
        else if ((sender.type !== 'select-one') && (key == 40)) { //down
            if (document.getElementById('txt' + (iRow + 1) + '_' + iCol) != null) { document.getElementById('txt' + (iRow + 1) + '_' + iCol).focus(); }
        }
    }

    function ChangePage(iPage) {
        document.forms[0].action = "tm.aspx?pageNum=" + iPage
        document.forms[0].submit()
    }

    function tglSort(sField) {
        if (document.getElementById('txtHdnSortField').value == sField) {
            if (document.getElementById('txtHdnSortOrder').value == 'Asc') {
                document.getElementById('txtHdnSortOrder').value = 'Desc';
            }
            else {
                document.getElementById('txtHdnSortOrder').value = 'Asc';
            }
        }
        else {
            document.getElementById('txtHdnSortField').value = sField;
            document.getElementById('txtHdnSortOrder').value = 'Asc';
        }
        document.forms[0].submit();
    }
</script>
<form name="frmTM" id="frmTM" method="POST" action="tm.aspx" runat="server">
<input type=hidden id="txtHdnOp" name="txtHdnOp" />

<div class="container_fluid" style="max-width: 100%">
    <div class="row float-right" style="margin-top: -4px; margin-left: -2px; margin-bottom: 10px">
        <div class="page-top-tab col-lg-3 float-right">
            <p class="panel-title-fd">Admin | Table Maintenance</p>
        </div>
    </div>

<table border=0 cellpadding=5 cellspacing=1 bgcolor="#cccccc" style="padding: 5px; border: 1px solid #cccccc; margin-bottom: 10px">
    <tr>
        <td bgcolor="#eeeeee" valign=top>
            <font class="frm-text">Your Tables:</font>
            <select id="cboTable" name="cboTable" runat="server" onchange="document.forms[0].submit()" style="font-size: 8pt">
            </select>
        </td>
        <% 
            var strFilter = new StringBuilder();
            var strFilterVal = new StringBuilder();
            var param_type = new StringBuilder(); var param_sql = new StringBuilder();

            if (cboTable.SelectedIndex > -1) { %>
        <td bgcolor="#eeeeee" valign=top style="margin-left: 5px">
            <table border=0 cellspacing=0 cellpadding=0>
                <tr>
                    <td><font class="frm-text">Filter (optional): </font></td>
                    <td>
                        <select id="cboFilter" name="cboFilter" runat="server" style="font-size: xx-small" onchange="document.forms(0).submit()">
                        </select>
                    </td>
                    <% 
                        if (cboFilter.Value != "") { %>
                    <td>
                    <%
                        var dr = reserve.Fn_enc.ExecuteReader("select * from lkup_tm_tables_params where firm_id=@Param1 and table_id=@Param2 and param_id=@Param3", new string[] { Session["firmid"].ToString(), cboTable.Value, cboFilter.Value });
                        if (dr.Read()) {

                            strFilter.Append(dr["param_name"].ToString());
                            param_type.Append(dr["param_type"].ToString());
                            if (dr["param_options_sql"] != DBNull.Value)
                            {
                                param_sql.Append(dr["param_options_sql"].ToString());
                                dr.Close();
                                Response.Write("");
                                Response.Write("<select id = \"objFilterVal\" name=\"objFilterVal\" runat=\"server\" style=\"font-size: xx-small\" onchange=\"document.forms(0).submit()\"><Option></Option>");
                                dr = reserve.Fn_enc.ExecuteReader(param_sql.ToString(), null);
                                while (dr.Read()) {
                                    if (Request.Form["objFilterVal"].ToString() == dr[0].ToString()) {
                                        Response.Write("<option selected value=\"" + dr[0].ToString() + "\">" + dr[1].ToString() + "</option>");
                                    } else {
                                        Response.Write("<option value=\"" + dr[0].ToString() + "\">" + dr[1].ToString() + "</option>");
                                    }
                                }
                                Response.Write("</select>");
                            }
                            else {
                                Response.Write("<input type=\"text\" id=\"objFilterVal\" name=\"objFilterVal\" style=\"font-size: 8pt\" value=\"" + Request.Form["objFilterVal"].ToString() + "\">");
                            }
                            if (param_type.ToString() == "wildcard") Response.Write("<input type=\"button\" id=\"cmdFilter\" name=\"cmdFilter\" class=\"input_button_green\" onclick=\"document.forms(0).submit()\" value=\"go\">");
                        }
                        dr.Close();
                        strFilterVal.Append(Request.Form["objFilterVal"].ToString().Replace("'", "''")); %>
                    </td>
                    <% } %>
                </tr>
            </table>
        </td>
            <% } %>
    </tr>
</table>
<%  
    if (cboTable.Value != "") {
        var conn = reserve.Fn_enc.getconn();
        SqlDataReader dr;
        DataSet ds = new DataSet();
        SqlDataAdapter adapter;
        SqlCommand cmd;
        var strTable = new StringBuilder(); var sql_string = new StringBuilder(); var strPK = new StringBuilder(); var strDft = new StringBuilder(); //For building the sql string for each row
        int iPage; int iRowCount; int iPageSize = 25; int iRow; int iPageCount; //For paging
        var strSql = new StringBuilder(); var strVal = new StringBuilder(); var strText = new StringBuilder(); var strDesc = new StringBuilder(); int iSize; //For evaluating values of fields
        var strStatus = new StringBuilder(); var strDefaultSort = new StringBuilder();

        //    'Field-table list
        conn.Open();
        adapter = new SqlDataAdapter();
        cmd = new SqlCommand("sp_app_tm_fields @Param1, @Param2", conn);
        cmd.Parameters.Add(new SqlParameter("Param1", Session["firmid"].ToString()));
        cmd.Parameters.Add(new SqlParameter("Param2", cboTable.Value));
        adapter.SelectCommand = cmd;
        adapter.Fill(ds, "lkup");
        var dv = new DataView(ds.Tables["lkup"]);
        conn.Close();

        dr = reserve.Fn_enc.ExecuteReader("select * from lkup_tm_tables where firm_id=@Param1 and table_id=@Param2", new string[] { Session["firmid"].ToString(), cboTable.Value });
        if (dr.Read()) {
            strTable.Append(dr["table_name_real"].ToString());
            sql_string.Append(dr["table_sql"].ToString());

            if ((strFilter.ToString() != "") && (strFilterVal.ToString() != "")) {
                if(sql_string.ToString().IndexOf(" where ") > 0) {
                    sql_string.Append(" and (" + strFilter);
                }
                else {
                    sql_string.Append(" where (" + strFilter);
                }
                if (param_type.ToString() == "wildcard") {
                    sql_string.Append(" like '%" + strFilterVal + "%')");
                }
                else {
                    sql_string.Append(" = '" + strFilterVal + "')");
                }
            }

            if (dr["default_sort"] != DBNull.Value) strDefaultSort.Append(dr["default_sort"].ToString());
        }
        dr.Close();

        //Get indexes
        dr = reserve.Fn_enc.ExecuteReader("SELECT sysobjects.id AS TABLE_ID, sysobjects.name AS TABLE_NAME, sysindexes.name AS INDEX_NAME, syscolumns.name AS COL_NAME FROM sysobjects INNER JOIN sysindexes ON sysobjects.id = sysindexes.id INNER JOIN sysindexkeys ON sysindexes.id = sysindexkeys.id AND sysindexes.indid = sysindexkeys.indid INNER JOIN syscolumns ON sysindexkeys.id = syscolumns.id AND sysindexkeys.colid = syscolumns.colid INNER JOIN sysobjects sysobjects_1 ON sysindexes.name = sysobjects_1.name WHERE     (sysobjects.type = 'U') AND (sysobjects_1.xtype = 'PK') AND (sysobjects.name = @Param1)", new string[] { strTable.ToString() });
        while (dr.Read()) {
            strPK.Append("[" + dr["COL_Name"].ToString() + "], ");
        }
        dr.Close();

        if (txtHdnSortField.Value != "") sql_string.Append(" order by [" + txtHdnSortField.Value + "] " + txtHdnSortOrder.Value);
        else if (strDefaultSort.ToString() != "") sql_string.Append(" order by " + strDefaultSort);

        adapter = new SqlDataAdapter(sql_string.ToString(), conn);
        adapter.MissingSchemaAction = MissingSchemaAction.AddWithKey;
        adapter.Fill(ds, "recs");

        iRowCount = ds.Tables["recs"].Rows.Count;
        if (Request.QueryString["pageNum"] != null) iPage = int.Parse(Request.QueryString["pageNum"]);
        else iPage = 1;

%>
<table border="0" cellspacing="1" cellpadding="0" bgcolor="#92aedf" width="100%" style="border-collapse: collapse">
	<tr style="height: 35px">
		<td bgcolor="#eeeeee" colspan="<%=ds.Tables["recs"].Columns.Count%>" class="text-left frm-text-blue-bold" style="border-top: 1px solid #dddddd; border-left: 1px solid #dddddd; border-right: 1px solid #dddddd"> <i class="fa fa-chevron-circle-right" style="font-size: 18px"></i> Add New Record</td>
	</tr>
	<tr>
		<td style="BACKGROUND-IMAGE: url('images/grid_chrome.jpg'); HEIGHT: 23px !important; border: 1px solid #dddddd;" width="25px"><font face="arial" size="1" color="#555555" style="FONT-SIZE: 8pt"><b>Add</b></font></td>
		<%

            for (var i = 0; i < ds.Tables["recs"].Columns.Count; i++) {
                dv = new DataView(ds.Tables["lkup"], "field_name='" + ds.Tables["recs"].Columns[i].ColumnName + "' and field_type='hidden'", "", DataViewRowState.CurrentRows);
                if (dv.Count == 0)
                {
                    if (strPK.ToString().IndexOf("[" + ds.Tables["recs"].Columns[i].ColumnName + "]") > 0) {
                        Response.Write("<td style=\"BACKGROUND-IMAGE: url('images/grid_chrome.jpg'); HEIGHT: 25px !important; border: 1px solid #dddddd;\" nowrap><font face=arial size=1 color=red style=\"FONT-SIZE: 8pt\"><b>" + ds.Tables["recs"].Columns[i].ColumnName + "</b></font></td>" + System.Environment.NewLine);
                    }
                    else
                    {
                        Response.Write("<td style=\"BACKGROUND-IMAGE: url('images/grid_chrome.jpg'); HEIGHT: 25px !important; border: 1px solid #dddddd;\" nowrap><font face=arial size=1 color=#555555 style=\"FONT-SIZE: 8pt\"><b>" + ds.Tables["recs"].Columns[i].ColumnName + "</b></font></td>");
                    }
                }
            }
		%>
	</tr>
	<tr style="height: 20px">
		<td bgcolor="#ffffff" align="center"><font face="arial" size="1"><a href="JavaScript: document.forms[0].MainContent_txtHdnType.value='Add'; document.forms[0].submit()"><img src="images/tm_save.jpg" border="0" align="absmiddle"></a></td>
		<%
            for (var i = 0; i < ds.Tables["recs"].Columns.Count; i++)
            {
                strDft.Clear();
                dv.RowFilter = "field_name='" + ds.Tables["recs"].Columns[i].ColumnName + "' and field_type='default'";
                if (dv.Count > 0) strDft.Append(dv.ToTable().Rows[0]["opt_id"].ToString());
                dv.RowFilter = "field_name='" + ds.Tables["recs"].Columns[i].ColumnName + "' and field_type='hidden'";
                if (dv.Count == 0)
                {
                    dv.RowFilter = "field_name='" + ds.Tables["recs"].Columns[i].ColumnName + "' and field_type='dropdown'";
                    if (dv.Count > 0) {
                        Response.Write("<td bgcolor=#dfefff><font face=arial size=1 color=#555555 style=\"FONT-SIZE: 8pt\">");
                        if (dv.ToTable().Rows[0]["field_type"].ToString() == "dropdown")
                        {
                            Response.Write("<font face=arial size=1 color=#555555 style=\"FONT-SIZE: 8pt\"><select id=txtNew" + i + " name=txtNew" + i + " class=\"gridcbo2\">" + System.Environment.NewLine);
                            popCbo(dv.ToTable(), strDft.ToString());
                            Response.Write("</select>");
                        }
                        Response.Write("</td>");
                    }
                    else if (ds.Tables["recs"].Columns[i].DataType.ToString() == "System.Boolean")
                    { //checkbox
                        Response.Write("<td bgcolor=#ffffff style=\"border-bottom: 1px solid #eeeeee\"><font face=arial size=1 color=#555555 style=\"FONT-SIZE: 8pt\"><input type=\"checkbox\" id=txtNew" + i + " name=txtNew" + i + "></td>" + System.Environment.NewLine);
                    }
                    else
                    {
                        Response.Write("<td bgcolor=#ffffff><font face=arial size=1 color=#555555 style=\"FONT-SIZE: 8pt\"><input type=\"text\" id=txtNew" + i + " name=txtNew" + i + " class=\"gridrow_txtbox3\"></td>" + System.Environment.NewLine);
                    }
                }
                else {
                    Response.Write("<input type=\"hidden\" id=txtNew" + i + " name=txtNew" + i + " value=\"" + strDft + "\">");
                }
            }
		%>
	</tr>
</table>
<br />
<table border=0 cellspacing=0 cellpadding=0>
    <tr>
        <td align=right nowrap id="tdRecCount" style="display: none">
            <table border=0 cellspacing=1 cellpadding=0 bgcolor=#cccccc>
                <tr>
                    <td bgcolor=#eeeeee nowrap>
                        <table border=0 style="border-top: 1px solid #dddddd; border-left: 1px solid #dddddd; border-right: 1px solid #dddddd;">
                            <tr>
                                <td nowrap style="vertical-align: bottom">
                                    <div class="frm-text">Page&nbsp;</div>
                                </td>
                                <td nowrap style="vertical-align: bottom">
                                    <!--<div id="dPNum" class="smlcaps">0</div>-->
                                    <select id="cboCurPage" name="cboCurPage" class="frm-text" onchange="ChangePage(this.options[this.selectedIndex].value)"></select>
                                </td>
                                <td nowrap style="vertical-align: bottom">
                                    <div class="frm-text">&nbsp;of&nbsp;</div>
                                </td>
                                <td nowrap style="vertical-align: bottom">
                                    <div id="dPOf" class="frm-text">0</div>
                                </td>
                                <td style="vertical-align: bottom; padding-left: 5px">
                                    <nav aria-label="Page navigation" style="padding: 0px !important; margin: 0px !important; vertical-align: text-bottom">
                                        <ul class="pagination pagination-sm" style="padding: 0px !important; margin: 0px !important; vertical-align: bottom">
                                            <% if (iPage == 1)
                                                { %> <li id="pgPrev" class="page-item disabled"><a href="#">Previous</a></li> <% } %>
                                            <% else
                                                { %> <li id="pgPrev" class="page-item"><a href="#" onclick="ChangePage('<%=iPage - 1 %>')" >Previous</a></li> <% } %>
                                            <li id="pgNext" class="page-item" onclick="ChangePage('<%=iPage + 1 %>')"><a href="#" onclick="" >Next</a></li>
                                        </ul>
                                    </nav>
                                </td>
                                <td id="tdTotalRecs" style="vertical-align: bottom; padding-left: 5px"><div id="dTotalRecs" class="frm-text-blue" style="vertical-align: bottom"></div></td>
                            </tr>
                        </table>
                    </td>
                    <td style="vertical-align: bottom"><label id="lblStatus" class="frm-text-red" style="vertical-align: bottom" runat="server">Loading, please wait...</label></td>
                </tr>
            </table>
        </td>
    </tr>
</table>
<table border=0 cellspacing=0 cellpadding="0" style="border-collapse:collapse !important; padding: 0px !important; margin: 0px" id="Grid" width="100%">
    <tr>
        <td bgcolor="#f7f7f7" nowrap style="BACKGROUND-IMAGE: url('images/grid_chrome.jpg'); HEIGHT: 23px !important; border: 1px solid #dddddd;" width="30px"><div class="gridcol"></div></td>
        <td bgcolor="#f7f7f7" nowrap style="BACKGROUND-IMAGE: url('images/grid_chrome.jpg'); HEIGHT: 23px !important; border: 1px solid #dddddd;" width="30px"><div class="gridcol"></div></td>
		<%

            for (var i = 0; i < ds.Tables["recs"].Columns.Count; i++) {
                dv.RowFilter = "field_name='" + ds.Tables["recs"].Columns[i].ColumnName + "' and field_type='hidden'"; //Some fields are hidden, as they need to be in the sql for certain updates (adding), but we don't want to display them.
                if (dv.Count == 0)
                {
                    if (strPK.ToString().IndexOf("[" + ds.Tables["recs"].Columns[i].ColumnName + "]") > 0)
                    {
                        Response.Write("<td style=\"BACKGROUND-IMAGE: url('images/grid_chrome.jpg'); HEIGHT: 23px !important; border: 1px solid #dddddd;\" nowrap><div onmouseover=\"this.style.cursor='pointer'\" onclick=\"tglSort('" + ds.Tables["recs"].Columns[i].ColumnName + "')\" face=arial size=1 color=red style=\"FONT-SIZE: 8pt\"><b>" + ds.Tables["recs"].Columns[i].ColumnName);
                        if (txtHdnSortField.Value == ds.Tables["recs"].Columns[i].ColumnName)
                        {
                            if (txtHdnSortField.Value.ToString().ToLower() == "desc") Response.Write("&nbsp;<font color=green>▼</font>");
                            else Response.Write("&nbsp;<font color=green>▲</font>");
                        }
                        Response.Write("</b></div></td>" + System.Environment.NewLine);
                    }
                    else
                    {
                        Response.Write("<td style=\"BACKGROUND-IMAGE: url('images/grid_chrome.jpg'); HEIGHT: 23px !important; border: 1px solid #dddddd;\" nowrap><div onmouseover=\"this.style.cursor='pointer'\" onclick=\"tglSort('" + ds.Tables["recs"].Columns[i].ColumnName + "')\" face=arial size=1 color=#555555 style=\"FONT-SIZE: 8pt\"><b>" + ds.Tables["recs"].Columns[i].ColumnName);
                        if (txtHdnSortField.Value == ds.Tables["recs"].Columns[i].ColumnName)
                        {
                            if (txtHdnSortOrder.Value.ToString().ToLower() == "desc") Response.Write("&nbsp;<font color=green>▼</font>");
                            else Response.Write("&nbsp;<font color=green>▲</font>");
                        }
                        Response.Write("</b></div></td>" + System.Environment.NewLine);
                    }
                }
            }
		%>
    </tr>
	<%
        iRow = (iPage - 1) * iPageSize;
        while (iRow < ds.Tables["recs"].Rows.Count && (iRow < (iPageSize * iPage))) {
            strSql.Clear();
            Response.Write("<tr>" + System.Environment.NewLine);
            Response.Write("<td nowrap class=\"gridrow_wt\" bgcolor=#f8f8f8 align=center nowrap><a href=\"javascript: checkDel(" + iRow + ")\"><img src=\"images/x_white.jpg\" border=0 alt=\"Delete\" align=\"absmiddle\"></a></td>" + System.Environment.NewLine);
            Response.Write("<td nowrap class=\"gridrow_wt\" bgcolor=#f8f8f8 align=center nowrap id=\"rowHdr" + iRow + "\"></td>" + System.Environment.NewLine);
            for (var i = 0; i < ds.Tables["recs"].Columns.Count; i++) {
                dv.RowFilter = "field_name='" + ds.Tables["recs"].Columns[i].ColumnName + "' and field_type='hidden'"; //Some fields are hidden, as they need to be in the sql for certain updates (adding), but we don't want to display them.
                if (dv.Count == 0)
                { //Not hidden
                  //Determine field type **202=date
                    dv.RowFilter = "field_name='" + ds.Tables["recs"].Columns[i].ColumnName + "' and field_type='dropdown'";
                    if (dv.Count > 0)
                    {
                        Response.Write("<td class=\"gridrow_wt\">" + System.Environment.NewLine);
                        if (dv.ToTable().Rows[0]["field_type"].ToString() == "dropdown")
                        {
                            Response.Write("<font face=arial size=1 color=#555555 style=\"FONT-SIZE: 8pt\"><select id=txt" + iRow + "_" + i + " name=txt" + iRow + "_" + i + " class=\"gridcbo2\" onfocus=\"UpdateRowHeader(" + iRow + ",'Edit')\" onblur=\"UpdateRowHeader(" + iRow + ",'None'); CheckRowChanges('" + ds.Tables["recs"].Columns[i].ColumnName + "','dropdown'," + iRow + ", " + i + ")\" onkeydown=\"chkKeybd(this, event," + iRow + "," + i + ")\">" + System.Environment.NewLine);
                            popCbo(dv.ToTable(), ds.Tables["recs"].Rows[iRow][i].ToString());
                            Response.Write("</select>");
                            strVal.Append(ds.Tables["recs"].Rows[iRow][i].ToString());
                        }
                        Response.Write("</td>");
                    }
                    else if (ds.Tables["recs"].Columns[i].DataType.ToString() == "System.Boolean")
                    { //checkbox
                        strVal.Clear();
                        strDesc.Clear();
                        if (ds.Tables["recs"].Rows[iRow][i] == DBNull.Value) {
                            strVal.Append("0");
                        }
                        else if (Convert.ToBoolean(ds.Tables["recs"].Rows[iRow][i].ToString()) == true) {
                            strVal.Append("1");
                            strDesc.Append(" checked");
                        }
                        else
                        {
                            strVal.Append(0);
                        }
                        Response.Write("<td class=\"gridrow_wt\"><input type=\"checkbox\" id=\"txt" + iRow + "_" + i + "\" name=\"txt" + iRow + "_" + i + "\"" + strDesc + " onclick=\"UpdateRowHeader(" + iRow + ",'Edit'); CheckRowChanges('" + ds.Tables["recs"].Columns[i].ColumnName + "','checkbox'," + iRow + ", " + i + ")\" onblur=\"UpdateRowHeader(" + iRow + ",'None')\">" + System.Environment.NewLine);
                    }
                    else
                    {
                        if (ds.Tables["recs"].Columns[i].MaxLength == -1)
                        {
                            iSize = 100;
                        }
                        else
                        {
                            iSize = ds.Tables["recs"].Columns[i].MaxLength;
                        }

                        strVal.Clear();
                        strVal.Append(ds.Tables["recs"].Rows[iRow][i].ToString());
                        Response.Write("<td class=\"gridrow_wt\"><input type=\"text\" id=\"txt" + iRow + "_" + i + "\" name=\"txt" + iRow + "_" + i + "\" value=\"" + strVal + "\" class=gridrow_txtbox2 onfocus=\"this.select(); UpdateRowHeader(" + iRow + ",'Edit')\" onblur=\"UpdateRowHeader(" + iRow + ",'None'); CheckRowChanges('" + ds.Tables["recs"].Columns[i].ColumnName + "','textbox'," + iRow + ", " + i + ");\" maxlength=\"" + iSize + "\" onkeydown=\"chkKeybd(this, event," + iRow + "," + i + ")\">" + System.Environment.NewLine);
                    }
                }
                else
                {
                    strVal.Clear();
                    strVal.Append( ds.Tables["recs"].Rows[iRow][i].ToString());
                }
                Response.Write("<input type=\"hidden\" id=\"hdnAnswer" + iRow + "_" + i + "\" name=\"hdnAnswer" + iRow + "_" + i + "\" value=\"" + strVal + "\" /></td>" + System.Environment.NewLine);
                //Generate sql criteria
                if (strPK.ToString().IndexOf("[" + ds.Tables["recs"].Columns[i].ColumnName + "]") >= 0)
                {
                    Response.Write("<input type=\"hidden\" id=\"txtHdnReqd" + iRow + "_" + i + "\" name=\"txtHdnReqd" + iRow + "_" + i + "\" value=\"1\">" + System.Environment.NewLine);
                    if (strSql.ToString() == "")
                    {
                        if (ds.Tables["recs"].Rows[iRow][i] != DBNull.Value)
                        {
                            strSql.Append(ds.Tables["recs"].Columns[i].ColumnName + "='" + strVal.Replace("'","''") + "'");
                        }
                        else
                        {
                            strSql.Append(ds.Tables["recs"].Columns[i].ColumnName + "='" + strVal + "'");
                        }
                    }
                    else {
                        strSql.Append(" and " + ds.Tables["recs"].Columns[i].ColumnName + "='" + strVal.Replace("'", "''") + "'");
                    }
                }
            }
            Response.Write("<input type=\"hidden\" id=txtHdnCrit" + iRow + " name=txtHdnCrit" + iRow + " value=\"" + strSql.ToString() + "\">");
            Response.Write("</tr>" + System.Environment.NewLine);
            iRow++;
        }
        Response.Write("<script>var iCols=" + (ds.Tables["recs"].Columns.Count - 1).ToString() + "</script>" + System.Environment.NewLine);

        if (iPageSize > iRowCount)
            iPageCount = 1;
        else
        {
            if ((iRowCount / iPageSize) > Convert.ToInt16(iRowCount / iPageSize))
                iPageCount = Convert.ToInt16(iRowCount / iPageSize) + 1;
            else
                iPageCount = Convert.ToInt16(iRowCount / iPageSize);
        }
	%>
</table>
<input type=hidden id="hdnTotalRows" name="hdnTotalRows" value="<%=iRowCount%>" />
<script>
    tdRecCount.style.display='block';
    //tdTotalRecs.style.display='block';
    dTotalRecs.innerHTML='<%=iRowCount %> Total Records.';
    for (var i = 0; i <<%=iPageCount+1 %>; i++) {
        var opt = document.createElement('option');
        opt.appendChild(document.createTextNode(i+1));
        opt.value = i+1; // set value property of opt
        document.getElementById('cboCurPage').appendChild(opt); // add opt to end of select box (sel)
    }
    document.getElementById('cboCurPage').selectedIndex=<%=iPage - 1 %>;
    dPOf.innerHTML = '<%=iPageCount+1%>';
    <% if (Convert.ToInt16(iPage) > Convert.ToInt16(iPageCount)) { %>
    document.getElementById('pgNext').className = 'page-item disabled';
    document.getElementById('pgNext').onclick = '';
    <% } %>
    document.getElementById('MainContent_lblStatus').innerHTML = '<%= strStatus %>';
</script>
<% } %>
<input type=hidden id="txtHdnType" name="txtHdnType" runat="server" />
<input type=hidden id="txtHdnDel" name="txtHdnDel" runat="server" />
<input type=hidden id="txtHdnSortField" name="txtHdnSortField" runat="server" />
<input type=hidden id="txtHdnSortOrder" name="txtHdnSortOrder" runat="server" />
</div>
</form>
</asp:Content>

<%@ Page Title="Components" Language="C#" MasterPageFile="~/Main.Master" AutoEventWireup="true" CodeBehind="components.aspx.cs" Inherits="reserve.components" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

<script src="https://ajax.aspnetcdn.com/ajax/jquery/jquery-1.8.0.js"></script>
<script src="https://ajax.aspnetcdn.com/ajax/jquery.ui/1.8.22/jquery-ui.js"></script>
<script src="assets/js/jquery.mask.min.js"></script>
<link href="https://ajax.aspnetcdn.com/ajax/jquery.ui/1.8.10/themes/redmond/jquery-ui.css" rel="stylesheet" />
<link href="css/style.css" rel="stylesheet" />
<link href="css/tbldrag.css" rel="stylesheet" />
<style>
    iframe { display:block; }

    .clientDisabled
        {
            background: #f5f5f5;
            cursor: default !important;
            color: #999999;
        }
</style>

<script language="javascript">
    var request;
    var iSendState = 0;
    var blGet = true;
    var sArea = "";
    var blCode = false;
    var XMLobj;
    var sOp = "";
    var gUrl;
    
    function sendComponent(sCrit, sSqlField, sVal, iRow, iCol) {
	    if ((request.readyState!=4) && (request.readyState!=0)) {
            setTimeout("sendComponent(" + iRow + ", '" + sSqlField + "', '" + sVal + "'," + iRow + "," + iCol + ")", 3000);
        }
	    else {
            sOp = 'sendComponent';
            var url = "ws.asmx/SaveComponent?sCrit=" + escape(sCrit) + "&sField=" + escape(sSqlField) + "&sVal=" + escape(sVal) + "&iRow=" + iRow + "&iCol=" + iCol + "&pd=y";
            console.log(url);
            gUrl = url;
            request.open("GET", url, true);
            request.onreadystatechange = updateSend;
            request.send(null);
            toggleComponentsTable('disable');
        }
    }

    function addComponent(iRow, iCol) {
	    if ((request.readyState!=4) && (request.readyState!=0)) {
            setTimeout("addComponent(" + iRow + ")", 3000);
        }
        else {
            if (iCol == 4) //Base unit cost was changed -- update unit cost column.
            {
                calcRow(iRow);
            }
            sOp = 'addComponent';
            var cGeo; var cVal;
            var cCat = document.getElementById('MainContent_cboCC').options[document.getElementById('MainContent_cboCC').selectedIndex].value;
            var cYr = document.getElementById('MainContent_cboYear').options[document.getElementById('MainContent_cboYear').selectedIndex].value;
            var cID = escape(document.getElementById('txtHdnCompID' + iRow).value);
            var cDesc = escape(document.getElementById('txt' + iRow + '_0').value);
            var cQty = escape(document.getElementById('txt' + iRow + '_1').value);
            var cPP = escape(document.getElementById('txt' + iRow + '_2').value);
            var cUnit = escape(document.getElementById('txt' + iRow + '_3').value);
            var cBUC = escape(document.getElementById('txt' + iRow + '_4').value.replace(/,/g, ''));
            if (document.getElementById('txt' + iRow + '_5').value == 'checked')
                cGeo = 1;
            else
                cGeo = 0;

            var cUC = escape(document.getElementById('txt' + iRow + '_6').value.replace(/,/g, ''));
            var cEUL = escape(document.getElementById('txt' + iRow + '_7').value);
            var cERUL = escape(document.getElementById('txt' + iRow + '_8').value);
            var cNote = escape(document.getElementById('txt' + iRow + '_9').value);

            if (document.getElementById('txt' + iRow + '_10').value == 'checked')
                cVal = 1;
            else
                cVal = 0;

            var cComm = escape(document.getElementById('txt' + iRow + '_11').value);

            var url = "ws.asmx/AddComponent?iRow=" + iRow + "&iCol=" + iCol + "&cYr=" + cYr + "&cCat=" + cCat + "&cID=" + cID + "&cDesc=" + cDesc + "&cQty=" + cQty + "&cPP=" + cPP + "&cUnit=" + cUnit + "&cBuc=" + cBUC + "&cGeo=" + cGeo + "&cUc=" + cUC + "&cEul=" + cEUL + "&cErul=" + cERUL + "&cNote=" + cNote + "&cVal=" + cVal + "&cComm=" + cComm + "&pd=y";
            gUrl = url;
            request.open("GET", url, true);
            request.onreadystatechange = updateSend;
            request.send(null);
        }
    }


function updateSend() {
    if (request.readyState == 4) {
		if (request.status == 200) {
			var Mime = request.getResponseHeader('Content-Type');
            Mime = Mime.toString();
			if(request.responseXML != null) {
                XMLobj = request.responseXML;
            }
			else if((Mime.indexOf('text/xml') == -1) || (Mime.indexOf('application/xml') == -1)) {
				try {
                    XMLobj = createXMLParser(request.responseText);
                }
				catch(e) {
                    alert("Not good: " + e);
                    XMLobj = request.responseText;
                }
            }
			else {
                alert("No XML!");
                var TEXTobj = request.responseText;
            }
		if (XMLobj!=null) {
            if (sOp == 'sendComponent') {
                examineComponent(XMLobj);
            }
            else if (sOp == 'addComponent') {
                examineAddComp(XMLobj);
            }
        }
    }
    else if (request.status == 404)
        alert("Error connecting to the web service - request URL does not exist. If the problem persists, please contact an administrator.")
    else
        alert("Error connecting to the web service: status code is " + request.status + ". If the problem persists, please contact an administrator.")
    }
}

function examineComponent(XMLObj) {
    var iRow=-1;
    var iCol = -1;
    var sStatus = "";
	for (j=0; j<XMLobj.getElementsByTagName('Results').length; j++) {
        iRow = XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('i_row')[0].firstChild.nodeValue;
        iCol=XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('i_col')[0].firstChild.nodeValue;

        if (XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_type')[0].firstChild.nodeValue=='Error') {
            alert("Error saving record. Please send the following error to an administrator: " + XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_desc')[0].firstChild.nodeValue); 
            document.getElementById('MainContent_lblStatus').innerHTML='Error saving record.' + XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_desc')[0].firstChild.nodeValue;
        }
        if (XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_type')[0].firstChild.nodeValue=='Reject') {
            alert(XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_desc')[0].firstChild.nodeValue);
            document.getElementById('MainContent_lblStatus').innerHTML='Could not save record.';
        }
        if (XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_type')[0].firstChild.nodeValue == 'Success') {
            if ((iCol!=-1) && (XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_desc')[0].firstChild==null)) {
                document.getElementById('hdnAnswer' + iRow + '_' + iCol).value = '';
            }
            else if (iCol!=-1) {
                if (iCol==6) document.getElementById('txt' + iRow + '_' + iCol).value = XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_desc')[0].firstChild.nodeValue;
                document.getElementById('hdnAnswer' + iRow + '_' + iCol).value = XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_desc')[0].firstChild.nodeValue;
            }

            if (iCol == -1) sStatus = "component order";
            if (iCol==0) sStatus = "component";
            if (iCol==1) sStatus = "quantity";
            if (iCol==2) sStatus = "+%";
            if (iCol==3) sStatus = "unit";
            if (iCol==4) sStatus = "base unit cost";
            if (iCol==5) sStatus = "geo factor";
            if (iCol==6) sStatus = "unit cost";
            if (iCol==7) sStatus = "estimated useful life";
            if (iCol==8) sStatus = "estimated remaining useful life";
            if (iCol==9) sStatus = "note";
            if (iCol==10) sStatus = "value";
            if (iCol == 11) sStatus = "comments";
            toggleComponentsTable('enable');
            document.getElementById('MainContent_lblStatus').innerHTML='Successfully updated ' + sStatus + '.';
        }
    }
    document.forms[0].disabled=false;
    UpdateRowHeader(iRow, 'None');
    if ((iCol==4) || (iCol==5)) CheckRowChanges("unit_cost", "textbox", iRow, 6)
    return true;
}

function examineAddComp(XMLObj) {
    var iRow = -1;
    var iCol = -1;
    var sStatus = "";
	for (j=0; j<XMLobj.getElementsByTagName('Results').length; j++) {
        iRow = XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('i_row')[0].firstChild.nodeValue;
        iCol=XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('i_col')[0].firstChild.nodeValue;

        if (XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_type')[0].firstChild.nodeValue=='Error') {
            alert("Error saving record. Please send the following error to an administrator: " + XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_desc')[0].firstChild.nodeValue); 
            document.getElementById('MainContent_lblStatus').innerHTML='Error saving record.' + XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_desc')[0].firstChild.nodeValue;
        }
        if (XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_type')[0].firstChild.nodeValue=='Reject') {
            alert(XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_desc')[0].firstChild.nodeValue);
            document.getElementById('MainContent_lblStatus').innerHTML='Could not save record.';
        }
        if (XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_type')[0].firstChild.nodeValue == 'Success') {
            if (XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_desc')[0].firstChild==null) {
                document.getElementById('hdnAnswer' + iRow + '_' + iCol).value = '';
            }
            else {
                document.getElementById('hdnAnswer' + iRow + '_' + iCol).value = XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_desc')[0].firstChild.nodeValue;
            }
            document.getElementById('txtHdnNew' + iRow).value = '0';
            document.getElementById('aDel' + iRow).style.display = 'block';
            document.getElementById('MainContent_lblStatus').innerHTML='Successfully updated component for ' + document.getElementById('MainContent_cboYear').options[document.getElementById('MainContent_cboYear').selectedIndex].text + '.';
            //document.getElementById('MainContent_lblStatus').innerHTML='Successfully updated ' + sStatus + '.';
        }
    }
    document.forms[0].disabled=false;
    UpdateRowHeader(iRow, 'None');
    return true;
}


try {
            request = new XMLHttpRequest(); //recordset
        }
catch (trymicrosoft) {
	try {
            request = new ActiveXObject("Msxml2.XMLHTTP");
        }
	catch (othermicrosoft) {
		try {
            request = new ActiveXObject("Microsoft.XMLHTTP");
        }
		catch (failed) {
            request = false;
        }
	}
}
</script>

<script lang="ja">
    var iTotalRows = 0;
    var iCurRow = 0;

    function UpdateRowHeader(iRow, sType) {
        if (sType == 'Edit') {
            document.getElementById('rowHdr' + iRow).innerHTML = '<img src="images/wg_edit.jpg" border=0 align="absmiddle">';
            iCurRow = iRow;
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
            if (document.getElementById('txtHdnNew' + iRow).value == '1') {
                addComponent(iRow, iCol);
            }
            else {
                sendComponent(document.getElementById('txtHdnCrit' + iRow).value, sSqlField, sVal, iRow, iCol);
            }
        }
        else {
            UpdateRowHeader('None');
        }
    }

    function checkSaveCat() {
        if (document.getElementById('MainContent_txtCatName').value == '') {
            alert('Please enter a category name.')
        }
        else {
            document.getElementById('MainContent_txtHdnType').value = 'SaveCat';
            document.forms[0].submit();
        }
    }

    function checkDelCat() {
        if (confirm('Are you sure you want to PERMANENTLY delete this category? NOTE: all components under this category will also be deleted.') == 1) {
            document.getElementById('MainContent_txtHdnType').value = 'DelCat';
            document.forms[0].submit();
        }

    }

    $(document).ready(function() {
        SearchText();
    });  

    function SearchText() {  
        $(".Component").autocomplete({  
            source: function (request, response) {
            var s = document.getElementById('txt' + iCurRow + '_0').value;
                s = s.replace(/\\/g, "&#92;");
                s = s.replace(/'/gi, "\\'");
            $.ajax({  
                type: "POST",  
                contentType: "application/json; charset=utf-8",  
                url: "components.aspx/Prefill",  
                data: "{'component':'" + s + "'}",  
                dataType: "json",  
                success: function (data) {
                    response($.map(data.d, function (item) {
                        return {
                            label: item.split('|')[0],
                            cBUC: item.split('|')[1],
                            cGf: item.split('|')[2],
                            cEul: item.split('|')[3],
                            cErul: item.split('|')[4]
                        }
                    }))
                },
                error: function(result) {  
                        alert(result.responseText);  
                    }  
                });  
            },
            select: function (event, ui) {
                $("#txt" + iCurRow + "_0").val(ui.item.label);
                $("#txt" + iCurRow + "_4").val(ui.item.cBUC);
                $("#txt" + iCurRow + "_5").prop('checked', ui.item.cGf);
                $("#txt" + iCurRow + "_7").val(ui.item.cEul);
                $("#txt" + iCurRow + "_8").val(ui.item.cErul);
                calcRow(iCurRow);
            },
    });  
}

    var lastCharCode=-1;
    function isNumber(evt) {
        evt = (evt) ? evt : window.event;
        var charCode = (evt.which) ? evt.which : evt.keyCode;
        // This is a special allowance for ctrl+c, ctrl+v, ctrl+z
        if (lastCharCode==17 && (charCode==67 || charCode==86 || charCode==90)) {
            lastCharCode=charCode;
            return true;
        }
        lastCharCode=charCode;
        // 8: backspace
        // 9: tab
        // 37: left
        // 39: right
        // 46: period
        // 48-57: numbers
        var allowableCodes = new Array(8, 9, 17, 37, 39, 46, 190);
        if (allowableCodes.includes(charCode) || (charCode > 47 && charCode < 58)) {
            return true;
        }
        return false;
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
        var iAdjCol = 1;



        if (key == 37) { //left
            <% if ((txtHdnProjType.Value != "1") || (txtHdnProjType.Value != "8")) { %>
            if (iCol == 3) iAdjCol = 2;
            <% } %>

            if (document.getElementById('txt' + iRow + '_' + (iCol - iAdjCol)) != null) {
                if (getCaretPosition(sender) >= 0) document.getElementById('txt' + iRow + '_' + (iCol - iAdjCol)).focus();
            }
        }
        else if ((sender.type !== 'select-one') && (key == 38)) { //up
            if (document.getElementById('txt' + (iRow - 1) + '_' + iCol) != null) { document.getElementById('txt' + (iRow - 1) + '_' + iCol).focus(); }
        }
        else if (key == 39) { //right
            <% if ((txtHdnProjType.Value != "1") && (txtHdnProjType.Value != "8")) { %>
            if (iCol == 1) iAdjCol = 2;
            <% } %>
            if (document.getElementById('txt' + iRow + '_' + (iCol + iAdjCol)) != null) {
                if ((sender.type == 'select-one') || (sender.value.length == getCaretPosition(sender))) { document.getElementById('txt' + iRow + '_' + (iCol + iAdjCol)).focus(); }
                else if (getCaretPosition(sender) >= 0) document.getElementById('txt' + iRow + '_' + (iCol + iAdjCol)).focus();
            }
        }
        else if ((sender.type !== 'select-one') && (key == 40) && (iRow!=0)) { //down
            if (document.getElementById('txt' + (iRow + 1) + '_' + iCol) != null) { document.getElementById('txt' + (iRow + 1) + '_' + iCol).focus(); }
        }
    }

    function calcRow(iRow) {
        var iGeo = <% 
        SqlDataReader dr = reserve.Fn_enc.ExecuteReader("select geo_factor from info_project_info where firm_id=@Param1 and project_id=@Param2 and revision_id=@Param3", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString(), Session["revisionid"].ToString() });
        if (dr.Read()) Response.Write(dr["geo_factor"].ToString() == "" ? "1" : dr["geo_factor"].ToString());
        else Response.Write("1");
        dr.Close();
        %>;
        if (!isNaN(document.getElementById('txt' + iRow + '_4').value) && (document.getElementById('txt' + iRow + '_4').value!='')) {
            var n = parseFloat(document.getElementById('txt' + iRow + '_4').value);
            if (document.getElementById('txt' + iRow + '_5').checked) document.getElementById('txt' + iRow + '_6').value = (iGeo * n).toFixed(2);
            else document.getElementById('txt' + iRow + '_6').value = document.getElementById('txt' + iRow + '_6').value = n;
        }
    }

    function saveNew() {
        if (document.getElementById('txt0_0').value == '') {
            alert("Please enter a component.");
            document.getElementById('txt0_0').focus();
            return false;
        }
        document.getElementById('MainContent_txtHdnType').value = "SaveNewRow";
        document.forms[0].submit();
    }

    function checkDel(iRow) {
        if (confirm("Are you sure you want to PERMANENTLY delete this component?") == 1) {
            document.getElementById('MainContent_txtHdnType').value = "Del";
            document.getElementById('MainContent_txtHdnDel').value = document.getElementById('txtHdnCrit' + iRow).value;
            document.forms[0].submit();
        }
    }

    function togglePP(iRow) {
        if ((document.getElementById('chkPP' + iRow).checked) && (document.getElementById('txt' + iRow + '_2').value == '')) {
            document.getElementById('txt' + iRow + '_2').value = '10';
        }
        else if (!document.getElementById('chkPP' + iRow).checked) document.getElementById('txt' + iRow + '_2').value = '';
        CheckRowChanges('plus_pct', 'textbox', iRow, 2);
    }

    function toggleComponentsTable(state) {
        if (state == 'disable') {
            document.getElementById('components').style.opacity = '.2';
            document.getElementById('components').disabled = true;
        }
        else {
            document.getElementById('components').style.opacity = '1';
            document.getElementById('components').disabled = false;
        }
    }
</script>  
<form id="frmProject" method="post" runat="server" class="needs-validation">
    <div class="container_fluid" style="width: 100%; max-width: 100%">
        <div class="row float-right" style="margin-top: -4px; margin-left: -2px;">
            <div class="page-top-tab-project col-lg-3 float-right">
                <p class="panel-title-fd">Components<br /><label id="lblProject" runat="server" class="frm-text"></label></p>
            </div>
            <div id="divPnRevisions" runat="server" class="page-top-tab-revision col-lg-2 float-right">
                <p class="panel-title-fd">
                    Revision:<br />
                    <label id="lblRevision" runat="server" class="frm-text"></label>
                </p>
           </div>
        </div>
    </div>
    <% if (Session["projectid"].ToString() == "") { %>
    <div class="frm-text-red">Please select a project on the Projects tab first.</div>
    <% } else { %>
    <table style="border-top: 1px solid #cccccc; border-left: 1px solid #cccccc; border-right: 1px solid #cccccc; margin-top: 10px; margin-left: 5px; margin-right: 5px;">
        <tr>
            <td style="background-color: #eeeeee; padding: 3px" class="frm-text-bold">Component Category: </td>
            <td style="background-color: #eeeeee; padding: 3px" class="frm-text-bold"><select id="cboCC" runat="server" onchange="document.getElementById('MainContent_txtHdnType').value=''; document.forms[0].submit()"></select></td>
            <td style="background-color: #eeeeee; padding: 3px" class="frm-text-bold clientHide">
                Category Name: <input type="text" id="txtCatName" runat="server" />
                <button type="button" id="btnSave" class="btn btn-success" onclick="checkSaveCat()">Save</button>
                <% if (cboCC.SelectedIndex > 0) { %> <button type="button" id="btnDel" class="btn btn-danger" onclick="checkDelCat()">Delete</button><% } %>
                <span id="divSaveProject" class="frm-text" style="display: none; font-weight: 500;"><i class="fa fa-spinner fa-pulse fa-fw"></i>&nbsp;Saving, please wait...</span>
                <label id="lblSaveStatus" class="frm-text-red" runat="server"></label>
            </td>
        </tr>
        <% if (cboCC.SelectedIndex>0)
            { %>
        <tr>
            <td style="background-color: #eeeeee; padding: 3px" class="frm-text-bold text-right">Year: </td>
            <td style="background-color: #eeeeee; padding: 3px" colspan="2" class="frm-text-bold text-left"><select id="cboYear" runat="server" onchange="document.getElementById('MainContent_txtHdnType').value=''; document.forms[0].submit()"></select></td>
        </tr>
        <% } %>
    </table>
    <div class="components">
    <% if (cboCC.Value != "-1") {
            string sPP;
            if ((txtHdnProjType.Value == "1") || (txtHdnProjType.Value == "8")) sPP = "";
            else sPP = "none";

            %>
    <table border="0" cellspacing="1" cellpadding="0" bgcolor="#92aedf" width="100%" style="border-collapse: collapse" class="clientHide">
	    <tr style="height: 35px" class="hideClient">
		    <td bgcolor="#eeeeee" colspan="15" class="text-left frm-text-blue-bold" style="border-top: 1px solid #dddddd; border-left: 1px solid #dddddd; border-right: 1px solid #dddddd"> <i class="fa fa-chevron-circle-right" style="font-size: 18px"></i> Add New Record <label id="lblSaveNew" runat="server" class="frm-text-red"></label></td>
	    </tr>
	    <tr class="frm-text-bold grid_tbl_hdr hideClient">
		    <td style="width: 2%">Save</td>
            <td style="width: 20%; text-wrap: none">Component</td>
            <td style="width: 5%">Qty</td>

            <td style="width: 1%; display: <%=sPP%>" nowrap>+%</td>
            <td style="width: 3%; display: <%=sPP%>"></td>

            <td style="width: 4%">Unit</td>
            <td style="width: 7%; text-wrap: none">Base Unit Cost</td>
            <td style="width: 5%; text-wrap: none; word-wrap: hyphenate">Geo Factor</td>
            <td style="width: 8%; text-wrap: none">Unit Cost</td>
            <td style="width: 7%; text-wrap: none">Est. Useful Life</td>
            <td style="width: 7%; text-wrap: none">Est. Remain Useful Life</td>
            <td style="width: 5%">Note</td>
            <td style="width: 2%">Value</td>
            <td style="width: 20%">Comments</td>
		    <td style="width: 2%">Save</td>
	    </tr>
        <tr class="hideClient">
            <td class="gridrow_wt"><a href="#" onclick="saveNew()"><img src="images/tm_save.jpg" border="0" align="absmiddle"></a></td>
            <td class="gridrow_wt"><input type="text" ID="txt0_0" name="txt0_0" class="gridrow_txtbox2 Component"></td>
            <td class="gridrow_wt"><input type="text" id="txt0_1" name="txt0_1" class="gridrow_txtbox2" onkeydown="return isNumber(event)"></td>
            <td class="gridrow_wt" style="display: <%=sPP%>" nowrap><input type="checkbox" id="chkPP0" name="chkPP0" onclick="togglePP(0)" /></td>
            <td class="gridrow_wt" style="display: <%=sPP%>" nowrap><input type="text" id="txt0_2" name="txt0_2" class="gridrow_txtbox2" onkeydown="return isNumber(event)"></td>
            <td class="gridrow_wt"><input type="text" id="txt0_3" name="txt0_3" class="gridrow_txtbox2"></td>
            <td class="gridrow_wt"><input type="text" id="txt0_4" name="txt0_4" class="gridrow_txtbox2" onkeydown="return isNumber(event)" onblur="calcRow(0)"></td>
            <td class="gridrow_wt"><input type="checkbox" id="txt0_5" name="txt0_5" onclick="calcRow(0)" /></td>
            <td class="gridrow_wt"><input type="text" id="txt0_6" name="txt0_6" class="gridrow_txtbox2" style="background-color: #e3f7ff" onkeydown="return isNumber(event)"></td>
            <td class="gridrow_wt"><input type="text" id="txt0_7" name="txt0_7" class="gridrow_txtbox2" onkeydown="return isNumber(event)"></td>
            <td class="gridrow_wt"><input type="text" id="txt0_8" name="txt0_8" class="gridrow_txtbox2" onkeydown="return isNumber(event)"></td>
            <td class="gridrow_wt"><input type="text" id="txt0_9" name="txt0_9" class="gridrow_txtbox2" onkeydown="return isNumber(event)"></td>
            <td class="gridrow_wt"><input type="checkbox" id="txt0_10" name="txt0_10"></td>
            <td class="gridrow_wt"><input type="text" id="txt0_11" name="txt0_11" class="gridrow_txtbox2"></td>
            <td class="gridrow_wt"><a href="#" onclick="saveNew()"><img src="images/tm_save.jpg" border="0" align="absmiddle"></a></td>
        </tr>
    </table>
        <input type="text" id="txtTest" />
    <div id="row" class="text-left">
        <label id="lblStatus" runat="server" class="frm-text-red text-left" style="margin-left: 5px; margin-top: 10px"></label>
    </div>
    <table style="border-collapse: collapse; margin-left: 5px; margin-right: 5px" id="components">
	    <tr class="frm-text-bold grid_tbl_hdr">
		    <th style="width: 2%" class="clientHide">Del</th>
		    <th style="width: 2%">Save</th>
            <th style="width: 20%; text-wrap: none; text-align: left">Component</th>
            <th style="width: 4%; text-align: left">Qty</th>
            <th style="width: 1%; text-align: left; display: <%=sPP%>" nowrap class="clientHide">+%</th>
            <th style="width: 3%; text-align: left; display: <%=sPP%>" nowrap class="clientHide"></th>
            <th style="width: 4%; text-align: left">Unit</th>
            <th style="width: 7%; text-align: left; text-wrap: none">Base Unit Cost</th>
            <th style="width: 5%; text-align: left; text-wrap: none; word-wrap: hyphenate" class="clientHide">Geo Factor</th>
            <th style="width: 5%; text-align: left; text-wrap: none">Unit Cost</th>
            <th style="width: 7%; text-align: left; text-wrap: none">Est. Useful Life</th>
            <th style="width: 11%; text-align: left; text-wrap: none">Est. Remain Useful Life</th>
            <th style="width: 5%; text-align: left">Note</th>
            <th style="width: 2%; text-align: left" class="clientHide">Value</th>
            <th style="width: 20%; text-align: left" class="clientHide">Comments</th>
            <th style="width: 2%; text-align: left" class="clientHide">Images</th>

	    </tr>
        <%
            var iRow = 1;
            StringBuilder sql = new StringBuilder();
            SqlDataReader dr = reserve.Fn_enc.ExecuteReader("sp_app_components @Param1, @Param2, @Param3, @Param4, @Param5", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString(), Session["revisionid"].ToString(), cboYear.Value, cboCC.Value });
            while (dr.Read())
            {
                sql.Clear();
                sql.Append("category_id=" + cboCC.Value + " and component_id=" + dr["component_id"].ToString() + " and year_id=" + cboYear.Value);
            %>
        <tr>
            <td id="<%=dr["component_id"].ToString() %>" nowrap class="gridrow_wt clientHide" bgcolor=#f8f8f8 align=center nowrap><a id="aDel<%=iRow %>" href="javascript: checkDel(<%=iRow %>)" style="display: <% if (dr["year_id"].ToString() == cboYear.Value) { Response.Write("block"); } else { Response.Write("none"); } %>"><img src="images/x_white.jpg" border=0 alt="Delete" align="absmiddle"></a></td>
            <td nowrap class="gridrow_wt" bgcolor=#f8f8f8 align=center nowrap id="rowHdr<%=iRow %>"></td>
            <td class="gridrow_wt">
                <input type="text" ID="txt<%=iRow %>_0" name="txt<%=iRow %>_0" value="<%=dr["component_desc"].ToString() %>" class="gridrow_txtbox2 Component clientDis" onfocus="UpdateRowHeader(<%=iRow %>,'Edit')" onblur="UpdateRowHeader(<%=iRow %>,'None'); CheckRowChanges('component_desc','textbox',<%=iRow %>, 0)" />
                <input type="hidden" id="hdnAnswer<%=iRow %>_0" name="hdnAnswer<%=iRow %>_0" value="<%=dr["component_desc"].ToString() %>" />
                <input type="hidden" id="txtHdnCompID<%=iRow %>" name="txtHdnCompID<%=iRow %>" value="<%=dr["component_id"].ToString() %>" />
            </td>
            <td class="gridrow_wt">
                <input type="text" ID="txt<%=iRow %>_1" name="txt<%=iRow %>_1" value="<%=dr["comp_quantity"].ToString() %>" class="gridrow_txtbox2 clientDis" onkeydown="return isNumber(event)" onfocus="UpdateRowHeader(<%=iRow %>,'Edit')" onblur="UpdateRowHeader(<%=iRow %>,'None'); CheckRowChanges('comp_quantity','textbox',<%=iRow %>, 1)" />
                <input type="hidden" id="hdnAnswer<%=iRow %>_1" name="hdnAnswer<%=iRow %>_1" value="<%=dr["comp_quantity"].ToString() %>" />
            </td>

            <td class="gridrow_wt clientHide" style="display: <%=sPP%>" nowrap>
                <input type="checkbox" ID="chkPP<%=iRow %>" name="chkPP<%=iRow %>" <% if ((dr["plus_pct"].ToString() != "") && (dr["plus_pct"].ToString() != "0")) Response.Write("checked"); %> class="clientDis" onfocus="UpdateRowHeader(<%=iRow %>,'Edit');" onclick="togglePP(<%=iRow %>)" onblur="UpdateRowHeader(<%=iRow %>,'None')" />
            </td>
            <td class="gridrow_wt clientHide" style="display: <%=sPP%>" nowrap>
                <input type="text" ID="txt<%=iRow %>_2" name="txt<%=iRow %>_2" value="<% if ((dr["plus_pct"].ToString() != "") && (dr["plus_pct"].ToString() != "0")) Response.Write(dr["plus_pct"].ToString()); %>" class="gridrow_txtbox2 clientDis" onfocus="UpdateRowHeader(<%=iRow %>,'Edit')" onblur="UpdateRowHeader(<%=iRow %>,'None'); CheckRowChanges('plus_pct','textbox',<%=iRow %>, 2)" />
                <input type="hidden" id="hdnAnswer<%=iRow %>_2" name="hdnAnswer<%=iRow %>_2" value="<%= dr["plus_pct"].ToString() %>" />
            </td>

            <td class="gridrow_wt">
                <input type="text" ID="txt<%=iRow %>_3" name="txt<%=iRow %>_3" value="<%=dr["comp_unit"].ToString() %>" class="gridrow_txtbox2 clientDis" onfocus="UpdateRowHeader(<%=iRow %>,'Edit')" onblur="UpdateRowHeader(<%=iRow %>,'None'); CheckRowChanges('comp_unit','textbox',<%=iRow %>, 3)" />
                <input type="hidden" id="hdnAnswer<%=iRow %>_3" name="hdnAnswer<%=iRow %>_3" value="<%=dr["comp_unit"].ToString() %>" />
            </td>
            <td class="gridrow_wt">
                <input type="text" ID="txt<%=iRow %>_4" name="txt<%=iRow %>_4" value="<%=dr["base_unit_cost"].ToString() %>" class="gridrow_txtbox2 clientDis" onkeydown="return isNumber(event)" onfocus="UpdateRowHeader(<%=iRow %>,'Edit');" onblur="UpdateRowHeader(<%=iRow %>,'None'); CheckRowChanges('base_unit_cost','textbox',<%=iRow %>, 4)" />
                <input type="hidden" id="hdnAnswer<%=iRow %>_4" name="hdnAnswer<%=iRow %>_4" value="<%=dr["base_unit_cost"].ToString() %>" />
            </td>
            <td class="gridrow_wt clientHide">
                <input type="checkbox" ID="txt<%=iRow %>_5" name="txt<%=iRow %>_5" <%= Convert.ToBoolean(dr["geo_factor"].ToString()) == true ? "checked" : "" %> class="clientDis" onclick="UpdateRowHeader(<%=iRow %>, 'Edit'); calcRow(<%=iRow%>); CheckRowChanges('geo_factor','checkbox',<%=iRow %>, 5)" onblur="UpdateRowHeader(<%=iRow %>,'None')" />
                <input type="hidden" id="hdnAnswer<%=iRow %>_5" name="hdnAnswer<%=iRow %>_5" value="<%=Convert.ToBoolean(dr["geo_factor"].ToString()) == true ? "1" : "0" %>" />
            </td>

            <td class="gridrow_wt">
                <input type="text" ID="txt<%=iRow %>_6" name="txt<%=iRow %>_6" value="<%=dr["unit_cost"].ToString() %>" class="gridrow_txtbox2" style="background-color: #e3f7ff" onkeydown="return isNumber(event); calcRow(<%=iRow %>)" onfocus="UpdateRowHeader(<%=iRow %>,'Edit')" onblur="UpdateRowHeader(<%=iRow %>,'None'); CheckRowChanges('unit_cost','textbox',<%=iRow %>, 6)" />
                <input type="hidden" id="hdnAnswer<%=iRow %>_6" name="hdnAnswer<%=iRow %>_6" value="<%=dr["unit_cost"].ToString() %>" />
            </td>


            <td class="gridrow_wt">
                <input type="text" ID="txt<%=iRow %>_7" name="txt<%=iRow %>_7" value="<%=dr["est_useful_life"].ToString() %>" class="gridrow_txtbox2 clientDis" onkeydown="return isNumber(event)" onfocus="UpdateRowHeader(<%=iRow %>,'Edit')" onblur="UpdateRowHeader(<%=iRow %>,'None'); CheckRowChanges('est_useful_life','textbox',<%=iRow %>, 7)" />
                <input type="hidden" id="hdnAnswer<%=iRow %>_7" name="hdnAnswer<%=iRow %>_7" value="<%=dr["est_useful_life"].ToString() %>" />
            </td>
            <td class="gridrow_wt">
                <input type="text" ID="txt<%=iRow %>_8" name="txt<%=iRow %>_8" value="<%=dr["est_remain_useful_life"].ToString() %>" class="gridrow_txtbox2" onkeydown="return isNumber(event)" onfocus="UpdateRowHeader(<%=iRow %>,'Edit');" onblur="UpdateRowHeader(<%=iRow %>,'None'); CheckRowChanges('est_remain_useful_life','textbox',<%=iRow %>, 8)" />
                <input type="hidden" id="hdnAnswer<%=iRow %>_8" name="hdnAnswer<%=iRow %>_8" value="<%=dr["est_remain_useful_life"].ToString() %>" />
            </td>
            <td class="gridrow_wt">
                <input type="text" ID="txt<%=iRow %>_9" name="txt<%=iRow %>_9" value="<%=dr["comp_note"].ToString() %>" class="gridrow_txtbox2 clientDis" onfocus="this.select(); UpdateRowHeader(<%=iRow %>,'Edit')" onblur="UpdateRowHeader(<%=iRow %>,'None'); CheckRowChanges('comp_note','textbox',<%=iRow %>, 9)" />
                <input type="hidden" id="hdnAnswer<%=iRow %>_9" name="hdnAnswer<%=iRow %>_9" value="<%=dr["comp_note"].ToString() %>" />
            </td>
            <td class="gridrow_wt clientHide">
                <input type="checkbox" ID="txt<%=iRow %>_10" name="txt<%=iRow %>_10" <%= Convert.ToBoolean(dr["comp_value"].ToString()) == true ? "checked" : "" %> class="clientDis" onfocus="UpdateRowHeader(<%=iRow %>,'Edit');" onclick="CheckRowChanges('comp_value','checkbox',<%=iRow %>, 10)" onblur="UpdateRowHeader(<%=iRow %>,'None')" />
                <input type="hidden" id="hdnAnswer<%=iRow %>_10" name="hdnAnswer<%=iRow %>_10" value="<%= Convert.ToBoolean(dr["comp_value"].ToString()) == true ? "1" : "0" %>" />
            </td>
            <td class="gridrow_wt clientHide">
                <input type="text" ID="txt<%=iRow %>_11" name="txt<%=iRow %>_11" value="<%=dr["comp_comments"].ToString() %>" class="gridrow_txtbox2 clientDis" onfocus="this.select(); UpdateRowHeader(<%=iRow %>,'Edit')" onblur="UpdateRowHeader(<%=iRow %>,'None'); CheckRowChanges('comp_comments','textbox',<%=iRow %>, 11)" />
                <input type="hidden" id="hdnAnswer<%=iRow %>_11" name="hdnAnswer<%=iRow %>_11" value="<%=dr["comp_comments"].ToString() %>" />
                <input type="hidden" id="txtHdnCrit<%=iRow %>" name="txtHdnCrit<%=iRow %>" value="<%=sql %>">
                <input type="hidden" id="txtHdnNew<%=iRow %>" name="txtHdnNew<%=iRow %>" value="<%= cboYear.Value == dr["year_id"].ToString() ? "0" : "1" %>" />
            </td>
            <td class="gridrow_wt clientHide" nowrap>
                <% if (cboYear.Value == "1") { %><a href="#"><img src="images/plus_white.jpg" class="showModal" data-toggle="modal" data-target="#mdlNotes"  data-cat="<%=cboCC.Value %>" data-comp="<%=dr["component_id"].ToString() %>" /><label class="frm-text" id="lblImg<%=dr["component_id"].ToString() %>"><sup><%=dr["ttl_images"].ToString() %></sup></label></a> <% } %>
            </td>

        </tr>
        <%
            iRow++;
        }
            dr.Close();
        %>
    </table>

    <br />

    <% } } %>
    </div>
    <input type="hidden" id="txtHdnType" runat="server" />
    <input type="hidden" id="txtHdnDel" runat="server" />
    <!--Modal: Name-->
    <div class="modal fade" id="mdlNotes" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
      <div class="modal-dialog modal-lg" role="document">
        <!--Content-->
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Photos and Notes</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
              <!--Body-->
            <div class="modal-body mt-0 mb-0 p-0" style="margin-top: 0px">
                <div class="embed-responsive embed-responsive-16by9 z-depth-1-half">
                    <iframe class="embed-responsive-item" src="notes.aspx" id="mdlWindow" allowfullscreen></iframe>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal" onclick="document.getElementById('lblImg' + iCurComp).innerHTML='<sup>' + document.getElementById('mdlWindow').contentWindow.document.getElementById('txtHdnCount').value + '</sup>'">Close</button>
            </div>
        </div>
        <!--/.Content-->
      </div>
    </div>
    <input type="hidden" id="txtHdnProjType" name="txtHdnProjType" runat="server" />
    <script>
        var iCurComp = -1;
        $(document).ready(function () {
            <% if (Session["client"].ToString()=="1") { %>
            $(".clientHide").hide();
            $(".clientDis").attr("disabled", true);
            $(".clientDis").addClass("clientDisabled");
            <% } %>
            $(".showModal").click(function (e) {
            e.preventDefault();
            var cat = $(this).attr("data-cat");
            var comp = $(this).attr("data-comp")
            iCurComp = comp;
            $("#mdlNotes iframe").attr("src", "notes.aspx?cat=" + cat + "&comp=" + comp);
            $("#mdlNotes").modal("show");
          });
        });
    </script>
    <script src="Scripts/tbldrag.js"></script>
</form>


</asp:Content>




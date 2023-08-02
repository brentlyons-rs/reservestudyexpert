<%@ Page Language="C#" AutoEventWireup="true" MasterPageFile="~/Main.Master"  CodeBehind="main.aspx.cs" Inherits="reserve.main" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

<script src="Scripts/jquery-3.3.1.js"></script>
<script src="Scripts/jquery-ui.js"></script>
<script src="assets/js/jquery.mask.min.js"></script>
<script src="Scripts/main.js"></script>
<link href="css/jquery-ui.css" rel="stylesheet" />
<link href="css/style.css" rel="stylesheet" />
    <style>
            td {
                width: auto;
            }

            td.min {
                width: 1%;
                white-space: nowrap;
            }
            .ui-widget{font-size:12px;}
            .form-control { height: 30px; width: 100% !important; }
    </style>

    <script type="text/javascript">
        var sElems = [];

        $(document).ready(function() {
            SearchText();
            <% if (Session["client"].ToString() == "0") { %>
            $('#MainContent_txtPID').mask('00000-00');
            $('#MainContent_txtClonePID').mask('00000-00');
            <% } %>
        });  

        function SearchText() {  
            $("#MainContent_txtProject").autocomplete({  
                source: function (request, response) {  
                    var s = document.getElementById('MainContent_txtProject').value;
                    s = s.replace(/\\/g, "&#92;");
                    s = s.replace(/'/gi, "\\'");
                    $.ajax({  
                        type: "POST",  
                        contentType: "application/json; charset=utf-8",  
                        url: "main.aspx/GetEmp",  
                        data: "{'empName':'" + s + "'}",  
                        dataType: "json",  
                        success: function (data) {
                            response($.map(data.d, function (item) {
                                return {
                                    label: item.split('|')[0],
                                    val: item.split('|')[1]
                                }
                            }))
                        },
                        error: function (result) {  
                                alert(result.responseText);  
                            }  
                        });  
                },
                select: function (event, ui) {
                    $("#MainContent_txtHdnSave").val('');
                    $("#MainContent_lblSaveStatus").html('');
                    $("#MainContent_txtHdnProject").val(ui.item.val);
                    $("#MainContent_txtHdnSelected").val('selected');
                    $("#divLoadProject").show();
                    $('#frmProject').submit();
                }
            });  
        }

        function isNumber(evt) {
            evt = (evt) ? evt : window.event;
            var charCode = (evt.which) ? evt.which : evt.keyCode;
            if (charCode != 46 && charCode > 31 && (charCode < 48 || charCode > 57)) {
                return false;
            }
            return true;
        }

        function NewProj() {
            document.getElementById('MainContent_txtProject').value = '';
            document.getElementById('MainContent_txtHdnProject').value = '-1';
            document.getElementById('MainContent_txtHdnType').value = 'New';
            document.forms[0].submit();
        }

        function SameAsSite(c) {
            if (c.checked) {
                document.getElementById('MainContent_txtClA1').value = document.getElementById('MainContent_txtSA1').value;
                document.getElementById('MainContent_txtClA2').value = document.getElementById('MainContent_txtSA2').value;
                document.getElementById('MainContent_txtClC').value = document.getElementById('MainContent_txtSC').value;
                document.getElementById('MainContent_txtClZ').value = document.getElementById('MainContent_txtSZ').value;
                document.getElementById('MainContent_cboCS').value = document.getElementById('MainContent_cboSS').value;
            }
            else {
                document.getElementById('MainContent_txtClA1').value = '';
                document.getElementById('MainContent_txtClA2').value = '';
                document.getElementById('MainContent_txtClC').value = '';
                document.getElementById('MainContent_txtClZ').value = '';
                document.getElementById('MainContent_cboCS').value = '';
            }
        }

        function SameAsContact(c) {
            if (c.checked) {
                document.getElementById('MainContent_txtSN').value = document.getElementById('MainContent_txtCN').value;
                document.getElementById('MainContent_txtST').value = document.getElementById('MainContent_txtCT').value;
                document.getElementById('MainContent_cboSP').value = document.getElementById('MainContent_cboCP').value;
            }
            else {
                document.getElementById('MainContent_txtSN').value = '';
                document.getElementById('MainContent_txtST').value = '';
                document.getElementById('MainContent_cboSP').value = '';
            }
        }

        function toggleReqd() {
            if (document.getElementById('MainContent_cboPT').value == 9) { //Preliminary study doesn't need Source of Previous Begin Bal
                document.getElementById('tdSBB1').style.display = 'none';
                document.getElementById('tdSBB2').style.display = 'none';
            }
            else {
                document.getElementById('tdSBB1').style.display = '';
                document.getElementById('tdSBB2').style.display = '';
            }

            if ((document.getElementById('MainContent_cboPT').value == 2) || (document.getElementById('MainContent_cboPT').value == 3) || (document.getElementById('MainContent_cboPT').value == 4)) {
                document.getElementById('MainContent_txtPP').required = true;
                document.getElementById('MainContent_txtPRC').required = true;
                //document.getElementById('MainContent_txtPP').value = '';
                //document.getElementById('MainContent_txtPRC').value = '';
                document.getElementById('trUpdate').style.display = '';
            }
            else {
                document.getElementById('MainContent_txtPP').required = false;
                document.getElementById('MainContent_txtPRC').required = false;
                document.getElementById('trUpdate').style.display = 'none';
            }
        }

        function checkClone() {
            if (document.getElementById('MainContent_txtClonePID').value.length != 8) {
                alert("Please enter a project number in the format of 00000-00.");
                document.getElementById('MainContent_txtClonePID').focus();
                return false;
            }
            if (document.getElementById('MainContent_txtClonePName').value == '') {
                alert("Please enter a new project name.");
                document.getElementById('MainContent_txtClonePName').focus();
                return false;
            }
            document.getElementById('MainContent_txtHdnType').value = 'Clone';
            document.getElementById('MainContent_divCloneStatus').innerHTML = 'Saving, please wait...';
            document.forms[0].submit();
        }

        function initItemsChanged() {
            sElems.push(document.getElementById('MainContent_cboPT').value); //0
            sElems.push(document.getElementById('MainContent_txtPN').value); //1
            sElems.push(document.getElementById('MainContent_txtPM').value); //2
            sElems.push(document.getElementById('MainContent_txtAoC').value); //3
            sElems.push(document.getElementById('MainContent_txtNU').value); //4
            sElems.push(document.getElementById('MainContent_txtNB').value); //5
            sElems.push(document.getElementById('MainContent_txtNF').value); //6
            sElems.push(document.getElementById('MainContent_txtSA1').value); //7
            sElems.push(document.getElementById('MainContent_txtSA2').value); //8
            sElems.push(document.getElementById('MainContent_txtSC').value); //9
            sElems.push(document.getElementById('MainContent_cboSS').value); //10
            sElems.push(document.getElementById('MainContent_txtSZ').value); //11
            sElems.push(document.getElementById('MainContent_txtID').value); //12
            sElems.push(document.getElementById('MainContent_txtRE').value); //13
            sElems.push(document.getElementById('MainContent_txtGF').value); //14
            //sElems.push(document.getElementById('MainContent_txtTV').value); //15
            sElems.push(document.getElementById('MainContent_txtInt').value); //16
            sElems.push(document.getElementById('MainContent_txtInf').value); //17
            sElems.push(document.getElementById('MainContent_cboCP').value); //18
            sElems.push(document.getElementById('MainContent_txtCN').value); //19
            sElems.push(document.getElementById('MainContent_txtCT').value); //20
            sElems.push(document.getElementById('MainContent_txtCoN').value); //21
            sElems.push(document.getElementById('MainContent_txtCP').value); //22
            sElems.push(document.getElementById('MainContent_txtCE').value); //23
            sElems.push(document.getElementById('MainContent_txtClA1').value); //24
            sElems.push(document.getElementById('MainContent_txtClA2').value); //25
            sElems.push(document.getElementById('MainContent_txtClC').value); //26
            sElems.push(document.getElementById('MainContent_cboCS').value); //27
            sElems.push(document.getElementById('MainContent_txtClZ').value); //28
            sElems.push(document.getElementById('MainContent_txtBB').value); //29
            sElems.push(document.getElementById('MainContent_txtCC').value); //30
            sElems.push(document.getElementById('MainContent_cboSP').value); //31
            sElems.push(document.getElementById('MainContent_txtSN').value); //32
            sElems.push(document.getElementById('MainContent_txtST').value); //33
            sElems.push(document.getElementById('MainContent_txtPP').value); //34
            sElems.push(document.getElementById('MainContent_txtPRC').value); //35
            sElems.push(document.getElementById('MainContent_txtSBB').value); //36
            sElems.push(document.getElementById('MainContent_txtPSD').value); //37
        }

        function checkChanges() {
            var blChanged = false;
            if (sElems[0] != document.getElementById('MainContent_cboPT').value) blChanged = true;
            if (sElems[1] != document.getElementById('MainContent_txtPN').value) blChanged = true;
            if (sElems[2] != document.getElementById('MainContent_txtPM').value) blChanged = true;
            if (sElems[3] != document.getElementById('MainContent_txtAoC').value) blChanged = true;
            if (sElems[4] != document.getElementById('MainContent_txtNU').value) blChanged = true;
            if (sElems[5] != document.getElementById('MainContent_txtNB').value) blChanged = true;
            if (sElems[6] != document.getElementById('MainContent_txtNF').value) blChanged = true;
            if (sElems[7] != document.getElementById('MainContent_txtSA1').value) blChanged = true;
            if (sElems[8] != document.getElementById('MainContent_txtSA2').value) blChanged = true;
            if (sElems[9] != document.getElementById('MainContent_txtSC').value) blChanged = true;
            if (sElems[10] != document.getElementById('MainContent_cboSS').value) blChanged = true;
            if (sElems[11] != document.getElementById('MainContent_txtSZ').value) blChanged = true;
            if (sElems[12] != document.getElementById('MainContent_txtID').value) blChanged = true;
            if (sElems[13] != document.getElementById('MainContent_txtRE').value) blChanged = true;
            if (sElems[14] != document.getElementById('MainContent_txtGF').value) blChanged = true;
            //if (sElems[15] != document.getElementById('MainContent_txtTV').value) blChanged = true;
            if (sElems[15] != document.getElementById('MainContent_txtInt').value) blChanged = true;
            if (sElems[16] != document.getElementById('MainContent_txtInf').value) blChanged = true;
            if (sElems[17] != document.getElementById('MainContent_cboCP').value) blChanged = true;
            if (sElems[18] != document.getElementById('MainContent_txtCN').value) blChanged = true;
            if (sElems[19] != document.getElementById('MainContent_txtCT').value) blChanged = true;
            if (sElems[20] != document.getElementById('MainContent_txtCoN').value) blChanged = true;
            if (sElems[21] != document.getElementById('MainContent_txtCP').value) blChanged = true;
            if (sElems[22] != document.getElementById('MainContent_txtCE').value) blChanged = true;
            if (sElems[23] != document.getElementById('MainContent_txtClA1').value) blChanged = true;
            if (sElems[24] != document.getElementById('MainContent_txtClA2').value) blChanged = true;
            if (sElems[25] != document.getElementById('MainContent_txtClC').value) blChanged = true;
            if (sElems[26] != document.getElementById('MainContent_cboCS').value) blChanged = true;
            if (sElems[27] != document.getElementById('MainContent_txtClZ').value) blChanged = true;
            if (sElems[28] != document.getElementById('MainContent_txtBB').value) blChanged = true;
            if (sElems[29] != document.getElementById('MainContent_txtCC').value) blChanged = true;
            if (sElems[30] != document.getElementById('MainContent_cboSP').value) blChanged = true;
            if (sElems[31] != document.getElementById('MainContent_txtSN').value) blChanged = true;
            if (sElems[32] != document.getElementById('MainContent_txtST').value) blChanged = true;
            if (sElems[33] != document.getElementById('MainContent_txtPP').value) blChanged = true;
            if (sElems[34] != document.getElementById('MainContent_txtPRC').value) blChanged = true;
            if (sElems[35] != document.getElementById('MainContent_txtSBB').value) blChanged = true;
            if (sElems[36] != document.getElementById('MainContent_txtPSD').value) blChanged = true;

            if (blChanged) {
                if (confirm("You have made changes to this form but have not saved your changes. Are you sure you want to navigate away from this page and lose your unsaved changes?") == 0) return false;
            }
        }

        function checkSendToClient() {
            var str = document.getElementById('MainContent_txtS2CEMail').value;
            if (str == '') {
                alert("Please enter the email address to send this project to.");
                document.getElementById('MainContent_txtS2CEMail').focus();
                return false;
            }
            if ((str.indexOf("@") == -1) || (str.indexOf(".") == -1)) {
                alert("Please enter a valid email address.");
                document.getElementById('MainContent_txtS2CEMail').focus();
                return false;
            }
            var blRevSelected = false;
            for (var i = 0; i < parseInt(document.getElementById('txtHdnTotalRevs').value) - 1; i++) {
                if (document.getElementById('chkClientRev' + i).checked) {
                    blRevSelected = true;
                }
            }
            if (!blRevSelected) {
                alert("Please select at least one revision you would like the client to be able to access.");
                return false;
            }
            document.getElementById('MainContent_txtHdnType').value = 'SendToClient';
            document.getElementById('MainContent_divCloneStatus').innerHTML = 'Sending to client, please wait...';
            document.forms[0].submit();
        }

        function confirmNewRevision() {
            if (confirm("Continuing will copy all data (project info, components, projections, etc.) under a new revision. Would you like to continue?") == 1) {
                document.getElementById('MainContent_txtHdnType').value = 'CreateRevision';
                document.forms[0].submit();
            }
        }

        function changeRevision() {
            document.getElementById('MainContent_txtHdnType').value = 'ChangeRevision';
            document.forms[0].submit();
        }

        function toggleChkRev(i) {
            if (document.getElementById('chkRev' + i).checked) {
                document.getElementById('chkRev' + i).checked = false;
            }
            else {
                document.getElementById('chkRev' + i).checked = true;
            }
        }

        function toggleClientRev(i) {
            if (document.getElementById('chkClientRev' + i).checked) {
                document.getElementById('chkClientRev' + i).checked = false;
            }
            else {
                document.getElementById('chkClientRev' + i).checked = true;
            }
        }

        function checkDelRev(i) {
            if (confirm("Are you sure you want to PERMANENTLY delete this revision, and all associated data for this revision?") == 1) {
                deleteRevision(document.getElementById('txtHdnChkRev' + i).value, i);
            }
        }
    </script>
<form id="frmProject" runat="server" class="needs-validation">
    <div class="container_fluid" id="container_main" style="max-width: 100%">
        <div class="row float-right" style="margin-top: -4px; margin-left: -2px;">
            <div class="page-top-tab-project col-lg-3 float-right">
                <p class="panel-title-fd">Input page for Reserve Study:&nbsp;<label id="lblProject" runat="server" class="frm-text"></label></p>
            </div>
            <div id="divPnRevisions" runat="server" class="page-top-tab-revision col-lg-2 float-right">
                <p class="panel-title-fd">
                    Revision:<br />
                    <select id="cboRevision" runat="server" onchange="changeRevision()"></select>
                    <button id="btnNewRevision" title="Create New Revision" runat="server" class="btn-revision showNewRevision" data-toggle="modal" data-target="#mdlNewRevision" data-cat="catg" data-comp="dcmp"><i class="fa fa-plus-circle" style="color: white"></i></button>
                    <button id="btnManageRevisions" title="Manage Existing Revisions" runat="server" class="btn-revision showManageRevisions" data-toggle="modal" data-target="#mdlManageRevisions" data-cat="catg" data-comp="dcmp"><i class="fa fa-gear" style="color: white"></i></button>
                </p>
           </div>
        </div>
        <div class="input-group text-left col-lg-5 text-nowrap rounded-lg shadow form-inline" id="divProjManip" runat="server" style="margin-bottom: 5px; padding: 0px; margin-top: 3px">
            <input type="text" ID="txtProject" runat="server" class="form-control" placeholder="Search for an existing project" />  
            <asp:HiddenField ID="txtHdnProject" runat="server" Value="-1" />
            <input type="hidden" id="txtHdnSelected" runat="server" />
            &nbsp;or&nbsp;
            <button type="button" class="btn btn-primary" onclick="NewProj()">Create new project</button>
            <% if (txtHdnProject.Value != "-1") { %>
            &nbsp;<a href="#" class="btn btn-primary showClone" id="cmdLogin" data-toggle="modal" data-target="#mdlNotes" data-cat="catg" data-comp="dcmp">Clone Project</a>
            &nbsp;<a href="#" class="btn btn-primary showSendToClient" id="cmdSendToClient" data-toggle="modal" data-target="#mdlClient" data-cat="catg" data-comp="dcmp">Client Invites</a>
            <div id="divCloneStatus" runat="server" class="frm-text-red"></div>
            <% } %>
            <span id="divLoadProject" class="frm-text" style="display: none; font-weight: 500;"><i class="fa fa-spinner fa-pulse fa-fw"></i>&nbsp;Loading, please wait...</span>
        </div>

        <table class="table table-striped table-condensed" style="width:100%">
            <tbody>
                <tr><td colspan="8" class="text-left frm-text-blue-bold" style="background-color: #eeeeee"><i class="fa fa-chevron-circle-right" style="font-size: 18px"></i> General Project Information</td></tr>
                <tr>
                    <td class="form-inline text-right"><label class="frm-text-bold">Project type:</label></td>
                    <td class="form-inline"><select class="form-control" id="cboPT" runat="server" onchange="toggleReqd()"></select></td>

                    <td class="form-inline text-right"><label class="frm-text-bold">Project number:</label></td>
                    <td class="form-inline"><div class="col"><input type="text" runat="server" class="form-control" id="txtPID" maxlength="15" required placeholder="00000-00"></div></td>

                    <td class="form-inline text-right"><label class="frm-text-bold">Project name:</label></td>
                    <td class="form-inline"><div class="col"><input type="text" runat="server" class="form-control" id="txtPN" maxlength="100" required></div></td>

                    <td class="form-inline text-right"><label class="frm-text-bold">Project manager:</label></td>
                    <td class="form-inline"><div class="col"><input type="text" runat="server" class="form-control" id="txtPM" maxlength="50" required></div></td>
                </tr>
                <tr><td colspan="8" class="text-left frm-text-blue-bold" style="background-color: #eeeeee"><i class="fa fa-chevron-circle-right" style="font-size: 18px"></i> Community Characteristics</td></tr>
                <tr>
                    <td class="form-inline text-right"><label class="frm-text">Age of community:</label></td>
                    <td class="form-inline"><input type="text" class="form-control" runat="server" id="txtAoC" onkeypress="return isNumber(event)"></td>

                    <td class="form-inline text-right"><label class="frm-text"># of units:</label></td>
                    <td class="form-inline"><input type="text" class="form-control" runat="server" id="txtNU" onkeypress="return isNumber(event)"></td>

                    <td class="form-inline text-right"><label class="frm-text"># of bldgs:</label></td>
                    <td class="form-inline"><input type="text" class="form-control" runat="server" id="txtNB" onkeypress="return isNumber(event)"></td>
            
                    <td class="form-inline text-right"><label class="frm-text"># of floors:</label></td>
                    <td class="form-inline"><input type="text" class="form-control" runat="server" id="txtNF" onkeypress="return isNumber(event)"></td>
                </tr>
                <tr>
                    <td class="form-inline text-right"><label class="frm-text">Site address 1:</label></td>
                    <td class="form-inline" colspan="3"><input type="text" class="form-control" runat="server" id="txtSA1" maxlength="50"></td>

                    <td class="form-inline text-right"><label class="frm-text">Site address 2:</label></td>
                    <td class="form-inline" colspan="3"><input type="text" class="form-control" runat="server" id="txtSA2" maxlength="50"></td>
                </tr>
                <tr>
                    <td class="form-inline text-right"><label class="frm-text">Site city:</label></td>
                    <td class="form-inline"><input type="text" class="form-control" runat="server" id="txtSC" maxlength="50"></td>

                    <td class="form-inline text-right"><label class="frm-text">Site state:</label></td>
                    <td class="form-inline"><select class="form-control" id="cboSS" runat="server"></select></td>

                    <td class="form-inline text-right"><label class="frm-text">Site zip:</label></td>
                    <td class="form-inline"><input type="text" class="form-control" runat="server" id="txtSZ" maxlength="15"></td>

                    <td colspan="2"></td>
                </tr>
                <tr><td colspan="8" class="text-left frm-text-blue-bold" style="background-color: #eeeeee"><i class="fa fa-chevron-circle-right" style="font-size: 18px"></i> Inputs</td></tr>
                <tr>
                    <td class="form-inline text-right"><label class="frm-text">Inspection date:</label></td>
                    <td class="form-inline"><input type="text" class="form-control" runat="server" id="txtID" placeholder="mm/dd/yyyy"></td>

                    <td class="form-inline text-right"><%= reserve.GenerateInfoBalloons.GetIcon(1,"Report Effective","green") %><label class="frm-text">Report effective:</label></td>
                    <td class="form-inline"><input type="text" class="form-control" runat="server" id="txtRE" placeholder="mm/dd/yyyy"></td>

                    <td class="form-inline text-right"><%= reserve.GenerateInfoBalloons.GetIcon(2,"Geo Factor","green") %><label class="frm-text">Geo. factor:</label></td>
                    <td class="form-inline" colspan="3"><input type="text" class="form-control" runat="server" id="txtGF" onkeypress="return isNumber(event)"><input id="txtHdnGF" type="hidden" runat="server" /></td>
                </tr>
                <tr>
                    <td class="form-inline text-right"><%= reserve.GenerateInfoBalloons.GetIcon(3,"Interest","green") %><label class="frm-text">Interest:</label></td>
                    <td class="form-inline"><input type="text" class="form-control" runat="server" id="txtInt" placeholder="0.00" onkeypress="return isNumber(event)"></td>

                    <td class="form-inline text-right"><%= reserve.GenerateInfoBalloons.GetIcon(4,"Inflation","green") %><label class="frm-text">Inflation:</label></td>
                    <td class="form-inline"><input type="text" class="form-control" runat="server" id="txtInf" placeholder="0.00" onkeypress="return isNumber(event)"></td>

                    <td colspan="4"></td>
                </tr>
                <tr><td colspan="8" class="text-left frm-text-blue-bold" style="background-color: #eeeeee"><i class="fa fa-chevron-circle-right" style="font-size: 18px"></i> Contact Information</td></tr>
                <tr>
                    <td class="form-inline text-right"><label class="frm-text">Contact prefix:</label></td>
                    <td class="form-inline"><select class="form-control" id="cboCP" runat="server"><option>Mr.</option><option>Ms.</option><option>Mrs.</option></select></td>

                    <td class="form-inline text-right"><label class="frm-text">Contact name:</label></td>
                    <td class="form-inline"><input type="text" class="form-control" runat="server" id="txtCN" maxlength="50"></td>

                    <td class="form-inline text-right"><label class="frm-text">Contact title:</label></td>
                    <td class="form-inline"><input type="text" class="form-control" runat="server" id="txtCT" maxlength="50"></td>

                    <td colspan="2"></td>
                </tr>
                <tr>
                    <td class="form-inline text-right text-nowrap"><label class="frm-text">Association name:</label></td>
                    <td class="form-inline" colspan="3"><input type="text" class="form-control" runat="server" id="txtCoN" maxlength="50"></td>

                    <td class="form-inline text-right"><label class="frm-text">Contact phone:</label></td>
                    <td class="form-inline"><input type="text" class="form-control" runat="server" id="txtCP" maxlength="25"></td>

                    <td class="form-inline text-right"><label class="frm-text">Contact email:</label></td>
                    <td class="form-inline"><input type="text" class="form-control" runat="server" id="txtCE" maxlength="50"></td>
                </tr>
                <tr>
                    <td class="frm-text text-left" style="padding: 0px; margin: 0px"></td>
                    <td colspan="7" class="frm-text text-left" style="padding: 0px; margin: 0px">
                        <input class="form-check-input" type="checkbox" value="" id="chkSS" onclick="SameAsSite(this)"><label class="frm-text" for="chkSS">Make Client Info the same as site info</label>
                    </td>
                </tr>
                <tr>
                    <td class="form-inline text-right"><label class="frm-text">Client address 1:</label></td>
                    <td class="form-inline" colspan="3"><input type="text" class="form-control" runat="server" id="txtClA1" maxlength="50"></td>

                    <td class="form-inline text-right"><label class="frm-text">Client address 2:</label></td>
                    <td class="form-inline" colspan="3"><input type="text" class="form-control" runat="server" id="txtClA2" maxlength="50"></td>

                </tr>
                <tr>
                    <td class="form-inline text-right"><label class="frm-text">Client city:</label></td>
                    <td class="form-inline"><input type="text" class="form-control" runat="server" id="txtClC" maxlength="50"></td>

                    <td class="form-inline text-right"><label class="frm-text">Client state:</label></td>
                    <td class="form-inline"><select class="form-control" id="cboCS" runat="server"></select></td>

                    <td class="form-inline text-right"><label class="frm-text">Client zip:</label></td>
                    <td class="form-inline"><input type="text" class="form-control" runat="server" id="txtClZ" maxlength="15"></td>
                </tr>
                <tr><td colspan="8" class="text-left frm-text-blue-bold" style="background-color: #eeeeee"><i class="fa fa-chevron-circle-right" style="font-size: 18px"></i> Financial Information</td></tr>
                <tr>
                    <td class="form-inline text-right text-nowrap"><%= reserve.GenerateInfoBalloons.GetIcon(5,"Begin Balance","green") %><label class="frm-text">Effective Date Beginning balance:</label></td>
                    <td class="form-inline"><input type="text" class="form-control" runat="server" id="txtBB" placeholder="0.00" onkeypress="return isNumber(event)"></td>
            
                    <td class="form-inline text-right"><%= reserve.GenerateInfoBalloons.GetIcon(6,"Current Contrib","green") %><label class="frm-text">Current contrib:</label></td>
                    <td class="form-inline"><input type="text" class="form-control" runat="server" id="txtCC" placeholder="0.00" onkeypress="return isNumber(event)"></td>
                </tr>
                <tr>
                    <td class="frm-text text-left" style="padding: 0px; margin: 0px"></td>
                    <td colspan="7" class="frm-text text-left" style="padding: 0px; margin: 0px">
                        <input class="form-check-input" type="checkbox" value="" id="chkSC" onclick="SameAsContact(this)"><label class="frm-text" for="chkSC">Make Source Info the same as contact info</label>
                    </td>
                </tr>
                <tr>
                    <td class="form-inline text-right"><label class="frm-text">Source prefix:</label></td>
                    <td class="form-inline"><select class="form-control" id="cboSP" runat="server"><option>Mr.</option><option>Ms.</option><option>Mrs.</option></select></td>

                    <td class="form-inline text-right"><label class="frm-text">Source name:</label></td>
                    <td class="form-inline"><input type="text" class="form-control" runat="server" id="txtSN" maxlength="50"></td>

                    <td class="form-inline text-right"><label class="frm-text">Source title:</label></td>
                    <td class="form-inline"><input type="text" class="form-control" runat="server" id="txtST" maxlength="50"></td>

                    <td class="form-inline text-right" id="tdSBB1"><label id="lblSBB" class="frm-text">Source begin bal:</label></td>
                    <td class="form-inline" id="tdSBB2"><input type="text" class="form-control" runat="server" id="txtSBB"></td>
                </tr>
                <tr id="trUpdate">
                    <td class="form-inline text-right"><label class="frm-text">Previous preparer:</label></td>
                    <td class="form-inline"><input type="text" class="form-control" runat="server" id="txtPP" maxlength="50"></td>

                    <td class="form-inline text-right"><label class="frm-text">Previous recomm. cont:</label></td>
                    <td class="form-inline"><input type="text" class="form-control" runat="server" id="txtPRC" placeholder="0.00" onkeypress="return isNumber(event)"></td>

                    <td class="form-inline text-right"><label class="frm-text">Prev study date:</label></td>
                    <td class="form-inline" colspan="3"><input type="text" class="form-control" runat="server" id="txtPSD" placeholder="mm/dd/yyyy"></td>
                </tr>
                <tr>
                    <td></td>
                    <td colspan="7" class="text-left">
                        <button type="submit" id="btnSave" class="btn btn-success">Save Project Info</button>
                        <span id="divSaveProject" class="frm-text" style="display: none; font-weight: 500;"><i class="fa fa-spinner fa-pulse fa-fw"></i>&nbsp;Saving, please wait...</span>
                        <label id="lblSaveStatus" class="frm-text-red" runat="server"></label>
                        <input type="hidden" id="txtHdnSave" runat="server" value="" />
                    </td>
                </tr>
            </tbody>
        </table>
        <% var iBalloonPage = "10"; %>
        <script>var iBalloonPage = <%= iBalloonPage %>;</script>
        <!-- #Include virtual="info_balloons.aspx" -->
    </div>
    <!--Modal: Clone Project-->
    <div class="modal fade" id="mdlNotes" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
      <div class="modal-dialog" role="document">
        <!--Content-->
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Clone Existing Project to New Project</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
              <!--Body-->
            <div class="modal-body mt-0 mb-0 p-0" style="margin-top: 0px">
                <div class="embed-responsive embed-responsive-16by9 z-depth-1-half">
                    <h5 class="text-left">Copy all current data from <b><%=txtProject.Value %></b> to:</h5>
                    <table>
                        <tr>
                            <td class="text-right frm-text-bold p3" style="padding: 3px !important">New Project ID:&nbsp;</td>
                            <td class="text-left"><input type="text" runat="server" class="form-control" id="txtClonePID" maxlength="15" size="50" placeholder="00000-00"></td>
                        </tr>
                        <tr>
                            <td class="text-right frm-text-bold">New Project Name:&nbsp;</td>
                            <td class="text-left"><input type="text" runat="server" class="form-control" id="txtClonePName" maxlength="100"></td>
                        </tr>
                        <tr style="height: 10px"><td colspan="2"></td></tr>
                        <tr>
                            <td></td>
                            <td class="text-left"><button type="button" id="btnClone" class="btn btn-success" onclick="checkClone()">Clone Project</button></td>
                        </tr>
                    </table>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
            </div>
        </div>
        <!--/.Content-->
      </div>
    </div>
    <!--Modal: Send to Client-->
    <div class="modal fade" id="mdlClient" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
      <div class="modal-dialog modal-dialog-scrollable" role="document">
        <!--Content-->
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Send Project to Client</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
              <!--Body-->
            <div class="modal-body mt-0 mb-0 p-0" style="margin-top: 0px">
                <table style="width: 100%; border-radius: 10px; background-color: #eeeeee">
                    <tr>
                        <td nowrap colspan="2" style="padding-left: 10px"><h5 class="text-left">Send <b><%=txtProject.Value %></b> to:</h5></td>
                    </tr>
                    <tr>
                        <td style="padding-left: 10px"><h5>Email: </h5></td>
                        <td style="padding-right: 10px"><input type="text" runat="server" class="form-control" id="txtS2CEMail" maxlength="100" style="width: 100% !important"></td>
                    </tr>
                    <tr>
                        <td></td>
                        <td>
                            <table style="width: 100%">
                                <tr style="background-color: #dddddd">
                                    <td class="frm-text-bold">#</td>
                                    <td class="frm-text-bold" style="text-align: left"></td>
                                    <td class="frm-text-bold" style="text-align: left">Name</td>
                                    <td class="frm-text-bold" style="text-align: left">Description</td>
                                    <td class="frm-text-bold" style="text-align: left">Created By</td>
                                    <td class="frm-text-bold" style="text-align: left">Created Date</td>
                                </tr>
                                <%
                                    var i = 0;
                                    var bgColor = "";

                                    SqlDataReader dr = reserve.Fn_enc.ExecuteReader("sp_app_manage_revisions @Param1, @Param2", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString() });

                                    while (dr.Read())
                                    {
                                %>
                                <tr>
                                    <td class="frm-text" onclick="toggleClientRev(<%=i %>)"><%=dr["revision_id"].ToString() %></td>
                                    <td>
                                        <input id="chkClientRev<%=i %>" name="chkClientRev<%=i %>" type="checkbox" <% if (dr["isthere"].ToString()=="1") { Response.Write("checked"); } %> />
                                        <input type="hidden" id="txtHdnClientRev<%=i %>" name="txtHdnClientRev<%=i %>" value="<%=dr["revision_id"].ToString() %>" />
                                    </td>
                                    <td class="frm-text" style="text-align: left; cursor: default" onclick="toggleClientRev(<%=i %>)"><%=dr["revision_name"].ToString() %></td>
                                    <td class="frm-text" style="text-align: left; cursor: default" onclick="toggleClientRev(<%=i %>)"><%=dr["revision_desc"].ToString() %></td>
                                    <td class="frm-text" style="text-align: left; cursor: default" onclick="toggleClientRev(<%=i %>)"><%=dr["created_by"].ToString() %></td>
                                    <td class="frm-text" style="text-align: left; cursor: default" onclick="toggleClientRev(<%=i %>)"><%=dr["revision_created_date"].ToString() %></td>
                                </tr>
                                <% 
                                i++;
                                }
                                dr.Close();
                                %>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td></td>
                        <td class="text-left" style="padding-bottom: 10px">
                            <button type="button" id="btnSendToClient" class="btn btn-success" onclick="checkSendToClient()">Create Client Login</button>
                        </td>
                    </tr>
                </table>
                <table style="width: 100%; border-top-left-radius: 10px; border-top-right-radius: 10px; background-color: #dddddd; margin-top: 10px">
                    <tr>
                        <td style="text-align: left; padding-top: 5px; padding-left: 2px" class="frm-text-bold">&nbsp;Previous client invitations:</td>
                    </tr>
                </table>
                <table style="width: 100%; border-radius: 10px; background-color: #dddddd">
                    <tr style="padding: 5px; background-color: #eeeeee; text-align: left" class="frm-text-bold">
                        <td style="padding-left: 5px; padding-top: 3px; padding-bottom: 3px">Username</td>
                        <td>Date Sent</td>
                        <td>Sent By</td>
                        <td># Logins</td>
                        <td>Last Login</td>
                    </tr>
                    <%
                    dr = reserve.Fn_enc.ExecuteReader("select i.client_email, i.project_id, i.invite_sent, au.first_name + ' ' + au.last_name as sent_by, i.num_logins, i.last_login from info_projects_client_invites i left join app_users au on i.firm_id=au.firm_id and i.invited_by=au.user_id where i.firm_id=@Param1 and i.project_id=@Param2 order by i.invite_sent desc", new string[] { Session["firmid"].ToString(), $"C{Session["projectid"].ToString()}" });
                    while (dr.Read())
                    {
                        if (i % 2 == 0) 
                        { 
                            bgColor = "#eeeeee";
                        } 
                        else 
                        { 
                            bgColor = "#f9f9f9";
                        }

                    %>
                    <tr style="background-color: <%=bgColor%>; text-align: left" class="frm-text">
                        <td style="padding-top: 3px; padding-bottom: 3px; padding-left: 5px"><%=dr["client_email"] %></td>
                        <td><%=dr["invite_sent"] %></td>
                        <td><%=dr["sent_by"] %></td>
                        <td><%=dr["num_logins"] %></td>
                        <td><%=dr["last_login"] %></td>
                    </tr>
                    <% 
                            i++;
                        }
                        dr.Close();
                    %>
                </table>
                <table style="width: 100%; border-radius: 10px; background-color: #009CDC; margin-top: 10px">
                    <tr>
                        <td style="text-align: left; padding-top: 5px; padding-left: 2px; color: white" class="frm-text">
                            Login information for all recipients is:<br /><br />
                            - Url: https://reservestudyplus.com/default.aspx?c=1<br />
                            - Username: {client email address}<br />
                            - Password: C<%=Session["projectid"].ToString() %>
                        </td>
                    </tr>
                </table>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
            </div>
        </div>
        <!--/.Content-->
      </div>
    </div>
    <!--Modal: Create new revision-->
    <div class="modal fade" id="mdlNewRevision" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
      <div class="modal-dialog" role="document">
        <!--Content-->
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Create New Revision</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
              <!--Body-->
            <div class="modal-body mt-0 mb-0 p-0" style="margin-top: 0px">
                <div class="embed-responsive embed-responsive-16by9 z-depth-1-half">
                    <table style="width: 100%">
                        <tr>
                            <td valign="top" width="1%"><h5 class="text-right">Revision Name:&nbsp;</h5></td>
                            <td><input type="text" id="txtRevisionName" name="txtRevisionName" runat="server" class="form-control" style="width: 100% !important"></td>
                        </tr>
                        <tr>
                            <td valign="top" width="1%"><h5 class="text-right">Revision Description:&nbsp;</h5></td>
                            <td><textarea runat="server" class="form-control" id="txtRevisionDesc" name="txtRevisionDesc" rows="8" style="width: 100% !important"></textarea></td>
                        </tr>
                        <tr>
                            <td></td>
                            <td class="text-left">
                                <button type="button" id="btnSaveNewRevision" class="btn btn-success" onclick="confirmNewRevision()">Create Revision</button>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
            </div>
        </div>
        <!--/.Content-->
      </div>
    </div>
        <!--Modal: Manage Existing Revisions -->
    <div class="modal fade" id="mdlManageRevisions" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
      <div class="modal-dialog" role="document">
        <!--Content-->
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Manage Existing Revisions</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
              <!--Body-->
            <div class="modal-body mt-0 mb-0 p-0" style="margin-top: 0px">
                <div class="embed-responsive embed-responsive-16by9 z-depth-1-half">
                    <table style="width: 100%">
                        <tr style="background-color: #dddddd">
                            <td class="frm-text-bold">#</td>
                            <td class="frm-text-bold" style="text-align: left">Client</td>
                            <td class="frm-text-bold" style="text-align: left">Name</td>
                            <td class="frm-text-bold" style="text-align: left">Description</td>
                            <td class="frm-text-bold" style="text-align: left">Created By</td>
                            <td class="frm-text-bold" style="text-align: left">Created Date</td>
                            <td></td>
                        </tr>
                        <%
                            dr = reserve.Fn_enc.ExecuteReader("sp_app_manage_revisions @Param1, @Param2", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString() });
                            i = 0;
                            while (dr.Read())
                            {
                                if (i % 2 == 0)
                                {
                                    bgColor = "#eeeeee";
                                }
                                else
                                {
                                    bgColor = "#f9f9f9";
                                }
                        %>
                        <tr id="trRev<%=i %>" style="background-color:<%=bgColor%>">
                            <td class="frm-text" onclick="toggleChkRev(<%=i %>)"><%=dr["revision_id"].ToString() %></td>
                            <td>
                                <input id="chkRev<%=i %>" type="checkbox" <% if (dr["isthere"].ToString()=="1") { Response.Write("checked"); } %> />
                                <input type="hidden" id="txtHdnChkRev<%=i %>" name="txtHdnChkRev<%=i %>" value="<%=dr["revision_id"].ToString() %>" />
                            </td>
                            <td class="frm-text" style="text-align: left; cursor: default" onclick="toggleChkRev(<%=i %>)"><%=dr["revision_name"].ToString() %></td>
                            <td class="frm-text" style="text-align: left; cursor: default" onclick="toggleChkRev(<%=i %>)"><%=dr["revision_desc"].ToString() %></td>
                            <td class="frm-text" style="text-align: left; cursor: default" onclick="toggleChkRev(<%=i %>)"><%=dr["created_by"].ToString() %></td>
                            <td class="frm-text" style="text-align: left; cursor: default" onclick="toggleChkRev(<%=i %>)"><%=dr["revision_created_date"].ToString() %></td>
                            <td style="text-align: right; cursor: pointer"><img src="images/x_white.jpg" style="font-size: 0; display: inline-block" onclick="checkDelRev(<%=i %>)" /></td>
                        </tr>
                        <% 
                            i++;
                            }
                            dr.Close();
                            %>
                    </table>
                    <input type="hidden" id="txtHdnTotalRevs" name="txtHdnTotalRevs" value="<%=i %>" />
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" id="btnSaveClientRevisions" class="btn btn-success" onclick="sendAvailableRevs()">Make Available to Client</button>
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button><br />
                <label id="lblRevStatus" name="lblRevStatus" style="color: red"></label>
            </div>
        </div>
        <!--/.Content-->
      </div>
    </div>
    <script>
        var iCurComp = -1;
        $(document).ready(function() {
            $(".showClone").click(function (e) {
                e.preventDefault();
                $("#mdlNotes").modal("show");
            });
            $(".showSendToClient").click(function (e) {
                e.preventDefault();
                $("#mdlClient").modal("show");
            });
            $(".showNewRevision").click(function (e) {
                e.preventDefault();
                $("#mdlRevision").modal("show");
            });
            $(".showManageRevisions").click(function (e) {
                e.preventDefault();
                $("#mdlManageRevisions").modal("show");
            });
        });
    </script>
    <input type="hidden" id="txtHdnType" name="txtHdnType" runat="server" />
    <input type="hidden" id="txtHdnGenClientData" name="txtHdnGenClientData" runat="server" />
</form>  

<script>
    toggleReqd();

    $(function () {
        $("#MainContent_txtID").datepicker();
        $("#MainContent_txtRE").datepicker();
        $("#MainContent_txtPSD").datepicker();

        $('#MainContent_cmdSaveBalloonText').on('click', function () {
            alert("hi");
        });

        window.addEventListener('load', function() {
            // Fetch all the forms we want to apply custom Bootstrap validation styles to
            var forms = document.getElementsByClassName('needs-validation');
            // Loop over them and prevent submission
            var validation = Array.prototype.filter.call(forms, function(form) {
              form.addEventListener('submit', function(event) {
                if (form.checkValidity() === false) {
                  event.preventDefault();
                  event.stopPropagation();
                  }
                  $("#MainContent_txtHdnSave").val('Save');
                  $("#divSaveProject").show();
                  $("btnSave").prop("disabled", true);
                  form.classList.add('was-validated');
                }, false);
            });
        }, false);

        initItemsChanged();
    });
</script>
</asp:Content>
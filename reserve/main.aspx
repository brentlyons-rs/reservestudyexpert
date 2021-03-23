﻿<%@ Page Language="C#" AutoEventWireup="true" MasterPageFile="~/Main.Master"  CodeBehind="main.aspx.cs" Inherits="reserve.main" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

<script src="https://ajax.aspnetcdn.com/ajax/jquery/jquery-1.8.0.js"></script>
<script src="https://ajax.aspnetcdn.com/ajax/jquery.ui/1.8.22/jquery-ui.js"></script>
<script src="assets/js/jquery.mask.min.js"></script>
<link href="https://ajax.aspnetcdn.com/ajax/jquery.ui/1.8.10/themes/redmond/jquery-ui.css" rel="stylesheet" />
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
                document.getElementById('MainContent_txtPP').value = '';
                document.getElementById('MainContent_txtPRC').value = '';
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
            document.getElementById('MainContent_txtHdnType').value = 'SendToClient';
            document.getElementById('MainContent_divCloneStatus').innerHTML = 'Sending to client, please wait...';
            document.forms[0].submit();
        }
    </script>  

<form id="frmProject" runat="server" class="needs-validation">
    <div class="container_fluid" style="max-width: 100%">
        <div class="row float-right" style="margin-top: -4px; margin-left: -2px;">
            <div class="page-top-tab col-lg-3 float-right">
                <p class="panel-title-fd">Input page for Reserve Study: <label id="lblProject" runat="server" class="frm-text"></label></p>
            </div>
        </div>
        <div class="input-group text-left col-lg-5 text-nowrap rounded-lg shadow form-inline" id="divProjManip" runat="server" style="margin-bottom: 5px; padding: 0px; margin-top: 3px">
            <input type="text" ID="txtProject" runat="server" class="form-control" placeholder="Search for an existing project" />  
            <asp:HiddenField ID="txtHdnProject" runat="server" Value="-1" />
            <input type="hidden" id="txtHdnSelected" runat="server" />
            &nbsp;or&nbsp;
            <button type="button" class="btn btn-primary" onclick="NewProj()">Create new project</button>
            <% if (txtHdnProject.Value != "-1") { %>
            &nbsp;<a href="#" class="btn btn-primary showModal" id="cmdLogin" data-toggle="modal" data-target="#mdlNotes" data-cat="catg" data-comp="dcmp">Clone Project</a>
            &nbsp;<a href="#" class="btn btn-primary showSendToClient" id="cmdSendToClient" data-toggle="modal" data-target="#mdlClient" data-cat="catg" data-comp="dcmp">Send to Client</a>
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
                    <td class="form-inline text-right"><label class="frm-text-bold">Age of community:</label></td>
                    <td class="form-inline"><input type="text" class="form-control" runat="server" id="txtAoC" required onkeypress="return isNumber(event)"></td>

                    <td class="form-inline text-right"><label class="frm-text-bold"># of units:</label></td>
                    <td class="form-inline"><input type="text" class="form-control" runat="server" id="txtNU" required onkeypress="return isNumber(event)"></td>

                    <td class="form-inline text-right"><label class="frm-text-bold"># of bldgs:</label></td>
                    <td class="form-inline"><input type="text" class="form-control" runat="server" id="txtNB" required onkeypress="return isNumber(event)"></td>
            
                    <td class="form-inline text-right"><label class="frm-text-bold"># of floors:</label></td>
                    <td class="form-inline"><input type="text" class="form-control" runat="server" id="txtNF" required onkeypress="return isNumber(event)"></td>
                </tr>
                <tr>
                    <td class="form-inline text-right"><label class="frm-text-bold">Site address 1:</label></td>
                    <td class="form-inline" colspan="3"><input type="text" class="form-control" runat="server" id="txtSA1" maxlength="50" required></td>

                    <td class="form-inline text-right"><label class="frm-text">Site address 2:</label></td>
                    <td class="form-inline" colspan="3"><input type="text" class="form-control" runat="server" id="txtSA2" maxlength="50"></td>
                </tr>
                <tr>
                    <td class="form-inline text-right"><label class="frm-text-bold">Site city:</label></td>
                    <td class="form-inline"><input type="text" class="form-control" runat="server" id="txtSC" maxlength="50" required></td>

                    <td class="form-inline text-right"><label class="frm-text-bold">Site state:</label></td>
                    <td class="form-inline"><select class="form-control" id="cboSS" runat="server" required></select></td>

                    <td class="form-inline text-right"><label class="frm-text-bold">Site zip:</label></td>
                    <td class="form-inline"><input type="text" class="form-control" runat="server" id="txtSZ" maxlength="15" required></td>

                    <td colspan="2"></td>
                </tr>
                <tr><td colspan="8" class="text-left frm-text-blue-bold" style="background-color: #eeeeee"><i class="fa fa-chevron-circle-right" style="font-size: 18px"></i> Inputs</td></tr>
                <tr>
                    <td class="form-inline text-right"><label class="frm-text-bold">Inspection date:</label></td>
                    <td class="form-inline"><input type="text" class="form-control" runat="server" id="txtID" placeholder="mm/dd/yyyy" required></td>

                    <td class="form-inline text-right"><label class="frm-text-bold">Report effective:</label></td>
                    <td class="form-inline"><input type="text" class="form-control" runat="server" id="txtRE" placeholder="mm/dd/yyyy" required></td>

                    <td class="form-inline text-right"><label class="frm-text-bold">Geo. factor:</label></td>
                    <td class="form-inline" colspan="3"><input type="text" class="form-control" runat="server" id="txtGF" required onkeypress="return isNumber(event)"></td>
                </tr>
                <tr>
                    <td class="form-inline text-right"><label class="frm-text">Interest:</label></td>
                    <td class="form-inline"><input type="text" class="form-control" runat="server" id="txtInt" placeholder="0.00" onkeypress="return isNumber(event)"></td>

                    <td class="form-inline text-right"><label class="frm-text">Inflation:</label></td>
                    <td class="form-inline"><input type="text" class="form-control" runat="server" id="txtInf" placeholder="0.00" onkeypress="return isNumber(event)"></td>

                    <td colspan="4"></td>
                </tr>
                <tr><td colspan="8" class="text-left frm-text-blue-bold" style="background-color: #eeeeee"><i class="fa fa-chevron-circle-right" style="font-size: 18px"></i> Contact Information</td></tr>
                <tr>
                    <td class="form-inline text-right"><label class="frm-text-bold">Contact prefix:</label></td>
                    <td class="form-inline"><select class="form-control" id="cboCP" runat="server" required><option>Mr.</option><option>Ms.</option><option>Mrs.</option></select></td>

                    <td class="form-inline text-right"><label class="frm-text-bold">Contact name:</label></td>
                    <td class="form-inline"><input type="text" class="form-control" runat="server" id="txtCN" maxlength="50" required></td>

                    <td class="form-inline text-right"><label class="frm-text-bold">Contact title:</label></td>
                    <td class="form-inline"><input type="text" class="form-control" runat="server" id="txtCT" maxlength="50" required></td>

                    <td colspan="2"></td>
                </tr>
                <tr>
                    <td class="form-inline text-right text-nowrap"><label class="frm-text-bold">Association name:</label></td>
                    <td class="form-inline" colspan="3"><input type="text" class="form-control" runat="server" id="txtCoN" maxlength="50" required></td>

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
                    <td class="form-inline text-right"><label class="frm-text-bold">Client address 1:</label></td>
                    <td class="form-inline" colspan="3"><input type="text" class="form-control" runat="server" id="txtClA1" maxlength="50" required></td>

                    <td class="form-inline text-right"><label class="frm-text">Client address 2:</label></td>
                    <td class="form-inline" colspan="3"><input type="text" class="form-control" runat="server" id="txtClA2" maxlength="50"></td>

                </tr>
                <tr>
                    <td class="form-inline text-right"><label class="frm-text-bold">Client city:</label></td>
                    <td class="form-inline"><input type="text" class="form-control" runat="server" id="txtClC" maxlength="50" required></td>

                    <td class="form-inline text-right"><label class="frm-text-bold">Client state:</label></td>
                    <td class="form-inline"><select class="form-control" id="cboCS" runat="server" required></select></td>

                    <td class="form-inline text-right"><label class="frm-text-bold">Client zip:</label></td>
                    <td class="form-inline"><input type="text" class="form-control" runat="server" id="txtClZ" maxlength="15" required></td>
                </tr>
                <tr><td colspan="8" class="text-left frm-text-blue-bold" style="background-color: #eeeeee"><i class="fa fa-chevron-circle-right" style="font-size: 18px"></i> Financial Information</td></tr>
                <tr>
                    <td class="form-inline text-right text-nowrap"><label class="frm-text-bold">Effective Date Beginning balance:</label></td>
                    <td class="form-inline"><input type="text" class="form-control" runat="server" id="txtBB" placeholder="0.00" required onkeypress="return isNumber(event)"></td>
            
                    <td class="form-inline text-right"><label class="frm-text-bold">Current contrib:</label></td>
                    <td class="form-inline"><input type="text" class="form-control" runat="server" id="txtCC" placeholder="0.00" required onkeypress="return isNumber(event)"></td>
                </tr>
                <tr>
                    <td class="frm-text text-left" style="padding: 0px; margin: 0px"></td>
                    <td colspan="7" class="frm-text text-left" style="padding: 0px; margin: 0px">
                        <input class="form-check-input" type="checkbox" value="" id="chkSC" onclick="SameAsContact(this)"><label class="frm-text" for="chkSC">Make Source Info the same as contact info</label>
                    </td>
                </tr>
                <tr>
                    <td class="form-inline text-right"><label class="frm-text-bold">Source prefix:</label></td>
                    <td class="form-inline"><select class="form-control" id="cboSP" runat="server" required><option>Mr.</option><option>Ms.</option><option>Mrs.</option></select></td>

                    <td class="form-inline text-right"><label class="frm-text-bold">Source name:</label></td>
                    <td class="form-inline"><input type="text" class="form-control" runat="server" id="txtSN" maxlength="50" required></td>

                    <td class="form-inline text-right"><label class="frm-text-bold">Source title:</label></td>
                    <td class="form-inline"><input type="text" class="form-control" runat="server" id="txtST" maxlength="50" required></td>

                    <td class="form-inline text-right" id="tdSBB1"><label id="lblSBB" class="frm-text">Source begin bal:</label></td>
                    <td class="form-inline" id="tdSBB2"><input type="text" class="form-control" runat="server" id="txtSBB"></td>
                </tr>
                <tr id="trUpdate">
                    <td class="form-inline text-right"><label class="frm-text-bold">Previous preparer:</label></td>
                    <td class="form-inline"><input type="text" class="form-control" runat="server" id="txtPP" maxlength="50" required></td>

                    <td class="form-inline text-right"><label class="frm-text-bold">Previous recomm. cont:</label></td>
                    <td class="form-inline"><input type="text" class="form-control" runat="server" id="txtPRC" placeholder="0.00" required onkeypress="return isNumber(event)"></td>

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
    </div>
    <!--Modal: Name-->
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
      <div class="modal-dialog" role="document">
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
                <div class="embed-responsive embed-responsive-16by9 z-depth-1-half">
                    <table style="width: 100%">
                        <tr>
                            <td nowrap colspan="2"><h5 class="text-left">Send <b><%=txtProject.Value %></b> to:</h5></td>
                        </tr>
                        <tr>
                            <td><h5>Email: </h5></td>
                            <td><input type="text" runat="server" class="form-control" id="txtS2CEMail" maxlength="100" style="width: 100% !important"></td>
                        </tr>
                        <tr>
                            <td></td>
                            <td class="text-left">
                                <button type="button" id="btnSendToClient" class="btn btn-success" onclick="checkSendToClient()">Send to Client</button>
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
    <script>
        var iCurComp = -1;
        $(document).ready(function() {
            $(".showModal").click(function (e) {
                e.preventDefault();
                $("#mdlNotes").modal("show");
            });
            $(".showSendToClient").click(function (e) {
                e.preventDefault();
                $("#mdlClient").modal("show");
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
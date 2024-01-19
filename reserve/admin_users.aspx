<%@ Page Language="C#" MasterPageFile="~/Main.Master" AutoEventWireup="true" CodeBehind="admin_users.aspx.cs" Inherits="reserve.admin_users" %>
<asp:Content ID="Content1" runat="server" ContentPlaceHolderID="MainContent">
<link href="css/style.css" rel="stylesheet" />
<style>
    body { line-height: 20px !important; }
    iframe { display:block; }
    .tblUsers {
        margin-top: 5px; 
        margin-left: 5px;
        border-radius: 10px;
        padding: 10px;
        background-color: #eeeeee;
        vertical-align: top;
    }
</style>
<script>
    function CheckStrength() {
        var iCap = 0; iNum = 0; iStrength = 0;
        var i;
        var s = new String();
        s = document.forms[0].MainContent_txtNewPW.value;
        if (s.length > 0) {
            document.getElementById('trStrength').style.display = 'block';
            for (i = 0; i < s.length; i++) {
                if ((s.charCodeAt(i) > 64) && (s.charCodeAt(i) < 91)) { //Capital letter
                    iCap = 1;
                }
                if ((s.charCodeAt(i) > 47) && (s.charCodeAt(i) < 58)) {
                    iNum = 1;
                }
            }
            if (iCap == 0) {
                document.images['imgCap'].src = 'images/x_white.jpg';
            }
            else {
                document.images['imgCap'].src = 'images/check_white.jpg';
                iStrength++;
            }
            if (iNum == 0) {
                document.images['imgNum'].src = 'images/x_white.jpg';
            }
            else {
                document.images['imgNum'].src = 'images/check_white.jpg';
                iStrength++;
            }
            //Length
            if (s.length < 8) {
                document.images['imgLen'].src = 'images/x_white.jpg';
            }
            else {
                document.images['imgLen'].src = 'images/check_white.jpg';
                iStrength++;
            }
            if (document.forms[0].MainContent_txtNewPW.value == document.forms[0].MainContent_txtConfirmPW.value) {
                document.images['imgCnf'].src = 'images/check_white.jpg';
                iStrength++;
            }
            else {
                document.images['imgCnf'].src = 'images/x_white.jpg';
            }
            //Ensable-disable save button
            if ((iStrength == 4) || ((document.forms[0].MainContent_txtNewPW.value == '') && (document.forms[0].MainContent_txtConfirmPW.value == ''))) {
                document.forms[0].MainContent_cmdSave.disabled = false;
                //document.getElementById('MainContent_cmdSave').className = 'input_button_green';
            }
            else {
                document.forms[0].MainContent_cmdSave.disabled = true;
                //document.getElementById('MainContent_cmdSave').className = 'input_button_grey';
            }
        }
        else {
            trStrength.style.display = 'none';
            if (document.forms[0].MainContent_lstUsers.options[document.forms[0].MainContent_lstUsers.selectedIndex].value == -1) {
                document.forms[0].MainContent_cmdSave.disabled = true;
                //document.getElementById('MainContent_cmdSave').className = 'input_button_grey';
            }
            else {
                document.forms[0].MainContent_cmdSave.disabled = false;
                //document.getElementById('MainContent_cmdSave').className = 'input_button_green';
            }
        }
    }

    function CheckSaveGen() {
        if (document.forms[0].MainContent_txtFN.value == '') {
            alert("Please enter the user's first name.")
            document.forms[0].MainContent_txtFN.focus();
            return false;
        }
        if (document.forms[0].MainContent_txtLN.value == '') {
            alert("Please enter the user's last name.")
            document.forms[0].MainContent_txtLN.focus();
            return false;
        }
        if (document.forms[0].MainContent_txtEM.value == '') {
            alert("Please enter the user's email address.")
            document.forms[0].MainContent_txtEM.focus();
            return false;
        }
        document.getElementById('MainContent_txtHdnOp').value = 'SaveGen';
        //document.getElementById('MainContent_txtHdnOp').value = 'SaveGen';
        document.forms[0].submit();
        return true;
    }
</script>
<form id="frmUsers" name="frmUsers" method="POST" action="admin_users.aspx" runat="server" autocomplete="off">
<div class="container_fluid" style="width: 100%; max-width: 100%">
    <div class="row float-right" style="margin-top: -4px; margin-left: -2px;">
        <div class="page-top-tab-project col-lg-3 float-right">
            <p class="panel-title-fd">Admin | User Administration</p>
        </div>
    </div>
</div>
<table class="tblUsers">
    <tr>
        <td class="tblUsers">
            <select id="lstUsers" name="lstUsers" runat="server" size=44 style="font-size: 8pt" onchange="document.getElementById('MainContent_txtHdnOp').value='Users'; document.forms[0].submit()"></select>
        </td>
        <td class="tblUsers">
            <div id="divInfo" runat="server">
                <table border="0">
                    <tr><td colspan="4" class="text-left frm-text-blue-bold" style="background-color: #dddddd; padding: 5px"><i class="fa fa-chevron-circle-right" style="font-size: 18px"></i> General Information</td></tr>
                    <tr><td colspan="4" style="height: 10px"></td></tr>
                    <tr>
                        <td class="frm-text-bold" style="text-align: right">First Name:&nbsp;</td>
                        <td><input type="text" id="txtFN" name="txtFN" runat="server" class="form-control" /></td>
                        <td class="frm-text-bold" style="text-align: right; padding-left: 10px">Last Name:&nbsp;</td>
                        <td><input type="text" id="txtLN" name="txtLN" runat="server" class="form-control" /></td>
                    </tr>
                    <tr>
                        <td class="frm-text-bold" style="text-align: right">EMail:&nbsp;</td>
                        <td><input type="text" id="txtEM" name="txtEM" runat="server" class="form-control" /></td>
                        <td class="frm-text">
                            <input type=checkbox runat="server" id="chkDis" name="chkDis" />
                            <label id="lblDis" for="MainContent_chkDis">Disabled</label>
                        </td>
                    </tr>
                    <tr>
                        <td></td>
                        <td colspan="3" class="frm-text" style="text-align: left">
                            <input type="checkbox" runat="server" id="chkAdmin" name="chkAdmin" />
                            <label id="lblAdmin" for="MainContent_chkAdmin">Admin</label>
                        </td>
                    </tr>
                    <tr><td colspan="4" class="text-left frm-text-blue-bold" style="background-color: #dddddd; padding: 5px"><i class="fa fa-chevron-circle-right" style="font-size: 18px"></i> Password <label id="divNewPW" class="frm-text-bold" runat="server"></label></td></tr>
                    <tr><td colspan="4" style="height: 10px"></td></tr>
                    <tr>
                        <td class="frm-text" style="text-align: right">New password: </td>
                        <td><input type="password" runat="server" id="txtNewPW" name="txtNewPW" class="form-control" onkeyup="CheckStrength()" autocomplete="new-password" /></td>
                        <td colspan="2"></td>
                    </tr>
                    <tr>
                        <td class="frm-text">Confirm new password: </td>
                        <td><input type="password" runat="server" id="txtConfirmPW" name="txtConfirmPW" class="form-control" onkeyup="CheckStrength()" autocomplete="new-password" /></td>
                        <td colspan="2"></td>
                    </tr>
                    <tr>
                        <td></td>
                        <td colspan="2">
                            <div id="trStrength" style="display: none">
                                <table style="border-radius: 10px; background-color: #dddddd">
                                    <tr>
                                        <td valign=top align=right style="padding: 3px"><div class=gridcol>Password Strength:</div></td>
                                        <td>
                                            <table style="padding: 10px">
                                                <tr>
                                                    <td><img src="images/x_white.jpg" id="imgCap" /></td>
                                                    <td style="text-align: left"><div class=gridcol>Capital Letter</div></td>
                                                </tr>
                                                <tr>
                                                    <td><img src="images/x_white.jpg" id="imgNum" /></td>
                                                    <td style="text-align: left"><div class=gridcol>Number</div></td>
                                                </tr>
                                                <tr>
                                                    <td><img src="images/x_white.jpg" id="imgLen" /></td>
                                                    <td style="text-align: left"><div class=gridcol>8 Characters</div></td>
                                                </tr>
                                                <tr>
                                                    <td><img src="images/x_white.jpg" id="imgCnf" /></td>
                                                    <td style="text-align: left; padding-right: 3px"><div class=gridcol>Confirm New Password</div></td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <td></td>
                        <td colspan="3" style="text-align: left">
                            <asp:Button runat="server" ID="cmdSave" CssClass="btn btn-success" Text="Save Information" CausesValidation="false" />
                            <label runat="server" id="lblStatus" name="lblStatus" class="gridcol_red"></label>
                        </td>
                    </tr>
                </table>
            </div>
        </td>
    </tr>
</table>
<input type="hidden" runat="server" id="txtHdnOp" name="txtHdnOp" />
</form>
</asp:Content>

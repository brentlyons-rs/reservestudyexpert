<%@ Language="C#" AutoEventWireup="true" MasterPageFile="~/Site.Master" CodeBehind="admin_users.aspx.cs" Inherits="reserve.admin_users" %>
<asp:Content ID="Content1" runat="server" ContentPlaceHolderID="MainContent">
<script src="scripts/masked_input_1.3.js" type="text/javascript"></script>
<script type="javascript">
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
                document.getElementById('MainContent_cmdSave').className = 'input_button_green';
            }
            else {
                document.forms[0].MainContent_cmdSave.disabled = true;
                document.getElementById('MainContent_cmdSave').className = 'input_button_grey';
            }
        }
        else {
            trStrength.style.display = 'none';
            if (document.forms[0].MainContent_lstUsers.options[document.forms[0].MainContent_lstUsers.selectedIndex].value == -1) {
                document.forms[0].MainContent_cmdSave.disabled = true;
                document.getElementById('MainContent_cmdSave').className = 'input_button_grey';
            }
            else {
                document.forms[0].MainContent_cmdSave.disabled = false;
                document.getElementById('MainContent_cmdSave').className = 'input_button_green';
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
<LINK rel="stylesheet" type="text/css" href="styles/Site.css">
<form id="frmUsers" name="frmUsers" method="POST" action="admin_users.aspx" runat="server">
Administrative Area: 
<select id="cboAArea" name="cboAArea" style="font-size: 8pt" onchange="window.location=this.options[this.selectedIndex].value">
    <option selected>User Maintenance</option>
    <option value="admin_batches.aspx">Batch Deletion</option>
</select>
<table border=0 cellpadding=2 cellspacing=1 bgcolor=#ffffff>
    <tr>
        <td bgcolor=#eeeeee valign=top>
            <select id="lstUsers" name="lstUsers" runat="server" size=44 style="font-size: 8pt" onchange="document.getElementById('MainContent_txtHdnOp').value='Users'; document.forms[0].submit()"></select>
        </td>
        <td bgcolor=#eeeeee valign=top>
            <div id="divInfo" runat="server">
                <table border=0 cellspacing=1 cellpadding=2>
                    <tr>
                        <td colspan=6>
                            <font class=gridcol_blue><i>General Information</i></font>
                        </td>
                    </tr>
                    <tr>
                        <asp:TextBox ID="txtTest" runat="server" />
                        <td bgcolor=#eeeeee><font class=gridcol_bold>First Name:</font></td>
                        <td><input type="text" id="txtFN" name="txtFN" runat="server" style="font-size: 8pt"/></td>
                        <td bgcolor=#eeeeee><font class=gridcol_bold>Last Name:</font></td>
                        <td><input type="text" id="txtLN" name="txtLN" runat="server" style="font-size: 8pt"/></td>
                        <td bgcolor=#eeeeee><font class=gridcol_bold>EMail:</font></td>
                        <td><input type="text" id="txtEM" name="txtEM" runat="server" style="font-size: 8pt"/></td>
                    </tr>
                    <tr>
                        <td bgcolor=#eeeeee><font class=gridcol></font></td>
                        <td colspan=5>
                            <input type=checkbox runat="server" id="chkDis" name="chkDis" />
                            <label id="lblDis" name="lblDis" class=gridcol for="MainContent_chkDis">Disabled</label>
                        </td>
                    </tr>
                </table>
                <table border="0" cellpadding="0" cellspacing="0">
                    <tr>
                        <td valign="top">
                            <table border=0 cellpadding=2 cellspacing=1>
                                <tr>
                                    <td bgcolor=#eeeeee align=right nowrap><div class=gridcol>New password: </div></td>
                                    <td bgcolor=#eeeeee><input type=password runat="server" id="txtNewPW" name="txtNewPW" onkeyup="CheckStrength()" /></td>
                                </tr>
                                <tr>
                                    <td bgcolor=#eeeeee align=right nowrap><div class=gridcol>Confirm new password: </div></td>
                                    <td bgcolor=#eeeeee><input type=password runat="server" id="txtConfirmPW" name="txtConfirmPW" onkeyup="CheckStrength()" /></td>
                                </tr>
                                <tr>
                                    <td colspan=2>
                                        <input type=checkbox runat="server" id="chkFPWR" name="chkFPWR" />
                                        <label id="lblFPWR" name="lblFPWR" for="MainContent_chkFPWR" class=gridcol>Force user to reset password on next login</label>
                                    </td>
                                </tr>
                                <tr>
                                    <td bgcolor=#eeeeee colspan=2 align=right>
                                        <asp:Button runat="server" ID="cmdSave" CssClass="input_button_green" Text="Save Information" CausesValidation="false" />
                                        <label runat="server" id="lblStatus" name="lblStatus" class="gridcol_red"></label>
                                    </td>
                                </tr>
                            </table>
                            <div id="trStrength" style="display: none">
                                <table border=0 cellspacing=0 cellpadding=0>
                                    <tr>
                                        <td bgcolor=#ffffff valign=top align=right><div class=gridcol>Password Strength:</div></td>
                                        <td bgcolor=#ffffff>
                                            <table border=0 cellpadding=1 cellspacing=0>
                                                <tr>
                                                    <td><img src="images/x_white.jpg" id="imgCap" /></td>
                                                    <td><div class=gridcol>Capital Letter</div></td>
                                                </tr>
                                                <tr>
                                                    <td><img src="images/x_white.jpg" id="imgNum" /></td>
                                                    <td><div class=gridcol>Number</div></td>
                                                </tr>
                                                <tr>
                                                    <td><img src="images/x_white.jpg" id="imgLen" /></td>
                                                    <td><div class=gridcol>8 Characters</div></td>
                                                </tr>
                                                <tr>
                                                    <td><img src="images/x_white.jpg" id="imgCnf" /></td>
                                                    <td><div class=gridcol>Confirm New Password</div></td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                            <% //If lstUsers.SelectedIndex > 0 Then %>
                            <font class=gridcol_blue><i>Roles</i></font><br />
                            <select id="lstRoles" name="lstRoles" style="font-size: 8pt" runat="server" size="5" multiple>
                            </select><br />
                            <input type="button" class="input_button_green" value="Save Roles" onclick="document.getElementById('MainContent_txtHdnOp').value = 'SaveRoles'; document.forms[0].submit()" />
                            <label id="lblRoles" name="lblRoles" runat="server" style="color: red"></label>
                            <% //end If %>
                        </td>
                        <td valign=top>
                            <div id="divNewPW" runat="server"></div>
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

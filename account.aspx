<%@ Language="C#" AutoEventWireup="true" MasterPageFile="~/Site.Master" CodeBehind="account.aspx.cs" Inherits="reserve.account" %>
<asp:Content ID="Content1" runat="server" ContentPlaceHolderID="MainContent">
<html>
<body>
<script language=javascript>
    function CheckStrength() {
        var iCap = 0; iNum = 0; iStrength = 0;
        var i;
        var s = new String();
        s = document.forms[0].MainContent_txtNew.value;
        if (s.length > 0) {
            trStrength.style.display = 'block';
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
            if (document.forms[0].MainContent_txtNew.value == document.forms[0].MainContent_txtConfirm.value) {
                document.images['imgCnf'].src = 'images/check_white.jpg';
                iStrength++;
            }
            else {
                document.images['imgCnf'].src = 'images/x_white.jpg';
            }
            //Ensable-disable save button
            if (iStrength == 4) {
                document.forms[0].MainContent_cmdSave.disabled = false;
            }
            else {
                document.forms[0].MainContent_cmdSave.disabled = true;
            }
        }
        else {
            trStrength.style.display = 'none';
        }
    }

    function CheckSave() {
        document.forms[0].submit();
    }
</script>
<LINK rel="stylesheet" type="text/css" href="Styles/site.css">
<form name="frmAccount" id="frmAccount" method="POST" action="account.aspx" runat="server">
<table border=0 cellspacing=1 cellpadding=2 width=50% ID="Table3">
	<tr height="3px" bgcolor=#c2deba><td></td></tr>
    <tr height="20px">
        <td bgcolor=#dddddd nowrap>
            <div class="smlcaps">Account Management - Password Change
        </td>
    </tr>
	<tr height="1px" bgcolor=#c2deba><td></td></tr>
    <tr><td bgcolor=#eeeeee><div id="lblStatus" runat="server" class=gridcol_red></div></td></tr>
    <tr>
        <td style="padding: 0px">
            <table border=0 cellspacing=1 cellpadding=2 bgcolor=#ffffff>
                <tr>
                    <td bgcolor=#eeeeee align=right><div class=gridcol>Your new password: </div></td>
                    <td bgcolor=#eeeeee><input type="password" runat="server" id="txtNew" name="txtNew" onkeyup="CheckStrength()" /></td>
                </tr>
                <tr>
                    <td bgcolor=#eeeeee align=right><div class=gridcol>Confirm your new password: </div></td>
                    <td bgcolor=#eeeeee><input type="password" runat="server" id="txtConfirm" name="txtConfirm" onkeyup="CheckStrength()" /></td>
                </tr>
                <tr>
                    <td bgcolor=#ffffff></td>
                    <td bgcolor=#ffffff>
                        <asp:Button runat="server" ID="cmdSave" CssClass="input_button_green" Text="Save Information" />
                    </td>
                </tr>
                <tr>
                    <td colspan=2>
                        <table border=0 cellspacing=0 cellpadding=0 id="trStrength" style="display: none">
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
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>
</form>
</body>
</html>
</asp:Content>

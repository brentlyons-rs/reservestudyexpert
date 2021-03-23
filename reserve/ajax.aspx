<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ajax.aspx.cs" Inherits="reserve.ajax" %>

<html>
    <body>
        <form id="form1" runat="server">
<script type="text/javascript">
    function ShowCurrentTime() {
        PageMethods.GetCurrentTime(document.getElementById("<%=txtUserName.ClientID%>").value, OnSuccess);
    }
    function OnSuccess(response, userContext, methodName) {
        alert(response);
    }
</script>

        <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true">
        </asp:ScriptManager>
        <div>
        Your Name :
        <asp:TextBox ID="txtUserName" runat="server" ></asp:TextBox>
        <input id="btnGetTime" type="button" value="Show Current Time" onclick="ShowCurrentTime()"/>
        </div>
        </form>

    </body>
</html>

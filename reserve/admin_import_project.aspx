<%@ Page Language="C#" MasterPageFile="~/Main.Master" AutoEventWireup="true" CodeBehind="admin_import_project.aspx.cs" Inherits="reserve.admin_import_project" %>
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

</script>
<form id="frmImport" name="frmImport" method="POST" action="admin_import_project.aspx" runat="server" autocomplete="off">
<div class="container_fluid" style="width: 100%; max-width: 100%">
    <div class="row float-right" style="margin-top: -4px; margin-left: -2px;">
        <div class="page-top-tab col-lg-3 float-right">
            <p class="panel-title-fd">Admin | Import Project</p>
        </div>
    </div>
</div>
<table class="tblUsers">
    <tr>
        <td>
            Project Number in Production: <input type="text" id="txtProjectNum" name="txtProjectNum" runat="server" />
            <asp:Button runat="server" ID="cmdSave" CssClass="btn btn-primary" Text="Search" OnClick="cmdSave_Click" />
        </td>
    </tr>
    <% if (txtProjectNum.Value != "")
        { %>
    <tr>
        <td>
            <label id="lblProject" runat="server"></label><asp:Button runat="server" ID="cmdImport" CssClass="btn btn-success" OnClick="cmdImport_Click" Text="Import" />
        </td>
    </tr>
    <% } %>
</table>
<input type="hidden" runat="server" id="txtHdnOp" name="txtHdnOp" />
</form>
</asp:Content>

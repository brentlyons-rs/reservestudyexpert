<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="notes.aspx.cs" Inherits="reserve.notes" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Component Notes and Photos</title>
    <link href="css/style.css" rel="stylesheet" />
    <link rel="stylesheet" href="assets/bootstrap/css/bootstrap.min.css" />
    <script src="assets/bootstrap/js/bootstrap.min.js"></script>
    <script src="https://ajax.aspnetcdn.com/ajax/jquery/jquery-1.8.0.js"></script>
    <script src="https://ajax.aspnetcdn.com/ajax/jquery.ui/1.8.22/jquery-ui.js"></script>
    <script src="assets/js/jquery.mask.min.js"></script>
    <link href="https://ajax.aspnetcdn.com/ajax/jquery.ui/1.8.10/themes/redmond/jquery-ui.css" rel="stylesheet" />
    <style>
        .hidden {
            display:none;
        }
        .button {
            border: 1px solid #333;
            padding: 10px;
            margin: 5px;
            background: #777;
            color: #fff;
            width:75px;
        }
    </style>

    <script language="javascript">
        function checkFile(blPhotoReqd) {
            if (blPhotoReqd) {
                if (document.getElementById('lblFName').innerHTML == '[No file selected]') {
                    alert("Please select a file to upoad first.");
                    return false
                }
            }
            return true;
        }

        function checkDel(imgID) {
            if (confirm('Are you sure you want to PERMANENTLY remove this image from the system?') == 1) {
                document.getElementById('txtHdnDel').value = imgID;
                document.getElementById('txtHdnType').value = 'del';
                document.forms[0].submit();
            }
        }

        function toggleEdit(sID) {
            if (document.getElementById('cmdEdit' + sID).value == 'Update Comment') {
                document.getElementById('lblUpdate').innerHTML = 'Updating comment, please wait...';
                document.getElementById('cmdEdit' + sID).disabled = true;
                document.getElementById('txtHdnType').value = 'update';
                document.getElementById('txtHdnID').value = sID;
                document.forms[0].submit();
            }
            else {
                document.getElementById('cmdEdit' + sID).className = 'btn btn-success';
                document.getElementById('cmdEdit' + sID).value = 'Update Comment';
                document.getElementById('divCommentsRO' + sID).style.display = 'none';
                document.getElementById('divCommentsE' + sID).style.display = 'block';
            }
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <% int iTot = 0;
                if (Session["firmid"] == null)
                { %>
            <div class="frm-text-red">Your session has expired. Please log back in.</div>
            <% }
                else
                {
                    bool blPhotoReqd=false;
                    SqlDataReader dr = reserve.Fn_enc.ExecuteReader("select ipi.project_type_id, isnull(lpt.photo_required,0) as photo_required from info_project_info ipi left join lkup_project_types lpt on ipi.firm_id=lpt.firm_id and ipi.project_type_id=lpt.project_type_id where ipi.firm_id=@Param1 and ipi.project_id=@Param2 and ipi.revision_id=@Param3", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString(), Session["revisionid"].ToString() });
                    if (dr.Read() && dr["photo_required"].ToString() == "1") blPhotoReqd = true;
                    dr.Close();
                    %>

            <div style="width: 100%; max-width: 100%">
                <div class="row float-right" style="margin-right: 1px; margin-left: 1px;">
                    <div class="images-upload col-lg-3 float-right" style="padding-left: 0px; padding-right: 0px;">
                        <div style="border-bottom: 1px solid #88d8fe; width: 100%; padding-top: 5px; padding-bottom: 5px; padding-left: 5px; background-color: #c7ecf5">Save a new note:</div>
                        <div style="padding: 5px 5px 5px 5px">
                            <table style="width: 100%">
                                <tr>
                                    <td nowrap style="width: 25%; text-wrap: none; padding: 5px">
                                        <label id="lblFName" style="text-wrap: none">[No file selected]</label>
                                    </td>
                                    <td style="width: 75%; padding: 5px">
                                        <label class="btn btn-primary">Browse <asp:FileUpload ID="flUp" runat="server" CssClass="hidden" /></label>
                                        <b>Note: </b>maximum file size is 10 MB.
                                    </td>
                                </tr>
                                <tr>
                                    <td style="padding: 5px">Comments:</td>
                                    <td style="padding-left: 5px"><textarea style="width: 100%" rows="3" width="100%" id="txtComments" runat="server" maxlength="4000"></textarea></td>
                                </tr>
                                <tr>
                                    <td></td>
                                    <td style="padding: 5px"><asp:Button ID="btnUpload" runat="server" CssClass="btn btn-success" OnClientClick="return checkFile()" OnClick="btnUpload_Click" Text="Save Entry" /></td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
            <label id="lblStatus" class="frm-text-red" runat="server"></label>

            <div style="width: 100%; max-width: 100%">
                <div class="row float-right" style="margin-right: 1px; margin-left: 1px;">
                    <div class="images-upload col-lg-3 float-right" style="padding-left: 0px; padding-right: 0px;">
                        <div style="border-bottom: 1px solid #88d8fe; width: 100%; padding-top: 5px; padding-bottom: 5px; padding-left: 5px; background-color: #c7ecf5">Existing notes for this component:</div>
                        <div style="padding: 5px 5px 5px 5px">
                        <table style="border-top: 1px solid #cccccc; border-left: 1px solid #cccccc; border-right: 1px solid #cccccc; border-bottom: 1px solid #cccccc; padding: 3px 3px 3px 3px !important; width: 100%" cellpadding="3px">
                        <%
                            dr = reserve.Fn_enc.ExecuteReader("select image_id, image_comments, isnull(len(image_bytes),0) as img_size from info_components_images where firm_id=@Param1 and project_id=@Param2 and revision_id=@Param3 and category_id=@Param4 and component_id=@Param5", new string[5] { Session["firmid"].ToString(), Session["projectid"].ToString(), Session["revisionid"].ToString(), txtHdnCat.Value, txtHdnComp.Value });
                            while (dr.Read())
                            {
                            %>
                            <tr style="background-color: #eeeeee">
                                <td style="width: 1%; vertical-align: top"><% if (Convert.ToInt32(dr["img_size"].ToString()) > 0) { %><img id="img1" height="200" width="200" src="ShowImage.ashx?cat=<%=txtHdnCat.Value %>&comp=<%=txtHdnComp.Value %>&img=<%=dr["image_id"].ToString() %>" /><% } %></td>
                                <td style="width: 99%; vertical-align: top">
                                    <table style="width: 100%; padding: 5px">
                                        <tr>
                                            <td style="border-bottom: 1px solid #cccccc; padding: 5px; background-color: #dddddd"><b>Comments:</b>
                                                <div id="divCommentsRO<%=dr["image_id"].ToString() %>"><%=dr["image_comments"].ToString() %></div>
                                                <div id="divCommentsE<%=dr["image_id"].ToString() %>" style="display: none"><textarea id="txtComments<%=dr["image_id"].ToString() %>" name="txtComments<%=dr["image_id"].ToString() %>" style="width: 100%; font-size: 8pt" rows="10"><%=dr["image_comments"].ToString() %></textarea></div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td style="padding: 5px">
                                                <input type="button" id="cmdEdit<%=dr["image_id"].ToString() %>" class="btn btn-primary" value="Edit Entry" onclick="toggleEdit('<%= dr["image_id"].ToString() %>'); " />
                                                <input type="button" class="btn btn-danger" value="Delete Entry" onclick="checkDel('<%= dr["image_id"].ToString() %>'); " />
                                                <label id="lblUpdate"></label>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <%
                                    iTot++;
                                }
                                dr.Close();
                            %>
                        </table>
                        </div>
                    </div>
                </div>
            </div>

            <% } %>
        </div>
        <input type="hidden" id="txtHdnCat" runat="server" />
        <input type="hidden" id="txtHdnComp" runat="server" />
        <input type="hidden" id="txtHdnDel" runat="server" />
        <input type="hidden" id="txtHdnType" runat="server" />
        <input type="hidden" id="txtHdnID" runat="server" />
        <input type="hidden" id="txtHdnCount" value="<%= iTot %>" />
        <script language="javascript">
            $(document).on('change', ':file', function() {
                var input = $(this),
                numFiles = input.get(0).files ? input.get(0).files.length : 1,
                label = input.val().replace(/\\/g, '/').replace(/.*\//, '');
                input.trigger('fileselect', [numFiles, label]);
            });

            $(document).ready( function() {
                $(':file').on('fileselect', function (event, numFiles, label) {
                    $("#lblFName").text(label);
                });
            });


        </script>
    </form>
</body>
</html>

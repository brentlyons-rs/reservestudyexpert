<%@ Page Language="C#" MasterPageFile="~/Main.Master" AutoEventWireup="true" CodeBehind="finalize.aspx.cs" Inherits="reserve.finalize" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
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

    #fader {
      opacity: 0.5;
      background: black;
      position: fixed;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      text-align: center;
      align-content:center;
      display: none;
    }
</style>
<form id="frmFin" method="post" runat="server" class="needs-validation">
    <div class="container_fluid" style="width: 100%; max-width: 100%">
        <div class="row float-right" style="margin-top: -4px; margin-left: -2px;">
            <div class="page-top-tab-project col-lg-3 float-right">
                <p class="panel-title-fd">Finalize<br /><label id="lblProject" runat="server" class="frm-text"></label></p>
            </div>
            <div id="divPnRevisions" runat="server" class="page-top-tab-revision col-lg-2 float-right">
                <p class="panel-title-fd">
                    Revision:<br />
                    <label id="lblRevision" runat="server" class="frm-text"></label>
                </p>
           </div>
        </div>
    </div>
    <% if (Session["projectid"].ToString() == "")
        { %>
    <div class="frm-text-red">Please select a project on the Projects tab first.</div>
    <% }
    else { %>
    <br />
    <table>
        <tr>
            <td style="width: 100px">
                <div style="border-radius: 5px; border: 1px solid #cccccc; margin-left: 5px; text-align: left; padding: 5px; margin-top: 0px !important; margin-bottom: 0px !important; white-space: nowrap" class="frm-text">
                    <i class="fa fa-check-circle" style="color: green; font-size: 16px" id="icoTR" runat="server"></i>&nbsp;Template Ready
                </div>
            </td>
            <td rowspan="4" style="vertical-align: top; width: 150px; padding-left: 10px">
                <label id="lblStatus" class="frm-text" style="text-align: left" runat="server">You're all set! Just click the <i>Generate Document</i> button below to download your Word document.</label>
                <a href="wrdexport.aspx" class="btn btn-primary" id="downloadLink" runat="server">Generate Document</a>
                <span id="divSaveProject" class="frm-text" style="display: none; font-weight: 500;"><i class="fa fa-spinner fa-pulse fa-fw"></i>&nbsp;Saving, please wait...</span>
            </td>
        </tr>
        <tr>
            <td class="form-inline">
                <div style="border-radius: 5px; border: 1px solid #cccccc; margin-left: 5px; text-align: left; padding: 5px; margin-top: 0px !important; margin-bottom: 0px !important; white-space: nowrap" nowrap class="frm-text">
                    <i class="fa fa-check-circle" style="color: green; font-size: 16px" id="icoPI" runat="server"></i>&nbsp;Project Information Entered
                </div>
            </td>
        </tr>
        <tr>
            <td class="form-inline">
                <div style="border-radius: 5px; border: 1px solid #cccccc; margin-left: 5px; text-align: left; padding: 5px; margin-top: 0px !important; margin-bottom: 0px !important; white-space: nowrap" class="frm-text">
                    <i class="fa fa-check-circle" style="color: green; font-size: 16px" id="icoCE" runat="server"></i>&nbsp;Components Entered
                </div>
            </td>
        </tr>
        <tr>
            <td class="form-inline">
                <div style="border-radius: 5px; border: 1px solid #cccccc; margin-left: 5px; text-align: left; padding: 5px; margin-top: 0px !important; margin-bottom: 0px !important; white-space: nowrap" class="frm-text">
                    <i class="fa fa-check-circle" style="color: green; font-size: 16px" id="icoPDG" runat="server"></i>&nbsp;Projection Data Generated
                </div>
            </td>
        </tr>
        <tr>
            <td class="form-inline">
                <div style="border-radius: 5px; border: 1px solid #cccccc; margin-left: 5px; text-align: left; padding: 5px; margin-top: 0px !important; margin-bottom: 0px !important; white-space: nowrap" class="frm-text">
                    <i class="fa fa-check-circle" style="color: green; font-size: 16px" id="icoMTU" runat="server" title="Multiple threshold types cannot be used in the final report. If you have more than one selected, go to the Projections tab and select just one."></i>&nbsp;<label style="font-weight:400" title="Multiple threshold types cannot be used in the final report. If you have more than one selected, go to the Projections tab and select just one.">One or Less Thresholds Used</label>
                </div>
            </td>
        </tr>
    </table>

    <div id="fader">
        <div style="padding: 15px; border-radius: 5px; border: 1px solid #aaaaaa; width: 300px; margin: auto; background-color: #eeeeee; position: absolute; top: 50%; left: 50%; -ms-transform: translateX(-50%) translateY(-50%); -webkit-transform: translate(-50%,-50%); transform: translate(-50%,-50%);">
            <p style="color: #000000"><i class="fa fa-circle-o-notch fa-spin" style="color: blue"></i>Your document is being generated, please wait...</p>
        </div>
    </div>

    <script src="assets/js/jquery-1.11.1.min.js"></script>
    <script src="assets/bootstrap/js/bootstrap.min.js"></script>

    <script lang="ja">

    var setCookie = function (name, value, expiracy) {
        var exdate = new Date();
        exdate.setTime(exdate.getTime() + expiracy * 1000);
        var c_value = escape(value) + ((expiracy == null) ? "" : "; expires=" + exdate.toUTCString());
        document.cookie = name + "=" + c_value + '; path=/';
    };

    var getCookie = function (name) {
        var i, x, y, ARRcookies = document.cookie.split(";");
        for (i = 0; i < ARRcookies.length; i++) {
            x = ARRcookies[i].substr(0, ARRcookies[i].indexOf("="));
            y = ARRcookies[i].substr(ARRcookies[i].indexOf("=") + 1);
            x = x.replace(/^\s+|\s+$/g, "");
            if (x == name) {
                return y ? decodeURI(unescape(y.replace(/\+/g, ' '))) : y; //;//unescape(decodeURI(y));
            }
        }
    };

    $('#MainContent_downloadLink').click(function () {
        $('#fader').css('display', 'block');
        setCookie('downloadStarted', 0, 100); //Expiration could be anything... As long as we reset the value
        setTimeout(checkDownloadCookie, 1000); //Initiate the loop to check the cookie.
    });

    var downloadTimeout;
        var checkDownloadCookie = function () {
            var x = getCookie("downloadStarted");
            if (x == "error") {
                alert("There was an error generating your document: please notify an administrator.");
                setCookie("downloadStarted", "false", 100); //Expiration could be anything... As long as we reset the value
                $('#fader').css('display', 'none');
            }
            else if (x == "1") {
                setCookie("downloadStarted", "false", 100); //Expiration could be anything... As long as we reset the value
                $('#fader').css('display', 'none');
            } else {
                downloadTimeout = setTimeout(checkDownloadCookie, 1000); //Re-run this function in 1 second.
            }
        };

    </script>

    <% } %>
</form>

</asp:content>

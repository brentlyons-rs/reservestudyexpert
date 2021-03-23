<%@ Page Title="Home Page" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="landing1.aspx.cs" Inherits="reserve.landing1" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

<style>

    .row-flex {
        display: flex;
        flex-wrap: wrap;
    }

    .row-eq-height {
        display: -webkit-box;
        display: -webkit-flex;
        display: -ms-flexbox;
        display: flex;
    }
    .row-eq-height > div {
        background: red;
    }

    .loginPanel {
        border: 1px solid #cccccc;
        background-color: rgba(229, 229, 229, .95);
        padding: 20px;
        border-radius: 20px;
    }

    body {
        background-position: center top;
        background-attachment: scroll;
        background-image:url(images/kipcon_main_800.jpg);
        background-repeat: no-repeat;
        height: 1034px;
    }

</style>
    <script type="text/javascript">
        function checkLogin() {
            if (document.getElementById('MainContent_txtEM').value == '') {
                alert('Please enter your email address.');
                document.getElementById('MainContent_txtEM').focus();
                return false;
            }
            if (document.getElementById('MainContent_txtPW').value == '') {
                alert('Please enter your password.');
                document.getElementById('MainContent_txtPW').focus();
                return false;
            }
        }
    </script>

    <form id="frmLogin" runat="server">
        <div class="container" style="margin-top: -40px !important">
            <div class="collapse navbar-collapse" id="top-navbar-1">
		        <div class="container nav navbar-nav navbar-right" style="width: 500px">
                    <ul class="nav nav-tabs" style="margin-left: 30px; margin-right: 20px">
			            <li style="background-color: #efefef; border-top-left-radius: 5px; border-top-right-radius: 5px; margin-right: 5px" class="active">
                            <a  href="#1" data-toggle="tab">Client Login</a>
			            </li>
			            <li style="background-color: #efefef; border-top-left-radius: 5px; border-top-right-radius: 5px">
                            <a href="#2" data-toggle="tab">Staff Login</a>
			            </li>
		           </ul>

			        <div class="tab-content ">
			            <div class="media-left text-left rounded-lg shadow loginPanel tab-pane active" id="1">
                            <h2>CLIENT LOGIN</h2>
                            <div class="form-group">
                                <label for="txtEMClient">Email address</label>
                                <input type="email" class="form-control" id="txtEMClient" aria-describedby="emailHelp" runat="server" style="height: 50px">
                                <small id="emailHelpClient" class="form-text text-muted">We'll never share your email with anyone else.</small>
                            </div>
                            <div class="form-group">
                                <label for="txtPWClient" runat="server">Password</label>
                                <input type="password" class="form-control" id="txtPWClient" runat="server" style="background-color: #ffffff; height: 50px">
                            </div>
                            <div class="form-check form-group form-check-inline">
                                <a href="#" class="btn btn-primary" id="cmdLoginClient" data-loading-text="<i class='fa fa-circle-o-notch fa-spin'></i> Signing you in...">Log me in!</a>&nbsp;&nbsp;&nbsp;
                            </div>
                            <small runat="server" id="lblStatusClient" class="form-text text-muted" style="color: red"></small>
				        </div>
				        <div class="media-left text-left rounded-lg shadow loginPanel tab-pane" id="2">
                            <h2>STAFF LOGIN</h2>
                            <div class="form-group">
                                <label for="txtEM">Email address</label>
                                <input type="email" class="form-control" id="Email" aria-describedby="emailHelp" runat="server" style="height: 50px">
                                <small id="emailHelp" class="form-text text-muted">We'll never share your email with anyone else.</small>
                            </div>
                            <div class="form-group">
                                <label for="txtPW" runat="server">Password</label>
                                <input type="password" class="form-control" id="Password" runat="server" style="background-color: #ffffff; height: 50px">
                            </div>
                            <div class="form-check form-group form-check-inline">
                                <a href="#" class="btn btn-primary" id="cmdLogin" data-loading-text="<i class='fa fa-circle-o-notch fa-spin'></i> Signing you in...">Log me in!</a>&nbsp;&nbsp;&nbsp;
                            </div>
                            <small runat="server" id="lblStatus" class="form-text text-muted" style="color: red"></small>
				        </div>
                        <div class="tab-pane" id="3">
                          <h3>add clearfix to tab-content (see the css)</h3>
				        </div>
			        </div>
                  </div>
                </div>
            </div>
        <!-- Javascript -->
        <script src="assets/js/jquery-1.11.1.min.js"></script>
        <script src="assets/bootstrap/js/bootstrap.min.js"></script>
        <script src="assets/js/jquery.backstretch.min.js"></script>
        <script src="assets/js/wow.min.js"></script>
        <script src="assets/js/retina-1.1.0.min.js"></script>
        <script src="assets/js/waypoints.min.js"></script>
        <script src="assets/js/scripts.js"></script>
        <!--[if lt IE 10]>
            <script src="assets/js/placeholder.js"></script>
        <![endif]-->
        <script lang="ja">
            $('#cmdLogin').on('click',
                function () {
                    if ($('#MainContent_txtEM').val() == null || $('#MainContent_txtEM').val() == '') {
                        alert('Please enter your email address.');
                        $('#MainContent_txtEM').focus();
                        return;
                    }
                    if ($('#MainContent_txtPW').val() == null || $('#MainContent_txtPW').val() == '') {
                        alert('Please enter your password.');
                        $('#MainContent_txtPW').focus();
                        return;
                    }

                    var $this = $(this); $this.button('loading');
                    $('#frmLogin').submit();
                    //setTimeout(function() { $this.button('reset');}, 8000);
                }
            );
        </script>
    </form>

</asp:Content>

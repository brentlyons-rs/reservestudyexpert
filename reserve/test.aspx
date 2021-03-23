


<!DOCTYPE html>

<html lang="en">
<head><meta charset="utf-8" /><meta http-equiv="X-UA-Compatible" content="IE=edge" /><meta name="viewport" content="width=device-width, initial-scale=1" />

        <!-- CSS -->        
        <link rel="stylesheet" href="assets/bootstrap/css/bootstrap.min.css" /><link rel="stylesheet" href="assets/font-awesome/css/font-awesome.min.css" /><link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Josefin+Sans:300,400|Roboto:300,400,500" /><link rel="stylesheet" href="assets/css/animate.css" /><link rel="stylesheet" href="assets/css/style.css" />
        
        <script src="assets/js/jquery-1.11.1.min.js"></script>
        <script src="assets/bootstrap/js/bootstrap.min.js"></script>

        <style id="jsbin-css">
            .alt-grid [class*="col-"] {padding-left:2px;padding-right:2px;margin-top:55px}
            .alt-grid .row {margin-left:2px;margin-right:2px;margin-top:55px}

            /* container adjusted */
            .alt-grid .container {width:98%;max-width:none;padding:2px;margin-top:55px}
        </style>

        <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
        <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
        <!--[if lt IE 9]>
            <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
            <script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
        <![endif]-->

    <title>
	Reserve Study
</title><link href="favicon.ico" rel="shortcut icon" type="image/x-icon" />

    <script>
        function sendLink(sURL) {
            if (window.location.toString().indexOf('main.aspx') > 0) {
                if (checkChanges() == false) window.event.preventDefault();
            }
            else {
                window.location = sURL;
            }
        }
    </script>
</head>
<body>
	<nav class="navbar navbar-fixed-top">
		<div class="container_fluid" style="margin-right: 15px">
			<div class="navbar-header">
				<img src="images/rs.jpg" class="mt-5" style="margin-top: 10px" />
            </div>
            <div class="col" style="position: absolute; bottom: 5px; margin-left: 40px">
                <h6>Brent Lyons - Kipcon</h6>
			</div>
			<!-- Collect the nav links, forms, and other content for toggling -->
			<div class="collapse navbar-collapse" id="topheader2">
				<ul class="nav navbar-nav navbar-right">
					<li><a href="main.aspx" onclick="sendLink('main.aspx')" class="btn btn-link-2 no-transition">Projects</a></li>
					<li><a href="components.aspx" onclick="sendLink('components.aspx')" class="btn btn-link-2 no-transition">Components</a></li>
					<li><a href="rvw_summ.aspx" onclick="sendLink('rvw_summ.aspx')" class="btn btn-link-2 no-transition">Review</a></li>
					<li><a href="finalize.aspx" onclick="sendLink('finalize.aspx')" class="btn btn-link-2 no-transition">Finalize</a></li>
                    <li id="liAdmin" class="dropdown">
                        <a class="dropdown-toggle btn btn-link-2 no-transition" data-toggle="dropdown" href="#">Admin
                        <span class="caret"></span></a>
                        <ul class="dropdown-menu">
                            <li><a href="admin_users.aspx" onclick="sendLink('admin_users.aspx')" class="nav-dd-subitem">User Accounts</a></li>
                            <li><a href="tm.aspx" onclick="sendLink('tm.aspx')" class="nav-dd-subitem">Table Maintenance</a></li>
                        </ul>
                    </li>
					<li><a href="default.aspx?lo=1" onclick="sendLink('default.aspx?lo=1')" class="btn btn-link-4 no-transition">Logout</a></li>
				</ul>
			</div>
		</div>
	</nav>

    <div class="alt-grid">
        

<script src="https://ajax.aspnetcdn.com/ajax/jquery/jquery-1.8.0.js"></script>
<script src="https://ajax.aspnetcdn.com/ajax/jquery.ui/1.8.22/jquery-ui.js"></script>
<script src="assets/js/jquery.mask.min.js"></script>
<link href="https://ajax.aspnetcdn.com/ajax/jquery.ui/1.8.10/themes/redmond/jquery-ui.css" rel="stylesheet" />
<link href="css/style.css" rel="stylesheet" />

<style>
    body:
    {
        line-height: 20px !important;
    }
    iframe { display:block; }
</style>

<form method="post" action="./rvw_graphs.aspx" id="frmProject" class="needs-validation">
<div class="aspNetHidden">
<input type="hidden" name="__VIEWSTATE" id="__VIEWSTATE" value="QkcXMginITfBdEJBLL2///TdlYWFILzT8kpxJeW4GZLg8A+M4kVw29QT+WToMBdivX0knYk4HCmiLilPcekBGa2tB4nRvU5QjZ2oufQAVEhzyoSsiigPApdyGqsgSZry86/jm0yd1cKKyDt8VolnBKJtiR9DLNPMZmcYMkAzNWs=" />
</div>

<div class="aspNetHidden">

	<input type="hidden" name="__VIEWSTATEGENERATOR" id="__VIEWSTATEGENERATOR" value="32A9C631" />
</div>
    <div class="container_fluid" style="width: 100%; max-width: 100%">
        <div class="row float-right" style="margin-top: -4px; margin-left: -2px;">
            <div class="page-top-tab col-lg-3 float-right">
                <p class="panel-title-fd">Review&nbsp;<label id="MainContent_lblProject" class="frm-text">Kipcon Reserve Study +</label></p>
            </div>
        </div>
    </div>
    
    <div style="margin-top: 5px">
        <ul class="nav nav-tabs">
            <li class="frm-text">
                <a href="rvw_summ.aspx">Summary</a>
            </li>
            <li class="frm-text">
                <a href="rvw_comp.aspx">Components</a>
            </li>
            <li class="frm-text">
                <a href="rvw_proj.aspx">Projection</a>
            </li>
            <li class="frm-text">
                <a href="rvw_exp.aspx">Expenditures</a>
            </li>
            <li class="active frm-text">
                <a href="rvw_graphs.aspx">Graphs</a>
            </li>
        </ul>
    </div>
    
    <canvas id="myChart" width="600px" height="200px"></canvas>
    <script src="https://cdn.jsdelivr.net/npm/chart.js@2.8.0"></script>
    <script>
        var ctx = document.getElementById('myChart').getContext('2d');
        var chart = new Chart(ctx, {
            // The type of chart we want to create
            type: 'line',

            // The data for our dataset
            data: {
                labels: ['2020', '2020', '2021', '2022', '2023', '2024', '2025', '2026', '2027', '2028', '2029', '2030', '2031', '2032', '2033', '2034', '2035', '2036', '2037', '2038', '2039', '2040', '2041', '2042', '2043', '2044', '2045', '2046', '2047', '2048', '2049'],
                datasets: [
                    {
                        label: 'Reserve Fund Balance - Full Funding',
                        borderColor: 'rgb(255, 99, 132)',
                        data: [296970, 362362, 427754, 493146, 551968, 617360, 682752, 748144, 813536, 872358, 826750, 892142, 957534, 1022926, 1081748, 600890, 666282, 731674, 797066, 855888, 715480, 780872, 846264, 911656, 970478, 1035870, 1101262, 1166654, 1232046, 1290868, 397260]
                    },
                    {
                        label: 'Reserve Fund Balance - Current Funding',
                        borderColor: 'rgb(99, 102, 255)',
                        data: [296970, 341170, 385370, 429570, 467200, 511400, 555600, 599800, 644000, 681630, 614830, 659030, 703230, 747430, 785060, 283010, 327210, 371410, 415610, 453240, 291640, 335840, 380040, 424240, 461870, 506070, 550270, 594470, 638670, 676300, -238500]
                    },
                    {
                        label: 'Reserve Fund Balance - Baseline Funding',
                        borderColor: 'rgb(31, 237, 45)',
                        data: [296970, 349120, 401270, 453420, 499000, 551150, 603300, 655450, 707600, 753180, 694330, 746480, 798630, 850780, 896360, 402260, 454410, 506560, 558710, 604290, 450640, 502790, 554940, 607090, 652670, 704820, 756970, 809120, 861270, 906850, 0]
                    }

                ]
            },

            // Configuration options go here
            options: {
                elements: {
                    line: {
                        tension: 0
                    }
                },
                tooltips: {
                    callbacks: {
                        label: function (tooltipItem, data) {
                            return '$' + tooltipItem.yLabel.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
                        },
                    },
                },
                scales: {
                    yAxes: [{
                        ticks: {
                            beginAtZero: true,
                            callback: function (value, index, values) {
                                return value.toLocaleString("en-US", { style: "currency", currency: "USD" });
                            }
                        }
                    }]
                }
            }
        });
    </script>
    
    </form>


    </div>

    <script>
        $(document).ready(function () {
            var url = window.location.toString();
            $('.navbar .nav').find('.active').removeClass('active');
            $('.navbar .nav li a').each(function () {
                if ((this.href == url) && (this.href != '#')) {
                    $(this).addClass('overwrite');
                }
                else if ((this.href.indexOf('rvw_') > 0) && (this.href.indexOf('#') < 0) && (url.indexOf('rvw_') > 0)) {
                    $(this).addClass('overwrite');
                }
            });
        });
    </script>
</body>
</html>

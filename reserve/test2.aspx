<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="test2.aspx.cs" Inherits="reserve.test2" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta charset="utf-8" />
    <title>HTML DOM</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link href="css/tbldrag.css" rel="stylesheet" />
</head>
<body class="font-sans w-full">
    <div class="py-16 flex items-center justify-center">
        <table id="table" class="table_drag">
            <thead>
                <tr>
                    <th data-type="number">No.</th>
                    <th>First name</th>
                    <th>Last name</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td>1</td>
                    <td>Andrea</td>
                    <td>Ross</td>
                </tr>
                <tr>
                    <td>2</td>
                    <td>Penelope</td>
                    <td>Mills</td>
                </tr>
                <tr>
                    <td>3</td>
                    <td>Sarah</td>
                    <td>Grant</td>
                </tr>
                <tr>
                    <td>4</td>
                    <td>Vanessa</td>
                    <td>Roberts</td>
                </tr>
                <tr>
                    <td id="test">5</td>
                    <td>Oliver</td>
                    <td>Alsop</td>
                </tr>
                <tr>
                    <td>6</td>
                    <td>Jennifer</td>
                    <td>Forsyth</td>
                </tr>
                <tr>
                    <td>7</td>
                    <td>Michelle</td>
                    <td>King</td>
                </tr>
                <tr>
                    <td>8</td>
                    <td>Steven</td>
                    <td>Kelly</td>
                </tr>
                <tr>
                    <td>9</td>
                    <td>Julian</td>
                    <td>Ferguson</td>
                </tr>
                <tr>
                    <td>10</td>
                    <td>Chloe</td>
                    <td>Ince</td>
                </tr>
            </tbody>
        </table>
    </div>
    <script src="Scripts/tbldrag.js"></script>
</body>
</html>

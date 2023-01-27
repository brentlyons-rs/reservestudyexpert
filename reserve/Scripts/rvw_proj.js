var request;
var iSendState = 0;
var blGet = true;
var sArea = "";
var blCode = false;
var XMLobj;
var sOp = "";
var gUrl;

function sendProjection(sCrit, sSqlField, sVal, iRow, iCol) {
    if ((request.readyState != 4) && (request.readyState != 0)) {
        setTimeout("sendProjection('" + sCrit + "', '" + sSqlField + "', '" + sVal + "'," + iRow + "," + iCol + ")", 3000);
    }
    else {
        sOp = 'sendTM';
        var url = "ws.asmx/SaveReview?sTable=proj&sCrit=" + escape(sCrit) + "&sField=" + escape(sSqlField) + "&sVal=" + escape(sVal) + "&iRow=" + iRow + "&iCol=" + iCol + "&pd=y";
        gUrl = url;
        request.open("GET", url, true);
        request.onreadystatechange = updateSend;
        request.send(null);
    }
}

function sendThreshold1(iState, sVal) {
    if ((request.readyState != 4) && (request.readyState != 0)) {
        setTimeout("sendThreshold1(" + iState + ", '" + sVal + "')", 3000);
    }
    else {
        document.getElementById('imgThreshold1').style.display = 'block';
        document.getElementById('MainContent_chkThreshold1').disabled = true;
        sOp = 'sendThreshold1';
        var url = "ws.asmx/SaveThreshold1?iState=" + escape(iState) + "&sValue=" + escape(sVal) + "&pd=y";
        gUrl = url;
        request.open("GET", url, true);
        request.onreadystatechange = updateSend;
        request.send(null);
    }
}

function sendThreshold2(sVal) {
    if ((request.readyState != 4) && (request.readyState != 0)) {
        setTimeout("sendThreshold2('" + sVal + "')", 3000);
    }
    else {
        document.getElementById('imgThreshold2').style.display = 'block';
        document.getElementById('MainContent_chkThreshold2').disabled = true;
        sOp = 'sendThreshold2';
        var url = "ws.asmx/SaveThreshold2?sThreshold=" + escape(sVal) + "&pd=y";
        gUrl = url;
        request.open("GET", url, true);
        request.onreadystatechange = updateSend;
        request.send(null);
    }
}

function sendChkDisp(iField, sVal) {
    if ((request.readyState != 4) && (request.readyState != 0)) {
        setTimeout("sendChkDisp(" + iField + ", '" + sVal + "')", 3000);
    }
    else {
        document.getElementById('imgChkDisp' + iField).style.display = 'block';
        document.getElementById('MainContent_chkDisp' + iField).disabled = true;
        sOp = 'sendChkDisp';
        var url = "ws.asmx/SaveChkDisp?iField=" + iField + "&sVal=" + sVal + "&pd=y";
        gUrl = url;
        request.open("GET", url, true);
        request.onreadystatechange = updateSend;
        request.send(null);
    }

}

function sendChkPctFunded(iField, sVal) {
    if ((request.readyState != 4) && (request.readyState != 0)) {
        setTimeout("sendChkPctFunded(" + iField + ", '" + sVal + "')", 3000);
    }
    else {
        document.getElementById('imgChkPctFunded' + iField).style.display = 'block';
        document.getElementById('MainContent_chkPctFunded' + iField).disabled = true;
        sOp = 'sendChkPctFunded';
        var url = "ws.asmx/SaveChkPctFunded?iField=" + iField + "&sVal=" + sVal + "&pd=y";
        gUrl = url;
        request.open("GET", url, true);
        request.onreadystatechange = updateSend;
        request.send(null);
    }

}


function updateSend() {
    if (request.readyState == 4) {
        if (request.status == 200) {
            var Mime = request.getResponseHeader('Content-Type');
            Mime = Mime.toString();
            if (request.responseXML != null) {
                XMLobj = request.responseXML;
            }
            else if ((Mime.indexOf('text/xml') == -1) || (Mime.indexOf('application/xml') == -1)) {
                try {
                    XMLobj = createXMLParser(request.responseText);
                }
                catch (e) {
                    alert("Not good: " + e);
                    XMLobj = request.responseText;
                }
            }
            else {
                alert("No XML!");
                var TEXTobj = request.responseText;
            }
            if (XMLobj != null) {
                if (sOp == 'sendTM') {
                    examineTM(XMLobj);
                }
                else if (sOp == 'sendThreshold1') {
                    examineThreshold1(XMLobj);
                }
                else if (sOp == 'sendThreshold2') {
                    examineThreshold2(XMLobj);
                }
                else if (sOp == 'sendChkDisp') {
                    examineChkDisp(XMLobj);
                }
                else if (sOp == 'sendChkPctFunded') {
                    examineChkPctFunded(XMLobj);
                }
            }
        }
        else if (request.status == 404)
            alert("Error connecting to the web service - request URL does not exist. If the problem persists, please contact an administrator.")
        else
            alert("Error connecting to the web service: status code is " + request.status + ". If the problem persists, please contact an administrator.")
    }
}

function examineThreshold1(XMLObj) {
    for (j = 0; j < XMLobj.getElementsByTagName('Results').length; j++) {
        if (XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_type')[0].firstChild.nodeValue == 'Error') {
            alert("Error saving record. Please send the following error to an administrator: " + XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_desc')[0].firstChild.nodeValue);
            document.getElementById('MainContent_lblStatus').innerHTML = 'Error saving record.' + XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_desc')[0].firstChild.nodeValue;
        }
        if (XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_type')[0].firstChild.nodeValue == 'Reject') {
            alert(XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_desc')[0].firstChild.nodeValue);
            document.getElementById('MainContent_lblStatus').innerHTML = 'Could not save record.';
        }
        if (XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_type')[0].firstChild.nodeValue == 'Success') {
            calcTotals();
            document.getElementById('imgThreshold1').style.display = 'none';
            document.getElementById('MainContent_chkThreshold1').disabled = false;
            examineDisablePctFunded('threshold1');
            document.getElementById('MainContent_lblStatus').innerHTML = 'Successfully updated threshold analysis.';
        }
    }
    document.forms[0].disabled = false;
    return true;
}

function examineThreshold2(XMLObj) {
    for (j = 0; j < XMLobj.getElementsByTagName('Results').length; j++) {
        if (XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_type')[0].firstChild.nodeValue == 'Error') {
            alert("Error saving record. Please send the following error to an administrator: " + XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_desc')[0].firstChild.nodeValue);
            document.getElementById('MainContent_lblStatus').innerHTML = 'Error saving record.' + XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_desc')[0].firstChild.nodeValue;
        }
        if (XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_type')[0].firstChild.nodeValue == 'Reject') {
            alert(XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_desc')[0].firstChild.nodeValue);
            document.getElementById('MainContent_lblStatus').innerHTML = 'Could not save record.';
        }
        if (XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_type')[0].firstChild.nodeValue == 'Success') {
            calcTotals();
            document.getElementById('imgThreshold2').style.display = 'none';
            document.getElementById('MainContent_chkThreshold2').disabled = false;
            examineDisablePctFunded('threshold2');
            document.getElementById('MainContent_lblStatus').innerHTML = 'Successfully updated threshold 2 analysis.';
        }
    }
    document.forms[0].disabled = false;
    return true;
}

function examineDisablePctFunded(strObject) {
    if (strObject == 'chkDisp1') {
        if ((!document.getElementById('MainContent_chkDisp1').checked) && (document.getElementById('MainContent_chkPctFunded1').checked)) {
            document.getElementById('MainContent_chkPctFunded1').checked = false;
            sendChkPctFunded(1, "1");
            return;
        }
    }
    else if (strObject == 'chkDisp3') {
        if ((!document.getElementById('MainContent_chkDisp3').checked) && (document.getElementById('MainContent_chkPctFunded2').checked)) {
            document.getElementById('MainContent_chkPctFunded2').checked = false;
            sendChkPctFunded(2, "1");
            return;
        }
    }
    else if (strObject == 'threshold1') {
        if ((!document.getElementById('MainContent_chkThreshold1').checked) && (document.getElementById('MainContent_chkPctFunded3').checked)) {
            document.getElementById('MainContent_chkPctFunded3').checked = false;
            sendChkPctFunded(3, "1");
            return;
        }
    }
    else if (strObject == 'threshold2') {
        if ((!document.getElementById('MainContent_chkThreshold2').checked) && (document.getElementById('MainContent_chkPctFunded4').checked)) {
            document.getElementById('MainContent_chkPctFunded4').checked = false;
            sendChkPctFunded(4, "1");
            return;
        }
    }
}

function examineChkDisp(XMLObj) {
    var sStatus = "";
    for (j = 0; j < XMLobj.getElementsByTagName('Results').length; j++) {
        if (XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_type')[0].firstChild.nodeValue == 'Error') {
            alert("Error saving record. Please send the following error to an administrator: " + XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_desc')[0].firstChild.nodeValue);
            document.getElementById('MainContent_lblStatus').innerHTML = 'Error saving record.' + XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_desc')[0].firstChild.nodeValue;
        }
        if (XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_type')[0].firstChild.nodeValue == 'Reject') {
            alert(XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_desc')[0].firstChild.nodeValue);
            document.getElementById('MainContent_lblStatus').innerHTML = 'Could not save record.';
        }
        if (XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_type')[0].firstChild.nodeValue == 'Success') {
            var i = XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('i_field')[0].firstChild.nodeValue;
            document.getElementById('imgChkDisp' + i).style.display = 'none';
            document.getElementById('MainContent_chkDisp' + i).disabled = false;
            examineDisablePctFunded('chkDisp' + i);
            document.getElementById('MainContent_lblStatus').innerHTML = 'Successfully updated display option.';
        }
    }
    document.forms[0].disabled = false;
    calcPctFunded();
    return true;
}


function examineChkPctFunded(XMLObj) {
    var sStatus = "";
    for (j = 0; j < XMLobj.getElementsByTagName('Results').length; j++) {
        if (XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_type')[0].firstChild.nodeValue == 'Error') {
            alert("Error saving record. Please send the following error to an administrator: " + XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_desc')[0].firstChild.nodeValue);
            document.getElementById('MainContent_lblStatus').innerHTML = 'Error saving record.' + XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_desc')[0].firstChild.nodeValue;
        }
        if (XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_type')[0].firstChild.nodeValue == 'Reject') {
            alert(XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_desc')[0].firstChild.nodeValue);
            document.getElementById('MainContent_lblStatus').innerHTML = 'Could not save record.';
        }
        if (XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_type')[0].firstChild.nodeValue == 'Success') {
            var i = XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('i_field')[0].firstChild.nodeValue;
            document.getElementById('imgChkPctFunded' + i).style.display = 'none';
            document.getElementById('MainContent_chkPctFunded' + i).disabled = false;
            document.getElementById('MainContent_lblStatus').innerHTML = 'Successfully updated display option.';
        }
    }
    document.forms[0].disabled = false;
    calcPctFunded();
    return true;
}

function examineTM(XMLObj) {
    var iRow = -1;
    var iCol = -1;
    var sStatus = "";
    for (j = 0; j < XMLobj.getElementsByTagName('Results').length; j++) {
        iRow = XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('i_row')[0].firstChild.nodeValue;
        iCol = XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('i_col')[0].firstChild.nodeValue;

        if (XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_type')[0].firstChild.nodeValue == 'Error') {
            alert("Error saving record. Please send the following error to an administrator: " + XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_desc')[0].firstChild.nodeValue);
            document.getElementById('MainContent_lblStatus').innerHTML = 'Error saving record.' + XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_desc')[0].firstChild.nodeValue;
        }
        if (XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_type')[0].firstChild.nodeValue == 'Reject') {
            alert(XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_desc')[0].firstChild.nodeValue);
            document.getElementById('MainContent_lblStatus').innerHTML = 'Could not save record.';
        }
        if (XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_type')[0].firstChild.nodeValue == 'Success') {
            if (XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_desc')[0].firstChild == null) {
                document.getElementById('hdnAnswer' + iRow + '_' + iCol).value = '';
            }
            else {
                try {
                    document.getElementById('hdnAnswer' + iRow + '_' + iCol).value = XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_desc')[0].firstChild.nodeValue;
                }
                catch (err) {
                    alert("row: " + iRow + ", col: " + iCol);
                }
            }

            if (iCol == 0) sStatus = "annual expense";
            if (iCol == 1) sStatus = "current funding analysis - annual contribution";
            if (iCol == 2) sStatus = "current funding analysis - reserve fund balance";
            if (iCol == 3) sStatus = "full funding analysis - required annual contribution";
            if (iCol == 4) sStatus = "full funding analysis - average required annual contribution";
            if (iCol == 5) sStatus = "full funding analysis - reserve fund balance";
            if (iCol == 6) sStatus = "baseline funding analysis - annual contribution";
            if (iCol == 7) sStatus = "baseline funding analysis - reserve fund balance";
            if (iCol == 8) sStatus = "threshold funding analysis - reserve fund balance";
            if (iCol == 9) sStatus = "threshold funding analysis - reserve fund balance";
            if (iCol == 10) sStatus = "% increase";
            document.getElementById('MainContent_lblStatus').innerHTML = 'Successfully updated ' + sStatus + '.';
        }
    }
    if (XMLobj.getElementsByTagName('adjthresh').length > 0) {
        for (j = 0; j < XMLobj.getElementsByTagName('adjthresh').length; j++) {
            if (XMLobj.getElementsByTagName('adjthresh')[j].getElementsByTagName('pct_increase').length > 0) {
                document.getElementById('txt' + (j + 1) + '_10').value = XMLobj.getElementsByTagName('adjthresh')[j].getElementsByTagName('pct_increase')[0].firstChild.nodeValue;
                document.getElementById('hdnAnswer' + (j + 1) + '_10').value = XMLobj.getElementsByTagName('adjthresh')[j].getElementsByTagName('pct_increase')[0].firstChild.nodeValue;
            }
            else {
                document.getElementById('txt' + (j + 1) + '_10').value = '0.00';
                document.getElementById('hdnAnswer' + (j + 1) + '_10').value = '0.00';
            }
            //TFA
            if (XMLobj.getElementsByTagName('adjthresh')[j].getElementsByTagName('contrib').length > 0) {
                document.getElementById('txt' + (j + 1) + '_11').value = XMLobj.getElementsByTagName('adjthresh')[j].getElementsByTagName('contrib')[0].firstChild.nodeValue;
                document.getElementById('hdnAnswer' + (j + 1) + '_11').value = XMLobj.getElementsByTagName('adjthresh')[j].getElementsByTagName('contrib')[0].firstChild.nodeValue;
            }
            if (XMLobj.getElementsByTagName('adjthresh')[j].getElementsByTagName('bal').length > 0) {
                document.getElementById('txt' + (j + 1) + '_12').value = XMLobj.getElementsByTagName('adjthresh')[j].getElementsByTagName('bal')[0].firstChild.nodeValue;
                document.getElementById('hdnAnswer' + (j + 1) + '_12').value = XMLobj.getElementsByTagName('adjthresh')[j].getElementsByTagName('bal')[0].firstChild.nodeValue;
            }
        }
    }
    else if (XMLobj.getElementsByTagName('cfa').length > 0) {
        //CFA
        for (j = 0; j < XMLobj.getElementsByTagName('cfa').length; j++) {
            if (XMLobj.getElementsByTagName('cfa')[j].getElementsByTagName('cfa_bal').length > 0) {
                document.getElementById('txt' + (j + 1) + '_2').value = XMLobj.getElementsByTagName('cfa')[j].getElementsByTagName('cfa_bal')[0].firstChild.nodeValue;
                document.getElementById('hdnAnswer' + (j + 1) + '_2').value = XMLobj.getElementsByTagName('cfa')[j].getElementsByTagName('cfa_bal')[0].firstChild.nodeValue;
            }            
        }
    }
    calcTotals();
    document.forms[0].disabled = false;
    UpdateRowHeader(iRow, 'None');
    return true;
}

function checkExisting(sExists) {
    if (sExists == 'True') {
        if (confirm("Projection data already exists for this project. If you re-generate data, any changes you previously made to projection data will be lost. Are you sure you want to continue?") == 0) {
            return false;
        }
    }
    document.getElementById('MainContent_txtHdnType').value = 'Gen';
    document.forms[0].submit();
}

try {
    request = new XMLHttpRequest(); //recordset
}
catch (trymicrosoft) {
    try {
        request = new ActiveXObject("Msxml2.XMLHTTP");
    }
    catch (othermicrosoft) {
        try {
            request = new ActiveXObject("Microsoft.XMLHTTP");
        }
        catch (failed) {
            request = false;
        }
    }
}

var iTotalRows = 0;
var iCurRow = 0;

function UpdateRowHeader(iRow, sType) {
    if (sType == 'Edit') {
        document.getElementById('rowHdr' + iRow).innerHTML = '<img src="images/wg_edit.jpg" border=0 align="absmiddle">';
        iCurRow = iRow;
    }
    else if (sType == 'Load') {
        document.getElementById('rowHdr' + iRow).innerHTML = '<img src="images/ajax_snake.gif" border=0 align="absmiddle">';
    }
    else if (sType == 'None') {
        document.getElementById('rowHdr' + iRow).innerHTML = '';
    }
}

function CheckPctIncAllChanged() {
    if (document.getElementById('txt1_10').value != document.getElementById('hdnAnswer1_10').value) {
        document.forms[0].disabled = true;
        sendProjection("", "pct_increase_all", document.getElementById('txt1_10').value, 1, 10);
    }
}

function CheckRowChanges(sSqlField, sType, iRow, iCol) {
    var sVal = "";
    var iChg = 0;
    if (sType == 'textbox') {
        if (document.getElementById('txt' + iRow + '_' + iCol).value != document.getElementById('hdnAnswer' + iRow + '_' + iCol).value) {
            sVal = document.getElementById('txt' + iRow + '_' + iCol).value;
            iChg = 1;
        }
    }
    else if (sType == 'checkbox') {
        if (document.getElementById('txt' + iRow + '_' + iCol).checked && (document.getElementById('hdnAnswer' + iRow + '_' + iCol).value == '0' || document.getElementById('hdnAnswer' + iRow + '_' + iCol).value == '')) {
            sVal = 1;
            iChg = 1;
        }
        else if (document.getElementById('txt' + iRow + '_' + iCol).checked == false && document.getElementById('hdnAnswer' + iRow + '_' + iCol).value == '1') {
            sVal = 0;
            iChg = 1;
        }
    }

    if (iChg == 1) {
        UpdateRowHeader(iRow, 'Load');
        document.forms[0].disabled = true;
        sendProjection(document.getElementById('txtHdnCrit' + iRow).value, sSqlField, sVal, iRow, iCol);
    }
    else {
        UpdateRowHeader('None');
    }
}

function getCaretPosition(oField) {

    // Initialize
    var iCaretPos = 0;

    // IE Support
    if (document.selection) {

        // Set focus on the element
        oField.focus();

        // To get cursor position, get empty selection range
        var oSel = document.selection.createRange();

        // Move selection start to 0 position
        oSel.moveStart('character', -oField.value.length);

        // The caret position is selection length
        iCaretPos = oSel.text.length;
    }

    // Firefox support
    else if (oField.selectionStart || oField.selectionStart == '0')
        iCaretPos = oField.selectionStart;

    // Return results
    return (iCaretPos);
}

function isTextSelected(input) {
    if (typeof input.selectionStart == "number") {
        return input.selectionStart == 0 && input.selectionEnd == input.value.length;
    } else if (typeof document.selection != "undefined") {
        input.focus();
        return document.selection.createRange().text == input.value;
    }
}

function chkKeybd(sender, e, iRow, iCol) {
    var key = e.which ? e.which : e.keyCode;
    var iAdjCol = 1;

    if ((!isTextSelected(sender)) && (key == 37)) { //left
        if (document.getElementById('txt' + iRow + '_' + (iCol - iAdjCol)) != null) {
            if (getCaretPosition(sender) >= 0) document.getElementById('txt' + iRow + '_' + (iCol - iAdjCol)).focus();
        }
    }
    else if ((sender.type !== 'select-one') && (key == 38)) { //up
        if (document.getElementById('txt' + (iRow - 1) + '_' + iCol) != null) {
            document.getElementById('txt' + (iRow - 1) + '_' + iCol).focus();
            document.getElementById('txt' + (iRow - 1) + '_' + iCol).select();
        }
    }
    else if ((!isTextSelected(sender)) && (key == 39)) { //right
        if (document.getElementById('txt' + iRow + '_' + (iCol + iAdjCol)) != null) {
            if ((sender.type == 'select-one') || (sender.value.length == getCaretPosition(sender))) { document.getElementById('txt' + iRow + '_' + (iCol + iAdjCol)).focus(); }
            else if (getCaretPosition(sender) >= 0) document.getElementById('txt' + iRow + '_' + (iCol + iAdjCol)).focus();
        }
    }
    else if ((sender.type !== 'select-one') && ((key == 40) || (key == 13)) && (iRow != 0)) { //down
        if (document.getElementById('txt' + (iRow + 1) + '_' + iCol) != null) {
            document.getElementById('txt' + (iRow + 1) + '_' + iCol).focus();
            document.getElementById('txt' + (iRow + 1) + '_' + iCol).select();
        }
    }
}

function calcPctFunded() {
    for (var i = 1; i < 31; i++) {
        var fullFundBal = fullFund[i - 1];
        if (fullFundBal > 0) {
            // Current
            if (document.getElementById('MainContent_chkPctFunded1').checked) {
                var fund = fmtNum(document.getElementById('txt' + i + '_2').value);

                if (!isNaN(fund) && fullFundBal > 0) {
                    document.getElementById('pctFunded' + i + '_1').innerHTML = (fund / fullFundBal).toLocaleString(undefined, { style: 'percent', minimumFractionDigits: 0 });
                }
            }
            // Full
            if (document.getElementById('MainContent_chkPctFunded2').checked) {
                var fund = fmtNum(document.getElementById('txt' + i + '_5').value);

                if (!isNaN(fund) && fullFundBal > 0) {
                    document.getElementById('pctFunded' + i + '_2').innerHTML = (fund / fullFundBal).toLocaleString(undefined, { style: 'percent', minimumFractionDigits: 0 });
                }
            }
            // Baseline
            if (document.getElementById('MainContent_chkPctFunded3').checked) {
                var fund = fmtNum(document.getElementById('txt' + i + '_7').value);

                if (!isNaN(fund) && fullFundBal > 0) {
                    document.getElementById('pctFunded' + i + '_3').innerHTML = (fund / fullFundBal).toLocaleString(undefined, { style: 'percent', minimumFractionDigits: 0 });
                }
            }
            // Threshold1
            if (document.getElementById('MainContent_chkPctFunded4').checked) {
                var fund = fmtNum(document.getElementById('txt' + i + '_9').value);

                if (!isNaN(fund) && fullFundBal > 0) {
                    document.getElementById('pctFunded' + i + '_4').innerHTML = (fund / fullFundBal).toLocaleString(undefined, { style: 'percent', minimumFractionDigits: 0 });
                }
            }
            // Threshold2
            if (document.getElementById('MainContent_chkPctFunded5').checked) {
                var fund = fmtNum(document.getElementById('txt' + i + '_12').value);

                if (!isNaN(fund) && fullFundBal > 0) {
                    document.getElementById('pctFunded' + i + '_5').innerHTML = (fund / fullFundBal).toLocaleString(undefined, { style: 'percent', minimumFractionDigits: 0 });
                }
            }
        }
    }
    // Disabled pct funded boxes if those sections aren't be displayed
    document.getElementById('MainContent_chkPctFunded1').disabled = !document.getElementById('MainContent_chkDisp1').checked;
    document.getElementById('MainContent_chkPctFunded2').disabled = !document.getElementById('MainContent_chkDisp2').checked;
    document.getElementById('MainContent_chkPctFunded3').disabled = !document.getElementById('MainContent_chkDisp3').checked;
    document.getElementById('MainContent_chkPctFunded4').disabled = !document.getElementById('MainContent_chkThreshold1').checked;
    document.getElementById('MainContent_chkPctFunded5').disabled = !document.getElementById('MainContent_chkThreshold2').checked;
}

function calcTotals() {
    var iTtl0 = 0;
    var iTtl1 = 0;
    var iTtl2 = 0;
    var iTtl3 = 0;
    var iTtl4 = 0;
    var iTtl5 = 0;
    var iLowestBFA = -1; var iBFALine = -1;
    var iLowestTFA = -1; var iTFALine = -1;
    var s = "";


    for (var i = 1; i < 31; i++) {
        //Format negative values red
        for (var j = 0; j < 13; j++) {
            if (j != 1) {
                if (document.getElementById('txt' + i + '_' + j).value.indexOf('-') > -1) {
                    document.getElementById('txt' + i + '_' + j).style.color = "red";
                }
                else {
                    document.getElementById('txt' + i + '_' + j).style.color = "#000000";
                }
            }
        }

        iTtl0 = iTtl0 + fmtNum(document.getElementById('txt' + i + '_0').value);
        iTtl1 = iTtl1 + fmtNum(document.getElementById('txt' + i + '_1').value);
        iTtl2 = iTtl2 + fmtNum(document.getElementById('txt' + i + '_3').value);
        iTtl3 = iTtl3 + fmtNum(document.getElementById('txt' + i + '_4').value);
        iTtl4 = iTtl4 + fmtNum(document.getElementById('txt' + i + '_6').value);
        iTtl5 = iTtl5 + fmtNum(document.getElementById('txt' + i + '_11').value);

        if (iLowestBFA == -1) {
            iBFALine = i;
            iLowestBFA = fmtNum(document.getElementById('txt' + i + '_7').value);
        }
        else {
            if (fmtNum(document.getElementById('txt' + i + '_7').value) < iLowestBFA) {
                iBFALine = i;
                iLowestBFA = fmtNum(document.getElementById('txt' + i + '_7').value);
            }
        }

        if (document.getElementById('MainContent_chkThreshold1').checked) {
            iTtl5 = iTtl5 + fmtNum(document.getElementById('txt' + i + '_8').value);
            if (iLowestTFA == -1) {
                iTFALine = i;
                iLowestTFA = fmtNum(document.getElementById('txt' + i + '_9').value);
            }
            else {
                if (fmtNum(document.getElementById('txt' + i + '_9').value) < iLowestTFA) {
                    iTFALine = i;
                    iLowestTFA = fmtNum(document.getElementById('txt' + i + '_9').value);
                }
            }
            iTtl5 = iTtl5 + fmtNum(document.getElementById('txt' + i + '_11').value);
            if (iLowestTFA == -1) {
                iTFALine = i;
                iLowestTFA = fmtNum(document.getElementById('txt' + i + '_12').value);
            }
            else {
                if (fmtNum(document.getElementById('txt' + i + '_12').value) < iLowestTFA) {
                    iTFALine = i;
                    iLowestTFA = fmtNum(document.getElementById('txt' + i + '_12').value);
                }
            }
        }
        document.getElementById('txt' + i + '_7').style.backgroundColor = "#ffffff";
        document.getElementById('txt' + i + '_9').style.backgroundColor = "#ffffff";
        document.getElementById('txt' + i + '_12').style.backgroundColor = "#ffffff";
    }
    document.getElementById('divTtl0').innerHTML = accounting.formatMoney(iTtl0, "$", 0, ",");
    document.getElementById('divTtl1').innerHTML = accounting.formatMoney(iTtl1, "$", 0, ",");
    document.getElementById('divTtl2').innerHTML = accounting.formatMoney(iTtl2, "$", 0, ",");
    document.getElementById('divTtl3').innerHTML = accounting.formatMoney(iTtl3, "$", 0, ",");
    document.getElementById('divTtl4').innerHTML = accounting.formatMoney(iTtl4, "$", 0, ",");
    if (document.getElementById('MainContent_chkThreshold1').checked) document.getElementById('divTtl6').innerHTML = accounting.formatMoney(iTtl5, "$", 0, ",");

    if (iBFALine != -1) document.getElementById('txt' + iBFALine + '_7').style.backgroundColor = "rgba(110, 186, 60, 0.52)";
    if (iTFALine != -1) document.getElementById('txt' + iTFALine + '_9').style.backgroundColor = "rgba(110, 186, 60, 0.52)";
    if (iTFALine != -1) document.getElementById('txt' + iTFALine + '_12').style.backgroundColor = "rgba(110, 186, 60, 0.52)";

    calcPctFunded();
}

function fmtNum(strNum) {
    var result = strNum.replace(/[$,]+/g, "");
    return parseFloat(result);
}

function checkThreshold() {
    if (isNaN(document.getElementById('MainContent_txtThresholdValue').value.replace(/[$,]+/g, ""))) {
        alert("Please enter a valid, numeric threshold value.");
        return false;
    }
    document.getElementById('MainContent_txtHdnType').value = 'Threshold';
    document.forms[0].submit();
}
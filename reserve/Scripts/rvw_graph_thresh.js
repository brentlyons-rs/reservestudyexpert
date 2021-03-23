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
        toggOpac(true);
        sOp = 'sendThreshold';
        var url = "ws.asmx/SaveReview?sTable=proj&sCrit=" + escape(sCrit) + "&sField=" + escape(sSqlField) + "&sVal=" + escape(sVal) + "&iRow=" + iRow + "&iCol=" + iCol + "&pd=y";
        gUrl = url;
        request.open("GET", url, true);
        request.onreadystatechange = updateSend;
        request.send(null);
    }
}

function sendThreshold(iRow, iYear, sVal) {
    if ((request.readyState != 4) && (request.readyState != 0)) {
        setTimeout("sendProjection('" + iRow + "'," + iYear + "," + sVal + ")", 3000);
    }
    else {
        toggOpac(true);
        sOp = 'sendThreshold';
        var url = "ws.asmx/SaveGraphThreshold?iRow=" + escape(iRow) + "&iYear=" + escape(iYear) + "&sVal=" + escape(sVal);
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
                if (sOp == 'sendThreshold') {
                    examineThreshold(XMLobj);
                }
            }
        }
        else if (request.status == 404)
            alert("Error connecting to the web service - request URL does not exist. If the problem persists, please contact an administrator.")
        else
            alert("Error connecting to the web service: status code is " + request.status + ". If the problem persists, please contact an administrator.")
    }
}

function examineThreshold(XMLObj) {
    var yr;
    if (XMLobj.getElementsByTagName('Results')[0].getElementsByTagName('r_type')[0].firstChild.nodeValue == 'Error') {
        alert("Error saving record. Please send the following error to an administrator: " + XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_desc')[0].firstChild.nodeValue);
    }
    if (XMLobj.getElementsByTagName('adjthresh').length > 0) {
        for (j = 0; j < XMLobj.getElementsByTagName('adjthresh').length; j++) {
            yr = XMLobj.getElementsByTagName('adjthresh')[j].getElementsByTagName('year_id')[0].firstChild.nodeValue;
            if (XMLobj.getElementsByTagName('adjthresh')[j].getElementsByTagName('pct_increase').length > 0) {
                document.getElementById('txt2_' + yr).value = XMLobj.getElementsByTagName('adjthresh')[j].getElementsByTagName('pct_increase')[0].firstChild.nodeValue;
                document.getElementById('hdn2_' + yr).value = XMLobj.getElementsByTagName('adjthresh')[j].getElementsByTagName('pct_increase')[0].firstChild.nodeValue;
            }
            else {
                document.getElementById('txt2_' + yr).value = '0.00';
                document.getElementById('hdn2_' + yr).value = '0.00';
            }
            if (XMLobj.getElementsByTagName('adjthresh')[j].getElementsByTagName('contrib').length > 0) {
                document.getElementById('txt1_' + yr).value = XMLobj.getElementsByTagName('adjthresh')[j].getElementsByTagName('contrib')[0].firstChild.nodeValue;
                document.getElementById('hdn1_' + yr).value = XMLobj.getElementsByTagName('adjthresh')[j].getElementsByTagName('contrib')[0].firstChild.nodeValue;
            }
            chart.data.datasets[0].data[j + 1] = XMLobj.getElementsByTagName('adjthresh')[j].getElementsByTagName('bal')[0].firstChild.nodeValue.replace('$', '').split(',').join('');
            //if (XMLobj.getElementsByTagName('adjthresh')[j].getElementsByTagName('bal').length > 0) {
            //    document.getElementById('txt' + (j + 1) + '_12').value = XMLobj.getElementsByTagName('adjthresh')[j].getElementsByTagName('bal')[0].firstChild.nodeValue;
            //    document.getElementById('hdnAnswer' + (j + 1) + '_12').value = XMLobj.getElementsByTagName('adjthresh')[j].getElementsByTagName('bal')[0].firstChild.nodeValue;
            //    chart.data.datasets[0].data[j + 1] = XMLobj.getElementsByTagName('adjthresh')[j].getElementsByTagName('bal')[0].firstChild.nodeValue;
            //}
        }
    }
    //for (j = 0; j < XMLobj.getElementsByTagName('Threshold').length; j++) {
    //    chart.data.datasets[0].data[j + 1] = XMLobj.getElementsByTagName('Threshold')[j].getElementsByTagName('bal')[0].firstChild.nodeValue;
    //    //document.getElementById('div' + XMLobj.getElementsByTagName('Threshold')[j].getElementsByTagName('year_id')[0].firstChild.nodeValue).innerHTML = '$' + numberWithCommas(XMLobj.getElementsByTagName('Threshold')[j].getElementsByTagName('bal')[0].firstChild.nodeValue);
    //    document.getElementById('hdn1_' + XMLobj.getElementsByTagName('Threshold')[j].getElementsByTagName('year_id')[0].firstChild.nodeValue).value = document.getElementById('txt1_' + XMLobj.getElementsByTagName('Threshold')[j].getElementsByTagName('year_id')[0].firstChild.nodeValue).value;
    //}
    chart.update();
    //document.forms[0].disabled = false;
    toggOpac(false);
    return true;
}

function numberWithCommas(x) {
    return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
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

function CheckRowChanges(sSqlField, sType, iRow, iYear) {
    var sVal = "";
    var iChg = 0;
    if (sType == 'textbox') {
        if (document.getElementById('txt' + iRow + '_' + iYear).value != document.getElementById('hdn' + iRow + '_' + iYear).value) {
            sVal = document.getElementById('txt' + iRow + '_' + iYear).value;
            sVal = sVal.replace('$', '');
            sVal = sVal.replace(',', '');
            iChg = 1;
        }
    }

    if (iChg == 1) {
        //sendThreshold(iRow, iYear, sVal);
        sendProjection('year_id=' + iYear, sSqlField, sVal, iRow, iYear);
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

function chkKeybd(sender, e, iRow, iYear) {
    var key = e.which ? e.which : e.keyCode;

    if (key == 37) { //left
        if (document.getElementById('txt' + iRow + '_' + (iYear-1)) != null) {
            if (getCaretPosition(sender) >= 0) document.getElementById('txt' + iRow + '_' + (iYear-1)).focus();
        }
    }
    else if ((key == 39) || (key == 13)) { //right
        if (document.getElementById('txt' + iRow + '_' + (iYear+1)) != null) {
            if (getCaretPosition(sender) >= 0) document.getElementById('txt' + iRow + '_' + (iYear+1)).focus();
        }
    }
    else if ((sender.type !== 'select-one') && (key == 38)) { //up
        if (document.getElementById('txt' + (iRow - 1) + '_' + iYear) != null) {
            document.getElementById('txt' + (iRow - 1) + '_' + iYear).focus();
        }
    }
    else if ((sender.type !== 'select-one') && ((key == 40) || (key == 13)) && (iRow != 0)) { //down
        if (document.getElementById('txt' + (iRow + 1) + '_' + iYear) != null) {
            document.getElementById('txt' + (iRow + 1) + '_' + iYear).focus();
        }
    }
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

function toggOpac(blMask) {
    if (blMask) {
        document.getElementById('tblThresh').style.opacity = ".2";
    }
    else {
        document.getElementById('tblThresh').style.opacity = "1";
    }
}
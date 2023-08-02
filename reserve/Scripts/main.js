var request;
var iSendState = 0;
var blGet = true;
var sArea = "";
var blCode = false;
var XMLobj;
var sOp = "";
var gUrl;

function sendAvailableRevs() {
    if ((request.readyState != 4) && (request.readyState != 0)) {
        setTimeout("sendAvailableRevs()", 3000);
    }
    else {
        var iTotal = parseInt(document.getElementById('txtHdnTotalRevs').value);
        var sAR = "";
        for (i = 0; i < iTotal; i++) {
            if (document.getElementById('chkRev' + i).checked) {
                if (sAR == "") {
                    sAR = sAR + document.getElementById('txtHdnChkRev' + i).value;
                }
                else {
                    sAR = sAR + "," + document.getElementById('txtHdnChkRev' + i).value;
                }
            }
        }
        sOp = 'sendAvailableRevs';
        var url = "api/main.asmx/SaveAvailableClientRevisions?availableRevs=" + sAR;
        gUrl = url;
        request.open("GET", url, true);
        request.onreadystatechange = updateSend;
        request.send(null);
    }
}

function deleteRevision(iRev, iRow) {
    if ((request.readyState != 4) && (request.readyState != 0)) {
        setTimeout("deleteRevision(" + iRev + ")", 3000);
    }
    else {
        sOp = 'deleteRevision';
        var url = "api/main.asmx/DeleteRevision?revId=" + iRev + "&iRow=" + iRow;
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
                if (sOp == 'sendAvailableRevs') {
                    examineAvailableRevs(XMLobj);
                }
                else if (sOp == 'deleteRevision') {
                    examineDeleteRevision(XMLobj);
                }
            }
        }
        else if (request.status == 404)
            alert("Error connecting to the web service - request URL does not exist. If the problem persists, please contact an administrator.")
        else
            alert("Error connecting to the web service: status code is " + request.status + ". If the problem persists, please contact an administrator.")
    }
}

function examineAvailableRevs(XMLObj) {
    for (j = 0; j < XMLobj.getElementsByTagName('Results').length; j++) {
        if (XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_type')[0].firstChild.nodeValue == 'Error') {
            alert("Error saving record. Please send the following error to an administrator: " + XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_desc')[0].firstChild.nodeValue);
            document.getElementById('lblRevStatus').innerHTML = 'Error saving record.';
        }
        if (XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_type')[0].firstChild.nodeValue == 'Success') {
            document.getElementById('lblRevStatus').innerHTML = 'Successfully updated revisions available to the client.';
        }
    }
    return true;
}

function examineDeleteRevision(XMLObj) {
    for (j = 0; j < XMLobj.getElementsByTagName('Results').length; j++) {
        if (XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_type')[0].firstChild.nodeValue == 'Error') {
            alert("Error deleting revision. Please send the following error to an administrator: " + XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_desc')[0].firstChild.nodeValue);
            document.getElementById('lblRevStatus').innerHTML = 'Error deleting revision.';
        }
        if (XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_type')[0].firstChild.nodeValue == 'Success') {
            document.getElementById('lblRevStatus').innerHTML = 'Successfully deleted revision.';
            var iRow = XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('iRow')[0].firstChild.nodeValue;
            document.getElementById('trRev' + iRow).style.display = 'none';
        }
    }
    return true;
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

    var request;
    var iSendState = 0;
    var blGet = true;
    var sArea = "";
    var blCode = false;
    var XMLobj;
    var sOp = "";
    var gUrl;
    
    function sendTM(iTable, sCrit, sSqlField, sVal, iRow, iCol) {
	    if ((request.readyState!=4) && (request.readyState!=0)) {
            setTimeout("sendTM(" + iRow + ", '" + sSqlField + "', '" + sVal + "'," + iRow + "," + iCol + ")", 3000);
        }
	    else {
            sOp = 'sendTM';
            var url = "ws.asmx/SaveTM?iTbl=" + iTable + "&sCrit=" + escape(sCrit) + "&sField=" + escape(sSqlField) + "&sVal=" + escape(sVal) + "&iRow=" + iRow + "&iCol=" + iCol + "&pd=y";
            gUrl = url;
            request.open("GET", url, true);
            request.onreadystatechange = updateSend;
            request.send(null);
        }
    }

    //function sendComponent(sCrit, sSqlField, sVal, iRow, iCol) {
	   // if ((request.readyState!=4) && (request.readyState!=0)) {
    //        setTimeout("sendComponent(" + iRow + ", '" + sSqlField + "', '" + sVal + "'," + iRow + "," + iCol + ")", 3000);
    //    }
	   // else {
    //        sOp = 'sendTM';
    //        var url="ws.asmx/SaveComponent?sCrit=" + escape(sCrit) + "&sField=" + escape(sSqlField) + "&sVal=" + escape(sVal) + "&iRow=" + iRow + "&iCol=" + iCol + "&pd=y";
    //        gUrl = url;
    //        request.open("GET", url, true);
    //        request.onreadystatechange = updateSend;
    //        request.send(null);
    //    }
    //}


function updateSend() {
    if (request.readyState == 4) {
		if (request.status == 200) {
			var Mime = request.getResponseHeader('Content-Type');
            Mime = Mime.toString();
			if(request.responseXML != null) {
                XMLobj = request.responseXML;
            }
			else if((Mime.indexOf('text/xml') == -1) || (Mime.indexOf('application/xml') == -1)) {
				try {
                    XMLobj = createXMLParser(request.responseText);
                }
				catch(e) {
                    alert("Not good: " + e);
                    XMLobj = request.responseText;
                }
            }
			else {
                alert("No XML!");
                var TEXTobj = request.responseText;
            }
		if (XMLobj!=null) {
            if (sOp=='sendTM') {
                examineTM(XMLobj);
            }
        }
    }
    else if (request.status == 404)
        alert("Error connecting to the web service - request URL does not exist. If the problem persists, please contact an administrator.")
    else
        alert("Error connecting to the web service: status code is " + request.status + ". If the problem persists, please contact an administrator.")
    }
}

function examineTM(XMLObj) {
    var iRow=-1;
    var iCol=-1;
	for (j=0; j<XMLobj.getElementsByTagName('Results').length; j++) {
        iRow = XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('i_row')[0].firstChild.nodeValue;
        iCol=XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('i_col')[0].firstChild.nodeValue;

        if (XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_type')[0].firstChild.nodeValue=='Error') {
            alert("Error saving record. Please send the following error to an administrator: " + XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_desc')[0].firstChild.nodeValue); 
            document.getElementById('MainContent_lblStatus').innerHTML='Error saving record.';
        }
        if (XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_type')[0].firstChild.nodeValue=='Reject') {
            alert(XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_desc')[0].firstChild.nodeValue);
            document.getElementById('MainContent_lblStatus').innerHTML='Could not save record.';
}
        if (XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_type')[0].firstChild.nodeValue=='Success') {
            if (XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_desc')[0].firstChild==null) {
                document.getElementById('hdnAnswer' + iRow + '_' + iCol).value = '';
            }
            else {
                document.getElementById('hdnAnswer' + iRow + '_' + iCol).value = XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_desc')[0].firstChild.nodeValue;
            }
            document.getElementById('MainContent_lblStatus').innerHTML='Successfully updated ' + XMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_field')[0].firstChild.nodeValue + '.';
        }
    }
    document.forms[0].disabled=false;
    UpdateRowHeader(iRow,'None');
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

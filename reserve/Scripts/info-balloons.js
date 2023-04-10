var balloonRequest;
var balloonXMLobj;
var curBalloon = -1;
var curField = "";
const balloons = [];

function sendBalloonText() {
    if ((balloonRequest.readyState != 4) && (balloonRequest.readyState != 0)) {
        setTimeout("sendBalloonText(" + iBalloonPage + ", " + iId + ", '" + sText + "')", 3000);
    }
    else {
        document.getElementById('divSaveBalloon').style.display = 'block';
        sText = document.getElementById('txtBalloon').value;
        var url = "ws.asmx/SaveBalloon?iPage=" + iBalloonPage + "&iId=" + curBalloon + "&sField=" + escape(curField) + "&sText=" + escape(sText) + "&pd=y";
        balloonRequest.open("GET", url, true);
        balloonRequest.onreadystatechange = updateSendBalloon;
        balloonRequest.send(null);
    }
}


function updateSendBalloon() {
    if (balloonRequest.readyState == 4) {
        if (balloonRequest.status == 200) {
            var Mime = balloonRequest.getResponseHeader('Content-Type');
            Mime = Mime.toString();
            if (balloonRequest.responseXML != null) {
                balloonXMLobj = balloonRequest.responseXML;
            }
            else if ((Mime.indexOf('text/xml') == -1) || (Mime.indexOf('application/xml') == -1)) {
                try {
                    balloonXMLobj = createXMLParser(balloonRequest.responseText);
                }
                catch (e) {
                    alert("Not good: " + e);
                    balloonXMLobj = balloonRequest.responseText;
                }
            }
            else {
                alert("No XML!");
                var TEXTobj = balloonRequest.responseText;
            }
            if (balloonXMLobj != null) {
                examineBalloonResponse(balloonXMLobj);
            }
        }
        else if (balloonRequest.status == 404)
            alert("Error connecting to the web service - request URL does not exist. If the problem persists, please contact an administrator.")
        else
            alert("Error connecting to the web service: status code is " + balloonRequest.status + ". If the problem persists, please contact an administrator.")
    }
}

function examineBalloonResponse(balloonXMLobj) {
    for (j = 0; j < balloonXMLobj.getElementsByTagName('Results').length; j++) {
        if (balloonXMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_type')[0].firstChild.nodeValue == 'Error') {
            alert("Error saving record. Please send the following error to an administrator: " + balloonXMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_desc')[0].firstChild.nodeValue);
        }
        if (balloonXMLobj.getElementsByTagName('Results')[j].getElementsByTagName('r_type')[0].firstChild.nodeValue == 'Success') {
            document.getElementById('divSaveBalloon').innerHTML = 'Success.';
            balloons[curBalloon] = document.getElementById('txtBalloon').value;
        }
    }
    document.getElementById('divSaveBalloon').style.display = 'none';
    //document.getElementById('balloonTooltipAdmin').style.display = 'none';
    fadeOutBalloon();
    return true;
}


function showBalloon(obj, iElem) {
    curBalloon = iElem;
    var rect = obj.getBoundingClientRect();
    var newTop = rect.top + window.scrollY - 10;
    var newLeft = rect.left + window.scrollX + 19;
    if (newLeft < 50) {
        newLeft = 110;
    }
    document.getElementById('balloonTooltip').style.left = newLeft + 'px';
    document.getElementById('balloonTooltip').style.top = newTop + 'px';
    if (balloons[iElem] != undefined) {
        document.getElementById('balloonText').innerHTML = balloons[iElem];
    }
    else {
        document.getElementById('balloonText').innerHTML = '';
    }
    document.getElementById('balloonTooltip').style.display = 'block';
}

function hideBalloon() {
    document.getElementById('balloonTooltip').style.display = 'none';
}

function showBalloonAdmin(obj, iElem, sField) {
    curBalloon = iElem;
    curField = sField;
    var rect = obj.getBoundingClientRect();
    var newTop = rect.top + window.scrollY - 10;
    var newLeft = rect.left + window.scrollX + 19;
    if (newLeft < 50) {
        newLeft = 110;
    }
    document.getElementById('balloonTooltipAdmin').style.left = newLeft + 'px';
    document.getElementById('balloonTooltipAdmin').style.top = newTop + 'px';
    if (balloons[iElem] != undefined) {
        document.getElementById('txtBalloon').value = balloons[iElem];
    }
    else {
        document.getElementById('txtBalloon').value = '';
    }
    document.getElementById('balloonTooltipAdmin').style.display = 'block';
    document.getElementById("balloonTooltipAdmin").style.opacity = 1;
}

function fadeOutBalloon() {
    var fadeTarget = document.getElementById("balloonTooltipAdmin");
    var fadeEffect = setInterval(function () {
        if (!fadeTarget.style.opacity) {
            fadeTarget.style.opacity = 1;
        }
        if (fadeTarget.style.opacity > 0) {
            fadeTarget.style.opacity -= 0.1;
        } else {
            clearInterval(fadeEffect);
        }
    }, 50);
}

try {
    balloonRequest = new XMLHttpRequest(); //recordset
}
catch (trymicrosoft) {
    try {
        balloonRequest = new ActiveXObject("Msxml2.XMLHTTP");
    }
    catch (othermicrosoft) {
        try {
            balloonRequest = new ActiveXObject("Microsoft.XMLHTTP");
        }
        catch (failed) {
            balloonRequest = false;
        }
    }
}
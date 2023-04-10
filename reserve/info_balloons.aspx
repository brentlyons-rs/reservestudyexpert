<script src="Scripts/info-balloons.js"></script>
<script>
    <% Response.Write(reserve.GenerateInfoBalloons.GenerateInfoBalloonScript(iBalloonPage)); %>
</script>
<div id="balloonTooltip" class="balloon-popup" style="display: none">
    <span id="balloonText"></span>
</div>
<div id="balloonTooltipAdmin" class="balloon-popup" style="display: none" align="left">
    <input type="text" id="txtBalloon" name="txtBalloon" size="40" style="color: #000000" /><br />
    <input type="button" class="btn btn-success" value="Save" id="cmdSaveBalloonText" onclick="sendBalloonText()" />
    <a href="#" onclick="javascript: document.getElementById('balloonTooltipAdmin').style.display='none'" style="vertical-align: middle"><font color="#ffffff" style="padding-bottom: 20px">Cancel</font></a>
    <span id="divSaveBalloon" class="frm-text" style="display: none; font-weight: 500; color: #ffffff"><i class="fa fa-spinner fa-pulse fa-fw"></i>&nbsp;Saving, please wait...</span>
</div>

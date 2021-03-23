<html>
<body>
<% if lcase(Request.Form("txtPW")) = "cats" then Session("SiteAdmin") = "Y" %>
<% if Session("SiteAdmin") = "" then %>
<form name="frmAdmin" id="frmAdmin" method="POST" action="siteadmin.asp">
<font face=arial size=1><b>
Password: <input type="password" id=txtPW name=txtPW style="FONT-SIZE: xx-small"><input type="submit" value="go" id=cmdGo name=cmdGo style="FONT-SIZE: xx-small">
</form>
<%
else

Response.Expires=-1

dim conn
dim myTempRS, i, sql_string, iCols, j
dim myRS, myCompareRS
dim strDB, strTable, strStatus, strErr, strPK, strPKDesc, strItem, strSql, iPK, iRow, strColor, blFound

if Request.Form("txtDB")<>"" then
	strDB=Request.Form("txtDB")
else
	strDB="reserve"
end if

set conn = server.CreateObject("ADODB.Connection")
'conn.Open "Provider=SQLOLEDB.1;Server=BRLY\SQLExpress;Database=reserve;Trusted_Connection=yes;"
conn.Open "Provider=SQLOLEDB.1;Server=.\MSSQLSERVER2017;Database=crossove_reserve;UID=app_reserve;Password=@x6x0zN3;"

set myTempRS = server.CreateObject("ADODB.Recordset")

if Request.Form("txtSQL") <> "" then
	sql_string = Request.Form("txtSQL")
else
	sql_string = "Select getdate()"
	strTable = "app_users"
end if

if strTable = "" then
	if instr(instr(1,lcase(sql_string),"from")+5,sql_string," ") = 0 then
		strTable = mid(sql_string,instr(1,lcase(sql_string),"from")+5,len(sql_string)-instr(1,lcase(sql_string),"from")+5)
	else
		strTable = mid(sql_string,instr(1,lcase(sql_string),"from")+5,instr(instr(1,lcase(sql_string),"from")+5,sql_string," ")-(instr(1,lcase(sql_string),"from")+5))
	end if
end if
%>
<form name="frmAdmin" id="frmAdmin" method="POST" action="siteadmin.asp">
<font face=arial size=1><b>
<table border=0 cellspacing=1 cellpadding=1 bgcolor=#ffffff width=100%>
	<tr>
		<td width=1% bgcolor=#eeeeee><font face=arial size=1 style="FONT-SIZE: 8pt">DB:</td>
		<td width=99% bgcolor=#eeeeee><input type="text" id=txtDB name=txtDB style="FONT-SIZE: xx-small" value="<%=strDB%>"><input type="submit" value="go" id=cmdGo name=cmdGo style="FONT-SIZE: xx-small"></td>
	</tr>
	<tr>
		<td bgcolor=#eeeeee><font face=arial size=1 style="FONT-SIZE: 8pt">SQL:</td>
		<td bgcolor=#eeeeee><input type="text" id=txtSQL name=txtSQL style="FONT-SIZE: xx-small" value="<%=sql_string%>" size=80></td>
	</tr>
	<tr>
		<td bgcolor=#eeeeee><font face=arial size=1 style="FONT-SIZE: 8pt"><a href="#" onclick="document.frmAdmin.txtHdnType.value='SP'; document.frmAdmin.submit()">SPs:</a></td>
		<td bgcolor=#eeeeee>
		<% 
		if Request.Form("txtHdnType")="SP" then 
		myTempRS.Open "select distinct so.id, su.name as uname, so.name as spname from sysobjects so inner join sysusers su on so.uid=su.uid inner join syscomments sc on so.id=sc.id where so.xtype='P' and so.name not like 'dt_%' order by so.name", conn, 3, 4
		%>
		<select id="lstSP" name="lstSP" style="FONT-SIZE: 8pt" size=5>
		<%
		do until myTempRS.EOF
			Response.Write("<option value=" & chr(34) & myTempRS("id") & chr(34) & ">" & myTempRS("uname") & "." & myTempRS("spname") & "</option>" & chr(34))
			myTempRS.MoveNext
		loop
		myTempRS.Close
		%>
		</select><br>
		<input type="button" value="Edit SQL" id=cmdSPEdit name=cmdSPEdit style="FONT-SIZE: 8pt">
		<% end if %>
		</td>
	</tr>
</table>
<%
set myRS = server.CreateObject("ADODB.Recordset")
set myCompareRS = server.CreateObject("ADODB.Recordset")

'if Request.QueryString("Table") <> "" then
'	strTable = Request.QueryString("Table")
'elseif Request.Form("lstTables") <> "" then
'	strTable = Request.Form("lstTables")
'end if

if Request.Form("lstItems") <> "" then
	strItem = Request.Form("lstItems")
end if

if Request.Form("txtHdnType") = "Add" then
	on error resume next
	myRS.Open  "Select Top 1 * from " & strTable, conn, 1, 3
	myRS.AddNew
	for i = 0 to myRS.Fields.Count - 1
		if Request.Form("txtNew" & i) <> "" then myRS.Fields(i).Value = Request.Form("txtNew" & i)
	next
	myRS.Update
	if err.number <> 0 then 
		myRS.CancelUpdate
		strErr = "There was an error adding your record: " & err.number & ": " & err.Description
	else
		strErr = "Successfully added record."
	end if
	myRS.Close
	on error goto 0
	strStatus = "Saved"
elseif Request.Form("txtHdnType") = "Save" then
	on error resume next
	myRS.Open  "Select * from " & strTable & " Where " & Request.Form("txtHdn" & Request.Form("txtHdnRow")), conn, 1, 3
	if not myRS.EOF then
		for i = 0 to myRS.Fields.Count - 1
			if Request.Form("txt" & i) <> "" then
				myRS.Fields(i).Value = Request.Form("txt" & i)
			else
				myRS.Fields(i).Value = null
			end if
		next
		myRS.Update
		strStatus = "Saved"
	else
		strStatus = "NotFound"
	end if
	myRS.Close
	if err.number <> 0 then
		strErr = "There was an error saving your record: " & err.number & ": " & err.Description
	else
		strErr = "Successfully saved record."
	end if
	on error goto 0
elseif Request.Form("txtHdnType") = "Del" then
	on error resume next
	conn.Execute("Delete from " & strTable & " Where " & Request.Form("txtHdn" & Request.Form("txtHdnRow")))
	if err.number <> 0 then
		strErr = "There was an error deleting your record: " & err.number & ": " & err.Description
	else
		strErr = "Successfully removed record."
	end if
	on error goto 0
end if
%>
<html>
<script LANGUAGE="javascript">
<!--
function ConfirmDel(iRow) {
	if (confirm("Are you sure you want to PERMANENTLY remove this record?")==1) {
		document.frmAdmin.txtHdnRow.value=iRow
		document.frmAdmin.txtHdnType.value='Del'
		document.frmAdmin.submit()
	}
}
//-->
</script>
<style>
FORM
{
    MARGIN: 0px
}
.textbox
{
    BORDER-RIGHT: #555555 1px solid;
    PADDING-RIGHT: 1px;
    BORDER-TOP: #555555 1px solid;
    PADDING-LEFT: 1px;
    FONT-SIZE: 8pt;
    BACKGROUND: #ffffff;
    PADDING-BOTTOM: 1px;
    BORDER-LEFT: #555555 1px solid;
    COLOR: 000000;
    PADDING-TOP: 1px;
    BORDER-BOTTOM: #555555 1px solid
}
</style>
<input type="hidden" id="txtType" name="txtType">
<% if strErr <> "" then %>
<font face="arial" size="1" color="red" style="FONT-SIZE: 8pt"><%=strErr%>
<% end if %>
<% if strTable <> "" then
'Get indexes
myRS.Open  "SELECT sysobjects.id AS TABLE_ID, sysobjects.name AS TABLE_NAME, sysindexes.name AS INDEX_NAME, syscolumns.name AS COL_NAME FROM sysobjects INNER JOIN sysindexes ON sysobjects.id = sysindexes.id INNER JOIN sysindexkeys ON sysindexes.id = sysindexkeys.id AND sysindexes.indid = sysindexkeys.indid INNER JOIN syscolumns ON sysindexkeys.id = syscolumns.id AND sysindexkeys.colid = syscolumns.colid INNER JOIN sysobjects sysobjects_1 ON sysindexes.name = sysobjects_1.name WHERE     (sysobjects.type = 'U') AND (sysobjects_1.xtype = 'PK') AND (sysobjects.name = '" & strTable & "')", conn, 3, 4
strPK = ""
do until myRS.EOF
	strPK = strPK & "[" & myRS("COL_Name") & "], "
	myRS.MoveNext
loop
myRS.Close
'Display the records
'myRS.Open  "Select * From " & strTable, conn, 3, 4
myRS.Open sql_string, conn, 3, 4
if Request.Form("txtHdnType") = "Edit" then
	myCompareRS.Open  "Select * from " & strTable & " Where " & Request.Form("txtHdn" & Request.Form("txtHdnRow")), conn, 3, 4
else
	myCompareRS.Open  "Select Top 0 * From " & strTable, conn, 3, 4
end if
%>
<font color="#000000"><br>
<table border="0" cellspacing="1" cellpadding="1" bgcolor="#92aedf">
	<tr>
		<td bgcolor="#dddddd" colspan="<%=myRS.Fields.count+2%>"><font face="arial" size="1" color="#555555" style="FONT-SIZE: 8pt"><b>:: Add New Record
	</tr>
	<tr>
		<td style="BACKGROUND-IMAGE: url('images/tbl_header.jpg'); HEIGHT: 25px"><font face="arial" size="1" color="#555555" style="FONT-SIZE: 8pt"><b>Add</td>
		<%
		for i = 0 to myRS.Fields.Count-1
			if instr(1,strPK,"[" & myRS.Fields(i).Name & "]") > 0 then
				Response.Write("<td style=""BACKGROUND-IMAGE: url('images/tbl_header.jpg'); HEIGHT: 25px"" nowrap><font face=arial size=1 color=red style=""FONT-SIZE: 8pt""><b>" & myRS.Fields(i).Name & "</td>" & vbCrLf)
			else
				Response.Write("<td style=""BACKGROUND-IMAGE: url('images/tbl_header.jpg'); HEIGHT: 25px"" nowrap><font face=arial size=1 color=#555555 style=""FONT-SIZE: 8pt""><b>" & myRS.Fields(i).Name & "</td>" & vbCrLf)
			end if
		next
		%>
		<td style="BACKGROUND-IMAGE: url('images/tbl_header.jpg'); HEIGHT: 25px"><font face="arial" size="1" color="#555555" style="FONT-SIZE: 8pt"><b>Add</td>
	</tr>
	<tr>
		<td bgcolor="#dddddd" align="center"><font face="arial" size="1"><a href="JavaScript: document.frmAdmin.txtHdnType.value='Add'; document.frmAdmin.submit()"><img src="images/tm_save.jpg" border="0" align="absmiddle" WIDTH="15" HEIGHT="15"></a></td>
		<%
		for i = 0 to myRS.Fields.Count-1
			Response.Write("<td bgcolor=#dfefff><font face=arial size=1 color=#555555 style=""FONT-SIZE: 8pt""><input type=""text"" id=txtNew" & i & " name=txtNew" & i & " class=""textbox""></td>" & vbCrLf)
		next
		%>
		<td bgcolor="#dddddd" align="center"><font face="arial" size="1"><a href="JavaScript: document.frmAdmin.txtHdnType.value='Add'; document.frmAdmin.submit()"><img src="images/tm_save.jpg" border="0" align="absmiddle" WIDTH="15" HEIGHT="15"></a></td>
	</tr>
</table>
<br>
<table border="0" cellspacing="1" cellpadding="1" bgcolor="#92aedf">
	<tr>
		<td bgcolor="#dddddd" colspan="<%=myRS.Fields.count+2%>"><font face="arial" size="1" color="#555555" style="FONT-SIZE: 8pt"><b>:: Edit Records
	</tr>
	<tr>
		<td style="BACKGROUND-IMAGE: url('images/tbl_header.jpg'); HEIGHT: 25px"><font face="arial" size="1" color="#555555" style="FONT-SIZE: 8pt"><b>View</td>
		<td style="BACKGROUND-IMAGE: url('images/tbl_header.jpg'); HEIGHT: 25px"><font face="arial" size="1" color="#555555" style="FONT-SIZE: 8pt"><b>Del</td>
		<%
		for i = 0 to myRS.Fields.Count-1
			if instr(1,strPK,"[" & myRS.Fields(i).Name & "]") > 0 then
				Response.Write("<td style=""BACKGROUND-IMAGE: url('images/tbl_header.jpg'); HEIGHT: 25px"" nowrap><font face=arial size=1 color=red style=""FONT-SIZE: 8pt""><b>" & myRS.Fields(i).Name & "</td>" & vbCrLf)
			else
				Response.Write("<td style=""BACKGROUND-IMAGE: url('images/tbl_header.jpg'); HEIGHT: 25px"" nowrap><font face=arial size=1 color=#555555 style=""FONT-SIZE: 8pt""><b>" & myRS.Fields(i).Name & "</td>" & vbCrLf)
			end if
		next
		%>
	</tr>
	<%
	iRow = 0
	do until myRS.EOF
		strSql = ""
		Response.Write("<tr>" & vbCrLf)
		'See if this is the row they selected
		blFound = false
		if not myCompareRS.EOF then
			blFound = true
			for j = 0 to myCompareRS.Fields.count - 1
				if myCompareRS.Fields(j).Value & "" <> myRS.Fields(j).Value & "" then
					blFound = false
					exit for
				end if
			next
		end if
		if blFound then
			strColor = "#dfefff"
			Response.Write("<td bgcolor=""#dddddd"" align=center><font face=arial size=1><a href=""JavaScript: document.frmAdmin.txtHdnRow.value='" & iRow & "'; document.frmAdmin.txtHdnType.value='Save'; document.frmAdmin.submit()""><img src=""images/tm_save.jpg"" border=0 align=absmiddle></a></td>" & vbCrLf)
		else
			strColor = "#ffffff"
			Response.Write("<td bgcolor=""#dddddd"" align=center><font face=arial size=1><a href=""JavaScript: document.frmAdmin.txtHdnRow.value='" & iRow & "'; document.frmAdmin.txtHdnType.value='Edit'; document.frmAdmin.submit()""><img src=""images/tm_edit.jpg"" border=0 align=absmiddle></a></td>" & vbCrLf)
		end if
		Response.Write("<td bgcolor=""#dddddd"" align=center><font face=arial size=1><a href=""JavaScript: ConfirmDel('" & iRow & "')""><img src=""images/x_white.jpg"" border=0 align=absmiddle></a></td>" & vbCrLf)
		for i = 0 to myRS.Fields.Count-1
			if blFound then
				Response.Write("<td bgcolor=" & strColor & "><font face=arial size=1 color=#555555 style=""FONT-SIZE: 8pt""><input type=""text"" id=txt" & i & " name=txt" & i & " value=" & chr(34) & myRS.Fields(i).Value & chr(34) & " class=""textbox""></td>" & vbCrLf)
			else
				if lcase(myRS.Fields(i).Name) = "imgurl" then
					Response.Write("<td bgcolor=" & strColor & "><font face=arial size=1 color=#555555 style=""FONT-SIZE: 8pt""><img src=" & chr(34) & myRS.Fields(i).Value & chr(34) & " align=left border=0>" & myRS.Fields(i).Value & "</td>" & vbCrLf)
				else
					Response.Write("<td bgcolor=" & strColor & "><font face=arial size=1 color=#555555 style=""FONT-SIZE: 8pt"">" & myRS.Fields(i).Value & "</td>" & vbCrLf)
				end if
			end if
			'Generate sql criteria
			if instr(1,strPK,"[" & myRS.Fields(i).Name & "]") > 0 then
				if strSql = "" then
					if not isnull(myRS.Fields(i).Value) then
						strSql = myRS.Fields(i).Name & "='" & Replace(myRS.Fields(i).Value,"'","''") & "'"
					else
						strSql = myRS.Fields(i).Name & "='" & myRS.Fields(i).Value & "'"
					end if
				else
					strSql = strSql & " and " & myRS.Fields(i).Name & "='" & replace(myRS.Fields(i).Value,"'","''") & "'"
				end if
			end if
		next
		Response.Write("<input type=""hidden"" id=txtHdn" & iRow & " name=txtHdn" & iRow & " value=" & chr(34) & strSql & chr(34) & ">")
		Response.Write("</tr>" & vbCrLf)
		myRS.MoveNext
		iRow = iRow + 1
	loop
	myRS.Close
	%>
</table>
<% end if %>
<input type="hidden" id="txtHdnType" name="txtHdnType">
<input type="hidden" id="txtHdnRow" name="txtHdnRow">
<font face=verdana size=1><b><%=iRow%></b> rows.
</form>
<% end if %>
</body>
</html>
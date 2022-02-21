<cfsetting enablecfoutputonly="yes">
<!--- Version 3.5.0 --->
<!---	3.5.0 06/28/99 
		3.2.0 09/16/98 --->
<!--- customimport.cfm --->

<cfset securepage="customimport.cfm">
<cfinclude template="security.cfm">
<cfparam name="pathimport" default="#billpath#temp#OSType#">
<cfif (IsDefined("delone")) AND (IsDefined("DeleteImport.x"))>
	<cfquery datasource="#pds#">
		DELETE FROM CustomImport 
		WHERE ciid In (#delone#)
	</cfquery>
</cfif>
<cfif IsDefined("enternew.x")>
	<cfset locpath = Trim(path1)>
	<cfset front1 = Left(locpath, 1)>
	<cfif (front1 is not "/") AND (front1 is not "\")>
		<cfset locpath = OSType & locpath>
	</cfif>
	<cfset back1 = Right(locpath, 1)>
	<cfif (back1 is not "/") AND (back1 is not "\")>
		<cfset locpath = locpath & OSType>
	</cfif>
	<cfquery name="inputnew" datasource="#pds#">
		INSERT INTO customimport 
		(activeyn,ftpyn,server1,path1,filename1,ftplogin,ftppassword,usetab, CAuthID) 
		VALUES 
		(#ActiveYN#,#FTPYN#,'#Trim(Server1)#','#locpath#','#Trim(Filename1)#',
		<cfif Trim(ftplogin) is "">Null<cfelse>'#Trim(ftplogin)#'</cfif>,
		<cfif Trim(ftppassword) is "">Null<cfelse>'#Trim(ftppassword)#'</cfif>,1, #CAuthID#)
	</cfquery>
</cfif>
<cfif IsDefined("editold.x")>
	<cfset locpath = Trim(path1)>
	<cfset front1 = Left(locpath, 1)>
	<cfif (front1 is not "/") AND (front1 is not "\")>
		<cfset locpath = OSType & locpath>
	</cfif>
	<cfset back1 = Right(locpath, 1)>
	<cfif (back1 is not "/") AND (back1 is not "\")>
		<cfset locpath = locpath & OSType>
	</cfif>
	<cfquery name="updateold" datasource="#pds#">
		UPDATE CustomImport SET 
		ActiveYN = #ActiveYN#, ftpyn = #ftpyn#,
		server1 = '#Trim(server1)#', path1 = '#locpath#',
		filename1 = '#Trim(filename1)#', 
		CAuthID = #CAuthID#, 
		ftplogin = <cfif Trim(ftplogin) is "">Null<cfelse>'#Trim(ftplogin)#'</cfif>,
		ftppassword = <cfif Trim(ftppassword) is "">Null<cfelse>'#Trim(ftppassword)#'</cfif>
		WHERE ciid = #ciid#
	</cfquery>
</cfif>
<cfif IsDefined("UpdatePath.x")>
	<cfquery name="DelFirst" datasource="#pds#">
		DELETE FROM Setup 
		WHERE varname = 'pathimport' 
		OR varname = 'cpds'
	</cfquery>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT * 
		FROM CustomImport 
		WHERE filename1 = 'cpds' 
	</cfquery>
	<cfif CheckFirst.RecordCount gt 0>
		<cfquery name="upd2" datasource="#pds#">
			UPDATE CustomImport SET 
			Path1 = '#cpds#' 
			WHERE FileName1 = 'cpds'
		</cfquery>
	<cfelse>
		<cfquery name="ins1" datasource="#pds#">
			INSERT INTO CustomImport 
			(FileName1, Path1, UseTab, ActiveYN, CAuthID) 
			VALUES 
			('cpds', '#cpds#',0,1,0)
		</cfquery>
	</cfif>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT * 
		FROM CustomImport 
		WHERE filename1 = 'cTable' 
	</cfquery>
	<cfif CheckFirst.RecordCount gt 0>
		<cfquery name="upd2" datasource="#pds#">
			UPDATE CustomImport SET 
			Path1 = '#cTable#' 
			WHERE FileName1 = 'cTable' 
		</cfquery>
	<cfelse>
		<cfquery name="ins1" datasource="#pds#">
			INSERT INTO CustomImport 
			(FileName1, Path1, UseTab, ActiveYN, CAuthID) 
			VALUES 
			('cTable', '#cTable#',0,1,0)
		</cfquery>
	</cfif>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT * 
		FROM CustomImport 
		WHERE filename1 = 'cLogin' 
	</cfquery>
	<cfif CheckFirst.RecordCount gt 0>
		<cfquery name="upd2" datasource="#pds#">
			UPDATE CustomImport SET 
			Path1 = <cfif cLogin Is "">Null<cfelse>'#cLogin#'</cfif> 
			WHERE FileName1 = 'cLogin' 
		</cfquery>
	<cfelse>
		<cfquery name="ins1" datasource="#pds#">
			INSERT INTO CustomImport 
			(FileName1, Path1, UseTab, ActiveYN, CAuthID) 
			VALUES 
			('cLogin', <cfif cLogin Is "">Null<cfelse>'#cLogin#'</cfif>,0,1,0)
		</cfquery>
	</cfif>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT * 
		FROM CustomImport 
		WHERE filename1 = 'cPasswd' 
	</cfquery>
	<cfif CheckFirst.RecordCount gt 0>
		<cfquery name="upd2" datasource="#pds#">
			UPDATE CustomImport SET 
			Path1 = <cfif cPasswd Is "">Null<cfelse>'#cPasswd#'</cfif> 
			WHERE FileName1 = 'cPasswd' 
		</cfquery>
	<cfelse>
		<cfquery name="ins1" datasource="#pds#">
			INSERT INTO CustomImport 
			(FileName1, Path1, UseTab, ActiveYN, CAuthID) 
			VALUES 
			('cPasswd', <cfif cPasswd Is "">Null<cfelse>'#cPasswd#'</cfif>,0,1,0)
		</cfquery>
	</cfif>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT * 
		FROM CustomImport 
		WHERE filename1 = 'pathimport' 
	</cfquery>
	<cfset thepathimport = Trim(pathimport)>
	<cfset end1 = Right(thepathimport, 1)>
	<cfif (end1 is not "/") AND (end1 is not "\")>
		<cfset thepathimport = thepathimport & OSType>
	<cfelse>
		<cfset thepathimport = Trim(pathimport)>
	</cfif>
	<cfif CheckFirst.RecordCount gt 0>
		<cfquery name="upd2" datasource="#pds#">
			UPDATE CustomImport SET 
			Path1 = '#thepathimport#' 
			WHERE FileName1 = 'pathimport'
		</cfquery>
	<cfelse>
		<cfquery name="ins1" datasource="#pds#">
			INSERT INTO CustomImport 
			(FileName1,Path1,UseTab,ActiveYN) 
			VALUES 
			('pathimport', '#thepathimport#',0,1)
		</cfquery>
	</cfif>
	<cfloop index="B5" from="1" to="#LoopCount#">
		<cfset var1 = Evaluate("CIID#B5#")>
		<cfset var2 = Evaluate("Path1#B5#")>
		<cfset var3 = Evaluate("FieldType#B5#")>
		<cfquery name="UpdData" datasource="#pds#">
			UPDATE CustomImport SET 
			Path1 = <cfif var2 Is "">Null<cfelse>'#var2#'</cfif>, 
			FieldType = '#var3#' 
			WHERE CIID = #var1#
		</cfquery>
	</cfloop>
</cfif>

<cfparam name="tab" default="1">
<cfparam name="HowWide" default="2">

<cfif tab Is 1>
	<cfset HowWide = 8>
	<cfquery name="getallinfo" datasource="#pds#">
		SELECT C.*, A.AuthDescription 
		FROM CustomImport C, CustomAuth A 
		WHERE A.CAuthID = C.CAuthID 
		AND C.UseTab = 1 
		ORDER BY C.FileName1
	</cfquery>
<cfelseif tab Is 2>
	<cfset HowWide = 3>
	<cfquery name="getallfields" datasource="#pds#">
		SELECT * 
		FROM CustomImport 
		WHERE UseTab = 2 
		ORDER BY FileName1 
	</cfquery>
	<cfquery name="getpath" datasource="#pds#">
		SELECT * 
		FROM CustomImport 
		WHERE UseTab = 0 
		AND FileName1 = 'pathimport' 
	</cfquery>
	<cfquery name="getds" datasource="#pds#">
		SELECT * 
		FROM CustomImport 
		WHERE UseTab = 0 
		AND FileName1 = 'cpds' 
	</cfquery>
	<cfquery name="gettb" datasource="#pds#">
		SELECT * 
		FROM CustomImport 
		WHERE UseTab = 0 
		AND FileName1 = 'cTable' 
	</cfquery>
	<cfquery name="getlg" datasource="#pds#">
		SELECT * 
		FROM CustomImport 
		WHERE UseTab = 0 
		AND FileName1 = 'cLogin' 
	</cfquery>
	<cfquery name="getpw" datasource="#pds#">
		SELECT * 
		FROM CustomImport 
		WHERE UseTab = 0 
		AND FileName1 = 'cPasswd' 
	</cfquery>
<cfelseif tab Is 9>
	<cfparam name="CiID" default="0">
	<cfquery name="getallinfo" datasource="#pds#">
		SELECT * 
		FROM CustomImport
		WHERE UseTab = 1 
		AND CiID = #CiID# 
		ORDER BY filename1
	</cfquery>
	<cfquery name="textauth" datasource="#pds#">
		SELECT * 
		FROM CustomAuth 
		WHERE AuthType = 0 
	</cfquery>
	<cfif CiID GT 0>
		<cfset editone = 1>
	</cfif>
</cfif>
<cfsetting enablecfoutputonly="no">

<HTML>
<HEAD>
<TITLE>Setup Import Text Files</TITLE>
<cfinclude template="coolsheet.cfm"></HEAD>
<cfoutput><BODY #colorset#></cfoutput>
<cfinclude template="header.cfm">
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th bgcolor="#ttclr#" colspan="#HowWide#"><font color="#ttfont#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> size="#ttsize#">Setup Radius Text File Import</font></th>
	</tr>
	<tr>
		<th colspan="#HowWide#">
			<table border="1">
				<tr>
					<form method="post" action="customimport.cfm">
						<td bgcolor=<cfif Tab Is 1>"#tbclr#"<cfelse>"#tdclr#"</cfif> ><input type="radio" <cfif tab Is 1>checked</cfif> name="tab" value="1" onclick="submit()" id="tab1"><label for="tab1">Import Files</label></td>
						<td bgcolor=<cfif Tab Is 2>"#tbclr#"<cfelse>"#tdclr#"</cfif> ><input type="radio" <cfif tab Is 2>checked</cfif> name="tab" value="2" onclick="submit()" id="tab2"><label for="tab2">Import Setup</label></td>
						<td bgcolor=<cfif Tab Is 3>"#tbclr#"<cfelse>"#tdclr#"</cfif> ><input type="radio" <cfif tab Is 3>checked</cfif> name="tab" value="3" onclick="submit()" id="tab3"><label for="tab3">Sample File</label></td>
					</form>
				</tr>
			</table>
		</th>
	</tr>
</cfoutput>

<cfif Tab Is 1>
	<cfoutput>
		<tr>
			<form method="post" action="customimport.cfm">
				<input type="hidden" name="tab" value="9">
				<td colspan="#HowWide#" align="right">
					<input type="image" src="images/addnew.gif" name="addnew" border="0">
				</td>
			</form>
		</tr>
		<tr bgcolor="#thclr#">
			<th>Active</th>
			<th>Auth</th>
			<th>Filename</th>
			<th>FTP</th>
			<th>Server</th>
			<th>Path</th>
			<th>FTP Login</th>
			<th>Delete</th>
		</tr>
	</cfoutput>	
	<form method="post" action="customimport.cfm" onSubmit="return confirm ('Click Ok to confirm deleting the selected file imports.')">	
		<cfset counter1 = 0>
		<cfoutput query="getallinfo">
			<cfset counter1 = counter1 + 1>
			<tr bgcolor="#tbclr#">
				<td>#YesNoFormat(ActiveYN)#</td>
				<td>#AuthDescription#</td>
				<td><a href="customimport.cfm?ciid=#ciid#&tab=9">#filename1#</a></td>				
				<td>#YesNoFormat(ftpyn)#</td>
				<td>#server1#</td>
				<td>#path1#</td>
				<td><cfif ftplogin is Not "">#ftplogin#<cfelse>&nbsp;</cfif></td>
				<th bgcolor="#tdclr#"><input type="checkbox" name="DelOne" value="#ciid#"></th>
			</tr>
		</cfoutput>
		<tr>
			<cfoutput>
				<th colspan="#HowWide#"><input type="image" src="images/delete.gif" name="DeleteImport" border="0"></th>
			</cfoutput>
		</tr>
	</form>
<cfelseif tab Is 2>
	<form method="post" action="customimport.cfm">
		<cfoutput>
			<input type="hidden" name="tab" value="#tab#">
			<tr>
				<td bgcolor="#tbclr#" align="right">Import files to</td>
				<td bgcolor="#tdclr#" colspan="2"><input type="text" name="pathimport" value="#GetPath.Path1#" size="30"></td>
			</tr>
			<tr>
				<td bgcolor="#tbclr#" align="right">Custom Datasource</td>
				<td bgcolor="#tdclr#" colspan="2"><input type="text" name="cpds" value="#GetDS.Path1#" size="10"> Datasource for custom database.</td>
			</tr>
			<tr>
				<td bgcolor="#tbclr#" align="right">Custom Table</td>
				<td bgcolor="#tdclr#" colspan="2"><input type="text" name="cTable" value="#GetTB.Path1#" size="10"> Table Name in custom database.</td>
			</tr>
			<tr>
				<td bgcolor="#tbclr#" align="right">Custom Login</td>
				<td bgcolor="#tdclr#" colspan="2"><input type="text" name="cLogin" value="#GetLg.Path1#" size="10"> Database login. (If Needed)</td>
			</tr>
			<tr>
				<td bgcolor="#tbclr#" align="right">Custom Password</td>
				<td bgcolor="#tdclr#" colspan="2"><input type="password" name="cPasswd" value="#GetPW.Path1#" size="10"> Database password. (If Needed)</td>
			</tr>
		</cfoutput>
		<cfset counter1 = 0>
		<cfoutput query="getallfields">
			<cfset counter1 = counter1 + 1>
			<tr bgcolor="#tdclr#">
				<td align="right" bgcolor="#tbclr#">#FieldDesc#</td>
				<input type="hidden" name="CIID#counter1#" value="#CIID#">
				<td><input type="text" name="Path1#counter1#" value="#Path1#" maxlength="200"></td>
				<td><select name="FieldType#Counter1#">
					<option <cfif FieldType Is "c">selected</cfif> value="c">Text
					<option <cfif FieldType Is "d">selected</cfif> value="d">Date
					<option <cfif FieldType Is "n">selected</cfif> value="n">Number
				</select></td>
			</tr>
		</cfoutput>
		<cfoutput>
			<input type="hidden" name="LoopCount" value="#counter1#">
		</cfoutput>
		<tr>
			<th colspan="3"><input type="image" src="images/update.gif" name="UpdatePath" border="0"></th>
		</tr>
	</form>
<cfelseif tab Is 3>
	<cfoutput>
	<tr>
		<td colspan="2" bgcolor="#thclr#">The Import File must be in the following format.</td>
	</tr>
	<tr>
		<td colspan="2" bgcolor="#tbclr#">
<pre>
Wed Jun 22 21:28:18 1999
	User-Name = "ibob"
	NAS-IP-Address = xxx.xxx.xxx.xxx
	NAS-Port = 10224
	NAS-Port-Type = Sync
	Acct-Status-Type = Start
	Acct-Delay-Time = 0
	Acct-Session-Id = "260420551"
	Acct-Authentic = Local
	Called-Station-Id = "8950014"
	Framed-Protocol = PPP
	Framed-IP-Address = xxx.xxx.xxx.xxx

Wed Jun 22 21:29:25 1999
	User-Name = "jeff"
	NAS-IP-Address = xxx.xxx.xxx.xxx
	NAS-Port = 20120
	NAS-Port-Type = Async
	Acct-Status-Type = Stop
	Acct-Delay-Time = 0
	Acct-Session-Id = "260420548"
	Acct-Authentic = RADIUS
	Acct-Session-Time = 143
	Acct-Input-Octets = 9950
	Acct-Output-Octets = 98682
	Acct-Input-Packets = 228
	Acct-Output-Packets = 251
	Ascend-Disconnect-Cause = 45
	Ascend-Connect-Progress = 60
	Ascend-Data-Rate = 26400
	Ascend-PreSession-Time = 17
	Ascend-Pre-Input-Octets = 356
	Ascend-Pre-Output-Octets = 324
	Ascend-Pre-Input-Packets = 10
	Ascend-Pre-Output-Packets = 11
	Ascend-First-Dest = xxx.xxx.xxx.xxx
	Called-Station-Id = "8950014"
	Framed-Protocol = PPP
	Framed-IP-Address = xxx.xxx.xxx.xxx
</pre>
		</td>
	</tr>
</cfoutput>
<cfelseif tab Is 9>
	<cfoutput>
		<form method="post" action="customimport.cfm">
			<input type="hidden" name="server1_required" value="Please enter the Server information.">
			<input type="hidden" name="path1_required" value="Please enter the Pathway to the file.">
			<input type="hidden" name="filename1_required" value="Please enter the Filename.">
			<cfif IsDefined("editone")>
				<input type="hidden" name="ciid" value="#ciid#">
			</cfif>
			<tr>
				<td bgcolor="#tbclr#" align="right">Active</td>
				<td bgcolor="#tdclr#"><input type="radio" <cfif IsDefined("editone")><cfif getallinfo.ActiveYN is 1>checked</cfif><cfelse>checked</cfif> name="ActiveYN" value="1"> Yes <input type="radio" <cfif IsDefined("editone")><cfif getallinfo.ActiveYN is 0>checked</cfif></cfif> name="ActiveYN" value="0"> No</td>
			</tr>
			<tr bgcolor="#tdclr#">
				<td bgcolor="#tbclr#" align="right">Custom Auth</td>
	</cfoutput>
				<td><select name="CAuthID">
					<cfoutput query="TextAuth">
						<option <cfif IsDefined("editone")><cfif getallinfo.CAuthID Is CAuthID>selected</cfif></cfif> value="#CAuthID#">#AuthDescription#
					</cfoutput>
				</select></td>
			</tr>
	<cfoutput>
			<tr>
				<td bgcolor="#tbclr#" align="right">FTP the file</td>
				<td bgcolor="#tdclr#"><input type="radio" <cfif IsDefined("editone")><cfif getallinfo.ftpyn is 1>checked</cfif></cfif> name="ftpyn" value="1"> Yes <input type="radio" <cfif IsDefined("editone")><cfif getallinfo.ftpyn is 0>checked</cfif><cfelse>checked</cfif> name="ftpyn" value="0"> No</td>
			</tr>
			<tr>
				<td bgcolor="#tbclr#" align="right">Server</td>
				<td bgcolor="#tdclr#"><input type="text" <cfif IsDefined("editone")>value="#getallinfo.server1#"</cfif> name="server1" size="30" maxlength="30"></td>
			</tr>
			<tr>
				<td bgcolor="#tbclr#" align="right">Path</td>
				<td bgcolor="#tdclr#"><input type="text" <cfif IsDefined("editone")>value="#getallinfo.path1#"</cfif> name="path1" size="30" maxlength="200"></td>
			</tr>
			<tr>
				<td bgcolor="#tbclr#" align="right">Filename</td>
				<td bgcolor="#tdclr#"><input type="text" <cfif IsDefined("editone")>value="#getallinfo.filename1#"</cfif> name="filename1" size="30" maxlength="30"></td>
			</tr>
			<tr>
				<td bgcolor="#tbclr#" align="right">FTP Login:<br><font size="1">If needed.</font></td>
				<td bgcolor="#tdclr#"><input type="text" <cfif IsDefined("editone")>value="#getallinfo.ftplogin#"</cfif> name="ftplogin" size="30" maxlength="30"></td>
			</tr>
			<tr valign="top">
				<td bgcolor="#tbclr#" align="right">FTP Password:<br><font size="1">If needed.</font></td>
				<td bgcolor="#tdclr#"><input type="password" <cfif IsDefined("editone")>value="#getallinfo.ftppassword#"</cfif> name="ftppassword" size="30" maxlength="30"></td>
			</tr>
			<tr valign="top">
				<cfif IsDefined("editone")>
					<th colspan="2"><input type="image" src="images/edit.gif" name="editold" border="0"></th>
				<cfelse>
					<th colspan="2"><input type="image" src="images/enter.gif" name="enternew" border="0"></th>
				</cfif>
			</tr>	
		</form>				
	</cfoutput>			
</cfif>		
</table>
	
	
</center>
<cfinclude template="footer.cfm">
</BODY>
</HTML>

<!-- /customimport.cfm -->






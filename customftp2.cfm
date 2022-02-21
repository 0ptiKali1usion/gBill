<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page is for customizing the ftp setup. --->
<!--- 4.0.0 11/09/99 --->
<!--- customftp2.cfm --->

<cfset securepage="customftp.cfm">
<cfinclude template="security.cfm">

<cfif (IsDefined("MvRt")) AND (IsDefined("TheHaveNots"))>
	<cfquery name="MvEmRight" datasource="#pds#">
		UPDATE Domains SET 
		CFTPID = #CFTPID# 
		WHERE DomainID IN (#TheHaveNots#)
	</cfquery>
	<!--- BOB History --->
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="TheNames" datasource="#pds#">
			SELECT DomainName 
			FROM Domains 
			WHERE DomainID IN (#TheHaveNots#) 
		</cfquery>
		<cfquery name="FTPName" datasource="#pds#">
			SELECT FTPDescription 
			FROM CustomFTP 
			WHERE CFTPID = #CFTPID# 
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'System',
			'#StaffMemberName.FirstName# #StaffMemberName.LastName# added the following domains to #FTPName.FTPDescription#: #ValueList(TheNames.DomainName)#.')
		</cfquery>
	</cfif>
</cfif>
<cfif (IsDefined("MvLt")) AND (IsDefined("TheHaves"))>
	<cfquery name="MvEmLeft" datasource="#pds#">
		UPDATE Domains SET 
		CFTPID = 0 
		WHERE DomainID IN (#TheHaves#)
	</cfquery>
	<!--- BOB History --->
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="TheNames" datasource="#pds#">
			SELECT DomainName 
			FROM Domains 
			WHERE DomainID IN (#TheHaves#) 
		</cfquery>
		<cfquery name="FTPName" datasource="#pds#">
			SELECT FTPDescription 
			FROM CustomFTP 
			WHERE CFTPID = #CFTPID# 
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'System',
			'#StaffMemberName.FirstName# #StaffMemberName.LastName# removed the following domains from #FTPName.FTPDescription#: #ValueList(TheNames.DomainName)#.')
		</cfquery>
	</cfif>
</cfif>
<cfif IsDefined("UpdSelected.x")>
	<cfquery name="SetUse" datasource="#pds#">
		UPDATE CustomFTPSetup 
		SET ActiveYN = 0, 
		ScriptCode = Null 
		WHERE CFTPID = #CFTPID# 
		AND BOBName <> 'Password' 
		AND BOBName <> 'DomainName' 
		AND BOBName <> 'UserName' 
	</cfquery>
	<cfquery name="SetSelect" datasource="#pds#">
		UPDATE CustomFTPSetup 
		SET ActiveYN = 1, 
		ScriptCode = Null 
		WHERE CustomFTPID IN (#CustomFTPID#) 
	</cfquery>
	<cfquery name="TheDataFields" datasource="#pds#">
		SELECT BOBName, CustomFTPID 
		FROM CustomFTPSetup 
		WHERE ActiveYN = 1 
		AND CFTPID = #CFTPID# 
		AND BOBName <> 'Password' 
		AND BOBName <> 'DomainName' 
		AND BOBName <> 'UserName' 
		ORDER BY SortOrder, FTPDescription 
	</cfquery>
	<cfloop query="TheDataFields">
		<cfif IsDefined("ScriptCode#CustomFTPID#")>
			<cfset TheCode = Evaluate("ScriptCode#CustomFTPID#")>
			<cfif IsDefined("SortOrder#CustomFTPID#")>
				<cfset TheSort = Evaluate("SortOrder#CustomFTPID#")>
			<cfelse>
				<cfset TheSort = TheDataFields.RecordCount>
			</cfif>
			<cfquery name="UpdData" datasource="#pds#">
				UPDATE CustomFTPSetup SET 
				SortOrder = #TheSort#, 
				ScriptCode = <cfif Trim(TheCode) Is "">Null<cfelse>'#Trim(TheCode)#'</cfif> 
				WHERE CustomFTPID = #CustomFTPID# 
			</cfquery>
		<cfelse>
			<cfif IsDefined("SortOrder#CustomFTPID#")>
				<cfset TheSort = Evaluate("SortOrder#CustomFTPID#")>
			<cfelse>
				<cfset TheSort = TheDataFields.RecordCount>
			</cfif>
			<cfquery name="UpdData" datasource="#pds#">
				UPDATE CustomFTPSetup SET 
				SortOrder = #TheSort# 
				WHERE CustomFTPID = #CustomFTPID# 
			</cfquery>
		</cfif>
	</cfloop>
	<!--- BOB History --->
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="GetNewFTP" datasource="#pds#">
			SELECT FTPDescription 
			FROM CustomFTP 
			WHERE CFTPID = #CFTPID# 
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'System',
			'#StaffMemberName.FirstName# #StaffMemberName.LastName# edited the custom FTP setup for #GetNewFTP.FTPDescription#.')
		</cfquery>
	</cfif>
</cfif>

<cfparam name="Tab" default="1">
<cfif Tab Is 1>
	<cfset HowWide = 4>
	<cfquery name="GetFields" datasource="#pds#">
		SELECT * 
		FROM CustomFTPSetup 
		WHERE CFTPID = #CFTPID# 
		AND BOBName <> 'Password' 
		AND BOBName <> 'DomainName' 
		AND BOBName <> 'UserName' 
		ORDER BY ActiveYN Desc, SortOrder, FTPDescription 
	</cfquery>
	<cfquery name="ActiveFields" datasource="#pds#">
		SELECT CustomFTPID 
		FROM CustomFTPSetup 
		WHERE ActiveYN = 1 
		AND CFTPID = #CFTPID# 
		AND BOBName <> 'Password' 
		AND BOBName <> 'DomainName' 
		AND BOBName <> 'UserName' 
	</cfquery>
<cfelse>
	<cfset HowWide = 3>
	<cfquery name="GetSelected" datasource="#pds#">
		SELECT D.DomainID, D.DomainName 
		FROM Domains D, CustomFTP A 
		WHERE D.CFTPID = A.CFTPID 
		AND D.CFTPID = #CFTPID# 
		ORDER BY DomainName 
	</cfquery>
	<cfquery name="AvailOnes" datasource="#pds#">
		SELECT D.DomainID, D.DomainName, A.FTPDescription 
		FROM Domains D, CustomFTP A 
		WHERE D.CFTPID = A.CFTPID 
		AND D.CFTPID <> #CFTPID# 
		UNION 
		SELECT D.DomainID, D.DomainName, 'None' as FTPDescription 
		FROM Domains D 
		WHERE D.CFTPID = 0 
		OR D.CFTPID IS NULL 
		ORDER BY DomainName 
	</cfquery>
</cfif>
<cfquery name="GetFTP" datasource="#pds#">
	SELECT FTPDescription 
	FROM CustomFTP 
	WHERE CFTPID = #CFTPID# 
</cfquery>
<cfsetting enablecfoutputonly="no">
<html>
<head>
<cfoutput><title>#GetFTP.FTPDescription# Setup</title></cfoutput>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<form method="post" action="customftp.cfm">
	<input type="image" name="retrun" src="images/return.gif" border="0">
</form>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th bgcolor="#ttclr#" colspan="#HowWide#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">#GetFTP.FTPDescription# Setup</font></th>
	</tr>
	<tr>
		<th colspan="#HowWide#">
			<table border="1">
				<tr>
					<form method="post" action="customftp2.cfm">
						<th bgcolor=<cfif tab Is 1>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input type="radio" <cfif tab Is 1>checked</cfif> name="tab" value="1" onclick="submit()" id="tab1"><label for="tab1">Database</label></th>
						<th bgcolor=<cfif tab Is 2>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input type="radio" <cfif tab Is 2>checked</cfif> name="tab" value="2" onclick="submit()" id="tab2"><label for="tab2">Domains</label></th>
						<input type="hidden" name="CFTPID" value="#CFTPID#">
					</form>
				</tr>
			</table>
		</th>
	</tr>
</cfoutput>
<cfif Tab Is 1>
		<cfoutput>
			<tr bgcolor="#thclr#">
				<th>Use</th>
				<th>Description</th>
				<th>Script Code</th>
				<th>SortOrder</th>
			</tr>
		</cfoutput>
		<form method="post" action="customftp2.cfm">
			<cfloop query="GetFields">
				<cfoutput>
					<tr bgcolor="#tdclr#">
						<th><input type="checkbox" <cfif ActiveYN Is "1">checked</cfif> name="CustomFTPID" value="#CustomFTPID#"></th>
						<td bgcolor="#tbclr#">#FTPDescription#</td>
						<cfif ListFind("Read1,Write1,Create1,Delete1,MkDir1,RmDir1,NoRedir1,AnyDir1,NoDrive1,PutAny1,Super1,FTPExecFile,FTPListDirs,FTPInheritD,AnyDrive1",BOBName)>
							<td><input type="Text" name="ScriptCode#CustomFTPID#" value="#ScriptCode#" size="5" maxlength="5"></td>
						<cfelse>
							<td>&nbsp;</td>
						</cfif>
				</cfoutput>
						<cfif ActiveYN Is 1>
							<cfoutput><td><select name="SortOrder#CustomFTPID#"></cfoutput>
								<cfloop index="B4" from="1" to="#ActiveFields.RecordCount#">
									<cfoutput><option <cfif SortOrder Is B4>selected</cfif> value="#B4#">#B4#</cfoutput>
								</cfloop>
							</select></td>
						<cfelse>
							<td>&nbsp;</td>
						</cfif>
					</tr>
			</cfloop>
			<cfoutput>
				<input type="hidden" name="CFTPID" value="#CFTPID#">
				<tr>
					<th colspan="#HowWide#"><input type="image" src="images/update.gif" name="UpdSelected" border="0"></th>
				</tr>
			</cfoutput>
		</form>
<cfelseif Tab Is 2>
	<cfoutput>
	<tr bgcolor="#thclr#">
		<th>Available Domains</th>
		<th>Action</th>
		<th>Selected Domains</th>
	</tr>
	<tr bgcolor="#tdclr#" valign="top">
	</cfoutput>
		<form method="post" action="customftp2.cfm">
			<th><select name="TheHaveNots" multiple size="10">
				<cfloop query="AvailOnes">
					<cfoutput><option value="#DomainID#">#DomainName# - #FTPDescription#</cfoutput>
				</cfloop>
				<option value="0">______________________________
			</select><br>Selecting a domain will override<br>the current setup for the selected domain.</th>
			<th align="center" valign="middle"><input type="submit" name="MvRt" value="---->"><br>
			<input type="submit" name="MvLt" value="<----"><br></th>
			<th><select name="TheHaves" multiple size="10">
				<cfloop query="GetSelected">
					<cfoutput><option value="#DomainID#">#DomainName#</cfoutput>
				</cfloop>
				<option value="0">______________________________
			</select></th>
			<cfoutput>
				<input type="hidden" name="CFTPID" value="#CFTPID#">
				<input type="hidden" name="tab" value="2">
			</cfoutput>
		</form>
	</tr>
</cfif>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 
<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page is for customizing the ftp setup. --->
<!--- 4.0.0 11/09/99 --->
<!--- customftp.cfm --->

<cfset securepage="customftp.cfm">
<cfinclude template="security.cfm">

<cfif IsDefined("SetDefault")>
	<cfquery name="ResetAll" datasource="#pds#">
		UPDATE CustomFTP SET 
		DefaultYN = 0 
	</cfquery>
	<cfquery name="SetOne" datasource="#pds#">
		UPDATE CustomFTP SET 
		DefaultYN = 1 
		WHERE CFTPID = #CFTPID# 
	</cfquery>
</cfif>
<cfif IsDefined("DelSel.x")>
	<cftransaction>
		<cfquery name="DelData" datasource="#pds#">
			DELETE FROM CustomFTP 
			WHERE CFTPID = #DelID#
		</cfquery>
		<cfquery name="DelData" datasource="#pds#">
			DELETE FROM CustomFTPSetup 
			WHERE CFTPID = #DelID#
		</cfquery>
		<cfquery name="ResetData" datasource="#pds#">
			UPDATE Domains SET 
			CFTPID = 0 
			WHERE CFTPID = #DelID# 
		</cfquery>
	</cftransaction>
</cfif>
<cfif IsDefined("NewFTP.x")>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT CFTPID 
		FROM CustomFTP 
	</cfquery>
	<cfif CheckFirst.Recordcount Is 0>
		<cfset DefaultYN = 1>
	<cfelse>
		<cfset DefaultYN = 0>
	</cfif>
	<cftransaction>
		<cfquery name="AddFirstOne" datasource="#pds#">
			INSERT INTO CustomFTP 
			(FTPDescription, ActiveYN, DefaultYN) 
			VALUES 
			('#FTPDescription#',#ActiveYN#, #DefaultYN#)
		</cfquery>
		<cfquery name="GetID" datasource="#pds#">
			SELECT Max(CFTPID) as NewID 
			FROM CustomFTP
		</cfquery>
		<cfset CFTPID = GetID.NewID>
	</cftransaction>
	<cfset LoopList = "DomainName;Domain Name;Text,UserName;UserName;Text,Password;Password;Text,Start_Dir;Users FTP Home Directory;Text,Read1;Read;Number,Write1;Write;Number,Create1;Create New Files;Number,Delete1;Delete Files;Number,MkDir1;Make New Directories;Number,RmDir1;Delete Directories;Number,NoRedir1;Redirect;Number,AnyDir1;Any Directory;Number,NoDrive1;No Drive;Number,Max_Idle1;Max Idle Time;Number,Max_Connect1;Max Connect Time;Number,PutAny1;Put Any;Number,Super1;Super User;Number">
	<cfloop index="B5" list="#LoopList#">
		<cfset Var1 = ListGetAt("#B5#",1,";")>
		<cfset Var2 = ListGetAt("#B5#",2,";")>
		<cfset Var3 = ListGetAt("#B5#",3,";")>
		<cfquery name="CheckFirst" datasource="#pds#">
			SELECT CustomFTPID 
			FROM CustomFTPSetup 
			WHERE BOBName = '#Var1#' 
			AND CFTPID = #CFTPID# 
		</cfquery>
		<cfif CheckFirst.Recordcount Is 0>
			<cfquery name="AddData" datasource="#pds#">
				INSERT INTO CustomFTPSetup 
				(FTPDescription, BOBName, ActiveYN, CFVarYN, DataType, CFTPID) 
				VALUES 
				('#Var2#','#Var1#',1,1,'#Var3#',#CFTPID#)
			</cfquery>
		</cfif>
	</cfloop>
</cfif>

<cfparam name="Tab" default="1">
<cfparam name="Page" default="0">
<cfif Tab Lt 20>
	<cfset HowWide = 4>
<cfelseif Tab Is 22>
	<cfset HowWide = 2>
	<cfquery name="GetDesc" datasource="#pds#">
		SELECT FTPDescription 
		FROM CustomFTP 
		WHERE CFTPID = #CFTPID# 
	</cfquery>
<cfelse>
	<cfset HowWide = 2>
</cfif>
<cfquery name="AllFTPSetups" datasource="#pds#">
	SELECT * 
	FROM CustomFTP 
	ORDER BY FTPDescription 
</cfquery>
<cfif Page Is 0>
	<cfset Srow = 1>
	<cfset Maxrows = AllFTPSetups.Recordcount>
<cfelse>
	<cfset Srow = (Page * Mrow) - (Mrow - 1)>
	<cfset Maxrows = Mrow>
</cfif>
<cfset PageNumber = Ceiling(AllFTPSetups.Recordcount/Mrow)>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>FTP Setup</title>
<cfinclude template="coolsheet.cfm">
</HEAD>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<cfif tab gte 20>
	<form method="post" action="customftp.cfm">
		<input type="image" src="images/return.gif" border="0">
	</form>
</cfif>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="#HowWide#" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Custom FTPs</font></th>
	</tr>
</cfoutput>
<cfif Tab Is 1>
	<tr>
		<cfoutput>
			<form method="post" action="customftp.cfm">
				<th align="right" colspan="#HowWide#"><input type="image" name="AddFTP" src="images/addnew.gif" border="0"></th>
				<input type="hidden" name="tab" value="20">
			</form>
		</cfoutput>
	</tr>
	<cfif AllFTPSetups.Recordcount GT 0>
		<tr>
			<cfoutput>
				<th bgcolor="#thclr#">Edit</th>
				<th bgcolor="#thclr#">Default</th>
				<th bgcolor="#thclr#">Description</th>
				<th bgcolor="#thclr#">Delete</th>
			</cfoutput>
		</tr>
		<cfoutput query="AllFTPSetups" startrow="#Srow#" maxrows="#Maxrows#">
			<tr bgcolor="#tbclr#">
				<form method="post" action="customftp2.cfm">
					<th bgcolor="#tdclr#"><input type="radio" name="CFTPID" value="#CFTPID#" onclick="submit()"></th>
				</form>
				<form method="post" action="customftp.cfm">
					<th bgcolor="#tdclr#"><input type="radio" <cfif DefaultYN Is 1>checked</cfif> name="DefaultYN" value="1" onclick="submit()"></th>
					<input type="hidden" name="CFTPID" value="#CFTPID#">
					<input type="hidden" name="SetDefault" value="1">
				</form>
				<td>#FTPDescription#</td>
				<cfif (AllFTPSetups.Recordcount GT 1) AND (DefaultYN Is 0)>
					<form method="post" action="customftp.cfm">
						<th bgcolor="#tdclr#"><input type="radio" value="#CFTPID#" name="CFTPID" onclick="submit()"></th>
						<input type="hidden" name="tab" value="22">
					</form>
				<cfelse>
					<th bgcolor="#tdclr#">&nbsp;</th>
				</cfif>
			</tr>
		</cfoutput>
	</cfif>
<cfelseif Tab Is 20>
	<form method="post" action="customftp.cfm">
		<cfoutput>
			<tr bgcolor="#tdclr#">
				<td align="right" bgcolor="#tbclr#">Description</td>
				<td><input type="text" name="FTPDescription" value="" maxlength="255"></td>
			</tr>
			<tr>
				<th colspan="2"><input type="image" src="images/enter.gif" name="NewFTP" border="0"></th>
			</tr>
			<input type="hidden" name="FTPDescription_Required" value="Please enter a description for this FTP setup.">
			<input type="hidden" name="ActiveYN" value="1">
		</cfoutput>
	</form>
<cfelseif Tab Is 22>
	<form method="post" action="customftp.cfm">
		<cfoutput>
			<tr>
				<td bgcolor="#tbclr#">You have selected to delete #GetDesc.FTPDescription#<br>
				Click Continue to comfirm deleting the selected setup.</td>
			</tr>
			<tr>
				<th><input type="image" src="images/continue.gif" name="DelSel" border="0"></th>
			</tr>
			<input type="hidden" name="DelID" value="#CFTPID#">
		</cfoutput>
	</form>
</cfif>
</table>
<cfinclude template="footer.cfm">
</body>
</html>
 
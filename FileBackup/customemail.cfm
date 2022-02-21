<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page is for customizing the email setup. --->
<!--- 4.0.0 12/02/99 --->
<!--- customemail.cfm --->

<cfset securepage="customemail.cfm">
<cfinclude template="security.cfm">

<cfif IsDefined("SetDefault")>
	<cfquery name="ResetAll" datasource="#pds#">
		UPDATE CustomEMail SET 
		DefaultYN = 0 
	</cfquery>
	<cfquery name="SetOne" datasource="#pds#">
		UPDATE CustomEMail SET 
		DefaultYN = 1 
		WHERE CEMailID = #CEMailID# 
	</cfquery>
</cfif>
<cfif IsDefined("DelSel.x")>
	<cftransaction>
		<cfquery name="DelData" datasource="#pds#">
			DELETE FROM CustomEMail 
			WHERE CEMailID = #DelID#
		</cfquery>
		<cfquery name="DelData" datasource="#pds#">
			DELETE FROM CustomEMailSetup 
			WHERE CEMailID = #DelID#
		</cfquery>
		<cfquery name="ResetData" datasource="#pds#">
			UPDATE Domains SET 
			CEMailID = 0 
			WHERE CEMailID = #DelID# 
		</cfquery>
	</cftransaction>
</cfif>
<cfif IsDefined("NewEMail.x")>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT CEMailID 
		FROM CustomEMail 
	</cfquery>
	<cfif CheckFirst.Recordcount Is 0>
		<cfset DefaultYN = 1>
	<cfelse>
		<cfset DefaultYN = 0>
	</cfif>
	<cftransaction>
		<cfquery name="AddFirstOne" datasource="#pds#">
			INSERT INTO CustomEMail 
			(EMailDescription, ActiveYN, DefaultYN) 
			VALUES 
			('#EMailDescription#',#ActiveYN#, #DefaultYN#)
		</cfquery>
		<cfquery name="GetID" datasource="#pds#">
			SELECT Max(CEMailID) as NewID 
			FROM CustomEMail
		</cfquery>
		<cfset CEMailID = GetID.NewID>
	</cftransaction>
	<cfset LoopList = "DomainName;Domain Name;Text,Login;Login;Text,EPass;Password;Text,FName;First Name;Text,LName;Last Name;Text,MailCMD;IPAD EMail Type;Text,MailBoxPath;Users EMail Home Directory;Text,MailBoxLimit;Size Limit on Users mailbox;Text,UniqueIdentifier;Unique ID for Email address;Text">
	<cfloop index="B5" list="#LoopList#">
		<cfset Var1 = ListGetAt("#B5#",1,";")>
		<cfset Var2 = ListGetAt("#B5#",2,";")>
		<cfset Var3 = ListGetAt("#B5#",3,";")>
		<cfquery name="CheckFirst" datasource="#pds#">
			SELECT CustomEMailID 
			FROM CustomEMailSetup 
			WHERE BOBName = '#Var1#' 
			AND CEMailID = #CEMailID# 
		</cfquery>
		<cfif CheckFirst.Recordcount Is 0>
			<cfquery name="AddData" datasource="#pds#">
				INSERT INTO CustomEMailSetup 
				(EMailDescription, BOBName, ActiveYN, CFVarYN, DataType, CEMailID) 
				VALUES 
				('#Var2#','#Var1#',1,1,'#Var3#',#CEMailID#)
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
		SELECT EMailDescription 
		FROM CustomEMail 
		WHERE CEMailID = #CEMailID# 
	</cfquery>
<cfelse>
	<cfset HowWide = 2>
</cfif>
<cfquery name="AllEMailSetups" datasource="#pds#">
	SELECT * 
	FROM CustomEMail 
	ORDER BY EMailDescription 
</cfquery>
<cfif Page Is 0>
	<cfset Srow = 1>
	<cfset Maxrows = AllEMailSetups.Recordcount>
<cfelse>
	<cfset Srow = (Page * Mrow) - (Mrow - 1)>
	<cfset Maxrows = Mrow>
</cfif>
<cfset PageNumber = Ceiling(AllEMailSetups.Recordcount/Mrow)>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>E-Mail Setup</title>
<cfinclude template="coolsheet.cfm">
</HEAD>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<cfif tab gte 20>
	<form method="post" action="customemail.cfm">
		<input type="image" src="images/return.gif" border="0">
	</form>
</cfif>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="#HowWide#" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Custom E-Mails</font></th>
	</tr>
</cfoutput>
<cfif Tab Is 1>
	<tr>
		<cfoutput>
			<form method="post" action="customemail.cfm">
				<th align="right" colspan="#HowWide#"><input type="image" name="AddEMail" src="images/addnew.gif" border="0"></th>
				<input type="hidden" name="tab" value="20">
			</form>
		</cfoutput>
	</tr>
	<cfif AllEMailSetups.Recordcount GT 0>
		<tr>
			<cfoutput>
				<th bgcolor="#thclr#">Edit</th>
				<th bgcolor="#thclr#">Default</th>
				<th bgcolor="#thclr#">Description</th>
				<th bgcolor="#thclr#">Delete</th>
			</cfoutput>
		</tr>
		<cfoutput query="AllEMailSetups" startrow="#Srow#" maxrows="#Maxrows#">
			<tr bgcolor="#tbclr#">
				<form method="post" action="customemail2.cfm">
					<th bgcolor="#tdclr#"><input type="radio" name="CEMailID" value="#CEMailID#" onclick="submit()"></th>
				</form>
				<form method="post" action="customemail.cfm">
					<th bgcolor="#tdclr#"><input type="radio" <cfif DefaultYN Is 1>checked</cfif> name="DefaultYN" value="1" onclick="submit()"></th>
					<input type="hidden" name="CEMailID" value="#CEMailID#">
					<input type="hidden" name="SetDefault" value="1">
				</form>
				<td>#EMailDescription#</td>
				<cfif (AllEMailSetups.Recordcount GT 1) AND (DefaultYN Is 0)>
					<form method="post" action="customemail.cfm">
						<th bgcolor="#tdclr#"><input type="radio" value="#CEMailID#" name="CEMailID" onclick="submit()"></th>
						<input type="hidden" name="tab" value="22">
					</form>
				<cfelse>
					<th bgcolor="#tdclr#">&nbsp;</th>
				</cfif>
			</tr>
		</cfoutput>
	</cfif>
<cfelseif Tab Is 20>
	<form method="post" action="customemail.cfm">
		<cfoutput>
			<tr bgcolor="#tdclr#">
				<td align="right" bgcolor="#tbclr#">Description</td>
				<td><input type="text" name="EMailDescription" value="" maxlength="255"></td>
			</tr>
			<tr>
				<th colspan="2"><input type="image" src="images/enter.gif" name="NewEMail" border="0"></th>
			</tr>
			<input type="hidden" name="EMailDescription_Required" value="Please enter a description for this EMail setup.">
			<input type="hidden" name="ActiveYN" value="1">
		</cfoutput>
	</form>
<cfelseif Tab Is 22>
	<form method="post" action="customemail.cfm">
		<cfoutput>
			<tr>
				<td bgcolor="#tbclr#">You have selected to delete #GetDesc.EMailDescription#<br>
				Click Continue to comfirm deleting the selected setup.</td>
			</tr>
			<tr>
				<th><input type="image" src="images/continue.gif" name="DelSel" border="0"></th>
			</tr>
			<input type="hidden" name="DelID" value="#CEMailID#">
		</cfoutput>
	</form>
</cfif>
</table>
<cfinclude template="footer.cfm">
</body>
</html>
 
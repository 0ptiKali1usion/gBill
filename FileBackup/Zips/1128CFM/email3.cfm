<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This is page 4 of the mass emailer. --->
<!--- 4.0.0 09/08/98 --->
<!--- email3.cfm --->

<cfparam name="JumpSecs" default="5">
<cfparam name="SendRows" default="100">
<cfquery name="GetAddresses" datasource="#pds#" maxrows="#SendRows#">
	SELECT * 
	FROM EMailOutgoing 
	WHERE AdminID = #MyAdminID# 
	AND LetterID = 6
</cfquery>
<!--- Start looping over the records in the EMailOutgoing --->
<cfloop query="GetAddresses">
	<cfif SelectedLetter Is 0>
		<cfif SendEMail Is 1>
			<cfmail from="#FromAddr#" to="#EMailAddr#" subject="#EMailSubject#">
#LetterBody#
</cfmail>
		</cfif>
		<cfquery name="GetWhoIs" datasource="#pds#">
			SELECT AccountID, FirstName, LastName 
			FROM Accounts 
			WHERE AccountID = #AccountID# 
		</cfquery>
		<cfif Not IsDefined("NoBOBHist")>
			<cfquery name="BOBHist" datasource="#pds#">
				INSERT INTO BOBHist
				(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
				VALUES 
				('#LetterBody#',#AccountID#,#MyAdminID#, #Now()#,'E-Mailed','#StaffMemberName.FirstName# #StaffMemberName.LastName# e-mailed #GetWhoIs.FirstName# #GetWhoIs.LastName# at #EMailAddr#.')
			</cfquery>
		</cfif>
	<cfelse>
		<!--- If letter is selected then replace the letter variables and send the letter --->	
		<cfquery name="GetLetter" datasource="#pds#">
			SELECT * 
			FROM Integration 
			WHERE IntID = #SelectedLetter# 
		</cfquery>
		<cfset LocScriptID = SelectedLetter>
		<cfset LocAccountID = AccountID>
		<cfsetting enablecfoutputonly="no">
			<cfinclude template="runvarvalues.cfm">
		<cfsetting enablecfoutputonly="yes">
		<cfset LocServer = ReplaceList("#GetLetter.EMailServer#","#FindList#","#ReplList#")>
		<cfset LocSvPort = ReplaceList("#GetLetter.EMailServerPort#","#FindList#","#ReplList#")>
		<cfif Trim(LocSvPort) Is "">
			<cfset LocSvPort = 25>
		</cfif>
		<cfset LocEMFrom = ReplaceList("#GetLetter.EMailFrom#","#FindList#","#ReplList#")>
		<cfset LocEmalCC = ReplaceList("#GetLetter.EMailCC#","#FindList#","#ReplList#")>
		<cfset LocSubjct = ReplaceList("#GetLetter.EMailSubject#","#FindList#","#ReplList#")>
		<cfset LocFileNm = ReplaceList("#GetLetter.EMailFile#","#FindList#","#ReplList#")>
		<cfset LocMessag = ReplaceList("#GetLetter.EMailMessage#","#FindList#","#ReplList#")>
		<cfset TheLocMessag = Replace(LocMessag,")*N/A*(","","All")>
		<cfset LocScriptID = SelectedLetter>
		<cfset LocAccountID = AccountID>
		<cfset TheFindList = FindList>
		<cfset TheReplList = ReplList>
		<cfinclude template="runrepeatvalues.cfm">
		<cfset TheLocMessag = TheLocMessag & RepeatMessage>
		<cfif SendEMail Is 1>
			<cfif LocServer Is Not "">
				<cfmail server="#LocServer#" port="#LocSvPort#"
				 to="#EMailAddr#" from="#LocEMFrom#" subject="#LocSubjct#">
#TheLocMessag#
</cfmail>
			<cfelse>
				<cfmail to="#EMailAddr#" from="#LocEMFrom#" subject="#LocSubjct#">
#TheLocMessag#
</cfmail>
			</cfif>
		</cfif>
		<cfquery name="GetWhoIs" datasource="#pds#">
			SELECT AccountID, FirstName, LastName 
			FROM Accounts 
			WHERE AccountID = #AccountID# 
		</cfquery>
		<cfif Not IsDefined("NoBOBHist")>
			<cfquery name="BOBHist" datasource="#pds#">
				INSERT INTO BOBHist
				(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
				VALUES 
				('#LocMessag#',#AccountID#,#MyAdminID#, #Now()#,'E-Mailed','#StaffMemberName.FirstName# #StaffMemberName.LastName# e-mailed #GetWhoIs.FirstName# #GetWhoIs.LastName# at #EMailAddr#.')
			</cfquery>
		</cfif>
	</cfif>
	<cfquery name="DelData" datasource="#pds#">
		DELETE FROM EMailOutgoing 
		WHERE AdminID = #MyAdminID# 
		AND LetterID = 6 
		AND AccountID = #AccountID#
	</cfquery>
</cfloop>
<cfsetting enablecfoutputonly="no">
<html>
<head>
<cfif GetAddresses.Recordcount GT 0>
<title>Processing</title>
<cfelse>
<title>Finished processing</title>
</cfif>
</head>
<cfif GetAddresses.Recordcount GT 0>
	<META HTTP-EQUIV=REFRESH CONTENT="#JumpSecs#; URL=email3.cfm">
</cfif>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
	<cfif GetAddresses.Recordcount GT 0>
		<td bgcolor="#tbclr#">Processing!  Please Wait!</td>
	<cfelse>
		<td bgcolor="#tbclr#">gBill has finished processing the email list.</td>
	</cfif>
	</tr>
</table>
</cfoutput>
</center>
<cfinclude template="footer.cfm">
</body>
</html>    



<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page works with the Group List to send email. --->
<!--- 4.0.0 09/09/98 --->
<!--- emailsend.cfm --->

<cfparam name="JumpSecs" default="5">
<cfparam name="SendRows" default="#Mrow#">
<cfif IsDefined("SendIt.x")>
	<cfset TheTempLetterID = LetterID>
	<cfquery name="InsData"	datasource="#pds#">
		INSERT INTO TempValues 
		(AdminID,LetterID,VariableName,VariableValue)
		VALUES 
		(#MyAdminID#,#TheTempLetterID#,'SendHeader','#SendHeader#')
	</cfquery>
	<cfquery name="InsData"	datasource="#pds#">
		INSERT INTO TempValues 
		(AdminID,LetterID,VariableName,VariableValue)
		VALUES 
		(#MyAdminID#,#TheTempLetterID#,'SendFields','#SendFields#')
	</cfquery>
	<cfquery name="InsData"	datasource="#pds#">
		INSERT INTO TempValues 
		(AdminID,LetterID,VariableName,VariableValue)
		VALUES 
		(#MyAdminID#,#TheTempLetterID#,'LetterID','#LetterID#')
	</cfquery>
	<cfquery name="InsData"	datasource="#pds#">
		INSERT INTO TempValues 
		(AdminID,LetterID,VariableName,VariableValue)
		VALUES 
		(#MyAdminID#,#TheTempLetterID#,'ReportID','#ReportID#')
	</cfquery>
	<cfquery name="InsData"	datasource="#pds#">
		INSERT INTO TempValues 
		(AdminID,LetterID,VariableName,VariableValue)
		VALUES 
		(#MyAdminID#,#TheTempLetterID#,'ReturnPage','#ReturnPage#')
	</cfquery>
	<cfquery name="InsData"	datasource="#pds#">
		INSERT INTO TempValues 
		(AdminID,LetterID,VariableName,VariableValue)
		VALUES 
		(#MyAdminID#,#TheTempLetterID#,'ReturnTo','#ReturnTo#')
	</cfquery>
	<cfquery name="InsData"	datasource="#pds#">
		INSERT INTO TempValues 
		(AdminID,LetterID,VariableName,VariableValue)
		VALUES 
		(#MyAdminID#,#TheTempLetterID#,'obid2','#obid2#')
	</cfquery>
	<cfquery name="InsData"	datasource="#pds#">
		INSERT INTO TempValues 
		(AdminID,LetterID,VariableName,VariableValue)
		VALUES 
		(#MyAdminID#,#TheTempLetterID#,'obdir2','#obdir2#')
	</cfquery>
	<cfquery name="InsData"	datasource="#pds#">
		INSERT INTO TempValues 
		(AdminID,LetterID,VariableName,VariableValue)
		VALUES 
		(#MyAdminID#,#TheTempLetterID#,'Page2','#page2#')
	</cfquery>
	<cfquery name="InsData"	datasource="#pds#">
		INSERT INTO TempValues 
		(AdminID,LetterID,VariableName,VariableValue)
		VALUES 
		(#MyAdminID#,#TheTempLetterID#,'EPage','#EPage#')
	</cfquery>
	<cfif IsDefined("ReturnID")>
		<cfquery name="InsData"	datasource="#pds#">
			INSERT INTO TempValues 
			(AdminID,LetterID,VariableName,VariableValue)
			VALUES 
			(#MyAdminID#,#TheTempLetterID#,'ReturnID','#ReturnID#')
		</cfquery>
	</cfif>
	<cfif IsDefined("page")>
		<cfquery name="InsData"	datasource="#pds#">
			INSERT INTO TempValues 
			(AdminID,LetterID,VariableName,VariableValue)
			VALUES 
			(#MyAdminID#,#TheTempLetterID#,'Page','#Page#')
		</cfquery>
	</cfif>
	<cfif IsDefined("obdir")>
		<cfquery name="InsData"	datasource="#pds#">
			INSERT INTO TempValues 
			(AdminID,LetterID,VariableName,VariableValue)
			VALUES 
			(#MyAdminID#,#TheTempLetterID#,'obdir','#obdir#')
		</cfquery>
	</cfif>
	<cfif IsDefined("obid")>
		<cfquery name="InsData"	datasource="#pds#">
			INSERT INTO TempValues 
			(AdminID,LetterID,VariableName,VariableValue)
			VALUES 
			(#MyAdminID#,#TheTempLetterID#,'obid','#obid#')
		</cfquery>
	</cfif>
</cfif>

<cfquery name="GetAddresses" datasource="#pds#" maxrows="#SendRows#">
	SELECT * 
	FROM EMailOutgoing 
	WHERE AdminID = #MyAdminID# 
	AND LetterID = #LetterID# 
	ORDER BY LastName, FirstName 
</cfquery>
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
		AND LetterID = #LetterID# 
		AND AccountID = #AccountID#
	</cfquery>
</cfloop>
<cfquery name="SeeIfDone" datasource="#pds#">
	SELECT AccountID 
	FROM EMailOutgoing 
	WHERE AdminID = #MyAdminID# 
	AND LetterID = #LetterID# 
	ORDER BY LastName, FirstName 
</cfquery>
<cfif IsDefined("PaymentHistory")>
	<cfsetting enablecfoutputonly="no">
	<cfinclude template="pmthist.cfm">
	<cfabort>
</cfif>
<cfif SeeIfDone.Recordcount Is 0>
	<cfquery name="GetTheValues" datasource="#pds#">
		SELECT * 
		FROM TempValues 
		WHERE AdminID = #MyAdminID# 
		AND LetterID = #LetterID#
	</cfquery>
	<cfoutput query="GetTheValues">
		<cfset "#VariableName#" = VariableValue>
	</cfoutput>
	<cfquery name="DeleteTheValues" datasource="#pds#">
		DELETE FROM TempValues 
		WHERE AdminID = #MyAdminID# 
		AND LetterID = #LetterID# 
	</cfquery>
</cfif>
<cfsetting enablecfoutputonly="no">
<html>
<head>
<cfif SeeIfDone.Recordcount GT 0>
<title>Processing</title>
<cfelse>
<title>Finished processing</title>
</cfif>
</head>
<cfif SeeIfDone.Recordcount GT 0>
	<cfoutput><META HTTP-EQUIV=REFRESH CONTENT="#JumpSecs#; URL=emailsend.cfm?LetterID=#LetterID#&RequestTimeout=300"></cfoutput>
</cfif>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<cfif SeeIfDone.Recordcount Is 0>
	<cfoutput>
	<form method="post" action="#ReturnTo#">
		<cfif IsDefined("SendHeader")>
			<input type="hidden" name="SendHeader" value="#SendHeader#">
		</cfif>
		<cfif IsDefined("SendFields")>
			<input type="hidden" name="SendFields" value="#SendFields#">
		</cfif>
		<cfif IsDefined("LetterID")>
			<input type="hidden" name="LetterID" value="#LetterID#">
		</cfif>
		<cfif IsDefined("ReportID")>
			<input type="hidden" name="ReportID" value="#ReportID#">
		</cfif>
		<cfif IsDefined("ReturnPage")>
			<input type="hidden" name="ReturnPage" value="#ReturnPage#">
		</cfif>
		<cfif IsDefined("ReturnTo")>
			<input type="hidden" name="ReturnTo" value="#ReturnTo#">
		</cfif>
		<cfif IsDefined("obid2")>
			<input type="hidden" name="obid2" value="#obid2#">
		</cfif>
		<cfif IsDefined("obdir2")>
			<input type="hidden" name="obdir2" value="#obdir2#">
		</cfif>
		<cfif IsDefined("page2")>
			<input type="hidden" name="page2" value="#page2#">
		</cfif>
		<cfif IsDefined("EPage")>
			<input type="hidden" name="EPage" value="#EPage#">
		</cfif>		
		<cfif IsDefined("ReturnID")>
			<input type="hidden" name="ReturnID" value="#ReturnID#">
		</cfif>
		<cfif IsDefined("page")>
			<input type="hidden" name="page" value="#Page#">
		</cfif>
		<cfif IsDefined("obdir")>
			<input type="hidden" name="obdir" value="#obdir#">
		</cfif>
		<cfif IsDefined("obid")>
			<input type="hidden" name="obid" value="#obid#">
		</cfif>
		<input type="image" src="images/return.gif" name="Return" border="0">
	</form>
	</cfoutput>
</cfif>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
	<cfif SeeIfDone.Recordcount GT 0>
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
 
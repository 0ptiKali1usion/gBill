<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This is the account wizard. --->
<!---	4.0.1 01/25/01 Fixed an error with the Default Postal Option.
		4.0.0 08/14/99
		3.2.1 10/14/98  Fixed the pop query to work with International set to yes.
		3.2.0 09/08/98 --->
<!--- account1.cfm --->

<cfset securepage="account.cfm">
<cfinclude template="security.cfm">
<cfif IsDefined("StartOver")>
	<cfquery name="CleanUp" datasource="#pds#">
		DELETE FROM AccntTemp 
		WHERE AdminID = #MyAdminID#
	</cfquery>
</cfif>
<cfset dropby1 = 1>
<cfinclude template="license.cfm">
<cfif IsDefined("greensoft") is "No">
	<cfset maxuser = "1">
</cfif>
<cfquery name="HowMany1" datasource="#pds#">
	SELECT Count(accountid) as CID 
	FROM accounts 
	WHERE cancelyn = 0 
</cfquery>
<cfsetting enablecfoutputonly="no">
<cfif HowMany1.cid GT MaxUser>
	<HTML>
	<HEAD>
	<TITLE>License</TITLE>
	<cfinclude template="coolsheet.cfm">
	</HEAD>
	<cfoutput><BODY #colorset#></cfoutput>
	<cfinclude template="header.cfm">
	<center>
	<cfoutput>
		<font size="5">License Limit</font>
		<table border="#tblwidth#">
			<tr valign="top">
				<td bgcolor="#tbclr#">This copy of gBill has reached it maximum licensed limit of customers.<br>
Please contact GreenSoft Solutions, Inc. to obtain a higher limit or
cancel some of the current customers.</td>
			</tr>
		</table>
	</cfoutput>
	</center>
	<cfinclude template="footer.cfm">
	</BODY>
	</HTML>
	<cfabort>
</cfif>
<cfif IsDefined("PaymentInfo.x")>
	<cfinclude template="account2.cfm">
	<cfif IsDefined("NoAdvance")>
		<cfset tab = tab>
	<cfelse>
		<cfset tab = tab + 1>
	</cfif>
</cfif>
<cfif IsDefined("UpdateAccount.x")>
	<cfquery name="GetFields" datasource="#pds#">
		SELECT BOBFieldName, DataType 
		FROM WizardSetup 
		WHERE PageNumber = #tab# 
		AND ActiveYN = 1 
		AND AWUseYN = 1 
	</cfquery>
	<cfquery name="UpdateInfo" datasource="#pds#">
		UPDATE AccntTemp SET 
		<cfloop query="GetFields">
				<cfset FieldValue = Evaluate("#BOBFieldName#")>
				#BOBFieldName# = <cfif Trim(FieldValue) Is "">NULL<cfelse><cfif DataType Is "Text">'#FieldValue#'<cfelseif DataType Is "Number">#FieldValue#<cfelseif DataType Is "Date">#CreateODBCDateTime(FieldValue)#</cfif></cfif>, 
		</cfloop> 
		AdminID = #MyAdminID#, 
		TabCompleted = #tab#
		<cfif (Tab Is 1)> 
			<cfif (IsDefined("FirstName")) AND (IsDefined("LastName"))>
			, CardHold = '#FirstName# #LastName#'
			, CheckD5 = '#FirstName# #LastName#' 
			</cfif>
			<cfif IsDefined("Address1")>
			,AVSAddr = '#Address1#'
			</cfif>
		</cfif> 
		WHERE AccountID = #AccountID# 
	</cfquery>
	<cfset tab = tab + 1>
</cfif>
<cfif IsDefined("AccountInfo.x")>
	<cfinclude template="account2.cfm">
	<cfset tab = tab + 1>
</cfif>
<cfif IsDefined("AddAccount.x")>
	<cfquery name="GetFields" datasource="#pds#">
		SELECT BOBFieldName, DataType 
		FROM WizardSetup 
		WHERE PageNumber = #tab# 
		AND ActiveYN = 1 
		AND AWUseYN = 1 
		ORDER BY RowOrder, SortOrder
	</cfquery>
	<cfset LoopCounter = 1>
	<cftransaction>
		<cfquery name="TempInfo" datasource="#pds#">
			INSERT INTO AccntTemp 
			(#ValueList(GetFields.BOBFieldName)#,AdminID,TabCompleted,StartDate<cfif Tab Is 1>,WaiveA,CardHold,PostalInv</cfif>)
			VALUES 
			(<cfloop index="B5" list="#ValueList(GetFields.BOBFieldName)#">
				<cfset DataType = ListGetAt("#ValueList(GetFields.DataType)#",LoopCounter)>
				<cfset LoopCounter = LoopCounter + 1>
				<cfset FieldValue = Evaluate("#B5#")>
				<cfif Trim(FieldValue) Is "">NULL<cfelse><cfif DataType Is "Text">'#Trim(FieldValue)#'<cfelseif DataType Is "Number">#FieldValue#<cfelseif DataType Is "Date">#CreateODBCDateTime(FieldValue)#</cfif></cfif>,
			</cfloop>#MyAdminID#,1,#Now()#
			<cfif Tab Is 1>
				,0, 
				<cfif (IsDefined("FirstName")) AND (IsDefined("LastName"))>
					'#FirstName# #LastName#' 
				<cfelse> 
					Null 
				</cfif>
			</cfif>,2 )
		</cfquery>
		<cfquery name="NewID" datasource="#pds#">
			SELECT max(AccountID) As MaxID 
			FROM AccntTemp 
		</cfquery>
		<cfif Not IsDefined("AccountID")><cfset AccountID = NewID.MaxID></cfif>
		<cfset tab = tab + 1>
	</cftransaction>
	<cfquery name="CheckSales" datasource="#pds#">
		SELECT SalesPersonID 
		FROM AccntTemp 
		WHERE AccountID = #AccountID# 
	</cfquery>
	<cfif CheckSales.SalesPersonID Is "">
		<cfquery name="UpdSalesID" datasource="#pds#">
			UPDATE AccntTemp SET 
			SalesPersonID = #MyAdminID# 
			WHERE AccountID = #AccountID# 
		</cfquery>
	</cfif>
</cfif>

<cfparam name="Tab" default="1">
<cfparam name="CompletedTab" default="0">
<cfset HideRow = 0>
<cfif tab LT 6>
	<cfquery name="WhichPage" datasource="#pds#">
		SELECT RowOrder 
		FROM WizardSetup 
		WHERE ActiveYN = 1 
		AND AWUseYN = 1 
		AND PageNumber = #Tab# 
		GROUP BY RowOrder 
		ORDER BY RowOrder 
	</cfquery>
	<cfquery name="MaxSort" datasource="#pds#">
		SELECT max(SortOrder) as HowWide 
		FROM WizardSetup 
		WHERE ActiveYN = 1 
		AND AWUseYN = 1 
		AND PageNumber = #Tab#
	</cfquery>
	<cfset HowWide = MaxSort.HowWide * 2>
<cfelse>
	<cfset HowWide = 2>
</cfif>
<cfquery name="SignUpInfo" datasource="#pds#">
	SELECT * 
	FROM AccntTemp 
	WHERE AccountID = 
		<cfif IsDefined("AccountID")>#AccountID#<cfelse>0</cfif>
</cfquery>
<cfset CheckPayType = 1>
<cfif SignUpInfo.RecordCount GT 0>
	<cfset CompletedTab = SignUpInfo.TabCompleted>
	<cfif Not IsDefined("AccountID")><cfset AccountID = SignUpInfo.AccountID></cfif>
</cfif>
<cfif Tab Is 4>
	<cfset HavePlans = SignUpInfo.SelectPlan>
	<cfquery name="CleanUp" datasource="#pds#">
		DELETE FROM 
		AccntTempInfo 
		WHERE AccountID = #AccountID# 
		AND PlanID Not In (#HavePlans#) 
	</cfquery>
	<cfquery name="CleanUp2" datasource="#pds#">
		UPDATE AccntTempInfo SET 
		AdminID = #MyAdminID# 
		WHERE AccountID = #AccountID# 
	</cfquery>
	<cfquery name="LogPass" datasource="#pds#">
		SELECT * 
		FROM AccntTempInfo 
		WHERE AccountID = #AccountID# 
		AND AdminID = #MyAdminID# 
	</cfquery>
	<cfloop query="LogPass">
		<cfif Type Is "Auth">
			<cfset "Plan#PlanID#ALogin#Sort#" = Login>
			<cfset "Plan#PlanID#APassword#Sort#" = Password>
			<cfset "Plan#PlanID#AServer#Sort#" = DomainID>
			<cfif StaticIP Is 1>
				<cfset "Plan#PlanID#StaticIP#Sort#" = 1>
			</cfif>
		<cfelseif Type Is "FTP">
			<cfset "Plan#PlanID#FLogin#Sort#" = Login>
			<cfset "Plan#PlanID#FPassword#Sort#" = Password>
			<cfset "Plan#PlanID#FServer#Sort#" = DomainID>
		<cfelseif Type Is "EMail">
			<cfset "Plan#PlanID#ELogin#Sort#" = Login>
			<cfset "Plan#PlanID#EUserName#Sort#" = UserName>
			<cfset "Plan#PlanID#EDomainID#Sort#" = DomainID>
			<cfset "Plan#PlanID#EPassword#Sort#" = Password>
		</cfif>
	</cfloop>
<cfelseif Tab Is 5>
	<cfquery name="CheckPayTypes" datasource="#pds#">
		SELECT AWPayCK, AWPayCD, AWPayCC, AWPayPO 
		FROM Plans 
		WHERE PlanID In (#SignUpInfo.SelectPlan#)
	</cfquery>
	<cfset CheckPayType = 0>
	<cfloop query="CheckPayTypes">
		<cfset CheckPayType = CheckPayType + AWPayCK + AWPayCD + AWPayCC + AWPayPO>
	</cfloop>
</cfif>
<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Account Wizard</TITLE>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr valign="top">
		<cfif IsDefined("AccountID")>
			<th colspan="#HowWide#" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#perFontName#"</cfif> color="#ttfont#">Signup - #SignUpInfo.FirstName# #SignUpInfo.LastName#</font></th>
		<cfelse>
			<th colspan="#HowWide#" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#perFontName#"</cfif> color="#ttfont#">Account Wizard</font></th>
		</cfif>
	</tr>
	<tr valign="top">
		<th colspan="#HowWide#">
			<table border="1">
				<form method="post" action="account1.cfm">
					<cfif IsDefined("AccountID")>
						<input type="hidden" name="AccountID" value="#AccountID#">
					</cfif>
					<tr valign="top">
						<th bgcolor=<cfif Tab Is 1>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input type="radio" <cfif tab is 1>checked</cfif> name="tab" value="1" onclick="submit()" id="Tab1"><label for="Tab1">Personal</label></th>
						<cfif CompletedTab GT 0>
							<th bgcolor=<cfif Tab Is 2>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input type="radio" <cfif tab is 2>checked</cfif> name="tab" value="2" onclick="submit()" id="Tab2"><label for="Tab2">Support</label></th>
						<cfelse>
							<th bgcolor="#thclr#">Support</th>
						</cfif>
						<cfif CompletedTab GT 1>
							<th bgcolor=<cfif Tab Is 3>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input type="radio" <cfif tab is 3>checked</cfif> name="tab" value="3" onclick="submit()" id="Tab3"><label for="Tab3">Service</label></th>
						<cfelse>
							<th bgcolor="#thclr#">Service</th>
						</cfif>
						<cfif CompletedTab GT 2>
							<th bgcolor=<cfif Tab Is 4>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input type="radio" <cfif tab is 4>checked</cfif> name="tab" value="4" onclick="submit()" id="Tab4"><label for="Tab4">Integration</label></th>
						<cfelse>
							<th bgcolor="#thclr#">Integration</th>
						</cfif>
						<cfif CompletedTab GT 3>
							<th bgcolor=<cfif Tab Is 5>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input type="radio" <cfif tab is 5>checked</cfif> name="tab" value="5" onclick="submit()" id="Tab5"><label for="Tab5">Financial</label></th>
						<cfelse>
							<th bgcolor="#thclr#">Financial</th>
						</cfif>
						<cfif CompletedTab GT 4>
							<th bgcolor=<cfif Tab Is 6>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input type="radio" <cfif tab is 6>checked</cfif> name="tab" value="6" onclick="submit()" id="Tab6"><label for="Tab6">Final Verification</label></th>
						</cfif>
					</tr>
				</form>
			</table>
		</th>
	</tr>
</cfoutput>
<cfif tab Is 6>
	<cfinclude template="account3.cfm">
<cfelse>
<cfoutput>
	<tr valign="top">
		<td bgcolor="#tbclr#" colspan="#HowWide#"><b>* Required</b></td>
	</tr>
	<form name="info" action="account1.cfm" method="post">
		<input type="hidden" name="tab" value="#tab#">
</cfoutput>	
<cfset PageNumber = Tab>
<cfinclude template="wizardfields.cfm">
<cfoutput>
	<cfif IsDefined("AccountID")>
		<input type="hidden" name="AccountID" value="#AccountID#">
		<cfif tab Is 4>
			<cfif HideRow Is 0><tr valign="top"></cfif>
				<th colspan="#HowWide#"><Input type="image" name="AccountInfo" src="images/update.gif" border="0"></th>
			<cfif CheckPayType GT 0></tr></cfif>
		<cfelseif tab Is 5>
			<cfif CheckPayType Is 0>
				<input type="hidden" name="NoAdvance" value="1">
			</cfif>
			<cfif HideRow Is 0><tr valign="top"></cfif>
				<th colspan="#HowWide#"><Input type="image" name="PaymentInfo" src="images/update.gif" border="0"></th>
			<cfif CheckPayType GT 0></tr></cfif>
		<cfelse>
			<cfif HideRow Is 0><tr valign="top"></cfif>
				<th colspan="#HowWide#"><Input type="image" name="UpdateAccount" src="images/update.gif" border="0"></th>
			<cfif CheckPayType GT 0></tr></cfif>
		</cfif>
	<cfelse>
		<cfif HideRow Is 0><tr valign="top"></cfif>
			<th colspan="#HowWide#"><Input type="image" name="AddAccount" src="images/enter.gif" border="0"></th>
		<cfif CheckPayType GT 0></tr></cfif>
	</cfif>
</cfoutput>	
</cfif>
</table>
</form>

</center>
<cfinclude template="footer.cfm">
</body>
</html>

            
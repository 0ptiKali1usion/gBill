<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- Make financial adjustments on accounts. --->
<!--- adjustment.cfm --->

<cfset securepage="lookup1.cfm">
<cfinclude template="security.cfm">

<cfif IsDefined("AdjEnter.x")>
	<cfquery name="GetIds" datasource="#pds#">
		SELECT PayBy, FTPDomainID, AuthDomainID, EMailDomainID, POPID, PlanID, AccntPlanID 
		FROM AccntPlans
		WHERE AccountID = #AccountID#
	</cfquery>
	<cfquery name="MultiCheck" datasource="#pds#">
		SELECT PrimaryID 
		FROM Multi 
		WHERE AccountID = #AccountID#
	</cfquery>
	<cfquery name="PersonalInfo" datasource="#pds#">
		SELECT FirstName, LastName, SalesPersonID 
		FROM Accounts 
		WHERE AccountID = #AccountID# 
	</cfquery>
	<cfset Date1 = LSParseDateTime(AdjDate)>
	<cftransaction>
		<cfquery name="InsAdj" datasource="#pds#">
			INSERT INTO TransActions 
			(AccountID,DateTime1,Credit,Debit,TaxYN,TaxLevel,CreditLeft,DebitLeft,
			 MemoField,AdjustmentYN,EnteredBy,
			 EMailDomainID,FTPDomainID,AuthDomainID,POPID,PlanID,FinishedYN,
			 SubAccountID,SetUpFeeYN,
			 PaymentDueDate,AccntCutOffDate,PrintedYN, PaymentLateDate,
			 EMailStateYN,DepositedYN,BatchPendingYN,DebitFromDate, DebitToDate,
			 SalesPersonID,AccntPlanID,DiscountYN,
			 FirstName, LastName, PlanPayBy)
			VALUES 
			(<cfif MultiCheck.RecordCount Is 0>#AccountID#<cfelse>#MultiCheck.PrimaryID#</cfif>, 
			 #CreateODBCDate(Date1)#, 
			 <cfif AdjType Is "Credit">
			 	#AdjAmount#, 0, 0, 0, #AdjAmount#, 0, 
			 <cfelse>
			 	0, #AdjAmount#, 0, 0, 0, #AdjAmount#, 
			 </cfif>
			 '#AdjReason#', 1, '#StaffMemberName.Firstname# #StaffMemberName.LastName#', 
			 <cfif GetIds.EMailDomainID Is "">Null<cfelse>#GetIds.EMailDomainID#</cfif>, 
			 <cfif GetIds.FTPDomainID Is "">Null<cfelse>#GetIds.FTPDomainID#</cfif>,
			 <cfif GetIds.AuthDomainID Is "">Null<cfelse>#GetIds.AuthDomainID#</cfif>,
			 <cfif GetIds.POPID Is "">Null<cfelse>#GetIds.POPID#</cfif>, 
			 <cfif GetIds.PlanID Is "">Null<cfelse>#GetIds.PlanID#</cfif>, 0,
			 #AccountID#, 0, Null, Null, 0, Null, 0, 0, 0, Null, Null, 
			 #PersonalInfo.SalesPersonID#, #GetIds.AccntPlanID#, 0, 
			 '#PersonalInfo.FirstName#', '#PersonalInfo.LastName#', <cfif GetIds.PayBy Is "">'CK'<cfelse>'#GetIds.PayBy#'</cfif>)
		</cfquery>
		<cfquery name="NewTopID" datasource="#pds#">
			SELECT Max(TransID) as TopID 
			FROM TransActions 
		</cfquery>
		<cfset TransID = NewTopID.TopID>
	</cftransaction>
	<cfset TheAccountID = AccountID>
	<cfset TransType = AdjType>
	<cfinclude template="cfpayment.cfm">
	<cfsetting enablecfoutputonly="No">
	<cfinclude template="custinf1.cfm">
	<cfabort>
</cfif>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Enter An Adjustment</title>
<cfinclude template="coolsheet.cfm">
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<form method="post" action="custinf1.cfm">
	<input type="Image" src="images/return.gif" border="0">
	<cfoutput><input type="Hidden" name="AccountID" value="#AccountID#"></cfoutput>
</form>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="2" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Enter An Adjustment</font></th>
	</tr>
	<form method="post" action="adjustment.cfm">
		<tr valign="top">
			<td align="right" bgcolor="#tbclr#">Type</td>
			<td bgcolor="#tdclr#"><input type="Radio" name="AdjType" value="Credit"> Credit <input type="Radio" checked name="AdjType" value="Debit"> Debit</td>
		</tr>
		<tr>
			<td align="right" bgcolor="#tbclr#">Amount</td>
			<td bgcolor="#tdclr#"><input type="Text" name="AdjAmount"></td>
		</tr>
		<tr>
			<td align="right" bgcolor="#tbclr#">Date</td>
			<td bgcolor="#tdclr#"><input type="Text" value="#LSDateFormat(Now(), '#DateMask1#')#" name="AdjDate"></td>
		</tr>
		<tr valign="top">
			<td align="right" bgcolor="#tbclr#">Reason</td>
			<td bgcolor="#tdclr#"><textarea cols="35" rows="4" name="AdjReason"></textarea></td>
		</tr>
		<tr>
			<td colspan="2" bgcolor="#tbclr#">Entered By: #StaffMemberName.FirstName# #StaffMemberName.LastName#</td>
		</tr>
		<tr>
			<th colspan="2"><input type="Image" name="AdjEnter" src="images/adjustment.gif" border="0"></th>
		</tr>
		<input type="Hidden" name="AccountID" value="#AccountID#">
	</form>
</cfoutput>


</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 

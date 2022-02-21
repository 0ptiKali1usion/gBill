<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- Account management. --->
<!---	4.0.0 04/10/00 --->
<!--- accntmanage7.cfm --->

<cfif GetOpts.ChPlan Is 1>
	<cfset securepage="lookup1.cfm">
</cfif>
<cfinclude template="security.cfm">

<cfquery name="CurPlan" datasource="#pds#">
	SELECT PlanID, PlanDesc, RecurDiscount, FixedDiscount, FixedAmount, RecurringAmount, DefPlan, RecurringCycle, 
	OSPlanDisplay, AWPlanDisplay 
	FROM Plans 
	WHERE PlanID IN 
		(SELECT PlanID 
		 FROM AccntPlans 
		 WHERE AccntPlanID = #AccntPlanID#)
</cfquery>
<cfquery name="OtherInfo" datasource="#pds#">
	SELECT * 
	FROM AccntPlans 
	WHERE AccntPlanID = #AccntPlanID#
</cfquery>
<cfquery name="AuthCount" datasource="#pds#">
	SELECT UserName 
	FROM AccountsAuth 
	WHERE AccntPlanID = #AccntPlanID# 
	ORDER BY UserName 
</cfquery>
<cfquery name="FTPInfo" datasource="#pds#">
	SELECT UserName 
	FROM AccountsFTP 
	WHERE AccntPlanID = #AccntPlanID# 
	ORDER BY UserName 
</cfquery>
<cfquery name="EMailInfo" datasource="#pds#">
	SELECT Email 
	FROM AccountsEMail 
	WHERE AccntPlanID = #AccntPlanID# 
	AND ContactYN = 0 
	ORDER BY EMail 
</cfquery>
<cfquery name="AvailPlans" datasource="#pds#">
	SELECT PlanID, PlanDesc, RecurDiscount, FixedDiscount, FixedAmount, RecurringAmount, DefPlan, RecurringCycle, 
	OSPlanDisplay, AWPlanDisplay, AuthNumber, FTPNumber, FreeEmails 
	FROM Plans 
	WHERE PlanID <> #delaccount# 
	AND PlanID <> #deactaccount# 
	AND PlanID NOT IN 
		(SELECT PlanID 
		 FROM AccntPlans 
		 WHERE AccntPlanID = #AccntPlanID#)
	<cfif IsDefined("GetOpts")>
		AND PlanID In 
				(SELECT PlanID 
				 FROM PlanAdm 
				 WHERE AdminID = #GetOpts.AdminID#)
	</cfif>
	AND PlanID In 
		(SELECT PlanID 
		 FROM POPPlans 
		 WHERE POPID = 
		 	(SELECT POPID 
			 FROM AccntPlans 
			 WHERE AccntPlanID = #AccntPlanID#)
		 ) 
	<cfif GetOpts.OverRide Is 0>
		AND AuthNumber >= #AuthCount.RecordCount# 
		AND FTPNumber >= #FTPInfo.RecordCOunt# 
		AND FreeEMails >= #EMailInfo.RecordCount# 
	</cfif>
	<cfif IsDefined("PromoCode")>
		OR PlanID In 
			(SELECT PlanID 
			 FROM Plans 
			 WHERE TotalInternetCode = '#PromoCode#')
	</cfif>
	ORDER BY PlanDesc
</cfquery>
<cfquery name="AccntInfo" datasource="#pds#">
	SELECT AccountID 
	FROM AccntPlans 
	WHERE AccntPlanID = #AccntPlanID# 
</cfquery>
<cfquery name="CustName" datasource="#pds#">
	SELECT FirstName, LastName 
	FROM Accounts 
	WHERE AccountID = #AccntInfo.AccountID# 
</cfquery>
<cfhtmlhead text="<script language=""javascript"">
<!--  
function MsgWindow(var1)
	{
 	 var var2 = var1
    window.open('plandesc.cfm?PlanID='+var2,'Description','scrollbars=auto,status=no,width=400,height=200,location=no,resizable=no');
	}
// -->
</script>
">

<cfquery name="GetLocale" datasource="#pds#">
	SELECT Value1 
	FROM Setup 
	WHERE VarName = 'Locale'
</cfquery>
<cfset Locale = GetLocale.Value1>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Select New Service</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<form method="post" action="accntmanage.cfm">
	<input type="image" src="images/return.gif" border="0">
	<cfoutput><input type="hidden" name="AccountID" value="#AccntInfo.AccountID#"></cfoutput>
	<input type="hidden" name="Tab" value="2">
</form>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th bgcolor="#ttclr#" colspan="11"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">#CustName.FirstName# #CustName.LastName#<br>Change Plan</font></th>
	</tr>
	<form method="post" action="accntmanage8.cfm">
		<tr bgcolor="#thclr#">
			<th>Selected</th>
			<th>Months</th>
			<th>Service</th>
			<th>Recurring</th>
			<th>Discount</th>
			<th>Setup</th>
			<th>Discount</th>
			<th>Total</th>
			<th>Auth</th>
			<th>EMail</th>
			<th>FTP</th>
		</tr>
		<tr bgcolor="#tdclr#">
			<th bgcolor="#tbclr#">Current</th>
			<td>#Int(CurPlan.RecurringCycle)# <cfif CurPlan.RecurringCycle Is 1>Month<cfelse>Months</cfif></td>
			<td>#CurPlan.PlanDesc#</td>
			<td align="right">#LSCurrencyFormat(CurPlan.RecurringAmount)#</td>
			<td align="right">#LSCurrencyFormat(CurPlan.RecurDiscount)#</td>
			<td align="right">#LSCurrencyFormat(CurPlan.FixedAmount)#</td>
			<td align="right">#LSCurrencyFormat(CurPlan.FixedDiscount)#</td>
			<cfset TOT = CurPlan.RecurringAmount + CurPlan.FixedAmount - CurPlan.RecurDiscount - CurPlan.FixedDiscount>
			<td align="right">#LSCurrencyFormat(TOT)#</td>
			<td align="right">#AuthCount.RecordCount#</td>
			<td align="right">#FTPInfo.RecordCount#</td>
			<td align="right">#EMailInfo.RecordCount#</td>
			<input type="Hidden" name="CurPlanID" value="#CurPlan.PlanID#">
		</tr>
		<tr>
			<th colspan="11" bgcolor="#thclr#">Change To</th>
		</tr>
		<tr bgcolor="#thclr#">
			<th>Select</th>
			<th>Months</th>
			<th>Service</th>
			<th>Recurring</th>
			<th>Discount</th>
			<th>Setup</th>
			<th>Discount</th>
			<th>Total</th>
			<th>Auth</th>
			<th>EMail</th>
			<th>FTP</th>
		</tr>
</cfoutput>
		<cfloop query="AvailPlans">
			<cfoutput>
				<tr bgcolor="#tbclr#">
					<th bgcolor="#tdclr#"><input type="Radio" name="NewPlanID" value="#PlanID#" onclick="submit()"></th>
					<td align="right">#Int(RecurringCycle)# <cfif RecurringCycle Is 1>Month<cfelse>Months</cfif></td>
					<cfif (Trim(AWPlanDisplay) Is Not "") OR (Trim(OSPlanDisplay) Is Not "")>
						<td><a href="plandesc.cfm?PlanID=#PlanID#" target="_PlanDesc" onclick="MsgWindow(#PlanID#);return false"><cfif (Trim(AWPlanDisplay) Is Not "")>! </cfif> *#PlanDesc#</a></td>
					<cfelse>
						<td>#PlanDesc#</td>
					</cfif>
					<td align="right">#LSCurrencyFormat(RecurringAmount)#</td>
					<td align="right">#LSCurrencyFormat(RecurDiscount)#</td>
					<td align="right">#LSCurrencyFormat(FixedAmount)#</td>
					<td align="right">#LSCurrencyFormat(FixedDiscount)#</td>
					<cfset TOT = RecurringAmount + FixedAmount - RecurDiscount - FixedDiscount>
					<td align="right">#LSCurrencyFormat(TOT)#</td>		
					<td align="right">#AuthNumber#</td>
					<td align="right">#FTPNumber#</td>
					<td align="right">#FreeEmails#</td>
				</cfoutput>
			</tr>
		</cfloop>
<cfoutput>
		<cfif AvailPlans.Recordcount Is 0>
			<tr>
				<td bgcolor="#tbclr#" colspan="11">No plans available to change to.</td>
			</tr>
		</cfif>
		<tr>
			<td colspan="11" bgcolor="#thclr#">* Click on the Service Name for a description.<cfif IsDefined("MyAdminID")><br>! Important Staff Note</cfif></td>
		</tr>	
		<input type="Hidden" name="AccntPlanID" value="#AccntPlanID#">
	</form>
	<form method="post" action="accntmanage7.cfm">
		<tr>
			<th bgcolor="#tbclr#">Promo</th>
			<td bgcolor="#tdclr#" colspan="10"><input type="Text" <cfif IsDefined("PromoCode")>value="#PromoCode#"</cfif> name="PromoCode"></td>
		</tr>
		<input type="Hidden" name="AccntPlanID" value="#AccntPlanID#">
		<tr>
			<th colspan="11"><input type="image" src="images/enter.gif" border="0"></th>
		</tr>
	</form>
</table>
</cfoutput>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
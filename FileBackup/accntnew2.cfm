<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- Account Management. --->
<!---	4.0.0 04/11/00 --->
<!--- accntnew2.cfm --->

<cfset securepage="lookup1.cfm">
<cfinclude template="security.cfm">

<cfquery name="AvailPlans" datasource="#pds#">
	SELECT PlanID, PlanDesc, RecurDiscount, FixedDiscount, FixedAmount, RecurringAmount, DefPlan, RecurringCycle, 
	OSPlanDisplay, AWPlanDisplay, AuthNumber, FTPNumber, FreeEmails  
	FROM Plans 
	WHERE PlanID <> #delaccount# 
	AND PlanID <> #deactaccount# 
	<cfif IsDefined("GetOpts")>
		AND PlanID In 
				(SELECT PlanID 
				 FROM PlanAdm 
				 WHERE AdminID = #GetOpts.AdminID#)
	</cfif>
	AND PlanID In 
			(SELECT PlanID 
			 FROM POPPlans 
			 WHERE POPID = #POPID#) 
	<cfif IsDefined("PromoCode")>
		OR PlanID In 
			(SELECT PlanID 
			 FROM Plans 
			 WHERE TotalInternetCode = '#PromoCode#')
	</cfif>
	ORDER BY PlanDesc
</cfquery>
<cfquery name="CustName" datasource="#pds#">
	SELECT FirstName, LastName 
	FROM Accounts 
	WHERE AccountID = #AccountID# 
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


<cfsetting enablecfoutputonly="No">
<html>
<head>
<title>Add Plan</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<form method="post" action="accntnew.cfm">
	<input type="image" src="images/return.gif" border="0">
	<cfoutput>
		<input type="hidden" name="accountid" value="#AccountID#">
		<input type="Hidden" name="selPOPID" value="#POPID#">
	</cfoutput>
</form>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th bgcolor="#ttclr#" colspan="11"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">#CustName.FirstName# #CustName.LastName# Select Plan</font></th>
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
<form method="post" action="accntnew3.cfm">
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
	<tr>
		<td colspan="11" bgcolor="#thclr#">* Click on the Service Name for a description.<cfif IsDefined("MyAdminID")><br>! Important Staff Note</cfif></td>
	</tr>	
	<input type="Hidden" name="PromoCode" <cfif IsDefined("PromoCode")>value="#PromoCode#"</cfif> >
	<input type="Hidden" name="POPID" value="#POPID#">
	<input type="Hidden" name="AccountID" value="#AccountID#">
</cfoutput>
</form>
<form method="post" action="accntnew2.cfm">
	<cfoutput>
	<tr>
		<th bgcolor="#tbclr#">Promo</th>
		<td bgcolor="#tdclr#" colspan="10"><input type="Text" <cfif IsDefined("PromoCode")>value="#PromoCode#"</cfif> name="PromoCode"></td>
	</tr>
	<tr>
		<th colspan="11"><input type="image" src="images/enter.gif" border="0"></th>
	</tr>
	<input type="Hidden" name="POPID" value="#POPID#">
	<input type="Hidden" name="AccountID" value="#AccountID#">
	</cfoutput>
</form>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 
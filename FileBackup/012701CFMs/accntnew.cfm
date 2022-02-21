<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- Account Management. --->
<!---	4.0.0 04/11/00 --->
<!--- accntnew.cfm --->

<cfset securepage="lookup1.cfm">
<cfinclude template="security.cfm">

<cfif Not IsDefined("selPOPID")>
	<cfquery name="AcntInfo" datasource="#pds#">
		SELECT POPID 
		FROM AccntPlans 
		WHERE AccountID = #AccountID# 	
	</cfquery>
	<cfif AcntInfo.Recordcount Is 1>
		<cfset SelPOPID = AcntInfo.POPID>
	<cfelse>
		<cfset SelPOPID = 0>
	</cfif>
</cfif>
<cfquery name="PersInfo" datasource="#pds#">
	SELECT State 
	FROM Accounts 
	WHERE AccountID = #AccountID#
</cfquery>
<cfquery name="AvailPOPs" datasource="#pds#">
	SELECT P.POPID, P.POPName 
	FROM POPs P, POPsStates S 
	WHERE P.POPID = S.POPID 
	<cfif IsDefined("GetOpts")>
		AND P.POPID In 
			(SELECT POPID 
			 FROM POPAdm 
			 WHERE AdminID = #GetOpts.AdminID#) 
	</cfif>
	AND S.StateID = 
		(Select StateID 
		 FROM States 
		 WHERE Abbr = '#PersInfo.State#')
</cfquery>
<cfif AvailPOPS.RecordCount Is 0>
	<cfquery name="AvailPOPs" datasource="#pds#">
		SELECT P.POPID, P.POPName 
		FROM POPs P 
		WHERE DefPOP = 1 
	</cfquery>
</cfif>

<cfsetting enablecfoutputonly="No">
<html>
<head>
<title>Add Plan</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<form method="post" action="accntmanage.cfm">
	<input type="image" src="images/return.gif" border="0">
	<cfoutput><input type="hidden" name="accountid" value="#AccountID#"></cfoutput>
</form>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th bgcolor="#ttclr#" colspan="2"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Select POP</font></th>
	</tr>
	<form method="post" action="accntnew2.cfm">
		<tr bgcolor="#tdclr#">
			<td bgcolor="#tbclr#" align="right">Select the POP</td>
</cfoutput>
			<td><select name="POPID">
				<cfloop query="AvailPOPs">
					<cfoutput><option <cfif POPID Is SelPOPID>selected</cfif> value="#POPID#">#POPName#</cfoutput>
				</cfloop>
			</select></td>
		</tr>
		<tr>
			<th colspan="2"><input type="Image" border="0" src="images/continue.gif" name="Step2"></th>
		</tr>
		<cfoutput><input type="Hidden" name="AccountID" value="#AccountID#"></cfoutput>
	</form>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 

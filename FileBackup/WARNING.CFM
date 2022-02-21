<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page displays the expiration warning. --->
<!--- 4.0.0 11/02/99 
		3.2.0 09/08/98 --->
<!--- warning.cfm --->

<cfinclude template="license.cfm">
<cfset dateval = DateCompare(expdate, Now())>
<cfset diff1 = datediff("d", Now(), expdate)>

<cfsetting enablecfoutputonly="no">
<cfif diff1 lt expdays>
	<cfoutput>
	<center>
	<table border="#tblwidth#">
		<tr>
			<td bgcolor="#tbclr#"><font size="5">This copy of gBill expires on #expdate#.</font><br>
			Please contact GreenSoft Solutions, Inc. to obtain a newer license.</td>
		</tr>
	</table>
	</center>
	</cfoutput>
</cfif>
 
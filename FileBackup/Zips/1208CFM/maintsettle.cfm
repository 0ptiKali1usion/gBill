<cfsetting enablecfoutputonly="Yes">
<!--- Version 4.0.0 --->
<!--- MaintSettle.CFM should be placed in the CFM directory of your IBOB installation   --->
<!--- and scheduled to run every n hours.  If it does not find any batches to settle, it --->
<!--- will just quiety run.  If it does find a batch to settle, it will settle it, and --->
<!--- notify the person(s) listed in the <CFSET SettleNotify> section of pcchargevars.cfm --->
<!--- 4.0.0 11/30/00 
		3.2.0 09/08/98 --->
<!--- maintsettle.cfm --->

<cfquery name="SetupValues" datasource="#pds#">
	SELECT Value1, VarName 
	FROM Setup 
	WHERE VarName In ('DateMask1', 'Locale')
</cfquery>
<cfloop query="SetupValues">
	<cfset "#VarName#" = Value1>
</cfloop>

<cfquery name="GetValues" datasource="#pds#">
	SELECT FieldName1, FieldValue 
	FROM CustomCCOutput 
	WHERE UseTab = 5 
</cfquery>
<cfloop query="GetValues">
	<cfset "#FieldName1#" = FieldValue>
</cfloop>

<cfobject action="CREATE" name="Batch1" class="PSCharge.Batch">
	<cfset Batch1.Path = Path>
	<cfset Batch1.Processor = Processor >
	<cfset Batch1.MerchantNumber = MerchantAccount>
	<cfset Batch1.User = Login>
	<cfset Batch1.Action = 30>
<cfset Batch1.Send()>

<cfif Trim(Batch1.GetStatus()) is "OPEN">
	<cfset Batch1.DeleteUserFiles()>

	<cfobject action="CREATE" name="Batch2" class="PSCharge.Batch">
		<cfset Batch2.Path = Path>
		<cfset Batch2.Processor = Processor >
		<cfset Batch2.MerchantNumber = MerchantNumber>
		<cfset Batch2.User = User>
		<cfset Batch2.Action = 31>
	<cfset Batch2.Send()>
	
	<cfif SettleNotify neq "">
		<cfmail to="#MerchantEMail#" from="#MerchantEMail#" subject="Batch Settlement Results for #LSDateFormat(Now(), '#DateMask1#')# #TimeFormat(NOW(), 'hh:mm tt')#">
A Credit Card batch was settled at #TimeFormat(Now(), 'hh:mm tt')# with the following results.

Message: #Batch2.GetStatus()#
ItemCnt: #Batch2.GetItemCount()#
Balance: #Batch2.GetBalance()#

</CFMAIL>
	</cfif>
	<cfset Batch2.DeleteUserFiles()>
<CFELSE>
	<cfset Batch1.DeleteUserFiles()>
</cfif>
<cfsetting enablecfoutputonly="No">
 
<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This is page 3 that makes the deposit. --->
<!---	4.0.0 09/07/99 --->
<!--- depositnew3.cfm --->

<cfset securepage = "depositnew.cfm">
<cfinclude template="security.cfm">
<cftransaction>
<cfquery name="InsData" datasource="#pds#">
	INSERT INTO DepositHist 
	(DepositDate, DepositNumID, DepositNumber, AccountID, TransID, 
	PaymentDate, PayAmount, PaymentMemo, PayType, ChkNumber, FirstName, 
	Lastname) 
	SELECT #CreateODBCDate(DepositDate)#, #NextID#, '#DepositNumber#', T.AccountID, 
	T.TransID, T.DateTime1, T.Credit, T.MemoField, T.PayType, T.ChkNumber, 
	A.FirstName, A.LastName 
	FROM Transactions T, Accounts A 
	WHERE T.AccountID = A.AccountID 
	AND T.TransID In (#Deposit#) 
</cfquery>
<cfquery name="UpdData" datasource="#pds#">
	UPDATE Transactions SET 
	DepositDate = #CreateODBCDate(DepositDate)#, 
	DepositedYN = 1 
	WHERE TransID In (#Deposit#) 
</cfquery>
<cfif Not IsDefined("NoBOBHist")>
	<cfquery name="GetLocale" datasource="#pds#">
		SELECT Value1, VarName 
		FROM Setup 
		WHERE VarName In ('Locale','DateMask1')
	</cfquery>
	<cfloop query="GetLocale">
		<cfset "#VarName#" = Value1>
	</cfloop>
	<cfquery name="BOBHist" datasource="#pds#">
		INSERT INTO BOBHist
		(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
		VALUES 
		(Null,0,#MyAdminID#, #Now()#,'Create Deposit','#StaffMemberName.FirstName# #StaffMemberName.LastName# created deposit number #DepositNumber# for #LSDateFormat(DepositDate ,'#DateMask1#')#')
	</cfquery>
</cfif>
</cftransaction>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Deposit Finished</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<td bgcolor="#tbclr#">Deposit Finished.  To print a deposit slip click 'Print Slip' below.</td>
	</tr>
	<tr>
		<form method="post" action="depositslip.cfm" target="_New">
			<input type="hidden" name="Deposit" value="#Deposit#">
			<input type="hidden" name="DepositDate" value="#DepositDate#">
			<input type="hidden" name="DepositNumber" value="#DepositNumber#">
			<th><input type="image" src="images/printslip.gif" name="PrintSlip" border="0"></th>
		</form>
	</tr>
</cfoutput>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
    
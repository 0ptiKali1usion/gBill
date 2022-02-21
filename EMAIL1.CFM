<cfsetting enablecfoutputonly="yes">
<!-- Version 4.0.0 -->
<!--- This is page 2 of the mass emailer. --->
<!--- 4.0.0 09/08/98 --->
<!-- email1.cfm -->

<cfset securepage = "email.cfm">
<cfinclude template="security.cfm">
<cfif IsDefined("SaveFilter")>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT * 
		FROM Filters 
		WHERE AdminID = #MyAdminID# 
		AND LetterID = 6 
		AND FilterName = <cfif Trim(FilterName) Is "">'Default'<cfelse>'#FilterName#'</cfif> 
	</cfquery>
	<cfif CheckFirst.RecordCount GT 0>
		<cfquery name="CleanUp" datasource="#pds#">
			Delete FROM FilterDomains 
			WHERE FilterID = #CheckFirst.FilterID#
		</cfquery>
		<cfquery name="CleanUp" datasource="#pds#">
			Delete FROM FilterPlans 
			WHERE FilterID = #CheckFirst.FilterID#
		</cfquery>
		<cfquery name="CleanUp" datasource="#pds#">
			Delete FROM FilterPOPs 
			WHERE FilterID = #CheckFirst.FilterID#
		</cfquery>
		<cfquery name="CleanUp" datasource="#pds#">
			Delete FROM FilterSalesp 
			WHERE FilterID = #CheckFirst.FilterID#
		</cfquery>
		<cfquery name="ChangeFilter" datasource="#pds#">
			DELETE FROM Filters 
			WHERE FilterID = #CheckFirst.FilterID#
		</cfquery>
		<cfquery name="CheckFirst" datasource="#pds#">
			SELECT * 
			FROM Filters 
			WHERE AdminID = #MyAdminID# 
			AND ReportID = 4 
			AND FilterName = <cfif Trim(FilterName) Is "">'Default'<cfelse>'#FilterName#'</cfif> 
		</cfquery>
	</cfif>
	<cfif CheckFirst.RecordCount Is 0>
		<cftransaction>
			<cfquery name="AddFilter" datasource="#pds#">
				INSERT INTO Filters 
				(AdminID,LetterID,FilterName,FirstParam,SecondParam,FirstAction,SecondAction,
				 FirstField,SecondField,LogicConnect,ActiveStatus) 
				VALUES 
				(#MyAdminID#,6,
				 <cfif Trim(FilterName) Is "">'Default'<cfelse>'#FilterName#'</cfif>,
				 '#BegDay#', '#EndDay#',
				 <cfif Trim(MinAmnt) Is "">Null<cfelse>'#MinAmnt#'</cfif>,
				 <cfif Trim(MinCredit) Is "">Null<cfelse>'#MinCredit#'</cfif>,
				 <cfif Not IsDefined("Credit")>Null<cfelse>'#Credit#'</cfif>, 
				 <cfif Not IsDefined("CheckD")>Null<cfelse>'#CheckD#'</cfif>, 
				 <cfif Not IsDefined("Postal")>Null<cfelse>'#Postal#'</cfif>,
				 <cfif Not IsDefined("GroupSubs")>Null<cfelse>'#GroupSubs#'</cfif>)
			</cfquery>
			<cfquery name="NewFilter" datasource="#pds#">
				SELECT Max(FilterID) as NewID 
				FROM Filters 
			</cfquery>
			<cfset FilterID = NewFilter.NewID>
		</cftransaction>
		<cfloop index="B5" list="#PlanID#">
			<cfif (B5 Is Not "") AND (B5 GT 0)>
				<cfquery name="AddData" datasource="#pds#">
					INSERT INTO FilterPlans 
					(FilterID, PlanID) 
					VALUES 
					(#FilterID#, #B5#)
				</cfquery>
			</cfif>
		</cfloop>
		<cfloop index="B5" list="#POPID#">
			<cfif (B5 Is Not "") AND (B5 GT 0)>
				<cfquery name="AddData" datasource="#pds#">
					INSERT INTO FilterPOPs 
					(FilterID, POPID) 
					VALUES 
					(#FilterID#, #B5#)
				</cfquery>
			</cfif>
		</cfloop>
		<cfloop index="B5" list="#DomainID#">
			<cfif (B5 Is Not "") AND (B5 GT 0)>
				<cfquery name="AddData" datasource="#pds#">
					INSERT INTO FilterDomains 
					(FilterID, DomainID) 
					VALUES 
					(#FilterID#, #B5#)
				</cfquery>
			</cfif>
		</cfloop>
		<cfloop index="B5" list="#SalesPID#">
			<cfif (B5 Is Not "") AND (B5 GT 0)>
				<cfquery name="AddData" datasource="#pds#">
					INSERT INTO FilterSalesp 
					(FilterID, AdminID) 
					VALUES 
					(#FilterID#, #B5#)
				</cfquery>
			</cfif>
		</cfloop>
	</cfif>
</cfif>
<cfquery name="GetEMail" datasource="#pds#">
	SELECT EMail 
	FROM AccountsEMail 
	WHERE PREmail = 1 
	AND AccountID = (SELECT AccountID 
						  FROM Admin 
						  WHERE AdminID = #MyAdminID#)
</cfquery>
<cfquery name="EmailDom" datasource="#pds#">
	SELECT DomainName 
	FROM Domains 
	WHERE DomainID In
		(SELECT D.DomainID 
		 FROM Domains D, DomAdm A
		 WHERE D.DomainID = A.DomainID 
		 AND A.AdminID = #MyAdminID#)
</cfquery>
<cfquery name="GetLetters" datasource="#pds#">
	SELECT IntID, IntDesc 
	FROM Integration 
	WHERE Action = 'Letter' 
	AND ActiveYN = 1 
	ORDER BY SortOrder
</cfquery>
<cfif GetEMail.Recordcount Is 0>
	<cfparam name="WhoFrom" default="billing">
<cfelse>
	<cfparam name="WhoFrom" default="#GetEMail.EMail#">
</cfif>
<cfparam name="Message" default="">
<cfparam name="Subject" default="">
<cfparam name="BDomainName" default="">
<cfparam name="whofrom2" default="">
<cfparam name="CDomainName" default="">
<cfparam name="SDomainName" default="">
<cfparam name="whofrom2" default="">
<cfparam name="LetterID" default="0">
<cfquery name="CheckFirst" datasource="#pds#">
	SELECT FirstName 
	FROM EMailOutgoing 
	WHERE AdminID = #MyAdminID# 
	AND LetterID = 6
</cfquery>
<cfsetting enablecfoutputonly="no">
<html>
<head>
<script language="javascript">
<!--
function CheckEMail()
   {
   var testy2 = document.EMail.Message.value.length
	var var1 = document.EMail.LetterID.options[document.EMail.LetterID.selectedIndex].value
	if (testy2 < 1  && var1 == 0)
		{
		 alert ('Please enter your message')
		 document.EMail.Message.focus()
	    return false
		}
    var testy1 = document.EMail.Subject.value.length
    if (testy1 < 1 && var1 == 0)
	   {
	   document.EMail.Subject.focus()
	   return confirm ('You have left the subject blank.  Continue?')
	   }
    return true
   }
// -->
</script>
<title>Mass E-Mail Letter</title>
</head>
<cfoutput><body #colorset# onLoad="document.EMail.Subject.focus()"></cfoutput>
<cfinclude template="header.cfm">
<form method="post" action="email.cfm">
	<input type="image" src="images/changecriteria.gif" name="StartOver" border="0">
	<cfoutput>
		<input type="hidden" name="WhoFrom" value="#WhoFrom#">
		<input type="hidden" name="Message" value="#Message#">
		<input type="hidden" name="Subject" value="#Subject#">
		<input type="hidden" name="BDomainName" value="#BDomainName#">
		<input type="hidden" name="CDomainName" value="#CDomainName#">
		<input type="hidden" name="SDomainName" value="#SDomainName#">
		<input type="hidden" name="whofrom2" value="#whofrom2#">
		<input type="hidden" name="LetterID" value="#LetterID#">
		<input type="hidden" name="BegDay" value="#BegDay#">
		<input type="hidden" name="EndDay" value="#EndDay#">
		<input type="hidden" name="MinAmnt" value="#MinAmnt#">
		<input type="hidden" name="MinCredit" value="#MinCredit#">
		<cfif IsDefined("Credit")>
			<input type="hidden" name="Credit" value="#Credit#">
		<cfelse>
			<input type="hidden" name="Credit" value="0">
		</cfif>
		<cfif IsDefined("CheckD")>
			<input type="hidden" name="CheckD" value="#CheckD#">
		<cfelse>
			<input type="hidden" name="CheckD" value="0">
		</cfif>
		<cfif IsDefined("Postal")>
			<input type="hidden" name="Postal" value="#Postal#">
		<cfelse>
			<input type="hidden" name="Postal" value="0">
		</cfif>
		<cfif IsDefined("GroupSubs")>
			<input type="hidden" name="GroupSubs" value="#GroupSubs#">
		<cfelse>
			<input type="hidden" name="GroupSubs" value="0">
		</cfif>
		<input type="hidden" name="DomainID" value="#DomainID#">
		<input type="hidden" name="TheDomainID" value="#DomainID#">
		<input type="hidden" name="PlanID" value="#PlanID#">
		<input type="hidden" name="ThePlanID" value="#PlanID#">
		<input type="hidden" name="POPID" value="#POPID#">
		<input type="hidden" name="ThePOPID" value="#POPID#">
		<input type="hidden" name="SalesPID" value="#SalesPID#">
	</cfoutput>
</form>
<center>
<form method="post" name="EMail" action="email2.cfm" onsubmit="return CheckEMail()">
<cfoutput>
<table border="#tblwidth#" bgcolor="#tdclr#">
	<tr bgcolor="#tdclr#">
		<td bgcolor="#tbclr#" align="right">Letter</td>
</cfoutput>
		<td colspan="3"><select name="LetterID">
			<option <cfif LetterID Is 0>selected</cfif> value="0">*** Use Settings Below ***
			<cfoutput query="GetLetters"><option <cfif LetterID Is IntID>selected</cfif> value="#IntID#">#IntDesc#</cfoutput>
		</select></td>
	</tr>
<cfoutput>
	<tr valign="top">
		<td bgcolor="#tbclr#" align="right">From</td>
</cfoutput>
		<td colspan="3">
			<table border="0" cellpadding="0" cellspacing="1">
				<tr>
					<td><INPUT type="Radio" name="whofrom" <cfif whofrom Is "billing">checked</cfif> value="billing"></td>
					<td align="right">billing@<select name="BDomainName">
						<cfoutput query="EmailDom"><option <cfif BDomainName Is DomainName>selected</cfif> value="#DomainName#">#DomainName#</cfoutput>
					</select></td>
					<td><INPUT type="Radio" name="whofrom" <cfif whofrom Is "custom">checked</cfif> value="custom"><INPUT type="text" <cfoutput>value="#whofrom2#"</cfoutput> name="whofrom2" size=10>@<select name="CDomainName">
						<cfoutput query="EmailDom"><option <cfif CDomainName Is DomainName>selected</cfif> value="#DomainName#">#DomainName#</cfoutput>
					</select></td>
				</tr>
				<tr>
					<td><INPUT type="Radio" name="whofrom" <cfif whofrom Is "service">checked</cfif> value="service"></td>
					<td align="right">service@<select name="SDomainName">
						<cfoutput query="EmailDom"><option <cfif SDomainName Is DomainName>selected</cfif> value="#DomainName#">#DomainName#</cfoutput>
					</select></td>
					<cfif GetEmail.Recordcount GT 0>
						<cfoutput>
							<td><INPUT type="Radio" name="whofrom" <cfif whofrom Is "#GetEmail.Email#">checked</cfif> value="#GetEmail.Email#"> #GetEmail.Email#</td>
						</cfoutput>
					</cfif>
				</tr>
			</table>
		</td>
	</tr>
<cfoutput>
	<tr bgcolor="#tdclr#">
		<td bgcolor="#tbclr#" align="right">Subject</td>
		<td colspan="3"><INPUT type="text" name="Subject" value="#Subject#" size="50"></td>
	</tr>
</cfoutput>
	<tr>
		<th colspan="4">
			<table border="0">
				<tr>
					<cfif CheckFirst.RecordCount Is 0>
						<td><input type="image" src="images/sendemail.gif" name="SendNow" border="0"></td>
					<cfelse>
						<td><input type="image" src="images/sendemail.gif" name="SendExisting" border="0"></td>
					</cfif>
					<td><a href="email.cfm" onClick="reset(); return false"><img src="images/clear.gif" border="0" name="reset1"></a></td>
					<cfif CheckFirst.RecordCount Is 0>
						<td><input type="image" src="images/viewlist.gif" name="EditFirst" border="0"></td>
					<cfelse>
						<td><input type="image" src="images/viewlist.gif" name="ListExists" border="0"></td>
					</cfif>
				</tr>
			</table>
		</th>
	</tr>
	<cfoutput>
		<tr>
			<th bgcolor="#tdclr#" colspan="4"><font size="2"><B>Note:</B>Please enter your message, including spacing and signature.</font><BR>
	   	<cfif #http_user_agent# contains "MSIE">
			   <textarea wrap="virtual" name="Message" Rows=7 Cols=90>#Message#</textarea>
		   <cfelse>
	   		<textarea wrap="virtual" name="Message" Rows=7 Cols=70>#Message#</textarea>
		   </cfif></th>
		</tr>
		<input type="hidden" name="BegDay" value="#BegDay#">
		<input type="hidden" name="EndDay" value="#EndDay#">
		<input type="hidden" name="MinAmnt" value="#MinAmnt#">
		<input type="hidden" name="MinCredit" value="#MinCredit#">
		<cfif IsDefined("Credit")>
			<input type="hidden" name="Credit" value="#Credit#">
		<cfelse>
			<input type="hidden" name="Credit" value="0">
		</cfif>
		<cfif IsDefined("CheckD")>
			<input type="hidden" name="CheckD" value="#CheckD#">
		<cfelse>
			<input type="hidden" name="CheckD" value="0">
		</cfif>
		<cfif IsDefined("Postal")>
			<input type="hidden" name="Postal" value="#Postal#">
		<cfelse>
			<input type="hidden" name="Postal" value="0">
		</cfif>
		<cfif IsDefined("GroupSubs")>
			<input type="hidden" name="GroupSubs" value="#GroupSubs#">
		<cfelse>
			<input type="hidden" name="GroupSubs" value="0">
		</cfif>
		<input type="hidden" name="DomainID" value="#DomainID#">
		<input type="hidden" name="PlanID" value="#PlanID#">
		<input type="hidden" name="POPID" value="#POPID#">
		<input type="hidden" name="SalesPID" value="#SalesPID#">
	</cfoutput>
</table>
</form>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
     
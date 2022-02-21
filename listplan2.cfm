<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page is for adding/ editing plans.  
It calls the correct page to match to the selected tab.
--->
<!---	4.0.1 02/06/01 Split Staff Tab to Staff View and Staff Signup
		4.0.0 07/02/99 
		3.2.0 09/08/98 Moved IPAD auth to the Integration Tab
		3.1.1 08/10/98 Added tab 6 for POPs
    	3.1.0 07/15/98 --->
<!--- listplan2.cfm --->
<cfset securepage="listplan.cfm">
<cfinclude template="security.cfm">
<cfif IsDefined("EditID")>
	<cfparam name="PlanID" default="#EditID#">
</cfif>
<cfinclude template="listplan3.cfm">
<cfparam name="PlanID" default="0">
<cfparam name="tab" default="1">
<cfif tab Is 1>
	<cfset HowWide = 4>
	<cfquery name="EMailLetters" datasource="#pds#">
		SELECT IntID, IntDesc 
		FROM Integration 
		WHERE Action = 'Letter' 
	</cfquery>
	<cfquery name="AllPlans" datasource="#pds#">
		SELECT P.PlanDesc, P.PlanID 
		FROM Plans P, PlanAdm A 
		WHERE P.PlanID = A.PlanID 
		AND A.AdminID = #MyAdminID# 
		AND P.PlanID <> #PlanID#
		ORDER BY PlanDesc
	</cfquery>
<cfelseif tab Is 2>
	<cfset HowWide = 4>
	<cfquery name="EMailLetters" datasource="#pds#">
		SELECT IntID, IntDesc 
		FROM Integration 
		WHERE Action = 'Letter' 
	</cfquery>
	<cfquery name="AWTypes" datasource="#pds#">
		SELECT C.SortOrder, C.CardTypeID, C.CardType, 1 as Sel 
		FROM CreditCardTypes C, PlanCCTypes P 
		WHERE C.CardTypeID = P.CardTypeID 
		AND P.PlanID=#PlanID# 
		AND C.UseAW=1 
		AND P.WizardType = 'AW' 
		AND C.ActiveYN=1 
		UNION 
		SELECT C.SortOrder, C.CardTypeID, C.CardType, 0 as Sel 
		FROM CreditCardTypes C 
		WHERE CardTypeID Not In 
				(SELECT C.CardTypeID 
				 FROM CreditCardTypes C, PlanCCTypes P 
				 WHERE C.CardTypeID = P.CardTypeID 
				 AND P.PlanID=#PlanID# 
				 AND C.UseAW=1 
				 AND P.WizardType = 'AW' 
				 AND C.ActiveYN=1) 
		AND C.ActiveYN = 1 
		AND C.UseAW = 1 
		ORDER BY C.SortOrder, C.CardType 
	</cfquery>
	<cfquery name="OSTypes" datasource="#pds#">
		SELECT C.SortOrder, C.CardTypeID, C.CardType, 1 as Sel 
		FROM CreditCardTypes C, PlanCCTypes P 
		WHERE C.CardTypeID = P.CardTypeID 
		AND P.PlanID=#PlanID# 
		AND C.UseOS=1 
		AND P.WizardType = 'OS' 
		AND C.ActiveYN=1 
		UNION 
		SELECT C.SortOrder, C.CardTypeID, C.CardType, 0 as Sel 
		FROM CreditCardTypes C 
		WHERE CardTypeID Not In 
				(SELECT C.CardTypeID 
				 FROM CreditCardTypes C, PlanCCTypes P 
				 WHERE C.CardTypeID = P.CardTypeID 
				 AND P.PlanID=#PlanID# 
				 AND C.UseOS=1 
				 AND P.WizardType = 'OS'
				 AND C.ActiveYN=1) 
		AND C.ActiveYN = 1 
		AND C.UseOS = 1 
		ORDER BY C.SortOrder, C.CardType 
	</cfquery>
<cfelseif tab Is 3>
	<cfset HowWide = 4>
	<cfparam name="tbacnttypes" default="">
	<cfparam name="acnttypesfd" default="">
	<cfparam name="acnttype" default="">
	<cfquery name="EMailLetters" datasource="#pds#">
		SELECT IntID, IntDesc 
		FROM Integration 
		WHERE Action = 'Letter' 
	</cfquery>
	<cfinclude template="cfauthvalues.cfm">
	<cfif (tbacnttypes is not "") AND (acnttypesfd is not "") 
	 AND (authodbc is not "")>
	 	<cftry>
			<cfquery name="gettypes" datasource="#authodbc#">
				SELECT #acnttypesfd# as AccountType1
				FROM #tbacnttypes# 
				ORDER BY #acnttypesfd#
			</cfquery>
			<cfcatch type="Database">
				<cfset tbacnttypes = "">
				<cfset acnttypesfd = "">
				<cfset authodbc = "">
			</cfcatch>
		</cftry>
	</cfif>
	<cfquery name="SelDomains" datasource="#pds#">
		SELECT D.DomainID 
		FROM Domains D, DomPlans P 
		WHERE D.DomainID = P.DomainID 
		AND P.PlanID = #PlanID# 
		ORDER BY DomainName 
	</cfquery>
	<cfquery name="SelADomains" datasource="#pds#">
		SELECT D.DomainID 
		FROM Domains D, DomAPlans P 
		WHERE D.DomainID = P.DomainID 
		AND P.PlanID = #PlanID# 
		ORDER BY DomainName 
	</cfquery>
	<cfquery name="SelFDomains" datasource="#pds#">
		SELECT D.DomainID 
		FROM Domains D, DomFPlans P 
		WHERE D.DomainID = P.DomainID 
		AND P.PlanID = #PlanID# 
		ORDER BY DomainName 
	</cfquery>
	<cfquery name="DefFTP" datasource="#pds#">
		SELECT FTPServer, DomainName 
		FROM Domains 
		WHERE DomainID In 
				(SELECT D.DomainID 
				 FROM Domains D, DomFPlans P 
				 WHERE D.DomainID = P.DomainID 
				 AND P.PlanID = #PlanID#) 
		AND FTPServer Is Not Null 
		ORDER BY DomainName
	</cfquery>
	<cfquery name="DefAuth" datasource="#pds#">
		SELECT AuthServer, DomainName 
		FROM Domains 
		WHERE DomainID In 
				(SELECT D.DomainID 
				 FROM Domains D, DomAPlans P 
				 WHERE D.DomainID = P.DomainID 
				 AND P.PlanID = #PlanID#) 
		AND AuthServer Is Not Null 
		ORDER BY DomainName
	</cfquery>
	<cfquery name="DefEMail" datasource="#pds#">
		SELECT POP3Server, DomainName 
		FROM Domains 
		WHERE DomainID In 
				(SELECT D.DomainID 
				 FROM Domains D, DomPlans P 
				 WHERE D.DomainID = P.DomainID 
				 AND P.PlanID = #PlanID#) 
		AND POP3Server Is Not Null 
		ORDER BY DomainName, POP3Server
	</cfquery>
	<cfquery name="AllOthPlans" datasource="#pds#">
		SELECT PlanID, PlanDesc 
		FROM Plans 
		WHERE PlanID <> #PlanID# 
		ORDER BY PlanDesc 
	</cfquery>
<cfelseif tab Is 4>
	<cfquery name="GetLocale" datasource="#pds#">
		SELECT Value1 
		FROM Setup 
		WHERE VarName = 'Locale'
	</cfquery>
	<cfset Locale = GetLocale.Value1>
	<cfset HowWide = 9>
	<cfquery name="getinfo" datasource="#pds#">
		SELECT * 
		FROM Spans 
		WHERE PlanID = #planid# 
		ORDER BY SpanStart 
	</cfquery>
	<cfif IsDefined("addnew.x")>
		<cfset HowWide = 7>
		<cfhtmlhead text="
<script language='javascript'>
<!--
function checkit()
  {
   var pos1 = document.spanchk.ss1.options[document.spanchk.ss1.selectedIndex].value
   var pos2 = document.spanchk.se1.options[document.spanchk.se1.selectedIndex].value
   if (pos1 > pos2)
   {
   document.spanchk.se1.options[96].selected = true
   return alert ('The end time can not be earlier than the begin time.')
   }
  }
function checkit2()
  {
   var pos1 = document.spanchk3.ss1.options[document.spanchk3.ss1.selectedIndex].value
   var pos2 = document.spanchk3.se1.options[document.spanchk3.se1.selectedIndex].value
   if (pos1 > pos2)
   {
   document.spanchk3.se1.options[96].selected = true
   return alert ('The end time can not be earlier than the begin time.')
   }
  }
// -- End Hiding Here -->  
</script>
">
	<cfelseif IsDefined("EditOne")>
		<cfset HowWide = 7>
		<cfquery name="OneSpan" datasource="#pds#">
			SELECT * 
			FROM Spans 
			WHERE SpanID = #EditOne#
		</cfquery>	
		<cfquery name="getinfo" datasource="#pds#">
			SELECT * 
			FROM Spans 
			WHERE PlanID = #PlanID# 
			AND SpanID <> #EditOne# 
			ORDER BY SpanStart 
		</cfquery>		
	<cfelse>
		<cfhtmlhead text="
<script language='javascript'>
<!--
function SetValues(carry1,carry2)
	{
	 var var1 = document.EditInfo.LoopCount.value
	 var var9 = 0
	 if (var1 == 1)
	 	{
		 var var2 = document.EditInfo.DelSelected.checked
		 var var3 = document.EditInfo.DelSelected.value
		 if (var2 == 1)
		 	{
			 var var9 = var9 + ',' + var3
			}
		 document.PickDelete.DelThese.value = var9
		 return
		}
	 for (count = 0; count < var1; count++)
	 	{
		 var var2 = document.EditInfo.DelSelected[count].checked
		 var var3 = document.EditInfo.DelSelected[count].value
		 if (var2 == 1)
		 	{
			 var var9 = var9 + ',' + var3
			}		 
		}
	 document.PickDelete.DelThese.value = var9
	}  
// -- End Hiding Here -->  
</script>
">
	</cfif>
<cfelseif tab Is 5>
	<cfset HowWide = 3>
	<cfquery name="GetWhoHas" datasource="#pds#">
		SELECT U.FirstName, U.LastName, A.AdminID 
		FROM PlanAdm P, Accounts U, Admin A 
		WHERE P.AdminID = A.AdminID 
		AND U.AccountID = A.AccountID 
		AND P.PlanID = #planid# 
		Order By U.LastName, U.FirstName 
	</cfquery>
	<cfquery name="GetWhoWants" datasource="#pds#">
		SELECT U.FirstName, U.LastName, A.AdminID 
		FROM Accounts U, Admin A 
		WHERE U.AccountID = A.AccountID 
		AND A.AdminID Not In 
				(SELECT A.AdminID 
				 FROM PlanAdm P, Accounts U, Admin A 
				 WHERE P.AdminID = A.AdminID 
				 AND U.AccountID = A.AccountID 
				 AND P.PlanID = #planid#)
		Order By U.LastName, U.FirstName 
	</cfquery>
<cfelseif tab Is 6>
	<cfset HowWide = 3>
	<cfquery name="GetWhoHas" datasource="#pds#">
		SELECT P.PopName, P.POPID 
		FROM POPPlans L, POPs P 
		WHERE L.POPID=P.POPID 
		AND L.PlanID = #PlanID# 
		Order By P.POPName
	</cfquery>
	<cfquery name="GetWhoWants" datasource="#pds#">
		SELECT P.PopName, P.POPID 
		FROM POPs P 
		WHERE P.POPID Not In 
			(SELECT P.POPID 
			 FROM POPPlans L, POPs P 
			 WHERE L.POPID=P.POPID 
			 AND L.PlanID = #PlanID# )
		Order By POPName
	</cfquery>
<cfelseif tab Is 7>
	<cfset HowWide = 3>
	<cfquery name="GetSelScripts" datasource="#pds#">
		SELECT I.IntID, I.IntDesc 
		FROM Integration I, IntPlans P 
		WHERE I.IntID = P.IntID 
		AND P.PlanID = #PlanID# 
		AND I.Action <> 'Letter'
		ORDER BY IntDesc
	</cfquery>
	<cfquery name="AllScripts" datasource="#pds#">
		SELECT I.IntID, I.IntDesc 
		FROM Integration I 
		WHERE I.Action <> 'Letter'
		AND IntID Not In 
				(SELECT I.IntID 
				 FROM Integration I, IntPlans P 
				 WHERE I.IntID = P.IntID 
				 AND I.Action <> 'Letter'
				 AND P.PlanID = #PlanID#) 
		ORDER BY IntDesc 
	</cfquery>
<cfelseif tab Is 8>
	<cfset HowWide = 3>
	<cfquery name="GetSelDomains" datasource="#pds#">
		SELECT D.DomainID, D.DomainName 
		FROM Domains D, DomPlans P 
		WHERE D.DomainID = P.DomainID 
		AND P.PlanID = #PlanID# 
		ORDER BY DomainName
	</cfquery>
	<cfquery name="AllDomains" datasource="#pds#">
		SELECT D.DomainID, D.DomainName 
		FROM Domains D 
		WHERE DomainID Not In 
				(SELECT D.DomainID 
				 FROM Domains D, DomPlans P 
				 WHERE D.DomainID = P.DomainID 
				 AND P.PlanID = #PlanID#) 
		ORDER BY DomainName 
	</cfquery>
	<cfquery name="GetSelADomains" datasource="#pds#">
		SELECT D.DomainID, D.DomainName 
		FROM Domains D, DomAPlans P 
		WHERE D.DomainID = P.DomainID 
		AND P.PlanID = #PlanID# 
		ORDER BY DomainName
	</cfquery>
	<cfquery name="AllADomains" datasource="#pds#">
		SELECT D.DomainID, D.DomainName 
		FROM Domains D 
		WHERE DomainID Not In 
				(SELECT D.DomainID 
				 FROM Domains D, DomAPlans P 
				 WHERE D.DomainID = P.DomainID 
				 AND P.PlanID = #PlanID#) 
		ORDER BY DomainName 
	</cfquery>
	<cfquery name="GetSelFDomains" datasource="#pds#">
		SELECT D.DomainID, D.DomainName 
		FROM Domains D, DomFPlans P 
		WHERE D.DomainID = P.DomainID 
		AND P.PlanID = #PlanID# 
		ORDER BY DomainName
	</cfquery>
	<cfquery name="AllFDomains" datasource="#pds#">
		SELECT D.DomainID, D.DomainName 
		FROM Domains D 
		WHERE DomainID Not In 
				(SELECT D.DomainID 
				 FROM Domains D, DomFPlans P 
				 WHERE D.DomainID = P.DomainID 
				 AND P.PlanID = #PlanID#) 
		ORDER BY DomainName 
	</cfquery>
<cfelseif tab Is 9>
	<cfset HowWide = 3>
	<cfquery name="GetWhoHas" datasource="#pds#">
		SELECT U.FirstName, U.LastName, A.AdminID 
		FROM PlanSignAdm P, Accounts U, Admin A 
		WHERE P.AdminID = A.AdminID 
		AND U.AccountID = A.AccountID 
		AND P.PlanID = #PlanID# 
		Order By U.LastName, U.FirstName 
	</cfquery>
	<cfquery name="GetWhoWants" datasource="#pds#">
		SELECT U.FirstName, U.LastName, A.AdminID 
		FROM Accounts U, Admin A 
		WHERE U.AccountID = A.AccountID 
		AND A.AdminID Not In 
				(SELECT A.AdminID 
				 FROM PlanSignAdm P, Accounts U, Admin A 
				 WHERE P.AdminID = A.AdminID 
				 AND U.AccountID = A.AccountID 
				 AND P.PlanID = #PlanID#)
		Order By U.LastName, U.FirstName 
	</cfquery>
</cfif>
<cfquery name="OnePlan" datasource="#pds#">
	SELECT * 
	FROM Plans 
	Where planid = #PlanID#
</cfquery>
<cfquery name="HowMany" datasource="#pds#">
	SELECT Count(AccountID) as Num1 
	FROM AccntPlans
	WHERE PlanID = #PlanID# 
</cfquery>
<cfsetting enablecfoutputonly="no">
<HTML>
<HEAD>
<TITLE>Plan Setup</TITLE>
<cfinclude template="coolsheet.cfm">
</HEAD>
<cfoutput><BODY #colorset#></cfoutput>
<cfinclude template="header.cfm">
<form method="post" action="listplan.cfm">
	<cfoutput>
		<input type="hidden" name="page" value="#page#">
		<input type="hidden" name="obid" value="#obid#">
		<input type="hidden" name="obdir" value="#obdir#">		
	</cfoutput>
<input type="image" src="images/return.gif" name="return" border="0">
</form>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="#HowWide#" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttfont Is Not "NA">face="#perfontname#"</cfif> color="#ttfont#">#OnePlan.PlanDesc# Setup</font></th>
	</tr>
	<tr>
		<th colspan="#HowWide#">
			<table border="1">
				<form method="post" action="listplan2.cfm">
					<input type="hidden" name="page" value="#page#">
					<input type="hidden" name="obid" value="#obid#">
					<input type="hidden" name="obdir" value="#obdir#">
					<input type="hidden" name="PlanID" value="#PlanID#">
					<tr>
						<th bgcolor=<cfif tab is 1>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input type="radio" <cfif tab Is 1>checked</cfif> name="tab" value="1" onclick="submit()" id="tab1"><label for="tab1">General</label></th>
						<cfif PlanID GT 0>
							<th bgcolor=<cfif tab is 2>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input type="radio" <cfif tab Is 2>checked</cfif> name="tab" value="2" onclick="submit()" id="tab2"><label for="tab2">Financial</label></th>
						<cfelse>
							<th bgcolor="#thclr#">Financial</th>
						</cfif>
						<cfif PlanID GT 0>
							<th bgcolor=<cfif tab is 8>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input type="radio" <cfif tab Is 8>checked</cfif> name="tab" value="8" onclick="submit()" id="tab8"><label for="tab8">Domains</label></th>
						<cfelse>
							<th bgcolor="#thclr#">Domains</th>
						</cfif>
						<cfif PlanID GT 0>
							<th bgcolor=<cfif tab is 3>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input type="radio" <cfif tab Is 3>checked</cfif> name="tab" value="3" onclick="submit()" id="tab3"><label for="tab3">Integration</label></th>
						<cfelse>
							<th bgcolor="#thclr#">Integration</th>
						</cfif>
						<cfif PlanID GT 0>
							<th bgcolor=<cfif tab is 4>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input type="radio" <cfif tab Is 4>checked</cfif> name="tab" value="4" onclick="submit()" id="tab4"><label for="tab4">Metered</label></th>
						<cfelse>
							<th bgcolor="#thclr#">Metered</th>
						</cfif>
						<cfif PlanID GT 0>
							<th bgcolor=<cfif tab is 9>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input type="radio" <cfif tab Is 9>checked</cfif> name="tab" value="9" onclick="submit()" id="tab9"><label for="tab9">Staff Signup</label></th>
						<cfelse>
							<th bgcolor="#thclr#">Staff Signup</th>
						</cfif>
						<cfif PlanID GT 0>
							<th bgcolor=<cfif tab is 5>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input type="radio" <cfif tab Is 5>checked</cfif> name="tab" value="5" onclick="submit()" id="tab5"><label for="tab5">Staff View</label></th>
						<cfelse>
							<th bgcolor="#thclr#">Staff View</th>
						</cfif>
						<cfif PlanID GT 0>
							<th bgcolor=<cfif tab is 6>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input type="radio" <cfif tab Is 6>checked</cfif> name="tab" value="6" onclick="submit()" id="tab6"><label for="tab6">POP</label></th>
						<cfelse>
							<th bgcolor="#thclr#">POP</th>
						</cfif>
						<cfif PlanID GT 0>
							<th bgcolor=<cfif tab is 7>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input type="radio" <cfif tab Is 7>checked</cfif> name="tab" value="7" onclick="submit()" id="tab7"><label for="tab7">Scripts</label></th>
						<cfelse>
							<th bgcolor="#thclr#">Scripts</th>
						</cfif>
					</tr>
				</form>
			</table>
		</th>
	</tr>
	<tr>
		<th colspan="#HowWide#" bgcolor="#thclr#">#HowMany.Num1# Customers on this plan</th>
	</tr>
</cfoutput>
<cfif tab Is 1>
	<cfinclude template="plantab1.cfm">
<cfelseif tab Is 2>
	<cfinclude template="plantab2.cfm">
<cfelseif tab Is 3>
	<cfinclude template="plantab3.cfm">
<cfelseif tab Is 4>
	<cfinclude template="plantab4.cfm">
<cfelseif tab Is 5>
	<cfinclude template="plantab5.cfm">
<cfelseif tab Is 6>
	<cfinclude template="plantab6.cfm">
<cfelseif tab Is 7>
	<cfinclude template="plantab7.cfm">
<cfelseif tab Is 8>
	<cfinclude template="plantab8.cfm">
<cfelseif tab Is 9>
	<cfinclude template="plantab9.cfm">
</cfif>
</table>
</center>
<cfinclude template="footer.cfm">
</BODY>
</HTML>








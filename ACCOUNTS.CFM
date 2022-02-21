<cfsetting enablecfoutputonly="Yes">

<!--- Version 4.0.0 --->
<!--- This page allows managing email addresses. --->
<!--- 4.0.1 01/25/01 Added support for the IPAD EMail directory structure.
		4.0.0 10/02/00 --->
<!--- accounts.cfm --->
<cfif IsDefined("DeleteEMailAlias")>
	<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
		<cfhttpparam type="FORMFIELD" name="ResultType" value="Script">
		<cfhttpparam type="FORMFIELD" name="MCIntType" value="5">
		<cfhttpparam type="FORMFIELD" name="MCScrAction" value="Delete">
		<cfhttpparam type="FORMFIELD" name="MCEMailID" value="#EMailID#">
		<cfhttpparam type="FORMFIELD" name="MCAccountID" value="#Cookie.Session#">
		<cfhttpparam type="FORMFIELD" name="MCPageLocation" value="accounts.cfm">
	</cfhttp>
	
	<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
		<cfhttpparam name="TheQuery" type="FORMFIELD" value="DELETE FROM AccountsEMail 
		WHERE EMailID = #EMailID# ">
	</cfhttp>
</cfif>
<cfif IsDefined("DeleteEMailAddr")>
	<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
		<cfhttpparam type="FORMFIELD" name="ResultType" value="Script">
		<cfhttpparam type="FORMFIELD" name="MCIntType" value="4">
		<cfhttpparam type="FORMFIELD" name="MCScrAction" value="Delete">
		<cfhttpparam type="FORMFIELD" name="MCEMailID" value="#EMailID#">
		<cfhttpparam type="FORMFIELD" name="MCAccountID" value="#Cookie.Session#">
		<cfhttpparam type="FORMFIELD" name="MCPageLocation" value="accounts.cfm">
	</cfhttp>
	
	<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
		<cfhttpparam name="TheQuery" type="FORMFIELD" value="DELETE FROM AccountsEMail 
		WHERE EMailID = #EMailID# ">
	</cfhttp>
</cfif>
<cfif IsDefined("AddTheEMail")>
	<!--- Get the Custom EMail attributes --->
	<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
		<cfhttpparam name="TheQuery" type="FORMFIELD" value="SELECT MailBox, OSMailLower, MailBoxLimit 
		FROM Plans 
		WHERE PlanID = 
			(SELECT PlanID 
			 FROM AccntPlans 
			 WHERE AccntPlanID = #AccntPlanID#) ">
	</cfhttp>
	<cfset TheResult = cfhttp.FileContent>
	<cfwddx action="WDDX2CFML" input="#TheResult#" output="PlanSettings">
	
	<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
		<cfhttpparam name="TheQuery" type="FORMFIELD" value="SELECT DomainName, POP3Server, CEMailID 
		FROM Domains 
		WHERE DomainID = #DomainID# ">
	</cfhttp>
	<cfset TheResult = cfhttp.FileContent>
	<cfwddx action="WDDX2CFML" input="#TheResult#" output="DomainSettings">

	<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
		<cfhttpparam name="TheQuery" type="FORMFIELD" value="SELECT FirstName, LastName 
		FROM Accounts 
		WHERE AccountID = #Cookie.Session# ">
	</cfhttp>
	<cfset TheResult = cfhttp.FileContent>
	<cfwddx action="WDDX2CFML" input="#TheResult#" output="DefaultName">
	<cfparam name="FName" default="#DefaultName.FirstName#">
	<cfparam name="LName" default="#DefaultName.LastName#">
	
	<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
		<cfhttpparam name="TheQuery" type="FORMFIELD" value="SELECT * 
		FROM AccountsEMail 
		WHERE AccountID = #Cookie.Session# ">
	</cfhttp>
	<cfset TheResult = cfhttp.FileContent>
	<cfwddx action="WDDX2CFML" input="#TheResult#" output="PrimaryCheck">
	<cfif PrimaryCheck.RecordCount IS 0>
		<cfset Primary1 = 1>
	<cfelse>	
		<cfset Primary1 = 0>
	</cfif>
	<!--- Insert AccountsEMail --->
	<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
		<cfhttpparam name="TheQuery" type="FORMFIELD" value="INSERT INTO AccountsEMail 
		(AccountID, AccntPlanID, DomainID, Login, EMail, 
		 EPass, FName, LName, Alias, PrEMail, ContactYN, SMTPUserName, DomainName, 
		 FullName, EMailServer, MailCMD, MailBoxPath, MailBoxLimit, CEMailID)
		VALUES
		(#Cookie.Session#, #AccntPlanID#, #DomainID#, '#UserName#', '#UserName#@#DomainSettings.DomainName#', 
		 '#Password#', '#FName#', '#LName#', 0, #Primary1#, 0, '#UserName#', '#DomainSettings.DomainName#', 
		 '#FName# #LName#', '#DomainSettings.POP3Server#', 'POP3', '#PlanSettings.MailBox#', '#PlanSettings.MailBoxLimit#',
		 #DomainSettings.CEMailID#) ">
		 <cfhttpparam name="TheQuery2" type="FORMFIELD" value="SELECT Max(EMailID) as NewID 
		 FROM AccountsEMail ">
	</cfhttp>
	<cfset TheResult = cfhttp.FileContent>
	<cfwddx action="WDDX2CFML" input="#TheResult#" output="NewerID">

	<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
		<cfhttpparam name="TheQuery" type="FORMFIELD" value="UPDATE AccountsEMail SET 
		UniqueIdentifier = #NewerID.NewID# 
		WHERE EMailID = #NewerID.NewID# ">
	</cfhttp>
	
	<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
		<cfhttpparam name="TheQuery" type="FORMFIELD" value="SELECT ActiveYN 
				FROM CustomEMailSetup 
				WHERE CEMailID = #DomainSettings.CEMailID# 
				AND BOBName = 'MailCMD' ">
		<cfset TheResult = cfhttp.FileContent>
	<cfwddx action="WDDX2CFML" input="#TheResult#" output="CheckIPAD">
	<cfif CheckIPAD.ActiveYN Is "1">
		<cfif Len(NewerID.EMailID) GTE 2>
			<cfset TheDir = Right(NewerID.EMailID,2)>
		<cfelse>
			<cfset TheDir = "0" & NewerID.EMailID>
		</cfif>
		<cfset IPADMailBoxPath = GetPlanDefs.MailBox & TheDir & "\" & NewerID.EMailID>
		<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
			<cfhttpparam name="TheQuery" type="FORMFIELD" value="UPDATE AccountsEMail SET 
					MailBoxPath = '#IPADMailBoxPath#' 
					WHERE EMailID = #NewerID.EMailID# ">
		</cfhttp>
	</cfif>
	
	<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
		<cfhttpparam type="FORMFIELD" name="ResultType" value="Script">
		<cfhttpparam type="FORMFIELD" name="MCIntType" value="4">
		<cfhttpparam type="FORMFIELD" name="MCScrAction" value="Create">
		<cfhttpparam type="FORMFIELD" name="MCEMailID" value="#NewerID.NewID#">
		<cfhttpparam type="FORMFIELD" name="MCAccountID" value="#Cookie.Session#">
		<cfhttpparam type="FORMFIELD" name="MCPageLocation" value="accounts.cfm">
	</cfhttp>
</cfif>

<cfif IsDefined("AddContEM")>
	<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
		<cfhttpparam name="TheQuery" type="FORMFIELD" value="SELECT * 
		FROM Accounts 
		WHERE AccountID = #Cookie.Session# ">
	</cfhttp>
	<cfset TheResult = cfhttp.FileContent>
	<cfwddx action="WDDX2CFML" input="#TheResult#" output="WhoInfo">

	<cfset EMailToCheck = Trim(ContactEMail)>
	<cfset Pos1 = FindNoCase("@",EMailToCheck)>
	<cfif Pos1 GT 0>
		<cfset EMFirst = Left(EMailToCheck,Pos1)>
		<cfset Len1 = Len(EMailToCheck) - Pos1>
		<cfset EMSecond = Right(EMailToCheck,Len1)>
		<cfset EMFirst = ReplaceList(EMFirst,"@","")>
		<cfset EMSecond = ReplaceList(EMSecond,"@","")>
	<cfelse>
		<cfset EMFirst = "">
		<cfset EMSecond = "">
	</cfif>
	<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
		<cfhttpparam name="TheQuery" type="FORMFIELD" value="INSERT INTO AccountsEMail 
			(AccountID, EMail, FName, LName, Alias, PrEMail, ContactYN, 
			 FullName, AccntPlanID, DomainName, SMTPUserName, Login, CEMailID) 
			VALUES 
			(#Cookie.Session#, '#ContactEMail#', '#WhoInfo.FirstName#', '#WhoInfo.LastName#', 0, 0, 1, 
			 '#WhoInfo.FirstName# #WhoInfo.LastName#', #AccntPlanID#,
			 <cfif Trim(EMSecond) Is "">Null<cfelse>'#EMSecond#'</cfif>, 
			 <cfif Trim(EMFirst) Is "">Null<cfelse>'#EMFirst#'</cfif>, 
			 <cfif Trim(EMFirst) Is "">Null<cfelse>'#EMFirst#'</cfif>, 0 )">
	</cfhttp>
</cfif>
<cfif IsDefined("DelContEMail")>
	<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
		<cfhttpparam name="TheQuery" type="FORMFIELD" value="DELETE FROM AccountsEMail 
			WHERE EMailID = #EMailID# ">
	</cfhttp>
</cfif>

<cfif IsDefined("MkPrim")>
	<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
		<cfhttpparam name="TheQuery" type="FORMFIELD" value="UPDATE AccountsEMail SET 
		PrEMail = 0 
		WHERE AccountID = 
			(SELECT AccountID 
			 FROM AccountsEMail 
			 WHERE EMailID = #EMailID# )">
	</cfhttp>
	<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
		<cfhttpparam name="TheQuery" type="FORMFIELD" value="UPDATE AccountsEMail SET 
		PrEMail = 1 
		WHERE EMailID = #EMailID# ">
	</cfhttp>
</cfif>

<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
	<cfhttpparam name="TheQuery" type="FORMFIELD" value="SELECT P.PlanDesc, P.FreeEmails, A.EMailAccounts, A.AccntPlanID 
FROM AccntPlans A, Plans P 
WHERE A.PlanID = P.PlanID 
AND A.AccountID = #cookie.session# 
ORDER BY P.PlanDesc">
</cfhttp>
<cfset TheResult = cfhttp.FileContent>
<cfwddx action="WDDX2CFML" input="#TheResult#" output="AllPlans">

<cfset HowWide = 4>
<cfset HowWide2 = HowWide - 1>

<cfsetting enablecfoutputonly="No">
<html>
<head>
<title>EMail Management</title>
</head>
<cfoutput>
<body #PageColors#>
</cfoutput>
<cfinclude template="header.cfm">
<center>
	<cfoutput>
		<table border="#TblBorder#">
			<tr>
				<th colspan="#HowWide#" bgcolor="#TblTitleColor#"><font color="#TblTitleText#" size="#TblTitleSize#">EMail Management</font></th>
			</tr>
	</cfoutput>
			<cfloop query="AllPlans">
				<tr>
					<cfoutput><td colspan="#HowWide#" bgcolor="#thclr#">#PlanDesc#</td></cfoutput>
				</tr>
				<cfsetting enablecfoutputonly="Yes">
					<cfset AccntPlanID = AccntPlanID>
					<cfhttp url="#gBillURL#/maintconverter.cfm" method="POST" resolveurl="false">
						<cfhttpparam name="TheQuery" type="FORMFIELD" value="SELECT E.PrEMail, E.AccountID, E.EMailID AS PrEMailID, E.EMail, E.ContactYN, 
	                E.FullName, E.Alias, E.DomainName, E.Login, E.FullName, 
						 A.EMailID, A.EMail AS EMailAlias 
						 FROM AccountsEMail A RIGHT JOIN AccountsEMail E 
						 ON A.AliasTo = E.emailid 
						 WHERE E.AccntPlanID = #AccntPlanID# 
						 AND E.Alias = 0 
						 AND (A.Alias = 1 OR A.Alias Is Null) 
						 ORDER BY E.PrEMail DESC , E.EMail, A.EMail ">
					</cfhttp>
					<cfset TheResult = cfhttp.FileContent>
					<cfwddx action="WDDX2CFML" input="#TheResult#" output="AllEmails">
				<cfsetting enablecfoutputonly="No">
				<cfoutput query="AllEmails" group="PrEMailID">
					<tr>
							<cfif PrEMail Is "1">
								<td bgcolor="#tdclr#">Primary</td>
							<cfelse>
								<form method="post" action="accounts.cfm">
									<td bgcolor="#tdclr#"><input type="Submit" name="MkPrim" value="Make Primary"></td>
									<input type="Hidden" name="EMailID" value="#PrEMailID#">
								</form>
							</cfif>
							<td bgcolor="#tbclr#">#EMail#</td>
							<cfif ContactYN Is "1">
								<td bgcolor="#tbclr#">Contact</td>
							<cfelse>
								<td bgcolor="#tbclr#">EMail</td>
							</cfif>
							<cfif PrEMail Is "1">
								<td bgcolor="#tbclr#">&nbsp;</td>
							<cfelseif Alias Is "1">
								<td bgcolor="#tbclr#">&nbsp;</td>
							<cfelse>
								<form method="post" action="accntdel.cfm">
									<td bgcolor="#tdclr#"><input type="Submit" name="AddDel" value="Delete"></td>
									<input type="Hidden" name="AccntPlanID" value="#AccntPlanID#">	
									<input type="Hidden" name="EMailID" value="#PrEMailID#">
								</form>
							</cfif>
					</tr>
					<cfif EMailAlias IS NOT "">
						<cfoutput>
							<tr bgcolor="#tbclr#">
								<td>&nbsp;</td>
								<td>#EMailAlias#</td>
								<td>Alias</td>
								<form method="post" action="aliasdel.cfm">
									<td bgcolor="#tdclr#"><input type="Submit" name="AddDel" value="Delete"></td>
									<input type="Hidden" name="AccntPlanID" value="#AccntPlanID#">	
									<input type="Hidden" name="EMailID" value="#EMailID#">
								</form>
							</tr>
						</cfoutput>
					</cfif>
				</cfoutput> 
				<tr>
					<cfoutput><td colspan="#HowWide2#">&nbsp;</td></cfoutput>
					<form method="post" action="accntadd.cfm">
						<cfoutput>
							<td align="right" bgcolor="#tdclr#"><input type="Submit" name="AddAcnt" value="Add"></td>
							<input type="Hidden" name="AccntPlanID" value="#AccntPlanID#">
						</cfoutput>
					</form>
				</tr>
			</cfloop>
		</table>
</center>
</body>
</html>
 
<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page is a list of all of the domains.
--->
<!---	4.0.2 01/31/01 Added columns for Auth and FTP accounts.  Modified the report to show by type.
		4.0.1 01/30/01 Made the report row wider to accomadate the new copy column.
		4.0.0 07/05/99
		3.2.0 09/08/98
		3.1.1 07/23/98 Aligned the buttons to be consistent with other pages
		3.1.0 07/15/98 --->
<!--- domains.cfm --->

<cfinclude template="security.cfm">
<cfif IsDefined("CopyFrom")>
	<cfquery name="GetFrom" datasource="#pds#">
		SELECT * 
		FROM Domains 
		WHERE DomainID = #CopyFrom# 
	</cfquery>
	<cfset FieldList = GetFrom.ColumnList>
	<cfset Pos1 = ListFindNoCase(FieldList,"DomainID")>
	<cfset FieldList = ListDeleteAt(FieldList,Pos1)>
	<cfset Pos2 = ListFindNoCase(FieldList,"DomainName")>
	<cfset FieldList = ListDeleteAt(FieldList,Pos2)>
	<cfset Pos3 = ListFindNoCase(FieldList,"Primary1")>
	<cfset FieldList = ListDeleteAt(FieldList,Pos3)>
	<cftransaction>
		<cfquery name="MakeNew" datasource="#pds#">
			INSERT INTO Domains 
			(DomainName, Primary1, #FieldList#) 
			SELECT '#GetFrom.DomainName# Copy', 0, #FieldList# 
			FROM Domains 
			WHERE DomainID = #CopyFrom# 
		</cfquery>
		<cfquery name="NewID" datasource="#pds#">
			SELECT Max(DomainID) As MaxID 
			FROM Domains 
		</cfquery>
	</cftransaction>
	<cfset NewDomainID = NewID.MaxID>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="GetOldDom" datasource="#pds#">
			SELECT DomainName 
			FROM Domains 
			WHERE DomainID = #CopyFrom#
		</cfquery>
		<cfquery name="GetNewDom" datasource="#pds#">
			SELECT DomainName 
			FROM Domains 
			WHERE DomainID = #NewDomainID#
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'Domain','#StaffMemberName.FirstName# #StaffMemberName.LastName# copied #GetOldDom.DomainName# to #GetNewDom.DomainName#.')
		</cfquery>
	</cfif>
	<cfquery name="InsDomPlans" datasource="#pds#">
		INSERT INTO DomPlans 
		(DomainID, PlanID) 
		SELECT #NewDomainID#, PlanID
		FROM DomPlans 
		WHERE DomainID = #CopyFrom# 
	</cfquery>
	<cfquery name="InsDomPlans" datasource="#pds#">
		INSERT INTO DomAPlans 
		(DomainID, PlanID) 
		SELECT #NewDomainID#, PlanID
		FROM DomAPlans 
		WHERE DomainID = #CopyFrom# 
	</cfquery>
	<cfquery name="InsDomPlans" datasource="#pds#">
		INSERT INTO DomFPlans 
		(DomainID, PlanID) 
		SELECT #NewDomainID#, PlanID
		FROM DomFPlans 
		WHERE DomainID = #CopyFrom# 
	</cfquery>
	<cfquery name="InsAdmin" datasource="#pds#">
		INSERT INTO DomAdm 
		(DomainID, AdminID) 
		SELECT #NewDomainID#, AdminID 
		FROM DomAdm 
		WHERE DomainID = #CopyFrom# 
	</cfquery>
	<cfquery name="InsScripts" datasource="#pds#">
		INSERT INTO DomAccnt 
		(DomainID, AccountID) 
		SELECT #NewDomainID#, AccountID 
		FROM DomAccnt 
		WHERE DomainID = #CopyFrom# 
	</cfquery>
</cfif>
<cfif IsDefined("deletelist")>
	<cfquery name="DelData" datasource="#pds#">
		DELETE FROM GrpLists 
		WHERE ReportID = 2 
		AND AdminID = #MyAdminID# 
	</cfquery>
</cfif>
<cfif IsDefined("Prim")>
	<cfif SetDefault Is 1>
		<cfif Not IsDefined("NoBOBHist")>
			<cfquery name="GetOldDom" datasource="#pds#">
				SELECT DomainName 
				FROM Domains 
				WHERE Primary1 = 1 
			</cfquery>
		</cfif>
		<cfquery name="Reset" datasource="#pds#">
			UPDATE Domains SET 
			Primary1 = 0
		</cfquery>
		<cfquery name="SetNew" datasource="#pds#">
			UPDATE Domains SET 
			Primary1 = 1, ShowYN = 1, UseAddr = 1 
			WHERE DomainID = #Prim#
		</cfquery>
		<cfif Not IsDefined("NoBOBHist")>
			<cfquery name="GetDom" datasource="#pds#">
				SELECT DomainName 
				FROM Domains 
				WHERE Primary1 = 1 
			</cfquery>
			<cfquery name="BOBHist" datasource="#pds#">
				INSERT INTO BOBHist
				(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
				VALUES 
				(Null,0,#MyAdminID#, #Now()#,'Domain','#StaffMemberName.FirstName# #StaffMemberName.LastName# changed the default domain from #GetOldDom.DomainName# to #GetDom.DomainName#.')
			</cfquery>
		</cfif>
	</cfif>
</cfif>
<cfif (IsDefined("ListDomains.x")) AND (IsDefined("DomainID"))>
	<cfsetting enablecfoutputonly="no">
	<cfif DomainID Is Not "0">
		<cfquery name="CheckFirst" datasource="#pds#">
			SELECT ReportID 
			FROM GrpLists 
			WHERE ReportID = 2 
			AND AdminID = #MyAdminID# 
		</cfquery>
		<cfif CheckFirst.RecordCount GT 0>
			<cfquery name="DelData" datasource="#pds#">
				DELETE FROM GrpLists 
				WHERE ReportID = 2 
				AND AdminID = #MyAdminID# 
			</cfquery>
		</cfif>
		<cfquery name="List" datasource="#PDS#">
			INSERT INTO GrpLists 
			(LastName, FirstName, Login, City, AccountID, ReportHeader, 
			 ReportID, AdminID, ReportTitle, ReportTab, TabType, CreateDate) 
			SELECT E.LName, E.FName, E.Login, A.City, A.AccountID, 
			E.Domainname, 2, #MyAdminID#, 'List of customers by Domain', 'EMail', 2, #Now()# 
			FROM AccountsEMail E, Accounts A 
			WHERE A.AccountID = E.AccountID 
			AND E.ContactYN = 0 
			AND E.DomainID In (#DomainID#)
			UNION 
			SELECT A.LastName, A.FirstName, R.UserName, A.City, A.AccountID, 
			R.Domainname, 2, #MyAdminID#, 'List of customers by Domain', 'Auth', 2, #Now()# 
			FROM Accounts A, AccountsAuth R 
			WHERE A.AccountID = R.AccountID 
			AND R.DomainID In (#DomainID#) 
			UNION 
			SELECT A.LastName, A.FirstName, F.Username, A.City, A.AccountID, 
			F.Domainname, 2, #MyAdminID#, 'List of customers by Domain', 'FTP', 2, #Now()# 
			FROM Accounts A, AccountsFTP F 
			WHERE A.AccountID = F.AccountID 
			AND F.DomainID In (#DomainID#) 
		</cfquery>
		<cfquery name="GetEMails" datasource="#pds#">
			UPDATE GrpLists SET 
			EMail = E.Email 
			FROM AccountsEMail E, GrpLists G 
			WHERE G.AccountID = E.AccountID 
			AND E.PrEMail = 1 
			AND G.ReportID = 2  
			AND G.AdminID = #MyAdminID# 
		</cfquery>
	</cfif>
	<cfset ReturnPage = "domains.cfm">
	<cfset SendReportID = 2>
	<cfset SendLetterID = 2>
	<cfquery name="ClearEmailTable" datasource="#pds#">
		DELETE FROM EMailOutGoing 
		WHERE LetterID = 2 
		AND AdminID = #MyAdminID# 
	</cfquery>
	<cfset SendHeader = "Name,Login,City,Domain,E-Mail">
	<cfset SendFields = "Name,Login,City,ReportHeader,EMail">
	<cfinclude template="grplist.cfm">
	<cfsetting enablecfoutputonly="yes">
	<cfabort>
</cfif>
<cfif IsDefined("DelDomain.x") AND IsDefined("DelThese")>
	<cfloop index="LoopDomainID" list="#DelThese#">
		<cfif LoopDomainID GT 0>
			<cfquery name="CleanUp" datasource="#pds#">
				DELETE FROM DomAdm 
				WHERE DomainID = #LoopDomainID#
			</cfquery>
			<cfquery name="CleanUp" datasource="#pds#">
				DELETE FROM DomAccnt 
				WHERE DomainID = #LoopDomainID#
			</cfquery>
			<cfquery name="CleanUp" datasource="#pds#">
				DELETE FROM FilterDomains 
				WHERE DomainID = #LoopDomainID# 
			</cfquery>
			<cfquery name="CleanUp" datasource="#pds#">
				DELETE FROM DomPlans 
				WHERE DomainID = #LoopDomainID#
			</cfquery>
			<cfquery name="CleanUp" datasource="#pds#">
				DELETE FROM DomAPlans 
				WHERE DomainID = #LoopDomainID#
			</cfquery>
			<cfquery name="CleanUp" datasource="#pds#">
				DELETE FROM DomFPlans 
				WHERE DomainID = #LoopDomainID#
			</cfquery>
			<cfquery name="GetScripts" datasource="#pds#">
					SELECT I.IntID 
					FROM Integration I, IntScriptLoc S, IntLocations L 
					WHERE I.IntID = S.IntID 
					AND S.LocationID = L.LocationID 
					AND L.ActiveYN = 1 
					AND I.ActiveYN = 1 
					AND L.PageName = 'domains.cfm' 
					AND L.LocationAction = 'Delete' 
					AND I.TypeID = 
						(SELECT TypeID 
						 FROM IntTypes 
						 WHERE TypeStr = 'Domain') 
			</cfquery>
			<cfif GetScripts.RecordCount GT 0>
				<cfset LocScriptID = ValueList(GetScripts.IntID)>
				<cfset LocDomainID = LoopDomainID>
				<cfsetting enablecfoutputonly="no">
				<cfinclude template="runintegration.cfm">
				<cfsetting enablecfoutputonly="yes">
			</cfif>
			<cfif FileExists(ExpandPath("external#OSType#domainnamedel.cfm"))>
				<cfset SendID = LoopDomainID>
				<cfsetting enablecfoutputonly="no">
				<cfinclude template="external#OSType#domainnamedel.cfm">
				<cfsetting enablecfoutputonly="yes">
			</cfif>
			<!--- BOB History --->
			<cfif Not IsDefined("NoBOBHist")>
				<cfquery name="GetWhoName" datasource="#pds#">
					SELECT DomainName 
					FROM Domains 
					WHERE DomainID = #LoopDomainID#
				</cfquery>
				<cfquery name="BOBHist" datasource="#pds#">
					INSERT INTO BOBHist
					(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
					VALUES 
					(Null,0,#MyAdminID#, #Now()#,'Domain',
					'#StaffMemberName.FirstName# #StaffMemberName.LastName# deleted the domain: #GetWhoName.DomainName#.')
				</cfquery>
			</cfif>
			<cfquery name="del1" datasource="#pds#">
				DELETE FROM Domains 
				WHERE domainid = #LoopDomainID# 
			</cfquery>
		</cfif>	
	</cfloop>
</cfif>

<cfparam name="page" default="1">
<cfparam name="ordby" default="DomainName">
<cfparam name="orddir" default="asc">
<cfquery name="CheckReport" datasource="#pds#">
	SELECT AdminID 
	FROM GrpLists 
	WHERE ReportID = 2 
	AND AdminID = #MyAdminID# 
</cfquery>
<!---
	SELECT D.DomainName, D.Domainid, D.Primary1, D.PrivateYN, 
	Count(EMailID) as AID 
	FROM Domains D Left Join AccountsEMail E ON D.DomainID = E.DomainID 
	GROUP BY D.Domainname, D.Domainid, D.Primary1, D.PrivateYN 
--->
<cfquery name="AllDomains" datasource="#pds#">
	SELECT D.DomainName, D.Domainid, D.Primary1, D.PrivateYN, 
	(SELECT Count(EMailID) FROM AccountsEMail WHERE DomainID = D.DomainID AND ContactYN = 0) as EID,
	(SELECT Count(FTPID) FROM AccountsFTP WHERE DomainID = D.DomainID) as FID, 
	(SELECT Count(AuthID) FROM AccountsAuth WHERE DomainID = D.DomainID) as AID
	FROM Domains D 
	ORDER BY #OrdBy# #OrdDir#
</cfquery>
<cfif Page GT 0>
	<cfset MaxRows = mrow>
	<cfset Srow = (page * mrow) - (mrow - 1)>
<cfelse>
	<cfset Srow = 1>
	<cfset MaxRows = AllDomains.RecordCount>
</cfif>
<cfset PageNumber = Ceiling(AllDomains.RecordCount/mrow)>
<cfset HowWide = 10>
<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Domain Names</TITLE>
<cfinclude template="coolsheet.cfm">
<script language="javascript">
<!-- 
function MsgWindow()
	{
    window.open('processing.cfm','Processing','scrollbars=no,status=no,width=400,height=150,location=no,resizable=no');
	}
function GoEdit()
	{
	 document.EditInfo.action = 'domains2.cfm'
	 document.EditInfo.submit()
	}
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
// -->
</script>
<script language="javascript">
<!--  
function CopyPlan()
	{
    if (confirm ('Click Ok to confirm making a copy of this domain.'))
	 	document.EditInfo.submit()
	}
// -->
</script>
</head>
<cfoutput><body #colorset# onload="self.focus()"></cfoutput>
<cfinclude template="header.cfm">
<center>
<cfoutput>
	<table border="#tblwidth#">
		<tr>
			<th colspan="#HowWide#" bgcolor="#ttclr#"><font <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#" size="#ttsize#">Domain Names</font></th>
		</tr>
</cfoutput>
		<cfif mrow LT AllDomains.recordCount>
			<tr>
				<form method="post" action="domains.cfm">
					<cfoutput>
						<input type="hidden" name="orddir" value="#orddir#">
						<input type="hidden" name="ordby" value="#ordby#">
					</cfoutput>
					<td colspan="#HowWide#"><select name="page" onChange="submit()">
						<cfloop index="B5" from="1" to="#PageNumber#">
							<cfset ArrayPoint = (B5 * mrow) - (mrow -1)>
							<cfif ordby Is "DomainName">
								<cfset disp = AllDomains.DomainName[ArrayPoint]>
							<cfelseif ordby Is "PrivateYN">
								<cfset disp = AllDomains.PrivateYN[ArrayPoint]>
							<cfelseif ordby Is "AID">
								<cfset disp = AllDomains.AID[ArrayPoint]>
							</cfif>
							<cfoutput><option <cfif Page Is B5>selected</cfif> value="#B5#">Page #B5# - #disp#</cfoutput>
						</cfloop>
						<cfoutput><option <cfif Page Is 0>selected</cfif> value="0">View All - #AllDomains.RecordCount#</cfoutput>
					</select></td>
				</form>
			</tr>
		</cfif>
<cfoutput>
		<tr>
			<form method="post" name="AddNew" action="domains2.cfm">
				<input type="hidden" name="orddir" value="#orddir#">
				<input type="hidden" name="ordby" value="#ordby#">
				<input type="hidden" name="page" value="#page#">
				<td align="right" colspan="#HowWide#"><input type="image" src="images/addnew.gif" name="NewDomain" border="0"></td>
			</form>
		</tr>
		<tr bgcolor="#thclr#">
			<th>List</th>
			<th>Edit</th>
			<th>Default</th>
			<form method="post" action="domains.cfm">
				<cfif ordby Is "DomainName" AND orddir Is "asc">
					<input type="hidden" name="orddir" value="desc">
				<cfelse>
					<input type="hidden" name="orddir" value="asc">
				</cfif>
				<input type="hidden" name="page" value="#Page#">
				<th><input <cfif ordby Is "domainname">checked</cfif> type="radio" name="ordby" value="Domainname" onclick="submit()" id="col1"><label for="col1">Domain Name</label></th>
			</form>
			<form method="post" action="domains.cfm">
				<cfif ordby Is "PrivateYN" AND orddir Is "asc">
					<input type="hidden" name="orddir" value="desc">
				<cfelse>
					<input type="hidden" name="orddir" value="asc">
				</cfif>
				<input type="hidden" name="page" value="#Page#">
				<th><input <cfif ordby Is "PrivateYN">checked</cfif> type="radio" name="ordby" value="PrivateYN" onclick="submit()" id="col2"><label for="col2">Private</label></th>
			</form>
			<form method="post" action="domains.cfm">
				<cfif ordby Is "EID" AND orddir Is "asc">
					<input type="hidden" name="orddir" value="desc">
				<cfelse>
					<input type="hidden" name="orddir" value="asc">
				</cfif>
				<input type="hidden" name="page" value="#Page#">
				<th><input <cfif ordby Is "EID">checked</cfif> type="radio" name="ordby" value="EID" onclick="submit()" id="col3"><label for="col3">E-Mails</label></th>
			</form>
			<form method="post" action="domains.cfm">
				<cfif ordby Is "AID" AND orddir Is "asc">
					<input type="hidden" name="orddir" value="desc">
				<cfelse>
					<input type="hidden" name="orddir" value="asc">
				</cfif>
				<input type="hidden" name="page" value="#Page#">
				<th><input <cfif ordby Is "AID">checked</cfif> type="radio" name="ordby" value="AID" onclick="submit()" id="col3"><label for="col3">Auth</label></th>
			</form>
			<form method="post" action="domains.cfm">
				<cfif ordby Is "FID" AND orddir Is "asc">
					<input type="hidden" name="orddir" value="desc">
				<cfelse>
					<input type="hidden" name="orddir" value="asc">
				</cfif>
				<input type="hidden" name="page" value="#Page#">
				<th><input <cfif ordby Is "FID">checked</cfif> type="radio" name="ordby" value="FID" onclick="submit()" id="col3"><label for="col3">FTP</label></th>
			</form>
			<th>Copy</th>
			<th>Delete</th>
		</tr>
		<form method="post" name="EditInfo" action="domains.cfm" onsubmit="MsgWindow()">
			<input type="hidden" name="SetDefault" value="0">
			<input type="hidden" name="SetEdit" value="0">
			<input type="hidden" name="page" value="#page#">
			<input type="hidden" name="orddir" value="#orddir#">
			<input type="hidden" name="ordby" value="#ordby#">
</cfoutput>
			<cfset LoopCount = 0>
			<cfoutput query="AllDomains" startrow="#Srow#" maxrows="#MaxRows#">
				<tr bgcolor="#tbclr#">
					<td align="center" bgcolor="#tdclr#"><INPUT type="checkbox" name="DomainID" value="#DomainID#"></td>
					<td align="center" bgcolor="#tdclr#"><input type="radio" name="DomainID" value="#DomainID#" onClick="GoEdit()"></td>
					<td align="center" bgcolor="#tdclr#"><input type="radio" <cfif Primary1 is 1>Checked</cfif> name="Prim" value="#DomainID#" onClick="document.EditInfo.SetDefault.value=1;submit()"></td>
					<td>#DomainName#</td>
					<td>#YesNoFormat(PrivateYN)#</td>
					<cfset CntCheck = 0>
					<td align="right">#EID#</td>
					<cfset CntCheck = CntCheck + EID>
					<td align="right">#AID#</td>
					<cfset CntCheck = CntCheck + AID>
					<td align="right">#FID#</td>
					<cfset CntCheck = CntCheck + FID>
					<td align="center"><input type="Radio" name="CopyFrom" value="#DomainID#" onclick="CopyPlan()"></td>
					<td align="center" bgcolor="#tdclr#"><cfif (CntCheck GT 0) OR (Primary1 Is 1)>&nbsp;<cfelse><cfset LoopCount = LoopCount + 1><input type="checkbox" name="DelSelected" value="#DomainID#" onClick="SetValues(#DomainID#,this)"></cfif></td>
				</tr>
			</cfoutput>
<cfoutput>
			<input type="hidden" name="LoopCount" value="#LoopCount#">
			<cfif CheckReport.RecordCount GT 0>
				<tr bgcolor="#tdclr#">
					<th><input type="checkbox" name="domainid" value="0"></th>
					<cfset HowWide2 = HowWide - 2>
					<td bgcolor="#tbclr#" colspan="#HowWide2#">View Existing List</td>
					<th><input type="checkbox" name="deletelist" value="1" onclick="submit()"></th>
				</tr>
			</cfif>
			<tr>
				<th colspan="#HowWide#"><table border="0" cellpadding="0" cellspacing="0">
						<tr>
							<td><input type="image" src="images/list.gif" name="ListDomains" border="0"></td>
		</form>
							<td>&nbsp;&nbsp;</td>
							<form method="post" name="PickDelete" action="domains.cfm?RequestTimeout=500" onSubmit="return confirm('Click Ok to confirm deleting the selected Domains.')">
								<input type="hidden" name="DelThese" value="0">
								<td><input type="image" src="images/delete.gif" name="DelDomain" border="0"></td>
							</form>
						</tr>
					</table></th>
			</tr>
</cfoutput>		
		<cfif mrow LT AllDomains.recordCount>
			<tr>
				<form method="post" action="domains.cfm">
					<cfoutput>
						<input type="hidden" name="orddir" value="#orddir#">
						<input type="hidden" name="ordby" value="#ordby#">
					</cfoutput>
					<td colspan="#HowWide#"><select name="page" onChange="submit()">
						<cfloop index="B5" from="1" to="#PageNumber#">
							<cfset ArrayPoint = (B5 * mrow) - (mrow -1)>
							<cfif ordby Is "Primary1">
								<cfset disp = AllDomains.Primary1[ArrayPoint]>
							<cfelseif ordby Is "DomainName">
								<cfset disp = AllDomains.DomainName[ArrayPoint]>
							<cfelseif ordby Is "PrivateYN">
								<cfset disp = AllDomains.PrivateYN[ArrayPoint]>
							<cfelseif ordby Is "AID">
								<cfset disp = AllDomains.AID[ArrayPoint]>
							</cfif>
							<cfoutput><option <cfif Page Is B5>selected</cfif> value="#B5#">Page #B5# - #disp#</cfoutput>
						</cfloop>
						<cfoutput><option <cfif Page Is 0>selected</cfif> value="0">View All - #AllDomains.RecordCount#</cfoutput>
					</select></td>
				</form>
			</tr>
		</cfif>
	</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 
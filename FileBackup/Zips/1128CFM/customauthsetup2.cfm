<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page is for customizing the authentication database setup. --->
<!--- 4.0.0 06/24/99
		3.2.0 09/08/98 --->
<!--- customauthsetup2.cfm --->

<cfset securepage="customauthsetup.cfm">
<cfinclude template="security.cfm">
<cfif IsDefined("SetGeneral.x")>
	<cfif IsDefined("LastComplete")>
		<cfif IsDate(LastComplete)>
			<cfset NDT = LSParseDateTime(LastComplete)>
		<cfelse>
			<cfset NDT = DateAdd("m",-1,Now())>
		</cfif>
		<cfset NextDateTime = CreateDateTime(Year(NDT),Month(NDT),Day(NDT),Hour(NDT),0,0)>
	</cfif>
	<cfquery name="UpdData" datasource="#pds#">
		UPDATE CustomAuth SET 
		AuthDescription = '#AuthDescription#', 
		AuthType = #AuthType#, 
		<cfif IsDefined("NextDateTime")>LastImport = #CreateODBCDateTime(NextDateTime)#,</cfif> 
		<cfif IsDefined("NextDateTime")>LastComplete = #CreateODBCDateTime(NextDateTime)#,</cfif> 
		<cfif IsDefined("LastCompleteSpan")>LastImportSpan = #CreateODBCDateTime(LastCompleteSpan)#,</cfif> 
		<cfif IsDefined("LastCompleteSpan")>LastCompleteSpan = #CreateODBCDateTime(LastCompleteSpan)#,</cfif> 
		<cfif IsDefined("LastCompleteAmount")>LastImportAmount = #CreateODBCDateTime(LastCompleteAmount)#,</cfif> 
		<cfif IsDefined("LastCompleteAmount")>LastCompleteAmount = #CreateODBCDateTime(LastCompleteAmount)#,</cfif> 
		UniqueBy = #UniqueBY# 
		WHERE CAuthID = #CAuthID# 
	</cfquery>
</cfif>
<cfif (IsDefined("MvRt")) AND (IsDefined("TheHaveNots"))>
	<cfquery name="MvEmRight" datasource="#pds#">
		UPDATE Domains SET 
		CAuthID = #CAuthID# 
		WHERE DomainID IN (#TheHaveNots#)
	</cfquery>
</cfif>
<cfif (IsDefined("MvLt")) AND (IsDefined("TheHaves"))>
	<cfquery name="MvEmLeft" datasource="#pds#">
		UPDATE Domains SET 
		CAuthID = 0 
		WHERE DomainID IN (#TheHaves#)
	</cfquery>
</cfif>
<cfif (IsDefined("DelAuth.x")) AND (IsDefined("DelThese"))>
	<cfquery name="GetTables" datasource="#pds#">
		SELECT CRSID 
		FROM CustomAuthSetup 
		WHERE CRSID In 
			(SELECT ForTable 
			 FROM CustomAuthSetup 
			 WHERE CRSID In (#DelThese#) 
			)
		AND DBType = 'TB' 
		AND CAuthID = #CAuthID#
	</cfquery>
	<cfquery name="DelThese" datasource="#pds#">
		DELETE FROM CustomAuthSetup 
		WHERE CRSID In (#DelThese#) 
		AND CAuthID = #CAuthID# 
	</cfquery>
	<cfloop index="B5" list="#ValueList(GetTables.CRSID)#">
		<cfquery name="GetItems" datasource="#pds#">
			SELECT * 
			FROM CustomAuthSetup 
			WHERE ForTable = #B5# 
			AND DBType = 'FD' 
			AND CAuthID = #CAuthID# 
		</cfquery>
		<cfset SortOrd = 0>
		<cfloop query="GetItems">
			<cfset SortOrd = SortOrd + 1>
			<cfquery name="UpdData" datasource="#pds#">
				UPDATE CustomAuthSetup SET 
				SortOrder = #SortOrd# 
				Where CRSID = #CRSID# 
			</cfquery>
		</cfloop>
	</cfloop>
</cfif>
<cfif IsDefined("AddField.x")>
	<cfquery name="Custom" datasource="#pds#">
		SELECT CRSID 
		FROM CustomAuthSetup 
		WHERE BOBName LIKE 'Custom%' 
		AND CAuthID = #CAuthID# 
	</cfquery>
	<cfset CustomNum = Custom.Recordcount + 1>
	<cfset B4 = 0>
	<cfloop condition = "B4 Less Than 1">
		<cfquery name="CheckFirst" datasource="#pds#">
			SELECT CRSID 
			FROM CustomAuthSetup 
			WHERE BOBName LIKE 'Custom#CustomNum#' 
			AND CAuthID = #CAuthID# 
		</cfquery>
		<cfif CheckFirst.Recordcount Is 0>
			<cfset B4 = 10>
		<cfelse>
			<cfset CustomNum = CustomNum + 1>
		</cfif>
	</cfloop>
	<cfquery name="MaxSort" datasource="#pds#">
		SELECT Max(SortOrder) as MSO 
		FROM CustomAuthSetup 
		WHERE ForTable = #ForTable# 
		AND CAuthID = #CAuthID# 
	</cfquery>
	<cfif MaxSort.MSO Is "">
		<cfset MxSort = 1>
	<cfelse>
		<cfset MxSort = MaxSort.MSO + 1>
	</cfif>
	<cfquery name="AddNew" datasource="#pds#">
		INSERT INTO CustomAuthSetup 
		(DBType, Descrip1, BOBName, DBName, UseYN, CFVarYN, SortOrder, ForTable, ODBCSType, UseTab, DataType, CAuthID) 
		SELECT 
		'Fd', '#Description#', 'Custom#CustomNum#', '#DBName#', 1, 0, #MxSort#, #ForTable#, ODBCSType, UseTab, '#DataType#', #CAuthID# 
		FROM CustomAuthSetup 
		WHERE CRSID = #ForTable# 
	</cfquery>
</cfif>
<cfif IsDefined("setcreate")>
	<cfset intcode = "createaccount">
	<cfinclude template="integration/#thecode#.cfm">
</cfif>
<cfif IsDefined("setgeneric")>
	<cfset intcode = "saveauth">
	<cfinclude template="integration/#thecode#.cfm">
</cfif>
<cfif IsDefined("DeleteField.x")>
	<cfquery name="DelData" datasource="#pds#">
		DELETE FROM CustomAuthAccount 
		WHERE CAAID In (#DelThese#)
	</cfquery>
</cfif>
<cfif IsDefined("enterinfo.x")>
	<cfquery name="GetFields" datasource="#pds#">
		SELECT CustomAuthSetup.BOBName 
		FROM CustomAuthSetup 
		<cfif Ptab Is 3>
			WHERE UseTab = 2 
		<cfelse>
			WHERE UseTab = 1  
		</cfif>
		AND CAuthID = #CAuthID# 
		ORDER BY CustomAuthSetup.ODBCSType desc, CustomAuthSetup.fortable,
		CustomAuthSetup.DBType DESC, CustomAuthSetup.sortorder
	</cfquery>
	<cfset looplist = ValueList(GetFields.BOBName)>
	<cfloop list="#looplist#" index="B5">
		<cfif B5 does not contain "useyn">
			<cfset avalue = Evaluate("#B5#")>
			<cfif IsDefined("DataType#B5#")>
				<cfset dtvalue = Evaluate("DataType#B5#")>
			<cfelse>
				<cfset dtvalue = "">
			</cfif>
			<cfif avalue is "">
				<cfset usevalue = 0>
			<cfelse>
				<cfset usevalue = 1>
			</cfif>
			<cfquery name="updateinfo" datasource="#pds#">
				UPDATE CustomAuthSetup 
				SET dbname = 
				<cfif Trim(avalue) is "">
				Null,
				<cfelse>
				'#Trim(avalue)#', 
				</cfif>
				DataType = '#dtvalue#', 
				UseYN = #usevalue# 
				WHERE BOBName = '#B5#' 
				AND CAuthID = #CAuthID# 
				AND UseTab = 
					<cfif ptab Is 1>1<cfelse>2</cfif>
			</cfquery>
		</cfif>
	</cfloop>
</cfif>
<cfif IsDefined("enterone.x")>
	<cfquery name="enterdata" datasource="#pds#">
		INSERT INTO CustomAuthAccount 
		(DBFieldName, DataNeed, OrderBy, DataType, CAuthID) 
		Values 
		(<cfif DBFieldName is "">NULL<cfelse>'#Trim(DBFieldName)#'</cfif>, '#DataNeed#', 
		 #OrderBy#, '#DataType#', #CAuthID#)
	</cfquery>
</cfif>
<cfif IsDefined("editone.x")>
	<cfloop index="B5" from="1" to="#LoopCount#">
		<cfset var1 = Evaluate("CAAID#B5#")>
		<cfset var2 = Evaluate("DBFieldName#B5#")>
		<cfset var3 = Evaluate("DataNeed#B5#")>
		<cfset var4 = Evaluate("DataType#B5#")>
		<cfquery name="editdata" datasource="#pds#">
			UPDATE CustomAuthAccount SET 
			DBFieldName = <cfif Trim(var2) Is "">Null<cfelse>'#var2#'</cfif>,
			DataNeed = <cfif Trim(var3) Is "">Null<cfelse>'#var3#'</cfif>,
			DataType = <cfif Trim(var4) Is "">Null<cfelse>'#var4#'</cfif> 
			WHERE CAAID = #var1#
		</cfquery>
	</cfloop>
</cfif>
<cfparam name="ptab" default="5">
<cfparam name="HowWide" default="3">
<cfif ptab is 1>
	<cfset HowWide = 5>
	<cfquery name="getds" datasource="#pds#">
		SELECT * FROM CustomAuthSetup 
		WHERE DBType = 'DS' 
		AND CAuthID = #CAuthID# 
	</cfquery>
	<cfquery name="getfields" datasource="#pds#">
		SELECT CustomAuthSetup.* 
		FROM CustomAuthSetup 
		WHERE UseTab = 1 
		AND CAuthID = #CAuthID# 
		ORDER BY CustomAuthSetup.ODBCSType desc, CustomAuthSetup.fortable,
		CustomAuthSetup.DBType DESC, CustomAuthSetup.sortorder
	</cfquery>
<cfelseif ptab Is 3>
	<cfset HowWide = 5>
	<cfquery name="getfields" datasource="#pds#">
		SELECT CustomAuthSetup.* 
		FROM CustomAuthSetup 
		WHERE UseTab = 2 
		AND CAuthID = #CAuthID# 
		ORDER BY CustomAuthSetup.ODBCSType desc, CustomAuthSetup.fortable,
		CustomAuthSetup.DBType DESC, CustomAuthSetup.sortorder
	</cfquery>
<cfelseif ptab is 2>
	<cfset HowWide = 4>
	<cfquery name="getaccountinfo" datasource="#pds#">
		SELECT * 
		FROM CustomAuthAccount 
		WHERE CAuthID = #CAuthID# 
		ORDER BY DBFieldName
	</cfquery>
<cfelseif ptab Is 4>
	<cfset HowWide = 3>
	<cfquery name="GetSelected" datasource="#pds#">
		SELECT D.DomainID, D.DomainName 
		FROM Domains D, CustomAuth A 
		WHERE D.CauthID = A.CauthID 
		AND D.CAuthID = #CAuthID# 
		ORDER BY DomainName 
	</cfquery>
	<cfquery name="AvailOnes" datasource="#pds#">
		SELECT D.DomainID, D.DomainName, A.AuthDescription 
		FROM Domains D, CustomAuth A 
		WHERE D.CauthID = A.CauthID 
		AND D.CAuthID <> #CAuthID# 
		UNION 
		SELECT D.DomainID, D.DomainName, 'None' as AuthDescription 
		FROM Domains D 
		WHERE D.CAuthID = 0 
		OR D.CAuthID Is Null 
		ORDER BY DomainName
	</cfquery>
<cfelseif ptab Is 5>
	<cfset HowWide = 2>
	<cfquery name="GetAuthValues" datasource="#pds#">
		SELECT * 
		FROM CustomAuth 
		WHERE CAuthID = #CAuthID#
	</cfquery>
<cfelseif ptab Is 20>
	<cfset HowWide = 2>
	<cfquery name="AuthTables" datasource="#pds#">
		SELECT ForTable, DBName 
		FROM CustomAuthSetup 
		WHERE DBTYPE = 'TB' 
		AND CAuthID = #CAuthID# 
		<cfif rtab Is 1>
			AND UseTab = 1
		<cfelseif rtab Is 3>
			AND UseTab = 2
		</cfif>
	</cfquery>
</cfif>
<cfif (ptab Is Not 1) AND (ptab Is Not 3)>
	<cfquery name="GetVariables" datasource="#pds#">
		SELECT * 
		FROM IntVariables 
		WHERE CustomYN = 0 
		AND UseCreateYN = 1 
		ORDER BY UseText
	</cfquery>
</cfif>
<cfquery name="SetupDescrip" datasource="#pds#">
	SELECT AuthDescription 
	FROM CustomAuth 
	WHERE CAuthID = #CAuthID# 
</cfquery>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Authentication Setup</title>
<script language="javascript">
<!-- 
function CheckFor()
	{
	 var var1 = document.PickDelete.DelThese.value
	 return confirm ('Please Click Ok to confirm deleting the selected fields.')
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
<cfinclude template="coolsheet.cfm">
</HEAD>
<cfoutput>
	<body #colorset#>
</cfoutput>
<cfinclude template="header.cfm">
<cfif ptab gte 20>
	<form method="post" action="customauthsetup2.cfm">
		<cfoutput>
			<input type="hidden" name="ptab" value="#rtab#">
			<input type="hidden" name="CAuthID" value="#CAuthID#">
		</cfoutput>
		<input type="image" src="images/return.gif" border="0">
	</form>
<cfelse>
	<form method="post" action="customauthsetup.cfm">
		<input type="image" src="images/return.gif" border="0">
	</form>
</cfif>
<center>
<cfoutput>
	<table border="#tblwidth#">
		<tr>
			<th colspan="#HowWide#" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">#SetupDescrip.AuthDescription# Setup</font></th>
		</tr>
		<cfif ptab lte 5>
			<tr>
				<th colspan="#HowWide#">
					<table border="1">
						<tr>
							<form method="post" action="customauthsetup2.cfm">
								<td bgcolor=<cfif ptab is 5>"#tbclr#"<cfelse>"#tdclr#"</cfif> ><input type="radio" <cfif ptab Is 5>checked</cfif> name="ptab" value="5" onclick="submit()" id="tab5"><label for="tab5">General</label></td>
								<td bgcolor=<cfif ptab is 1>"#tbclr#"<cfelse>"#tdclr#"</cfif> ><input type="radio" <cfif ptab Is 1>checked</cfif> name="ptab" value="1" onclick="submit()" id="tab1"><label for="tab1">Database Authentication</label></td>
								<td bgcolor=<cfif ptab is 3>"#tbclr#"<cfelse>"#tdclr#"</cfif> ><input type="radio" <cfif ptab Is 3>checked</cfif> name="ptab" value="3" onclick="submit()" id="tab3"><label for="tab3">Database Accounting</label></td>							
								<td bgcolor=<cfif ptab is 2>"#tbclr#"<cfelse>"#tdclr#"</cfif> ><input type="radio" <cfif ptab Is 2>checked</cfif> name="ptab" value="2" onclick="submit()" id="tab2"><label for="tab2">Account Creation</label></td>
								<td bgcolor=<cfif ptab is 4>"#tbclr#"<cfelse>"#tdclr#"</cfif> ><input type="radio" <cfif ptab Is 4>checked</cfif> name="ptab" value="4" onclick="submit()" id="tab4"><label for="tab4">Domains</label></td>
								<input type="hidden" name="CAuthID" value="#CAuthID#">
							</form>
						</tr>
					</table>
				</th>
			</tr>
		</cfif>
		<cfif (ptab Is 1) OR (ptab Is 3)>
			<tr>
				<form method="post" action="customauthsetup2.cfm">
					<input type="hidden" name="ptab" value="20">
					<input type="hidden" name="rtab" value="#ptab#">
					<input type="hidden" name="CAuthID" value="#CAuthID#">
					<td colspan="#HowWide#" align="right"><input type="image" name="addnew" src="images/addnew.gif" border="0"></td>
				</form>
			</tr>
		</cfif>
</cfoutput>
<cfif (ptab is "1") OR (ptab is "3")>
	<form method="post" name="EditInfo" action="customauthsetup2.cfm">
		<cfset LoopCount = 0>
			<cfoutput query="getfields" group="ODBCSType">
				<cfoutput group="fortable">
					<tr>
						<cfif DBType Is "tb">
							<th bgcolor="#thclr#" colspan="4">#descrip1#</th>
							<th bgcolor="#thclr#">Delete</th>
						<cfelse>
							<th bgcolor="#thclr#" colspan="5">#descrip1#</th>
						</cfif>
					</tr>
					<cfoutput>
						<tr>
							<cfif DBType is "DS">
								<td bgcolor="#tbclr#" colspan="2">DataSource</td>
							<cfelseif DBType Is "Dt">
								<td bgcolor="#tbclr#" colspan="2">Database Type</td>
							<cfelseif DBType is "Tb">
								<td bgcolor="#tbclr#" colspan="2">Table Name</td>
							<cfelseif DBType is "Fd">
								<td bgcolor="#tbclr#">Field Name</td>
								<td bgcolor="#tdclr#"><select name="DataType#BOBName#">
									<option <cfif DataType Is "Date">selected</cfif> value="Date">Date
									<option <cfif DataType Is "Number">selected</cfif> value="Number">Number
									<option <cfif DataType Is "Text">selected</cfif> value="Text">Text
								</select></td>
							</cfif>
							<td bgcolor="#tbclr#" align="right">#descrip1#</td>
							<cfif DBType Is Not "Dt">
								<td bgcolor="#tdclr#"><input type="text" name="#BOBName#" value="#DBName#"></td>
							<cfelse>
								<td bgcolor="#tdclr#"><select name="#BOBName#">
									<option <cfif DBName Is "Access">selected</cfif> value="Access">Access
									<option <cfif DBName Is "SQL">selected</cfif> value="SQL">SQL Server
								</select></td>
							</cfif>
							<cfif CFVarYN Is 0>
								<cfset LoopCount = LoopCount + 1>
								<th bgcolor="#tdclr#"><input type="checkbox" name="DelSelected" value="#CRSID#" onClick="SetValues(#CRSID#,this)"></th>
							<cfelse>
								<td bgcolor="#tdclr#">&nbsp;</td>
							</cfif>
						</tr>
					</cfoutput>		
				</cfoutput>
			</cfoutput>
			<cfoutput>
				<input type="hidden" name="LoopCount" value="#LoopCount#">
				<input type="hidden" name="Ptab" value="#ptab#">
				<input type="hidden" name="CAuthID" value="#CAuthID#">
			</cfoutput>
			<tr>
				<th colspan="5">
					<table border="0">
						<tr>
							<td><input type="image" src="images/update.gif" name="enterinfo" border="0"></td>
	</form>
	<form method="post" name="PickDelete" action="customauthsetup2.cfm" onSubmit="return confirm('Click Ok to confirm deleting the selected Custom Authentication entries.')">
							<td><input type="image" src="images/delete.gif" name="DelAuth" border="0"></td>
						</tr>
					</table>
				</th>
			</tr>
			<cfoutput>
				<input type="hidden" name="DelThese" value="0">
				<input type="hidden" name="ptab" value="#ptab#">
				<input type="hidden" name="CAuthID" value="#CAuthID#">
			</cfoutput>
	</form>
<cfelseif ptab is 2>
	<cfoutput>
		<tr>
			<form method="post" action="customauthsetup2.cfm">
				<input type="hidden" name="ptab" value="S1">
				<input type="hidden" name="rtab" value="#ptab#">
				<input type="hidden" name="CAuthID" value="#CAuthID#">
				<td colspan="4" align="right"><input type="submit" name="addone" value="Add Single Line"></td>
			</form>
		</tr>
		<tr>
			<form method="post" action="customauthsetup2.cfm">
				<input type="hidden" name="ptab" value="M1">
				<input type="hidden" name="rtab" value="#ptab#">
				<input type="hidden" name="CAuthID" value="#CAuthID#">
				<td colspan="4" align="right"><input type="submit" name="addmulti" value="Add Multi Line"></td>
			</form>
		</tr>
		<tr bgcolor="#thclr#">
			<th>Data Type</th>
			<th>Field Name</th>
			<th>Data Needed</th>
			<th>Delete</th>
		</tr>
	</cfoutput>
	<form method="post" name="EditInfo" action="customauthsetup2.cfm">
		<cfoutput>
			<input type="hidden" name="ptab" value="#ptab#">
			<input type="hidden" name="CAuthID" value="#CAuthID#">
		</cfoutput>
		<cfset counter1 = 0>
		<cfloop query="getaccountinfo">
			<cfset counter1 = counter1 + 1>
			<cfoutput>
				<tr valign="top" bgcolor="#tdclr#">
					<input type="hidden" name="CAAID#counter1#" value="#CAAID#">
					<input type="hidden" name="orderby#counter1#" value="#orderby#">
					<td><select name="DataType#counter1#">
						<option <cfif datatype is "Date">selected</cfif> value="Date">Date
						<option <cfif datatype is "Number">selected</cfif> value="Number">Number
						<option <cfif datatype is "Text">selected</cfif> value="Text">Text
					</select></td>
					<td><input type="text" name="DBFieldName#counter1#" value="#DBFieldName#" maxlength="35" size="20"></td>
					<cfif orderby is 1>
						<td><input type="text" name="DataNeed#counter1#" value="#DataNeed#" size="20"></td>
					<cfelse>
						<td><textarea name="DataNeed#counter1#" rows="2" cols="30">#DataNeed#</textarea></td>
					</cfif>
					<th><input type="checkbox" name="DelSelected" value="#CAAID#" onClick="SetValues(#CAAID#,this)"></th>
				</tr>
			</cfoutput>
		</cfloop>
		<cfoutput><input type="hidden" name="LoopCount" value="#counter1#"></cfoutput>
		<tr>
			<th colspan="4">
				<table border="0">
					<tr>
						<td><input type="image" src="images/update.gif" name="editone" border="0"></td>
	</form>
	<form method="post" name="PickDelete" action="customauthsetup2.cfm" onSubmit="return CheckFor()">
						<input type="hidden" name="DelThese" value="0">
						<cfoutput>
						<input type="hidden" name="ptab" value="#ptab#">
						<input type="hidden" name="CAuthID" value="#CAuthID#">
						</cfoutput>
						<td> <input type="image" src="images/delete.gif" name="DeleteField" border="0"></td>		
					</tr>
				</table>		
			</th>
		</tr>
	</form>
<cfelseif ptab Is "4">
	<cfoutput>
	<tr bgcolor="#thclr#">
		<th>Available Domains</th>
		<th>Action</th>
		<th>Selected Domains</th>
	</tr>
	<tr bgcolor="#tdclr#" valign="top">
	</cfoutput>
		<form method="post" action="customauthsetup2.cfm">
			<th><select name="TheHaveNots" multiple size="10">
				<cfloop query="AvailOnes">
					<cfoutput><option value="#DomainID#">#DomainName# - #AuthDescription#</cfoutput>
				</cfloop>
				<option value="0">______________________________
			</select><br>Selecting a domain will override<br>the current setup for the selected domain.</th>
			<th align="center" valign="middle"><input type="submit" name="MvRt" value="---->"><br>
			<input type="submit" name="MvLt" value="<----"><br></th>
			<th><select name="TheHaves" multiple size="10">
				<cfloop query="GetSelected">
					<cfoutput><option value="#DomainID#">#DomainName#</cfoutput>
				</cfloop>
				<option value="0">______________________________
			</select></th>
			<cfoutput>
				<input type="hidden" name="CAuthID" value="#CAuthID#">
				<input type="hidden" name="ptab" value="4">
			</cfoutput>
		</form>
	</tr>
<cfelseif ptab Is "5">
	<form method="post" action="customauthsetup2.cfm">
		<cfoutput>
			<tr bgcolor="#tbclr#">
				<td align="right">Auth Description</td>
				<td bgcolor="#tdclr#"><input type="Text" name="AuthDescription" value="#GetAuthValues.AuthDescription#" maxlength="255" size="35"></td>
			</tr>
			<tr bgcolor="#tbclr#" valign="top">
				<td align="right">Data Type</td>
				<td bgcolor="#tdclr#"><input type="Radio" <cfif GetAuthValues.AuthType Is "0">checked</cfif> name="AuthType" value="0">Text File <input type="Radio" <cfif GetAuthValues.AuthTYpe Is "1">checked</cfif> name="AuthType" value="1">ODBC Database</td>
			</tr>
			<tr bgcolor="#tbclr#" valign="top">
				<td align="right">Usernames are unique</td>
				<td bgcolor="#tdclr#"><input type="Radio" <cfif GetAuthValues.UniqueBy Is "1">checked</cfif> name="UniqueBy" value="1">By Domain<br>
				<input type="Radio" <cfif GetAuthValues.UniqueBy Is "2">checked</cfif> name="UniqueBy" value="2">By This Custom Auth Only<br>
				<input type="Radio" <cfif GetAuthValues.UniqueBy Is "3">checked</cfif> name="UniqueBy" value="3">Globally - All Custom Auth</td>
			</tr>
			<cfif GetAuthValues.AuthType Is 1>
				<tr bgcolor="#tbclr#">
					<td align="right">Last Monthly Span Import</td>
					<cfif GetAuthValues.LastComplete Is "">
						<cfset NDT = Now()>
					<cfelse>
						<cfset NDT = GetAuthValues.LastComplete>
					</cfif>
					<cfset LastComplete = CreateDateTime(Year(NDT),Month(NDT),Day(NDT),Hour(NDT),0,0)>
					<td bgcolor="#tdclr#"><input type="Text" name="LastComplete" value="#DateFormat(LastComplete, '#DateMask1#')# #TimeFormat(LastComplete, 'hh tt')#"> <a href="maintradiusimport.cfm?catchup=1&id=#CAuthID#">Catch Up</a></td>
				</tr>
				<tr bgcolor="#tbclr#">
					<td align="right">Last Daily Span Import</td>
					<cfif GetAuthValues.LastCompleteSpan Is "">
						<cfset NDT = Now()>
					<cfelse>
						<cfset NDT = GetAuthValues.LastCompleteSpan>
					</cfif>
					<cfset LastCompleteS = CreateDateTime(Year(NDT),Month(NDT),Day(NDT),Hour(NDT),0,0)>
					<td bgcolor="#tdclr#"><input type="Text" name="LastCompleteSpan" value="#DateFormat(LastCompleteS, '#DateMask1#')# #TimeFormat(LastCompleteS, 'hh tt')#"> <a href="maintmeterbill.cfm?catchup=1&id=#CAuthID#">Catch Up</a></td>
				</tr>
				<tr bgcolor="#tbclr#">
					<td align="right">Last Daily $ Calculated</td>
					<cfif GetAuthValues.LastCompleteAmount Is "">
						<cfset NDT = Now()>
					<cfelse>
						<cfset NDT = GetAuthValues.LastCompleteAmount>
					</cfif>
					<cfset LastCompleteS = CreateDateTime(Year(NDT),Month(NDT),Day(NDT),Hour(NDT),0,0)>
					<td bgcolor="#tdclr#"><input type="Text" name="LastCompleteAmount" value="#DateFormat(LastCompleteS, '#DateMask1#')# #TimeFormat(LastCompleteS, 'hh tt')#"> <a href="maintmetered.cfm?catchup=1?catchup=1&id=#CAuthID#">Catch Up</a></td>
				</tr>
				<tr bgcolor="#tbclr#">
					<td colspan="2">Changing the import times will not reset any metered billing that you have already billed.<br>
               The maximum you can reset is 1 month.</td>
				</tr>
			</cfif>
			<tr>
				<th colspan="2"><input type="Image" src="images/update.gif" border="0" name="SetGeneral"></th>
			</tr>
			<input type="Hidden" name="CAuthID" value="#CAuthID#">
			<input type="Hidden" name="AuthDescription_Required" value="Please enter the description for this authentication setup.">
		</cfoutput>
		<input type="Hidden" name="ptab" value="5">
	</form>
<cfelseif ptab Is "20">
	<cfoutput>
		<form method="post" action="customauthsetup2.cfm">
			<tr bgcolor="#tdclr#">
				<td align="right" bgcolor="#tbclr#">Table Name</td>
	</cfoutput>
				<td><select name="ForTable">
					<cfoutput query="AuthTables">
						<option value="#ForTable#">#DBName#
					</cfoutput>
				</select></td>
			</tr>
		<cfoutput>
			<tr bgcolor="#tdclr#">
				<td align="right" bgcolor="#tbclr#">Field Name</td>
				<td><input type="text" name="DBName" size="25" maxlength="45"></td>
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">Description</td>
				<td bgcolor="#tdclr#"><input type="text" name="Description" maxlength="35" size="35"></td>
			</tr>
			<tr bgcolor="#tdclr#">
				<td align="right" bgcolor="#tbclr#">Data Type</td>
				<td><select name="DataType">
					<option value="Date">Date
					<option value="Number">Number
					<option value="Text">Text
				</select></td>
			</tr>
			<tr>
				<th colspan="2"><input type="image" src="images/enter.gif" border="0" name="AddField"></th>
			</tr>
			<input type="hidden" name="ptab" value="#rtab#">
			<input type="hidden" name="CAuthID" value="#CAuthID#">
		</cfoutput>
		</form>
<cfelseif ptab Is "S1">
	<cfoutput>
		<tr bgcolor="#thclr#">
			<th>Data Type</th>
			<th>Field Name</th>
			<th>Data Needed</th>
		</tr>
	</cfoutput>
	<form method="post" action="customauthsetup2.cfm">
		<tr>
			<input type="hidden" name="ptab" value="2">
			<input type="hidden" name="orderby" value="1">
			<td><select name="DataType">
				<option value="Date">Date
				<option value="Number">Number
				<option value="Text">Text
			</select></td>
			<td><input type="text" name="DBFieldName" maxlength="35" size="30"></td>
			<td><input type="text" name="DataNeed" size="30"></td>
			<input type="hidden" name="DBFieldName_required" value="Please enter the Database Field Name.">
			<input type="hidden" name="DataNeed_required" value="Please enter the Data needed.">
		</tr>
		<tr>
			<th colspan="3"><input type="image" src="images/enter.gif" name="enterone" border="0"></th>
		</tr>
		<cfoutput>
			<input type="hidden" name="CAuthID" value="#CAuthID#">
		</cfoutput>
	</form>
<cfelseif ptab Is "M1">
	<cfoutput>
		<tr bgcolor="#thclr#">
			<th>Data Type</th>
			<th>Field Name</th>
			<th>Data Needed</th>
		</tr>
	</cfoutput>
	<form method="post" action="customauthsetup2.cfm">
		<tr valign="top">
			<input type="hidden" name="ptab" value="2">
			<input type="hidden" name="orderby" value="0">
			<td><select name="DataType">
				<option value="Date">Date
				<option value="Number">Number
				<option value="Text">Text
			</select></td>
			<td><input type="text" name="DBFieldName" maxlength="35" size="30"></td>
			<td><textarea rows="5" cols="30" name="DataNeed"></textarea></td>
			<input type="hidden" name="DBFieldName_required" value="Please enter the Database Field Name.">
			<input type="hidden" name="DataNeed_required" value="Please enter the Data needed.">
		</tr>
		<tr>
			<th colspan="3"><input type="image" src="images/enter.gif" name="enterone" border="0"></th>
		</tr>
		<cfoutput>
			<input type="hidden" name="CAuthID" value="#CAuthID#">
		</cfoutput>
	</form>
</cfif>
<cfif (ptab Is Not 1) AND (ptab Is Not 3) AND (ptab LT 4)>
	<tr>
		<cfset counter1 = 0>
		<cfoutput>
		<td colspan="#HowWide#">
			<table border="1" bgcolor="#tbclr#">
		</cfoutput>
				<cfoutput query="GetVariables">
					<cfset counter1 = counter1  + 1>
					<cfif counter1 Is 1><tr></cfif>
					<td><font size="2">#UseText# #ForText#</font></td>
					<cfif counter1 Is 3></tr><cfset counter1 = 0></cfif>
				</cfoutput>
				<cfoutput>
					<cfif counter1 Is 1>
						<td>&nbsp;</td><td>&nbsp;</td></tr>
					<cfelseif counter1 Is 2>
						<td>&nbsp;</td></tr>
					<cfelseif counter1 Is 3>
						</tr>
					</cfif>
				</cfoutput>
			</table>
		</td>
	</tr>
</cfif>
</table>
</center>

<cfif ptab is "1">
	<cfdirectory action="list" directory="#billpath#cfm/integration"
	 filter="*.cfm" name="getint">
	<cfif getint.recordcount gt 0>
		<cfset intcode = "authentication">
		<cfset intcount = 1>
		<table>
			<tr>
				<cfloop query="getint">
					<cfinclude template="integration/#name#">
				</cfloop>
			</tr>
		</table>
		<cfif intcount Is 0>
			<table>
				<tr>
					<td>Click on your authentication software for a generic setup.</td>
				</tr>
			</table>
		</cfif>
	</cfif>
<cfelseif ptab is "2">
	<cfdirectory action="list" directory="#billpath#cfm/integration"
	 filter="*.cfm" name="getint">
	<cfif getint.recordcount gt 0>
		<cfset intcode = "createaccountsetup">
		<cfset intcount = 1>
		<table>
			<tr>
				<cfloop query="getint">
					<cfinclude template="integration/#name#">
				</cfloop>
			</tr>
		</table>
		<cfif intcount Is 0>
			<table>
				<tr>
					<td>Click on your authentication software for a generic setup.</td>
				</tr>
			</table>
		</cfif>
	</cfif>
</cfif>
<cfinclude template="footer.cfm">
</body>
</html>
 
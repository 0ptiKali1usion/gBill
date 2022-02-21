<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page edits the menu items. --->
<!--- 4.0.1 11/21/00 Added cleanup query when deleting menu items.
		4.0.0 08/01/99
		3.5.0 07/09/99
		3.2.0 09/08/98 --->
<!--- editmenu.cfm --->

<cfinclude template="security.cfm">
<cfif (IsDefined("HaveIt")) AND (IsDefined("MvLt"))>
	<cfquery name="GetMenuItem" datasource="#pds#">
		SELECT Title 
		FROM MenuItems 
		WHERE MenuID = #MenuID# 
	</cfquery>
	<cfloop index="B5" list="#HaveIt#">
		<cfif B5 GT 0>
			<cfquery name="DelData" datasource="#pds#">
				DELETE FROM Connect 
				WHERE MenuID = #MenuID# 
				AND AdminID = #B5# 
			</cfquery>
			<cfquery name="CheckFirst" datasource="#pds#">
				SELECT AdminID 
				FROM AdmSort 
				WHERE AdminID = #B5# 
				AND LevelID = 
					(SELECT Menu 
					 FROM MenuItems 
					 WHERE MenuID = #MenuID#)
			</cfquery>
			<cfquery name="GetWho" datasource="#pds#">
				SELECT AccountID, FirstName, LastName 
				FROM Accounts 
				WHERE AccountID =  
					(SELECT AccountID 
					 FROM Admin 
					 WHERE AdminID = #B5#)
			</cfquery>
			<cfif Not IsDefined("NoBOBHist")>
				<cfquery name="BOBHist" datasource="#pds#">
					INSERT INTO BOBHist
					(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
					VALUES 
					(Null,#GetWho.AccountID#,#MyAdminID#, #Now()#,'Staff','#StaffMemberName.FirstName# #StaffMemberName.LastName# removed the menu item - #GetMenuItem.Title#, from #GetWho.FirstName# #GetWho.LastName#.')
				</cfquery>
			</cfif>
		</cfif>
	</cfloop>
</cfif>
<cfif (IsDefined("WantIt")) AND (IsDefined("MvRt"))>
	<cfquery name="GetMenuItem" datasource="#pds#">
		SELECT Title 
		FROM MenuItems 
		WHERE MenuID = #MenuID# 
	</cfquery>
	<cfloop index="B5" list="#WantIt#">
		<cfif B5 GT 0>
			<cfquery name="CheckFirst" datasource="#pds#">
				SELECT AdminID 
				FROM AdmSort 
				WHERE AdminID = #B5# 
				AND LevelID = 
					(SELECT Menu 
					 FROM MenuItems 
					 WHERE MenuID = #MenuID#)
			</cfquery>
			<cfquery name="AddData" datasource="#pds#">
				INSERT INTO Connect 
				(AdminID, MenuID) 
				VALUES 
				(#B5#,#MenuID#)
			</cfquery>
			<cfif Not IsDefined("NoBOBHist")>
				<cfquery name="GetWho" datasource="#pds#">
					SELECT AccountID, FirstName, LastName 
					FROM Accounts 
					WHERE AccountID =  
						(SELECT AccountID 
						 FROM Admin 
						 WHERE AdminID = #B5#)
				</cfquery>
				<cfquery name="BOBHist" datasource="#pds#">
					INSERT INTO BOBHist
					(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
					VALUES 
					(Null,#GetWho.AccountID#,#MyAdminID#, #Now()#,'Staff','#StaffMemberName.FirstName# #StaffMemberName.LastName# added the menu item - #GetMenuItem.Title#, to #GetWho.FirstName# #GetWho.LastName#.')
				</cfquery>
			</cfif>
			<cfif CheckFirst.Recordcount Is 0>
				<cfquery name="GetSort" datasource="#pds#">
					SELECT max(SortOrder) as MSO 
					FROM AdmSort 
					WHERE AdminID = #B5# 
				</cfquery>
				<cfquery name="GetLevel" datasource="#pds#">
					SELECT Menu 
					FROM MenuItems 
					WHERE MenuID = #MenuID# 
				</cfquery>
				<cfif GetSort.MSO Is "">
					<cfset NewSort = 1>
				<cfelse>
					<cfset NewSort = 1 + GetSort.MSO>
				</cfif>
				<cfquery name="InsData" datasource="#pds#">
					INSERT INTO AdmSort 
					(AdminID, LevelID, SortOrder)
					VALUES 
					(#B5#, #GetLevel.Menu#, #NewSort#)
				</cfquery>
			</cfif>
		</cfif>
	</cfloop>
</cfif>
<cfif IsDefined("AddMenu.x")>
	<cftransaction>
		<cfquery name="AddData" datasource="#pds#">
			INSERT INTO MenuItems 
			(Title, DbmName, Menu, ActiveYN) 
			VALUES 
			('#Title#', '#DbmName#', #Menu#, 1)
		</cfquery>
		<cfquery name="MaxID" datasource="#pds#">
			SELECT max(MenuID) as MaxMenu 
			FROM MenuItems 
		</cfquery>
		<cfif Not IsDefined("NoBOBHist")>
			<cfquery name="BOBHist" datasource="#pds#">
				INSERT INTO BOBHist
				(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
				VALUES 
				(Null,0,#MyAdminID#, #Now()#,'Menu Item','#StaffMemberName.FirstName# #StaffMemberName.LastName# added the menu item #Title#.')
			</cfquery>
		</cfif>
		<cfset MenuID = MaxID.MaxMenu>
	</cftransaction>
</cfif>
<cfif IsDefined("UpMenu.x")>
	<cfquery name="UpdData" datasource="#pds#">
		UPDATE MenuItems SET 
		Title = '#Title#', 
		DbmName = '#DbmName#', 
		Menu = #Menu# 
		WHERE MenuID = #MenuID#
	</cfquery>
</cfif>
<cfif (IsDefined("DeleteItems.x")) AND (IsDefined("DeleteSelected"))>
	<cfquery name="GetItems" datasource="#pds#">
		SELECT Title 
		FROM MenuItems 
		WHERE MenuID In (#DeleteSelected#) 
	</cfquery>
	<cfquery name="DelData" datasource="#pds#">
		DELETE FROM MenuItems 
		WHERE MenuID In (#DeleteSelected#)
	</cfquery>
	<cfquery name="CLeanUp" datasource="#pds#">
		DELETE FROM Connect 
		WHERE MenuID In (#DeleteSelected#)
	</cfquery>
		<cfif Not IsDefined("NoBOBHist")>
			<cfquery name="BOBHist" datasource="#pds#">
				INSERT INTO BOBHist
				(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
				VALUES 
				(Null,0,#MyAdminID#, #Now()#,'Menu Item','#StaffMemberName.FirstName# #StaffMemberName.LastName# deleted the following menu items: (#ValueList(GetItems.Title)#).')
			</cfquery>
		</cfif>
</cfif>

<cfparam name="tab" default="1">

<cfif tab IS 1>
	<cfset HowWide = 4>	
	<cfquery name="SelLevel" datasource="#pds#">
		SELECT LevelID 
		FROM Levels 
		WHERE Sort = 
				(SELECT Min(Sort) 
				 FROM Levels)
	</cfquery>
	<cfparam name="StartID" default="#SelLevel.LevelID#">
	<cfparam name="obid" default="Title">
	<cfparam name="obdir" default="asc">
	<cfquery name="AllMenuItems" datasource="#pds#">
		SELECT M.MenuID, M.Title, M.dbmname, L.LevelName 
		FROM MenuItems M, Levels L 
		WHERE M.Menu = L.LevelID 
		<cfif StartID GT 0>
			AND L.LevelID = #StartID# 
		</cfif>
		ORDER BY 
		<cfif obid Is Not "Title">
			L.sort #obdir#, #obid# #obdir#
      <cfelse>
      	L.sort #obdir#, M.Title #obdir# 
      </cfif>
	</cfquery>
<cfelseif tab Is 2>
	<cfset HowWide = 2>
	<cfquery name="OneMenu" datasource="#pds#">
		SELECT M.Title, M.dbmname, M.MenuID, M.Menu, L.LevelName, L.LevelID 
		FROM MenuItems M, Levels L 
		WHERE M.MenuID = #MenuID# 
		AND M.Menu=LevelID
	</cfquery>
<cfelseif tab Is 3>
	<cfset HowWide = 3>
	<cfquery name="OneMenu" datasource="#pds#">
		SELECT M.Title, M.dbmname, M.MenuID, M.Menu, L.LevelName, L.LevelID 
		FROM MenuItems M, Levels L 
		WHERE M.MenuID = #MenuID# 
		AND M.Menu=LevelID
	</cfquery>
	<cfquery name="GetWhoHas" datasource="#pds#">
		SELECT U.LastName, U.FirstName, A.AdminID 
		FROM Accounts U, Admin A, Connect C 
		WHERE U.AccountID = A.Accountid 
		AND C.AdminID = A.Adminid 
		AND C.MenuID = #MenuID# 
		ORDER BY U.LastName, U.FirstName 
	</cfquery>
	<cfquery name="GetWhoWants" datasource="#pds#">
		SELECT U.LastName, U.FirstName, A.AdminID 
		FROM Accounts U, Admin A 
		WHERE U.AccountID = A.AccountID 
		AND A.Adminid Not In 
				(SELECT A.AdminID 
				 FROM Accounts U, Admin A, Connect C 
				 WHERE U.AccountID = A.Accountid 
				 AND C.AdminID = A.Adminid 
				 AND C.MenuID = #MenuID#)
		Order By U.LastName, U.FirstName 
	</cfquery>
</cfif>
<cfquery name="AllLevels" datasource="#pds#">
	SELECT LevelName, LevelID, Sort 
	FROM Levels 
	ORDER BY LevelName
</cfquery>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Edit Menu Items</TITLE>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<cfif tab GT 1>
	<form method="post" action="editmenu.cfm">
		<cfoutput><input type="hidden" name="StartID" value="#OneMenu.LevelID#"></cfoutput>
		<input type="image" name="Return" src="images/return.gif" border="0">
	</form>
</cfif>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th bgcolor="#ttclr#" colspan="#HowWide#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#perFontName#"</cfif> color="#ttfont#">Menu Items</font></th>
	</tr>
</cfoutput>
<cfif tab Is 1>
	<tr>
		<form method="post" action="editmenu.cfm">
			<input type="hidden" name="tab" value="2">
			<input type="hidden" name="MenuID" value="0">
			<td colspan="4" align="right"><input type="image" name="AddNew" src="images/addnew.gif" border="0"></td>
		</form>
	</tr>
	<tr>
		<form method="post" action="editmenu.cfm">
			<cfoutput>
			<input type="hidden" name="obdir" value="#obdir#">
			<input type="hidden" name="obid" value="#obid#">
			</cfoutput>
			<td colspan="4"><select name="StartID" onChange="submit()">
				<cfoutput query="AllLevels">
					<option <cfif LevelID Is StartID>selected</cfif> value="#LevelID#">#LevelName#
				</cfoutput>
				<option <cfif StartID Is 0>selected</cfif> value="0">All Headers
			</select></td>
		</form>
	</tr>
	<cfoutput>
	<tr bgcolor="#thclr#">
		<th>Edit</th>
		<form method="post" action="editmenu.cfm">
			<input type="hidden" name="StartID" value="#StartID#">
			<cfif (obid Is "Title") AND (obdir Is "asc")>
				<input type="hidden" name="obdir" value="desc">
			<cfelse>
				<input type="hidden" name="obdir" value="asc">
			</cfif>
			<th><Input type="radio" <cfif obid Is "Title">checked</cfif> name="obid" value="title" onclick="submit()" id="col1"><label for="col1">Menu Item</label></th>
		</form>
		<form method="post" action="editmenu.cfm">
			<input type="hidden" name="StartID" value="#StartID#">
			<cfif (obid Is "dbmName") AND (obdir Is "asc")>
				<input type="hidden" name="obdir" value="desc">
			<cfelse>
				<input type="hidden" name="obdir" value="asc">
			</cfif>
			<th><Input type="radio" name="obid" <cfif obid Is "dbmName">checked</cfif> value="dbmName" onclick="submit()" id="col1"><label for="col1">Page Name</label></th>
		</form>
		<th>Delete</th>
	</tr>
	</cfoutput>
	<form name="EditInfo" method="post" action="editmenu.cfm">
	<cfoutput>
		<input type="hidden" name="tab" value="1">
		<input type="hidden" name="StartID" value="#StartID#">
	</cfoutput>
	<cfoutput query="AllMenuItems" group="LevelName">
		<tr>
			<th bgcolor="#thclr#" colspan="4">#LevelName#</th>
		</tr>
		<cfoutput>
			<tr>
				<th bgcolor="#tdclr#"><input type="radio" name="MenuID" value="#MenuID#" onClick="document.EditInfo.tab.value=2;submit()"></th>
				<td bgcolor="#tbclr#">#Title#</td>
				<td bgcolor="#tbclr#"><a href="#dbmname#" target="_New">#dbmName#</a></td>
				<th bgcolor="#tdclr#"><input type="checkbox" name="DeleteSelected" value="#MenuID#"></th>
			</tr>
		</cfoutput>
	</cfoutput> 
	<tr>
		<th colspan="4"><input type="image" src="images/delete.gif" name="DeleteItems" border="0"></th>
	</tr>
	</form>
	<tr>
		<form method="post" action="editmenu.cfm">
			<cfoutput>
			<input type="hidden" name="obdir" value="#obdir#">
			<input type="hidden" name="obid" value="#obid#">
			</cfoutput>
			<td colspan="4"><select name="StartID" onChange="submit()">
				<cfoutput query="AllLevels">
					<option <cfif LevelID Is StartID>selected</cfif> value="#LevelID#">#LevelName#
				</cfoutput>
				<option <cfif StartID Is 0>selected</cfif> value="0">All Headers
			</select></td>
		</form>
	</tr>
<cfelseif tab Is 2>
	<cfoutput>
	<cfif MenuID GT 0>
		<tr>
			<th colspan="2">
				<table border="1">
					<tr>
						<form method="post" action="editmenu.cfm">
							<input type="hidden" name="MenuID" value="#OneMenu.MenuID#">
							<td bgcolor=<cfif tab Is 2>"#tbclr#"<cfelse>"#tdclr#"</cfif> ><input type="radio" <cfif tab Is 2>checked</cfif> name="tab" value="2" onclick="submit()" id="tab2"><label for="tab2">General</label></td>
							<td bgcolor=<cfif tab Is 3>"#tbclr#"<cfelse>"#tdclr#"</cfif> ><input type="radio" <cfif tab Is 3>checked</cfif> name="tab" value="3" onclick="submit()" id="tab3"><label for="tab3">Staff</label></td>
						</form>
					</tr>
				</table>
			</th>
		</tr>
	</cfif>
	<form method=post name="info" action="editmenu.cfm">
		<tr>
			<input type="hidden" name="tab" value="2">
			<INPUT type="hidden" value="#OneMenu.MenuID#" name="MenuID">
			<td bgcolor="#tbclr#" align="right">Title</td>
			<td bgcolor="#tdclr#"><INPUT type="text" name="title" value="#OneMenu.Title#"></td>
			<input type="hidden" name="Title_Required" value="Please enter the menu title.">
		</tr>
		<tr>
			<td bgcolor="#tbclr#" align="right">CFM Page</td>
			<td bgcolor="#tdclr#"><INPUT type="text" name="dbmname" value="#OneMenu.DbmName#"></td>			
			<input type="hidden" name="DbmName_Required" value="Please enter the cfm page.">
		</tr>
		<tr bgcolor="#tdclr#">
			<td bgcolor="#tbclr#" align="right">Menu Level</td>
	</cfoutput>			
			<td><select name="menu">
				<cfoutput query="AllLevels">
					<option <cfif LevelID is OneMenu.Menu>selected</cfif> value=#LevelID#>#LevelName#
				</cfoutput>
			</select></td>
		</tr>
		<tr>
			<cfif MenuID Is 0>
				<th colspan=2><INPUT type="image" name="AddMenu" src="images/enter.gif" border="0"></th>
			<cfelse>
				<th colspan=2><INPUT type="image" name="UpMenu" src="images/edit.gif" border="0"></th>
			</cfif>
		</tr>
<cfelseif tab Is 3>
	<cfoutput>
	<tr>
		<th colspan="3">
			<table border="1">
				<tr>
					<form method="post" action="editmenu.cfm">
						<input type="hidden" name="MenuID" value="#OneMenu.MenuID#">
						<td bgcolor=<cfif tab Is 2>"#tbclr#"<cfelse>"#tdclr#"</cfif> ><input type="radio" <cfif tab Is 2>checked</cfif> name="tab" value="2" onclick="submit()" id="tab2"><label for="tab2">General</label></td>
						<td bgcolor=<cfif tab Is 3>"#tbclr#"<cfelse>"#tdclr#"</cfif> ><input type="radio" <cfif tab Is 3>checked</cfif> name="tab" value="3" onclick="submit()" id="tab3"><label for="tab3">Staff</label></td>
					</form>
				</tr>
			</table>
		</th>
	</tr>
	<tr bgcolor="#thclr#">
		<th>Available Staff</th>
		<th>Action</th>
		<th>Menu Available To</th>
	</tr>
	<tr bgcolor="#tdclr#">
		<form method="post" action="editmenu.cfm">
		<input type="hidden" name="tab" value="#tab#">
		<input type="hidden" name="MenuID" value="#MenuID#">
	</cfoutput>
			<td><select multiple size="6" name="WantIt">
				<cfoutput query="GetWhoWants">
					<option value="#AdminID#">#LastName#, #FirstName#
				</cfoutput>
				<option value="0">______________________________
			</select></td>
			<td align="center" valign="middle"><input type="submit" name="MvRt" value="---->"><br>
				<input type="submit" name="MvLt" value="<----"><br></td>
			<td><select multiple size="6" name="HaveIt">
				<cfoutput query="GetWhoHas">
					<option value="#AdminID#">#LastName#, #FirstName#
				</cfoutput>
				<option value="0">______________________________
			</select></td>
		</form>
	</tr>
</cfif>

</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>







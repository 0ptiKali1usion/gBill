<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This is the main menu page.
It is called from just about every cfm there is. --->
<!---	4.0.0 07/02/99 
		3.2.1 09/09/98 Changed default colors and Margins.
		3.2.0 09/08/98 --->
<!--- admin.cfm --->

<cfif IsDefined("AcknowledgeRead")>
	<cfquery name="UpdData" datasource="#pds#">
		UPDATE StaffMessageResult SET 
		AckReadYN = 1 
		WHERE AdminID = #MyAdminID# 
		AND MessageID = #MessageID# 
	</cfquery>
</cfif>
<cfif Not IsDefined("Cookie.MyAdminID")>
	<CFINCLUDE TEMPLATE="chklogin.cfm">
	<cfquery name="getsess" datasource="#pds#">
		SELECT frames 
		FROM Admin 
		WHERE AccountID = #cklg.AccountID#
	</cfquery>	
</cfif>
<cfinclude template="license.cfm">
<cfif IsDefined("greensoft") is "No">
	<cfinclude template="index.cfm">
	<cfabort>
</cfif>
<cfset dateval = DateCompare(expdate,Now() )>
<cfset diff1 = datediff("d",Now(),expdate)>
<cfif IsDefined("Http_Referer")>
	<cfif Http_Referer Contains "index.cfm">
		<cfquery name="GetOpts" datasource="#pds#">
			SELECT * 
			FROM Admin 
			WHERE AdminID = #MyAdminID# 
		</cfquery>
	</cfif>
</cfif>
<cfquery name="AllMessages" datasource="#pds#">
	SELECT M.Message, M.DisplayCode, M.MessageID 
	FROM StaffMessages M, StaffMessageResult S 
	WHERE M.MessageID = S.MessageID 
	AND M.ActiveYN = 1 
	AND M.StartDate < #Now()# 
	AND M.ExpireDate > #Now()# 
	AND S.AdminID = #MyAdminID#
	AND (
		  (S.AckReadYN <> 1 AND M.DisplayCode = 2) 
			OR
		  (S.DateRead Is Null AND M.DisplayCode = 1) 
		   OR
		  (M.StartDate < #Now()# AND M.ExpireDate > #Now()# AND M.DisplayCode = 3)
		 )
</cfquery>

<cfsetting enablecfoutputonly="no">
<!--- Frames Style --->
<cfif GetOpts.frames is 1>
	<cfquery name="Check1" datasource="#pds#">
		SELECT Distinct M.Menu 
		FROM Connect C, MenuItems M, Levels L 
		WHERE C.AdminID = #MyAdminID# 
		AND C.MenuID = M.MenuID 
		AND M.Menu = L.LevelID 
		AND M.MenuID Not In 
			(SELECT M.MenuID 
			 FROM Connect C, MenuItems M, Levels L, AdmSort A 
	 		 WHERE C.AdminID = #MyAdminID# 
			 AND C.MenuID = M.MenuID 
			 AND M.Menu = L.LevelID 
		 	 AND A.LevelID = L.LevelID 
			 AND A.AdminID = #MyAdminID# 
			)
	</cfquery>
	<cfif Check1.Recordcount gt 0>
		<!--- Insert Into SortAdm --->
		<cfquery name="GetLastSort" datasource="#pds#">
			SELECT Max(SortOrder) as MO 
			FROM AdmSort 
			WHERE AdminID = #MyAdminID# 
		</cfquery>
		<cfif GetLastSort.MO Is "">
			<cfset NewSort = 1>
		<cfelse>
			<cfset NewSort = GetLastSort.MO + 1>
		</cfif>
		<cfloop index="B5" list="#Check1.Menu#">
			<cfquery name="InsData" datasource="#pds#">
				INSERT INTO AdmSort (AdminID, LevelID, SortOrder) 
				VALUES (#MyAdminID#, #B5#, #NewSort#)
			</cfquery>
			<cfset NewSort = NewSort + 1>
		</cfloop>
	</cfif>
	<cfset thepage = GetOpts.openpage>
	<cfif Trim(thepage) is "">
		<cfset thepage = "adminopt.cfm">
	</cfif>
	<cfquery name="GetWho" datasource="#pds#">
		SELECT FirstName, LastName, Login 
		FROM Accounts 
		WHERE AccountID = 
			(SELECT AccountID 
			 FROM Admin 
			 WHERE AdminID = #MyAdminID#)
	</cfquery>
	<cfoutput>
		<cfsetting enablecfoutputonly="no">
		<html>
		<head>
		<title>gBill For #GetWho.FirstName# #GetWho.LastName#</TITLE>
		<cfinclude template="coolsheet.cfm">
		</head>
		<frameset cols="210,*" BORDERCOLOR="#color1#" frameborder="No" framespacing="0" border="0">
			<frame name="Selector" src="Tree.cfm" marginwidth="2" marginheight="2" scrolling="No" noresize>
			<frame name="Main1" src="#thepage#" marginwidth="10" marginheight="10" scrolling="0">
		</frameset>	
	</cfoutput>	
	<cfsetting enablecfoutputonly="no">	
<!--- Classic Style --->
<cfelseif (GetOpts.frames is 0) OR (GetOpts.frames is "")>
	<cfsetting enablecfoutputonly="yes">
	<cfset thepage = GetOpts.openpage>
	<cfif Trim(thepage) is "">
		<cfset thepage = "admin.cfm">
	</cfif>
	<cfif IsDefined("Http_referer")>
		<cfif (Http_referer Contains "Index.cfm") AND (thepage Is Not "admin.cfm")>
			<cfsetting enablecfoutputonly="no">
			<cfif thepage Is "0">
				<cfset thepage = "account.cfm">
			</cfif>
			<cfinclude template="#thepage#">
			<cfabort>
		</cfif>
	</cfif>
	<cfquery name="Check1" datasource="#pds#">
		SELECT Distinct M.Menu 
		FROM Connect C, MenuItems M, Levels L 
		WHERE C.AdminID = #MyAdminID# 
		AND C.MenuID = M.MenuID 
		AND M.Menu = L.LevelID 
		AND M.MenuID Not In 
			(SELECT M.MenuID 
			 FROM Connect C, MenuItems M, Levels L, AdmSort A 
	 		 WHERE C.AdminID = #MyAdminID# 
			 AND C.MenuID = M.MenuID 
			 AND M.Menu = L.LevelID 
		 	 AND A.LevelID = L.LevelID 
			 AND A.AdminID = #MyAdminID# 
			)
	</cfquery>
	<cfif Check1.Recordcount gt 0>
		<!--- Insert Into SortAdm --->
		<cfquery name="GetLastSort" datasource="#pds#">
			SELECT Max(SortOrder) as MO 
			FROM AdmSort 
			WHERE AdminID = #MyAdminID# 
		</cfquery>
		<cfif GetLastSort.MO Is "">
			<cfset NewSort = 1>
		<cfelse>
			<cfset NewSort = GetLastSort.MO + 1>
		</cfif>
		<cfloop index="B5" list="#Check1.Menu#">
			<cfquery name="InsData" datasource="#pds#">
				INSERT INTO AdmSort (AdminID, LevelID, SortOrder) 
				VALUES (#MyAdminID#, #B5#, #NewSort#)
			</cfquery>
			<cfset NewSort = NewSort + 1>
		</cfloop>
	</cfif>
	<cfquery name="Menus" datasource="#PDS#">
		SELECT A.SortOrder, L.LevelName, U.FirstName, U.LastName, M.Title, M.dbmName 
		FROM AdmSort A, Levels L, MenuItems M, Connect C, Admin S, Accounts U 
		WHERE A.LevelID = L.LevelID 
		AND L.LevelID = M.Menu 
		AND M.MenuID = C.MenuID 
		AND C.AdminID = S.AdminID 
		AND S.AccountID = U.AccountID 
		AND S.AdminID = #MyAdminID# 
		AND A.AdminID = #MyAdminID# 
		<cfif GetOpts.SUserYN Is 0>
			AND M.ActiveYN = 1 
		</cfif>
		ORDER BY A.SortOrder, M.title 
	</cfquery>
	<cfquery name="MenuCheck" datasource="#pds#">
		SELECT L.Sort as SortOrder, L.LevelName, U.FirstName, U.LastName, M.Title, M.dbmName 
		FROM Levels L, MenuItems M, Connect C, Admin S, Accounts U 
		WHERE L.LevelID = M.Menu 
		AND M.MenuID = C.MenuID 
		AND C.AdminID = S.AdminID 
		AND S.AccountID = U.AccountID 
		AND S.AdminID = #MyAdminID# 
		<cfif GetOpts.SUserYN Is 0>
			AND M.ActiveYN = 1 
		</cfif>
		ORDER BY L.Sort, M.title 
	</cfquery>
	<cfif Menus.RecordCount Is 0>
		<cfquery name="Menus" datasource="#PDS#">
			SELECT L.Sort as SortOrder, L.LevelName, U.FirstName, U.LastName, M.Title, M.dbmName 
			FROM Levels L, MenuItems M, Connect C, Admin S, Accounts U 
			WHERE L.LevelID = M.Menu 
			AND M.MenuID = C.MenuID 
			AND C.AdminID = S.AdminID 
			AND S.AccountID = U.AccountID 
			AND S.AdminID = #MyAdminID# 
			<cfif GetOpts.SUserYN Is 0>
				AND M.ActiveYN = 1 
			</cfif>
			ORDER BY L.Sort, M.title 
		</cfquery>
	</cfif>
	<cfsetting enablecfoutputonly="no">
	<cfoutput>
	<html>
	<head>
	<title>gBill for #Menus.FirstName# #Menus.LastName#</TITLE>
	</cfoutput>
	<cfinclude template="coolsheet.cfm">
	<cfoutput>
	</head>
	<body #colorset# onLoad="if (self != top) top.location = self.location">
	</cfoutput>
	<cfinclude template="header.cfm">
	<br><br>
	<cfif diff1 lt expdays>
		<cfinclude template="warning.cfm">
	</cfif>
		<center>
		<cfif AllMessages.Recordcount GT 0>
			<cfoutput>
			<table border="#tblwidth#" bgcolor="#tbclr#">
			</cfoutput>
				<cfoutput query="AllMessages">
					<tr>	
						<td colspan="2">#Message#</td>
						<cfif DisplayCode Is 2>
							</tr>
							<tr>
							<form method="post" action="admin.cfm">
								<td>Click Yes to acknowledge reading this announcement.</td>
								<td><input type="submit" name="AcknowledgeRead" value="Yes"></td>
								<input type="hidden" name="MessageID" value="#MessageID#">
							</form>
						</cfif>
					</tr>
					<cfquery name="UpdDate" datasource="#pds#">
						UPDATE StaffMessageResult SET 
						DateRead = #CreateODBCDateTime(Now())# 
						WHERE MessageID = #MessageID# 
						AND AdminID = #MyAdminID# 
					</cfquery>
				</cfoutput>
			</table>
		</cfif>
	<cfoutput>
		<table border=#tblwidth#>
			<tr>
				<th colspan="3" bgcolor="#ttclr#"><font color="#ttfont#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> size="#ttsize#">Main Menu for #Menus.FirstName# #Menus.LastName#</font></th>
			</tr>
	</cfoutput>
			<cfset counter = 0>
			<cfoutput query="menus" group="sortorder">
				<tr bgcolor="#thclr#">
					<th colspan=3 bgcolor="#thclr#">#levelname#</th>
				</tr>
   			<cfoutput>
					<cfif counter is 0><tr></cfif>
					<cfset counter = counter + 1>
					<td bgcolor="#tbclr#" nowrap><a href="#dbmname#">#Title#</a></td>
					<cfif counter is 3></tr><cfset counter = 0></cfif>
				</cfoutput>
				<cfif counter is 2><td bgcolor="#tbclr#">&nbsp;</td></tr><cfset counter = 0></cfif>
				<cfif counter is 1><td bgcolor="#tbclr#">&nbsp;</td>
				<td bgcolor="#tbclr#">&nbsp;</td></tr><cfset counter = 0></cfif>
			</cfoutput>
	<cfoutput>
		</table>
	</center>
	</cfoutput>
	<cfinclude template="footer.cfm">
	</body>
	</html>
<!--- Tabs Style --->
<cfelseif GetOpts.frames is 2>
	<cfset level1 = GetOpts.openpage>
   <cfif level1 is 0>
	   <cfquery name="getremember" datasource="#pds#">
		   SELECT HelpUse 
			FROM Admin 
			WHERE AdminID = #MyAdminID#
   	</cfquery>
	   <cfset level1 = getremember.helpuse>
   </cfif>
   <cfif level1 is "">
	   <cfset level1 = 1>
   <cfelseif IsDefined("url.level1")>
   	<cfquery name="setremember" datasource="#pds#">
      	UPDATE admin 
			SET helpuse = #url.level1# 
	 		WHERE adminid = #MyAdminID# 
	  	</cfquery>
   	<cfset level1 = url.level1>
   </cfif>
	<cfquery name="Check1" datasource="#pds#">
		SELECT Distinct M.Menu 
		FROM Connect C, MenuItems M, Levels L 
		WHERE C.AdminID = #MyAdminID# 
		AND C.MenuID = M.MenuID 
		AND M.Menu = L.LevelID 
		AND M.MenuID Not In 
			(SELECT M.MenuID 
			 FROM Connect C, MenuItems M, Levels L, AdmSort A 
	 		 WHERE C.AdminID = #MyAdminID# 
			 AND C.MenuID = M.MenuID 
			 AND M.Menu = L.LevelID 
		 	 AND A.LevelID = L.LevelID 
			 AND A.AdminID = #MyAdminID# 
			)
	</cfquery>
	<cfif Check1.Recordcount gt 0>
		<!--- Insert Into SortAdm --->
		<cfquery name="GetLastSort" datasource="#pds#">
			SELECT Max(SortOrder) as MO 
			FROM AdmSort 
			WHERE AdminID = #MyAdminID# 
		</cfquery>
		<cfif GetLastSort.MO Is "">
			<cfset NewSort = 1>
		<cfelse>
			<cfset NewSort = GetLastSort.MO + 1>
		</cfif>
		<cfloop index="B5" list="#Check1.Menu#">
			<cfquery name="InsData" datasource="#pds#">
				INSERT INTO AdmSort (AdminID, LevelID, SortOrder) 
				VALUES (#MyAdminID#, #B5#, #NewSort#)
			</cfquery>
			<cfset NewSort = NewSort + 1>
		</cfloop>
	</cfif>
	<cfquery name="Menus" datasource="#PDS#">
		SELECT L.LevelID 
		FROM Levels L, MenuItems M, Connect C 
		WHERE L.LevelID = M.Menu 
		AND M.MenuId = C.MenuID 
		AND M.Menu = L.LevelID 
		AND M.ActiveYN = 1
		AND C.AdminID = #MyAdminID# 
		GROUP BY L.LevelID 
	</cfquery>
	<cfquery name="menuheaders" datasource="#pds#">
		SELECT A.SortOrder, L.sort, L.LevelID, L.levelname 
		FROM (AdmSort A Left Join Levels L 
		ON A.LevelID = L.LevelID), MenuItems M, Connect C, 
		Admin S, Accounts U
		WHERE L.LevelID = M.Menu 
		AND M.MenuID = C.MenuID 
		AND C.AdminID = S.AdminID 
		AND S.AccountID = U.AccountID 
		AND S.AdminID = #MyAdminID# 
		AND A.AdminID = #MyAdminID# 
		AND M.ActiveYN = 1 
		GROUP BY A.SortOrder, L.sort, L.LevelID, L.levelname 
		ORDER BY A.SortOrder, L.sort 
	</cfquery>
	<cfquery name="selectedlevel" datasource="#pds#">
		SELECT levelname 
		FROM levels 
		WHERE levelid = #level1#
	</cfquery>

<CFQUERY NAME="GetAdmInfo" DATASOURCE="#PDS#">
	SELECT * 
	FROM ACCOUNTS 
	WHERE AccountID = 
		(SELECT AccountID 
		 FROM Admin 
		 WHERE AdminID = #MyAdminID#)
</cfquery>
<cfquery name="mymenus" datasource="#pds#">
	SELECT menuitems.*
	FROM admin, connect, menuitems 
	WHERE admin.adminid = connect.adminid 
	AND connect.menuid = menuitems.menuid 
	AND admin.adminid = #MyAdminID# 
	AND menu = #level1# 
	ORDER BY title
</cfquery>
<cfsetting enablecfoutputonly="no">
<cfoutput>
<html>
<head>
<title>gBill for #GetAdmInfo.firstname# #GetAdmInfo.lastname#</TITLE>
</cfoutput>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput>
<body #colorset# onLoad="if (self != top) top.location = self.location">
</cfoutput>
<cfinclude template="header.cfm">
<br><br>
<center>
		<cfif AllMessages.Recordcount GT 0>
			<cfoutput>
			<table border="#tblwidth#" bgcolor="#tbclr#">
			</cfoutput>
				<cfoutput query="AllMessages">
					<tr>	
						<td colspan="2"><pre>#Message#</pre></td>
						<cfif DisplayCode Is 2>
							</tr>
							<tr>
							<form method="post" action="admin.cfm">
								<td>Click Yes to acknowledge reading this announcement.</td>
								<td><input type="submit" name="AcknowledgeRead" value="Yes"></td>
								<input type="hidden" name="MessageID" value="#MessageID#">
							</form>
						</cfif>
					</tr>
					<cfquery name="UpdDate" datasource="#pds#">
						UPDATE StaffMessageResult SET 
						DateRead = #CreateODBCDateTime(Now())# 
						WHERE MessageID = #MessageID# 
						AND AdminID = #MyAdminID# 
					</cfquery>
				</cfoutput>
			</table>
		</cfif>
<cfoutput>
   <cfif diff1 lt expdays>
		<table border="#tblwidth#">
			<tr>
				<td bgcolor="#tbclr#">This copy of gBill expires on #expdate#.</font><br>
				Please contact GreenSoft Solutions, Inc. to obtain a newer license.</td>
			</tr>
		</table>
   </cfif>
	<table border="0">
		<tr>
			<td>
				<table border="#tblwidth#" width="100%">
					<tr>
						<th bgcolor="#ttclr#" colspan="3"><font color="#ttfont#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> size="#ttsize#">Main Menu for #GetAdmInfo.firstname# #GetAdmInfo.lastname#</font></th>
					</tr>
</cfoutput>
					<cfset counter = 1>
					<cfoutput query="menuheaders">
						<cfif counter is 1><tr></cfif>
						<th bgcolor=<cfif level1 Is LevelID>"#tbclr#"<cfelse>"#tdclr#"</cfif> ><a href="admin.cfm?level1=#levelid#">#levelname#</a></th>
						<cfif counter is 3></tr><cfset counter = 0></cfif>
						<cfset counter = counter + 1>
					</cfoutput>
					<cfoutput>
						<cfif counter is 3><td bgcolor="#tdclr#"> </td></tr><cfset counter = 0></cfif>
						<cfif counter is 2><td bgcolor="#tdclr#"> </td><td bgcolor="#tdclr#"> </td></tr><cfset counter = 0></cfif>
					</cfoutput>
				</table>
			</td>
		</tr>
		<tr>
			<td>
				<cfoutput>
					<table border="#tblwidth#" width="100%">
						<tr>
							<th colspan="3" bgcolor="#thclr#">#selectedlevel.levelname#</th>
						</tr>		
				</cfoutput>
						<cfset counter = 1>		
						<cfoutput query="mymenus">
							<cfif counter is 1><tr></cfif>
							<th width="33%" bgcolor="#tbclr#" nowrap><a href="#dbmname#">#title#</a></th>
							<cfif counter is 3></tr><cfset counter = 0></cfif>
							<cfset counter = counter + 1>
						</cfoutput>
						<cfoutput>
							<cfif counter is 3><td bgcolor="#tbclr#"> </td></tr><cfset counter = 0></cfif>
							<cfif counter is 2><td bgcolor="#tbclr#"> </td><td bgcolor="#tbclr#"> </td></tr><cfset counter = 0></cfif>
						</cfoutput>
					</table>
			</td>
		</tr>
	</table>
	</center>
	<cfinclude template="footer.cfm">
	</body>
	</html>
</cfif>
 
<cfsetting enablecfoutputonly="yes">
<!-- Version 3.2.0 -->
<!--- This is main menu for the frames interface. --->
<!--- 3.2.0 09/08/98 --->
<!-- tree.cfm -->

<cfquery name="menus1" datasource="#PDS#">
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
<cfif Menus1.RecordCount Is 0>
	<cfquery name="Menus1" datasource="#PDS#">
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
<cfquery name="menus2" datasource="#PDS#">
	SELECT A.SortOrder, L.LevelName 
	FROM AdmSort A, Levels L, MenuItems M, Connect C 
	WHERE M.MenuID = C.MenuID 
	AND M.Menu = L.LevelID 
	AND L.LevelID = A.LevelID 
	<cfif GetOpts.SUserYN Is 0>
		AND M.ActiveYN = 1 
	</cfif>
	AND C.AdminID = #MyAdminID# 
	AND A.AdminID = #MyAdminID# 
	GROUP BY A.SortOrder, L.LevelName 
	ORDER BY A.SortOrder
</cfquery>
<cfif Menus2.RecordCount Is 0>
	<cfquery name="menus2" datasource="#PDS#">
		SELECT L.Sort, L.LevelName 
		FROM Levels L, MenuItems M, Connect C 
		WHERE M.MenuID = C.MenuID 
		AND M.Menu = L.LevelID 
		<cfif GetOpts.SUserYN Is 0>
			AND M.ActiveYN = 1 
		</cfif>
		AND C.AdminID = #MyAdminID# 
		GROUP BY L.Sort, L.LevelName 
		ORDER BY L.Sort
	</cfquery>
</cfif>
<cfsetting enablecfoutputonly="no">
<HTML>
<HEAD>
<TITLE>Menu</TITLE>
<cfinclude template="coolsheet.cfm"></HEAD>
<cfoutput><body #colorset#></cfoutput>
<cfform action="tree.cfm" name="form1">
	<cftree name="menu" border="No" vspace="0" hspace="0" APPENDKEY="No" Bold="Yes" Height="350">
		<cftreeitem Img="element" value="#menus1.firstname# #menus1.lastname#" display="#menus1.firstname# #menus1.lastname#" expand="Yes">
		<cfloop query="menus2">
			<cftreeitem Img="Folder" value="#levelname#" display="#levelname#" expand="No" parent="#menus1.firstname# #menus1.lastname#">
		</cfloop>
		<cfloop query="menus1">
			<cftreeitem Img="Document" value="#dbmname#" target="Main1" display="#title#" parent="#levelname#" href="#dbmname#">
		</cfloop>
	</cftree>
</cfform>

</BODY>
</HTML>




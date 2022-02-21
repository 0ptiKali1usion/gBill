<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page allows setting the admins personal settings.
--->
<!--- 4.0.0 06/01/00 
		3.5.0 07/02/99 New options
		3.2.0 09/08/98 --->
<!--- adminopt.cfm --->
<cfset securepage = "adminopt.cfm">
<cfinclude template="security.cfm">
<cfparam name="tab" default="1">
<cfif IsDefined("MvDn.x")>
	<cfset PrevSort = SortOrder + 1>
	<cfquery name="MoveDown" datasource="#pds#">
		UPDATE AdmSort SET 
		SortOrder = #SortOrder# 
		WHERE AdminID = #AdminID# 
		AND SortOrder = #PrevSort#
	</cfquery>
	<cfquery name="MoveUp" datasource="#pds#">
		UPDATE AdmSort SET 
		SortOrder = #PrevSort# 
		WHERE AdminID = #AdminID# 
		AND LevelID = #LevelID#
	</cfquery>
	<cfquery name="GetAllSorts" datasource="#pds#">
		SELECT * 
		FROM AdmSort 
		WHERE AdminID = #AdminID# 
		ORDER BY SortOrder
	</cfquery>
	<cfloop query="GetAllSorts">
		<cfquery name="ReSort" datasource="#pds#">
			UPDATE AdmSort SET 
			SortOrder = #CurrentRow# 
			WHERE AdminID = #AdminID# 
			AND LevelID = #LevelID#
		</cfquery>
	</cfloop>
</cfif>
<cfif IsDefined("MvUp.x")>
	<cfset PrevSort = SortOrder - 1>
	<cfquery name="MoveDown" datasource="#pds#">
		UPDATE AdmSort SET 
		SortOrder = #SortOrder# 
		WHERE AdminID = #AdminID# 
		AND SortOrder = #PrevSort#
	</cfquery>
	<cfquery name="MoveUp" datasource="#pds#">
		UPDATE AdmSort SET 
		SortOrder = #PrevSort# 
		WHERE AdminID = #AdminID# 
		AND LevelID = #LevelID#
	</cfquery>
	<cfquery name="GetAllSorts" datasource="#pds#">
		SELECT * 
		FROM AdmSort 
		WHERE AdminID = #AdminID# 
		ORDER BY SortOrder
	</cfquery>
	<cfloop query="GetAllSorts">
		<cfquery name="ReSort" datasource="#pds#">
			UPDATE AdmSort SET 
			SortOrder = #CurrentRow# 
			WHERE AdminID = #AdminID# 
			AND LevelID = #LevelID#
		</cfquery>
	</cfloop>
</cfif>
<cfif IsDefined("SetIt.x")>
	<cfquery name="chkcolorset" datasource="#pds#">
		UPDATE admin set color1 = '#form.color1#', 
		color2 = '#form.color2#', color3 = '#form.color3#', 
		color4 = '#form.color4#', tbclr = '#form.tbclr#',
		tdclr = '#form.tdclr#', thclr = '#form.thclr#', 
		ttclr = '#form.ttclr#', ttfont = '#form.ttfont#' 
		WHERE adminid = #form.adminid#
	</cfquery>
</cfif>
<cfif IsDefined("EditAppear.x")>
	<cfquery name="UpdData" datasource="#pds#">
		UPDATE Admin SET 
		perfontsize = '#perfontsize#', 
		perfontname = '#perfontname#', 
		tblwidth = '#tblwidth#', 
		ttsize = #ttsize#, 
		OpenNew = #OpenNew#, 
		mrow = #mrow# 
		WHERE AdminID = #AdminID#
	</cfquery>
</cfif>
<cfif IsDefined("enterit.x")>
	<cfif selframes Is 0>
		<cfquery name="UpdData" datasource="#pds#">
			UPDATE Admin SET 
			frames = #selframes#, 
			openpage = '#classicopenpage#' 
			WHERE AdminID = #AdminID#
		</cfquery>
	<cfelseif selframes Is 1>
		<cfquery name="UpdData" datasource="#pds#">
			UPDATE Admin SET 
			frames = #selframes#, 
			openpage = '#frameopenpage#' 
			WHERE AdminID = #AdminID#
		</cfquery>
	<cfelseif selframes Is 2>
		<cfquery name="UpdData" datasource="#pds#">
			UPDATE Admin SET 
			frames = #selframes#, 
			openpage = '#tabopenpage#' 
			WHERE AdminID = #AdminID#
		</cfquery>
	</cfif>
	<cflocation addtoken="no" url="admin.cfm">
</cfif>

<cfquery name="GetOpts" datasource="#pds#">
	SELECT A.*, C.AccountID, C.FirstName, C.LastName 
	FROM Admin A, Accounts C 
	Where C.AccountID = A.AccountID 
	AND A.AdminID = #Cookie.MyAdminID# 
</cfquery>
<cfif tab Is 1>
	<cfset HowWide = 3>
	<cfquery name="MenuItems" datasource="#PDS#">
		SELECT M.Title, M.dbmname 
		FROM MenuItems M, Connect C 
		WHERE M.MenuID = C.MenuID 
		AND C.AdminID = #GetOpts.AdminID# 
		AND M.DBMName <> 'killc.cfm' 
		ORDER BY M.Title
	</cfquery>
	<cfquery name="Levels" datasource="#pds#">
		SELECT * 
		FROM Levels 
		WHERE LevelID In 
			(SELECT L.LevelID 
			 FROM Levels L, MenuItems M, Connect C 
			 WHERE M.MenuID = C.MenuID 
			 AND L.Sort = M.Menu 
			 AND C.AdminID = #GetOpts.AdminID# 
			 AND M.DBMName <> 'killc.cfm' 
			)
		ORDER BY LevelName 
	</cfquery>
<cfelseif tab Is 2>
	<cfset HowWide = 3>
<cfelseif tab Is 3>
	<cfset HowWide = 2>
	<cfquery name="GetPerLevels" datasource="#pds#">
		SELECT Levels.*, AdmSort.SortOrder 
		FROM AdmSort, Levels 
		WHERE AdmSort.LevelID = Levels.LevelID 
		AND AdminID = #MyAdminID# 
		ORDER BY SortOrder
	</cfquery>
	<cfquery name="GetLevels" datasource="#pds#">
		SELECT L.LevelID, L.Sort 
		FROM Levels L, MenuItems M, Connect C 
		WHERE L.LevelID = M.Menu 
		AND M.MenuID = C.MenuID 
		AND C.AdminID = #MyAdminID#
		GROUP BY L.LevelID, L.Sort  
		ORDER BY L.Sort
	</cfquery>
	<cfif GetPerLevels.RecordCount Is GetLevels.RecordCount>
		<cfquery name="MaxSort" datasource="#pds#">
			SELECT Max(SortOrder) as MSO 
			FROM AdmSort 
			WHERE AdminID = #MyAdminID#
		</cfquery>
		<cfif MaxSort.MSO Is Not GetPerLevels.RecordCount>
			<cfset Count1 = 1>
			<cfloop query="GetPerLevels">
				<cfquery name="UpdSort" datasource="#pds#">
					UPDATE AdmSort SET 
					SortOrder = #Count1# 
					WHERE AdminID = #MyAdminID# 
					AND LevelID = #LevelID#
				</cfquery>
				<cfset Count1 = Count1 + 1>
			</cfloop>
		</cfif>
	<cfelse>
		<cfquery name="RemoveOld" datasource="#pds#">
			DELETE FROM AdmSort 
			WHERE AdminID = #MyAdminID# 
			AND LevelID Not In 
				(SELECT LevelID 
				 FROM Levels L, MenuItems M, Connect C 
				 WHERE L.LevelID = M.Menu 
				 AND M.MenuID = C.MenuID 
				 AND C.AdminID = #MyAdminID#
				 )
		</cfquery>
		<cfquery name="GetNew" datasource="#pds#">
			SELECT L.LevelID, L.Sort 
			FROM Levels L, MenuItems M, Connect C 
			WHERE L.LevelID = M.Menu 
			AND M.MenuID = C.MenuID 
			AND C.AdminID = #MyAdminID#
			AND L.LevelID Not In 
				(SELECT LevelID 
				 FROM AdmSort 
				 WHERE AdminID = #MyAdminID# 
				)
			GROUP BY L.LevelID, L.Sort  
			ORDER BY L.Sort
		</cfquery>
		<cfquery name="MaxSort" datasource="#pds#">
			SELECT Max(SortOrder) as MSO 
			FROM AdmSort 
			WHERE AdminID = #MyAdminID#
		</cfquery>
		<cfset TheSort = MaxSort.MSO>
		<cfif Trim(TheSort) Is "">
			<cfset TheSort = 1>
		</cfif>
		<cfloop query="GetNew">
			<cfquery name="AddNew" datasource="#pds#">
				INSERT INTO AdmSort 
				(AdminID,LevelID,SortOrder)
				VALUES 
				(#MyAdminID#,#LevelID#,#TheSort#)
			</cfquery>
			<cfset TheSort = TheSort + 1>
		</cfloop>
		<cfquery name="GetPerLevels" datasource="#pds#">
			SELECT Levels.*, AdmSort.SortOrder 
			FROM AdmSort, Levels 
			WHERE AdmSort.LevelID = Levels.LevelID 
			AND AdminID = #MyAdminID# 
			ORDER BY SortOrder
		</cfquery>
	</cfif>
<cfelseif tab Is 4>
	<cfset HowWide = 2>
</cfif>

<cfsetting enablecfoutputonly="no">
<HTML>
<HEAD>
<TITLE>Personal Settings</TITLE>
<cfinclude template="coolsheet.cfm">
</HEAD>
<cfoutput>
<BODY #colorset#>
</cfoutput>
<cfinclude template="header.cfm">
<center>
	<cfoutput>
	<table border="#tblwidth#">
		<tr valign="top">
			<th bgcolor="#ttclr#" colspan="#HowWide#"><font color="#ttfont#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> size="#ttsize#">Personal Settings</font></th>
		</tr>
		<tr>
			<th colspan="#HowWide#">
				<table border="1">
					<tr>
						<form method="post" action="adminopt.cfm">
							<td bgcolor=<cfif tab Is 1>"#tbclr#"<cfelse>"#tdclr#"</cfif> ><input type="radio" <cfif tab Is "1">checked</cfif> name="tab" value="1" onclick="submit()" id="tab1"><label for="tab1">Menu Style</label></td>
							<td bgcolor=<cfif tab Is 4>"#tbclr#"<cfelse>"#tdclr#"</cfif> ><input type="radio" <cfif tab Is "4">checked</cfif> name="tab" value="4" onclick="submit()" id="tab4"><label for="tab1">Page Appearance</label></td>
							<td bgcolor=<cfif tab Is 2>"#tbclr#"<cfelse>"#tdclr#"</cfif> ><input type="radio" <cfif tab Is "2">checked</cfif> name="tab" value="2" onclick="submit()" id="tab2"><label for="tab1">Colors</label></td>
							<td bgcolor=<cfif tab Is 3>"#tbclr#"<cfelse>"#tdclr#"</cfif> ><input type="radio" <cfif tab Is "3">checked</cfif> name="tab" value="3" onclick="submit()" id="tab3"><label for="tab1">Sort Order</label></td>
						</form>
					</tr>
				</table>
			</th>
		</tr>
	</cfoutput>
<cfif tab is "1">
	<cfoutput>
		<form action="adminopt.cfm" name="editopt" method="post" target="_top">
			<input type="hidden" name="adminid" value="#getopts.adminid#">
			<input type="hidden" name="tab" value="#tab#">
			<tr>
				<th bgcolor="#thclr#" colspan="3">Main Menu Style</th>
			</tr>
			<tr bgcolor="#tdclr#">
				<td><input <cfif getopts.frames is "0">checked</cfif> type="radio" name="selframes" value="0"> Classic Menu Style</td>
				<td bgcolor="#tbclr#" align="right">Start Page</td>
	</cfoutput>
				<td><select name="classicopenpage">
					<option value="admin.cfm">Main Menu
					<cfoutput query="MenuItems">
						<option <cfif (dbmname is getopts.openpage) AND (getopts.frames Is 0)>selected</cfif> value="#dbmname#">#title#
					</cfoutput>
				</select></td>
			</tr>
		<cfoutput>
			<tr bgcolor="#tdclr#">
				<td><input <cfif getopts.frames is "1">checked</cfif> type="radio" name="selframes" value="1"> Frames Style</td>
				<td bgcolor="#tbclr#" align="right">Start Page</td>
		</cfoutput>
				<td><select name="frameopenpage">
					<option value="adminopt.cfm">N/A
					<cfoutput query="MenuItems">
						<option <cfif (dbmname is getopts.openpage) AND (getopts.frames Is 1)>selected</cfif> value="#dbmname#">#title#
					</cfoutput>
				</select></td>
			</tr>
			<cfoutput>
			<tr bgcolor="#tdclr#">
				<td><input <cfif getopts.frames is "2">checked</cfif> type="radio" name="selframes" value="2"> Tabs Style</td>
				<td bgcolor="#tbclr#" align="right">Default Tab</td>
			</cfoutput>
				<td><select name="tabopenpage">
					<option value="0">N/A
					<option <cfif getopts.openpage is 0>selected</cfif> value="0">Remember Last Used
					<cfoutput query="Levels">
						<option <cfif levelid is getopts.openpage>selected</cfif> value="#LevelID#">#LevelName#
					</cfoutput> 
				</select></td>
			</tr>
			<tr>
				<th colspan=3><INPUT type="image" name="enterit" src="images/update.gif" border="0"></th>
			</tr>
		</form>
<cfelseif tab is "2">
	<cfoutput>
		<tr>
			<th colspan="3" bgcolor="#thclr#">Color Settings</th>
		</tr>
		<form method="post" action="optcolor.cfm">
			<input type="hidden" name="adminid" value="#getopts.adminid#">
			<input type="hidden" name="tab" value="#tab#">
			<tr>	
				<td align="right" bgcolor="#tbclr#">Background</td>
				<td bgcolor="#color1#">&nbsp;</td>
				<td bgcolor="#tdclr#"><INPUT type="text" name="color1" value="#color1#"></td>
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">Visited Link</td>
				<td bgcolor="#color2#">&nbsp;&nbsp;</td>
				<td bgcolor="#tdclr#"><INPUT type="text" name="color2" value="#color2#"></td>
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">Link</td>
				<td bgcolor="#color4#">&nbsp;</td>
				<td bgcolor="#tdclr#"><INPUT type="text" name="color4" value="#color4#"></td>
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">Text Color</td>
				<td bgcolor="#color3#">&nbsp;</td>
				<td bgcolor="#tdclr#"><INPUT type="text" name="color3" value="#color3#"></td>
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">Text Background Color</td>
				<td bgcolor="#tbclr#">&nbsp;</td>
				<td bgcolor="#tdclr#"><INPUT type="text" name="tbclr" value="#tbclr#"></td>
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">Data Background Color</td>
				<td bgcolor="#tdclr#">&nbsp;</td>
				<td bgcolor="#tdclr#"><INPUT type="text" name="tdclr" value="#tdclr#"></td>
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">Header Background Color</td>
				<td bgcolor="#thclr#">&nbsp;</td>
				<td bgcolor="#tdclr#"><INPUT type="text" name="thclr" value="#thclr#"></td>
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">Title Bar Color</td>
				<td bgcolor="#ttclr#">&nbsp;</td>
				<td bgcolor="#tdclr#"><INPUT type="text" name="ttclr" value="#ttclr#"></td>
			</tr>
			<tr>
				<td align="right" bgcolor="#tbclr#">Title Bar Text Color</td>
				<td bgcolor="#ttfont#">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
				<td bgcolor="#tdclr#"><INPUT type="text" name="ttfont" value="#ttfont#"></td>
			</tr>
			<tr>
				<th colspan=3><input type="image" src="images/preview.gif" border="0"></th>
			</tr>
		</form>
	</cfoutput>
<cfelseif tab Is 3>
	<cfset Count1 = 0>
	<cfoutput query="GetPerLevels">
		<cfset Count1 = Count1 + 1>
		<Form method="post" action="adminopt.cfm">
			<input type="hidden" name="AdminID" value="#getopts.AdminID#">
			<input type="hidden" name="LevelID" value="#LevelID#">
			<input type="hidden" name="tab" value="#tab#">
			<input type="hidden" name="SortOrder" value="#SortOrder#">
			<tr>
				<td bgcolor="#tbclr#" align="right">#Levelname#</td>
				<cfif Count1 Is 1>
					<td bgcolor="#tdclr#"><img src="images/buttonhide.gif" border="0"><input type="image" src="images/buttong.gif" name="MvDn" border="0"></td>
				<cfelseif Count1 Is GetPerLevels.RecordCount>
					<td nowrap bgcolor="#tdclr#"><input type="image" src="images/buttonf.gif" name="MvUp" border="0"></td>
				<cfelse>
					<td bgcolor="#tdclr#"><input type="image" src="images/buttonf.gif" name="MvUp" border="0"><input type="image" src="images/buttong.gif" name="MvDn" border="0"></td>
				</cfif>
			</tr>
		</form>
</cfoutput>
<cfelseif tab Is 4>
	<cfoutput>
	<form action="adminopt.cfm" name="editopt" method="post">
		<input type="hidden" name="adminid" value="#getopts.adminid#">
		<input type="hidden" name="tab" value="#tab#">
		<tr>
			<th bgcolor="#thclr#" colspan="2">Page Style</th>
		</tr>
		<tr>
			<td bgcolor="#tbclr#" align="right">Font name</td>
			<td bgcolor="#tdclr#"><SELECT name="PerFontName">
				<option <cfif getopts.PerFontName is "NA">selected</cfif> value="NA">No style sheet
				<option <cfif getopts.PerFontName is "Arial">selected</cfif> value="Arial">Arial
				<option <cfif getopts.PerFontName is "Braggadocio">selected</cfif> value="Braggadocio">Braggadocio
				<option <cfif getopts.PerFontName is "Cursive">selected</cfif> value="Cursive">Cursive
				<option <cfif getopts.PerFontName is "Courier New">selected</cfif> value="Courier New">Courier New
				<option <cfif getopts.PerFontName is "Modern">selected</cfif> value="Modern">Modern
				<option <cfif getopts.PerFontName is "Monospace">selected</cfif> value="Monospace">Monospace
				<option <cfif getopts.PerFontName is "MS Sans Serif">selected</cfif> value="MS Sans Serif">MS Sans Serif
				<option <cfif getopts.PerFontName is "Serif">selected</cfif> value="Serif">Serif
				<option <cfif getopts.PerFontName is "Times New Roman">selected</cfif> value="Times New Roman">Times New Roman
			</SELECT></td>
		</tr>
		<tr>
			<td bgcolor="#tbclr#" align="right">Font size</td>
			<td bgcolor="#tdclr#"><SELECT name="PerFontSize">
				<option <cfif getopts.PerFontSize is "NA">selected</cfif> value="NA">No style sheet
				<option <cfif getopts.PerFontSize is "x-small">selected</cfif> value="x-small">x-small
				<option <cfif getopts.PerFontSize is "small">selected</cfif> value="small">small
				<option <cfif getopts.PerFontSize is "medium">selected</cfif> value="medium">medium
				<option <cfif getopts.PerFontSize is "large">selected</cfif> value="large">large
			</SELECT></td>
		</tr>
		<tr>
			<td bgcolor="#tbclr#" align="right">Table Borders</td>
			<td bgcolor="#tdclr#"><select name="tblwidth">
	</cfoutput>
				<cfloop index="B5" From="0" To="10">
					<cfoutput><option <cfif getopts.tblwidth Is B5>Selected</cfif> value="#B5#">#B5#</cfoutput>
				</cfloop>
			</select></td>
		</tr>
	<cfoutput>
		<tr bgcolor="#tdclr#">
			<td align="right" bgcolor="#tbclr#">Title Bar Text Size</td>
	</cfoutput>
			<td><select name="ttsize">
				<cfloop index="B5" from="1" to="7">
					<cfoutput><option <cfif getopts.ttsize Is B5>selected</cfif> value="#B5#">#B5#</cfoutput>
				</cfloop>
			</select></td>
		</tr>	
		<tr>
			<cfoutput>
				<td align="right" bgcolor="#tbclr#">Rows per page on reports</td>
				<td bgcolor="#tdclr#"><input type="text" name="mrow" value="#getopts.mrow#" maxlength="4" size="3"></td>
			</cfoutput>
		</tr>	
		<tr>
			<cfoutput>
				<td align="right" bgcolor="#tbclr#">Open Customer Info in a new window</td>
				<td bgcolor="#tdclr#"><INPUT TYPE="radio" name="OpenNew" <cfif getopts.OpenNew is "1">checked</cfif> value="1">Yes	<INPUT TYPE="radio" name="OpenNew" <cfif getopts.OpenNew is "0">checked</cfif> value="0">No</td>
			</cfoutput>
		</tr>	
		<tr>
			<th colspan=2><INPUT type="image" name="EditAppear" src="images/update.gif" border="0"></th>
		</tr>
	</form>
</cfif>

</table>
</center>
<cfinclude template="footer.cfm">
</BODY>
</HTML>
  
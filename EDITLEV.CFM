<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page edits the Main Menu Section Headers. --->
<!--- 4.0.0 07/02/99 
		3.2.0 09/08/98 --->
<!--- editlev.cfm --->

<cfinclude template="security.cfm"> 
<cfif IsDefined("DelSelected.x")>
	<cfquery name="CleanUp" datasource="#pds#">
		DELETE FROM AdmSort 
		WHERE LevelID In (#DelThese#)
	</cfquery>
	<cfquery name="DelData" datasource="#pds#">
		DELETE FROM Levels 
		WHERE LevelID In (#DelThese#)
	</cfquery>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'Menu Headers','#StaffMemberName.FirstName# #StaffMemberName.LastName# deleted from the menu header list.')
		</cfquery>
	</cfif>
	<cfquery name="Reset" datasource="#pds#">
		SELECT * 
		FROM Levels 
		ORDER BY Sort
	</cfquery>
	<cfset NewSort = 1>
	<cfloop query="Reset">
		<cfquery name="ResetSort" datasource="#pds#">
			UPDATE Levels SET 
			Sort = #NewSort# 
			WHERE LevelID = #LevelID#
		</cfquery>
		<cfset NewSort = NewSort + 1>
	</cfloop>
</cfif>
<cfif IsDefined("AddLevel.x")>
	<cfif Trim(LevelName) Is Not "">
		<cfquery name="MaxLevel" datasource="#pds#">
			SELECT Max(Sort) as MaxSort 
			FROM Levels 
		</cfquery>
		<cfif MaxLevel.MaxSort Is "">
			<cfset NewSort = 1>
		<cfelse>
			<cfset NewSort = MaxLevel.MaxSort + 1>
		</cfif>
		<cfquery name="AddData" datasource="#pds#">
			INSERT INTO Levels 
			(LevelName, Sort)
			VALUES 
			('#LevelName#',#NewSort#)
		</cfquery>
		<cfif Not IsDefined("NoBOBHist")>
			<cfquery name="BOBHist" datasource="#pds#">
				INSERT INTO BOBHist
				(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
				VALUES 
				(Null,0,#MyAdminID#, #Now()#,'Menu Headers','#StaffMemberName.FirstName# #StaffMemberName.LastName# added #LevelName#.')
			</cfquery>
		</cfif>
	</cfif>
</cfif>
<cfif IsDefined("MvDn.x")>
	<cfset NewSort = Sort + 1>
	<cfquery name="MoveDown" datasource="#pds#">
		UPDATE Levels SET 
		Sort = #Sort# 
		WHERE Sort = #NewSort#
	</cfquery>
	<cfquery name="MoveDown" datasource="#pds#">
		UPDATE Levels SET 
		Sort = #NewSort# 
		WHERE LevelID = #LevelID#
	</cfquery>
</cfif>
<cfif IsDefined("MvUp.x")>
	<cfset NewSort = Sort - 1>
	<cfquery name="MoveUp" datasource="#pds#">
		UPDATE Levels SET 
		Sort = #Sort# 
		WHERE Sort = #NewSort#
	</cfquery>
	<cfquery name="MoveUp" datasource="#pds#">
		UPDATE Levels SET 
		Sort = #NewSort# 
		WHERE LevelID = #LevelID#
	</cfquery>
</cfif>
<cfif IsDefined("Update.x")>
	<cfloop index="B5" from="1" to="#LoopCount#">
		<cfset var1 = Evaluate("LevelName#B5#")>
		<cfset var2 = Evaluate("LevelID#B5#")>
		<cfquery name="UpdData" datasource="#pds#">
			UPDATE Levels SET 
			LevelName = '#var1#' 
			WHERE LevelID = #var2#
		</cfquery>
		<cfif Not IsDefined("NoBOBHist")>
			<cfquery name="BOBHist" datasource="#pds#">
				INSERT INTO BOBHist
				(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
				VALUES 
				(Null,0,#MyAdminID#, #Now()#,'Menu Headers','#StaffMemberName.FirstName# #StaffMemberName.LastName# edited the menu headers.')
			</cfquery>
		</cfif>
	</cfloop>
</cfif>

<cfparam name="tab" default="1">
<cfif tab Is 1>
	<cfquery name="Titles" datasource="#pds#">
		SELECT L.Sort, L.levelid, L.levelname, Count(M.MenuID) as AID
		FROM Levels L, MenuItems M
		WHERE L.LevelID *= M.Menu
		GROUP BY L.Sort, L.levelid, L.levelname 
		ORDER BY L.Sort
	</cfquery>
<cfelseif tab Is 2>
	<cfquery name="Titles" datasource="#pds#">
		SELECT L.Sort, L.levelid, L.levelname 
		FROM Levels L 
		ORDER BY L.Sort
	</cfquery>
</cfif>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Menu Headers</TITLE>
<script language="javascript">
<!-- 
function SetValues(carry1,carry2)
	{
	 var var1 = document.EditInfo.DelCount.value
	 var var9 = 0
	 if (var1 == 1)
	 	{
		 var var2 = document.EditInfo.DeleteMe.checked
		 var var3 = document.EditInfo.DeleteMe.value
		 if (var2 == 1)
		 	{
			 var var9 = var9 + ',' + var3
			}
		 document.PickDelete.DelThese.value = var9
		 return
		}
	 for (count = 0; count < var1; count++)
	 	{
		 var var2 = document.EditInfo.DeleteMe[count].checked
		 var var3 = document.EditInfo.DeleteMe[count].value
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
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<cfif tab Is 20>
	<form method="post" action="editlev.cfm">
		<input type="hidden" name="tab" value="1">
		<input type="image" src="images/return.gif" border="0">
	</form>
</cfif>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="3" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#perFontName#"</cfif> color="#ttfont#">Menu Headers</font></th>
	</tr>
	<cfif tab LT 20>
	<tr>
		<th colspan="3">
			<table border="1">
				<tr>
					<form method="post" action="editlev.cfm">
						<th bgcolor=<cfif tab Is 1>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input type="radio" <cfif tab Is 1>checked</cfif> name="tab" value="1" onclick="submit()" id="tab1"><label for="tab1">Headers</label></th>
						<th bgcolor=<cfif tab Is 2>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input type="radio" <cfif tab Is 2>checked</cfif> name="tab" value="2" onclick="submit()" id="tab2"><label for="tab2">Sort Order</label></th>
					</form>
				</tr>
			</table>
		</th>
	</tr>	
	</cfif>
</cfoutput>	
<cfif tab Is 1>
	<form method="post" name="AddNew" action="editlev.cfm">	
		<input type="hidden" name="tab" value="20">
		<tr>
			<td align="right" colspan="3"><input type="image" src="images/addnew.gif" name="AddNew" border="0"></td>
		</tr>
	</form>
	<form method="post" name="EditInfo" action="editlev.cfm">
		<cfset LoopCount = 0>
		<cfset DelCount = 0>
		<cfoutput><tr bgcolor="#thclr#"></cfoutput>
			<th>Header</th>
			<th>Menu Items</th>
			<th>Delete</th>
		</tr>
		<cfoutput query="Titles">
			<cfset LoopCount = LoopCount + 1>
			<tr>
				<input type="hidden" name="LevelID#LoopCount#" value="#LevelID#">
				<td bgcolor="#tdclr#"><input type="text" name="LevelName#LoopCount#" value="#LevelName#" maxlength="50" size="35"></td>
				<td bgcolor="#tbclr#" align="right">#AID#</td>
				<cfif AID Is 0>
					<cfset DelCount = DelCount + 1>
					<td bgcolor="#tdclr#" align="center"><input type="checkbox" name="DeleteMe" value="#LevelID#" onClick="SetValues(#LevelID#,this)"></td>
				<cfelse>
					<td bgcolor="#tdclr#" align="center">&nbsp;</td>
				</cfif>
			</tr>
		</cfoutput>
		<cfoutput>
			<input type="hidden" name="DelCount" value="#DelCount#">
			<input type="hidden" name="LoopCount" value="#LoopCount#">
		</cfoutput>
		<tr>
			<th colspan="3">
				<table border="0" cellpadding="0" cellspacing="0">
					<td><input type="image" name="Update" src="images/update.gif" border="0"></td>
	</form>
	<form method="post" name="PickDelete" action="editlev.cfm" onSubmit="return confirm ('Click Ok to confirm deleting the selected headers.')">
					<input type="hidden" name="DelThese" value="0">
					<td><input type="image" name="DelSelected" src="images/delete.gif" border="0"></td>
				</table>
			</th>
		</tr>
	</form>
<cfelseif tab Is 2>
		<cfoutput><tr bgcolor="#thclr#"></cfoutput>
			<th>Header</th>
			<th>Sort</th>
		</tr>
		<cfoutput query="Titles">
			<form method="post" action="editlev.cfm">
				<input type="hidden" name="tab" value="#tab#">
				<input type="hidden" name="LevelID" value="#LevelID#">
				<input type="hidden" name="Sort" value="#Sort#">
				<tr>
					<td bgcolor="#tbclr#">#Levelname#</td>
					<cfif CurrentRow Is 1>
						<td bgcolor="#tdclr#"><img src="images/buttonhide.gif" width="20" height="20" border=0><input type="image" src="images/buttong.gif" width="20" height="20" name="MvDn" border=0></td>
					<cfelseif CurrentRow Is RecordCount>
						<td bgcolor="#tdclr#"><input type="image" src="images/buttonf.gif" width="20" height="20" name="MvUp" border=0><img src="images/buttonhide.gif" width="20" height="20" border=0></td>
					<cfelse>
						<td bgcolor="#tdclr#"><input type="image" src="images/buttonf.gif" width="20" height="20" name="MvUp" border=0><input type="image" src="images/buttong.gif" name="MvDn" width="20" height="20" border=0></td>
					</cfif>	
				</tr>
			</form>
		</cfoutput>
<cfelseif tab Is 20>
	<cfoutput>
		<tr>
			<form method="post" name="info" action="editlev.cfm">
				<td bgcolor="#tdclr#" colspan="3"><INPUT type="text" name="LevelName" size="35"></td>
		</tr>
		<tr>
				<th colspan="3"><input type="image" src="images/enter.gif" border="0" name="AddLevel"></th>
				<input type="hidden" name="LevelName_Required" value="Please enter the Header text.">
			</form>
		</tr>
	</cfoutput>
</cfif>	
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>





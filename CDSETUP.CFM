<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page sets the check debit export format. --->
<!--- 4.0.0 06/21/99 Added ability to have a Null padchar
		3.2.0 09/08/98 --->
<!--- cdsetup.cfm --->

<cfinclude template="security.cfm">
<cfif IsDefined("setgeneric")>
	<cfset intcode = "savecdebit">
	<cfinclude template="integration/#thecode#.cfm">
</cfif>
<cfif (IsDefined("delone.x")) AND (IsDefined("DeleteEm"))>
	<cfquery name="getrid" datasource="#pds#">
		DELETE FROM CustomCDOutput 
		WHERE CDOutputID In (#DeleteEm#)
	</cfquery>
</cfif>
<cfif IsDefined("upd1.x")>
	<cfquery datasource="#pds#" name="CheckFirst">
		SELECT * FROM CustomCDOutput 
		WHERE FieldName1 = 'SetCDRecWidth' 
		AND UseTab = 6 
	</cfquery>
	<cfif CheckFirst.recordcount is not 0>
		<cfquery name="setcddateformat" datasource="#pds#">
			Update CustomCDOutput SET 
			Description1 = '#SetCDRecWidth#' 
			WHERE FieldName1 = 'SetCDRecWidth'  
			AND UseTab = 6 
		</cfquery>
	<cfelse>
		<cfquery name="setcchrout" datasource="#pds#">
	   	INSERT INTO CustomCDOutput 
			(FieldName1, Description1, UseTab, UseYN)
		   VALUES 
			('SetCDRecWidth','#SetCDRecWidth#',6,1)
		</cfquery>
	</cfif>   
	<cfquery datasource="#pds#" name="CheckFirst">
		SELECT * FROM CustomCDOutput 
		WHERE FieldName1 = 'TheCDFile' 
		AND UseTab = 6 
	</cfquery>
	<cfif CheckFirst.RecordCount is not 0>
		<cfquery name="setcddateformat" datasource="#pds#">
			Update CustomCDOutput SET 
			Description1 = '#TheCDFile#' 
			WHERE FieldName1 = 'TheCDFile'  
			AND UseTab = 6 
		</cfquery>
	<cfelse>
		<cfquery name="setcchrout" datasource="#pds#">
	   	INSERT INTO CustomCDOutput 
			(FieldName1, Description1, UseTab, UseYN)
		   VALUES 
			('TheCDFile','#TheCDFile#',6,1)
		</cfquery>
	</cfif>   
	<cfquery datasource="#pds#" name="CheckFirst">
		SELECT * FROM CustomCDOutput 
		WHERE FieldName1 = 'CDDateFormat' 
		AND UseTab = 6 
	</cfquery>
	<cfif CheckFirst.recordcount is not 0>
		<cfquery name="setcddateformat" datasource="#pds#">
			Update CustomCDOutput SET 
			Description1 = '#CDDateFormat#' 
			WHERE FieldName1 = 'CDDateFormat' 
			AND UseTab = 6 
		</cfquery>
	<cfelse>
		<cfquery name="setcchrout" datasource="#pds#">
	   	INSERT INTO CustomCDOutput 
			(FieldName1, Description1, UseTab, UseYN)
		   VALUES 
			('CDDateFormat','#CDDateFormat#',6,1)
		</cfquery>
	</cfif>   
	<cfquery datasource="#pds#" name="chkcddateformat">
		SELECT * 
		FROM CustomCDOutput 
		WHERE FieldName1 = 'CDTimeFormat' 
		AND UseTab = 6 
	</cfquery>
	<cfif chkcddateformat.recordcount is not 0>
		<cfquery name="setcddateformat" datasource="#pds#">
			Update CustomCDOutput SET 
			Description1 = '#CDTimeFormat#' 
			WHERE FieldName1 = 'CDTimeFormat' 
			AND UseTab = 6 
		</cfquery>
	<cfelse>
		<cfquery name="setcchrout" datasource="#pds#">
	   	INSERT INTO CustomCDOutput 
			(FieldName1, Description1, UseTab, UseYN)
		   VALUES 
			('CDTimeFormat','#CDTimeFormat#',6,1)
		</cfquery>
	</cfif>   
	<cfquery datasource="#pds#" name="chkcdseqid">
		SELECT * 
		FROM CustomCDOutput 
		WHERE FieldName1 = 'CDSeqID' 
		AND UseTab = 6 
	</cfquery>
	<cfif ChkCDSeqID.RecordCount Is 0>
		<cfquery name="InsData" datasource="#pds#">
			INSERT INTO CustomCDOutput 
			(FieldName1, Description1, UseTab, UseYN)
		   VALUES 
			('CDSeqID','Z',6,1)
		</cfquery>
	</cfif>
	<cfquery datasource="#pds#" name="chkcdUseDS">
		SELECT * 
		FROM CustomCDOutput 
		WHERE FieldName1 = 'CDUseDS' 
		AND UseTab = 6 
	</cfquery>
   <cfif chkcdUseDS.recordcount is not 0>
		<cfquery name="setcdUseDS" datasource="#pds#">
			Update CustomCDOutput SET 
			Description1 = '#cdUseDS#' 
			WHERE FieldName1 = 'cdUseDS' 
			AND UseTab = 6 
		</cfquery>
   <cfelse>
		<cfquery name="setcdUseDS" datasource="#pds#">
		   INSERT INTO CustomCDOutput 
			(FieldName1, Description1, UseTab, UseYN)
		   VALUES 
			('cdUseDS','#cdUseDS#',6,1)
		</cfquery>
   </cfif>   
	<cfquery datasource="#pds#" name="chkcdUseDS">
		SELECT * 
		FROM CustomCDOutput 
		WHERE FieldName1 = 'cdUseP' 
		AND UseTab = 6 
	</cfquery>
   <cfif chkcdUseDS.recordcount is not 0>
		<cfquery name="setcdUseDS" datasource="#pds#">
			Update CustomCDOutput SET 
			Description1 = '#cdUseP#' 
			WHERE FieldName1 = 'cdUseP' 
			AND UseTab = 6 
		</cfquery>
   <cfelse>
		<cfquery name="setcdUseDS" datasource="#pds#">
		   INSERT INTO CustomCDOutput 
			(FieldName1, Description1, UseTab, UseYN)
		   VALUES 
			('cdUseP','#cdUseP#',6,1)
		</cfquery>
   </cfif>   
	<cfset CheckChar = Right(cdoutpath,1)>
	<cfif CheckChar Is "\" OR CheckChar Is "/">
		<cfset var3a = cdoutpath>
	<cfelse>
		<cfset var3a = cdoutpath & OSType>
	</cfif>
	<cfquery name="chkcdoutpath" datasource="#pds#">
		SELECT * 
		FROM CustomCDOutput 
		WHERE FieldName1 = 'cdoutpath'
	</cfquery>
   <cfif chkcdoutpath.recordcount is not 0>
	   <cfquery name="setcdoutpath" datasource="#pds#">
		   UPDATE CustomCDOutput SET 
			Description1 = <cfif cdoutpath is not "">'#var3a#' <cfelse>Null </cfif>
		   WHERE FieldName1 = 'cdoutpath'
	   </cfquery>
   <cfelse>
	   <cfquery name="setcdoutpath" datasource="#pds#">
		   INSERT INTO CustomCDOutput 
			(FieldName1, Description1, UseTab, UseYN)
		   Values ('cdoutpath', '#var3a#', 6, 1) 
	   </cfquery>
   </cfif>
	<!--- BOB History --->
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'System',
			'#StaffMemberName.FirstName# #StaffMemberName.LastName# edited the General tab for check debit setup.')
		</cfquery>
	</cfif>
</cfif>
<cfif IsDefined("enter1.x")>
	<cfquery name="enternewone" datasource="#pds#">
		INSERT INTO customcdoutput
		(fieldname1,description1,useyn,startorder,endorder,cfvaryn,usetab,pjustify,padchar)
		VALUES ('#description1#','#description1#',1,#startorder#,
		#endorder#,0,#usetab#,'#pjustify#',<cfif padchar Is "">Null<cfelse>'#padchar#'</cfif>)
	</cfquery>
	<!--- BOB History --->
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'System',
			'#StaffMemberName.FirstName# #StaffMemberName.LastName# added the following value to check debit setup: #description1#.')
		</cfquery>
	</cfif>
</cfif>
<cfif IsDefined("edit1.x")>
	<cfloop index="B5" from="1" to="#LoopCount#">
		<cfset var2 = Evaluate("StartOrder#B5#")>
		<cfset var3 = Evaluate("EndOrder#B5#")>
		<cfset var4 = Evaluate("PJustify#B5#")>
		<cfset var5 = Evaluate("PadChar#B5#")>
		<cfset var6 = Evaluate("CDOutputID#B5#")>
		<cfif IsDefined("Description1#B5#")>
			<cfset var7 = Evaluate("Description1#B5#")>
		</cfif>
		<cfif IsDefined("UseYN#B5#")>
			<cfset var1 = 1>
		<cfelse>
			<cfset var1 = 0>
			<cfset var2 = 100>
			<cfset var3 = 100>
			<cfset var4 = "N">
			<cfset var5 = "">			
		</cfif>
		<cfquery name="setvalue" datasource="#pds#">
			UPDATE CustomCDOutput SET 
			StartOrder = #var2#, 
			EndOrder = #var3#, 
			PJustify = '#var4#', 
			<cfif IsDefined("Description1#B5#")>Description1 = <cfif var7 Is "">Null<cfelse>'#var7#'</cfif>,</cfif>
			PadChar = <cfif var5 Is "">Null<cfelse>'#var5#'</cfif>, 
			useyn = #var1# 
			WHERE CDOutputID = #var6#
		</cfquery>			
	</cfloop>
	<!--- BOB History --->
	<cfif Not IsDefined("NoBOBHist")>
		<cfif Tab Is 1>
			<cfset TabName = "Header">
		<cfelseif Tab Is 2>
			<cfset TabName = "Header 2">
		<cfelseif Tab Is 3>
			<cfset TabName = "Detail">
		<cfelseif Tab Is 4>
			<cfset TabName = "Control">
		<cfelseif Tab Is 5>
			<cfset TabName = "Control 2">
		</cfif>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'System',
			'#StaffMemberName.FirstName# #StaffMemberName.LastName# edited the #TabName# tab for check debit setup.')
		</cfquery>
	</cfif>
</cfif>
<cfquery name="getaddto" datasource="#pds#">
	SELECT * 
	FROM CustomCDOutput 
	WHERE UseTab = 6 
</cfquery>
<cfoutput query="getaddto">
	<cfset "#FieldName1#" = Description1>
</cfoutput>
<cfparam name="tab" default="6">
<cfif tab Is 6>
	<cfset HowWide = 4>
<cfelseif (IsDefined("AddRow.x")) AND (tab Is 1)>
	<cfset HowWide = 6>
<cfelse>
	<cfset HowWide = 7>
</cfif>
<cfparam name="pjustify" default="N">
<cfparam name="cddateformat" default="YYYYMMDD">
<cfparam name="cdtimeformat" default="hhmm">
<cfparam name="cdmemofld" default="Internet">
<cfquery name="alloptions" datasource="#pds#">
	SELECT * FROM CustomCDOutput 
	WHERE usetab = #tab#
	ORDER BY useyn desc, startorder 
</cfquery>

<cfsetting enablecfoutputonly="No">
<html>
<head>
<title>Check Debit Export Setup</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput>
<body #colorset#>
</cfoutput>
<cfinclude template="header.cfm">
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="#HowWide#" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Check Debit Setup</font></th>
	</tr>
	<tr>
		<th colspan="#HowWide#">
			<table border="1">
				<tr>
					<form method="post" action="cdsetup.cfm">
						<th bgcolor=<cfif tab is 6>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input type="radio" name="tab" <cfif tab Is 6>checked</cfif> value="6" onclick="submit()" id="tab6"><label for="tab6">General</label></th>
						<th bgcolor=<cfif tab is 1>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input type="radio" name="tab" <cfif tab Is 1>checked</cfif> value="1" onclick="submit()" id="tab1"><label for="tab1">Header</label></th>
						<th bgcolor=<cfif tab is 2>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input type="radio" name="tab" <cfif tab Is 2>checked</cfif> value="2" onclick="submit()" id="tab2"><label for="tab2">Header 2</label></th>
						<th bgcolor=<cfif tab is 3>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input type="radio" name="tab" <cfif tab Is 3>checked</cfif> value="3" onclick="submit()" id="tab3"><label for="tab3">Detail</label></th>
						<th bgcolor=<cfif tab is 4>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input type="radio" name="tab" <cfif tab Is 4>checked</cfif> value="4" onclick="submit()" id="tab4"><label for="tab4">Control</label></th>
						<th bgcolor=<cfif tab is 5>"#ttSTab#"<cfelse>"#ttNTab#"</cfif> ><input type="radio" name="tab" <cfif tab Is 5>checked</cfif> value="5" onclick="submit()" id="tab5"><label for="tab5">Control 2</label></th>
					</form>
				</tr>
			</table>
		</th>
	</tr>
</cfoutput>
		<cfif tab is 1>
			<cfinclude template="cdsetuptab1.cfm">
		<cfelseif tab is 2>
			<cfinclude template="cdsetuptab2.cfm">
		<cfelseif tab is 3>
			<cfinclude template="cdsetuptab3.cfm">
		<cfelseif tab is 4>
			<cfinclude template="cdsetuptab4.cfm">
		<cfelseif tab is 5>
			<cfinclude template="cdsetuptab5.cfm">
		<cfelseif tab is 6>
			<cfinclude template="cdsetuptab6.cfm">
		</cfif>
</table>
</center>

<cfdirectory action="list" directory="#billpath#/cfm/integration" filter="*.cfm" name="getint">
<cfif getint.recordcount gt 0>
	<cfset intcode = "checkdebit">
	<cfset intcount = 0>
	<table>
		<tr>
			<cfloop query="getint">
				<cfinclude template="integration/#name#">
			</cfloop>
		</tr>
	</table>
	<cfif intcount gt 0>
		<table>
			<tr>
				<td>Click on your check debit software for a generic setup.</td>
			</tr>
		</table>
	</cfif>
</cfif>

<cfinclude template="footer.cfm">
</body>
</html>
 
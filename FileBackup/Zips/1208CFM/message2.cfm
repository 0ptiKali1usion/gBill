<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- Staff Message Management. --->
<!---	4.0.1 11/08/00 Added defaults for Active and Display Until
		4.0.0 11/17/99 --->
<!--- message.cfm --->

<cfset securepage = "message.cfm">
<cfinclude template="security.cfm">

<cfif (IsDefined("MvLt")) AND (IsDefined("TheHaves"))>
	<cfloop index="B5" list="#TheHaves#">
		<cfquery name="DelData" datasource="#pds#">
			DELETE FROM StaffMessageResult 
			WHERE AdminID = #B5# 
			AND MessageID = #MessageID# 
		</cfquery>
	</cfloop>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="GetWho" datasource="#pds#">
			SELECT FirstName + ' ' + LastName as Name 
			FROM Accounts 
			WHERE AccountID IN 
				(SELECT AccountID 
				 FROM Admin 
				 WHERE AdminID IN (#TheHaves#)
				)
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'Staff Messages','#StaffMemberName.FirstName# #StaffMemberName.LastName# removed the following staff from a message.  #ValueList(GetWho.Name)#.')
		</cfquery>
	</cfif>
</cfif>
<cfif (IsDefined("MvRt")) AND (IsDefined("TheHaveNots"))>
	<cfloop index="B5" list="#TheHaveNots#">
		<cfif B5 GT 0>
			<cfquery name="InsData" datasource="#pds#">
				INSERT INTO StaffMessageResult 
				(AdminID, MessageID, AckReadYN, DateRead)
				VALUES 
				(#B5#,#MessageID#,0,Null)
			</cfquery>
		</cfif>
	</cfloop>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="GetWho" datasource="#pds#">
			SELECT FirstName + ' ' + LastName as Name 
			FROM Accounts 
			WHERE AccountID IN 
				(SELECT AccountID 
				 FROM Admin 
				 WHERE AdminID IN (#TheHaveNots#)
				)
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'Staff Messages','#StaffMemberName.FirstName# #StaffMemberName.LastName# added the following staff to a message.  #ValueList(GetWho.Name)#.')
		</cfquery>
	</cfif>
</cfif>
<cfif IsDefined("DelExist.x")>
	<cftransaction>
		<cfif Not IsDefined("NoBOBHist")>
			<cfquery name="GetMess" datasource="#pds#">
				SELECT Message 
				FROM StaffMessages 
				WHERE MessageID = #MessageID# 
			</cfquery>
			<cfquery name="BOBHist" datasource="#pds#">
				INSERT INTO BOBHist
				(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
				VALUES 
				(Null,0,#MyAdminID#, #Now()#,'Staff Messages','#StaffMemberName.FirstName# #StaffMemberName.LastName# deleted the following message.  #GetMess.Message#.')
			</cfquery>
		</cfif>
		<cfquery name="DelData" datasource="#pds#">
			DELETE FROM StaffMessageResult 
			WHERE MessageID = #MessageID# 
		</cfquery>
		<cfquery name="DelData" datasource="#pds#">
			DELETE FROM StaffMessages 
			WHERE MessageID = #MessageID# 
		</cfquery>
	</cftransaction>
	<cflocation addtoken="no" url="message.cfm">
</cfif>
<cfif IsDefined("UpdExist.x")>
	<cfif IsDate(StartDate)>
		<cfset SDate = LSParseDateTime(StartDate)>
	<cfelse>
		<cfset SDate = Now()>
	</cfif>
	<cfif IsDate(ExpireDate)>
		<cfset EDate = LSParseDateTime(ExpireDate)>
	<cfelse>
		<cfset EDate = DateAdd("m",1,Now())>
	</cfif>
	<cfquery name="InsData" datasource="#pds#">
		UPDATE StaffMessages SET 
		Message = '#Message#', 
		ActiveYN = #ActiveYN#, 
		StartDate = #CreateODBCDateTime(SDate)#, 
		ExpireDate = #CreateODBCDateTime(EDate)#, 
		DisplayCode = #DisplayCode# 
		WHERE MessageID = #MessageID# 
	</cfquery>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'Staff Messages','#StaffMemberName.FirstName# #StaffMemberName.LastName# edited the following message.  #Message#.')
		</cfquery>
	</cfif>
</cfif>
<cfif IsDefined("EnterNew.x")>
	<cfif IsDate(StartDate)>
		<cfset SDate = LSParseDateTime(StartDate)>
	<cfelse>
		<cfset SDate = Now()>
	</cfif>
	<cfif IsDate(ExpireDate)>
		<cfset EDate = LSParseDateTime(ExpireDate)>
	<cfelse>
		<cfset EDate = DateAdd("m",1,Now())>
	</cfif>
	<cftransaction>
		<cfquery name="CheckFirst" datasource="#pds#">
			SELECT MessageID 
			FROM StaffMessages 
			WHERE Message Like '#Message#' 
			AND StartDate = #SDate# 
			AND ExpireDate = #EDate# 
		</cfquery>
		<cfif CheckFirst.Recordcount Is 0>
			<cfquery name="InsData" datasource="#pds#">
				INSERT INTO StaffMessages 
				(Message, ActiveYN, StartDate, ExpireDate, DisplayCode) 
				VALUES 
				('#Message#', #ActiveYN#, #SDate#, #EDate#, #DisplayCode#)
			</cfquery>
		</cfif>
		<cfquery name="MaxID" datasource="#pds#">
			SELECT Max(MessageID) as NewID 
			FROM StaffMessages 
		</cfquery>
	</cftransaction>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'Staff Messages','#StaffMemberName.FirstName# #StaffMemberName.LastName# added the following message.  #Message#.')
		</cfquery>
	</cfif>
	<cfset MessageID = MaxID.NewID>
</cfif>

<cfparam name="tab" default="1">
<cfparam name="MessageID" default="0">
<cfquery name="SelectMessage" datasource="#pds#">
	SELECT * 
	FROM StaffMessages 
	WHERE MessageID = #MessageID# 
</cfquery>

<cfif Tab Is 1>
	<cfset HowWide = 2>
<cfelseif Tab Is 2>
	<cfset HowWide = 3>
	<cfquery name="StaffSeen" datasource="#pds#">
		SELECT C.FirstName, C.LastName, A.AdminID 
		FROM Accounts C, Admin A, StaffMessageResult S 
		WHERE C.AccountID = A.AccountID 
		AND A.AdminID = S.AdminID 
		AND S.MessageID = #MessageID# 
		ORDER BY C.LastName, C.FirstName 
	</cfquery>
	<cfquery name="StaffList" datasource="#pds#">
		SELECT C.FirstName, C.LastName, A.AdminID 
		FROM Accounts C, Admin A 
		WHERE C.AccountID = A.AccountID 
		AND A.AdminID NOT IN 
			(SELECT A.AdminID  
			 FROM Accounts C, Admin A, StaffMessageResult S 
			 WHERE C.AccountID = A.AccountID 
			 AND A.AdminID = S.AdminID 
			 AND S.MessageID = #MessageID# ) 
		ORDER BY C.LastName, C.FirstName 
	</cfquery>
<cfelseif Tab Is 3>
	<cfset HowWide = 1>
	<cfquery name="AckList" datasource="#pds#">
		SELECT C.FirstName, C.LastName, A.AdminID 
		FROM Accounts C, Admin A, StaffMessageResult S 
		WHERE C.AccountID = A.AccountID 
		AND A.AdminID = S.AdminID 
		AND S.MessageID = #MessageID# 
		AND S.AckReadYN = 1 
		ORDER BY C.LastName, C.FirstName 
	</cfquery>
</cfif>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Staff Message Editor</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<form method="post" action="message.cfm">
	<input type="image" src="images/return.gif" border="0">
</form>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th bgcolor="#ttclr#" colspan="#HowWide#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Staff Message Editor</font></th>
	</tr>
	<cfif SelectMessage.Recordcount GT 0>
		<tr>
			<th colspan="#HowWide#">
				<table border="1">
					<tr>
						<form method="post" action="message2.cfm">
							<th bgcolor=<cfif Tab Is 1>"#tbclr#"<cfelse>"#tdclr#"</cfif> ><input type="radio" name="Tab" <cfif Tab Is 1>checked</cfif> value="1" onclick="submit()" id="Tab1"><label for="Tab1">Message</label></th>
							<th bgcolor=<cfif Tab Is 2>"#tbclr#"<cfelse>"#tdclr#"</cfif> ><input type="radio" name="Tab" <cfif Tab Is 2>checked</cfif> value="2" onclick="submit()" id="Tab2"><label for="Tab2">Staff</label></th>
							<cfif (SelectMessage.DisplayCode Is 2)>
								<th bgcolor=<cfif Tab Is 3>"#tbclr#"<cfelse>"#tdclr#"</cfif> ><input type="radio" name="Tab" <cfif Tab Is 3>checked</cfif> value="3" onclick="submit()" id="Tab3"><label for="Tab3">Acknowledge</label></th>
							</cfif>
							<input type="hidden" name="MessageID" value="#MessageID#">
						</form>
					</tr>
				</table>
			</th>
		</tr>
	</cfif>
</cfoutput>
<cfif Tab Is 1>
	<cfoutput>
		<form method="post" action="message2.cfm">
			<tr>
				<td bgcolor="#tbclr#" align="right">Active</td>
				<td bgcolor="#tdclr#"><input type="radio" <cfif SelectMessage.ActiveYN Is 1>checked<cfelseif Trim(SelectMessage.ActiveYN) Is "">checked</cfif> name="ActiveYN" value="1">Yes <input type="radio" <cfif SelectMessage.ActiveYN Is 0>checked</cfif> name="ActiveYN" value="0">No </td>
			</tr>
			<tr bgcolor="#tdclr#" valign="top">
				<td bgcolor="#tbclr#" align="right">Start Date</td>
				<cfif SelectMessage.StartDate Is "">
					<cfset SelMess = Now()>
				<cfelse>
					<cfset SelMess = SelectMessage.StartDate>
				</cfif>
				<td><input type="text" name="StartDate" value="#LSDateFormat(SelMess, '#DateMask1#')#"></td>
			</tr>
			<tr bgcolor="#tdclr#" valign="top">
				<td bgcolor="#tbclr#" rowspan="3" align="right">Display Until</td>
				<td><input type="radio" <cfif SelectMessage.DisplayCode Is 1>checked<cfelseif Trim(SelectMessage.DisplayCode) Is "">checked</cfif> name="DisplayCode" value="1"> Read Once</td>
			</tr>
			<tr bgcolor="#tdclr#">
				<td><input type="radio" <cfif SelectMessage.DisplayCode Is 2>checked</cfif> name="DisplayCode" value="2"> Acknowledge Reading</td>
			</tr>
			<tr bgcolor="#tdclr#">
				<cfif SelectMessage.StartDate Is "">
					<cfset SelEMess = DateAdd("m",1,Now())>
				<cfelse>
					<cfset SelEMess = SelectMessage.ExpireDate>
				</cfif>
				<td><input type="radio" <cfif SelectMessage.DisplayCode Is 3>checked</cfif> name="DisplayCode" value="3"> Expire Date <input type="text" name="ExpireDate" value="#LSDateFormat(SelEMess, '#DateMask1#')#" size="15"></td>
			</tr>	
			<tr valign="top" bgcolor="#tdclr#">
				<td align="right" bgcolor="#tbclr#">Message</td>
				<td><textarea rows="6" cols="40" name="Message">#SelectMessage.Message#</textarea>
				</td>
			</tr>
			<tr>
				<cfif SelectMessage.Recordcount Is 0>
					<th colspan="2"><input type="image" src="images/enter.gif" name="EnterNew" border="0"></th>
				<cfelse>
					<th colspan="2">
						<table border="0">
							<tr>
								<th><input type="image" src="images/update.gif" name="UpdExist" border="0"></th>
								<input type="hidden" name="MessageID" value="#MessageID#">
								<input type="hidden" name="ActiveYN_Required" value="Please select the active status of this message.">
								<input type="hidden" name="DisplayCode_Required" value="Please select a display option.">
								<input type="hidden" name="StartDate_Required" value="Please enter the start date for this message.">
		</form>
		<form method="post" action="message2.cfm" onsubmit="return confirm('Click Ok to confirm deleting this message.')">
								<th><input type="image" src="images/delete.gif" name="DelExist" border="0"></th>
							</tr>
						</table>
					</th>
					<input type="hidden" name="MessageID" value="#MessageID#">
				</cfif>
			</tr>
		</form>
	</cfoutput>
<cfelseif Tab Is 2>
	<form method="post" action="message2.cfm">
		<cfoutput>
			<tr bgcolor="#thclr#">
				<th>Staff List</th>
				<th>Action</th>
				<th>View List</th>
			</tr>
			<tr bgcolor="#tdclr#">
		</cfoutput>
				<td><select name="TheHaveNots" multiple size="10">
					<cfoutput query="StaffList">
						<option value="#AdminID#">#LastName#, #FirstName#
					</cfoutput>
					<option value="">______________________________
				</select></td>
				<td align="center" valign="middle">
					<input type="submit" name="MvRt" value="---->"><br>
					<input type="submit" name="MvLt" value="<----"><br>
				</td>
				<td><select name="TheHaves" multiple size="10">
					<cfoutput query="StaffSeen">
						<option value="#AdminID#">#LastName#, #FirstName#
					</cfoutput>
					<option value="">______________________________
				</select></td>
			</tr>
			<cfoutput>
				<input type="hidden" name="MessageID" value="#MessageID#">
			</cfoutput>
			<input type="hidden" name="tab" value="2">
	</form>
<cfelseif Tab Is 3>
	<cfoutput>
		<tr>
			<td bgcolor="#thclr#">The Following have acknowledged reading this message.</td>
		</tr>
	</cfoutput>
		<cfif AckList.Recordcount GT 0>
			<cfoutput><tr bgcolor="#tbclr#">	</cfoutput>
				<td><cfoutput query="AckList">#LastName#, #FirstName#<br></cfoutput></td>
			</tr>
		</cfif>
</cfif>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 
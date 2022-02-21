<cfsetting enablecfoutputonly="yes">
<!-- Version 4.0.0 -->
<!--- This page works with the Group List to send email. --->
<!--- 4.0.0 09/09/98 --->
<!-- emaillist.cfm -->
<cfif (IsDefined("DeleteSelected.x")) AND (IsDefined("DeleteID"))>
	<cfquery name="DeleteData" datasource="#pds#">
		DELETE FROM EMailOutgoing 
		WHERE AdminID = #MyAdminID# 
		AND LetterID = #LetterID# 
		AND AccountID In (#DeleteID#)
	</cfquery>
</cfif>
<cfparam name="EPage" default="1">
<cfquery name="AllEmails" datasource="#pds#">
	SELECT * 
	FROM EMailOutgoing 
	WHERE LetterID = #LetterID# 
	AND AdminID = #MyAdminID# 
	ORDER BY LastName, FirstName 
</cfquery>
<cfif AllEmails.Recordcount GT 0>
	<cfset SelectLetter = AllEmails.SelectedLetter>
<cfelse>
	<cfset SelectLetter = 0>
</cfif>
<cfquery name="GetLetterName" datasource="#pds#">
	SELECT IntDesc 
	FROM Integration 
	WHERE IntID = #SelectLetter#
</cfquery>
<cfif GetLetterName.recordcount GT 0>
	<cfset LetterName = GetLetterName.IntDesc>
<cfelse>
	<cfset LetterName = "Custom E-Mail">
</cfif>
<cfif Epage Is 0>
	<cfset Srow = 1>
	<cfset Maxrows = AllEmails.Recordcount>
<cfelse>
	<cfset Srow = (EPage*Mrow)-(Mrow-1)>
	<cfset Maxrows = Mrow>
</cfif>
<cfset PageNumber = Ceiling(AllEmails.Recordcount/mrow)>

<cfquery name="GetLocale" datasource="#pds#">
	SELECT Value1, VarName 
	FROM Setup 
	WHERE VarName In ('Locale','DateMask1')
</cfquery>
<cfloop query="GetLocale">
	<cfset "#VarName#" = Value1>
</cfloop>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>E-Mail List</title>
<script language="javascript">
<!--  
function FilterWindow()
	{
   <cfoutput> window.open('letter.cfm?LetterID=#SelectLetter#&ID=#AllEmails.AccountID#','ProgramInfo','scrollbars=yes,status=no,width</cfoutput>=500,height=400,location=no,resizable=yes');
	return false
	}
function SelectAll(tf)
	{
	 var len = document.Results.DeleteID.length;
	 var i;  
	 for(i=0; i<len; i++) 
		{
		 document.Results.DeleteID[i].checked=tf;
		}
	}
// -->
</script>
</head>
<cfoutput><body #colorset# onload="self.focus()"></cfoutput>
<cfinclude template="header.cfm">
<cfoutput>
	<form method="post" action="#ReturnTo#">
		<input type="hidden" name="SendHeader" value="#SendHeader#">
		<input type="hidden" name="SendFields" value="#SendFields#">
		<input type="hidden" name="LetterID" value="#LetterID#">
		<input type="hidden" name="ReportID" value="#ReportID#">
		<input type="hidden" name="ReturnPage" value="#ReturnPage#">
		<input type="hidden" name="ReturnTo" value="#ReturnTo#">
		<input type="hidden" name="obid2" value="#obid2#">
		<input type="hidden" name="obdir2" value="#obdir2#">
		<input type="hidden" name="page2" value="#page2#">
		<cfif IsDefined("ReturnID")>
			<input type="hidden" name="ReturnID" value="#ReturnID#">
		</cfif>
		<cfif IsDefined("page")>
			<input type="hidden" name="page" value="#Page#">
		</cfif>
		<cfif IsDefined("obdir")>
			<input type="hidden" name="obdir" value="#obdir#">
		</cfif>
		<cfif IsDefined("obid")>
			<input type="hidden" name="obid" value="#obid#">
		</cfif>
		<input type="image" src="images/return.gif" name="Return" border="0">
	</form>
</cfoutput>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="5" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">E-Mail List</font></th>
	</tr>
</cfoutput>
<cfif AllEmails.Recordcount Is 0>
	<cfoutput>
		<tr>
			<td colspan="5" bgcolor="#tbclr#">There are no customers to be emailed.<br>
			Click the button Return to go back to the Customer List.</td>
		</tr>
	</cfoutput>
<cfelse>
	<cfif AllEmails.Recordcount GT Mrow>
		<form method="post" action="emaillist.cfm">
			<cfoutput>
				<input type="hidden" name="SendHeader" value="#SendHeader#">
				<input type="hidden" name="SendFields" value="#SendFields#">
				<input type="hidden" name="LetterID" value="#LetterID#">
				<input type="hidden" name="ReportID" value="#ReportID#">
				<input type="hidden" name="ReturnPage" value="#ReturnPage#">
				<input type="hidden" name="ReturnTo" value="#ReturnTo#">
				<input type="hidden" name="obid2" value="#obid2#">
				<input type="hidden" name="obdir2" value="#obdir2#">
				<input type="hidden" name="page2" value="#page2#">
				<cfif IsDefined("ReturnID")>
					<input type="hidden" name="ReturnID" value="#ReturnID#">
				</cfif>
				<cfif IsDefined("page")>
					<input type="hidden" name="page" value="#Page#">
				</cfif>
				<cfif IsDefined("obdir")>
					<input type="hidden" name="obdir" value="#obdir#">
				</cfif>
				<cfif IsDefined("obid")>
					<input type="hidden" name="obid" value="#obid#">
				</cfif>
			</cfoutput>
			<tr>
				<td colspan="5"><select name="EPage" onchange="submit()">
					<cfloop index="B2" from="1" to="#PageNumber#">
						<cfset ArrayPoint = (B2*Mrow)-(Mrow-1)>
						<cfset DispStr = AllEmails.LastName[ArrayPoint]>
						<cfoutput><option <cfif EPage Is B2>selected</cfif> value="#B2#">Page #B2# - #DispStr#</cfoutput>
					</cfloop>
					<cfoutput><option <cfif EPage Is 0>selected</cfif> value="0">View All #AllEmails.Recordcount#</cfoutput>
				</select></td>
			</tr>
		</form>
	</cfif>
	<cfoutput>
		<tr>
			<form method="post" action="emaillist.cfm" onsubmit="return FilterWindow()">
				<td bgcolor="#tbclr#" colspan="5">You have selected to send the '#LetterName#' letter. Click Preview to view the letter template.<br>
				<input type="Image" name="preview" src="images/preview.gif" border="0"></td>
			</form>
		</tr>
		<tr bgcolor="#thclr#">
			<th>Remove<br><font size="1"><a href="javascript:SelectAll(true)">Select</a> <a href="javascript:SelectAll(false)">Clear</a></font></th>
			<th>Name</th>
			<th>Company</th>
			<th>E-Mail</th>
			<th>Start Date</th>
		</tr>
	</cfoutput>
	<form method="post" name="Results" action="emaillist.cfm" onsubmit="return confirm ('Click Ok to confirm removing the selected customers from the email list.')">
		<cfoutput>
			<input type="hidden" name="SendHeader" value="#SendHeader#">
			<input type="hidden" name="SendFields" value="#SendFields#">
			<input type="hidden" name="LetterID" value="#LetterID#">
			<input type="hidden" name="ReportID" value="#ReportID#">
			<input type="hidden" name="ReturnPage" value="#ReturnPage#">
			<input type="hidden" name="ReturnTo" value="#ReturnTo#">
			<input type="hidden" name="obid2" value="#obid2#">
			<input type="hidden" name="obdir2" value="#obdir2#">
			<input type="hidden" name="page2" value="#page2#">
			<input type="hidden" name="EPage" value="#EPage#">
			<cfif IsDefined("ReturnID")>
				<input type="hidden" name="ReturnID" value="#ReturnID#">
			</cfif>
			<cfif IsDefined("page")>
				<input type="hidden" name="page" value="#Page#">
			</cfif>
			<cfif IsDefined("obdir")>
				<input type="hidden" name="obdir" value="#obdir#">
			</cfif>
			<cfif IsDefined("obid")>
				<input type="hidden" name="obid" value="#obid#">
			</cfif>
		</cfoutput>
		<cfoutput query="AllEmails" startrow="#Srow#" maxrows="#Maxrows#">
			<tr bgcolor="#tbclr#">
				<th bgcolor="#tdclr#"><input type="checkbox" name="DeleteID" value="#AccountID#"></th>
				<td>#LastName#, #FirstName#</td>
				<td><cfif Trim(Company) Is "">&nbsp;<cfelse>#Company#</cfif></td>
				<td>#EMailAddr#</td>
				<td>#LSDateFormat(StartDate, '#DateMask1#')#</td>
			</tr>
		</cfoutput>
		<tr>
			<th colspan="5">
				<table border="0">
					<td><input type="image" src="images/remove.gif" name="DeleteSelected" border="0"></td>
	</form>
				<form method="post" name="SendEMail" action="emailsend.cfm?RequestTimeout=300">	
					<cfoutput>
						<input type="hidden" name="SendHeader" value="#SendHeader#">
						<input type="hidden" name="SendFields" value="#SendFields#">
						<input type="hidden" name="LetterID" value="#LetterID#">
						<input type="hidden" name="ReportID" value="#ReportID#">
						<input type="hidden" name="ReturnPage" value="#ReturnPage#">
						<input type="hidden" name="ReturnTo" value="#ReturnTo#">
						<input type="hidden" name="obid2" value="#obid2#">
						<input type="hidden" name="obdir2" value="#obdir2#">
						<input type="hidden" name="page2" value="#page2#">
						<input type="hidden" name="EPage" value="#EPage#">
						<cfif IsDefined("ReturnID")>
							<input type="hidden" name="ReturnID" value="#ReturnID#">
						</cfif>
						<cfif IsDefined("page")>
							<input type="hidden" name="page" value="#Page#">
						</cfif>
						<cfif IsDefined("obdir")>
							<input type="hidden" name="obdir" value="#obdir#">
						</cfif>
						<cfif IsDefined("obid")>
							<input type="hidden" name="obid" value="#obid#">
						</cfif>
					</cfoutput>
					<th><input type="image" name="SendIt" src="images/sendemail.gif" border="0"></th>
				</form>
			</table>
		</th>
	</tr>
	<cfif AllEmails.Recordcount GT Mrow>
		<form method="post" action="emaillist.cfm">
			<cfoutput>
				<input type="hidden" name="SendHeader" value="#SendHeader#">
				<input type="hidden" name="SendFields" value="#SendFields#">
				<input type="hidden" name="LetterID" value="#LetterID#">
				<input type="hidden" name="ReportID" value="#ReportID#">
				<input type="hidden" name="ReturnPage" value="#ReturnPage#">
				<input type="hidden" name="ReturnTo" value="#ReturnTo#">
				<input type="hidden" name="obid2" value="#obid2#">
				<input type="hidden" name="obdir2" value="#obdir2#">
				<input type="hidden" name="page2" value="#page2#">
				<cfif IsDefined("ReturnID")>
					<input type="hidden" name="ReturnID" value="#ReturnID#">
				</cfif>
				<cfif IsDefined("page")>
					<input type="hidden" name="page" value="#Page#">
				</cfif>
				<cfif IsDefined("obdir")>
					<input type="hidden" name="obdir" value="#obdir#">
				</cfif>
				<cfif IsDefined("obid")>
					<input type="hidden" name="obid" value="#obid#">
				</cfif>
			</cfoutput>
			<tr>
				<td colspan="5"><select name="EPage" onchange="submit()">
					<cfloop index="B2" from="1" to="#PageNumber#">
						<cfset ArrayPoint = (B2*Mrow)-(Mrow-1)>
						<cfset DispStr = AllEmails.LastName[ArrayPoint]>
						<cfoutput><option <cfif EPage Is B2>selected</cfif> value="#B2#">Page #B2# - #DispStr#</cfoutput>
					</cfloop>
					<cfoutput><option <cfif EPage Is 0>selected</cfif> value="0">View All #AllEmails.Recordcount#</cfoutput>
				</select></td>
			</tr>
		</form>
	</cfif>
</cfif>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
   
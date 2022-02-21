<!--- Version 4.0.0 -->
<!--- This is the custom page for validating forms. --->
<!--- 4.0.0 09/29/99 
		3.2.0 09/08/98 --->
<!--- validation.cfm --->
<cfsetting enablecfoutputonly="No">
<html>
<head>
<title>Validation Error</TITLE>
</head>
<body #PageColors#>
</cfoutput>
<cfinclude template="header.cfm">
<center>
	<cfoutput>
		<table border="3">
			<tr>
				<th bgcolor="Navy"><font color="Yellow" size="5">Form Entries Incomplete or Invalid</font></th>
			</tr>
			<tr>
				<td bgcolor="Silver">One or more problems exist with the data you have entered.</td>
			</tr>
			<form>
			<tr>
				<td>Use this <B>button</b> to return to the previous page and correct the listed problems.<br>
				<INPUT TYPE="button" VALUE="Return to Previous Page" onClick="history.back()"></td>
			</tr>
		</form>
		<tr>
			<td>#error.Invalidfields#</td>
		</tr>
		<tr>
			<td>Please inform the <a href="mailto:#error.mailto#">Site Administrator</a> if you feel this error is incorrect.</td>
		</tr>
		</table>
	</cfoutput>
<HR>
</center>
</BODY>
</HTML>
    
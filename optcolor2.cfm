<cfsetting enablecfoutputonly="Yes">
<!--- Version 4.0.0 --->
<!--- This is admin page that previews the selected colors.
If a default button is clicked the colors are permanent.
If no button is clicked within 15 seconds it returns to the select colors page.
--->
<!--- 4.0.0
		3.5.0 07/02/99 New color options
		3.2.0 09//8/98 --->
<!--- optcolor3.cfm --->

<cfsetting enablecfoutputonly="No">
<html>
<head>
<title>Preview Colors</TITLE>
<cfinclude template="coolsheet.cfm">
<META HTTP-EQUIV=REFRESH CONTENT="15; URL=adminopt.cfm?Tab=2">
</head>
<cfoutput>
<body BGCOLOR="#Form.color1#" VLINK="#form.color2#" TEXT="#form.color3#" LINK="#form.color4#" LEFTMARGIN=0 TOPMARGIN=0 MARGINWIDTH=0 MARGINHEIGHT=0>
</cfoutput>
<cfinclude template="header.cfm">
<center>
<form method=post action="adminopt.cfm">
	<cfoutput>
	<input type="hidden" name="tab" value="2">
		<table border="#tblwidth#">
			<tr>
				<th><font size=5>These are your new settings</font></th>
			</tr>
			<tr>
				<td>If you wish to keep these settings click the button<br>
					"Set As Default".<br><br>
					If you do not wish to keep these settings as default, then wait 15 seconds and you will return to the standard default settings.</font></td>
			</tr>
		</table>
		<br>
		<br>
		<table border="#tblwidth#">
			<tr>
				<th bgcolor="#form.ttclr#" colspan="2"><font color="#form.ttfont#">Page Titles</font></th>
			</tr>
			<tr>
				<th colspan="2">
					<table border="1">
						<tr>
							<th bgcolor="#form.ttSTab#"><input type="Radio" name="SelectedTab" value="1"> Selected</th>
							<th bgcolor="#form.ttNTab#"><input type="Radio" name="NotSelectedTab" value="1"> Not Selected</th>
						</tr>
					</table>
				</th>
			</tr>
			<tr>
				<th bgcolor="#form.thclr#" colspan="2">Header Background</th>
			</tr>
			<tr>
				<th bgcolor="#form.tbclr#" width="200"><font color=#form.color3#>Text Background</font></th>
				<th bgcolor="#form.tdclr#" width="200"><input type="text" name="display" value="Form Fields Background"></th>
			</tr>
			<tr>
				<th bgcolor="#form.tbclr#"><font color=#form.color4#>Link color</font></th>				
				<th bgcolor="#form.tbclr#"><font color=#form.color2#>Visited link color</th>
			</tr>
			<tr>
				<th bgcolor="#form.tbclr#" colspan="2"><font color=#form.color3#>This is the color for text</font></th>
			</tr>
			<tr>
				<th colspan="2"><INPUT type="image" name="SetIt" src="images/setdefault.gif" border="0"></th>
			</tr>
		</table>
		<input type="hidden" name="adminid" value="#form.adminid#">
		<input type=hidden name="color1" value="#form.color1#">
		<input type=hidden name="color2" value="#form.color2#">
		<input type=hidden name="color3" value="#form.color3#">
		<input type=hidden name="color4" value="#form.color4#">
		<input type="hidden" name="tbclr" value="#form.tbclr#">
		<input type="hidden" name="tdclr"  value="#form.tdclr#">
		<input type="hidden" name="thclr"  value="#form.thclr#">
		<input type="hidden" name="ttclr"  value="#form.ttclr#">
		<input type="hidden" name="ttfont"  value="#form.ttfont#">
		<input type="hidden" name="ttSTab" value="#form.ttSTab#">
		<input type="hidden" name="ttNTab" value="#form.ttNTab#">
	</cfoutput>
</form>
</center>
<br>
<cfinclude template="footer.cfm">
</body>
</html>
 
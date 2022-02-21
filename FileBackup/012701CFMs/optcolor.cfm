<cfsetting enablecfoutputonly="Yes">
<!--- Version 4.0.0 --->
<!--- This is the admin page to set the colors for BOB.
--->
<!---	4.0.0 Add new color options
		3.2.0 09/08/98 --->
<!--- optcolor.cfm --->

<cfsetting enablecfoutputonly="No">
<html>
<head>
<title>Preview Colors</TITLE>
<cfinclude template="coolsheet.cfm"></head>
<body BGCOLOR="FFFFFF" VLINK="Blue" TEXT="000000" LINK="Blue" LEFTMARGIN=0 TOPMARGIN=0 MARGINWIDTH=0 MARGINHEIGHT=0>
<cfinclude template="header.cfm">
<center>
<font size=5>Prepare to test your new settingss.</font><br>
Your new settings will be tested when you click the button Preview Colors.  
If the screen is hard to read then wait 
15 seconds and your default colors will be restored.<br>
<br>
<form method=post action="optcolor2.cfm">
	<cfoutput>
		<input type="hidden" name="adminid" value="#form.adminid#">
		<input type=hidden name="color1" value="#form.color1#">
		<input type=hidden name="color2" value="#form.color2#">
		<input type=hidden name="color3" value="#form.color3#">
		<input type=hidden name="color4" value="#form.color4#">
		<input type="hidden" name="tbclr" value="#form.tbclr#">
		<input type="hidden" name="tdclr" value="#form.tdclr#">
		<input type="hidden" name="thclr" value="#form.thclr#">
		<input type="hidden" name="ttclr" value="#form.ttclr#">
		<input type="hidden" name="ttfont" value="#form.ttfont#">
		<input type="hidden" name="ttSTab" value="#form.ttSTab#">
		<input type="hidden" name="ttNTab" value="#form.ttNTab#">
	</cfoutput>
	<input type="image" src="images/preview.gif" border="0">
</form>
<br>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 
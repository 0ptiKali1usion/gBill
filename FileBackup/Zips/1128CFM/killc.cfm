<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page is the logout page. It kills all gBill cookies. --->
<!--- 4.0.0 08/19/99
		3.5.0 07/02/99
		3.2.0 09/08/98 --->
<!--- killc.cfm --->

<cfset colorset = "BGCOLOR=99CC66 TEXT=333333 LINK=009900 VLINK=009900 ALINK=CCFF66">
<cfquery name="GetValue" datasource="#pds#">
	SELECT * 
	FROM Setup 
	WHERE varname = 'hpurl'
</cfquery>
<cfquery name="Value2" datasource="#pds#">
	SELECT * 
	FROM Setup 
	WHERE varname = 'complogo'
</cfquery>

<cfcookie name="MyAdminID" value="0" expires="0">
<cfcookie name="Logout" value="gBill" expires="now">
<cfcookie name="Logout2" value="Brought to you by GreenSoft Solutions" expires="now">
<cfcookie name="MyAdminID" value="http://gBill.greensoft.com" expires="now">

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Logout</TITLE>
</head>
<cfoutput><body #colorset# onload = "if (self != top) top.location = self.location">
<a href="#GetValue.value1#"><IMG SRC="images/#Value2.value1#" border="0"></a></cfoutput>
<br><br>
<center>
	<cfoutput>
    <TABLE WIDTH="600" BORDER="0" CELLSPACING="0" CELLPADDING="0">
		<TR>
			<TD>
				<TABLE WIDTH="100%" BORDER="0" CELLSPACING="0" CELLPADDING="0">
					<TR>
						<TD WIDTH="564" BACKGROUND="images/gmail_top_tilebg.jpg"><IMG SRC="images/gmail_top2.jpg" WIDTH="582" HEIGHT="15"></TD>
						<TD BACKGROUND="images/gmail_top_tilebg.jpg" ALIGN="RIGHT"><IMG SRC="images/gmail_top_right.jpg" WIDTH="18" HEIGHT="15"></TD>
					</TR>
					<TR ALIGN="LEFT" VALIGN="TOP">
						<TD BGCOLOR="FFFFFF" COLSPAN="2">
							<TABLE WIDTH="100%" BORDER="0" CELLSPACING="0" CELLPADDING="0">
								<TR>
									<TD><IMG SRC="images/splash1.gif" WIDTH="353" HEIGHT="133" ALIGN="LEFT"></TD>
									<TD WIDTH="10"><IMG SRC="images/pixel_clear.gif" WIDTH="10" HEIGHT="8"></TD>
									<TD WIDTH="127" ALIGN="CENTER" VALIGN="TOP"><BR>
										<IMG SRC="images/poweredby_wt.gif" WIDTH="127" HEIGHT="38"></TD>
									<TD WIDTH="10"><IMG SRC="images/pixel_clear.gif" WIDTH="20" HEIGHT="8"></TD>
								</TR>
							</TABLE>
						</TD>
					</TR>
				</TABLE>
			</TD>
		</TR>
		<TR BGCOLOR="FFFFFF">
			    <TD ALIGN="CENTER">
					<TABLE WIDTH="300" BORDER="0" CELLSPACING="0" CELLPADDING="3">
				    	<TR VALIGN="MIDDLE">
					    	<TD>&nbsp;</TD>
						</TR>
						<TR VALIGN="MIDDLE">
					    	<TD><FONT FACE="Verdana, Arial, Helvetica, sans-serif"><a href="index.cfm">gBill Login Page</a></FONT></TD>
						</TR>
				    	<TR>
					    	<TD>&nbsp;</TD>
						</TR>
				    </TABLE>
				<BR><BR>
				<FONT SIZE="1" FACE="Arial, Helvetica, sans-serif" COLOR="999999">&copy; Copyright 2000 GreenSoft Solutions, Inc. All rights reserved. </FONT><BR>
			</TD>
		</TR>
	</TABLE>
	</cfoutput>
</center>	
</body>
</html>
 
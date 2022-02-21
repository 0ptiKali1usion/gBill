<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page is the main login page for BOB. --->
<!---	4.0.0 05/09/00 --->
<!--- index.cfm --->
<cfif IsDefined("MyAdminID")>
	<cflocation addtoken="no" url="admin.cfm">
</cfif>
<cfset colorset = "BGCOLOR=99CC66 TEXT=333333 LINK=009900 VLINK=009900 ALINK=CCFF66">
<cfset tblwidth = 3>
<cfif IsDefined("tfosneerg")>
	<cfset remraf = "ffej">
<cfelse>
	<cfcookie name="admin" value="done" expires="now">
	<cfcookie name="userid" value="done" expires="now">
	<cfcookie name="login" value="done" expires="now">
	<cfcookie name="MyAdminID" value="done" expires="now">
	<cfcookie name="colorset" value="done" expires="now">
	<cfif SCRIPT_NAME Does not contain "index.cfm">
		<cflocation url="index.cfm" addtoken="no">
	</cfif>
<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Login</TITLE>
</head>
<cfoutput><body #colorset# onLoad="document.loginpage.login.focus();"></cfoutput>
<center>
<form name="loginpage" action="login.cfm" method="post">
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
		<CFIF IsDefined("Attempt")>
					    	<TR>
						    	<TD>&nbsp;</TD>
								<TD><font face="Arial" size="+1" color="Red">Your Login Attempt Failed.</font></TD>
							</TR>
							<tr>
								<td>&nbsp;</td>
								<td><a href="index.cfm">Try Again</a></td>
							</tr>
		<cfelse>
					    	<TR VALIGN="MIDDLE">
						    	<TD>&nbsp;</TD>
								<TD><IMG SRC="images/txt_login.gif" WIDTH="108" HEIGHT="20"></TD>
							</TR>
							<TR VALIGN="MIDDLE">
						    	<TD ALIGN="RIGHT"><FONT SIZE="1" FACE="Verdana, Arial, Helvetica, sans-serif"><B>Username</B></FONT></TD>
								<TD><INPUT TYPE="text" NAME="login"></TD>
							</TR>
					    	<TR VALIGN="MIDDLE">
						    	<TD ALIGN="RIGHT"><B><FONT SIZE="1" FACE="Verdana, Arial, Helvetica, sans-serif">Password</FONT></B></TD>
								<TD><INPUT TYPE="password" NAME="password"></TD>
							</TR>
					    	<TR>
						    	<TD>&nbsp;</TD>
								<TD>
									<INPUT TYPE="image" BORDER="0" NAME="btn_login" SRC="images/btn_login.gif" ALT="Click To Login">
								</TD>
							</TR>
		</cfif>
							<tr>
								<td colspan="2"><font face="Arial" size="-2">Your use of this product confirms your acceptance of the system <a href="agreement.cfm" target="agreement">license agreement</a>, and binds you to it's terms.</font></td>
							</tr>
				    </TABLE>
				<BR><BR>
				<FONT SIZE="1" FACE="Arial, Helvetica, sans-serif" COLOR="999999">&copy; Copyright 2000 GreenSoft Solutions, Inc. All rights reserved. </FONT><BR>
			</TD>
		</TR>
	</TABLE>
	</cfoutput>
</form>
</center>
<br clear=left>
</body>
</html>
</cfif>
 
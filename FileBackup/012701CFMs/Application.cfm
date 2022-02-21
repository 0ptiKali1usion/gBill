<cfsetting enablecfoutputonly="yes" showdebugoutput="No">

<!--- Version 4.0.0 --->
<!--- Application.cfm The name says it all. --->
<!---	4.0.0 08/19/99 
		3.2.1 09/09/98 Changed default colors and Margins.
		3.2.0 09/08/98
		3.1.1 09/06/98 Robin Changed the default color for tablecells.
		3.1.0 07/15/98 --->
<!--- Application.cfm --->

<cfparam name="pds" default="GBill">
<cfparam name="ReportPath" default="/billing/">
<cfparam name="Locale" default ="English (US)">
<cfparam name="cfmpath" default="#GetDirectoryFromPath(CF_TEMPLATE_PATH)#">
<cfparam name="OSType" default="\">

<!--- Set to 1 to allow sending e-mail --->
<cfparam name="NonDemoSendEMail" default="1">
<cfset extpathway = ExpandPath("application.cfm")>
<cfset dirpathway = GetDirectoryFromPath(extpathway)>
<cfif FileExists("#dirpathway#external/pds.cfm")>
	<cfinclude template="external/pds.cfm">
</cfif>
<cfset caller.pds = pds>
<cfset gsdebug = find("MAINT", "#UCase(SCRIPT_NAME)#", 1)>
<cfif gsdebug is 0>
	<cferror type="validation" template="validation.cfm">
 	<cfquery name="GetEMail" datasource="#pds#">
		SELECT * 
		FROM Setup 
		WHERE VarName = 'servmail' 
	</cfquery>
	<cfif GetEmail.Value1 Is Not "">
		<cfset LocEMail = GetEmail.Value1>
	<cfelse>
		<cfset LocEMail = "support@greensoft.com">
	</cfif>
	<cfquery name="GetIPValue" datasource="#pds#">
		SELECT Value1, Description 
		FROM Setup 
		WHERE VarName = 'IPRange' 
	</cfquery>
	<cfif GetIPValue.Recordcount Is 0>
		<cferror type="request" template="requesterr.cfm" mailto="#LocEMail#">
	<cfelse>
		<cfset IPList = Valuelist(GetIPValue.Value1)>
		<cfset CurIP = Remote_Addr>
		<cfif ListFind(IPList,CurIP) Is 0>
			<cferror type="request" template="requesterr.cfm" mailto="#LocEMail#">
		<cfelse>
			<cfsetting showdebugoutput="Yes">
		</cfif>
	</cfif>
	<cfquery NAME="AllVs" DATASOURCE="#pds#">
		SELECT * 
		FROM setup 
		Where AutoLoadYN = 1 
	</cfquery>
	<cfloop query="AllVs">
		<cfset "#varname#" = #value1#>
	</cfloop>
	<!---  Run the automatic database updater --->
	<cfset cfmpathway = ExpandPath("autoadd.cfm")>
	<cfif FileExists("#cfmpathway#")>
		<cfinclude template="autoadd.cfm">
		<cffile action="DELETE" file="#cfmpathway#">
	</cfif>
	<cfset cfmpathway = ExpandPath("autoadd4.cfm")>
	<cfif FileExists("#cfmpathway#")>
		<cfinclude template="autoadd4.cfm">
		<cffile action="DELETE" file="#cfmpathway#">
	</cfif>
	<cfif SCRIPT_NAME contains "agreement.cfm">
		<cfinclude template="agreement.cfm">
		<CFABORT>
	</cfif>
	<cfoutput><cfset #SetLocale("#locale#")#></cfoutput>
	<cfif IsDefined("cookie.MyAdminID")>
		<cfset TempValue = Cookie.MyAdminID>
		<cfquery name="GetOpts" datasource="#pds#">
			SELECT * 
			FROM Admin 
			WHERE AdminID = #TempValue#
		</cfquery>
		<cfif GetOpts.RecordCount Is 0>
			<cfcookie name="MyAdminID" value="Now" expires="NOW">
			<cfset MyAdminID = MyAdminID>
			<cfsetting enablecfoutputonly="No">
			<cfinclude template="killc.cfm">
			<cfabort>
		</cfif>
		<cfquery name="StaffMemberName" datasource="#pds#">
			SELECT AccountID, FirstName, LastName 
			FROM Accounts 
			WHERE AccountID = 
				(SELECT AccountID 
				 FROM Admin 
				 WHERE AdminID = #GetOpts.AdminID#)
		</cfquery>
		<cfset LocDiff = DateDiff("n",GetOpts.lastsess,now())>
		<cfif LocDiff GT GetOpts.SessOut>
			<cfquery name="LastSes" datasource="#pds#">
				UPDATE Admin SET 
				LastSess = #Now()# 
				WHERE AdminID = #MyAdminID# 
			</cfquery>
			<cflocation addtoken="no" url="index.cfm">
		</cfif>
		<cfquery name="LastSes" datasource="#pds#">
			UPDATE Admin SET 
			LastSess = #Now()# 
			WHERE AdminID = #MyAdminID# 
		</cfquery>
		<cfparam name="colorset" default="BGCOLOR=#GetOpts.Color1# VLINK=#GetOpts.Color2# TEXT=#GetOpts.Color3# LINK=#GetOpts.Color4# LEFTMARGIN=0 TOPMARGIN=0 MARGINWIDTH=0 MARGINHEIGHT=0">
		<cfparam name="tblwidth" default="#GetOpts.tblwidth#">
		<cfparam name="ttclr" default="#GetOpts.ttclr#">
		<cfparam name="ttfont" default="#GetOpts.ttfont#">
		<cfparam name="ttsize" default="#GetOpts.ttsize#">
		<cfparam name="thclr" default="#GetOpts.thclr#">
		<cfparam name="tdclr" default="#GetOpts.tdclr#">
		<cfparam name="tbclr" default="#GetOpts.tbclr#">
		<cfparam name="mrow" default="#GetOpts.mrow#">
		<cfparam name="ttface" default="#GetOpts.PerFontName#">
		<cfparam name="color1" default="#GetOpts.color1#">
		<cfparam name="color2" default="#GetOpts.color2#">
		<cfparam name="color3" default="#GetOpts.color3#">
		<cfparam name="color4" default="#GetOpts.color4#">
		<cfif GetOpts.ttsTAB Is "">
			<cfparam name="ttSTab" default="#GetOpts.tbclr#">
		<cfelse>
			<cfparam name="ttSTab" default="#GetOpts.ttsTab#">
		</cfif>
		<cfif GetOpts.ttNTab Is "">
			<cfparam name="ttNTab" default="#GetOpts.tdclr#">
		<cfelse>
			<cfparam name="ttNTab" default="#GetOpts.ttNTab#">
		</cfif>
		<cfset ApplicationPageName = GetFileFromPath(CF_TEMPLATE_PATH)>
		<cfif Not IsDefined("NoBOBPHist")>
			<cfquery name="BOBHistory" datasource="#pds#">
				INSERT INTO BOBHist
				(ActionEmail, AccountID, AdminID, ActionDate, Action, ActionDesc) 
				VALUES 
				(Null,0,#MyAdminID#, #Now()#,'Page Access','#StaffMemberName.FirstName# #StaffMemberName.LastName# accessed #ApplicationPageName#.')
			</cfquery>
		</cfif>
	<cfelse>
		<cfparam name="colorset" default="BGCOLOR=FFFFFF VLINK=009900 TEXT=Black LINK=009900">
		<cfparam name="tblwidth" default="0">
		<cfparam name="ttclr" default="666666">
		<cfparam name="ttfont" default="FFFFFF">
		<cfparam name="ttsize" default="3">
		<cfparam name="thclr" default="CFCFCF">
		<cfparam name="tdclr" default="FFFFFF">
		<cfparam name="tbclr" default="FFFFFF">
		<cfparam name="mrow" default="50">
		<cfparam name="ttface" default="Arial">
		<cfparam name="color1" default="FFFFFF">
		<cfparam name="color2" default="009900">
		<cfparam name="color3" default="000000">
		<cfparam name="color4" default="009900">
		<cfparam name="ttSTab" default="FFFFFF">
		<cfparam name="ttNTab" default="CFCFCF">
		<cfif (SCRIPT_NAME does not contain 'index.cfm') 
		  AND (SCRIPT_NAME does not contain 'login.cfm')
		  AND (SCRIPT_NAME does not contain 'admin.cfm')
		  AND (SCRIPT_NAME does not contain 'killc.cfm')
		  AND (SCRIPT_NAME does not contain 'agreement.cfm')
		  AND (SCRIPT_NAME does not contain 'getstart.cfm')>
			<cflocation addtoken="no" url="index.cfm">
		</cfif>
	</cfif>
</cfif>
<cfparam name="AddYear" default="10">
<!--- <cfhtmlhead text="<META HTTP-EQUIV=""Pragma"" CONTENT=""no-cache"">
"> --->
<cfsetting enablecfoutputonly="no">
 
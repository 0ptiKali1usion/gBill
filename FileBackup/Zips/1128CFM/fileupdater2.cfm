<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This is the page that lists the areas to check for new files. --->
<!--- fileupdater2.cfm --->

<cfset theURL = "http://updates.greensoft.com/ibob/4x/dirlist.cfm">
<cfset theURL2 = "http://updates.greensoft.com/ibob/4x/dirlist2.cfm">
<cfset Helios = "http://updates.greensoft.com/ibob4code/">

<cfif (IsDefined("update")) AND (Not IsDefined("demoversion"))>
	<cfset TheRemoteDir = ListGetAT(ThePath,3,";")>
	<cfset TheType = ListGetAt(ThePath,1,";")>
	<cfif (TheType Is "CFM Files") OR (TheType Is "Customer Support CFM")>
		<cfset TheRemoteDir = TheRemoteDir & "_open">
	</cfif>
	<cfif IsDefined("needupdate")>
		<cfloop index="B4" list="#needupdate#">
			<cfset B4 = Trim(B4)>
			<cfif thetype Is "ctags">
				<cfset len1 = Find(".",B4)>
				<cfset len2 = Len(B4) - len1 + 1>
				<cfset B2 = Mid(B4,len1,len2)>
				<cfif B2 is ".cfm">
					<cfset B3 = Mid(B4,1,Len1) & "bak">
				<cfelse>
					<cfset B3 = B4>
				</cfif>
			<cfelse>
				<cfset B3 = B4>
			</cfif>
			<cfif FileExists("#LocPath##OSType##B4#")>
				<cfif Right(Locpath,1) is OSType>
					<cfset locLen = Len(Locpath)>
					<cfset LocPath = Left(Locpath,locLen)>
				</cfif>
				<cfif FileExists("#LocPath##OSType#filebackup#OSType##B3#")>
					<cffile action="DELETE" file="#LocPath##OSType#filebackup#OSType##B3#">
				</cfif>
				<cffile action="copy" source="#LocPath##OSType##B4#" destination="#LocPath##OSType#filebackup#OSType##B3#">
				<cffile action="RENAME" source="#LocPath##OSType##B4#" destination="#LocPath##OSType##B4#.old">
				<cffile action="DELETE" file="#LocPath##OSType##B4#.old">
			</cfif>
			<cfif Not IsDefined("NOFileUpdate")>
				<cfhttp url="#helios##TheRemoteDir##OSType##B4#" method="GET" path="#LocPath#" file="#B4#" resolveurl="false">
				<cfif Not IsDefined("NoBOBHist")>
					<cfquery name="BOBHist" datasource="#pds#">
						INSERT INTO BOBHist
						(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
						VALUES 
						(Null,0,#MyAdminID#, #Now()#,'Updated File','#StaffMemberName.FirstName# #StaffMemberName.LastName# updated the file #B4#.')
					</cfquery>
				</cfif>
			</cfif>
		</cfloop>
	</cfif>
	<cfif IsDefined("caution")>
		<cfloop index="B4" list="#caution#">
			<cfset B4 = Trim(B4)>
			<cfif thetype Is "ctags">
				<cfset len1 = Find(".",B4)>
				<cfset len2 = Len(B4) - len1 + 1>
				<cfset B2 = Mid(B4,len1,len2)>
				<cfif B2 is ".cfm">
					<cfset B3 = Mid(B4,1,Len1) & "bak">
				<cfelse>
					<cfset B3 = B4>
				</cfif>
			<cfelse>
				<cfset B3 = B4>
			</cfif>
			<cfif FileExists("#LocPath##OSType##B4#")>
				<cffile action="copy" source="#LocPath##OSType##B4#" destination="#LocPath##OSType#filebackup#OSType##B3#">
				<cffile action="RENAME" source="#LocPath##OSType##B4#" destination="#LocPath##OSType##B4#.old">
				<cffile action="DELETE" file="#LocPath##OSType##B4#.old">
			</cfif>
			<cfif Not IsDefined("NOFileUpdate")>
				<cfhttp url="#helios##TheRemoteDir#/#B4#" method="GET" path="#LocPath#" file="#B4#" resolveurl="false">
				<cfif Not IsDefined("NoBOBHist")>
					<cfquery name="BOBHist" datasource="#pds#">
						INSERT INTO BOBHist
						(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
						VALUES 
						(Null,0,#MyAdminID#, #Now()#,'Updated File','#StaffMemberName.FirstName# #StaffMemberName.LastName# updated the file #B4#.')
					</cfquery>
				</cfif>
			</cfif>
		</cfloop>
	</cfif>
	<cfif IsDefined("uptodate")>
		<cfloop index="B4" list="#uptodate#">
			<cfset B4 = Trim(B4)>
			<cfif thetype Is "ctags">
				<cfset len1 = Find(".",B4)>
				<cfset len2 = Len(B4) - len1 + 1>
				<cfset B2 = Mid(B4,len1,len2)>
				<cfif B2 is ".cfm">
					<cfset B3 = Mid(B4,1,Len1) & "bak">
				<cfelse>
					<cfset B3 = B4>
				</cfif>
			<cfelse>
				<cfset B3 = B4>
			</cfif>
			<cfif FileExists("#LocPath##OSType##B4#")>
				<cfif FileExists("#LocPath##OSType#filebackup#OSType##B3#")>
					<cffile action="DELETE" file="#LocPath##OSType#filebackup#OSType##B3#">
				</cfif>
				<cffile action="COPY" source="#LocPath##OSType##B4#" destination="#LocPath##OSType#filebackup#OSType##B3#">
				<cffile action="RENAME" source="#LocPath##OSType##B4#" destination="#LocPath##OSType##B4#.old">
				<cffile action="DELETE" file="#LocPath##OSType##B4#.old">
			</cfif>
			<cfif Not IsDefined("NOFileUpdate")>
				<cfhttp url="#helios##TheRemoteDir#/#B4#" method="GET" path="#LocPath#" file="#B4#" resolveurl="false">
				<cfif Not IsDefined("NoBOBHist")>
					<cfquery name="BOBHist" datasource="#pds#">
						INSERT INTO BOBHist
						(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
						VALUES 
						(Null,0,#MyAdminID#, #Now()#,'Updated File','#StaffMemberName.FirstName# #StaffMemberName.LastName# updated the file #B4#.')
					</cfquery>
				</cfif>
			</cfif>
		</cfloop>
	</cfif>
</cfif>

<cfhttp url="#theURL#?ListFiles=1" method="post">
	<cfhttpparam name="ThePath" value="#ThePath#" type="formfield">
</cfhttp>
<cfset strpos = Find("STARTDIRLIST",cfhttp.filecontent) + 13>
<cfset endpos = Find("ENDDIRLIST",cfhttp.filecontent) -1>
<cfset endpos = endpos - strpos>
<cfset thedirlist = Mid(cfhttp.filecontent,strpos,endpos)>
<cfset strpos2 = Find("STARTMESSAGE",cfhttp.filecontent) + 13>
<cfset endpos2 = Find("ENDMESSAGE",cfhttp.filecontent) -1>
<cfset endpos2 = endpos2 - strpos2>
<cfset themessage = Mid(cfhttp.filecontent,strpos2,endpos2)>
<cfset strpos3 = Find("Last Upgrade Number:",themessage)>
<cfif strpos3 GT 0>
	<cfset lookfrom = strpos3 + 20>
	<cfset endpos3 = Find(" ",themessage,lookfrom)>
	<cfset endpos3 = endpos3 - lookfrom>
	<cfset LastUpdate = Mid(themessage,lookfrom,endpos3)>
	<cfset LastUpdate = Trim(LastUpdate)>
<cfelse>
	<cfset LastUpdate = 0>
</cfif>
<cfif ListGetAt(ThePath,2, ";") is "Billpath">
	<cfset remotedir = ListGetAt(ThePath,1,";")>
	<cfset dirinfo = ListGetAt(ThePath,3,";")>
	<cfset thelocaldir = "#billpath##dirinfo#">
	<cfset thetype = "bob">
<cfelseif ListGetAt(ThePath,2, ";") is "customtag">
	<cfset remotedir = ListGetAt(ThePath,1,";")>
	<cfset dirinfo = ListGetAt(ThePath,3,";")>
	<CFSET MainBranch = "HKEY_LOCAL_MACHINE\SOFTWARE\Allaire\ColdFusion\CurrentVersion\CustomTags">
	<CFSET TagName="CFMLTagSearchPath">
	<cfif Mid(Server.ColdFusion.ProductVersion,1,1) is "3">
		<CF_ADMIN_REGISTRY_GET Branch="#MainBranch#" Entry="#TagName#" TYPE="STRING" NAME="CTAGPATH">
	<cfelse>
		<cfregistry action="get" branch="#MainBranch#" entry="#TagName#" type="string" variable="CTAGPATH">
	</cfif>
	<CFSET thelocaldir=CTAGPATH & OSType>
	<cfset thetype="ctags">
<cfelse>
	<cfset remotedir = "na">
	<cfset thelocaldir = "na">
	<cfset thetype="na">
</cfif>
<cfparam name="NoAutoAdd" default="0">
<cfif (remotedir Is "Main CFM Files") OR (remotedir Is "CFM Files")>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT * FROM Upgrades 
		WHERE Upgradenum = #LastUpdate#
	</cfquery>
	<cfif CheckFirst.RecordCount Is 0>
		<cfset NoAutoAdd = 0>
	<cfelse>
		<cfset NoAutoAdd = 1>
	</cfif>
	<cfset theMessage = Replace(theMessage,"Last Upgrade Number:#LastUpdate# ","")>
</cfif>

<cfset listnoupdate = "">
<cfif thelocaldir is not "na">
	<cfdirectory directory="#thelocaldir#" filter="noupdate.txt" action="list" name="check1">
	<cfif check1.recordcount gt 0>
		<cffile action="read" file="#thelocaldir##OSType#noupdate.txt" variable="message">
		<cfset thenoupds = Replace(message,"
",",","All")>
		<cfset listnoupdate = thenoupds>
	</cfif>
</cfif>

<cfset listuptodate = "">
<cfset listneedupdt = "">	

<cfloop index="B5" list="#thedirlist#" delimiters=";">
	<cfset theName = ListGetAt(B5,1)>
	<cfset theDate = ListGetAt(B5,2)>
	<cfdirectory directory="#thelocaldir#" filter="#theName#" action="list" name="check">
	<cfif check.recordcount gt 0>
		<cfset localdate = check.DateLastModified>
		<cfif DateCompare(thedate,localdate) is -1>
			<cfset listuptodate = ListAppend(listuptodate,theName)>
		<cfelse>
			<cfset listneedupdt = ListAppend(listneedupdt,theName)>
		</cfif>
	<cfelse>
		<cfset listneedupdt = ListAppend(listneedupdt,theName)>
	</cfif>
</cfloop>
<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>File Updater</title>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput>
<body #colorset#>
</cfoutput>
<cfinclude template="header.cfm">
<a href="fileupdater.cfm"><img src="images/return.gif" border="0"></a><br>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="3" bgcolor="#ttclr#"><font color="#ttfont#" <cfif ttface Is Not "NA">face="#perfontname#"</cfif> size="#ttsize#">#remotedir#</font></th>
	</tr>
	<tr>
		<th colspan="3" bgcolor="#tbclr#">Scroll down for a list of the changes made to the files.</th>
	</tr>
	<form method="post" action="fileupdater2.cfm?RequestTimeout=500">
		<input type="hidden" name="ThePath" value="#ThePath#">
		<input type="hidden" name="LocPath" value="#thelocaldir#">
		<input type="hidden" name="thetype" value="#thetype#">
		<tr bgcolor="#tdclr#">
</cfoutput>
			<td>
				<font size="4">Up To Date</font><br>
				<select name="uptodate" size="15" multiple>
					<cfloop index="B5" list="#listuptodate#">
						<cfif Not ListContains(listnoupdate,B5)>
							<cfoutput><option value="#B5#">#B5#</cfoutput>
						</cfif>
					</cfloop>
					<option value="">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				</select>
			</td>
			<td>
				<font size="4">Needs Updated</font><br>
				<select name="needupdate" size="15" multiple>
					<cfloop index="B5" list="#listneedupdt#">
						<cfif Not ListContains(listnoupdate,B5)>
							<cfif (B5 Is Not "autoadd.cfm") OR (NoAutoAdd Is 0)>
								<cfoutput><option value="#B5#">#B5#</cfoutput>
							</cfif>
						</cfif>
					</cfloop>
					<option value="">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;					
				</select>
			</td>
			<td>
				<font size="4" color="Red">Caution</font><br>
				<select name="caution" size="15" multiple>
					<cfloop index="B5" list="#listnoupdate#">
						<cfoutput><option value="#Trim(B5)#">#B5#</cfoutput>
					</cfloop>
					<option value="">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				</select>
			</td>
		</tr>
		<cfoutput>
		<tr bgcolor="#tbclr#">
		</cfoutput>
			<th colspan="3">All files will be backed up before updating.</th>
		</tr>
		<tr>
			<th colspan="3">
				<input type="submit" name="update" value="Update Selected Files">
			</th>
		</tr>
	</form>
</table>
<cfif theMessage is not "NA">
	<cfoutput>
		<table border="3">
			<tr bgcolor="#tbclr#">
				<td colspan="3"><font size="2"><pre>#Trim(theMessage)#</pre></font></td>
			</tr>
		</table>
	</cfoutput>
</cfif>

</center>
<cfinclude template="footer.cfm">
</body>
</html>
 
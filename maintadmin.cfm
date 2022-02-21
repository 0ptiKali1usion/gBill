<cfsetting enablecfoutputonly="Yes" showdebugoutput="Yes">
<!--- Version 4.0.0 --->
<!---	4.0.0 04/06/00 --->
<!--- maintadmin.cfm --->
<!--- Tab 1 - 97 --->
<!--- Tab 2 - 641 --->
<!--- Tab 3 - 841 --->

<cfif (#MID(remote_addr,1,11)# is not "204.77.123.")
  AND (#MID(remote_addr,1,11)# is not "204.77.126.") 
  AND (#MID(remote_addr,1,10)# is not "209.15.87.") 
  AND (#MID(remote_addr,1,10)# is not "192.168.2.") 
  AND (Not IsDefined("Cookie.MaintPages"))>
	<cflocation addtoken="No" url="admin.cfm">
<cfelse>
	<cfset ThisPageName = "maintadmin.cfm">
	<CFSET MainBranch = "HKEY_LOCAL_MACHINE\SOFTWARE\Allaire\ColdFusion\CurrentVersion\CustomTags">
	<CFSET TagName="CFMLTagSearchPath">
	<cfif Mid(Server.ColdFusion.ProductVersion,1,1) is "3">
		<CF_ADMIN_REGISTRY_GET Branch="#MainBranch#" Entry="#TagName#" TYPE="STRING" NAME="CTAGPATH">
	<cfelse>
		<cfregistry action="get" branch="#MainBranch#" entry="#TagName#" type="string" variable="CTAGPATH">
	</cfif>
	<cftry>
		<cfquery name="GetOS" datasource="#pds#">
			SELECT Value1 
			FROM Setup 
			WHERE VarName = 'OSType'
		</cfquery>
		<cfif GetOS.Value1 Is "">
			<cfset OSType = "\">
		<cfelse>
			<cfset OSType = GetOS.Value1>
		</cfif>
		<cfcatch type="Any">
			<cfset OSType = "\">
			<cfset gBillInstall = "0">
		</cfcatch>
	</cftry>
	<cfparam name="Tab" default="2">
	<cfparam name="gBillInstall" default="1">
	<cfparam name="DefODBC" default="gBill">
<cfsetting enablecfoutputonly="No">
<HTML>
<HEAD>
<TITLE>Admin Pages</TITLE>
<cfif Tab Is 5>
<script language="javascript">
<!--
function SelectAll(tf)
	{
	 var len = document.ViewFolder.UpgradeID.length;
    var i;  
    for(i=0; i<len; i++) 
	 	{
      document.ViewFolder.UpgradeID[i].checked=tf;
      }       
   }
// -->
</script>
</cfif>
</HEAD>
<BODY bgcolor="white">
<cfif IsDefined("returnto")>
	<cfoutput><a href="#returnto#">#returnto#</a></cfoutput>
</cfif>
<center>
<table>
	<tr>
		<cfoutput>
			<th><a href="#ThisPageName#?Tab=2">Query Builder</a></th>
			<th><a href="#ThisPageName#?Tab=1">Maintain Files</a></th>
			<th><a href="#ThisPageName#?Tab=3">Page Editor</a></th>
			<th><a href="#ThisPageName#?Tab=8">FTP</a></th>
			<cfif gBillInstall Is 1>
				<th><a href="#ThisPageName#?Tab=6">Setup Values</a></th>
				<th><a href="#ThisPageName#?Tab=7">Error Log</a></th>
				<th><a href="#ThisPageName#?Tab=5">Auto Add Updates</a></th>
				<th><a href="#ThisPageName#?Tab=4">License Values</a></th>
				<th><a href="admin.cfm">Main Menu</a></th>
			</cfif>
		</cfoutput>
	</tr>
	<cfoutput>
		<tr>
			<td colspan="7"><b>Server:</b> #Server.OS.Name# #Server.OS.Version# <b>Build:</b> #Server.OS.BuildNumber#</td>
		</tr>
		<tr>
			<td colspan="7"><b>Product:</b> #Server.ColdFusion.ProductName# <b>Edition:</b> #Server.ColdFusion.ProductLevel# <b>Version:</b> #Replace(Server.ColdFusion.ProductVersion,", ",".","All")#</td>
		</tr>
		<tr>
			<td colspan="7"><b>Custom Tag Directory:</b> #CTAGPATH#</td>
		</tr>
	</cfoutput>
</table>
</center>
<cfif Tab Is 1>
	<cfsetting enablecfoutputonly="Yes">
	<!--- MaintFile --->
		<cfset DefPath = GetDirectoryFromPath("#CF_TEMPLATE_PATH#")>
		<cfparam name="ThePathway" default="#DefPath#">
		<cfparam name="TheDirPath" default="#DefPath#">

		<cfif IsDefined("ChngMode")>
			<cfif Mid(Server.ColdFusion.ProductVersion,1,1) is "4">
				<cfexecute name="chmod" arguments="#modevalue# #TheDirPath##FileName#" timeout="20" outputfile="0_testresult.cfm">
				</cfexecute>
			</cfif>
		</cfif>
		<cfif IsDefined("turnoff")>
			<CFSET MainBranch = "HKEY_LOCAL_MACHINE\SOFTWARE\Allaire\ColdFusion\CurrentVersion\Server">
			<CFSET TagName="UseAdminPassword">
			<cfif Mid(Server.ColdFusion.ProductVersion,1,1) is "3">
				<CF_ADMIN_REGISTRY_SET Branch="#MainBranch#" Entry="#TagName#" TYPE="STRING" VALUE="0">
			<cfelse>
				<cfregistry action="SET" branch="#MainBranch#" entry="#TagName#" type="String" value="0">
			</cfif>
		</cfif>
		<cfif IsDefined("turnon")>
			<CFSET MainBranch = "HKEY_LOCAL_MACHINE\SOFTWARE\Allaire\ColdFusion\CurrentVersion\Server">
			<CFSET TagName="UseAdminPassword">
			<cfif Mid(Server.ColdFusion.ProductVersion,1,1) is "3">
				<CF_ADMIN_REGISTRY_SET Branch="#MainBranch#" Entry="#TagName#" TYPE="STRING" VALUE="1">
			<cfelse>
				<cfregistry action="SET" branch="#MainBranch#" entry="#TagName#" type="String" value="1">
			</cfif>
		</cfif>
		<cfif IsDefined("turnsoff")>
			<CFSET MainBranch = "HKEY_LOCAL_MACHINE\SOFTWARE\Allaire\ColdFusion\CurrentVersion\Server">
			<CFSET TagName="UseStudioPassword">
			<cfif Mid(Server.ColdFusion.ProductVersion,1,1) is "3">
				<CF_ADMIN_REGISTRY_SET Branch="#MainBranch#" Entry="#TagName#" TYPE="STRING" VALUE="0">
			<cfelse>
				<cfregistry action="SET" branch="#MainBranch#" entry="#TagName#" type="String" value="0">
			</cfif>
		</cfif>
		<cfif IsDefined("turnson")>
			<CFSET MainBranch = "HKEY_LOCAL_MACHINE\SOFTWARE\Allaire\ColdFusion\CurrentVersion\Server">
			<CFSET TagName="UseStudioPassword">
			<cfif Mid(Server.ColdFusion.ProductVersion,1,1) is "3">
				<CF_ADMIN_REGISTRY_SET Branch="#MainBranch#" Entry="#TagName#" TYPE="STRING" VALUE="1">
			<cfelse>
				<cfregistry action="SET" branch="#MainBranch#" entry="#TagName#" type="String" value="1">
			</cfif>
		</cfif>
		<cfif IsDefined("addme")>
			<cfregistry action="SET" branch="HKEY_LOCAL_MACHINE\SOFTWARE\Allaire\ColdFusion\CurrentVersion\Debug\DebugIPList" 
			 entry="#ipadd#" type="String" value="">
		</cfif>
		<cfif IsDefined("removeone")>
			<cfregistry action="DELETE" branch="HKEY_LOCAL_MACHINE\SOFTWARE\Allaire\ColdFusion\CurrentVersion\Debug\DebugIPList"
			 entry="#ipadd#">
		</cfif>
		
		<CFSET MainBranch = "HKEY_LOCAL_MACHINE\SOFTWARE\Allaire\ColdFusion\CurrentVersion\Server">
		<CFSET TagName="UseAdminPassword">
		<cfif Mid(Server.ColdFusion.ProductVersion,1,1) is "3">
			<CF_ADMIN_REGISTRY_GET Branch="#MainBranch#" Entry="#TagName#" TYPE="STRING" NAME="CTAGPATH">
		<cfelse>
			<cfregistry action="get" branch="#MainBranch#" entry="#TagName#" type="string" variable="CTAGPATH">
		</cfif>
		<CFSET UsePassword = CTAGPATH>
		
		<CFSET MainBranch = "HKEY_LOCAL_MACHINE\SOFTWARE\Allaire\ColdFusion\CurrentVersion\Server">
		<CFSET TagName="UseStudioPassword">
		<cfif Mid(Server.ColdFusion.ProductVersion,1,1) is "3">
			<CF_ADMIN_REGISTRY_GET Branch="#MainBranch#" Entry="#TagName#" TYPE="STRING" NAME="CTAGPATH">
		<cfelse>
			<cfregistry action="get" branch="#MainBranch#" entry="#TagName#" type="string" variable="CTAGPATH">
		</cfif>
		<CFSET UseSPassword = CTAGPATH>

		<cfset DebugYN = 0>
		<CFSET MainBranch = "HKEY_LOCAL_MACHINE\SOFTWARE\Allaire\ColdFusion\CurrentVersion\Debug\DebugIPList">
		<CFSET TagName="CurrentIPS">
		<cfif Mid(Server.ColdFusion.ProductVersion,1,1) is "4">
			<cfset DisplayDebug = 1>
			<cftry>
				<cfregistry action="getall" branch="#MainBranch#" Name="#TagName#" type="string">
				<cfcatch type="Any">
					<cfset DisplayDebug = 0>
				</cfcatch>
			</cftry>
			<cfif DisplayDebug Is 1>
				<cfoutput query="CurrentIPS">
					<cfif entry is REMOTE_ADDR>
						<cfsetting showdebugoutput="Yes">
						<cfset DebugYN = 1>
					</cfif>
				</cfoutput>
			</cfif>
		</cfif>

		<cfset MainBranch = "HKEY_LOCAL_MACHINE\SOFTWARE\Allaire\ColdFusion\CurrentVersion\Schedule">
		<cfset TagName="CheckInterval">
		<cfif Mid(Server.ColdFusion.ProductVersion,1,1) is "3">
			<CF_ADMIN_REGISTRY_GET Branch="#MainBranch#" Entry="#TagName#" TYPE="STRING" NAME="SchedInt">
		<cfelse>
			<cfregistry action="get" branch="#MainBranch#" entry="#TagName#" type="string" variable="SchedInt">
		</cfif>
		<cfset SchedInterval = SchedInt/60>

		<cfif IsDefined("upload1")>
			<cffile action="upload" filefield="afilename" destination="#TheDirPath#" nameconflict="overwrite" mode="777">
		</cfif>
		<cfif IsDefined("Encryptor") AND IsDefined("filename")>
			<cfset Path1 = TheDirPath>
			<cfset B5 = filename>
			<cfdirectory Action="List" Name="checkfirst" Sort="Type" Directory="#TheDirPath#backup">
			<cfif checkfirst.recordcount Is 0>
				<cfdirectory action="create" directory="#TheDirPath#backup">
			</cfif>
			<cffile action="copy" source="#Path1##B5#" destination="#Path1#backup#OSType##B5#" mode="777"> 
			<cffile action="write" file="#Path1##B5#.tmp"
			 output="#ThePathWay#cfcrypt.exe #Path1##B5# /h ""GreenSoft Solutions, Inc.  913-317-8083 FILE=#B5#  "" 
			 exit">
			<cffile action="rename" source="#Path1##B5#.tmp" destination="#Path1##B5#.cmd" >
				<cfx_shellexec FILE="#B5#.cmd" DIRECTORY="#Path1#">
				<cfx_wait SPAN="1">
			<cffile action="delete" file="#Path1##B5#.cmd">
		</cfif>
		<cfif IsDefined("movefile")>
			<cfif filename1 Is Not "">
				<cffile action="copy" source="#TheDirPath##filename#" destination="#filename1#">
				<cffile action="delete" file="#TheDirPath##filename#"> 
			</cfif>
		</cfif>
		<cfif IsDefined("delfile")>
		   <cffile action="delete" file="#TheDirPath##FileName#">
		</cfif>
		<cfif IsDefined("deldir1")>
			<cfif OSType Is "/">
				<cfdirectory action="Delete" directory="#TheDirPath##FileName#">
			<cfelse>
				<cfdirectory Action="List" Name="check2" Directory="c:\temp">
			   <cfif check2.RecordCount is 0>
			   	<cfdirectory Action="Create" Directory="c:\temp">   
		   	</cfif>
				<cfdirectory Action="List" Name="check1" Directory="#TheDirPath##FileName#">
			   <cfif check1.RecordCount gt 2>
			   	<cfloop index="B5" List="#valuelist(check1.name)#">
		   	   	<cfif (B5 is not ".") AND (B5 is not "..")>
						  <cffile action="delete" file="#TheDirPath##FileName##OSType##B5#">
		      		</cfif>
				   </cfloop>
			   	<cfdirectory Action="Delete" Directory="#TheDirPath##filename#">
			   <cfelseif check1.RecordCount is not 0>
				   <cfdirectory Action="Delete" Directory="#TheDirPath##filename#">
				</cfif>
		   </cfif>
		</cfif>
		<cfif IsDefined("cdir1")>
			<cfdirectory Action="List" Name="check1" Directory="#TheDirPath##DirMake#">
		   <cfif check1.RecordCount is 0>
		   	<cfdirectory Action="Create" Directory="#TheDirPath##DirMake#" mode="777">
		   </cfif>
		</cfif>
		<cfif IsDefined("DownLoadFile")>
			<cfcontent type="unknown" file="#FileName#" deletefile="No">
		</cfif>
		<cfif (IsDefined("renfile")) AND (IsDefined("Filename1"))>
			<cfif filename1 Is Not "">
			   <cffile action="copy" Source="#TheDirPath##FileName#" Destination="#TheDirPath##FileName1#">
		   	<cffile action="delete" file="#TheDirPath##FileName#"> 
			</cfif>
		</cfif>

		<cfparam name="mrow" default="50">
		<cfparam name="obid" default="Name">
		<cfparam name="obdir" default="asc">
		<cfparam name="Page" default="1">
		<cfparam name="NoEditTypes" default="jpg,jpeg,gif">
		
		<cfif IsDefined("drivelist")>
			<cfset DriveList = DriveList>
		<cfelse>
			<cfset CheckDriveList = "C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z">
			<cfset DriveList = "">
			<cfloop index="B5" list="#CheckDriveList#">
				<cfdirectory Action="List" Name="ADrive" Directory="#B5#:">
				<cfif ADrive.Recordcount GT 0>
					<cfset DriveList = ListAppend(DriveList,B5)>
				</cfif>
			</cfloop>			
		</cfif>

		<cfset CheckFirst = Right(TheDirPath,1)>
		<cfif CheckFirst Is Not OSType>
			<cfset TheDirPath = TheDirPath & OSType>
		</cfif>
		<cfset Len1 = Len(TheDirPath) - 1>
		<cfset TheDir = Left(TheDirPath,Len1)>
		<cfdirectory Action="List" Name="check1" Sort="Type, #obid# #obdir#" Directory="#TheDir#">
		<cfif Page Is 0>
			<cfset srow = 1>
			<cfset maxrows = check1.recordcount>
		<cfelse>
			<cfset srow = (Page*Mrow)-(Mrow-1)>
			<cfset maxrows = mrow>
		</cfif>
		<cfset PageNumber = Ceiling(check1.RecordCount/Mrow)>

	<cfsetting enablecfoutputonly="No" showdebugoutput="Yes">
	<center>
		<table border="2" cellpadding="2" cellspacing="0"> 
			<tr bgcolor="silver">
				<cfoutput>
					<form method="post" action="#ThisPageName#">
						<input type="Hidden" name="TheDirPath" value="#TheDirPath#">
						<input type="Hidden" name="tab" value="1">
				</cfoutput>
					<cfif check1.recordcount gt mrow>
						<td><font size="2"><select name="page" onChange="submit()">
							<cfloop Index="Loopc" from="1" To="#pagenumber#">
								<cfset ArrayPoint = Loopc * mrow - (mrow - 1)>
								<cfif obid is "size">
									<cfset disp = check1.Size[ArrayPoint]>
								<cfelse>
									<cfset disp = check1.Name[ArrayPoint]>
								</cfif>
								<cfoutput><option value="#loopc#" <cfif page is loopc>selected</cfif> >Page #loopc# - #disp#</cfoutput>
							</cfloop>
							<option value="0" <cfif Page Is 0>selected</cfif> >View All
						</select></font></td>
					<cfelse>
						<td>Page 1</td>
					</cfif>
					<cfif OSType Is "/">
						<cfset HowWide = 2>
					<cfelse>
						<cfset HowWide = 1>
					</cfif>
					<cfoutput>
						<td colspan="#HowWide#" align="center"><font size="2"><input type="submit" name="refreshpage" value="Refresh"></font></td>
					</cfoutput>
				</form>
				<cfoutput>
					<form method="post" action="#ThisPageName#">
						<input type="hidden" name="page" value="#page#">
						<input type="hidden" name="TheDirPath" value="#TheDirPath#">
						<input type="Hidden" name="tab" value="2">
						<th align="center" colspan="2"><font size="2"><input type="submit" name="query" value="Query Data"></font></th>
					</form>
					<td colspan="2">Scheduler: #SchedInterval#</td>
					<form method="post" action="#ThisPageName#">
						<input type="Hidden" name="TheDirPath" value="#TheDirPath#">
						<input type="hidden" name="page" value="#page#">
						<input type="hidden" name="ipadd" value="#REMOTE_ADDR#">
						<input type="Hidden" name="tab" value="1">
						<cfif DebugYN is 1>
							<td align="center" colspan="3"><font size="2"><input type="submit" name="removeone" value="Debug Off"></font> #Remote_Addr#</td>
						<cfelse>
							<td align="center" colspan="3"><font size="2"><input type="submit" name="addme" value="Debug On"></font> #Remote_Addr#</td>
						</cfif>
					</form>
				</cfoutput>
			</tr>
			<tr valign="top" bgcolor="silver">
				<cfoutput>
					<form method="post" action="#ThisPageName#">
						<input type="Hidden" name="TheDirPath" value="#TheDirPath#">
						<input type="Hidden" name="tab" value="1">
						<td colspan="3" align="right">Cold Fusion Administrator Password:&nbsp;</td>
						<cfif UsePassword is 1>
							<th><font size="2"><input type="submit" name="turnoff" value="Turn Off"></font></th>
						<cfelse>
							<th><font size="2"><input type="submit" name="turnon" value="Turn On"></font></th>
						</cfif>		
					</form>
					<td colspan="#HowWide#">&nbsp;</td>
					<form method="post" action="#ThisPageName#">
						<input type="Hidden" name="TheDirPath" value="#TheDirPath#">
						<input type="Hidden" name="tab" value="1">
						<td align="right" colspan="3">Cold Fusion Studio Password:&nbsp;</td>
						<cfif UseSPassword is 1>
							<th><font size="2"><input type="submit" name="turnsoff" value="Turn Off"></font></th>
						<cfelse>
							<th><font size="2"><input type="submit" name="turnson" value="Turn On"></font></th>
						</cfif>
					</form>
				</cfoutput>
			</tr>
			<tr bgcolor="silver">
				<cfoutput>
					<form method=post action="#ThisPageName#" enctype="multipart/form-data">
						<input type="hidden" name="page" value="#page#">
						<input type="Hidden" name="tab" value="1">
						<input type="Hidden" name="TheDirPath" value="#TheDirPath#">
						<input type="Hidden" name="action1" value="dir1ist1">
						<td align="right" colspan="4"><font size="2"><INPUT type="submit" name="cdir1" value="Create Directory"><INPUT type="text" name="dirmake"></font></td>
						<cfif OSType Is "/">
							<td>&nbsp;</td>
						</cfif>
						<td align="right" colspan="5"><font size="2"><INPUT type="submit" name="upload1" value="Upload File"><INPUT type="file" name="afilename"></td>
					</form>
				</cfoutput>
			</tr>
			<tr bgcolor="silver">
				<td colspan="2"><cfloop index="B4" list="#drivelist#">
						<cfoutput><a href="#ThisPageName#?tab=1&TheDirPath=#B4#:">#B4#</a></cfoutput>
				</cfloop><cfif OSType Is "/">&nbsp;</cfif></th>
				<cfoutput>
					<cfif OSType Is "/">
						<cfset HowWide2 = 6>
					<cfelse>
						<cfset HowWide2 = 5>
					</cfif>
					<cfset CarryRow = 1>
					<td colspan="#HowWide2#"><cfloop index="B5" list="#TheDirPath#" delimiters="#OSType#"><cfset Pos1 = FindNoCase(B5,TheDirPath) -1 ><cfif Pos1 LTE 0><cfset CarryDir = B5><cfset CarryRow = 2><cfelse><cfset CarryDir = Left(TheDirPath,Pos1) & B5><cfif CarryRow Is 1>#Left(TheDirPath,Pos1)#<cfset CarryRow=2></cfif></cfif><a href="#ThisPageName#?tab=1&TheDirPath=#URLEncodedFormat(CarryDir)#">#B5#</a>#OSType#</cfloop></td>
					<td colspan="2">#DateFormat(Now(), 'mmm/dd/yyyy')# #TimeFormat(Now(), 'hh:mm tt')#</td>
				</cfoutput>
			</tr>
			<tr bgcolor="silver">
				<cfoutput>
					<form method="post" action="#ThisPageName#">
						<input type="Hidden" name="tab" value="1">
						<input type="Hidden" name="TheDirPath" value="#TheDirPath#">
						<input type="Hidden" name="action1" value="dir1ist1">
						<cfif (obdir Is "Asc") AND (obid Is "Name")>
							<input type="Hidden" name="obdir" value="desc">
						<cfelse>
							<input type="Hidden" name="obdir" value="asc">
						</cfif>
						<th><font size="2"><input type="Radio" <cfif obid Is "Name">checked</cfif> name="obid" value="Name" onclick="submit()" id="Tab1"><label for="Tab1">Name</label></th>
					</form>
					<cfif OSType Is "/">
						<form method="post" action="#ThisPageName#">
							<input type="Hidden" name="tab" value="1">
							<input type="Hidden" name="TheDirPath" value="#TheDirPath#">
							<input type="Hidden" name="action1" value="dir1ist1">
							<cfif (obdir Is "Asc") AND (obid Is "Mode")>
								<input type="Hidden" name="obdir" value="desc">
							<cfelse>
								<input type="Hidden" name="obdir" value="asc">
							</cfif>
							<th><font size="2"><input type="Radio" <cfif obid Is "Mode">checked</cfif> name="obid" value="Mode" onclick="submit()" id="Tab4"><label for="Tab4">Mode</label></font></th>
						</form>
					</cfif>
					<form method="post" action="#ThisPageName#">
						<input type="Hidden" name="tab" value="1">
						<input type="Hidden" name="TheDirPath" value="#TheDirPath#">
						<input type="Hidden" name="action1" value="dir1ist1">
						<cfif (obdir Is "Asc") AND (obid Is "DateLastModified")>
							<input type="Hidden" name="obdir" value="desc">
						<cfelse>
							<input type="Hidden" name="obdir" value="asc">
						</cfif>
						<th><font size="2"><input type="Radio" <cfif obid Is "DateLastModified">checked</cfif> name="obid" value="DateLastModified" onclick="submit()" id="Tab2"><label for="Tab2">Date</label></th>
					</form>
					<form method="post" action="#ThisPageName#">
						<input type="Hidden" name="tab" value="1">
						<input type="Hidden" name="TheDirPath" value="#TheDirPath#">
						<input type="Hidden" name="action1" value="dir1ist1">
						<cfif (obdir Is "Asc") AND (obid Is "Size")>
							<input type="Hidden" name="obdir" value="desc">
						<cfelse>
							<input type="Hidden" name="obdir" value="asc">
						</cfif>
						<th><font size="2"><input type="Radio" <cfif obid Is "Size">checked</cfif> name="obid" value="Size" onclick="submit()" id="Tab3"><label for="Tab3">Size</label></th>
					</form>
				</cfoutput>
				<th><font size="2">Edit</font></th>
				<th><font size="2">Encrypt</font></th>
				<th><font size="2">Rename</font></th>
				<th><font size="2">Move</font></th>
				<th> </th>
				<th><font size="2">Delete</font></th>
			</tr>
			<cfif (OSType Is "/") OR (Page GT 1)>
				<tr>
					<cfoutput>
						<form method="post" action="#ThisPageName#">
							<input type="Hidden" name="tab" value="1">
							<input type="Hidden" name="action1" value="dir1ist1">
							<input type="Hidden" name="obdir" value="#obdir#">
							<input type="Hidden" name="obid" value="#obid#">
							<cfset ipath2 = Reverse("#TheDirPath#")>
							<cfset var2 = Find("#OSType#", "#ipath2#", "2")>
							<cfset var3 = Len("#ipath2#") - #var2#>
							<cfset var4 = Mid("#TheDirPath#", "1", "#var3#")>
							<td><font size="2"><input type="Radio" name="TheDirPath" value="#var4#" onclick="submit()" id="tab"><label for="tab">Move Up</label></font></td>
							<cfif OSType Is "/">
								<td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>
								<td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>
								<td>&nbsp;</td>
							<cfelse>
								<td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>
								<td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>
							</cfif>
						</form>
					</cfoutput>
				</tr>
			</cfif>
			<cfoutput query="check1" startrow="#srow#" maxrows="#maxrows#">
				<cfif name Is Not ".">
					<tr valign="top">
						<cfif type is "Dir">
							<cfif name is "..">
								<form method="post" action="#ThisPageName#">
									<input type="Hidden" name="tab" value="1">
									<input type="Hidden" name="action1" value="dir1ist1">
									<input type="Hidden" name="obdir" value="#obdir#">
									<input type="Hidden" name="obid" value="#obid#">
									<cfset ipath2 = Reverse("#TheDirPath#")>
									<cfset var2 = Find("#OSType#", "#ipath2#", "2")>
									<cfset var3 = Len("#ipath2#") - #var2#>
									<cfset var4 = Mid("#TheDirPath#", "1", "#var3#")>
									<td><font size="2"><input type="Radio" name="TheDirPath" value="#var4#" onclick="submit()" id="tab"><label for="tab">Move Up</label></td>
								</form>
							<cfelse>
								<form method="post" action="#ThisPageName#">
									<input type="Hidden" name="tab" value="1">
									<input type="Hidden" name="action1" value="dir1ist1">
									<input type="Hidden" name="obdir" value="#obdir#">
									<input type="Hidden" name="obid" value="#obid#">
									<td><font size="2"><input type="Radio" name="TheDirPath" value="#TheDirPath##Name#" onclick="submit()" id="tab"><label for="tab">#Name#</label></td>
								</form>
								<cfif OSType Is "/">
									<form method="post" action="#ThisPageName#" onsubmit="return confirm('Click Ok to confirm changing the mode for #Name#')">
										<input type="Hidden" name="tab" value="1">
										<input type="Hidden" name="action1" value="dir1ist1">
										<input type="Hidden" name="obdir" value="#obdir#">
										<input type="Hidden" name="obid" value="#obid#">
										<input type="Hidden" name="TheDirPath" value="#TheDirPath#">
										<input type="Hidden" name="FileName" value="#Name#">
										<td><font size="2"><input type="Text" size="4" name="modevalue" value="#Mode#"><input type="Submit" name="ChngMode" value="Edit"></font></td>
									</form>
								</cfif>
							</cfif>
						<cfelse>
							<cfset TheFileName = Replace(Name," ","_","All")>
							<cfif Mid("#Reverse("#TheDirPath#")#","1","1") Is OSType>
								<td><font size="2"><a href="#ThisPageName#/#TheFileName#?filename=#URLEncodedFormat(TheDirPath)##URLEncodedFormat(Name)#&DownLoadFile=1&tab=1">#Name#</a></font></td>
							<cfelse>
								<td><font size="2"><a href="#ThisPageName#/#TheFileName#?filename=#URLEncodedFormat(TheDirPath)##URLEncodedFormat(Name)#&DownLoadFile=1&tab=1">#Name#</a></font></td>
							</cfif>
							<cfif OSType Is "/">
								<form method="post" action="#ThisPageName#" onsubmit="return confirm('Click Ok to confirm changing the mode for #Name#')">
									<input type="Hidden" name="tab" value="1">
									<input type="Hidden" name="action1" value="dir1ist1">
									<input type="Hidden" name="obdir" value="#obdir#">
									<input type="Hidden" name="obid" value="#obid#">
									<input type="Hidden" name="TheDirPath" value="#TheDirPath#">
									<input type="Hidden" name="FileName" value="#Name#">
									<td><font size="2"><input type="Text" size="4" name="modevalue" value="#Mode#"><input type="Submit" name="ChngMode" value="Edit"></font></td>
								</form>
							</cfif>
						</cfif>
						<td><font size="2"><cfif name is "..">&nbsp;<cfelse>#DateFormat(DateLastModified, 'mm-dd-yy')# #TimeFormat(DateLastModified, 'hh:mm tt')#</cfif></td>
						<td align=right><cfif type is not "Dir"><font size="2">#Size#<cfelse>&nbsp;</cfif></td>
						<cfif type is "Dir">
							<td>&nbsp;</td>
							<td>&nbsp;</td>
						<cfelse>
							<cfset ThisExtension = Reverse(Name)>
							<cfset Pos1 = Find(".","#ThisExtension#") - 1>
							<cfif Pos1 lt 1>
								<cfset ThisExtension = "unknown">
							<cfelse>
								<cfset ThisExtension = Right(Name,Pos1)>
							</cfif>
							<cfif ListFindNoCase("#NoEditTypes#", "#ThisExtension#") Is 0>
								<form method="post" action="#ThisPageName#">
									<input type="hidden" name="apagename" value="#Name#">
									<input type="Hidden" name="TheDirPath" value="#TheDirPath#">
									<input type="hidden" name="page" value="#page#">
									<input type="Hidden" name="tab" value="3">
									<td><font size="2"><input type="submit" name="EditPage" value="Edit"></font></td>
								</form>
								<form method="post" action="#ThisPageName#" onSubmit="return confirm('Click Ok to confirm Encrypting #Name#')">
									<input type="hidden" name="filename" value="#Name#">
									<input type="hidden" name="page" value="#page#">
									<input type="Hidden" name="action1" value="dir1ist1">
									<input type="Hidden" name="TheDirPath" value="#TheDirPath#">
									<input type="Hidden" name="tab" value="1">
									<td><font size="2"><input type="submit" name="Encryptor" value="Encrypt"></font></td>
								</form>
							<cfelse>
								<td>&nbsp;</td>
								<td>&nbsp;</td>
							</cfif>
						</cfif>
						<form method=post action="#ThisPageName#" onSubmit="return confirm('Click Ok to confirm renaming or moving #Name#')">
							<input type="Hidden" name="action1" value="dir1ist1">
							<input type="Hidden" name="TheDirPath" value="#TheDirPath#">
							<input type="hidden" name="filename" value="#Name#">
							<input type="hidden" name="page" value="#page#">
							<input type="Hidden" name="tab" value="1">
							<td><cfif type is not "Dir"><font size="2"><INPUT type="submit" name="renfile" value="Rename"><cfelse>&nbsp;</cfif></td>
							<td><cfif type is not "Dir"><font size="2"><INPUT type="submit" name="movefile" value="Move"><cfelse>&nbsp;</cfif></td>
							<td><cfif type is not "Dir"><input type="text" name="filename1" size="10"><cfelse>&nbsp;</cfif></td>
						</form>
						<form method=post action="#ThisPageName#" onSubmit="return confirm('Click Ok to confirm deleting #Name#')">
							<input type="Hidden" name="action1" value="dir1ist1">
							<input type="Hidden" name="TheDirPath" value="#TheDirPath#">
							<input type="hidden" name="filename" value="#Name#">
							<input type="hidden" name="page" value="#page#">
							<input type="Hidden" name="tab" value="1">
							<cfif (type is "Dir") AND (name is not "..")>
								<td><font size="2"><INPUT type="submit" name="deldir1" value="Del Dir"></font></td>
							<cfelseif name is not "..">
								<td><font size="2"><INPUT type="submit" name="delfile" value="Del File"></font></td>
							<cfelse>
								<td>&nbsp;</td>
							</cfif>
						</form>
					</tr>
				</cfif>
				</cfoutput>
				
			<tr bgcolor="silver">
				<cfoutput>
					<form method="post" action="#ThisPageName#">
						<input type="Hidden" name="TheDirPath" value="#TheDirPath#">
						<input type="Hidden" name="tab" value="1">
				</cfoutput>
					<cfif check1.recordcount gt mrow>
						<td><font size="2"><select name="page" onChange="submit()">
							<cfloop Index="Loopc" from="1" To="#pagenumber#">
								<cfset ArrayPoint = Loopc * mrow - (mrow - 1)>
								<cfif obid is "size">
									<cfset disp = check1.Size[ArrayPoint]>
								<cfelse>
									<cfset disp = check1.Name[ArrayPoint]>
								</cfif>
								<cfoutput><option value="#loopc#" <cfif page is loopc>selected</cfif> >Page #loopc# - #disp#</cfoutput>
							</cfloop>
							<option value="0" <cfif Page Is 0>selected</cfif> >View All							
						</select></font></td>
					<cfelse>
						<td>Page 1</td>
					</cfif>
					<cfoutput>
						<td colspan="#HowWide#" align="center"><font size="2"><input type="submit" name="refreshpage" value="Refresh"></font></td>
					</cfoutput>
				</form>
				<td colspan="7">&nbsp;</td>
			</tr>
		</table>
	</center>
<cfelseif Tab Is 2>
	<!--- MaintQuery --->
	<cfif Not IsDefined("FORM.dsn")>
		<cfif OStype Is "\">
			<cfregistry action="GetAll" type="Any" name="DS1" sort="entry"
		    branch="HKEY_LOCAL_MACHINE\SOFTWARE\Allaire\ColdFusion\CurrentVersion\DataSources">
		<cfelse>
			<CFSET DS1 = cfusion_getodbcdsn()>
		</cfif>
		<center>
		<table border="0">
			<cfif IsDefined("TheDirPath")>
				<cfoutput>
					<tr>
						<form method="post" action="#ThisPageName#">
							<input type="hidden" name="TheDirPath" value="#TheDirPath#">
							<input type="hidden" name="Page" value="#Page#">
							<input type="Hidden" name="tab" value="1">
							<td><font size="2"><input type="submit" name="Cancel" value="Return To File List"></font></td>
						</form>
					</tr>
				</cfoutput>
			</cfif>
			<cfoutput>
				<form method="post" action="#ThisPageName#">
					<cfif IsDefined("TheDirPath")>
						<input type="hidden" name="TheDirPath" value="#TheDirPath#">
						<input type="hidden" name="Page" value="#Page#">
					</cfif>
					<input type="Hidden" name="tab" value="2">
			</cfoutput>
				<tr>
					<th align="right">DataSource</th>
					<td><select name="dsn">
						<cfoutput query="DS1">
							<cfif OSType Is "/">
								<cfset entry = Name>
        						<cfset Value=Description>
								<cfset Type="STRING">
							</cfif>
							<option <cfif entry Is DefODBC>Selected</cfif> value="#entry#">#entry#
						</cfoutput>
					</select></td>
					<td><font size="2"><INPUT TYPE="SUBMIT" VALUE="Run This Query"></font></td>
					<INPUT TYPE="hidden" value="MyQuery" NAME="qname">
				</tr>
				<tr valign="top">
					<th align="right">Records To Return</th>
					<td colspan="2"><input class="input" type="text" name="numrec" value="25" size="5"> 
					<input type="hidden" name="EditMode" value="" size="10"><!--- Enter the name of the IDField  --->
					</td>
				</tr>
				<tr valign="top">
					<th rowspan="2" align="right">Output Fields</th>
					<td align="right"><INPUT TYPE="TEXT" NAME="out1"></td>
					<td><INPUT TYPE="TEXT" NAME="out2"></td>
				</tr>
				<tr>
					<td align="right"><INPUT TYPE="TEXT" NAME="out3"></td>
					<td><INPUT TYPE="TEXT" NAME="out4"></td>
				</tr>
				<tr>
					<td colspan=3><TEXTAREA NAME="quer" ROWS=10 COLS=60>SELECT </TEXTAREA></td>
				</tr>
		</table>
		</center>
	<CFELSE>
		<cfsetting enablecfoutputonly="Yes">
			<cfif FORM.dsn contains "##">
				<cfset datasource = Evaluate("#form.dsn#")>
			<cfelse>
				<cfset datasource = form.dsn>
			</cfif>
			<cfif numrec Is "">
				<cfset numrec = 0>
			<cfelse>
				<cfset numrec = numrec>
			</cfif>
			<cfset TheQuery = Trim(FORM.quer)>
			<cfset sqltype = Mid("#preservesinglequotes(TheQuery)#",1,6)>
			<cfquery NAME=#FORM.qname# DATASOURCE=#datasource# maxrows="#numrec#">
				#preservesinglequotes(FORM.quer)#
			</cfquery>
			<CFSET CNT = 1>
		<cfsetting enablecfoutputonly="No">
		<center>
		<table>
			<tr>
				<cfoutput>
					<cfif IsDefined("TheDirPath")>
						<form method="post" action="#ThisPageName#">
							<input type="hidden" name="TheDirPath" value="#TheDirPath#">
							<input type="hidden" name="Page" value="#Page#">
							<input type="Hidden" name="Tab" value="1">
							<td><font size="2"><input type="submit" name="Cancel" value="Return To File List"></font></td>
						</form>
					</cfif>
					<FORM ACTION="#ThisPageName#" METHOD=POST>
						<cfif IsDefined("TheDirPath")>
							<input type="hidden" name="TheDirPath" value="#TheDirPath#">
							<input type="hidden" name="Page" value="#page#">
						</cfif>
						<input type="Hidden" name="tab" value="2">
						<td><font size="2"><INPUT TYPE=SUBMIT VALUE="New Query"></font></td>
					</FORM>
				</cfoutput>
			</tr>
			<cfif (out1 is "") AND  (out2 is "") AND  (out3 is "") AND  (out4 is "") AND (sqltype is "select")>
				<cfset thelist = Evaluate("#FORM.qname#.columnlist")>
				<cfif Trim(EditMode) Is Not "">
					<cfset var1 = FindNoCase("#EditMode#","#thelist#")>
					<cfif var1 gt 0>
						<cfset thelist = ReplaceNoCase("#thelist#","#EditMode#","")>
						<cfset thelist = "#UCase(EditMode)#," & thelist>
					</cfif>
				</cfif>
				<tr valign="top">
					<td></td>
					<cfloop index="B5" list="#thelist#">
						<cfoutput><th><font size="2">#B5#</font></th></cfoutput>
					</cfloop>
				</tr>
				<cfoutput><form method="post" action="#ThisPageName#"></cfoutput>
					<cfset count1 = 0>
					<cfloop QUERY=#FORM.qname#>
						<cfset count1 = count1 + 1>
						<tr valign="top">
							<cfoutput>
								<td style="background: silver;">#CNT#.</td>
							</cfoutput>
							<cfloop index="B5" list="#thelist#">
								<cfset thevalue=Evaluate("#B5#")>
								<cfoutput>
								<input type="hidden" name="#B5#_old#count1#" value="#thevalue#">
								<cfif Trim(EditMode) Is Not "">
									<cfif (Evaluate("editmode")) Is B5>
										<td style="background: ##ffffff;">#thevalue#</td>
										<input type="hidden" name="#B5##count1#" value="#thevalue#">
									<cfelseif Len(thevalue) gt 100>
										<td style="background: ##ffffff;"><textarea name="#B5##count1#" rows="4" cols="30">#thevalue#</textarea></td>
									<cfelse>
										<td style="background: ##ffffff;"><input type="text" name="#B5##count1#" value="#thevalue#" size="10"></td>
									</cfif>
								<cfelse>
									<td style="background: ##ffffff;">#thevalue#</td>
								</cfif>
								</cfoutput>			
							</cfloop>
							<CFSET #CNT#=#CNT#+1>
						</tr>
					</cfloop>	
					<cfif IsDefined("EditMode")>
						<cfloop index="B5" list="DSN,QNAME,NUMREC,EDITMODE,OUT1,OUT2,OUT3,OUT4,QUER">
							<cfset thevalue = Evaluate("#B5#")>
							<cfoutput>
							<input type="hidden" name="#B5#" value="#thevalue#">
							</cfoutput>
						</cfloop>
						<cfif IsDefined("TheDirPath")>
							<cfoutput>
								<input type="Hidden" name="TheDirPath" value="#TheDirPath#">
								<input type="Hidden" name="Page" value="#Page#">
							</cfoutput>
						</cfif>
					</cfif>
					<tr>
						<td colspan="6"><font size="2"><input type="submit" name="UpdateData" value="Update"></font></td>
					</tr>		
					<input type="Hidden" name="tab" value="2">
				</form>
			<cfelse>
				<cfoutput>
					<tr>
						<th></th>
						<th>#out1#</th>
						<th>#out2#</th>
						<th>#out3#</th>
						<th>#out4#</th>
					</tr>
				</cfoutput>
				<cfif sqltype is "select">
					<cfoutput QUERY=#FORM.qname#>
						<tr bgcolor="white">
							<td bgcolor="silver">#CNT#.</td>
							<td><CFIF #FORM.out1# not equal "">#EVALUATE(FORM.out1)#</CFIF></td>
							<td><CFIF #FORM.out2#  not equal "">#EVALUATE(FORM.out2)#</CFIF></td>
							<td><CFIF #FORM.out3#  not equal "">#EVALUATE(FORM.out3)#</CFIF></td>
							<td><CFIF #FORM.out4#  not equal "">#EVALUATE(FORM.out4)#</CFIF></td>
							<CFSET #CNT#=#CNT#+1>
						</tr>
					</cfoutput>
				<cfelse>
					<tr valign="top">
						<td  style="background: silver;">Query finished.</td>
					</tr>
				</cfif>
			</cfif>
		</table>
		</center>
	</CFIF>
<cfelseif Tab Is 3>
	<!--- MaintPage --->
	<cfsetting enablecfoutputonly="Yes">
	<cfset locatedir = GetDirectoryFromPath(CF_TEMPLATE_PATH)>
	<cfparam name="location1" default="#locatedir#">
	<cfparam name="apagename" default="index.cfm">
	<cfparam name="TheDirPath" default="#Location1#">
	<cfparam name="Page" default="1">
	<cfif IsDefined("updfile")>
		<cffile action="write" file ="#TheDirPath##apagename#" Output="#stripcr(theone)#">
		<cfsetting showdebugoutput="No">
	</cfif>   
	<cffile action="read" file="#TheDirPath##apagename#" Variable="message">
	<cfdirectory action="LIST" directory="#TheDirPath#" name="AllFiles" filter="*.??m*">
	<cfsetting enablecfoutputonly="No">
	<center>
		<table>
			<tr>
				<cfoutput>
				<form method="post" action="#ThisPageName#">
						<input type="hidden" name="TheDirPath" value="#TheDirPath#">
						<input type="hidden" name="Page" value="#page#">
						<input type="Hidden" name="tab" value="1">
					<td><font size="2"><input type="submit" name="Cancel" value="Return To File List"></font></td>
				</form>
				<form method="post" action="#ThisPageName#">
						<input type="hidden" name="Page" value="#page#">
						<input type="hidden" name="TheDirPath" value="#TheDirPath#">
						<input type="Hidden" name="tab" value="3">
				</cfoutput>
					<td><font size="2"><select name="apagename">
						<cfoutput query="AllFiles">
							<option <cfif Name Is apagename>selected</cfif> value="#Name#">#Name#
						</cfoutput>
					</select><INPUT type="submit" value="Edit File" name="SelFile"></font></td>
				</form>
				<cfoutput>
				<form name="info" method="post" action="#ThisPageName#">
						<INPUT type="hidden" name="apagename" value="#apagename#">
						<cfif IsDefined("apagename2")>
							<INPUT type="hidden" name="apagename2" value="#apagename2#">
						</cfif>
						<input type="hidden" name="Page" value="#page#">
						<input type="hidden" name="TheDirPath" value="#TheDirPath#">
						<input type="Hidden" name="tab" value="3">
						<td><font size="2"><INPUT type="submit" value="update file" name="updfile"> -	#TheDirPath##apagename#</font></td>
				</cfoutput>
			</tr>
			<tr>
					<cfoutput><td colspan="3"><textarea name="theone" rows=20 cols=75>#htmleditformat(message)#</textarea></td></cfoutput>
				</form>
			</tr>
		</table>
	</center>
<cfelseif Tab Is 4>
		<!--- MaintRead --->
	<cfset #dropby1# = 1>
	<cfinclude template="license.cfm">
	<cfsetting enablecfoutputonly="no">
	<cfoutput>
		<center>
			<table>
				<tr>
					<td align="right">Server Name:</td>
					<td>#servername1#</td>
				</tr>
				<tr>
					<td align="right">Server IP:</td>
					<td>#serverip1#</td>
				</tr>
				<tr>
					<td align="right">Expires:</td>
					<td>#expdate#</td>
				</tr>
				<tr>
					<td align="right">Max Users:</td>
					<td>#maxuser#</td>
				</tr>
			</table>
		</center>
	</cfoutput>
<cfelseif Tab Is 5>
	<!--- MaintUpgrade --->
	<cfsetting enablecfoutputonly="Yes">
	<cfif (IsDefined("DelOne")) AND (IsDefined("UpgradeID"))>
		<cfquery name="DelData" datasource="#pds#">
			DELETE FROM Upgrades 
			WHERE UpgradeID In (#upgradeid#)
		</cfquery>
	</cfif>
	<cfquery name="GetEm" datasource="#pds#">
		SELECT * 
		FROM upgrades 
		ORDER BY upgradenum desc
	</cfquery>
	
	<cfsetting enablecfoutputonly="no">
	<center>
	<table border="0">
		<tr bgcolor="silver">
			<th>Remove</th>
			<th>Upgrade</th>
			<th>Date</th>
			<th>Upgrade Description</th>
		</tr>
		<cfset color1 = 1>
		<cfoutput><form method="post" name="ViewFolder" action="#ThisPageName#" onSubmit="Return confirm ('Click Ok to confirm deleting the selected upgrades.')"></cfoutput>
			<tr>
				<td colspan="4"><font size="2"><input type="button" name="AllYes" value="Select All" onclick="SelectAll(true)"><input type="button" name="AllNo" value="Deselect All" onclick="SelectAll(false)"></font></td>
			</tr>
			<cfoutput query="getem">
				<cfif color1 is 1>
					<cfset tbclr = "FFBA8E">
					<cfset color1 = 2>
				<cfelse>
					<cfset tbclr = "silver">
					<cfset color1 = 1>
				</cfif>
				<tr bgcolor="#tbclr#" valign="top">
					<th><input type="checkbox" name="UpgradeID" value="#UpgradeID#"></th>
					<td>#upgradenum#</td>
					<td>#LSDateFormat(upgradedate, 'mm/dd/yy')#</td>
					<td>#descrip1# </td>
				</tr>
			</cfoutput>
			<tr>
				<td colspan="4"><font size="2"><input type="submit" name="DelOne" value="Remove"></font></td>
			</tr>
			<input type="Hidden" name="Tab" value="5">
		</form>
	</table>
	</center>
<cfelseif Tab Is 6>
		<!--- MaintValues --->
	<cfsetting enablecfoutputonly="Yes">
		<cfif IsDefined("EditOldOne")>
			<cfquery name="UpdData" datasource="#pds#">
				UPDATE SETUP SET 
				Value1 = <cfif NewValue Is "">NULL<cfelse>'#NewValue#'</cfif>, 
				DateValue1 = <cfif NewDateValue Is "">NULL<cfelse>#CreateODBCDateTime(NewDateValue)#</cfif>, 
				AutoLoadYN = <cfif IsDefined("NewAutoLoadYN")>1<cfelse>0</cfif> 
				WHERE SetupID = #OldSetupID# 
			</cfquery>
		</cfif>
		<cfif IsDefined("AddANewOne")>
			<cfquery name="AddMe" datasource="#pds#">
				INSERT INTO SETUP 
				(VarName,Value1,DateValue1,AutoLoadYN) 
				VALUES 
				('#NewVarName#',
				 <cfif NewValue Is "">NULL<cfelse>'#NewValue#'</cfif>, 
				 <cfif NewDateValue Is "">NULL<cfelse>#CreateODBCDateTime(NewDateValue)#</cfif>, 
				 <cfif IsDefined("NewAutoLoadYN")>1<cfelse>0</cfif>)
			</cfquery>
		</cfif>
		<cfif (IsDefined("DelValues")) AND (IsDefined("DeleteID"))>
			<cfquery name="DelData" datasource="#pds#">
				DELETE FROM Setup 
				WHERE SetupID In (#DeleteID#)
			</cfquery>
		</cfif>
		<cfif IsDefined("Toggle")>
			<cftransaction>
				<cfquery name="UpdData" datasource="#pds#">
					UPDATE Setup SET 
					AutoLoadYN = 0 
				</cfquery>
				<cfquery name="UpdData" datasource="#pds#">
					UPDATE Setup SET 
					AutoLoadYN = 1 
					WHERE SetupID In (#AutoLoadYN#) 
				</cfquery>
			</cftransaction>
		</cfif>
		<cfquery name="AllValues" datasource="#pds#">
			SELECT * 
			FROM setup 
			<cfif IsDefined("SetupID")>
				WHERE SetupID = #SetupID# 
			</cfif>
			ORDER BY varname
		</cfquery>
	<cfsetting enablecfoutputonly="No">
	<center>
	<table>
		<cfset color1 = 1>
		<cfoutput><form method="post" action="#ThisPageName#"></cfoutput>
			<cfif (IsDefined("AddNewValue")) OR (IsDefined("SetupID"))>
				<tr bgcolor="Silver">
					<cfif IsDefined("SetupID")>
						<th colspan="6">Edit Value</th>
					<cfelse>
						<th colspan="6">New Value</th>
					</cfif>
				</tr>
				<tr bgcolor="Silver">
					<td>&nbsp;</td>
					<th>AutoLoad</th>
					<th>Variable Name</th>
					<th>Value</th>
					<th>Date Value</th>
					<th>&nbsp;</th>
				</tr>
				<tr>
					<td>&nbsp;</td>
					<cfif IsDefined("SetupID")>
						<td><input type="Checkbox" <cfif AllValues.AutoLoadYN Is "1">checked</cfif> name="NewAutoLoadYN" value="1"></td>
					<cfelse>
						<td><input type="Checkbox" name="NewAutoLoadYN" value="1"></td>
					</cfif>
					<cfif IsDefined("SetupID")>
						<cfoutput><td>#AllValues.VarName#</td></cfoutput>
					<cfelse>
						<td><input type="Text" name="NewVarName"></td>
					</cfif>
					<cfoutput>
						<td><input type="Text" <cfif IsDefined("SetupID")>value="#AllValues.Value1#"</cfif> name="NewValue"></td>
						<td><input type="Text" <cfif IsDefined("SetupID")>value="#AllValues.DateValue1#"</cfif> name="NewDateValue"></td>
					</cfoutput>
					<cfif IsDefined("SetupID")>
						<td><input type="Submit" name="EditOldOne" value="Edit"></td>
						<cfoutput><input type="Hidden" name="OldSetupID" value="#SetupID#"></cfoutput>
					<cfelse>
						<td><input type="Submit" name="AddANewOne" value="Add"></td>
					</cfif>
				</tr>
			<cfelse>
				<tr>
					<td colspan="6" align="right"><input type="Submit" name="AddNewValue" value="Add New Value"></td>
				</tr>
			</cfif>
			<tr bgcolor="silver">
				<th>Edit</th>
				<th>Auto Load</th>
				<th>Variable</th>
				<th>Value</th>
				<th>Date Value</th>
				<th>Delete</th>
			</tr>
			<cfoutput query="allvalues">
				<cfif color1 is 1>
					<cfset tbclr = "FFBA8E">
					<cfset color1 = 2>
				<cfelse>
					<cfset tbclr = "silver">
					<cfset color1 = 1>
				</cfif>
				<tr bgcolor="#tbclr#">
					<th><input type="Radio" name="SetupID" value="#SetupID#" onclick="submit()"></th>
					<td><input type="checkbox" <cfif AutoLoadYN Is 1>checked</cfif> name="AutoLoadYN" value="#SetupID#"></td>
					<td>#VarName#</td>
					<td>#Value1# </td>
					<td>#DateValue1# </td>
					<td><input type="checkbox" name="DeleteID" value="#SetupID#"></td>
				</tr>
			</cfoutput>
			<tr>
				<th><font size="2"><input type="submit" name="Toggle" value="Set Loads"></font></th>
				<td colspan="4"></td>
				<th><font size="2"><input type="submit" name="DelValues" value="Delete"></font></th>
			</tr>
			<input type="Hidden" name="Tab" value="6">
		</form>
	</table>
	</center>
<cfelseif tab Is "7">
	<cfsetting enablecfoutputonly="Yes">
		<cfif (IsDefined("DelSelected")) AND (IsDefined("DelErrorID"))>
			<cfquery name="DelSelectedOnes" datasource="#pds#">
				DELETE FROM ErrorLog 
				WHERE ErrorID In (#DelErrorID#)
			</cfquery>
		</cfif>
		<cfparam name="OBID" default="ErrDateTime">
		<cfparam name="OBDir" default="desc">
		<cfquery name="ErrorLogInfo" datasource="#pds#" maxrows="75">
			SELECT * 
			FROM ErrorLog 
			<cfif IsDefined("ErrorID")>
				WHERE ErrorID = #ErrorID# 
			</cfif>
			ORDER BY #OBID# #OBDir# 
		</cfquery>
		<cfset color1 = 1>
		<cfparam name="LRow" default="25">
		<cfparam name="Pg" default="1">
		<cfif Pg Is 0>
			<cfset Srow = 1>
			<cfset Mrow = ErrorLogInfo.RecordCount>
		<cfelse>
			<cfset Srow = (LRow * PG) - (LRow - 1)>
			<cfset Mrow = LRow>
		</cfif>
		<cfset PageNumber = Ceiling(ErrorLogInfo.RecordCount/LRow)>
	<cfsetting enablecfoutputonly="No">
	<br>
	<br>
	<center>
	<cfif ErrorLogInfo.RecordCount Is 1>
	</center>
	<form method="post" action="maintadmin.cfm">
		<input type="Submit" name="GoBack" value="Go Back">
		<cfoutput><input type="Hidden" name="Pg" value="#Pg#"></cfoutput>
		<input type="Hidden" name="tab" value="7">
	</form>
	<center>
		<cfoutput query="ErrorLogInfo">
		<table border="2">
			<tr valign="top">
				<td align="right" bgcolor="Silver">Date Time</td>
				<td bgcolor="FFBA8E">#DateFormat(ErrDateTime, 'mmm/dd/yy')# #TimeFormat(ErrDateTime, 'hh:mm tt')#</td>
			</tr>
			<tr valign="top">
				<td align="right" bgcolor="Silver">Address</td>
				<td bgcolor="FFBA8E">#Addr#</td>
			</tr>
			<tr valign="top">
				<td align="right" bgcolor="Silver">Template</td>
				<td bgcolor="FFBA8E">#Template#</td>
			</tr>
			<tr valign="top">
				<td align="right" bgcolor="Silver">Referrer</td>
				<td bgcolor="FFBA8E">#Referrer#</td>
			</tr>
			<tr valign="top">
				<td align="right" bgcolor="Silver">Browser</td>
				<td bgcolor="FFBA8E">#Browser#</td>
			</tr>
			<tr valign="top">
				<td align="right" bgcolor="Silver">Diag</td>
				<td bgcolor="FFBA8E">#Diag#</td>
			</tr>
			<tr valign="top">
				<td align="right" bgcolor="Silver">QString</td>
				<td bgcolor="FFBA8E">#QString#<cfif QString Is "">&nbsp;</cfif></td>
			</tr>
			<tr valign="top">
				<td align="right" bgcolor="Silver">EMail</td>
				<td bgcolor="FFBA8E">#EMail#</td>
			</tr>
		</table>
		</cfoutput>
	<cfelse>
		<table border="2">
			<tr>	
				<form method="post" action="maintadmin.cfm">
					<td colspan="6"><select name="Pg" onchange="submit()">
						<cfloop index="B5" from="1" to="#PageNumber#">
							<cfoutput><option <cfif B5 Is Pg>selected</cfif> value="#B5#">Page #B5#</cfoutput>
						</cfloop>
					</select></td>
					<input type="Hidden" name="tab" value="7">
				</form>
			</tr>
			<tr>
				<th>View</th>
				<th>Date</th>
				<th>Address</th>
				<th>EMail</th>
				<th>Template</th>
				<th>Delete</th>
			</tr>
			<form method="post" action="maintadmin.cfm" onsubmit="return confirm('Click Ok to confirm deleting the selected errors from the error log.')">
				<input type="Hidden" name="tab" value="7">
				<cfoutput><input type="Hidden" name="pg" value="#Pg#"></cfoutput>
				<cfoutput query="ErrorLogInfo" startrow="#Srow#" maxrows="#Mrow#">
					<cfif color1 is 1>
						<cfset tbclr = "FFBA8E">
						<cfset color1 = 2>
					<cfelse>
						<cfset tbclr = "silver">
						<cfset color1 = 1>
					</cfif>
					<tr bgcolor="#tbclr#">
						<th><input type="Radio" name="ErrorID" value="#ErrorID#" onclick="submit()"></th>
						<td>#DateFormat(ErrDateTime, 'mmm/dd/yy')# #TimeFormat(ErrDateTime, 'hh:mm tt')#</td>
						<td>#Addr#</td>
						<td>#EMail#</td>
						<td>#Template#</td>
						<th><input type="Checkbox" name="DelErrorID" value="#ErrorID#"></th>
					</tr>
				</cfoutput>
				<tr>
					<th colspan="6"><input type="Submit" name="DelSelected" value="Delete Checked"></th>
				</tr>
			</form>
		</table>
	</cfif>
	</center>
	<br>
	<br>
<cfelseif tab Is 8>
	<cfsetting enablecfoutputonly="Yes">
		<cfif IsDefined("ConnectTo")>
			<cfparam name="FTPDirectory" default="\">
			<cfif IsDefined("ChDir") AND (IsDefined("NewDir") AND NewDir Is Not "")>
				<cfset FTPDirectory = NewDir>
			</cfif>
			<cfftp action="OPEN" server="#ServerName#" username="#Login#" password="#PassWord#" 
			 connection="AdminFTP">
	
			<cfif IsDefined("MoveRight")AND (IsDefined("LocalFiles"))>
				<cfloop index="B4" list="#LocalFiles#">
					<cfftp action="PUTFILE" connection="AdminFTP" transfermode="Auto" 
					 localfile="#TheDirPath##B4#" remotefile="#FTPDirectory#/#B4#" > 
				</cfloop>
			</cfif>
			<cfif IsDefined("DeleteREm") AND (IsDefined("TheFiles"))>
				<cfloop index="B2" list="#TheFiles#">
					<cfftp action="REMOVE" connection="AdminFTP" 
					 item="#FTPDirectory#/#B2#"> 
				</cfloop>
			</cfif>
	 
			<cfftp action="LISTDIR" connection="AdminFTP" name="FileList" directory="#FTPDirectory#">
			
			<cfif IsDefined("MoveLeft")AND (IsDefined("TheFiles"))>
				<cfloop index="B5" list="#TheFiles#">
					<cfftp action="GETFILE" connection="AdminFTP" transfermode="Auto" failifexists="No" 
					 localfile="#TheDirPath##B5#" remotefile="#FTPDirectory#/#B5#" > 
				</cfloop>
			</cfif>
			
			<cfftp action="CLOSE" connection="AdminFTP">
	
		</cfif>
	
		<cfif IsDefined("ChLDir") AND (IsDefined("NewLDir") AND NewLDir Is Not "")>
			<cfset TheDirPath = NewLDir>
			<cfif Right(TheDirPath,1) Is Not "\">
				<cfset TheDirPath = TheDirPath & "\">
			</cfif>
		</cfif>
		<cfif IsDefined("DeleteEm") AND IsDefined("LocalFiles")>
			<cfloop index="B3" list="#LocalFiles#">
				<cffile action="DELETE" file="#TheDirPath##B3#">
			</cfloop>
		</cfif>
	
		<cfset DefPath = GetDirectoryFromPath("#CF_TEMPLATE_PATH#")>
		<cfparam name="TheDirPath" default="#DefPath#">
	
		<cfset Len1 = Len(TheDirPath) - 1>
		<cfset TheDir = Left(TheDirPath,Len1)>
		<cfdirectory Action="List" Name="check1" Sort="Type, Name" Directory="#TheDir#">
		
	<cfsetting enablecfoutputonly="No">
	<center>
	<table border="2">
		<form method="post" action="maintadmin.cfm">
			<tr>
				<cfoutput>
					<td colspan="2">Local: #TheDirPath#</td>
					<td>&nbsp;</td>
					<cfif IsDefined("ConnectTo")>
						<td colspan="2">Remote: #Replace(FTPDirectory,"\/","")#<cfif FTPDirectory Is "\/">/</cfif></td>
					<cfelse>
						<td colspan="2">Remote: Connection Information</td>
					</cfif>
				</cfoutput>
			</tr>
			<tr valign="top">
				<td><input type="Text" name="NewLDir" size="6"><br><input type="submit" name="ChLDir" value="Change"></td>
				<td><select name="TheDirPath" size="5" onchange="submit()">
					<cfset ipath2 = Reverse("#TheDirPath#")>
					<cfset var2 = Find("#OSType#", "#ipath2#", "2")>
					<cfset var3 = Len("#ipath2#") - #var2#>
					<cfset var4 = Mid("#TheDirPath#", "1", "#var3#")>
					<cfoutput query="Check1">
						<cfif Name Is ".">
						<cfelseif Name Is "..">
							<option value="#var4#\">Move Up
						<cfelse>
							<cfif Type Is "Dir">
								<option value="#TheDirPath##Name#\">#Name#
							</cfif>
						</cfif>
					</cfoutput>
					<cfoutput><option value="#var4#">______________________________</cfoutput>
				</select></td>
				<cfoutput>
					<input type="Hidden" name="tab" value="8">
					<cfif IsDefined("ConnectTo")>
						<input type="Hidden" name="ConnectTo" value="Connect">
						<input type="Hidden" name="ServerName" value="#ServerName#">
						<input type="Hidden" name="Login" value="#Login#">
						<input type="Hidden" name="Password" value="#Password#">
					</cfif>
					<cfif IsDefined("FTPDirectory")>
						<input type="Hidden" name="FTPDirectory" value="#FTPDirectory#">
					</cfif>
				</cfoutput>
		</form>
		<form method="post" action="maintadmin.cfm">
				<cfif IsDefined("ConnectTo")>
					<td>Directory</td>
					<td><select name="FTPDirectory" size="5" onchange="submit()">
						<cfif FTPDirectory Is Not "\/">
							<cfset ipath2 = Reverse("#FTPDirectory#")>
							<cfset var2 = Find("/", "#ipath2#", "2")>
							<cfset var3 = Len("#ipath2#") - #var2#>
							<cfset var4 = Mid("#FTPDirectory#", "1", "#var3#")>
							<cfoutput><option value="#var4#">Move Up</cfoutput>
						</cfif>
						<cfoutput query="FileList">
							<cfif Attributes Is "Directory">
								<option value="#Path#">#Name#
							</cfif>
						</cfoutput>
						<option value="">______________________________
					</select></td>
					<td><input type="Text" name="NewDir" size="6"><br><input type="submit" name="ChDir" value="Change"></td>
				</tr>
				<cfoutput>
					<input type="Hidden" name="tab" value="8">
					<cfif IsDefined("ConnectTo")>
						<input type="Hidden" name="ConnectTo" value="Connect">
						<input type="Hidden" name="ServerName" value="#ServerName#">
						<input type="Hidden" name="Login" value="#Login#">
						<input type="Hidden" name="Password" value="#Password#">
					</cfif>
					<cfif IsDefined("TheDirPath")>
						<input type="Hidden" name="TheDirPath" value="#TheDirPath#">
					</cfif>
				</cfoutput>
		</form>
		<form method="post" action="maintadmin.cfm">
				<cfoutput>
					<input type="Hidden" name="tab" value="8">
					<cfif IsDefined("ConnectTo")>
						<input type="Hidden" name="ConnectTo" value="Connect">
						<input type="Hidden" name="ServerName" value="#ServerName#">
						<input type="Hidden" name="Login" value="#Login#">
						<input type="Hidden" name="Password" value="#Password#">
					</cfif>
					<cfif IsDefined("FTPDirectory")>
						<input type="Hidden" name="FTPDirectory" value="#FTPDirectory#">
					</cfif>
					<cfif IsDefined("TheDirPath")>
						<input type="Hidden" name="TheDirPath" value="#TheDirPath#">
					</cfif>
				</cfoutput>
				<tr valign="top">
					<td><input type="Submit" name="DeleteEm" value="Delete"><br>
					<input type="Submit" name="Refresh" value="Refresh"></td>
					<td><select name="LocalFiles" multiple size="10">
						<cfoutput query="Check1">
							<cfif Name Is ".">
							<cfelseif Name Is "..">
							<cfelse>
								<cfif Type Is NOT "Dir">
									<option value="#Name#">#Name#
								</cfif>
							</cfif>
						</cfoutput>
						<option value="">______________________________
					</select></td>
					<td valign="middle"><input type="Submit" name="MoveRight" value="Move >">
		</form>
		<form method="post" action="maintadmin.cfm">
					<input type="Submit" name="MoveLeft" value="Move <"></td>
					<td><select name="TheFiles" multiple size="10">
						<cfoutput query="FileList">
							<cfif Attributes Is NOT "Directory">
								<option value="#Name#">#Name#
							</cfif>
						</cfoutput>
						<option value="">______________________________
					</select></td>
					<td><input type="Submit" name="DeleteREm" value="Delete"><br>
					<input type="Submit" name="Refresh" value="Refresh"></td>
				<cfelse>
					<td>&nbsp;</td>
					<td>
						<table border="0">
							<tr>
								<th>Server</th>
								<td><input type="Text" name="servername" value=""></td>
							</tr>
							<tr>
								<th>Login</th>
								<td><input type="Text" name="Login" value=""></td>
							</tr>
							<tr>
								<th>Password</th>
								<td><input type="Password" name="Password" value=""></td>
							</tr>
							<tr>
								<th colspan="2"><input type="Submit" name="ConnectTo" value="Connect"></th>
							</tr>
						</table>
					</td>
				</cfif>
			</tr>
			<cfoutput>
				<input type="Hidden" name="tab" value="8">
				<cfif IsDefined("ConnectTo")>
					<input type="Hidden" name="ConnectTo" value="Connect">
					<input type="Hidden" name="ServerName" value="#ServerName#">
					<input type="Hidden" name="Login" value="#Login#">
					<input type="Hidden" name="Password" value="#Password#">
				</cfif>
				<cfif IsDefined("FTPDirectory")>
					<input type="Hidden" name="FTPDirectory" value="#FTPDirectory#">
				</cfif>
				<cfif IsDefined("TheDirPath")>
					<input type="Hidden" name="TheDirPath" value="#TheDirPath#">
				</cfif>
			</cfoutput>
		</form>
	</table>
	</center>
</cfif>
<center>
<table>
	<tr>
		<cfoutput>
			<th><a href="#ThisPageName#?Tab=2">Query Builder</a></th>
			<th><a href="#ThisPageName#?Tab=1">Maintain Files</a></th>
			<th><a href="#ThisPageName#?Tab=3">Page Editor</a></th>
			<th><a href="#ThisPageName#?Tab=8">FTP</a></th>
			<cfif gBillInstall Is 1>
				<th><a href="#ThisPageName#?Tab=6">Setup Values</a></th>
				<th><a href="#ThisPageName#?Tab=7">Error Log</a></th>
				<th><a href="#ThisPageName#?Tab=5">Auto Add Updates</a></th>
				<th><a href="#ThisPageName#?Tab=4">License Values</a></th>
				<th><a href="admin.cfm">Main Menu</a></th>
			</cfif>
		</cfoutput>
	</tr>
</table>
</center>
</BODY>
</HTML>

</cfif>
 
<cfsetting enablecfoutputonly="Yes">
<!--- Version 4.0.0 --->
<!--- This page is for selecting which domains a plan has access to.
--->
<!---	4.0.0 07/19/99 --->
<!--- plantab8.cfm --->
<cfsetting enablecfoutputonly="No">
<form method="post" action="listplan2.cfm">
<cfoutput>
	<input type="hidden" name="tab" value="#tab#">
	<input type="hidden" name="page" value="#page#">
	<input type="hidden" name="obid" value="#obid#">
	<input type="hidden" name="obdir" value="#obdir#">
	<input type="hidden" name="planid" value="#planid#">
	<tr bgcolor="#thclr#">
		<th>Domains</th>
		<th>Action</th>
		<th>Domains available for Auth Integration</th>
	</tr>
	<tr bgcolor="#tdclr#">
</cfoutput>
		<td><select name="WantIn" multiple size="6">
			<cfoutput query="AllADomains">
				<option value="#DomainID#">#DomainName#
			</cfoutput>
			<option value="0">______________________________
		</select></td>
		<td align="center" valign="middle">
			<input type="submit" name="MvRt8a" value="---->"><br>
			<input type="submit" name="MvLt8a" value="<----"><br>
		</td>
		<td><select name="HaveIt" multiple size="6">
			<cfoutput query="GetSelADomains">
				<option value="#DomainID#">#DomainName#
			</cfoutput>
			<option value="0">______________________________
		</select></td>
	</tr>
</form>
<form method="post" action="listplan2.cfm">
<cfoutput>
	<input type="hidden" name="tab" value="#tab#">
	<input type="hidden" name="page" value="#page#">
	<input type="hidden" name="obid" value="#obid#">
	<input type="hidden" name="obdir" value="#obdir#">
	<input type="hidden" name="planid" value="#planid#">
	<tr bgcolor="#thclr#">
		<th>Domains</th>
		<th>Action</th>
		<th>Domains available for EMail Integration</th>
	</tr>
	<tr bgcolor="#tdclr#">
</cfoutput>
		<td><select name="WantIn" multiple size="6">
			<cfoutput query="AllDomains">
				<option value="#DomainID#">#DomainName#
			</cfoutput>
			<option value="0">______________________________
		</select></td>
		<td align="center" valign="middle">
			<input type="submit" name="MvRt8" value="---->"><br>
			<input type="submit" name="MvLt8" value="<----"><br>
		</td>
		<td><select name="HaveIt" multiple size="6">
			<cfoutput query="GetSelDomains">
				<option value="#DomainID#">#DomainName#
			</cfoutput>
			<option value="0">______________________________
		</select></td>
	</tr>
</form>
<form method="post" action="listplan2.cfm">
<cfoutput>
	<input type="hidden" name="tab" value="#tab#">
	<input type="hidden" name="page" value="#page#">
	<input type="hidden" name="obid" value="#obid#">
	<input type="hidden" name="obdir" value="#obdir#">
	<input type="hidden" name="planid" value="#planid#">
	<tr bgcolor="#thclr#">
		<th>Domains</th>
		<th>Action</th>
		<th>Domains available for FTP Integration</th>
	</tr>
	<tr bgcolor="#tdclr#">
</cfoutput>
		<td><select name="WantIn" multiple size="6">
			<cfoutput query="AllFDomains">
				<option value="#DomainID#">#DomainName#
			</cfoutput>
			<option value="0">______________________________
		</select></td>
		<td align="center" valign="middle">
			<input type="submit" name="MvRt8f" value="---->"><br>
			<input type="submit" name="MvLt8f" value="<----"><br>
		</td>
		<td><select name="HaveIt" multiple size="6">
			<cfoutput query="GetSelFDomains">
				<option value="#DomainID#">#DomainName#
			</cfoutput>
			<option value="0">______________________________
		</select></td>
	</tr>
</form>
 

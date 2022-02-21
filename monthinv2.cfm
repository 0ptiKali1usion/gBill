<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This is page 2 of the debitor. --->
<!--- 4.0.0 09/14/99 --->
<!--- monthinv2.cfm --->

<cfif (IsDefined("RemoveSelected.x")) AND (IsDefined("RemoveID"))>
	<cfquery name="Remove" datasource="#pds#">
		DELETE FROM TempDebit 
		WHERE DebitID In (#RemoveID#)
	</cfquery>
</cfif>
<cfif IsDefined("StartDebit.x")>
	<cfquery name="UpdDebiter" datasource="#pds#">
		UPDATE TempDebit SET 
		SelectedLetter = #SelectedLetter# 
		WHERE AdminID = #MyAdminID# 
	</cfquery>
	<cfsetting enablecfoutputonly="no">
	<cfinclude template="monthinv3.cfm">
	<cfabort>
</cfif>
<cfparam name="Page" default="1">
<cfparam name="obid" default="Name">
<cfparam name="obdir" default="asc">
<cfquery name="AllDebits" datasource="#pds#">
	SELECT * 
	FROM TempDebit 
	WHERE AdminID = #MyAdminID# 
	ORDER BY <cfif obid Is "Name">LastName #obdir#, FirstName #obdir#<cfelse>#obid# #obdir#</cfif>
</cfquery>
<cfquery name="GetLetters" datasource="#pds#">
	SELECT IntID, IntDesc 
	FROM Integration 
	WHERE ActiveYN = 1 
	AND Action = 'Letter' 
	<cfif GetOpts.SendEmail Is 0>
		AND IntID = 0 
	</cfif>
</cfquery>
<cfif Page Is 0>
	<cfset Srow = 1>
	<cfset Maxrows = AllDebits.Recordcount>
<cfelse>
	<cfset Srow = (Page*Mrow)-(Mrow-1)>
	<cfset Maxrows = Mrow>
</cfif>
<cfset PageNumber = Ceiling(AllDebits.Recordcount/Mrow)>
<cfquery name="TotalDue" datasource="#pds#">
	SELECT Sum(DebitAmount-DebitDiscount) AS TD, 
	Sum(TotalTax1 + TotalTax2 + TotalTax3 + TotalTax4) AS TX 
	FROM TempDebit 
	WHERE AdminID = #MyAdminID#
</cfquery>

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
<title>Debit Totals</title>
<script language="javascript">
<!--  
function SelectAll(tf)
	{
	 var len = document.Results.RemoveID.length;
	 var i;  
	 for(i=0; i<len; i++) 
		{
		 document.Results.RemoveID[i].checked=tf;
		}
	}
// -->
</script>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset# onLoad="self.focus()"></cfoutput>
<cfinclude template="header.cfm">
<form method="post" action="monthinv.cfm">
<input type="image" src="images/return.gif" border="0">
</form>
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="8" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#perFontName#"</cfif> color="#ttfont#">Customer Debit Amounts</font></th>
	</tr>
</cfoutput>
<cfif AllDebits.Recordcount Is 0>
	<tr>
		<cfoutput>
			<th colspan="8" bgcolor="#tbclr#">There is no one to debit with the selected criteria.</th>
		</cfoutput>
	</tr>
<cfelse>
	<cfif AllDebits.Recordcount GT Mrow>
		<tr>
			<form method="post" action="monthinv2.cfm">
				<cfoutput>
					<input type="hidden" name="obid" value="#obid#">
					<input type="hidden" name="obdir" value="#obdir#">
				</cfoutput>
				<td colspan="8"><select name="Page" onchange="submit()">
					<cfloop index="B5" from="1" to="#PageNumber#">
						<cfset ArrayPoint = (B5*Mrow)-(Mrow-1)>
						<cfset DispStr = AllDebits.LastName[ArrayPoint]>
						<cfoutput><option <cfif Page Is B5>selected</cfif> value="#B5#">Page #B5# - #DispStr#</cfoutput>
					</cfloop>
					<cfoutput><option <cfif Page Is 0>selected</cfif> value="0">View All - #AllDebits.Recordcount#</cfoutput>
				</select></td>
			</form>
		</tr>
	</cfif>
	<form method="post" name="Results" action="monthinv2.cfm?RequestTimeout=500">
		<tr valign="top">
			<td colspan="8"><select name="SelectedLetter">
				<option value="0">None
				<cfloop query="GetLetters">
					<cfoutput><option <cfif IntID Is AllDebits.SelectedLetter>selected</cfif> value="#IntID#">#IntDesc#</cfoutput>
				</cfloop>
			</select><input type="image" src="images/debitall.gif" name="StartDebit" border="0"></td>
		</tr>
		<cfoutput>
		<tr bgcolor="#thclr#" valign="top">
			<th>Remove<br><font size="1"><a href="javascript:SelectAll(true)">Select</a> <a href="javascript:SelectAll(false)">Clear</a></font></th>
			<th>Name</th>
			<th colspan="2">Dates</th>
			<th>Totals</th>
			<th colspan="3">Description</th>
		</tr>
		</cfoutput>
		<cfoutput>
			<input type="hidden" name="Page" value="#Page#">
			<input type="hidden" name="obid" value="#obid#">
			<input type="hidden" name="obdir" value="#obdir#">
		</cfoutput>
		<cfset ISPDue = 0>
		<cfset GovDue = 0>
	<cfoutput query="AllDebits" startrow="#Srow#" maxrows="#Maxrows#">
		<tr valign="top" bgcolor="#tbclr#">
			<th rowspan="3" bgcolor="#tdclr#"><input type="checkbox" name="RemoveID" value="#DebitID#"></th>
			<td bgcolor="#tdclr#"><a href="custinf1.cfm?accountid=#AccountID#">#LastName#, #FirstName#</a></td>
			<td>From</td>
			<td>#LSDateFormat(DebitFromDate, '#DateMask1#')#</td>
			<td align="right">#LSCurrencyFormat(DebitAmount)#</td>
			<td colspan="3">#MemoField#</td>
		</tr>
		<tr valign="top" bgcolor="#tbclr#">
			<td><cfif Trim(EMailAddr) Is "">&nbsp;<cfelse><a href="mailto.cfm?email=#EMailAddr#">#EMailAddr#</a></cfif></td>
			<td>To</td>
			<td>#LSDateFormat(DebitToDate, '#DateMask1#')#</td>
			<td align="right">#LSCurrencyFormat(DebitDiscount)#</td>
			<td colspan="3">#MemoDiscount#</td>
		</tr>
		<tr valign="top" bgcolor="#tbclr#">
			<cfif PayBy Is "ck">
				<td>Check/Cash</td>
			<cfelseif PayBy Is "cc">
				<td>Credit Card</td>
			<cfelseif PayBy Is "cd">
				<td>Check Debit</td>
			<cfelseif PayBy Is "po">
				<td>Purchase Order</td>
			</cfif>
			<td>Due</td>
			<td>#LSDateFormat(PayDueDate, '#DateMask1#')#</td>
			<cfif TotalTax1 Is "">
				<cfset LocTotalTax1 = 0>
			<cfelse>
				<cfset LocTotalTax1 = TotalTax1>
			</cfif>
			<cfif TotalTax2 Is "">
				<cfset LocTotalTax2 = 0>
			<cfelse>
				<cfset LocTotalTax2 = TotalTax2>
			</cfif>
			<cfif TotalTax3 Is "">
				<cfset LocTotalTax3 = 0>
			<cfelse>
				<cfset LocTotalTax3 = TotalTax3>
			</cfif>
			<cfif TotalTax4 Is "">
				<cfset LocTotalTax4 = 0>
			<cfelse>
				<cfset LocTotalTax4 = TotalTax4>
			</cfif>
			<cfset TaxAmount = LocTotalTax1 + LocTotalTax2 + LocTotalTax3 + LocTotalTax4>
			<td align="right">#LSCurrencyFormat(TaxAmount)#</td>
			<td>Tax</td>
			<cfset TotalAmount = DebitAmount - DebitDiscount + TaxAmount>
			<td align="right">#LSCurrencyFormat(TotalAmount)#</td>
			<td>Total Due</td>
			<cfset ISPDue = ISPDue + DebitAmount -DebitDiscount>
			<cfset GovDue = GovDue + TaxAmount>
		</tr>
	</cfoutput>
		<cfoutput>
			<tr bgcolor="#thclr#">
				<td colspan="3">Page Totals</td> 
				<td align="right">Total Due</td>
				<td align="right">#LSCurrencyFormat(ISPDue)#</td>
				<td>&nbsp;</td>
				<td align="right">#LSCurrencyFormat(GovDue)#</td>
				<td>Total Tax</td>
			</tr>
			<tr bgcolor="#thclr#">
				<td colspan="3">Grand Totals</td>
				<td align="right">Total Due</td>
				<td align="right">#LSCurrencyFormat(TotalDue.TD)#</td>
				<td>&nbsp;</td>
				<td align="right">#LSCurrencyFormat(TotalDue.TX)#</td>
				<td>Total Tax</td>
			</tr>
		</cfoutput>
		<tr>
			<th colspan="8"><input type="image" src="images/remove.gif" name="RemoveSelected" border="0"></th>
		</tr>
	</form>
	<cfif AllDebits.Recordcount GT Mrow>
		<tr>
			<form method="post" action="monthinv2.cfm">
				<cfoutput>
					<input type="hidden" name="obid" value="#obid#">
					<input type="hidden" name="obdir" value="#obdir#">
				</cfoutput>
				<td colspan="8"><select name="Page" onchange="submit()">
					<cfloop index="B5" from="1" to="#PageNumber#">
						<cfset ArrayPoint = (B5*Mrow)-(Mrow-1)>
						<cfset DispStr = AllDebits.LastName[ArrayPoint]>
						<cfoutput><option <cfif Page Is B5>selected</cfif> value="#B5#">Page #B5# - #DispStr#</cfoutput>
					</cfloop>
					<cfoutput><option <cfif Page Is 0>selected</cfif> value="0">View All - #AllDebits.Recordcount#</cfoutput>
				</select></td>
			</form>
		</tr>
	</cfif>
</cfif>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>



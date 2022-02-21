<cfsetting enablecfoutputonly="Yes">
<!--- Version 4.0.0 --->
<!--- This page selects the date range for session history reports. --->
<!--- dateselect.cfm --->
<!--- Parameters: StartDateSelect, StartDateDropDnS, StartDateDropDnE, EndDateSelect, EndDateDropDnS, EndDateDropDnE	
			StartDateSelect	- The Date to be Selected in the From Row
			StartDateDropDnS	- The Minimun Year in the From Row year dropdown
			StartDateDropDnE	- The Maximun Year in the From Row year dropdown
			EndDateSelect		- The Date to be Selected in the To Row
			EndDateDropDnS		- The Minimun Year in the To Row year dropdown
			EndDateDropDnE		- The Maximun Year in the To Row year dropdown
--->
<cfparam name="StartDateSelect" default="#Now()#">
<cfparam name="StartDateDropDnS" default="#Now()#">
<cfparam name="StartDateDropDnE" default="#DateAdd("yyyy",1,StartDateDropDnS)#">
<cfparam name="EndDateSelect" default="#Now()#">
<cfparam name="EndDateDropDnS" default="#Now()#">
<cfparam name="EndDateDropDnE" default="#DateAdd("yyyy",1,EndDateDropDnS)#">
<!--- From Row --->
<cfset SelSMonth = Month(StartDateSelect)>
<cfset NumSDays = DaysInMonth(StartDateSelect)>
<cfset SelSDay = Day(StartDateSelect)>
<cfset SelSYear = Year(StartDateSelect)>
<cfset MinSYear = Year(StartDateDropDnS)>
<cfset MaxSYear = Year(StartDateDropDnE)>
<!--- To Row --->
<cfset SelEMonth = Month(EndDateSelect)>
<cfset NumEDays = DaysInMonth(EndDateSelect)>
<cfset SelEDay = Day(EndDateSelect)>
<cfset SelEYear = Year(EndDateSelect)>
<cfset MinEYear = Year(EndDateDropDnS)>
<cfset MaxEYear = Year(EndDateDropDnE)>

<cfhtmlhead text=" 
<script language=""javascript"">
<!--
function checkdates()
	{
	 var var1 = document.getdate.FromYear.options[document.getdate.FromYear.selectedIndex].value
	 var var2 = document.getdate.FromMon.options[document.getdate.FromMon.selectedIndex].value
	 var var3 = document.getdate.FromDay.options[document.getdate.FromDay.selectedIndex].value
	 var var6 = document.getdate.ToYear.options[document.getdate.ToYear.selectedIndex].value
	 var var7 = document.getdate.ToMon.options[document.getdate.ToMon.selectedIndex].value
	 var var8 = document.getdate.ToDay.options[document.getdate.ToDay.selectedIndex].value
	 var var10 = var1 + '/' + var2 + '/' + var3
	 var var16 = var6 + '/' + var7 + '/' + var8
	 date1 = new Date(var1,var2,var3)
	 date2 = new Date(var6,var7,var8)
	 if (date2 < date1)
	 	{
		 alert ('End date can not be before the start date.')
		 return false
		}
	 return true
	}
function getdays()
	{
	 var var1 = document.getdate.FromMon.options[document.getdate.FromMon.selectedIndex].value
	 if (var1 == 1 || var1 == 3 || var1 == 5 || var1 == 7 || var1 == 8 || var1 == 10 || var1 == 12)
		{
		document.getdate.FromDay.options.length = 31
		document.getdate.FromDay.options[28].text = '29'
		document.getdate.FromDay.options[29].text = '30'
		document.getdate.FromDay.options[30].text = '31'	   	   
		var var2 = var1 - 1
		return false
		}
	 else if (var1 == 4 || var1 == 6 || var1 == 9 || var1 == 11)
		{
		 document.getdate.FromDay.options.length = 30
		 document.getdate.FromDay.options[28].text = '29'
		 document.getdate.FromDay.options[29].text = '30'
		 var var2 = var1 - 1
		 var var9 = document.getdate.FromDay.selectedIndex
		 if (var9 == -1)
			{
			 var9 = 0
			}
		 document.getdate.FromDay.options[var9].selected = true		  
		 return false
		}
	 else if (var1 == 2)
		{
		 var var6 = document.getdate.FromYear.options[document.getdate.FromYear.selectedIndex].value
		 var7 = getfebdays(var6)
		 document.getdate.FromDay.options.length = var7
		 if (var7 == 29)
			{
			 document.getdate.FromDay.options[28].text = '29'		
			}
		 var var2 = var1 - 1
		 var var9 = document.getdate.FromDay.selectedIndex
		 if (var9 == -1)
			{
			 var9 = 0
			}
		 document.getdate.FromDay.options[var9].selected = true
		 return false
		}
	 return false
	}
function getdays2()
	{
	 var var1 = document.getdate.ToMon.options[document.getdate.ToMon.selectedIndex].value
	 if (var1 == 1 || var1 == 3 || var1 == 5 || var1 == 7 || var1 == 8 || var1 == 10 || var1 == 12)
		{
		 document.getdate.ToDay.options.length = 31
		 document.getdate.ToDay.options[28].text = '29'
		 document.getdate.ToDay.options[29].text = '30'
		 document.getdate.ToDay.options[30].text = '31'
		 var var2 = var1 - 1
		 document.getdate.ToMon.options[var2].selected = true
		 return false
		}
	 else if (var1 == 4 || var1 == 6 || var1 == 9 || var1 == 11)
		{
		 document.getdate.ToDay.options.length = 30
		 document.getdate.ToDay.options[28].text = '29'
		 document.getdate.ToDay.options[29].text = '30'
		 var var2 = var1 - 1
		 document.getdate.ToMon.options[var2].selected = true
		 document.getdate.ToDay.options[29].selected = true
		 return false
		}
	 else if (var1 == 2)
		{
		 var var6 = document.getdate.ToYear.options[document.getdate.ToYear.selectedIndex].value
		 var7 = getfebdays(var6)
		 document.getdate.ToDay.options.length = var7
		 if (var7 == 29)
			{
			 document.getdate.ToDay.options[28].text = '29'				   
			 document.getdate.ToDay.options[28].selected = true
			}
			 document.getdate.ToDay.options[27].selected = true			
		 return false
		}
	 return false
	}
function getfebdays(theyear)
	{
	 if ((theyear % 4 == 0 && theyear % 100 != 0) || theyear % 400 == 0)
	 return 29
	 else
	 return 28
	}
// -->
</script>
">
<cfsetting enablecfoutputonly="No">
<cfoutput>
<tr bgcolor="#tdclr#">
	<td bgcolor="#tbclr#" align=right>From:</td>
</cfoutput>
	<td><Select name="FromMon" onChange="getdays()">
		<cfloop index="B5" From="1" To="12">
			<cfif B5 lt 10><cfset B5 = "0" & B5></cfif>
			<cfoutput><option value="#B5#" <cfif SelSMonth is B5>Selected</cfif> >#LSDateFormat("#B5#/1/2000", 'MMMM')#</cfoutput>
		</cfloop>
	</select><SELECT name="FromDay">
		<cfloop index="B4" From="1" To="#NumSDays#">
			<cfif B4 lt 10><cfset B4 = "0" & B4></cfif>
			<cfoutput><option <cfif SelSDay Is B4>selected</cfif> value="#B4#">#B4#</cfoutput>
		</cfloop>
	</select><SELECT name="FromYear" onChange="getdays()">
		<cfloop index="B3" From="#MinSYear#" To="#MaxSYear#">
			<cfoutput><option <cfif SelSYear Is B3>Selected</cfif> value="#B3#">#B3#</cfoutput>
		</cfloop>
	</select></td>
<cfoutput>
	<td bgcolor="#tbclr#" align=right>To:</td>
</cfoutput>
	<td><Select name="ToMon" onChange="getdays2()">
		<cfloop index="B5" From="1" To="12">
			<cfif B5 lt 10><cfset B5 = "0" & B5></cfif>
			<cfoutput><option <cfif SelEMonth is B5>Selected</cfif> value="#B5#" >#LSDateFormat("#B5#/1/1996", 'MMMM')#</cfoutput>
		</cfloop>
	</select><SELECT name="ToDay">
		<cfloop index="B4" From="1" To="#NumEDays#">
			<cfif B4 lt 10><cfset B4 = "0" & B4></cfif>
			<cfoutput><option <cfif SelEDay is B4>Selected</cfif> value="#B4#">#B4#</cfoutput>
		</cfloop>
	</select><SELECT name="ToYear" onChange="getdays2()">
		<cfloop index="B3" From="#MinEYear#" To="#MaxEYear#">
			<cfoutput><option <cfif SelEYear is B3>Selected</cfif> value="#B3#">#B3#</cfoutput>
		</cfloop>
	</select></td>
</tr>
 

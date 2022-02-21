<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page does the date verification for two dates. --->
<!--- 4.0.1 02/07/01 Fixed an error with the date selectors	
		4.0.0 08/29/99
		3.2.0 09/08/98 --->
<!--- jsdates.cfm --->

<cfparam name="mmm" default="#Month(Now())#">
<cfparam name="yyy" default="#Year(Now())#">
<cfparam name="ddd" default="#Day(Now())#">
<cfparam name="NumDays" default="#DaysInMonth(Now())#">
<cfparam name="yy3" default="#DateAdd("yyyy",1,Now())#">
<cfif mmm Is "12">
	<cfset NextYear = DateAdd("yyyy",1,Now())>
	<cfparam name="yy4" default="#Year(NextYear)#">
</cfif>

<cfsetting enablecfoutputonly="no">
<script language="javascript">
<!--
function checkdates()
	{
	 var var1 = document.getdate.FromYear.options[document.getdate.FromYear.selectedIndex].value
    var var2 = document.getdate.FromMon.options[document.getdate.FromMon.selectedIndex].value - 1
	 var var3 = document.getdate.FromDay.options[document.getdate.FromDay.selectedIndex].text
    var var6 = document.getdate.ToYear.options[document.getdate.ToYear.selectedIndex].value
    var var7 = document.getdate.ToMon.options[document.getdate.ToMon.selectedIndex].value - 1
	 var var8 = document.getdate.ToDay.options[document.getdate.ToDay.selectedIndex].text
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
    
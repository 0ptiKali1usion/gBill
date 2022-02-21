<cfsetting enablecfoutputonly="Yes">
<!--- Version 4.0.0 --->
<!--- This does the date verification for 1 date. --->
<!--- 4.0.0 03/13/00 --->
<!--- jsdates2.cfm --->

<cfset mmm = Month(#Now()#)>
<cfset yyy = Year(#Now()#)>
<cfset ddd = Day(#Now()#)>
<cfset numdays = DaysInMonth(Now())>
<cfset yy3 = Year(DateAdd("yyyy",1,Now()))>

<cfsetting enablecfoutputonly="No">
<script language="javascript">
<!--
function getdays()
   {
   var var1 = document.getdate.FromMon.options[document.getdate.FromMon.selectedIndex].value
   if (var1 == 1 || var1 == 3 || var1 == 5 || var1 == 7 || var1 == 8 || var1 == 10 || var1 == 12)
      {
	   document.getdate.FromDay.options.length = 31
	   document.getdate.FromDay.options[28].text = '29'
	   document.getdate.FromDay.options[29].text = '30'
	   document.getdate.FromDay.options[30].text = '31'	   	   
	   return false
	  }
   else if (var1 == 4 || var1 == 6 || var1 == 9 || var1 == 11)
      {
	   document.getdate.FromDay.options.length = 30
	   document.getdate.FromDay.options[28].text = '29'
	   document.getdate.FromDay.options[29].text = '30'
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
function getfebdays(theyear)
   {
   if ((theyear % 4 == 0 && theyear % 100 != 0) || theyear % 400 == 0)
      return 29
   else
      return 28
   }
// -->
</script>
 
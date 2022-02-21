<!--- Version 4.2.0 --->
<!--- This tag adds padding and justify for Check Debit output. --->
<!--- 4.0.0 10/12/00 --->
<!--- gspadchar.cfm --->

<cfset howwide = attributes.pwidth>
<cfset thevalue = attributes.pvalue>
<cfset padding = "">
<cfset padding2 = "">
<cfset pad1 = howwide - Len("#thevalue#")>

<cfif pad1 lte 0>
   <cfset caller.newvalue = thevalue>

<cfelseif attributes.justify is 'R'>
   <cfset padding = RepeatString("#attributes.padchar#","#pad1#")>
   <cfset caller.newvalue = padding & thevalue>
   
<cfelseif attributes.justify is 'L'>
   <cfset padding = RepeatString("#attributes.padchar#","#pad1#")>
   <cfset caller.newvalue = thevalue & padding>

<cfelseif attributes.justify is 'C'>
   <cfset pad2 = Round(pad1/2)>
   <cfset pad3 = pad1 - pad2>
   <cfset padding = RepeatString("#attributes.padchar#","#pad2#")>
   <cfset padding2 = RepeatString("#attributes.padchar#","#pad3#")>   
   <cfset caller.newvalue = padding & thevalue & padding2>
   
</cfif>
 
<!--- Version 3.2.0 --->
<!--- 3.2.0 09/08/98 --->
<!--- ccreditcard.cfm --->
<!---

NOTE!: This is based on the validcc.cfm file that 
has been floating around for awhile.  I don't know
who originally wrote it, but they should be given
the credit for the good work.  I simply re-wrote it
to work as a CF_Tag.
 -- hans@westernmt.com, Hans Anderson, LLC

Description:

Credit card validation code.
Checks that expiry is in the future (handling future dates reasonably well),
and that the number is valid.
Works for Visa, Mastercard/Access, Discover and Amex.
To do: would like to add code for debit cards. Switch isn't possible but
others may be.

Input Variables:

	CardNumber		- string with spaces allowed.
	CardExpMonth	- two digits
	CardExpYear		- two digits
	CardType		- single character (V, M, D, A)

Output:

	#Caller.ValidCC# set to TRUE on validity and FALSE on invalidity.

--->

<!--- 
Construct an expiry date. 
Years before 20 are assumed to be past 2000.
Other years below 100 are assumed to 1900s.
The input form only accepts two digits for the date.
Note that the form validation code checks that the month and year are valid numbers
(and the month is in the valid range).
--->

<cfset Caller.CC_Error = " ">

<cfif not ( IsDefined("Attributes.CardNumber") )>
 <cfset Caller.CC_Error = Caller.CC_Error & "<LI> Attribute <b>CardNumber</b> is not defined.">
</cfif>

<cfif not ( IsDefined("Attributes.ExpMonth") )>
 <cfset Caller.CC_Error = Caller.CC_Error & "<LI> Attribute <b>ExpMonth</b> is not defined.">
</cfif>

<cfif not ( IsDefined("Attributes.ExpYear") )>
 <cfset Caller.CC_Error = Caller.CC_Error & "<LI> Attribute <b>ExpYear</b> is not defined.">
</cfif>

<cfif not ( IsDefined("Attributes.CardType") )>
 <cfset Caller.CC_Error = Caller.CC_Error & "<LI> Attribute <b>CardType</b> is not defined.">
</cfif>

<cfif Len (Caller.CC_Error) gt 1>
 <cfset Caller.CC_Error = "<P><b>There were errors:</b> <ul>" & Caller.CC_Error & "</ul><P>">
</cfif>

<!---
<CFIF  #Attributes.CardExpYear# LT 20>
	<CFSET #Expiry# = #CreateDate(Attributes.CardExpYear + 2000, Attributes.CardExpMonth, 1)#>
<CFELSE>
	<CFSET #Expiry# = #CreateDate(Attributes.CardExpYear + 1900, Attributes.CardExpMonth, 1)#>
</CFIF>
--->
<cfset Expiry = CreateDate(Attributes.CardExpYear,Attributes.CardExpMonth,1)>
<CFSET #Expiry# = #DateAdd("d", -1, DateAdd("m", 1, Expiry))#>

<!--- Continue if the date is ok --->
<CFIF #DateCompare(Now(), Expiry)# IS -1>	<!-- Initial substring --->

	<!--- Take out the anything that is not a number --->
	<cfset #CardNum# = #REReplace(Attributes.CardNumber,"[^0-9]","","ALL")#>  	
	
	<!--- Check the initial substring of the number against the card type. --->
	<CFSET #Caller.ValidCC# = TRUE>

	<!--- Check the obvious bated cards --->
	<CFIF (#Attributes.CardType# IS "V") AND (#CardNum# is "111111111111111")>
		<CFSET #Caller.ValidCC# = FALSE>		
		
	<CFELSEIF (#Attributes.CardType# IS "V") AND (#Left(CardNum, 1)# IS NOT "4")>
		<CFSET #Caller.ValidCC# = FALSE>

	<CFELSEIF (#Attributes.CardType# IS "M") AND (#Left(CardNum, 1)# IS NOT "5")>
		<CFSET #Caller.ValidCC# = FALSE>

	<CFELSEIF (#Attributes.CardType# IS "D") AND (#Left(CardNum, 4)# IS NOT "6011")>
		<CFSET #Caller.ValidCC# = FALSE>

	<CFELSEIF (#Attributes.CardType# IS "A") AND (#ListFind("34,37", Left(CardNum, 2))# IS 0)>
		<CFSET #Caller.ValidCC# = FALSE>

	</CFIF>

	<!--- If we passed the above, check the number of digits. --->
	<CFIF #Caller.ValidCC# IS TRUE>		

		<CFSET #CurDigit# = #Left(CardNum, 1)#>
		<CFSET #NumLen# = #Len(CardNum) # - 1>
		
		<CFIF  (#CurDigit# IS "3") AND (#NumLen# IS NOT 14)>
			<CFSET #Caller.ValidCC# = FALSE>

		<CFELSEIF  (#CurDigit# IS "4") AND (#NumLen# IS NOT 12) AND (#NumLen# IS NOT 15)>
			<CFSET #Caller.ValidCC# = FALSE>

		<CFELSEIF  (#CurDigit# IS "5") AND (#NumLen# IS NOT 15)>
			<CFSET #Caller.ValidCC# = FALSE>

		<CFELSEIF (#CurDigit# IS "6") AND (#NumLen# IS NOT 13) AND (#NumLen# IS NOT 15)>
			<CFSET #Caller.ValidCC# = FALSE>

		</CFIF>

		<!--- If we survived that, do the checksum. --->
		<CFIF #Caller.ValidCC# IS TRUE>	
		
			<CFSET #Multiplier# = 2>
			<CFSET #Sum# = 0>
			<CFLOOP INDEX="LoopIndex" FROM=#NumLen# TO="1" STEP="-1">
			
				<CFSET #CurDigit# = #Mid(CardNum, LoopIndex, 1)#>
				<CFSET #Product# = #Multiplier# * #CurDigit#>
				<CFIF #Product# GT 9>
					<CFSET #Sum# = #Sum# + #Product# - 9>
				<CFELSE>
					<CFSET #Sum# = #Sum# + #Product#>
				</CFIF>
				<CFSET #Multiplier# = 3 - #Multiplier#>

			</CFLOOP>

			<CFSET #Sum# = #Sum# MOD 10>
			<CFIF #Sum# IS NOT 0>
				<CFSET #Sum# = 10 - #Sum#>
			</CFIF>

			<CFIF #Sum# IS NOT #Right(CardNum, 1)#>
				<CFSET #Caller.ValidCC# = FALSE>
			</CFIF>

		</CFIF>		
		
	</CFIF>		
	
		<CFELSEIF #DateCompare(Now(), Expiry)# IS NOT -1>
		<CFSET #Caller.ValidCC# = FALSE>
		
</CFIF>		
<cfset CardNum= 0 >
<cfset Caller.CardNum = CardNum>
 
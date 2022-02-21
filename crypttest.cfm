<cfquery name="GetSalt" datasource="#pds#">
		SELECT Password 
		FROM Accounts
		WHERE Login = 'gbtest10'
	</cfquery>
	<CFOBJECT TYPE="COM"
          NAME="objCrypt"
          CLASS="AspCrypt.Crypt"
          ACTION="Create">
	<!--- This Encrypts the password before comparing it --->
	<CFSET strSalt = GetSalt.Password>
	<CFSET strValue = "Smith">
	<CFSET LookUpPassword = objCrypt.Crypt(strSalt, strValue)>
	<cfoutput>#GetSalt.Password##LookUpPassword#</cfoutput>
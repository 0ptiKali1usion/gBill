	<cfquery name="GetAInfo" datasource="#pds#">
		SELECT UserName, Password 
		FROM AccountsAuth
		WHERE AuthID = #LocAuthID#
	</cfquery>
	<CFOBJECT TYPE="COM"
          	  NAME="objCrypt"
          	  CLASS="AspCrypt.Crypt"
          	  ACTION="Create">
<!--- This Encrypts the password before comparing it --->
	<CFSET strSalt = GetAInfo.UserName>
	<CFSET strValue = GetAInfo.Password>
	<CFSET Password = objCrypt.Crypt(strSalt, strValue)>
	<cfquery name="UPdData" datasource="#pds#">
		UPDATE AccountsAuth SET  
		Password = '#Password#'
		WHERE AuthID = #LocAuthID# 
	</cfquery>
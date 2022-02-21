	<cfquery name="GetUserName" datasource="#pds#">
		SELECT UserName, Password 
		FROM AccountsAuth 
		WHERE AuthID = #LocAuthID#
	</cfquery>
	<CFOBJECT TYPE="COM"
          	  NAME="objCrypt"
          	  CLASS="AspCrypt.Crypt"
          	  ACTION="Create">
<!--- This Encrypts the password before comparing it --->
	<CFSET strSalt = GetUserName.UserName>
	<CFSET strValue = GetUserName.Password>
	<CFSET Password = objCrypt.Crypt(strSalt, strValue)>
	<cfquery name="UPdData" datasource="#pds#">
		UPDATE AccountsAuth SET 
		Login = '#UserName#', 
		Password = '#Password#',
		WHERE AccountID = #AccountID# 
	</cfquery>
	<cfquery name="GetFInfo" datasource="#pds#">
		SELECT UserName, Password 
		FROM AccountsFTP
		WHERE FTPID = #LocFTPID#
	</cfquery>
	<CFOBJECT TYPE="COM"
          	  NAME="objCrypt"
          	  CLASS="AspCrypt.Crypt"
          	  ACTION="Create">
<!--- This Encrypts the password before comparing it --->
	<CFSET strSalt = GetFInfo.UserName>
	<CFSET strValue = GetFInfo.Password>
	<CFSET Password = objCrypt.Crypt(strSalt, strValue)>
	<cfquery name="UPdData" datasource="#pds#">
		UPDATE AccountsFTP SET  
		Password = '#Password#'
		WHERE FTPID = #LocFTPID# 
	</cfquery>
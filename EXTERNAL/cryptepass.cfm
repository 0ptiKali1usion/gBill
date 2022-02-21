	<cfquery name="GetEInfo" datasource="#pds#">
		SELECT Login, EPass 
		FROM AccountsEmail
		WHERE EmailID = #LocEMailID#
	</cfquery>
	<CFOBJECT TYPE="COM"
          	  NAME="objCrypt"
          	  CLASS="AspCrypt.Crypt"
          	  ACTION="Create">
<!--- This Encrypts the password before comparing it --->
	<CFSET strSalt = GetEInfo.Login>
	<CFSET strValue = GetEInfo.EPass>
	<CFSET EPass = objCrypt.Crypt(strSalt, strValue)>
	<cfquery name="UPdData" datasource="#pds#">
		UPDATE AccountsEMail SET  
		EPass = '#EPass#'
		WHERE EMailID = #LocEMailID# 
	</cfquery>
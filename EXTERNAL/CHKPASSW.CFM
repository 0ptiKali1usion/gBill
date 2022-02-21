<!---<CFOBJECT TYPE="COM"
          NAME="objCrypt"
          CLASS="AspCrypt.Crypt"
          ACTION="Create">
<!--- This Encrypts the password before comparing it --->
<CFSET strSalt = Form.Login>
<CFSET strValue = Form.Password>
<CFSET LookUpPassword = objCrypt.Crypt(strSalt, strValue)> --->
<cfquery name="GetSalt" datasource="#pds#">
		SELECT Password 
		FROM Accounts
		WHERE Login = '#Form.Login#'
	</cfquery>
	<CFOBJECT TYPE="COM"
          NAME="objCrypt"
          CLASS="AspCrypt.Crypt"
          ACTION="Create">
	<!--- This Encrypts the password before comparing it --->
	<CFSET strSalt = GetSalt.Password>
	<CFSET strValue = Form.Password>
	<CFSET LookUpPassword = objCrypt.Crypt(strSalt, strValue)>
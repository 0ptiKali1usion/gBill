<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html>
<head>
	<title>Test Page</title>
</head>

<body>

<H1>Test Data from Styx</h1>
<CFQUERY NAME="TestQuery" DATASOURCE="GBill">
	SELECT Login, LastName FROM	dbo.Accounts
</cfquery>
<cfoutput QUERY="TestQuery">
	#Login#: #LastName# <BR>
	
</cfoutput>

</body>
</html>

<html>
<head><title>Unix Crypt ASP Test Script</title></head>
<body>

<%
  Set Cryptor = Server.CreateObject ("AspCrypt.Crypt")

  strSalt = "a"
  strValue = "Widgets"

  Response.Write "The crypted valued is " & Cryptor.Crypt (strSalt, strValue)

  Set Cryptor = nothing
%>

</body>
</html>


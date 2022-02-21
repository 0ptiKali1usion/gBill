<cfsetting enablecfoutputonly="Yes">
<!--- Version 4.0.0 --->
<!--- This is admin page that previews the selected colors.
If a default button is clicked the colors are permanent.
If no button is clicked within 15 seconds it returns to the select colors page.
--->
<!--- 4.0.0 12/13/00 --->
<!--- optcolor3.cfm --->

<cfsetting enablecfoutputonly="No">
<html>
<head>
<Script Language="JavaScript">
<!-- Hiding
/*      Script by Lefteris Haritou
                21/05/1997      
        http://www.geocities.com/~lef
        Please Keep The Credit Above
        (No copyrights, but be fair)
*/

var red=0;
var green=0;
var blue=0;
var value=0;
var convert = new Array()
var hexbase= new Array("0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F");

for (x=0; x<16; x++){
for (y=0; y<16; y++){
convert[value]= hexbase[x] + hexbase[y];
value++;
}
}

function clear(){
document.color.bl.value= blue;
document.color.rd.value= red;
document.color.gr.value= green;
}

function display(){
redx = convert[red]
greenx = convert[green]
bluex = convert[blue]
var rgb = redx+greenx+bluex;
document.color.rgbdspl.value= rgb;
document.bgColor =rgb;
}

function upred(x){
if ((red+x)<=255)
red+=x
document.color.rd.value= red;
display()
}

function downred(x){
if ((red-x)>=0)
red-=x
document.color.rd.value= red;
display()
}

function upgreen(x){
if ((green+x)<=255)
green+=x
document.color.gr.value= green;
display()
}

function downgreen(x){
if ((green-x)>=0)
green-=x
document.color.gr.value= green;
display()
}

function upblue(x){
if ((blue+x)<=255)
blue+=x
document.color.bl.value= blue;
display()
}

function downblue(x){
if ((blue-x)>=0)
blue-=x
document.color.bl.value= blue;
display()
}

// done hiding -->

</Script>
</head>
<cfoutput><body onLoad="clear();display()" #colorset#></cfoutput>
<cfinclude template="header.cfm">
<center>
<FORM Name="color" action="types2.cfm">
<cfoutput><table border="#tblwidth#"></cfoutput>
	<tr Align="center">
		<td><input NAME="red" type="button" VALUE=" +50 " onclick="upred(50)"></td>
		<td><input NAME="red" type="button" VALUE=" + + " onclick="upred(10)"></td>
		<td><input NAME="red" type="button" VALUE=" + " onclick="upred(1)"></td>
		<td bgcolor="White"><Font Color="#FF0000" size=+3>RED</font></td>
		<td><input NAME="red-" type="button" VALUE=" - " onclick="downred(1)"></td>
		<td><input NAME="red-" type="button" VALUE=" - - " onclick="downred(10)"></td>
		<td><input NAME="red-" type="button" VALUE=" -50 " onclick="downred(50)"></td>
		<td><input type="text" Name="rd" Size=3></td>
	</tr>
	<tr Align="center">
		<td><input NAME="green" type="button" VALUE=" +50 " onclick="upgreen(50)"></td>
		<td><input NAME="green" type="button" VALUE=" + + " onclick="upgreen(10)"></td>
		<td><input NAME="green" type="button" VALUE=" + " onclick="upgreen(1)"></td>
		<td bgcolor="White"><Font Color="#00FF00" size=+3>GREEN</font></td>
		<td><input NAME="green-" type="button" VALUE=" - " onclick="downgreen(1)"></td>
		<td><input NAME="green-" type="button" VALUE=" - - " onclick="downgreen(10)"></td>
		<td><input NAME="green-" type="button" VALUE=" -50 " onclick="downgreen(50)"></td>
		<td><input type="text" Name="gr" Size=3></td>
	</tr>
	<tr Align="center">
		<td><input NAME="blue" type="button" VALUE=" +50 " onclick="upblue(50)"></td>
		<td><input NAME="blue" type="button" VALUE=" + + " onclick="upblue(10)"></td>
		<td><input NAME="blue" type="button" VALUE=" + " onclick="upblue(1)"></td>
		<td bgcolor="White"><Font Color="#0000FF" size=+3>BLUE</font></td>
		<td><input NAME="blue-" type="button" VALUE=" - " onclick="downblue(1)"></td>
		<td><input NAME="blue-" type="button" VALUE=" - - " onclick="downblue(10)"></td>
		<td><input NAME="blue-" type="button" VALUE=" -50 " onclick="downblue(50)"></td>
		<td><input type="text" Name="bl" Size=3></td>
	</tr>
</table>
<input type="text" Name="rgbdspl" Size=7><br>
<input type="submit" name="pickedcolor" value="Select This Color">
</FORM>
<br>
<br>
<cfoutput>
<table border="#tblwidth#">
</cfoutput>
	<tr><td bgcolor="white">Text color is</td>
		<td>Here is the color of the text.</td>
	</tr>
	<tr>
		<td bgcolor="white">Link color is</td>
		<td><a href="adminopt.cfm" onClick="return false">Here is the color of a link.</a></td>
	</tr>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</HTML>


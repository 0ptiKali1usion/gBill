<cfsetting enablecfoutputonly="Yes">
<!-- Version 3.5.0 -->
<!--- Integration page for Livingston --->
<!--- 3.5.0 06/26/99 --->
<!--- NACHA.cfm --->

<cfif intcode is "checkdebit">
	<cfset intcount = 0>
	<form method="post" action="cdsetup.cfm">
		<input type="hidden" name="thecode" value="NACHA">
		<cfoutput><input type="hidden" name="tab" value="#tab#"></cfoutput>
		<td><input type="submit" name="setgeneric" value="NACHA"></td>
	</form>

<cfelseif intcode is "savecdebit">
	<cfquery datasource="#pds#" name="chkcddateformat">
		SELECT * 
		FROM setup 
		WHERE varname = 'cddateformat'
	</cfquery>
	<cfif chkcddateformat.recordcount is not 0>
		<cfquery name="setcddateformat" datasource="#pds#">
			Update setup SET 
			setup.value1 = 'YYMMDD' 
			WHERE varname= 'cddateformat'
		</cfquery>
	<cfelse>
		<cfquery name="setcchrout" datasource="#pds#">
	   	INSERT INTO setup (varname, value1, description)
		   Values ('cddateformat','YYMMDD','Check Debit Output Date Format') 
		</cfquery>
	</cfif>   
	<cfquery datasource="#pds#" name="chkcdtimeformat">
		SELECT * FROM setup WHERE varname = 'cdtimeformat'
	</cfquery>
	<cfif #chkcdtimeformat.recordcount# is not 0>
		<cfquery name="setcdtimeformat" datasource="#pds#">
			Update setup SET setup.value1 = 'hhmm' 
			WHERE varname= 'cdtimeformat'
		</cfquery>
   <cfelse>
		<cfquery name="setcdtimeformat" datasource="#pds#">
			INSERT INTO setup (varname, value1, description)
   		Values ('cdtimeformat','hhmm','Check Debit Output Time Format') 
		</cfquery>
   </cfif>   
	<cfquery datasource="#pds#" name="chkcdseqid">
		SELECT * FROM setup WHERE varname = 'cdseqid'
	</cfquery>
   <cfif #chkcdseqid.recordcount# is 0>
		<cfquery name="setcdseqid" datasource="#pds#">
			INSERT INTO setup (varname, value1, description)
			Values ('cdseqid', 'Z', 'Credit Debit SequenceID') 
		</cfquery>
	</cfif>   
	<cfquery datasource="#pds#" name="chkcdUseDS">
		SELECT * FROM setup WHERE varname = 'cdUseDS'
	</cfquery>
   <cfif #chkcdUseDS.recordcount# is not 0>
		<cfquery name="setcdUseDS" datasource="#pds#">
			Update setup SET setup.value1 = '0' 
			WHERE varname= 'cdUseDS'
		</cfquery>
   <cfelse>
		<cfquery name="setcdUseDS" datasource="#pds#">
		   INSERT INTO setup (varname, value1, description)
			Values ('cdUseDS','0','Use Dollar Signs in Money Format') 
		</cfquery>
   </cfif>   
	<cfquery datasource="#pds#" name="chkcdUseP">
		SELECT * FROM setup WHERE varname = 'cdUseP'
	</cfquery>
   <cfif #chkcdUseP.recordcount# is not 0>
		<cfquery name="setcdUseP" datasource="#pds#">
			Update setup SET setup.value1 = '1' 
			WHERE varname= 'cdUseP'
		</cfquery>
   <cfelse>
		<cfquery name="setcdUseP" datasource="#pds#">
			INSERT INTO setup (varname, value1, description)
		   Values ('cdUseP','1','Use periods in Money Format') 
		</cfquery>
   </cfif>
	<cfquery name="RemoveOld" datasource="#pds#">
		DELETE FROM CustomCDOutput 
		WHERE CFVarYN = 0 
	</cfquery>
<cfset FieldList = "1;1;N;1;1;Null;1;0;1,01;01;N;2;3;Null;1;0;1, ; ;N;4;4;Null;1;0;1,123456789;123456789;N;5;13;0;1;0;1,1;1;N;14;14;Null;1;0;1,123121234;123121234;N;15;23;Null;1;0;1,094;094;N;35;37;Null;1;0;1,10;10;N;38;39;Null;1;0;1,1;1;N;40;40;Null;1;0;1,Your Bank Name;Your Bank Name;L;41;63; ;1;0;1,Company name;Company name;L;64;86; ;1;0;1, ; ;N;87;94; ;1;0;1,time;Time;N;30;33;Null;1;1;1,cdsequenceid;SequenceID;N;34;34;Null;1;1;1,date;date;N;24;29; ;1;1;1,225;225;N;2;4;Null;2;0;1,123121234;123121234;N;42;50;Null;2;0;1,PPD;PPD;N;51;53;Null;2;0;1,Internet;Internet;N;54;63;Null;2;0;1,12345678;12345678;N;80;87;Null;2;0;1,5;5;N;1;1;Null;2;0;1,Company Name;Company Name;L;5;20; ;2;0;1, ; ;N;21;40; ;2;0;1,1;1;N;41;41;Null;2;0;1,1;1;N;79;79;Null;2;0;1,1;1;R;88;94;0;2;0;1,day;Day (ddd);N;76;78;Null;2;1;1,date;Settlement Date;R;70;75; ;2;1;1,6;6;N;1;1; ;3;0;1,28;28;N;2;3;Null;3;0;1, ; ;N;75;76; ;3;0;1,0;0;N;77;77;Null;3;0;1,87654321;87654321;N;78;85;0;3;0;1,accountid;AccountID;R;38;52;0;3;1;1,lastname;Last Name;N;100;100;Null;3;1;0,firstname;First Name;N;100;100;Null;3;1;0,Bal;Amount Owed;R;30;37;0;3;1;1,compname;Company Name;N;100;100;Null;3;1;0,checkd1;Bank Name;N;100;100;Null;3;1;0,checkd2;Routing Number;L;4;12;Null;3;1;1,checkd3;Account Number;R;13;29;0;3;1;1,checkd4;Bank Address;N;100;100;Null;3;1;0,checkd5;Name On Account;L;53;74; ;3;1;1,seqnumber;Incrementing Field;R;86;94;0;3;1;1,8;8;N;1;1; ;4;0;1,225;225;N;2;4;Null;4;0;1,0;0;N;31;40;0;4;0;1,1;1;N;41;41;Null;4;0;1,14789632;14789632;N;42;50; ;4;0;1, ; ;N;51;76; ;4;0;1,36987415;36987415;N;77;84; ;4;0;1,1;1;R;85;94;0;4;0;1,date;date;N;100;100;Null;4;1;0,sumdebits;Sum (Debits);R;21;30;0;4;1;1,sumall;Sum (All);N;100;100;Null;4;1;0,countall;Count (All);R;5;10;0;4;1;1,acntadd;Add the routing numbers;N;11;20;0;4;1;1,countdebits;Count (Debits);N;100;100;Null;4;1;0,9;9;N;1;1;Null;5;0;1,1;1;R;2;7;0;5;0;1,0;0;N;42;51;0;5;0;1, ; ;N;52;94; ;5;0;1,BlockTotal;Number Of Blocks;R;8;13;0;5;1;1,sumdebits;Sum (Debits);R;32;41;0;5;1;1,sumall;Sum (All);N;100;100;Null;5;1;0,countall;Count (All);R;14;21;0;5;1;1,acntadd;Add the routing numbers;R;22;31;0;5;1;1,date;date;N;100;100;Null;5;1;0">
	<cfloop index="B5" list="#FieldList#">
		<cfset FieldName = ListGetAt("#B5#",1,";")>
		<cfset Description1 = ListGetAt("#B5#",2,";")>
		<cfset PJustify = ListGetAt("#B5#",3,";")>
		<cfset StartOrder = ListGetAt("#B5#",4,";")>
		<cfset EndOrder = ListGetAt("#B5#",5,";")>
		<cfset PadChar = ListGetAt("#B5#",6,";")>
		<cfset UseTab = ListGetAt("#B5#",7,";")>
		<cfset CFVarYN = ListGetAt("#B5#",8,";")>
		<cfset UseYN = ListGetAt("#B5#",9,";")>
		<cfif CFVarYN Is 1>
			<cfquery name="UpdateOne" datasource="#pds#">
				UPDATE CustomCDOutput SET 
				Description1 = '#Description1#',
				PJustify = '#PJustify#', 
				StartOrder = #StartOrder#, 
				EndOrder = #EndOrder#,
				PadChar = <cfif PadChar Is "Null">Null<cfelse>'#PadChar#'</cfif>, 
				UseTab = #UseTab#, 
				UseYN = #UseYN#, 
				CFVarYN = #CFVarYN# 
				WHERE FieldName1 = '#FieldName#' 
				AND UseTab = #UseTab#
			</cfquery>
		<cfelse>
			<cfquery name="EnterOne" datasource="#pds#">
				INSERT INTO CustomCDOutput 
				(FieldName1, Description1, PJustify, StartOrder, 
				 EndOrder, PadChar, UseTab, CFVarYN, UseYN) 
				VALUES 
				('#FieldName#', '#Description1#', '#PJustify#', #StartOrder#, 
				 #EndOrder#, <cfif PadChar Is "Null">Null<cfelse>'#PadChar#'</cfif>, 
				 #UseTab#, #CFVarYN#, #UseYN#) 
			</cfquery>
		</cfif>
	</cfloop>
</cfif>
<cfset ShowButton = 0>
<cfsetting enablecfoutputonly="No"> 


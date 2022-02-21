<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This is the page that actually save the options from each tab. --->
<!--- 4.0.0 07/20/99
		3.2.0 09/08/98 --->
<!--- options2.cfm --->

<cfif (IsDefined("DelTypes.x")) AND (IsDefined("DelThese"))>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="GetTypes" datasource="#pds#">
			SELECT CardType 
			FROM CreditCardTypes 
			WHERE CardTypeID In (#DelThese#) 
		</cfquery>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'System','#StaffMemberName.FirstName# #StaffMemberName.LastName# deleted the following credit card types. #GetTypes.CardType#')
		</cfquery>
	</cfif>
	<cfquery name="DelData" datasource="#pds#">
		DELETE FROM PlanCCTypes 
		WHERE CardTypeID In (#DelThese#) 
	</cfquery>
	<cfquery name="DelData" datasource="#pds#">
		DELETE FROM CreditCardTypes 
		WHERE CardTypeID In (#DelThese#) 
	</cfquery>
</cfif>
<cfif IsDefined("EnterCardType.x")>
	<cfquery name="AddData" datasource="#pds#">
		INSERT INTO CreditCardTypes 
		(CardType,MinNumbers,MaxNumbers,UseAw,UseOS,ActiveYN,SortOrder,CFVarYN)
		VALUES 
		('#CardType#',0,0,#UseAW#,#UseOS#,1,1,0)
	</cfquery>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'System','#StaffMemberName.FirstName# #StaffMemberName.LastName# added the credit card type. #CardType#')
		</cfquery>
	</cfif>
</cfif>
<cfif IsDefined("UpdateCreditCards.x")>
	<cfset UseAWList = "0">
	<cfset UseOSList = "0">
	<cfset UseBothList = "0">
	<cfloop index="B5" from="1" to="#LoopCount#">
		<cfset var1 = Evaluate("CardTypeID#B5#")>
		<cfif IsDefined("UseAw#B5#")>
			<cfset var2 = 1>
		<cfelse>
			<cfset var2 = 0>
			<cfset UseAWList = ListAppend(UseAWList,var1)>
		</cfif>
		<cfif IsDefined("UseOS#B5#")>
			<cfset var3 = 1>
		<cfelse>
			<cfset var3 = 0>
			<cfset UseOSList = ListAppend(UseOSList,var1)>
		</cfif>
		<cfif IsDefined("ActiveYN#B5#")>
			<cfset var4 = 1>
		<cfelse>
			<cfset var4 = 0>
			<cfset UseBothList = ListAppend(UseBothList,var1)>
		</cfif>
		<cfif IsDefined("CardType#B5#")>
			<cfset var5 = Evaluate("CardType#B5#")>
		<cfelse>
			<cfset var5 = "">
		</cfif>
		<cfquery name="UpdData" datasource="#pds#">
			UPDATE CreditCardTypes SET 
			UseAw = #var2#, 
			UseOS = #var3#, 
			<cfif IsDefined("CardType#B5#")>
				CardType = '#var5#', 
			</cfif>
			ActiveYN = #var4# 
			WHERE CardTypeID = #var1# 
		</cfquery>
	</cfloop>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'System','#StaffMemberName.FirstName# #StaffMemberName.LastName# edited the credit card types.')
		</cfquery>
	</cfif>
	<cfquery name="RemoveOld" datasource="#pds#">
		DELETE FROM PlanCCTypes 
		WHERE CardTypeID In (#UseAWList#) 
		AND WizardType = 'AW' 
	</cfquery>
	<cfquery name="RemoveOld" datasource="#pds#">
		DELETE FROM PlanCCTypes 
		WHERE CardTypeID In (#UseOSList#) 
		AND WizardType = 'OS' 
	</cfquery>
	<cfquery name="RemoveOld" datasource="#pds#">
		DELETE FROM PlanCCTypes 
		WHERE CardTypeID In (#UseBothList#) 
	</cfquery>
</cfif>
<cfif IsDefined("UpdateTab1.x")>
	<cfset CheckChar = Right(Form.Billpath,1)>
	<cfif (CheckChar Is Not "\") AND (CheckChar Is Not "/")>
		<cfset TheBillPath = Form.BillPath & OSType>
	<cfelse>
		<cfset TheBillPath = Form.BillPath>
	</cfif>
	<cfquery name="chkBillPath" datasource="#pds#">
		SELECT * FROM Setup WHERE VarName = 'BillPath'
	</cfquery>
   <cfif chkBillPath.RecordCount Is Not 0>
	   <cfquery name="setBillPath" datasource="#pds#">
   		Update Setup SET 
			Value1= <cfif Trim(TheBillPath) Is OSType>Null<cfelse>'#TheBillPath#'</cfif> 
   		WHERE VarName= 'BillPath'
	   </cfquery>
   <cfelse>
	   <cfquery name="setBillPath" datasource="#pds#">
   		INSERT INTO Setup 
			(VarName, Value1, Description)
   		Values 
			('BillPath', '#TheBillPath#', 'Path To Billing Directory') 
	   </cfquery>
   </cfif>
	<cfif IsDefined("Form.OStype")>
		<cfquery name="CheckFirst" datasource="#pds#">
			SELECT * 
			FROM Setup 
			WHERE VarName = 'OSType' 
		</cfquery>
		<cfif CheckFirst.RecordCount Is 0>
			<cfif Form.OSType Is Not "">
				<cfquery name="AddValue" datasource="#pds#">
					INSERT INTO Setup 
					(VarName, Value1, Description, AutoLoadYN) 
					VALUES 
					('OSType', '#Form.OStype#', 'The O.S. gBill is installed on.', 1) 
				</cfquery>
			</cfif>
		<cfelseif Form.OSType Is Not "">
			<cfif Form.OSType Is Not "">
				<cfquery name="UpdValue" datasource="#pds#">
					UPDATE Setup SET 
					Value1 = '#Form.OSType#', 
					AutoLoadYN = 1 
					WHERE VarName = 'OSType' 
				</cfquery>
			</cfif>
		</cfif>
	</cfif>
	<cfset CRTPathway = Form.crtpath>
	<cfquery name="chkcrtpath" datasource="#pds#">
		SELECT * FROM Setup WHERE VarName = 'crtpath'
	</cfquery>
   <cfif chkCrtPath.RecordCount GT 0>
	   <cfquery name="setcrtoutpath" datasource="#pds#">
   		Update Setup SET 
			Value1 = <cfif Trim(CRTPathway) Is "">NULL<cfelse>'#CRTPathway#'</cfif>,
			AutoLoadYN = <cfif Trim(CRTPathway) Is "">0<cfelse>1</cfif> 
	   	WHERE VarName= 'crtpath'
   	</cfquery>
   <cfelse>
   	<cfquery name="setcrtoutpath" datasource="#pds#">
		   INSERT INTO Setup 
			(VarName, Value1, Description, AutoLoadYN)
		   Values 
			('crtpath', '#crtpathway#', 'Path To crt.exe', 1) 
	   </cfquery>
   </cfif>
	<cfquery datasource="#pds#" name="chkBODBCType">
		SELECT * FROM Setup WHERE VarName = 'BODBCType'
	</cfquery>
   <cfif chkBODBCType.RecordCount GT 0>
		<cfquery name="setBODBCType" datasource="#pds#">
			Update Setup SET Value1= '#form.BODBCType#' 
			WHERE VarName= 'BODBCType'
		</cfquery>
   <cfelse>
		<cfquery name="setBODBCType" datasource="#pds#">
 			INSERT INTO Setup 
			(varname, value1, description)
   		Values 
			('BODBCType', '#BODBCType#', 'Which Database for Billing') 
		</cfquery>
   </cfif>
	<cfquery datasource="#pds#" name="chkdeactaccount">
		SELECT * FROM Setup WHERE VarName = 'deactaccount'
	</cfquery>
	<cfif chkDeactAccount.RecordCount GT 0>
		<cfquery name="setDeactAccount" datasource="#pds#">
			Update Setup SET Value1 = '#form.deactaccount#' 
			WHERE VarName = 'deactaccount'
		</cfquery>
	<cfelse>
   	<cfquery name="setdeactaccount" datasource="#pds#">
		   INSERT INTO Setup 
			(varname, value1, description)
		   Values 
			('deactaccount', '#deactaccount#', 'Deactivated Account Plan ID') 
	   </cfquery>
	</cfif>
	<cfquery datasource="#pds#" name="chkDelAccount">
		SELECT * FROM Setup WHERE VarName = 'delaccount'
	</cfquery>
	<cfif chkdelaccount.RecordCount GT 0>
		<cfquery name="setdelaccount" datasource="#pds#">
			Update Setup SET Value1 = '#form.delaccount#' 
			WHERE VarName = 'delaccount' 
		</cfquery>
	<cfelse>
   	<cfquery name="setdelaccount" datasource="#pds#">
		   INSERT INTO Setup 
			(varname, value1, description)
		   Values 
			('delaccount', '#delaccount#', 'Deleted Account Plan ID') 
	   </cfquery>
	</cfif>
	<cfquery datasource="#pds#" name="chkPRLetter">
		SELECT * 
		FROM Setup 
		WHERE VarName = 'PRLetter' 
	</cfquery>
	<cfif chkPRLetter.RecordCount GT 0>
		<cfquery name="setDeactAccount" datasource="#pds#">
			Update Setup SET Value1 = '#form.PRLetter#' 
			WHERE VarName = 'PRLetter'
		</cfquery>
	<cfelse>
   	<cfquery name="setPRLetter" datasource="#pds#">
		   INSERT INTO Setup 
			(varname, value1, description, autoloadyn)
		   Values 
			('PRLetter', '#PRLetter#', 'Letter for password requests', 0) 
	   </cfquery>
	</cfif>
	<cfquery name="chkLocale" datasource="#pds#">
		SELECT * FROM Setup WHERE VarName ='Locale'
	</cfquery>
	<cfif chkLocale.RecordCount GT 0>
		<cfquery name="setLocale" datasource="#pds#">
			Update Setup SET Value1 = '#form.Locale#' 
			WHERE VarName = 'Locale'
		</cfquery>
	<cfelse>
		<cfquery name="setLocale" datasource="#pds#">
			INSERT INTO Setup 
			(varname, value1, description)
			Values 
			('Locale', '#form.Locale#', 'Country Locale')
		</cfquery>
	</cfif>
	<cfset datemask1 = f1 & "/" & f2 & "/" & f3>
	<cfquery name="chkDateMask1" datasource="#pds#">
		SELECT * FROM Setup WHERE VarName ='DateMask1'
	</cfquery>
	<cfif chkDateMask1.RecordCount GT 0>
		<cfquery name="setDateMask1" datasource="#pds#">
			Update Setup SET Value1 = '#DateMask1#' 
			WHERE VarName = 'DateMask1'
		</cfquery>
	<cfelse>
		<cfquery name="setDateMask1" datasource="#pds#">
			INSERT INTO Setup 
			(varname, value1, description)
			Values 
			('DateMask1', '#DateMask1#', 'Date Format Mask')
		</cfquery>
	</cfif>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'System','#StaffMemberName.FirstName# #StaffMemberName.LastName# edited the gBill system tab of system configuration.')
		</cfquery>
	</cfif>
</cfif>
<cfif IsDefined("UpdTab2.x")>
	<cfquery datasource="#pds#" name="chkcompname">
		SELECT * FROM Setup WHERE varname = 'compname'
	</cfquery>
	<cfif chkcompname.RecordCount GT 0>
		<cfquery name="setcompname" datasource="#pds#">
			Update Setup SET Value1 = '#form.compname#' 
			WHERE varname = 'compname'
		</cfquery>
	<cfelse>
	   <cfquery name="setcompname" datasource="#pds#">
   		INSERT INTO Setup (varname, value1, description)
		   Values ('compname', '#compname#', 'Comapny Name') 
	   </cfquery>
	</cfif>
	<cfquery datasource="#pds#" name="chkservmail">
		SELECT * FROM Setup WHERE varname = 'servmail'
	</cfquery>
	<cfif chkservmail.RecordCount GT 0>
		<cfquery name="setservmail" datasource="#pds#">
			Update Setup set Value1 = '#form.servmail#' 
			WHERE varname = 'servmail'
		</cfquery>
	<cfelse>
	   <cfquery name="set" datasource="#pds#">
   	INSERT INTO Setup (varname, value1, description)
	   Values ('servmail', '#servmail#', 'Service EMail Address') 
   	</cfquery>
	</cfif>
	<cfquery datasource="#pds#" name="chkwarnemail">
		SELECT * FROM Setup WHERE varname = 'warnemail'
	</cfquery>
	<cfif chkwarnemail.RecordCount GT 0>
		<cfquery name="setwarnemail" datasource="#pds#">
			Update Setup set Value1 = '#form.warnemail#' 
			WHERE varname = 'warnemail'
		</cfquery>
	<cfelse>
	   <cfquery name="set" datasource="#pds#">
   	INSERT INTO Setup (varname, value1, description)
	   Values ('warnemail', '#warnemail#', 'EMail Address for gBill warnings.') 
   	</cfquery>
	</cfif>
	<cfquery datasource="#pds#" name="chkcompaddr">
		SELECT * FROM Setup WHERE varname = 'compaddr'
	</cfquery>
	<cfif chkcompaddr.RecordCount GT 0>
		<cfquery name="setcompaddr" datasource="#pds#">
			Update Setup set Value1 = '#form.compaddr#' 
			WHERE varname = 'compaddr'
		</cfquery>
	<cfelse>
	   <cfquery name="setcompaddr" datasource="#pds#">
   		INSERT INTO Setup (varname, value1, description)
		   Values ('compaddr', '#compaddr#', 'Company Address') 
	   </cfquery>
	</cfif>
	<cfquery datasource="#pds#" name="chkcompcity">
		SELECT * FROM Setup WHERE varname = 'compcity'
	</cfquery>
	<cfif chkcompcity.RecordCount GT 0>
		<cfquery name="setcompcity" datasource="#pds#">
			Update Setup set Value1 = '#form.compcity#' 
			WHERE varname = 'compcity'
		</cfquery>
	<cfelse>
	   <cfquery name="setcompcity" datasource="#pds#">
	   	INSERT INTO Setup (varname, value1, description)
	   	Values ('compcity', '#compcity#', 'Company City') 
   	</cfquery>
	</cfif>
	<cfquery datasource="#pds#" name="chkcompstate">
		SELECT * FROM Setup WHERE varname = 'compstate'
	</cfquery>
	<cfif chkcompstate.RecordCount GT 0>
		<cfquery name="setcompstate" datasource="#pds#">
			Update Setup set Value1 = '#form.compstate#' 
			WHERE varname = 'compstate'
		</cfquery>
	<cfelse>
   	<cfquery name="set" datasource="#pds#">
		   INSERT INTO Setup (varname, value1, description)
		   Values ('compstate', '#compstate#', 'Company State') 
	   </cfquery>
	</cfif>
	<cfquery datasource="#pds#" name="chkcompzip">
		SELECT * FROM Setup WHERE varname = 'compzip'
	</cfquery>
	<cfif chkcompzip.RecordCount GT 0>
		<cfquery name="setcompzip" datasource="#pds#">
			Update Setup set Value1 = '#form.compzip#' 
			WHERE varname = 'compzip'
		</cfquery>
	<cfelse>
   	<cfquery name="set" datasource="#pds#">
		   INSERT INTO Setup (varname, value1, description)
	   	Values ('compzip', '#compzip#', 'Company Zip Code') 
   	</cfquery>
	</cfif>
	<cfquery datasource="#pds#" name="chkhpurl">
		SELECT * FROM Setup WHERE varname = 'hpurl'
	</cfquery>
	<cfif chkhpurl.RecordCount GT 0>
		<cfquery name="sethpurl" datasource="#pds#">
			Update Setup set Value1 = '#form.hpurl#' 
			WHERE varname = 'hpurl'
		</cfquery>
	<cfelse>
   	<cfquery name="sethpurl" datasource="#pds#">
		   INSERT INTO Setup (varname, value1, description)
		   Values ('hpurl', '#hpurl#', 'Home Page URL') 
	   </cfquery>
	</cfif>
	<cfquery datasource="#pds#" name="chkcomplogo">
		SELECT * FROM Setup WHERE varname = 'complogo'
	</cfquery>
	<cfif chkcomplogo.RecordCount GT 0>
		<cfquery name="setcomplogo" datasource="#pds#">
			Update Setup set Value1 = '#form.complogo#' 
			WHERE varname = 'complogo'
		</cfquery>
	<cfelse>
   	<cfquery name="set" datasource="#pds#">
		   INSERT INTO Setup (varname, value1, description)
		   Values ('complogo', '#complogo#', 'Company Logo Graphic') 
	   </cfquery>
	</cfif>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'System','#StaffMemberName.FirstName# #StaffMemberName.LastName# edited the Company tab of system configuration.')
		</cfquery>
	</cfif>
</cfif>
<cfif IsDefined("Updtab3.x")>
	<cfif IsDefined("Form.IPADCAuthID")>
		<cfquery name="CheckFirst" datasource="#pds#">
			SELECT * FROM Setup WHERE varname ='IPADCAuthID'
		</cfquery>
		<cfif CheckFirst.RecordCount Is "0">
			<cfquery name="InsValue" datasource="#pds#">
				INSERT INTO Setup (varname, value1, description)
				Values ('IPADCAuthID', '#Form.IPADCAuthID#', 'The IPAD Custom Auth Setup')
			</cfquery>
		<cfelse>
			<cfquery name="UpdValue" datasource="#pds#">
				UPDATE Setup SET 
				Value1 = #Form.IPADCAuthID# 
				WHERE VarName = 'IPADCAuthID' 
			</cfquery>
		</cfif>
	</cfif>
	<cfif IsDefined("form.IPADslipfileftp")>
		<cfquery name="chkIPADslipfileftp" datasource="#pds#">
			SELECT * FROM Setup WHERE varname ='IPADslipfileftp'
		</cfquery>
	   <cfif chkIPADslipfileftp.RecordCount GT 0>
			<cfquery name="setIPADslipfileftp" datasource="#pds#">
				Update Setup set Value1 = '1' 
				WHERE varname = 'IPADslipfileftp'
			</cfquery>
	   <cfelse>
			<cfquery name="setIPADslipfileftp" datasource="#pds#">
				INSERT INTO Setup (varname, value1, description)
				Values ('IPADslipfileftp', '1', 'FTP yn IPAD Slip File')
			</cfquery>
	   </cfif>
	<cfelse>
		<cfquery name="update" datasource="#pds#">
			UPDATE Setup SET value1 = '0' WHERE varname = 'IPADslipfileftp'
		</cfquery>
	</cfif>
	<cfif IsDefined("form.IPADslipfile")>
		<cfquery name="chkIPADslipfile" datasource="#pds#">
			SELECT * FROM Setup WHERE varname ='IPADslipfile'
		</cfquery>
		<cfif chkIPADslipfile.RecordCount GT 0>
			<cfquery name="setIPADslipfile" datasource="#pds#">
				Update Setup set Value1 = '#form.IPADslipfile#' 
				WHERE varname = 'IPADslipfile'
			</cfquery>
		<cfelse>
			<cfquery name="setIPADslipfile" datasource="#pds#">
				INSERT INTO Setup (varname, value1, description)
				Values ('IPADslipfile', '#form.IPADslipfile#', 'IPAD Slip File')
			</cfquery>
		</cfif>
	</cfif>
	<cfif IsDefined("form.IPADslipserver")>
		<cfquery name="chkIPADslipserver" datasource="#pds#">
			SELECT * FROM Setup WHERE varname ='IPADslipserver'
		</cfquery>
	   <cfif chkIPADslipserver.RecordCount GT 0>
			<cfquery name="setIPADslipserver" datasource="#pds#">
				Update Setup set Value1 = '#form.IPADslipserver#' 
				WHERE varname = 'IPADslipserver'
			</cfquery>
	   <cfelse>
			<cfquery name="setIPADslipserver" datasource="#pds#">
				INSERT INTO Setup (varname, value1, description)
				Values ('IPADslipserver', '#form.IPADslipserver#', 'IPAD Slip File Server')
			</cfquery>
	   </cfif>
	</cfif>
	<cfif IsDefined("form.IPADsliplogin")>
		<cfquery name="chkIPADsliplogin" datasource="#pds#">
			SELECT * FROM Setup WHERE varname ='IPADsliplogin'
		</cfquery>
	   <cfif #chkIPADsliplogin.RecordCount# GT 0>
			<cfquery name="setIPADsliplogin" datasource="#pds#">
				Update Setup set Value1 = '#form.IPADsliplogin#' 
				WHERE varname = 'IPADsliplogin'
			</cfquery>
	   <cfelse>
			<cfquery name="setIPADsliplogin" datasource="#pds#">
				INSERT INTO Setup (varname, value1, description)
				Values ('IPADsliplogin', '#form.IPADsliplogin#', 'IPAD Slip File Login')
			</cfquery>
	   </cfif>
	</cfif>
	<cfif IsDefined("form.IPADslippassw")>
		<cfquery name="chkIPADslippassw" datasource="#pds#">
			SELECT * FROM Setup WHERE varname ='IPADslippassw'
		</cfquery>
	   <cfif #chkIPADslippassw.RecordCount# GT 0>
			<cfquery name="setIPADslippassw" datasource="#pds#">
				Update Setup set Value1 = '#form.IPADslippassw#' 
				WHERE varname = 'IPADslippassw'
			</cfquery>
	   <cfelse>
			<cfquery name="setIPADslippassw" datasource="#pds#">
				INSERT INTO Setup (varname, value1, description)
				Values ('IPADslippassw', '#form.IPADslippassw#', 'IPAD Slip File Password')
			</cfquery>
	   </cfif>
	</cfif>
	<cfif IsDefined("form.IPADmailfileftp")>
		<cfquery name="chkIPADmailfileftp" datasource="#pds#">
			SELECT * FROM Setup WHERE varname ='IPADmailfileftp'
		</cfquery>
	   <cfif chkIPADmailfileftp.RecordCount GT 0>
			<cfquery name="setIPADmailfileftp" datasource="#pds#">
				Update Setup set Value1 = '1' 
				WHERE varname = 'IPADmailfileftp'
			</cfquery>
	   <cfelse>
			<cfquery name="setIPADmailfile" datasource="#pds#">
				INSERT INTO Setup (varname, value1, description)
				Values ('IPADmailfileftp', '1', 'FTP yn IPAD mail File')
			</cfquery>
	   </cfif>
	<cfelse>
		<cfquery name="update" datasource="#pds#">
			UPDATE Setup SET value1 = '0' WHERE varname = 'IPADmailfileftp'
		</cfquery>
	</cfif>
	<cfif IsDefined("form.IPADmailserver")>
		<cfquery name="chkIPADmailserver" datasource="#pds#">
			SELECT * FROM Setup WHERE varname ='IPADmailserver'
		</cfquery>
   	<cfif chkIPADmailserver.RecordCount GT 0>
			<cfquery name="setIPADmailserver" datasource="#pds#">
				Update Setup set Value1 = '#form.IPADmailserver#' 
				WHERE varname = 'IPADmailserver'
			</cfquery>
	   <cfelse>
			<cfquery name="setIPADmailserver" datasource="#pds#">
				INSERT INTO Setup (varname, value1, description)
				Values ('IPADmailserver', '#form.IPADmailserver#', 'IPAD mail File Server')
			</cfquery>
	   </cfif>
	</cfif>
	<cfif IsDefined("form.IPADmaillogin")>
		<cfquery name="chkIPADmaillogin" datasource="#pds#">
			SELECT * FROM Setup WHERE varname ='IPADmaillogin'
		</cfquery>
	   <cfif chkIPADmaillogin.RecordCount GT 0>
			<cfquery name="setIPADmaillogin" datasource="#pds#">
				Update Setup set Value1 = '#form.IPADmaillogin#' 
				WHERE varname = 'IPADmaillogin'
			</cfquery>
	   <cfelse>
			<cfquery name="setIPADmaillogin" datasource="#pds#">
				INSERT INTO Setup (varname, value1, description)
				Values ('IPADmaillogin', '#form.IPADmaillogin#', 'IPAD mail File Login')
			</cfquery>
	   </cfif>
	</cfif>
	<cfif IsDefined("form.IPADmailpassw")>
		<cfquery name="chkIPADmailpassw" datasource="#pds#">
			SELECT * FROM Setup WHERE varname ='IPADmailpassw'
		</cfquery>
	   <cfif chkIPADmailpassw.RecordCount GT 0>
			<cfquery name="setIPADmailpassw" datasource="#pds#">
				Update Setup set Value1 = '#form.IPADmailpassw#' 
				WHERE varname = 'IPADmailpassw'
			</cfquery>
	   <cfelse>
			<cfquery name="setIPADmailpassw" datasource="#pds#">
				INSERT INTO Setup (varname, value1, description)
				Values ('IPADmailpassw', '#form.IPADmailpassw#', 'IPAD mail File Password')
			</cfquery>
	   </cfif>
	</cfif>
	<cfif IsDefined("form.IPADmailfile")>
		<cfquery name="chkIPADmailfile" datasource="#pds#">
			SELECT * FROM Setup WHERE varname ='IPADmailfile'
		</cfquery>
		<cfif chkIPADmailfile.RecordCount GT 0>
			<cfquery name="setIPADmailfile" datasource="#pds#">
				Update Setup set Value1 = '#form.IPADmailfile#' 
				WHERE varname = 'IPADmailfile'
			</cfquery>
		<cfelse>
			<cfquery name="setIPADmailfile" datasource="#pds#">
				INSERT INTO Setup (varname, value1, description)
				Values ('IPADmailfile', '#form.IPADmailfile#', 'IPAD Mail File')
			</cfquery>
		</cfif>
	</cfif>
	<cfif IsDefined("form.IPADmailpath")>
		<cfquery name="chkIPADmailpath" datasource="#pds#">
			SELECT * FROM Setup WHERE varname ='IPADmailpath'
		</cfquery>
		<cfif chkIPADmailpath.RecordCount GT 0>
			<cfquery name="setIPADmailpath" datasource="#pds#">
				Update Setup set Value1 = '#form.IPADmailpath#' 
				WHERE varname = 'IPADmailpath'
			</cfquery>
		<cfelse>
			<cfquery name="setIPADmailpath" datasource="#pds#">
				INSERT INTO Setup (varname, value1, description)
				Values ('IPADmailpath', '#form.IPADmailpath#', 'IPAD E-Mail Default Path')
			</cfquery>
		</cfif>
	</cfif>
	<cfif IsDefined("form.IPADftpfile")>
		<cfquery name="chkIPADftpfile" datasource="#pds#">
			SELECT * FROM Setup WHERE varname ='IPADftpfile'
		</cfquery>
	   <cfif chkIPADftpfile.RecordCount GT 0>
			<cfquery name="setIPADftpfile" datasource="#pds#">
				Update Setup set Value1 = '#Form.IPADftpfile#' 
				WHERE varname = 'IPADftpfile'
			</cfquery>
	   <cfelse>
			<cfquery name="setIPADftpfile" datasource="#pds#">
				INSERT INTO Setup (varname, value1, description)
				Values ('IPADftpfile', '#Form.IPADftpfile#', 'FTP yn IPAD ftp File')
			</cfquery>
	   </cfif>
	</cfif>
	<cfif IsDefined("form.IPADftpfileftp")>
		<cfquery name="chkIPADftpfileftp" datasource="#pds#">
			SELECT * FROM Setup WHERE varname ='IPADftpfileftp'
		</cfquery>
	   <cfif chkIPADftpfileftp.RecordCount GT 0>
			<cfquery name="setIPADftpfileftp" datasource="#pds#">
				Update Setup set Value1 = '1' 
				WHERE varname = 'IPADftpfileftp'
			</cfquery>
	   <cfelse>
			<cfquery name="setIPADftpfileftp" datasource="#pds#">
				INSERT INTO Setup (varname, value1, description)
				Values ('IPADftpfileftp', '1', 'FTP yn IPAD ftp File')
			</cfquery>
	   </cfif>
	<cfelse>
		<cfquery name="update" datasource="#pds#">
			UPDATE Setup SET value1 = '0' WHERE varname = 'IPADftpfileftp'
		</cfquery>
	</cfif>
	<cfif IsDefined("form.IPADftpserver")>
		<cfquery name="chkIPADftpserver" datasource="#pds#">
			SELECT * FROM Setup WHERE varname ='IPADftpserver'
		</cfquery>
	   <cfif chkIPADftpserver.RecordCount GT 0>
			<cfquery name="setIPADftpserver" datasource="#pds#">
				Update Setup set Value1 = '#form.IPADftpserver#' 
				WHERE varname = 'IPADftpserver'
			</cfquery>
	   <cfelse>
			<cfquery name="setIPADftpserver" datasource="#pds#">
				INSERT INTO Setup (varname, value1, description)
				Values ('IPADftpserver', '#form.IPADftpserver#', 'IPAD ftp File Server')
			</cfquery>
	   </cfif>
	</cfif>
	<cfif IsDefined("form.IPADftplogin")>
		<cfquery name="chkIPADftplogin" datasource="#pds#">
			SELECT * FROM Setup WHERE varname ='IPADftplogin'
		</cfquery>
	   <cfif chkIPADftplogin.RecordCount GT 0>
			<cfquery name="setIPADftplogin" datasource="#pds#">
				Update Setup set Value1 = '#form.IPADftplogin#' 
				WHERE varname = 'IPADftplogin'
			</cfquery>
	   <cfelse>
			<cfquery name="setIPADftplogin" datasource="#pds#">
				INSERT INTO Setup (varname, value1, description)
				Values ('IPADftplogin', '#form.IPADftplogin#', 'IPAD ftp File Login')
			</cfquery>
	   </cfif>
	</cfif>
	<cfif IsDefined("form.IPADftppassw")>
		<cfquery name="chkIPADftppassw" datasource="#pds#">
			SELECT * FROM Setup WHERE varname ='IPADftppassw'
		</cfquery>
	   <cfif chkIPADftppassw.RecordCount GT 0>
			<cfquery name="setIPADftppassw" datasource="#pds#">
				Update Setup set Value1 = '#form.IPADftppassw#' 
				WHERE varname = 'IPADftppassw'
			</cfquery>
	   <cfelse>
			<cfquery name="setIPADftppassw" datasource="#pds#">
				INSERT INTO Setup (varname, value1, description)
				Values ('IPADftppassw', '#form.IPADftppassw#', 'IPAD ftp File Password')
			</cfquery>
	   </cfif>
	</cfif>
	<cfif Not IsDefined("NoBOBHist")>
		<cfquery name="BOBHist" datasource="#pds#">
			INSERT INTO BOBHist
			(ActionEmail, AccountID, AdminID,  ActionDate, Action, ActionDesc) 
			VALUES 
			(Null,0,#MyAdminID#, #Now()#,'System','#StaffMemberName.FirstName# #StaffMemberName.LastName# edited the IPAD tab of system configuration.')
		</cfquery>
	</cfif>
</cfif>
   
<cfsetting enablecfoutputonly="no">
    
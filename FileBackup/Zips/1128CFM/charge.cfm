<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!---	4.0.0 03/03/00 --->
<!--- charge.cfm --->
<!--- Syntax:  <CF_Charge
					Card="<credit card number>" 
					Member="<credit card holder name>"
					AVSAddress="<Address Verification>"
					AVSZip="<Zipcode for Address Verification>"
					Merchant="<company merchant name>"
					CompName="<company name>"  optional
					ExpMonth="<credit card expire month>"
					ExpYear="<credit card expire year>" 
					Amount="<amount to be charged>"
					CCSoftPackage="<package name of Credit Card Software>" optional
					Action="1 = Sale, 2 = Refund, 3 = Void  See the docs for your credit card software for the exact codes"
					AccountID="<customers accountid>" optional
					Phone="The customers phone number." optional
					EMail="The customers email address." optional
					>
--->
<!--- Returns 	
	"CCRes" variable as either OK or NO depending on success or failure of transaction
	"CCCode" variable as either Authorization Code or Error Code depending on CCRes
	"CCMess" message from the CC center.			
---> 
<cfset pds = caller.pds>
<cfset CCErrorLevel=0>
<cfset CErrorMode="OK">
<cfparam name="MaxCCLen" default="20">
<cfparam name="MinCCLen" default="11">

<cfquery name="GetVarValues" datasource="#pds#">
	SELECT * 
	FROM CustomCCOutput 
	WHERE UseTab = 5 
	AND UseYN = 1
</cfquery>
<cfloop query="GetVarValues">
	<cfset "#FieldName1#" = FieldValue>
</cfloop>
<cfif IsDefined("Mode")>
	<cfset Mode = "Live">
<cfelse>
	<cfset Mode = "Test">
</cfif>
<!--- Check to be sure they passed all the values --->
<cfif Mode Is "Live">
	<cfif IsDefined("Attributes.AVSZip")>
		<cfset ZipCheck= Trim(Attributes.AVSZip)>
		<cfif Trim(ZipCheck) Is "">
			<cfset CCResponse = "No">
			<cfset CCCodeAnswer = "Problem"> 
			<cfset CCMessage = "AVS Zipcode must not be blank."> 
			<cfset CCErrorLevel = "1">
		<cfelseif Not ((Len(ZipCheck) EQ 5) OR (Len(ZipCheck) EQ 9))>
			<cfset CCResponse = "No">
			<cfset CCCodeAnswer = "Problem"> 
			<cfset CCMessage = "AVS Zipcode must be either 5 or 9 characters long."> 
			<cfset CCErrorLevel = "1">
		<cfelseif Not IsNumeric("#ZipCheck#")>
			<cfset CCResponse = "No">
			<cfset CCCodeAnswer = "Problem"> 
			<cfset CCMessage = "AVS Zipcode must be numeric."> 
			<cfset CCErrorLevel = "1">
		</cfif>
	</cfif>
	<cfif IsDefined("Attributes.AVSAddress")>
		<cfif Trim(Attributes.AVSAddress) Is "">
			<cfset CCResponse = "No">
			<cfset CCCodeAnswer = "Problem"> 
			<cfset CCMessage = "AVS Address must not be blank."> 
			<cfset CCErrorLevel = "1">
		</cfif>
	</cfif>
	<cfif IsDefined("Attributes.Merchant")>
		<cfif Trim(Attributes.Merchant) Is "">
			<cfset CCResponse = "No">
			<cfset CCCodeAnswer = "Problem"> 
			<cfset CCMessage = "Merchant Name missing."> 
			<cfset CCErrorLevel = "1">
		</cfif>
	<cfelse>
		<cfset CCResponse = "No">
		<cfset CCCodeAnswer = "Problem"> 
		<cfset CCMessage = "Merchant Name missing."> 
		<cfset CCErrorLevel = "1">
	</cfif>
	<cfif CCErrorLevel Is 0>
		<cfif IsDefined("Attributes.Amount")>
			<cfif Not IsNumeric(Attributes.Amount)>
				<cfset CCResponse = "No">
				<cfset CCCodeAnswer = "Problem"> 
				<cfset CCMessage = "The amount must be in numeric format."> 
				<cfset CCErrorLevel = "1">
			</cfif>
			<cfif Attributes.Amount Is "0">
				<cfset CCResponse = "No">
				<cfset CCCodeAnswer = "Problem"> 
				<cfset CCMessage = "The amount can not be $0."> 
				<cfset CCErrorLevel = "1">
			</cfif>
			<cfif CCErrorLevel Is "0">
				<cfset ChargeAmt= Trim(NumberFormat(Attributes.Amount, "999999.99"))>
			</cfif>
		<cfelse>
			<cfset CCResponse = "No">
			<cfset CCCodeAnswer = "Problem"> 
			<cfset CCMessage = "The amount was not provided."> 
			<cfset CCErrorLevel = "1">
		</cfif>
	</cfif>
	<cfif CCErrorLevel is 0>
		<cfif IsDefined("Attributes.ExpMonth")>
			<cfif Not IsNumeric(Attributes.ExpMonth)>
				<cfset CCResponse = "No">
				<cfset CCCodeAnswer = "Problem"> 
				<cfset CCMessage = "The credit card expiration month must be in a numeric format."> 
				<cfset CCErrorLevel = "1">
			<cfelseif (Attributes.ExpMonth GT 12) OR (Attributes.ExpMonth LT 1)>
				<cfset CCResponse = "No">
				<cfset CCCodeAnswer = "Problem"> 
				<cfset CCMessage = "The credit card expiration month must be a valid month."> 
				<cfset CCErrorLevel = "1">
			</cfif>
			<cfif CCErrorLevel Is "0">
				<cfset CCExpMonth = Int(Attributes.ExpMonth)>
			</cfif>
		<cfelse>
			<cfset CCResponse = "No">
			<cfset CCCodeAnswer = "Problem"> 
			<cfset CCMessage = "The credit card expiration month is missing."> 
			<cfset CCErrorLevel = "1">
		</cfif>
	</cfif>
	<cfif CCErrorLevel is 0>
		<cfif IsDefined("Attributes.ExpYear")>
			<cfif Not IsNumeric(Attributes.ExpYear)>
				<cfset CCResponse = "No">
				<cfset CCCodeAnswer = "Problem"> 
				<cfset CCMessage = "The credit card expiration year must be in a numeric format."> 
				<cfset CCErrorLevel = "1">
			</cfif>
			<cfif Len(Attributes.ExpYear) Is Not "4">
				<cfset CCResponse = "No">
				<cfset CCCodeAnswer = "Problem"> 
				<cfset CCMessage = "The credit card expiration year must be four digits. Ex. 2000"> 
				<cfset CCErrorLevel = "1">
			</cfif>
			<cfif CCErrorLevel Is "0">
				<cfset CCExpYear = Attributes.ExpYear>
			</cfif>
		<cfelse>
			<cfset CCResponse = "No">
			<cfset CCCodeAnswer = "Problem"> 
			<cfset CCMessage = "The credit card expiration year is missing."> 
			<cfset CCErrorLevel = "1">
		</cfif>
	</cfif>
	<cfif CCErrorLevel is 0>
		<cfif Not IsDefined("Attributes.Card")>
			<cfset CCResponse = "No">
			<cfset CCCodeAnswer = "Problem"> 
			<cfset CCMessage = "Credit card number not supplied."> 
			<cfset CCErrorLevel = "1">
		<cfelseif Not IsNumeric(Attributes.Card)>
			<cfset CCResponse = "No">
			<cfset CCCodeAnswer = "Problem"> 
			<cfset CCMessage = "Credit card number must consist of ONLY numbers, without spaces or dashes."> 
			<cfset CCErrorLevel = "1">
		<cfelseif (Len(Attributes.Card) LT MinCCLen) OR (Len(Attributes.Card) GT MaxCCLen)>
			<cfset CCResponse = "No">
			<cfset CCCodeAnswer = "Problem"> 
			<cfset CCMessage = "Credit card number must be between #MinCCLen# and #MaxCCLen# characters in length."> 
			<cfset CCErrorLevel = "1">
		</cfif>
	</cfif>
	<cfif CCErrorLevel Is 0>
		<cfset CardTypeA = Left(Attributes.Card,1)>
		<cfif CardTypeA Is "3">
			<cfset CardType = "American Express">
		<cfelseif CardTypeA Is "4">
			<cfset CardType = "Visa">
		<cfelseif CardTypeA Is "5">
			<cfset CardType = "MasterCard">
		<cfelseif CardTypeA Is "6">
			<cfset CardType = "Discover">
		<cfelse>
			<cfset CardType = "Other">
		</cfif>
	</cfif>
	<cfif CCErrorLevel is 0>
		<cfif Not IsDefined("Attributes.Member")>
			<cfset CCResponse = "No">
			<cfset CCCodeAnswer = "Problem"> 
			<cfset CCMessage = "Credit card holder name not supplied."> 
			<cfset CCErrorLevel = "1">
		<cfelseif Attributes.Member is "">
			<cfset CCResponse = "No">
			<cfset CCCodeAnswer = "Problem"> 
			<cfset CCMessage = "Credit card holder name must not be blank."> 
			<cfset CCErrorLevel=1>
		</cfif>
	</cfif>
	<!--- Passed all the checks --->
	<cfif CCErrorLevel is 0>
		<cfset Meth = "Lock">
		<cfinclude template="chargelock.cfm">
		<cfif GoBack is 0>
			<cfset starttime=now()>
			<cfquery name="GeneralCCStuff" datasource="#pds#">
				SELECT * 
            FROM CustomCCOutput 
            WHERE UseTab = 3 
				AND FieldValue = 1 
			</cfquery>
			<cfif Not IsDefined("Attributes.CCSoftPackage")>
				<cfset CCPack = GeneralCCStuff.Description1>
			<cfelse>
				<cfset CCPack = Attributes.CCSoftPackage>
			</cfif>	
			<cfquery name="GetApproveCode" datasource="#pds#">
				SELECT FieldValue 
				FROM CustomCCOutput 
				WHERE UseTab = 8 
				AND FieldName1 = 'Approved'
			</cfquery>
			<cfset TheApprovalCodeIs = GetApproveCode.FieldValue>
			<cfquery name="GetSoftwareCodes" datasource="#pds#">
				SELECT * 
				FROM CustomCCOutput 
				WHERE UseTab = 8 
				AND (FieldName1 = 'AmericanExpress' 
				   	OR FieldName1 = 'Discover' 
						OR FieldName1 = 'MasterCard' 
						OR FieldName1 = 'Visa' )
			</cfquery>
			<cfloop query="GetSoftwareCodes">
				<cfset "Var#FieldName1#" = FieldValue>
			</cfloop>
			<cfquery name="GetYearFormat" datasource="#pds#">
				SELECT FieldValue 
				FROM CustomCCOutput 
				WHERE UseTab = 5 
				AND FieldName1 = 'CCYearFormat'
			</cfquery>
			<cfif GetYearFormat.FieldValue Is 2>
				<cfset TheExpYear = Right(Attributes.ExpYear,2)>
			<cfelse>
				<cfset TheExpYear = Attributes.ExpYear>
			</cfif>
			<cfif Len(Attributes.ExpMonth) Is "1">
				<cfset TheExpMonth = "0" & Attributes.ExpMonth>
			<cfelse>
				<cfset TheExpMonth = Attributes.ExpMonth>
			</cfif>
			<cfif CCPack is "pccharge">
				<!--- PC Charge --->
				<cfparam name="Attributes.AVSAddress" default="">
				<cfparam name="Attributes.AVSZip" default="">
				<cfparam name="Attributes.Action" default="1">
				<cfobject action="CREATE" name="Charge1" class="PSCharge.Charge">
					<cfset Charge1.Path = Path>
					<cfset Charge1.Processor = Processor>
					<cfset Charge1.MerchantNumber = MerchantAccount>
					<cfset Charge1.User = Login>
					<cfset Charge1.Card = REReplace(Attributes.Card,"[^0-9]","","ALL")>
					<cfset Charge1.ExpDate = TheExpMonth & TheExpYear>
					<cfset Charge1.Amount = ChargeAmt>
					<cfset Charge1.Member = Attributes.Member>
					<cfset Charge1.Street = Attributes.AVSAddress>
					<cfset Charge1.Zip = Attributes.AVSZip>
					<cfset Charge1.Action = Attributes.Action>
					<cfset Charge1.Send()>
					<cfset TheResult = Charge1.GetResult()>
					<cfset TheAuthCode = Charge1.GetAuth()>
					<cfset Charge1.DeleteUserFiles()>
				<cfif Charge1.GetErrorCode() is 0>
					<cfif Trim(TheResult) Is TheApprovalCodeIs>
						<cfset CCResponse = "OK">
						<cfset CCCodeAnswer = Trim(TheResult)> 
						<cfset CCMessage = Trim(TheAuthCode)>
						<cfset CCErrorLevel = "0">
					<cfelse>
						<cfset CCResponse = "No">
						<cfset CCCodeAnswer = "Problem"> 
						<cfset CCMessage = TRIM(TheAuthCode)> 
						<cfset CCErrorLevel = "1">
					</cfif>
				<cfelse>
					<cfset CCResponse = "No">
					<cfset CCCodeAnswer = "Problem">
					<cfset CCMessage = Charge1.GetErrorDesc()>
					<cfset CCErrorLevel = "1">
				</cfif>
				<!--- End PC Charge --->
			<cfelseif CCPack is "PCAuth">
				<!--- PC Auth --->		
				<cfx_pca Account="#Attributes.Card#" Amount="#ChargeAmt#"
				 ExpDate="#TheExpMonth##TheExpYear#"
				 AVSAddr="#AVSAddr#" AVSZip="#AVSZip#" AccountID="">
				<CFIF Status Is TheApprovalCodeIs>
					<cfset CCResponse = "OK">
					<cfset CCCodeAnswer = AuthCode> 
					<cfset CCMessage = AuthCode>
					<cfset CCErrorLevel = "0">
				<CFELSE>
					<cfset CCResponse = "No">
					<cfset CCCodeAnswer = "Problem"> 
					<cfset CCMessage = "Problem"> 
					<cfset CCErrorLevel = "1">
				</cfif>
			<cfelseif (CCPack is "icverify") OR (CCPack is "ezcharge")>
				<!--- IC Verify by ICVerify --->		
				<CFX_ICV NAME="DebitCard" IC_SHAREDIR="#Path#"
				 ACCOUNT="#Attributes.Card#" AMOUNT="#ChargeAmt#" 
				 EXPIRES_MO="#TheExpMonth#" EXPIRES_YR="#TheExpYear#"
				 TRANS_TYPE="#Attributes.Action#">
				<CFIF DebitCard.Validated Is TheApprovalCodeIs>
					<cfset CCResponse = "OK">
					<cfset CCCodeAnswer = DebitCard.Auth_No> 
					<cfset CCMessage = DebitCard.Auth_No>
					<cfset CCErrorLevel = "0">
				<CFELSE>
					<cfset CCResponse = "No">
					<cfset CCCodeAnswer = "Problem"> 
					<cfset CCMessage = "Problem"> 
					<cfset CCErrorLevel = "1">
				</cfif>
			<cfelseif CCPack is "euicverify">
				<!--- European ICVerify --->		
				<CF_GS_EURO_ICVERIFY Card="#Attributes.Card#" 
				 ExpYr="#TheExpYear#" ExpMo="#TheExpMonth#" 
				 Amount="#ChargeAmt#" > 
				 <CFIF Validated Is TheApprovalCodeIs>
					<cfset CCResponse = "OK">
					<cfset CCCodeAnswer = Auth_No> 
					<cfset CCMessage = Auth_No>
					<cfset CCErrorLevel = "0">
				<CFELSE>
					<cfset CCResponse = "No">
					<cfset CCCodeAnswer = "Problem"> 
					<cfset CCMessage = "Problem"> 
					<cfset CCErrorLevel = "1">
				</cfif>
			<cfelseif CCPack is "atsbank">
				<!--- ATS Bank --->		
				<cfif CardType Is "American Express">
					<cfset TheCardType = VarAmericanExpress>
				<cfelseif CardType Is "Mastercard">
					<cfset TheCardType = VarMasterCard>
				<cfelseif CardType Is "Visa">
					<cfset TheCardType = VarVisa>
				<cfelseif CardType Is "Discover">
					<cfset TheCardType = VarDiscover>				
				<cfelseif CardType Is "Other">
					<cfset TheCardType = "OTHER">				
				</cfif>
				<CF_GSATSBANK Amount="#ChargeAmt#" CardType="#TheCardType#" 
				 Name="#Attributes.Member#" ExpireYear="#TheExpYear#" 
				 ExpireMonth="#TheExpMonth#" CCNumber="#Attributes.Card#"> 
				<cfif UCASE(Validated) Is TheApprovalCodeIs>
					<cfset CCResponse = "OK">
					<cfset CCCodeAnswer = Auth_No> 
					<cfset CCMessage = Auth_No>
					<cfset CCErrorLevel = "0">
				<cfelse>
					<cfset CCResponse = "No">
					<cfset CCCodeAnswer = "Problem"> 
					<cfset CCMessage = "Problem"> 
					<cfset CCErrorLevel = "1">
				</cfif>
			<cfelseif CCPack is "cyber">
				<!--- CyberCash --->		
				<cfset ORDER = "0#DateFormat(NOW(),'YYMMDD')##TimeFORMAT(NOW(),'HHmmss')#">
				<cfparam name="transtype" default="mauthonly">
				<CFX_CYBERCASH	VERSION="#Version#"
									CCPS_HOST="#URL#"
									CYBERCASH_ID="#CashID#"
									MERCHANT_KEY="#MerchantAccount#" 
									ACTION="#Attributes.Action#"
									ORDER_ID="#ORDER#"
									AMOUNT="#ChargeAmt#"
									CARD_NUMBER="#Attributes.Card#"
									CARD_EXP="#TheExpMonth#/#TheExpYear#"
									CARD_NAME="#Attributes.Member#"
									CARD_ADDRESS="#Attributes.AvsAddress#"
									CARD_ZIP="#Attributes.AVSZIP#"
									OutputFieldsQuery="DebitCard"
									>
				<CFIF mid(DebitCard.MStatus,1,7) Is TheApprovalCodeIs>
					<cfset CCResponse = "OK">
					<cfset CCCodeAnswer = DebitCard.Auth_Code> 
					<cfset CCMessage = DebitCard.Auth_Code>
					<cfset CCErrorLevel = "0">
				<CFELSE>
					<cfset CCResponse = "No">
					<cfset CCCodeAnswer = "Problem"> 
					<cfset CCMessage = "Problem"> 
					<cfset CCErrorLevel = "1">
				</cfif>
		 	<cfelseif CCPack is "formbased">
				<!--- Form Based --->
				<cfif CardType Is "American Express">
					<cfset TheCardType = VarAmericanExpress>
				<cfelseif CardType Is "Mastercard">
					<cfset TheCardType = VarMasterCard>
				<cfelseif CardType Is "Visa">
					<cfset TheCardType = VarVisa>
				<cfelseif CardType Is "Discover">
					<cfset TheCardType = VarDiscover>				
				<cfelseif CardType Is "Other">
					<cfset TheCardType = "OTHER">				
				</cfif>
				<cfquery name="GetFormFields" datasource="#pds#">
					SELECT * 
					FROM CustomCCOutput 
					WHERE UseTab = 7 
					AND UseYN = 1 
				</cfquery>
				<cfif IsDefined("Attributes.AccountID")>
					<cfset TheID = Attributes.AccountID>
				<cfelse>
					<cfset TheID = 0>
				</cfif>
				<cfset Pos1 = Find(Attributes.Member," ")>
				<cfset Len1 = Len(Attributes.Member) - Pos1>
				<cfif Pos1 GT 0>
					<cfset TheFName = Trim(Mid(Attributes.Member,1,Pos1))>
					<cfif Len1 GT 0>
						<cfset TheLName = Mid(Attributes.Member,Pos1,Len1)>
					<cfelse>
						<cfset TheLName = "">
					</cfif>
				<cfelse>
					<cfset TheFName = Attributes.Member>
					<cfset TheLName = "">
				</cfif>
				<cfif Trim(TheFName) Is "">
					<cfset TheFName = "NA">
				</cfif>
				<cfif Trim(TheLName) Is "">
					<cfset TheLName = "NA">
				</cfif>
				<cfif Trim(Attributes.AVSAddress) Is "">
					<cfset TheAddress = "NA">
				<cfelse>
					<cfset TheAddress = Trim(Attributes.AVSAddress)>
				</cfif>
				<cfif IsDefined("Attributes.Phone")>
					<cfset ThePhone = Attributes.Phone>
				<cfelse>
					<cfset ThePhone = "">
				</cfif>
				<cfif Trim(ThePhone) Is "">
					<cfset ThePhone = "NA">
				</cfif>
				<cfif IsDefined("Attributes.EMail")>
					<cfset TheEmailAddr = Attributes.EMail>
				<cfelse>
					<cfset TheEmailAddr = "">
				</cfif>
				<cfif Trim(TheEmailAddr) Is "">
					<cfset TheEM = "NA">
				</cfif>
				<cfhttp url="#URL#" method="POST">
					<cfloop query="GetFormFields">
						<cfset WorkVar = FieldValue>
						<cfset SendValue = ReplaceList("#WorkVar#","%CC00,%CC01,%CC02,%CC03,%CC04,%CC05,%CC06,%CC07,%CC08,%CC09,%CC10,%CC11,%CC12","#TheID#,#TheFName#,#TheLName#,#TheAddress#,#ThePhone#,#Attributes.AVSZip#,#TheEM#,#Attributes.Amount#,#Attributes.Card#,#TheExpMonth#,#TheExpYear#,#TheCardType#,N#TheID##DateFormat(Now(), 'yyyymmddhhmmss')#")>
						<cfhttpparam type="FORMFIELD" name="#FieldName1#" value="#SendValue#">
					</cfloop>
				</cfhttp>
				<cfset Result1 = cfhttp.filecontent>
				<cfquery name="GetResponseItems" datasource="#pds#">
					SELECT * 
					FROM CustomCCOutput 
					WHERE UseTab = 8 
					AND (FieldName1 = 'ApproveDelimiter' 
							OR FieldName1 = 'ResponseField' 
							OR FieldName1 = 'CodeField' 
							OR FieldName1 = 'MessageField' ) 
				</cfquery>
				<cfloop query="GetResponseItems">
					<cfset "Var#FieldName1#" = FieldValue>
				</cfloop>
				<cfset Len1 = Len("#TheApprovalCodeIs#")>
				<cfset TheRes = ListGetAt("#Result1#","#VarResponseField#","#VarApproveDelimiter#")>
				<cfset TheCde = ListGetAt("#Result1#","#VarCodeField#","#VarApproveDelimiter#")>
				<cfset TheMes = ListGetAt("#Result1#","#VarMessageField#","#VarApproveDelimiter#")>
				<cfif TheRes Is TheApprovalCodeIs>
					<cfset CCResponse = "OK">
					<cfset CCCodeAnswer = TheCde> 
					<cfset CCMessage = TheCde>
					<cfset CCErrorLevel = "0">
				<cfelse>
					<cfset CCResponse = "No">
					<cfset CCCodeAnswer = "Problem"> 
					<cfset CCMessage = "Problem"> 
					<cfset CCErrorLevel = "1">
				</cfif>
			<cfelse>
				<!--- No valid CC Company Provided --->
				<cfset CCResponse = "No">
				<cfset CCCodeAnswer = "Problem"> 
				<cfset CCMessage = "Unrecognized CC Company."> 
				<cfset CCErrorLevel = "1">
			</cfif>
		<cfelse>
			<cfset CCResponse = "No">
			<cfset CCCodeAnswer = "Problem"> 
			<cfset CCMessage = "The charge tag is locked and has a problem.  Please unlock it by editing the <a href=""ccsetup.cfm?Tab2=4"">Credit Card Setup for Live Debiting.</a>"> 
			<cfset CCErrorLevel = "1">
		</cfif>
		<cfset Meth = "UnLock">
		<cfinclude template="chargelock.cfm">
	</cfif>
<cfelse>
	<cfset TestVar1 = RandRange(1,100)>
	<cfset TestVar2 = TestVar1 Mod 2>
	<cfif IsDefined("Attributes.TestResult")>
		<cfif Attributes.TestResult Is "A">
			<cfset TestVar2 = 0>
		<cfelseif Attributes.TestResult Is "D">
			<cfset TestVar2 = 1>
		</cfif>
	</cfif>
	<cfif TestVar2 Is 1>
		<cfset CCResponse = "No">
		<cfset CCCodeAnswer = "Problem">
		<cfset CCMessage = "Test Response Card Declined.">
		<cfset CCErrorLevel = "1">
	<cfelse>
		<cfset CCResponse = "Ok">
		<cfset CCCodeAnswer = "A1234567">
		<cfset CCMessage = "Test Response Card Approved.">
		<cfset CCErrorLevel = "0">
	</cfif>
</cfif>

<cfset Caller.CCRes = CCResponse> 
<cfset Caller.CCCode = CCCodeAnswer> 
<cfset Caller.CCMess = CCMessage> 
<cfsetting enablecfoutputonly="No">
 
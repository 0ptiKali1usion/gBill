<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- Integration page for Authorize.Net --->
<!--- 4.0.0 12/14/00 --->
<!--- authnet.cfm --->

<cfif IntCode Is "CreditCardBatch">
	<cfset TheCode = "authnet">
	<cfset TheDisp = "Authorize Net">
	<cfset FieldCodes = "bal;3,cctype;4,ccnum;6,ccmonccyear;7,accountid;9,cardhold;10,AVSAddr;11,AVSZIP;14">
	<cfset CustomFields1 = "Internet Charges;Internet Charges;2,NA;NA;5">
	<cfset CustomFields2 = "Internet Credit;Internet Credit;2,NA;NA;5">
	<cfset FieldGeneral = "ccamountformat; ,ccamountperiod;1,ccdateformat;MM-DD-YYYY,ccdelimit;**@**,ccenclose;0,ccenclosenull;0,cchrout; ,ccnumfield;21,ccoutputheadrow;0,cctimeformat;hh:mm:ss,ccyearformat;yyyy,MaxPerFile;500">
	<cfset ImportCodes = "accountid;9;1,amount;3;1,authcode;22;1,ccnum;4;1">
	<cfset ImportGeneral = "ccinputlines;1,ccinputheadrow;0,codewide;1">
	<cfset ShowButton = 1>
<cfelseif IntCode Is "CreditCardLive">
	<cfset TheCode = "authnet">
	<cfset TheDisp = "Authorize Net">
	<cfset UseTab = "3,5,5,5,8,8,8,8,8,8,8,8,8,8,8,8,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7">
	<cfset FldName = "Form Based,CCYearFormat,URL,Merchant,AmericanExpress,Approved,ApproveDelimiter,CodeField,DecMessageField,Discover,Mastercard,MessageField,RefundCode,ResponseField,SaleCode,Visa,TYPE,x_ADC_Delim_Data,x_ADC_URL,x_Address,x_Amount,x_Card_Num,x_Cust_ID,x_Description,x_Email_Customer,x_Exp_Date,x_Invoice_Num,x_Last_Name,x_login,x_Method,x_Password,x_Test_Request,x_Version,x_Zip">
	<cfset FldValue = "1,2,***http://www.authorize.net/scripts/authnet25/wldotrans.asp***,***MerchantName***,AMEX,1,**@**,5,2,DISCOVER,MASTERCARD,2,3,1,1,VISA,NA,True,False,%CC03,%CC07,%CC08,%CC00,Internet Service,False,%CC09%CC10,%CC12,%CC02,***Merchant Login***,CC,***Password***,False,3.5,%CC05">
	<cfset ShowButton = 1>
<cfelse>
	<cfset ShowButton = 0>
</cfif>
<cfsetting enablecfoutputonly="No">
 

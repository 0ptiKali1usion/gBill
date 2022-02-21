<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page loads the values for Authentication. --->
<!---	4.0.0 09/16/99 --->
<!--- CfPayment.cfm --->

<cfparam name="TransType" default="Credit">
<cfparam name="TheAccountID" default="0">
<cfquery name="GetWho" datasource="#pds#">
	SELECT AccountID 
	FROM Accounts 
	WHERE AccountID In 
		(#TheAccountID#) 
</cfquery>
<cfif TransType Is "Credit">
	<cfloop query="GetWho">
		<cfset LoopAccountID = AccountID>
		<cfquery name="AllCredts" datasource="#pds#">
			SELECT * 
			FROM Transactions 
			WHERE AccountID = #LoopAccountID#
			AND CreditLeft > 0 
			ORDER BY TransID 
		</cfquery>
		<cfloop query="AllCredts">
			<cfset TheCreditAmount = CreditLeft>
			<cfset TheTransID = TransID>
			<cfquery name="FindDebits" datasource="#pds#">
				SELECT * 
				FROM Transactions 
				WHERE DebitLeft > 0 
				AND AccountID = #LoopAccountID#
				ORDER BY TransID 
			</cfquery>
			<cfloop query="FindDebits">
				<cfif TheCreditAmount GT 0>
					<cfif TheCreditAmount GTE DebitLeft>
						<cfset TheCreditAmount = TheCreditAmount - DebitLeft>
						<cfquery name="UpdData" datasource="#pds#">
							UPDATE Transactions SET 
							DebitLeft = 0 
							WHERE TransID = #TransID# 
						</cfquery>
						<cfquery name="UpdData" datasource="#pds#">
							UPDATE Transactions SET 
							CreditLeft = #TheCreditAmount# 
							WHERE TransID = #TheTransID# 
						</cfquery>
					<cfelseif TheCreditAmount LT DebitLeft>
						<cfset TheDebitAmount = DebitLeft - TheCreditAmount>
						<cfset TheCreditAmount = 0>
						<cfquery name="UpdData" datasource="#pds#">
							UPDATE Transactions SET 
							DebitLeft = #TheDebitAmount# 
							WHERE TransID = #TransID#
						</cfquery>
						<cfquery name="UpdData" datasource="#pds#">
							UPDATE Transactions SET 
							CreditLeft = 0 
							WHERE TransID = #TheTransID#
						</cfquery>
					</cfif>
				</cfif>
			</cfloop>
		</cfloop>
	</cfloop>
<cfelseif TransType Is "Debit">
	<cfloop query="GetWho">
		<cfset LoopAccountID = AccountID>
		<cfquery name="AllDebits" datasource="#pds#">
			SELECT * 
			FROM Transactions 
			WHERE AccountID = #LoopAccountID#
			AND DebitLeft > 0 
			ORDER BY TransID 
		</cfquery>
		<cfloop query="AllDebits">
			<cfset TheDebitAmount = DebitLeft>
			<cfset TheTransID = TransID>
			<cfquery name="FindCredits" datasource="#pds#">
				SELECT * 
				FROM Transactions 
				WHERE CreditLeft > 0 
				AND AccountID = #LoopAccountID#
				ORDER BY TransID 
			</cfquery>
			<cfloop query="FindCredits">
				<cfif TheDebitAmount GT 0>
					<cfif TheDebitAmount GTE CreditLeft>
						<cfset TheDebitAmount = TheDebitAmount - CreditLeft>
						<cftransaction>
							<cfquery name="UpdData" datasource="#pds#">
								UPDATE Transactions SET 
								CreditLeft = 0 
								WHERE TransID = #TransID# 
							</cfquery>
							<cfquery name="UpdData" datasource="#pds#">
								UPDATE Transactions SET 
								DebitLeft = #TheDebitAmount# 
								WHERE TransID = #TheTransID# 
							</cfquery>
						</cftransaction>
					<cfelseif TheDebitAmount LT CreditLeft>
						<cfset TheCreditAmount = CreditLeft - TheDebitAmount>
						<cfset TheDebitAmount = 0>
						<cftransaction>
							<cfquery name="UpdData" datasource="#pds#">
								UPDATE Transactions SET 
								CreditLeft = #TheCreditAmount# 
								WHERE TransID = #TransID#
							</cfquery>
							<cfquery name="UpdData" datasource="#pds#">
								UPDATE Transactions SET 
								DebitLeft = 0 
								WHERE TransID = #TheTransID#
							</cfquery>
						</cftransaction>
					</cfif>
				</cfif>
			</cfloop>
		</cfloop>
	</cfloop>
</cfif>
 
<cfsetting enablecfoutputonly="no">
 
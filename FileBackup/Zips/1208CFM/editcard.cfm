<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- This page edits the customers payment information. --->
<!--- 4.0.0 09/29/99 
		3.2.0 09/08/98 --->
<!--- editcard.cfm --->
<cfif GetOpts.EditPay Is 1>
	<cfset securepage = "lookup1.cfm">
</cfif>
<cfinclude template="security.cfm">
<cfif (IsDefined("ClearCk.x")) AND (IsDefined("Delthese"))>
	<cfloop index="B5" list="#DelThese#">
		<cfif B5 GT 0>
			<cfquery name="CheckCC" datasource="#pds#">
				SELECT * 
				FROM PayByCC 
				WHERE AccountID = #AccountID# 
				AND AccntPlanID = #B5# 
			</cfquery>
			<cfquery name="CheckCD" datasource="#pds#">
				SELECT * 
				FROM PayByCD 
				WHERE AccountID = #AccountID# 
				AND AccntPlanID = #B5# 
			</cfquery>
			<cfquery name="CheckPO" datasource="#pds#">
				SELECT * 
				FROM PayByPO 
				WHERE AccountID = #AccountID# 
				AND AccntPlanID = #B5# 
			</cfquery>
			<cfif (CheckCC.Recordcount GT 0) OR (CheckCD.Recordcount GT 0) OR (CheckPO.Recordcount GT 0)>
				<cfquery name="DelData" datasource="#pds#">
					DELETE FROM PayByCK 
					WHERE AccountID = #AccountID# 
					AND AccntPlanID = #B5# 
				</cfquery>
				<cfquery name="CheckPayType" datasource="#pds#">
					SELECT PayBy 
					FROM AccntPlans 
					WHERE AccntPlanID = #B5# 
				</cfquery>
				<cfif CheckPayType.PayBy Is "ck">
					<cfif CheckPO.Recordcount GT 0>
						<cfquery name="UpdData" datasource="#pds#">
							UPDATE AccntPlans SET 
							PayBy = 'po' 
							WHERE AccntPlanID = #B5#
						</cfquery>
					</cfif>
					<cfif CheckCD.Recordcount GT 0>
						<cfquery name="UpdData" datasource="#pds#">
							UPDATE AccntPlans SET 
							PayBy = 'cd' 
							WHERE AccntPlanID = #B5#
						</cfquery>
					</cfif>
					<cfif CheckCC.Recordcount GT 0>
						<cfquery name="UpdData" datasource="#pds#">
							UPDATE AccntPlans SET 
							PayBy = 'cc' 
							WHERE AccntPlanID = #B5#
						</cfquery>
					</cfif>
				</cfif>
			<cfelse>
				<cfquery name="SetPayBy" datasource="#pds#">
					UPDATE AccntPlans SET 
					PayBy = 'cc' 
					WHERE AccntPlanID = #B5#
				</cfquery>
			</cfif>
		</cfif>
	</cfloop>
</cfif>
<cfif (IsDefined("ClearCD.x")) AND (IsDefined("Delthese"))>
	<cfloop index="B5" list="#DelThese#">
		<cfif B5 GT 0>
			<cfquery name="CheckCC" datasource="#pds#">
				SELECT * 
				FROM PayByCC 
				WHERE AccountID = #AccountID# 
				AND AccntPlanID = #B5# 
			</cfquery>
			<cfquery name="CheckCK" datasource="#pds#">
				SELECT * 
				FROM PayByCk 
				WHERE AccountID = #AccountID# 
				AND AccntPlanID = #B5# 
			</cfquery>
			<cfquery name="CheckPO" datasource="#pds#">
				SELECT * 
				FROM PayByPO 
				WHERE AccountID = #AccountID# 
				AND AccntPlanID = #B5# 
			</cfquery>
			<cfif (CheckCC.Recordcount GT 0) OR (CheckCK.Recordcount GT 0) OR (CheckPO.Recordcount GT 0)>
				<cfquery name="DelData" datasource="#pds#">
					DELETE FROM PayByCD 
					WHERE AccountID = #AccountID# 
					AND AccntPlanID = #B5# 
				</cfquery>
				<cfquery name="CheckPayType" datasource="#pds#">
					SELECT PayBy 
					FROM AccntPlans 
					WHERE AccntPlanID = #B5# 
				</cfquery>
				<cfif CheckPayType.PayBy Is "cd">
					<cfif CheckPO.Recordcount GT 0>
						<cfquery name="UpdData" datasource="#pds#">
							UPDATE AccntPlans SET 
							PayBy = 'po' 
							WHERE AccntPlanID = #B5#
						</cfquery>
					</cfif>
					<cfif CheckCK.Recordcount GT 0>
						<cfquery name="UpdData" datasource="#pds#">
							UPDATE AccntPlans SET 
							PayBy = 'ck' 
							WHERE AccntPlanID = #B5#
						</cfquery>
					</cfif>
					<cfif CheckCC.Recordcount GT 0>
						<cfquery name="UpdData" datasource="#pds#">
							UPDATE AccntPlans SET 
							PayBy = 'cc' 
							WHERE AccntPlanID = #B5#
						</cfquery>
					</cfif>
				</cfif>
			<cfelse>
				<cfquery name="SetPayBy" datasource="#pds#">
					UPDATE AccntPlans SET 
					PayBy = 'cd' 
					WHERE AccntPlanID = #B5#
				</cfquery>
			</cfif>
		</cfif>
	</cfloop>
</cfif>
<cfif (IsDefined("ClearCC.x")) AND (IsDefined("Delthese"))>
	<cfloop index="B5" list="#DelThese#">
		<cfif B5 GT 0>
			<cfquery name="CheckCD" datasource="#pds#">
				SELECT * 
				FROM PayByCD 
				WHERE AccountID = #AccountID# 
				AND AccntPlanID = #B5# 
			</cfquery>
			<cfquery name="CheckCK" datasource="#pds#">
				SELECT * 
				FROM PayByCk 
				WHERE AccountID = #AccountID# 
				AND AccntPlanID = #B5# 
			</cfquery>
			<cfquery name="CheckPO" datasource="#pds#">
				SELECT * 
				FROM PayByPO 
				WHERE AccountID = #AccountID# 
				AND AccntPlanID = #B5# 
			</cfquery>
			<cfif (CheckCD.Recordcount GT 0) OR (CheckCK.Recordcount GT 0) OR (CheckPO.Recordcount GT 0)>
				<cfquery name="DelData" datasource="#pds#">
					DELETE FROM PayByCC 
					WHERE AccountID = #AccountID# 
					AND AccntPlanID = #B5# 
				</cfquery>
				<cfquery name="CheckPayType" datasource="#pds#">
					SELECT PayBy 
					FROM AccntPlans 
					WHERE AccntPlanID = #B5# 
				</cfquery>
				<cfif CheckPayType.PayBy Is "cc">
					<cfif CheckPO.Recordcount GT 0>
						<cfquery name="UpdData" datasource="#pds#">
							UPDATE AccntPlans SET 
							PayBy = 'po' 
							WHERE AccntPlanID = #B5#
						</cfquery>
					</cfif>
					<cfif CheckCD.Recordcount GT 0>
						<cfquery name="UpdData" datasource="#pds#">
							UPDATE AccntPlans SET 
							PayBy = 'cd' 
							WHERE AccntPlanID = #B5#
						</cfquery>
					</cfif>
					<cfif CheckCK.Recordcount GT 0>
						<cfquery name="UpdData" datasource="#pds#">
							UPDATE AccntPlans SET 
							PayBy = 'ck' 
							WHERE AccntPlanID = #B5#
						</cfquery>
					</cfif>
				</cfif>
			<cfelse>
				<cfquery name="SetPayBy" datasource="#pds#">
					UPDATE AccntPlans SET 
					PayBy = 'cc' 
					WHERE AccntPlanID = #B5#
				</cfquery>
			</cfif>
		</cfif>
	</cfloop>
</cfif>
<cfif (IsDefined("ClearPO.x")) AND (IsDefined("Delthese"))>
	<cfloop index="B5" list="#DelThese#">
		<cfif B5 GT 0>
			<cfquery name="CheckCD" datasource="#pds#">
				SELECT * 
				FROM PayByCD 
				WHERE AccountID = #AccountID# 
				AND AccntPlanID = #B5# 
			</cfquery>
			<cfquery name="CheckCK" datasource="#pds#">
				SELECT * 
				FROM PayByCk 
				WHERE AccountID = #AccountID# 
				AND AccntPlanID = #B5# 
			</cfquery>
			<cfquery name="CheckCC" datasource="#pds#">
				SELECT * 
				FROM PayByCC 
				WHERE AccountID = #AccountID# 
				AND AccntPlanID = #B5# 
			</cfquery>
			<cfif (CheckCD.Recordcount GT 0) OR (CheckCK.Recordcount GT 0) OR (CheckCC.Recordcount GT 0)>
				<cfquery name="DelData" datasource="#pds#">
					DELETE FROM PayByPO 
					WHERE AccountID = #AccountID# 
					AND AccntPlanID = #B5# 
				</cfquery>
				<cfquery name="CheckPayType" datasource="#pds#">
					SELECT PayBy 
					FROM AccntPlans 
					WHERE AccntPlanID = #B5# 
				</cfquery>
				<cfif CheckPayType.PayBy Is "po">
					<cfif CheckCD.Recordcount GT 1>
						<cfquery name="UpdData" datasource="#pds#">
							UPDATE AccntPlans SET 
							PayBy = 'cd' 
							WHERE AccntPlanID = #B5#
						</cfquery>
					</cfif>
					<cfif CheckCC.Recordcount GT 0>
						<cfquery name="UpdData" datasource="#pds#">
							UPDATE AccntPlans SET 
							PayBy = 'cc' 
							WHERE AccntPlanID = #B5#
						</cfquery>
					</cfif>
					<cfif CheckCK.Recordcount GT 0>
						<cfquery name="UpdData" datasource="#pds#">
							UPDATE AccntPlans SET 
							PayBy = 'ck' 
							WHERE AccntPlanID = #B5#
						</cfquery>
					</cfif>
				</cfif>
			<cfelse>
				<cfquery name="SetPayBy" datasource="#pds#">
					UPDATE AccntPlans SET 
					PayBy = 'po' 
					WHERE AccntPlanID = #B5#
				</cfquery>
			</cfif>
		</cfif>
	</cfloop>
</cfif>
<cfif IsDefined("AddCK.x")>
	<cfquery name="GetFields" datasource="#pds#">
		SELECT FieldName, DataType 
		FROM PayTypes 
		WHERE UseTab = 4 
		AND ActiveYN = 1 
	</cfquery>
	<cfloop index="B5" list="#AccntPlanID#">
		<cfquery name="AddData#B5#" datasource="#pds#">
			Insert Into PayByCK 
			(<cfloop query="GetFields">#FieldName#,</cfloop>AccntPlanID,AccountID,ActiveYN)
			VALUES 
			(<cfloop query="GetFields">
				<cfset InsStr = Evaluate("#FieldName##B5#")>
					<cfif Trim(InsStr) Is "">Null
					<cfelse>
						<cfif DataType Is "Text">'#InsStr#'
						<cfelseif DataType Is "Number">#InsStr#
						<cfelseif DataType Is "Date">#CreateODBCDateTime(InsStr)#
						</cfif>
				 	</cfif>,
			 </cfloop>#B5#,#AccountID#,#Evaluate("ActiveYN#B5#")#)
		</cfquery>
	</cfloop>
</cfif>
<cfif IsDefined("AddCD.x")>
	<cfquery name="GetFields" datasource="#pds#">
		SELECT FieldName, DataType 
		FROM PayTypes 
		WHERE UseTab = 1 
		AND ActiveYN = 1 
	</cfquery>
	<cfloop index="B5" list="#AccntPlanID#">
		<cfquery name="AddData#B5#" datasource="#pds#">
			Insert Into PayByCD 
			(<cfloop query="GetFields">#FieldName#,</cfloop>AccntPlanID,AccountID,ActiveYN)
			VALUES 
			(<cfloop query="GetFields">
				<cfset InsStr = Evaluate("#FieldName##B5#")>
					<cfif Trim(InsStr) Is "">Null
					<cfelse>
						<cfif DataType Is "Text">'#InsStr#'
						<cfelseif DataType Is "Number">#InsStr#
						<cfelseif DataType Is "Date">#CreateODBCDateTime(InsStr)#
						</cfif>
				 	</cfif>,
			 </cfloop>#B5#,#AccountID#,#Evaluate("ActiveYN#B5#")#)
		</cfquery>
	</cfloop>
</cfif>
<cfif IsDefined("AddCC.x")>
	<cfquery name="GetFields" datasource="#pds#">
		SELECT FieldName, DataType 
		FROM PayTypes 
		WHERE UseTab = 2 
		AND ActiveYN = 1 
	</cfquery>
	<cfloop index="B5" list="#AccntPlanID#">
		<cfquery name="AddData#B5#" datasource="#pds#">
			Insert Into PayByCC 
			(<cfloop query="GetFields">#FieldName#,</cfloop>AccntPlanID,AccountID,ActiveYN)
			VALUES 
			(<cfloop query="GetFields">
				<cfset InsStr = Evaluate("#FieldName##B5#")>
					<cfif Trim(InsStr) Is "">Null
					<cfelse>
						<cfif DataType Is "Text">'#InsStr#'
						<cfelseif DataType Is "Number">#InsStr#
						<cfelseif DataType Is "Date">#CreateODBCDateTime(InsStr)#
						</cfif>
				 	</cfif>,
			 </cfloop>#B5#,#AccountID#,#Evaluate("ActiveYN#B5#")#)
		</cfquery>
	</cfloop>
</cfif>
<cfif IsDefined("AddPO.x")>
	<cfquery name="GetFields" datasource="#pds#">
		SELECT FieldName, DataType 
		FROM PayTypes 
		WHERE UseTab = 3 
		AND ActiveYN = 1 
	</cfquery>
	<cfloop index="B5" list="#AccntPlanID#">
		<cfquery name="AddData#B5#" datasource="#pds#">
			Insert Into PayByPO 
			(<cfloop query="GetFields">#FieldName#,</cfloop>AccntPlanID,AccountID,ActiveYN)
			VALUES 
			(<cfloop query="GetFields">
				<cfset InsStr = Evaluate("#FieldName##B5#")>
					<cfif Trim(InsStr) Is "">Null
					<cfelse>
						<cfif DataType Is "Text">'#InsStr#'
						<cfelseif DataType Is "Number">#InsStr#
						<cfelseif DataType Is "Date">#CreateODBCDateTime(InsStr)#
						</cfif>
				 	</cfif>,
			 </cfloop>#B5#,#AccountID#,#Evaluate("ActiveYN#B5#")#)
		</cfquery>
	</cfloop>
</cfif>
<cfif IsDefined("UpdCd.x")>
	<cfquery name="UpdData" datasource="#pds#">
		SELECT AccntPlanID 
		FROM PayByCD 
		WHERE AccountID = #AccountID# 
	</cfquery>
	<cfquery name="GetFields" datasource="#pds#">
		SELECT FieldName, DataType 
		FROM PayTypes 
		WHERE UseTab = 1 
		AND ActiveYN = 1 
	</cfquery>
	<cfloop index="B5" list="#ValueList(UpdData.AccntPlanID)#">
		<cfquery name="UpdCKData" datasource="#pds#">
			UPDATE PayBYCD SET 
			<cfloop query="GetFields">
				<cfif IsDefined("#FieldName##B5#")>
					<cfset FieldValue = Evaluate("#FieldName##B5#")>
				<cfelse>
					<cfset FieldValue = "">
				</cfif>
				<cfif (FieldName Is "AccntNumber") OR (FieldName Is "RouteNumber")>
					<cfset FieldValue = ReplaceList(FieldValue,"-, ",",")>
				</cfif>
				#FieldName# = 
				<cfif FieldValue Is "">Null
				<cfelse>
					<cfif DataType Is "Text">'#FieldValue#'
					<cfelseif DataType Is "Number">#FieldValue#
					<cfelseif DataType Is "Date">#CreateODBCDateTime(FieldValue)#
					</cfif>
				</cfif>, 
			</cfloop>
			ActiveYN = #Evaluate("ActiveYN#B5#")# 
			WHERE AccountID = #AccountID# 
			AND AccntPlanID = #B5# 
		</cfquery>
	</cfloop>
</cfif>
<cfif IsDefined("UpdPO.x")>
	<cfquery name="UpdData" datasource="#pds#">
		SELECT AccntPlanID 
		FROM PayByPO 
		WHERE AccountID = #AccountID# 
	</cfquery>
	<cfquery name="GetFields" datasource="#pds#">
		SELECT FieldName, DataType 
		FROM PayTypes 
		WHERE UseTab = 3 
		AND ActiveYN = 1 
	</cfquery>
	<cfloop index="B5" list="#ValueList(UpdData.AccntPlanID)#">
		<cfquery name="UpdCKData" datasource="#pds#">
			UPDATE PayBYPO SET 
			<cfloop query="GetFields">
				<cfif IsDefined("#FieldName##B5#")>
					<cfset FieldValue = Evaluate("#FieldName##B5#")>
				<cfelse>
					<cfset FieldValue = "">
				</cfif>
				<cfif (FieldName Is "AccntNumber") OR (FieldName Is "RouteNumber")>
					<cfset FieldValue = ReplaceList(FieldValue,"-, ",",")>
				</cfif>
				#FieldName# = 
					<cfif FieldValue Is "">Null
					<cfelse>
						<cfif DataType Is "Text">'#FieldValue#'
						<cfelseif DataType Is "Number">#FieldValue#
						<cfelseif DataType Is "Date">#CreateODBCDateTime(FieldValue)#
						</cfif>
					</cfif>, 
			</cfloop>
			ActiveYN = #Evaluate("ActiveYN#B5#")# 
			WHERE AccountID = #AccountID# 
			AND AccntPlanID = #B5# 
		</cfquery>
	</cfloop>
</cfif>
<cfif IsDefined("UpdCk.x")>
	<cfquery name="UpdData" datasource="#pds#">
		SELECT AccntPlanID 
		FROM PayByCK 
		WHERE AccountID = #AccountID# 
	</cfquery>
	<cfquery name="GetFields" datasource="#pds#">
		SELECT FieldName, DataType 
		FROM PayTypes 
		WHERE UseTab = 4 
		AND ActiveYN = 1 
	</cfquery>
	<cfloop index="B5" list="#ValueList(UpdData.AccntPlanID)#">
		<cfquery name="UpdCKData" datasource="#pds#">
			UPDATE PayBYCK SET 
			<cfloop query="GetFields">
				<cfif IsDefined("#FieldName##B5#")>
					<cfset FieldValue = Evaluate("#FieldName##B5#")>
				<cfelse>
					<cfset FieldValue = "">
				</cfif>
				<cfif (FieldName Is "AccntNumber") OR (FieldName Is "RouteNumber")>
					<cfset FieldValue = ReplaceList(FieldValue,"-, ",",")>
				</cfif>
				#FieldName# = 
					<cfif FieldValue Is "">Null
					<cfelse>
						<cfif DataType Is "Text">'#FieldValue#'
						<cfelseif DataType Is "Number">#FieldValue#
						<cfelseif DataType Is "Date">#CreateODBCDateTime(FieldValue)#
						</cfif>
					</cfif>, 
			</cfloop>
			ActiveYN = #Evaluate("ActiveYN#B5#")# 
			WHERE AccountID = #AccountID# 
			AND AccntPlanID = #B5# 
		</cfquery>
	</cfloop>
</cfif>
<cfif IsDefined("UpdCC.x")>
	<cfquery name="UpdData" datasource="#pds#">
		SELECT AccntPlanID 
		FROM PayByCC 
		WHERE AccountID = #AccountID# 
	</cfquery>
	<cfquery name="GetFields" datasource="#pds#">
		SELECT FieldName, DataType 
		FROM PayTypes 
		WHERE UseTab = 2 
		AND ActiveYN = 1 
	</cfquery>
	<cfloop index="B5" list="#ValueList(UpdData.AccntPlanID)#">
		<cfquery name="UpdCCData" datasource="#pds#">
			UPDATE PayBYCC SET 
			<cfloop query="GetFields">
				<cfif IsDefined("#FieldName##B5#")>
					<cfset FieldValue = Evaluate("#FieldName##B5#")>
				<cfelse>
					<cfset FieldValue = "">
				</cfif>
				<cfif FieldName Is "CCNumber">
					<cfset FieldValue = ReplaceList(FieldValue,"-, ",",")>
				</cfif>
				#FieldName# = 
					<cfif FieldValue Is "">Null
					<cfelse>
						<cfif DataType Is "Text">'#FieldValue#'
						<cfelseif DataType Is "Number">#FieldValue#
						<cfelseif DataType Is "Date">#CreateODBCDateTime(FieldValue)#
						</cfif>
					</cfif>, 
			</cfloop>
			ActiveYN = #Evaluate("ActiveYN#B5#")# 
			WHERE AccountID = #AccountID# 
			AND AccntPlanID = #B5# 
		</cfquery>
	</cfloop>
</cfif>
<cfif IsDefined("uptab1.x")>
	<cfquery name="UpdData" datasource="#pds#">
		SELECT AccntPlanID 
		FROM AccntPlans 
		WHERE AccountID = #AccountID#
	</cfquery>
	<cfloop query="UpdData">
		<cfset var1 = Evaluate("PostalRem#AccntPlanID#")>
		<cfset var2 = Evaluate("Taxable#AccntPlanID#")>
		<cfset var3 = Evaluate("PayBy#AccntPlanID#")>
		<cfquery name="UpdatePayInfo" datasource="#pds#">
			UPDATE AccntPlans SET 
			PostalRem = #var1#, 
			Taxable = #var2# 
			WHERE AccntPlanID = #AccntPlanID# 
		</cfquery>
		<cfif var3 Is "cc">
			<cfquery name="CheckFirst" datasource="#pds#">
				SELECT * 
				FROM PayByCC 
				WHERE AccntPlanID = #AccntPlanID# 
			</cfquery>
			<cfif CheckFirst.Recordcount GT 0>
				<cfquery name="UpdatePayInfo" datasource="#pds#">
					UPDATE AccntPlans SET 
					PayBy = '#var3#' 
					WHERE AccntPlanID = #AccntPlanID# 
				</cfquery>
			</cfif>
		<cfelseif var3 Is "ck">
			<cfquery name="CheckFirst" datasource="#pds#">
				SELECT * 
				FROM PayByCK 
				WHERE AccntPlanID = #AccntPlanID# 
			</cfquery>
			<cfif CheckFirst.Recordcount GT 0>
				<cfquery name="UpdatePayInfo" datasource="#pds#">
					UPDATE AccntPlans SET 
					PayBy = '#var3#' 
					WHERE AccntPlanID = #AccntPlanID# 
				</cfquery>
			</cfif>
		<cfelseif var3 Is "cd">
			<cfquery name="CheckFirst" datasource="#pds#">
				SELECT * 
				FROM PayByCD 
				WHERE AccntPlanID = #AccntPlanID# 
			</cfquery>
			<cfif CheckFirst.Recordcount GT 0>
				<cfquery name="UpdatePayInfo" datasource="#pds#">
					UPDATE AccntPlans SET 
					PayBy = '#var3#' 
					WHERE AccntPlanID = #AccntPlanID# 
				</cfquery>
			</cfif>
		<cfelseif var3 Is "po">
			<cfquery name="CheckFirst" datasource="#pds#">
				SELECT * 
				FROM PayByPO 
				WHERE AccntPlanID = #AccntPlanID# 
			</cfquery>
			<cfif CheckFirst.Recordcount GT 0>
				<cfquery name="UpdatePayInfo" datasource="#pds#">
					UPDATE AccntPlans SET 
					PayBy = '#var3#' 
					WHERE AccntPlanID = #AccntPlanID# 
				</cfquery>
			</cfif>
		</cfif>
	</cfloop>
</cfif>

<cfparam name="tab" default="1">
<cfquery name="GetUser" datasource="#pds#">
	SELECT C.FirstName, C.LastName 
	FROM Accounts C 
	WHERE AccountID = #AccountID# 
</cfquery>
<cfquery name="GetPayTypes" datasource="#pds#">
	SELECT A.AccntPlanID, A.PayBy, A.PostalRem, A.Taxable, 
	P.PlanDesc, P.AWPayCK, P.AWPayCD, P.AWPayCC, P.OSPayCK, 
	P.OSPayCD, P.OSPayCC, P.AWPayPO, P.OSPayPO 
	FROM AccntPlans A, Plans P 
	WHERE A.PlanID = P.PlanID 
	AND AccountID = #AccountID# 
</cfquery>
<cfset TabPayByCk = 0>
<cfset TabPayByCd = 0>
<cfset TabPayByCc = 0>
<cfset TabPayByPo = 0>
<cfset PayBys = "">
<cfloop query="GetPayTypes">
	<cfset TabPayByCk = TabPayByCk + AWPayCK + OSPayCK>
	<cfset TabPayByCd = TabPayByCd + AWPayCD + OSPayCD>
	<cfset TabPayByCc = TabPayByCc + AWPayCC + OSPayCC>
	<cfset TabPayByPo = TabPayByPo + AWPayPO + OSPayPO>
	<cfset PayBys = ListAppend(PayBys,PayBy)>
</cfloop>
<cfif tab Is "1">
	<cfset SelectPayTab = 0>
<cfelseif tab Is "2">
	<cfset SelectPayTab = 4>
	<cfquery name="GetCkPayInfo" datasource="#pds#">
		SELECT C.*, P.PlanDesc 
		FROM PayByCk C, AccntPlans A, Plans P 
		WHERE C.AccntPlanID = A.AccntPlanID 
		AND A.PlanID = P.PlanID 
		AND C.AccountID = #AccountID# 
		ORDER BY P.PlanDesc 
	</cfquery>
	<cfquery name="PlansLeft" datasource="#pds#">
		SELECT P.PlanDesc, A.AccntPlanID 
		FROM Plans P, AccntPlans A 
		WHERE A.PlanID = P.PlanID 
		AND A.AccountID = #AccountID# 
		AND A.AccntPlanID Not In 
			(SELECT C.AccntPlanID 
			 FROM PayByCk C, AccntPlans A, Plans P 
			 WHERE C.AccntPlanID = A.AccntPlanID 
			 AND A.PlanID = P.PlanID 
			 AND C.AccountID = #AccountID# )
		ORDER BY P.PlanDesc 
	</cfquery>
<cfelseif tab Is "3">
	<cfset SelectPayTab = 1>
	<cfquery name="GetCdPayInfo" datasource="#pds#">
		SELECT C.*, P.PlanDesc 
		FROM PayByCd C, AccntPlans A, Plans P 
		WHERE C.AccntPlanID = A.AccntPlanID 
		AND A.PlanID = P.PlanID 
		AND C.AccountID = #AccountID# 
		ORDER BY P.PlanDesc 
	</cfquery>
	<cfquery name="PlansLeft" datasource="#pds#">
		SELECT P.PlanDesc, A.AccntPlanID 
		FROM Plans P, AccntPlans A 
		WHERE A.PlanID = P.PlanID 
		AND A.AccountID = #AccountID# 
		AND A.AccntPlanID Not In 
			(SELECT C.AccntPlanID 
			 FROM PayByCD C, AccntPlans A, Plans P 
			 WHERE C.AccntPlanID = A.AccntPlanID 
			 AND A.PlanID = P.PlanID 
			 AND C.AccountID = #AccountID# )
		ORDER BY P.PlanDesc 
	</cfquery>
<cfelseif tab Is "4">
	<cfset SelectPayTab = 2>
	<cfquery name="GetCcPayInfo" datasource="#pds#">
		SELECT C.*, P.PlanDesc 
		FROM PayByCc C, AccntPlans A, Plans P 
		WHERE C.AccntPlanID = A.AccntPlanID 
		AND A.PlanID = P.PlanID 
		AND C.AccountID = #AccountID# 
		ORDER BY P.PlanDesc 
	</cfquery>
	<cfquery name="PlansLeft" datasource="#pds#">
		SELECT P.PlanDesc, A.AccntPlanID 
		FROM Plans P, AccntPlans A 
		WHERE A.PlanID = P.PlanID 
		AND A.AccountID = #AccountID# 
		AND A.AccntPlanID Not In 
			(SELECT C.AccntPlanID 
			 FROM PayByCc C, AccntPlans A, Plans P 
			 WHERE C.AccntPlanID = A.AccntPlanID 
			 AND A.PlanID = P.PlanID 
			 AND C.AccountID = #AccountID# )
		ORDER BY P.PlanDesc 
	</cfquery>
	<cfquery name="CCTypes" datasource="#pds#">
		SELECT CardType 
		FROM CreditCardTypes 
		WHERE ActiveYN = 1 
		ORDER BY SortOrder, CardType 
	</cfquery>
	<cfparam name="AddYear" default="6">
	<cfset SYear = Year(Now())>
	<cfset EYear = SYear + AddYear>
<cfelseif tab Is "5">
	<cfset SelectPayTab = 3>
	<cfquery name="GetPoPayInfo" datasource="#pds#">
		SELECT C.*, P.PlanDesc 
		FROM PayByPO C, AccntPlans A, Plans P 
		WHERE C.AccntPlanID = A.AccntPlanID 
		AND A.PlanID = P.PlanID 
		AND C.AccountID = #AccountID# 
		ORDER BY P.PlanDesc 	
	</cfquery>
	<cfquery name="PlansLeft" datasource="#pds#">
		SELECT P.PlanDesc, A.AccntPlanID 
		FROM Plans P, AccntPlans A 
		WHERE A.PlanID = P.PlanID 
		AND A.AccountID = #AccountID# 
		AND A.AccntPlanID Not In 
			(SELECT C.AccntPlanID 
			 FROM PayByPO C, AccntPlans A, Plans P 
			 WHERE C.AccntPlanID = A.AccntPlanID 
			 AND A.PlanID = P.PlanID 
			 AND C.AccountID = #AccountID# )
		ORDER BY P.PlanDesc 
	</cfquery>
</cfif>
<cfquery name="GetPayInfo" datasource="#pds#">
	SELECT * 
	FROM PayTypes 
	WHERE ActiveYN = 1 
	AND UseTab = #SelectPayTab# 
	ORDER BY SortOrder
</cfquery>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<title>Payment Information</TITLE>
<cfinclude template="coolsheet.cfm">
<script language="javascript">
<!-- 
function SetValues(carry1,carry2)
	{
	 var var1 = document.EditInfo.LoopCount.value
	 var var9 = 0
	 if (var1 == 1)
	 	{
		 var var2 = document.EditInfo.DelSelected.checked
		 var var3 = document.EditInfo.DelSelected.value
		 if (var2 == 1)
		 	{
			 var var9 = var9 + ',' + var3
			}
		 document.PickDelete.DelThese.value = var9
		 return
		}
	 for (count = 0; count < var1; count++)
	 	{
		 var var2 = document.EditInfo.DelSelected[count].checked
		 var var3 = document.EditInfo.DelSelected[count].value
		 if (var2 == 1)
		 	{
			 var var9 = var9 + ',' + var3
			}		 
		}
	 document.PickDelete.DelThese.value = var9
	}
// -->
</script>
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<cfoutput>
	<form method="post" action="custinf1.cfm">
		<input type="hidden" name="accountid" value="#AccountID#">
		<input type="image" name="return" src="images/returncust.gif" border="0">
	</form>
<center>
	<table border="#tblwidth#">
		<tr>
			<th colspan="2" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#ttface#"</cfif> color="#ttfont#">Payment Information for #GetUser.FirstName# #GetUser.LastName#</font></th>
		</tr>
		<tr>
			<th colspan="2">
				<table border="1">
					<tr bgcolor="#tdclr#">	
						<form method="post" action="editcard.cfm">
							<input type="hidden" name="accountid" value="#AccountID#">
							<td <cfif tab Is "1">bgcolor="#tbclr#"</cfif> ><input type="radio" name="tab" <cfif tab Is "1">checked</cfif> value="1" onclick="submit()" id="tab1"><label for="tab1">Misc</label></td>
							<cfif (TabPayByCk GT 0) OR (GetOpts.SUserYN Is 1) Or (ListFind(PayBys,'ck'))>
								<td <cfif tab Is "2">bgcolor="#tbclr#"</cfif> ><input type="radio" name="tab" <cfif tab Is "2">checked</cfif> value="2" onclick="submit()" id="tab2"><label for="tab2">Check</label></td>
							</cfif>
							<cfif (TabPayByCd GT 0) OR (GetOpts.SUserYN Is 1) Or (ListFind(PayBys,'cd'))>
								<td <cfif tab Is "3">bgcolor="#tbclr#"</cfif> ><input type="radio" name="tab" <cfif tab Is "3">checked</cfif> value="3" onclick="submit()" id="tab3"><label for="tab3">Check Debit</label></td>
							</cfif>
							<cfif (TabPayByCc GT 0) OR (GetOpts.SUserYN Is 1) Or (ListFind(PayBys,'cc'))>
								<td <cfif tab Is "4">bgcolor="#tbclr#"</cfif> ><input type="radio" name="tab" <cfif tab Is "4">checked</cfif> value="4" onclick="submit()" id="tab4"><label for="tab4">Credit Card</label></td>
							</cfif>
							<cfif (TabPayByPo GT 0) OR (GetOpts.SUserYN Is 1) Or (ListFind(PayBys,'po'))>
								<td <cfif tab Is "5">bgcolor="#tbclr#"</cfif> ><input type="radio" name="tab" <cfif tab Is "5">checked</cfif> value="5" onclick="submit()" id="tab5"><label for="tab5">Purchase Order</label></td>
							</cfif>
						</form>
					</tr>
				</table>
			</th>
		</tr>
</cfoutput>
<cfif tab Is "1">
	<cfoutput>
		<form name="check" action="editcard.cfm">
			<input type="hidden" name="AccountID" Value="#AccountID#">
			<input type="hidden" name="tab" value="#tab#">
	</cfoutput>
			<cfloop query="GetPayTypes">
				<cfoutput>
					<tr bgcolor="#thclr#">
						<th colspan="2">#PlanDesc#</th>
					</tr>
					<tr bgcolor="#tdclr#">
						<td align="right" bgcolor="#tbclr#">Postal Reminder</td>
						<td><input type="radio" name="PostalRem#AccntPlanID#" <cfif PostalRem Is "1">checked</cfif> value="1"> Yes <input type="radio" name="PostalRem#AccntPlanID#" <cfif PostalRem Is "0">checked</cfif> value="0"> No</td>
					</tr>
			   	 <tr bgcolor="#tdclr#">
				   	 <td align="right" bgcolor="#tbclr#">Taxable</td>
	      	       <td><input type="radio" name="Taxable#AccntPlanID#" <cfif Taxable Is "1">checked</cfif> value="1"> Yes <input type="radio" name="Taxable#AccntPlanID#" <cfif Taxable Is "0">checked</cfif> value="0"> No</td>
			   	 </tr>
					 <tr bgcolor="#tdclr#">
					 	<td align="right" bgcolor="#tbclr#">Payment Method</td>
						<cfset PayByCk = Max(AWPayCK,OSPayCK)>
						<cfset PayByCd = Max(AWPayCD,OSPayCD)>
						<cfset PayByCc = Max(AWPayCC,OSPayCC)>
						<cfset PayByPo = Max(AWPayPO,OSPayPO)>
						<td><select name="PayBy#AccntPlanID#">
							<cfif (PayByCk Is "1") OR (PayBy Is "ck") Or (GetOpts.SUserYN Is "1")>
								<option <cfif PayBy Is "ck">selected</cfif> value="ck">Check / Cash
							</cfif>
							<cfif (PayByCd Is "1") OR (PayBy Is "cd") Or (GetOpts.SUserYN Is "1")>
								<option <cfif PayBy Is "cd">selected</cfif> value="cd">Check Debit
							</cfif>
							<cfif (PayByCc Is "1") OR (PayBy Is "cc") Or (GetOpts.SUserYN Is "1")>
								<option <cfif PayBy Is "cc">selected</cfif> value="cc">Credit Card
							</cfif>
							<cfif (PayByPo Is "1") OR (PayBy Is "po") Or (GetOpts.SUserYN Is "1")>
								<option <cfif PayBy Is "po">selected</cfif> value="po">Purchase Order
							</cfif>
						</select></td>
					 </tr>
				</cfoutput>				
			</cfloop>
			<tr>
	   		 <th colspan="2"><INPUT type="image" name="uptab1" src="images/update.gif" border="0"></th>
			</tr>
		</form>
<cfelseif tab Is "2">
	<cfif GetCkPayInfo.Recordcount GT 0>
		<form method="post" name="EditInfo" action="editcard.cfm">
			<cfoutput>
				<input type="hidden" name="accountid" value="#AccountID#">
				<input type="hidden" name="tab" value="#tab#">
			</cfoutput>
			<cfloop query="GetCkPayInfo">
				<cfloop index="B3" list="#GetCkPayInfo.ColumnList#">
					<cfset "#B3#" = Evaluate("#B3#")>
				</cfloop>
				<cfoutput>
					<tr>
						<th colspan="2" bgcolor="#thclr#">#PlanDesc#</th>
					</tr>
					<tr>
						<td bgcolor="#tdclr#" align="right" colspan="2">Clear <input type="checkbox" name="DelSelected" value="#AccntPlanID#" onClick="SetValues(#AccntPlanID#,this)"></td>
					</tr>
					<tr>
						<td align="right" bgcolor="#tbclr#">Active</td>
						<td bgcolor="#tdclr#"><input type="radio" <cfif ActiveYN Is 1>checked</cfif> name="ActiveYN#AccntPlanID#" value="1"> Yes <input type="radio" <cfif ActiveYN Is 0>checked</cfif> name="ActiveYN#AccntPlanID#" value="0"> No</td>
					</tr>
				</cfoutput>					
				<cfoutput query="GetPayInfo">
					<tr>
						<td align="right" bgcolor="#tbclr#">#PromptStr#</td>
						<cfset DispStr = Evaluate("#Fieldname#")>
						<td bgcolor="#tdclr#"><input type="text" <cfif InputMaxSize Is Not "">maxlength="#InputMaxSize#"</cfif> name="#Fieldname##AccntPlanID#" value="#DispStr#"></td>
					</tr>
					<cfif RequiredYN Is 1>
						<input type="hidden" name="#FieldName##AccntPlanID#_Required" value="Please enter the information for #PromptStr#">
					</cfif>
				</cfoutput>
			</cfloop>
			<tr>
				<th colspan="2">
					<table border="0">
						<tr>
							<cfoutput>
								<input type="hidden" name="LoopCount" value="#GetCkPayInfo.Recordcount#">
							</cfoutput>
							<td><input type="image" src="images/update.gif" name="UpdCK" border="0"></td>
		</form>
		<form method="post" name="PickDelete" action="editcard.cfm" onsubmit="return confirm ('Click Ok to confirm deleting the selected payment info.')">
							<input type="hidden" name="DelThese" value="0">
							<cfoutput>
							<input type="hidden" name="accountid" value="#AccountID#">
							<input type="hidden" name="tab" value="#tab#">
							</cfoutput>
							<td><input type="image" src="images/clearck.gif" name="ClearCK" border="0"></td>
		</form>
						</tr>
					</table>
				</th>
			</tr>
	</cfif>
	<cfif PlansLeft.Recordcount GT 0>
		<cfloop query="PlansLeft">
			<form method="post" action="editcard.cfm">
				<cfoutput>
					<input type="hidden" name="accountid" value="#AccountID#">
					<input type="hidden" name="tab" value="#tab#">
				</cfoutput>
				<cfset AccntPlanID = AccntPlanID>
				<tr>
					<cfoutput>
						<th colspan="2" bgcolor="#thclr#">#PlanDesc#</th>
						<input type="hidden" name="AccntPlanID" value="#AccntPlanID#">
					</cfoutput>
				</tr>
				<tr>
				<cfoutput>
					<td align="right" bgcolor="#tbclr#">Active</td>
					<td bgcolor="#tdclr#"><input type="radio" name="ActiveYN#AccntPlanID#" value="1"> Yes <input type="radio" checked name="ActiveYN#AccntPlanID#" value="0"> No</td>
				</cfoutput>
				</tr>
				<cfloop query="GetPayInfo">
					<tr>
						<cfoutput>
							<td align="right" bgcolor="#tbclr#">#PromptStr#</td>
							<td bgcolor="#tdclr#"><input type="text" name="#Fieldname##AccntPlanID#" value=""></td>
							<cfif RequiredYN Is 1>
								<input type="hidden" name="#Fieldname##AccntPlanID#_Required" value="Please enter the information for #PromptStr#">
							</cfif>
						</cfoutput>
					</tr>
				</cfloop>
				<tr>
					<th colspan="2"><input type="image" src="images/enter.gif" name="AddCk" border="0"></th>
				</tr>
			</form>
		</cfloop>
	</cfif>
<cfelseif tab Is "3">
	<cfif GetCDPayInfo.Recordcount GT 0>
		<form method="post" name="EditInfo" action="editcard.cfm">
			<cfoutput>
				<input type="hidden" name="accountid" value="#AccountID#">
				<input type="hidden" name="tab" value="#tab#">
			</cfoutput>
			<cfloop query="GetCdPayInfo">
				<cfloop index="B3" list="#GetCdPayInfo.ColumnList#">
					<cfset "#B3#" = Evaluate("#B3#")>
				</cfloop>
				<cfoutput>
					<tr>
						<th colspan="2" bgcolor="#thclr#">#PlanDesc#</th>
					</tr>
					<tr>
						<td bgcolor="#tdclr#" align="right" colspan="2">Clear <input type="checkbox" name="DelSelected" value="#AccntPlanID#" onClick="SetValues(#AccntPlanID#,this)"></td>
					</tr>
					<tr>
						<td align="right" bgcolor="#tbclr#">Active</td>
						<td bgcolor="#tdclr#"><input type="radio" <cfif ActiveYN Is 1>checked</cfif> name="ActiveYN#AccntPlanID#" value="1"> Yes <input type="radio" <cfif ActiveYN Is 0>checked</cfif> name="ActiveYN#AccntPlanID#" value="0"> No</td>
					</tr>
				</cfoutput>					
				<cfoutput query="GetPayInfo">
					<tr>
						<td align="right" bgcolor="#tbclr#">#PromptStr#</td>
						<cfset DispStr = Evaluate("#Fieldname#")>
						<td bgcolor="#tdclr#"><input type="text" <cfif InputMaxSize Is Not "">maxlength="#InputMaxSize#"</cfif> name="#Fieldname##AccntPlanID#" value="#DispStr#"></td>
					</tr>
					<cfif RequiredYN Is 1>
						<input type="hidden" name="#FieldName##AccntPlanID#_Required" value="Please enter the information for #PromptStr#">
					</cfif>
				</cfoutput>
			</cfloop>
			<tr>
				<th colspan="2">
					<table border="0">
						<tr>
							<cfoutput>
								<input type="hidden" name="LoopCount" value="#GetCDPayInfo.Recordcount#">
							</cfoutput>
							<td><input type="image" src="images/update.gif" name="UpdCD" border="0"></td>
		</form>
		<form method="post" name="PickDelete" action="editcard.cfm" onsubmit="return confirm ('Click Ok to confirm deleting the selected payment info.')">
							<input type="hidden" name="DelThese" value="0">
							<cfoutput>
							<input type="hidden" name="accountid" value="#AccountID#">
							<input type="hidden" name="tab" value="#tab#">
							</cfoutput>
							<td><input type="image" src="images/clearcd.gif" name="ClearCD" border="0"></td>
		</form>
						</tr>
					</table>
				</th>
			</tr>
	</cfif>
	<cfif PlansLeft.Recordcount GT 0>
		<cfloop query="PlansLeft">
			<form method="post" action="editcard.cfm">
				<cfoutput>
					<input type="hidden" name="accountid" value="#AccountID#">
					<input type="hidden" name="tab" value="#tab#">
				</cfoutput>
				<cfset AccntPlanID = AccntPlanID>
				<tr>
					<cfoutput>
						<th colspan="2" bgcolor="#thclr#">#PlanDesc#</th>
						<input type="hidden" name="AccntPlanID" value="#AccntPlanID#">
					</cfoutput>
				</tr>
				<tr>
				<cfoutput>
					<td align="right" bgcolor="#tbclr#">Active</td>
					<td bgcolor="#tdclr#"><input type="radio" name="ActiveYN#AccntPlanID#" value="1"> Yes <input type="radio" checked name="ActiveYN#AccntPlanID#" value="0"> No</td>
				</cfoutput>
				</tr>
				<cfloop query="GetPayInfo">
					<tr>
						<cfoutput>
							<td align="right" bgcolor="#tbclr#">#PromptStr#</td>
							<td bgcolor="#tdclr#"><input type="text" <cfif InputMaxSize Is Not "">maxlength="#InputMaxSize#"</cfif> name="#Fieldname##AccntPlanID#" value=""></td>
							<cfif RequiredYN Is 1>
								<input type="hidden" name="#Fieldname##AccntPlanID#_Required" value="Please enter the information for #PromptStr#">
							</cfif>
						</cfoutput>
					</tr>
				</cfloop>
				<tr>
					<th colspan="2"><input type="image" src="images/enter.gif" name="AddCD" border="0"></th>
				</tr>
			</form>
		</cfloop>
	</cfif>
<cfelseif tab Is "4">
	<cfif GetCCPayInfo.Recordcount GT 0>
		<form method="post" name="EditInfo" action="editcard.cfm">
			<cfoutput>
				<input type="hidden" name="accountid" value="#AccountID#">
				<input type="hidden" name="tab" value="#tab#">
			</cfoutput>
			<cfloop query="GetCcPayInfo">
				<cfloop index="B3" list="#GetCcPayInfo.ColumnList#">
					<cfset "#B3#" = Evaluate("#B3#")>
				</cfloop>
				<cfoutput>
					<tr>
						<th colspan="2" bgcolor="#thclr#">#PlanDesc#</th>
					</tr>
					<tr>
						<td bgcolor="#tdclr#" align="right" colspan="2">Clear <input type="checkbox" name="DelSelected" value="#AccntPlanID#" onClick="SetValues(#AccntPlanID#,this)"></td>
					</tr>
					<tr>
						<td align="right" bgcolor="#tbclr#">Active</td>
						<td bgcolor="#tdclr#"><input type="radio" <cfif ActiveYN Is 1>checked</cfif> name="ActiveYN#AccntPlanID#" value="1"> Yes <input type="radio" <cfif ActiveYN Is 0>checked</cfif> name="ActiveYN#AccntPlanID#" value="0"> No</td>
					</tr>
				</cfoutput>					
				<cfloop query="GetPayInfo">
					<tr>
						<cfoutput>
							<td align="right" bgcolor="#tbclr#">#PromptStr#</td>
						</cfoutput>
						<cfif IsDefined("#Fieldname#")>
							<cfset DispStr = Evaluate("#Fieldname#")>
						<cfelse>
							<cfset DispStr = "">
						</cfif>
						<cfif FieldName Is "CCYear">
							<cfoutput>
								<td bgcolor="#tdclr#"><select name="CCYear#AccntPlanID#">
							</cfoutput>
									<cfloop index="B4" from="#SYear#" to="#EYear#">
										<cfoutput><option <cfif B4 Is CCYear>selected</cfif> value="#B4#">#B4#</cfoutput>
									</cfloop>
								</select></td>
								<cfif RequiredYN Is 1>
									<cfoutput>
										<input type="hidden" name="CCYear#AccntPlanID#_Required" value="Please enter the information for #PromptStr#">
									</cfoutput>
								</cfif>
						<cfelseif FieldName is "CCMonth">
							<cfoutput>
								<td bgcolor="#tdclr#"><select name="CCMonth#AccntPlanID#">
							</cfoutput>
									<cfloop index="B4" from="1" to="12">
										<cfif B4 lt 10><cfset B4 = "0" & B4></cfif>
										<cfoutput><option <cfif B4 Is CCMonth>selected</cfif> value="#B4#">#MonthAsString(B4)#</cfoutput>
									</cfloop>
								</select></td>
								<cfif RequiredYN Is 1>
									<cfoutput>
										<input type="hidden" name="CCMonth#AccntPlanID#_Required" value="Please enter the information for #PromptStr#">
									</cfoutput>
								</cfif>
						<cfelseif FieldName Is "CCType">
							<cfoutput>
								<td bgcolor="#tdclr#"><select name="CCType#AccntPlanID#">
							</cfoutput>
									<option value="NA">None
									<cfloop query="CCTypes">
										<cfoutput><option <cfif CardType Is CCType>selected</cfif> value="#CardType#">#CardType#</cfoutput>
									</cfloop>
								</select></td>
								<cfif RequiredYN Is 1>
									<cfoutput>
										<input type="hidden" name="CCType#AccntPlanID#_Required" value="Please enter the information for #PromptStr#">
									</cfoutput>
								</cfif>
						<cfelse>
							<cfoutput>
								<td bgcolor="#tdclr#"><input type="text" <cfif InputMaxSize Is Not "">maxlength="#InputMaxSize#"</cfif> name="#Fieldname##AccntPlanID#" value="#DispStr#"></td>
							</cfoutput>
							<cfif RequiredYN Is 1>
								<cfoutput>
									<input type="hidden" name="#FieldName##AccntPlanID#_Required" value="Please enter the information for #PromptStr#">
								</cfoutput>
							</cfif>
						</cfif>
					</tr>
				</cfloop>
			</cfloop>
			<tr>
				<th colspan="2">
					<table border="0">
						<tr>
							<cfoutput>
								<input type="hidden" name="LoopCount" value="#GetCCPayInfo.Recordcount#">
							</cfoutput>
							<td><input type="image" src="images/update.gif" name="UpdCC" border="0"></td>
		</form>
		<form method="post" name="PickDelete" action="editcard.cfm" onsubmit="return confirm ('Click Ok to confirm deleting the selected payment info.')">
							<input type="hidden" name="DelThese" value="0">
							<cfoutput>
							<input type="hidden" name="accountid" value="#AccountID#">
							<input type="hidden" name="tab" value="#tab#">
							</cfoutput>
							<td><input type="image" src="images/clearcc.gif" name="ClearCC" border="0"></td>
		</form>
						</tr>
					</table>
				</th>
			</tr>
	</cfif>
	<cfif PlansLeft.Recordcount GT 0>
		<cfloop query="PlansLeft">
			<form method="post" action="editcard.cfm">
				<cfoutput>
					<input type="hidden" name="accountid" value="#AccountID#">
					<input type="hidden" name="tab" value="#tab#">
				</cfoutput>
				<cfset AccntPlanID = AccntPlanID>
				<tr>
					<cfoutput>
						<th colspan="2" bgcolor="#thclr#">#PlanDesc#</th>
						<input type="hidden" name="AccntPlanID" value="#AccntPlanID#">
					</cfoutput>
				</tr>
				<tr>
				<cfoutput>
					<td align="right" bgcolor="#tbclr#">Active</td>
					<td bgcolor="#tdclr#"><input type="radio" name="ActiveYN#AccntPlanID#" value="1"> Yes <input type="radio" checked name="ActiveYN#AccntPlanID#" value="0"> No</td>
				</cfoutput>
				</tr>
				<cfloop query="GetPayInfo">
					<tr>
						<cfoutput>
							<td align="right" bgcolor="#tbclr#">#PromptStr#</td>
						</cfoutput>
						<cfif FieldName Is "CCYear">
							<cfoutput>
								<td bgcolor="#tdclr#"><select name="CCYear#AccntPlanID#">
							</cfoutput>
									<cfloop index="B4" from="#SYear#" to="#EYear#">
										<cfoutput><option value="#B4#">#B4#</cfoutput>
									</cfloop>
								</select></td>
								<cfif RequiredYN Is 1>
									<cfoutput>
										<input type="hidden" name="CCYear#AccntPlanID#_Required" value="Please enter the information for #PromptStr#">
									</cfoutput>
								</cfif>
						<cfelseif FieldName is "CCMonth">
							<cfoutput>
								<td bgcolor="#tdclr#"><select name="CCMonth#AccntPlanID#">
							</cfoutput>
									<cfloop index="B4" from="1" to="12">
										<cfif B4 lt 10><cfset B4 = "0" & B4></cfif>
										<cfoutput><option value="#B4#">#MonthAsString(B4)#</cfoutput>
									</cfloop>
								</select></td>
								<cfif RequiredYN Is 1>
									<cfoutput>
										<input type="hidden" name="CCMonth#AccntPlanID#_Required" value="Please enter the information for #PromptStr#">
									</cfoutput>
								</cfif>
						<cfelseif FieldName Is "CCType">
							<cfoutput>
								<td bgcolor="#tdclr#"><select name="CCType#AccntPlanID#">
							</cfoutput>
									<option value="NA">None
									<cfloop query="CCTypes">
										<cfoutput><option value="#CardType#">#CardType#</cfoutput>
									</cfloop>
								</select></td>
								<cfif RequiredYN Is 1>
									<cfoutput>
										<input type="hidden" name="CCType#AccntPlanID#_Required" value="Please enter the information for #PromptStr#">
									</cfoutput>
								</cfif>
						<cfelse>
							<cfoutput>
								<td bgcolor="#tdclr#"><input type="text" name="#Fieldname##AccntPlanID#" value=""></td>
								<cfif RequiredYN Is 1>
									<input type="hidden" name="#Fieldname##AccntPlanID#_Required" value="Please enter the information for #PromptStr#">
								</cfif>
							</cfoutput>
						</cfif>
					</tr>
				</cfloop>
				<tr>
					<th colspan="2"><input type="image" src="images/enter.gif" name="AddCC" border="0"></th>
				</tr>
			</form>
		</cfloop>
	</cfif>
<cfelseif tab Is "5">
	<cfif GetPoPayInfo.Recordcount GT 0>
		<form method="post" name="EditInfo" action="editcard.cfm">
			<cfoutput>
				<input type="hidden" name="accountid" value="#AccountID#">
				<input type="hidden" name="tab" value="#tab#">
			</cfoutput>
			<cfloop query="GetPOPayInfo">
				<cfloop index="B3" list="#GetPOPayInfo.ColumnList#">
					<cfset "#B3#" = Evaluate("#B3#")>
				</cfloop>
				<cfoutput>
					<tr>
						<th colspan="2" bgcolor="#thclr#">#PlanDesc#</th>
					</tr>
					<tr>
						<td bgcolor="#tdclr#" align="right" colspan="2">Clear <input type="checkbox" name="DelSelected" value="#AccntPlanID#" onClick="SetValues(#AccntPlanID#,this)"></td>
					</tr>
					<tr>
						<td align="right" bgcolor="#tbclr#">Active</td>
						<td bgcolor="#tdclr#"><input type="radio" <cfif ActiveYN Is 1>checked</cfif> name="ActiveYN#AccntPlanID#" value="1"> Yes <input type="radio" <cfif ActiveYN Is 0>checked</cfif> name="ActiveYN#AccntPlanID#" value="0"> No</td>
					</tr>
				</cfoutput>					
				<cfloop query="GetPayInfo">
					<tr>
						<cfoutput>
							<td align="right" bgcolor="#tbclr#">#PromptStr#</td>
						</cfoutput>
						<cfif IsDefined("#Fieldname#")>
							<cfset DispStr = Evaluate("#Fieldname#")>
						<cfelse>
							<cfset DispStr = "">
						</cfif>
						<cfoutput>
							<td bgcolor="#tdclr#"><input type="text" name="#Fieldname##AccntPlanID#" value="#DispStr#"></td>
							<cfif RequiredYN Is 1>
								<input type="hidden" name="#Fieldname##AccntPlanID#_Required" value="Please enter the information for #PromptStr#">
							</cfif>
						</cfoutput>
					</tr>
				</cfloop>
			</cfloop>
			<tr>
				<th colspan="2">
					<table border="0">
						<tr>
							<cfoutput>
								<input type="hidden" name="LoopCount" value="#GetPoPayInfo.Recordcount#">
							</cfoutput>
							<td><input type="image" src="images/update.gif" name="UpdPO" border="0"></td>
		</form>
		<form method="post" name="PickDelete" action="editcard.cfm" onsubmit="return confirm ('Click Ok to confirm deleting the selected payment info.')">
							<input type="hidden" name="DelThese" value="0">
							<cfoutput>
							<input type="hidden" name="accountid" value="#AccountID#">
							<input type="hidden" name="tab" value="#tab#">
							</cfoutput>
							<td><input type="image" src="images/clearpo.gif" name="ClearPO" border="0"></td>
		</form>
						</tr>
					</table>
				</th>
			</tr>
	</cfif>
	<cfif PlansLeft.Recordcount GT 0>
		<cfloop query="PlansLeft">
			<form method="post" action="editcard.cfm">
				<cfoutput>
					<input type="hidden" name="accountid" value="#AccountID#">
					<input type="hidden" name="tab" value="#tab#">
				</cfoutput>
				<cfset AccntPlanID = AccntPlanID>
				<tr>
					<cfoutput>
						<th colspan="2" bgcolor="#thclr#">#PlanDesc#</th>
						<input type="hidden" name="AccntPlanID" value="#AccntPlanID#">
					</cfoutput>
				</tr>
				<tr>
				<cfoutput>
					<td align="right" bgcolor="#tbclr#">Active</td>
					<td bgcolor="#tdclr#"><input type="radio" name="ActiveYN#AccntPlanID#" value="1"> Yes <input type="radio" checked name="ActiveYN#AccntPlanID#" value="0"> No</td>
				</cfoutput>
				</tr>
				<cfloop query="GetPayInfo">
					<tr>
						<cfoutput>
							<td align="right" bgcolor="#tbclr#">#PromptStr#</td>
							<td bgcolor="#tdclr#"><input type="text" name="#Fieldname##AccntPlanID#" value=""></td>
							<cfif RequiredYN Is 1>
								<input type="hidden" name="#Fieldname##AccntPlanID#_Required" value="Please enter the information for #PromptStr#">
							</cfif>
						</cfoutput>
					</tr>
				</cfloop>
				<tr>
					<th colspan="2"><input type="image" src="images/enter.gif" name="AddPO" border="0"></th>
				</tr>
			</form>
		</cfloop>
	</cfif>
</cfif>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
  

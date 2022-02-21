<cfsetting enablecfoutputonly="yes">
<!--- Version 4.0.0 --->
<!--- 4.0.1 02/08/01 Fixed the Javascript error on selecting a date range.
		4.0.0 12/16/00 --->
<!--- reportpage.cfm --->
<!--- 
	Filters Selector Parameters: Set ShowFilters To 1

	Date Selector Parameters:  Set ShowDateRange To 1 
		StartDateSelect, StartDateDropDnS, StartDateDropDnE, EndDateSelect, EndDateDropDnS, EndDateDropDnE	
			StartDateSelect	- The Date to be Selected in the From Row
			StartDateDropDnS	- The Minimun Year in the From Row year dropdown
			StartDateDropDnE	- The Maximun Year in the From Row year dropdown
			EndDateSelect		- The Date to be Selected in the To Row
			EndDateDropDnS		- The Minimun Year in the To Row year dropdown
			EndDateDropDnE		- The Maximun Year in the To Row year dropdown
	
	POPs, Plans, Domains, Staff Selector Parameters: Set ShowPPDS To 1 
		ShowCancel, ShowDeact, ShowSalesOnly
			ShowCancel 		- Show the Cancelled plan as an option.
			ShowDeact 		- Show the Deactivated plan as an option.
			ShowSalesOnly	- Show salespersons only, not staff.
			TheDomainID 	- Comma delimited list of Domains to be preselected.
			ThePlanID		- Comma delimited list of Plans to be preselected.
			ThePOPID			- Comma delimited list of POPs to be preselected.
			SalesPID			- Comma delimited list of Staff to be preselected.
--->

<cfparam name="TheDomainID" default="0">
<cfparam name="ThePlanID" default="0">
<cfparam name="ThePOPID" default="0">
<cfparam name="TheSalesPID" default="0">
<cfparam name="FirstParam" default="0">
<cfparam name="SecondParam" default="">
<cfparam name="FirstAction" default="Starts">
<cfparam name="SecondAction" default="Contains">
<cfparam name="FirstField" default="">
<cfparam name="SecondField" default="">
<cfparam name="LogicConnect" default="And">
<cfparam name="ActiveStatus" default="">
<cfparam name="DueDayBegin" default="1">
<cfparam name="DueDayEnd" default="31">
<cfparam name="PayCk" default="1">
<cfparam name="PayCC" default="1">
<cfparam name="PayCD" default="1">
<cfparam name="PayPO" default="1">
<cfparam name="OwedMin" default="NA">
<cfparam name="OwedMax" default="NA">
<cfparam name="CreditMin" default="NA">
<cfparam name="CreditMax" default="NA">
<cfparam name="SetupFeeYN" default="1">
<cfparam name="TaxesYN" default="1">
<cfparam name="AdjYN" default="1">
<cfparam name="UnpaidDebits" default="1">
<cfparam name="UnpaidCredits" default="1">
<cfparam name="AccntActive" default="1">
<cfparam name="AccntDeact" default="1">
<cfparam name="AccntCancel" default="1">

<cfparam name="ShowLogicNameA" default="0">
<cfparam name="ShowLogicNameB" default="0">
<cfparam name="ShowDateRange" default="0">
<cfparam name="ShowPPDS" default="0">

<cfparam name="HowWide" default="4">
<cfset HowWide = HowWide * 2>
<cfquery name="GetLocale" datasource="#pds#">
	SELECT Value1, VarName 
	FROM Setup 
	WHERE VarName In ('Locale','DateMask1')
</cfquery>
<cfloop query="GetLocale">
	<cfset "#VarName#" = Value1>
</cfloop>
<cfif IsDefined("StartOver.x")>
	<cfquery name="StartOver" datasource="#pds#">
		DELETE FROM GrpLists 
		WHERE ReportID = #ReportID# 
		AND AdminID = #MyAdminID# 
	</cfquery>
</cfif>
<cfif IsDefined("SaveFilter")>
	<cfquery name="CheckFirst" datasource="#pds#">
		SELECT * 
		FROM Filters 
		WHERE AdminID = #MyAdminID# 
		AND ReportID = #ReportID# 
		AND FilterName = <cfif Trim(FilterName) Is "">'Default'<cfelse>'#FilterName#'</cfif> 
	</cfquery>
	<cfif CheckFirst.RecordCount GT 0>
		<cfquery name="CleanUp" datasource="#pds#">
			Delete FROM FilterDomains 
			WHERE FilterID = #CheckFirst.FilterID#
		</cfquery>
		<cfquery name="CleanUp" datasource="#pds#">
			Delete FROM FilterPlans 
			WHERE FilterID = #CheckFirst.FilterID#
		</cfquery>
		<cfquery name="CleanUp" datasource="#pds#">
			Delete FROM FilterPOPs 
			WHERE FilterID = #CheckFirst.FilterID#
		</cfquery>
		<cfquery name="CleanUp" datasource="#pds#">
			Delete FROM FilterSalesp 
			WHERE FilterID = #CheckFirst.FilterID#
		</cfquery>
		<cfquery name="ChangeFilter" datasource="#pds#">
			DELETE FROM Filters 
			WHERE FilterID = #CheckFirst.FilterID#
		</cfquery>
		<cfquery name="CheckFirst" datasource="#pds#">
			SELECT * 
			FROM Filters 
			WHERE AdminID = #MyAdminID# 
			AND ReportID = #ReportID# 
			AND FilterName = <cfif Trim(FilterName) Is "">'Default'<cfelse>'#FilterName#'</cfif> 
		</cfquery>
	</cfif>
	<cfif CheckFirst.RecordCount Is 0>
		<cftransaction>
			<cfquery name="AddFilter" datasource="#pds#">
				INSERT INTO Filters 
				(AdminID,FilterName,
				 <cfloop index="B5" list="#CriteriaToSearch#">
				 	<cfif B5 Is NOT "Null">
						#B5#,
					</cfif>
				 </cfloop>
				 <cfif (IsDefined("ShowDateRange")) AND (ShowDateRange Is 1)>
				 	FromYear,FromMon,FromDay,ToYear,ToMon,ToDay,
				 </cfif>
				 <cfif (IsDefined("ShowLogicName")) AND (ShowLogicName Is 1)>
				 	FirstParam, FirstAction, FirstField, LogicConnect, 
				 </cfif>
				 <cfif (IsDefined("ShowLogicNameB")) AND (ShowLogicNameB Is 1)>
					SecondParam, SecondAction, SecondField, 
				 </cfif>
				 ReportID)
				VALUES 
				(#MyAdminID#,<cfif Trim(FilterName) Is "">'Default'<cfelse>'#FilterName#'</cfif>,
				 <cfloop index="B5" list="#CriteriaToSearch#">
					<cfif B5 Is NOT "Null">
						<cfif IsDefined("Form.#B5#")>
							<cfset FieldName = Evaluate("#B5#")>
							'#FieldName#', 
						<cfelse>
							0, 						
						</cfif>
					</cfif>
				 </cfloop>
				 <cfif (IsDefined("ShowDateRange")) AND (ShowDateRange Is 1)>
				 	#FromYear#,#FromMon#,#FromDay#,#ToYear#,#ToMon#,#ToDay#,
				 </cfif>
				 <cfif (IsDefined("ShowLogicNameA")) AND (ShowLogicNameA Is 1)>
				 	'#FirstParam#', '#FirstAction#', '#FirstField#', '#LogicConnect#', 
				 </cfif>
				 <cfif (IsDefined("ShowLogicNameB")) AND (ShowLogicNameB Is 1)>
				 	'#SecondParam#', '#SecondAction#', '#SecondField#', 
				 </cfif>
				 #ReportID#) 
			</cfquery>
			<cfquery name="NewFilter" datasource="#pds#">
				SELECT Max(FilterID) as NewID 
				FROM Filters 
			</cfquery>
			<cfset FilterID = NewFilter.NewID>
		</cftransaction>
		<cfif PlanID Is Not 0>
			<cfquery name="AddData" datasource="#pds#">
				INSERT INTO FilterPlans 
				(FilterID, PlanID) 
				SELECT #FilterID#, PlanID 
				FROM Plans 
				WHERE PlanID In (#PlanID#) 
			</cfquery>
		</cfif>
		<cfif POPID Is Not 0>
			<cfquery name="AddData" datasource="#pds#">
				INSERT INTO FilterPOPs 
				(FilterID, POPID) 
				SELECT #FilterID#, POPID 
				FROM POPs 
				WHERE POPID In (#POPID#) 
			</cfquery>
		</cfif>
		<cfif DomainID Is Not 0>
			<cfquery name="AddData" datasource="#pds#">
				INSERT INTO FilterDomains 
				(FilterID, DomainID) 
				SELECT #FilterID#, DomainID 
				FROM Domains 
				WHERE DomainID In (#DomainID#) 			
			</cfquery>
		</cfif>
		<cfif SalesPID Is Not 0>
			<cfquery name="AddData" datasource="#pds#">
				INSERT INTO FilterSalesp 
				(FilterID, AdminID) 
				SELECT #FilterID#, AdminID 
				FROM Admin 
				WHERE AdminID In (#SalesPID#) 				
			</cfquery>
		</cfif>		
	</cfif>
</cfif>
<cfif IsDefined("Report.x")>
	<cfquery name="ClearEmailTable" datasource="#pds#">
		DELETE FROM EMailOutGoing 
		WHERE LetterID = #ReportID# 
		AND AdminID = #MyAdminID# 
	</cfquery>
	<cfquery name="SetCreateDate" datasource="#pds#">
		UPDATE GrpLists SET 
		CreateDate = #Now()# 
		WHERE ReportID = #ReportID# 
		AND AdminID = #MyAdminID# 
	</cfquery>
	<cfsetting enablecfoutputonly="no">
	<cfinclude template="grplist.cfm">
	<cfabort>
</cfif>
<cfquery name="CheckFirst" datasource="#pds#">
	SELECT GrpListID 
	FROM GrpLists 
	WHERE AdminID = #MyAdminID# 
	AND ReportID = #ReportID# 
</cfquery>
<cfif CheckFirst.Recordcount Is 0>
	<cfquery name="SavedFilters" datasource="#pds#">
		SELECT * 
		FROM Filters 
		WHERE ReportID = #ReportID# 
		AND AdminID = #MyAdminID# 
		ORDER BY FilterName 
	</cfquery>
	<cfparam name="SavedFilter" default="0">
	<cfparam name="FilterName" default="">
	<cfif IsDefined("ShowPPDS") AND ShowPPDS Is "1">
		<cfquery name="GetPlans" datasource="#pds#">
			SELECT PlanID, PlanDesc 
			FROM Plans 
			WHERE PlanID In 
				(SELECT P.PlanID 
				 FROM PlanAdm P, Admin A, Accounts C
				 WHERE P.AdminID = A.AdminID 
				 AND A.AccountID = C.AccountID 
				 AND A.AdminID = #MyAdminID#)
			<cfif IsDefined("ShowCancel") AND ShowCancel Is 0>
				AND PlanID <> #DelAccount# 
			</cfif>
			<cfif IsDefined("ShowDeact") AND ShowDeact Is 0>
				AND PlanID <> #DeactAccount#
			</cfif>
			ORDER BY PlanDesc
		</cfquery>
		<cfquery name="GetDomains" datasource="#pds#">
			SELECT DomainID, DomainName 
			FROM Domains 
			WHERE DomainID In 
				(SELECT D.DomainID 
				 FROM DomAdm D, Admin A, Accounts C
				 WHERE D.AdminID = A.AdminID 
				 AND A.AccountID = C.AccountID 
				 AND A.AdminID = #MyAdminID#)
			ORDER BY DomainName
		</cfquery>
		<cfquery name="GetPOPs" datasource="#pds#">
			SELECT POPID, POPName 
			FROM POPs 
			WHERE POPID In 
				(SELECT P.POPID 
				 FROM POPAdm P, Admin A, Accounts C
				 WHERE P.AdminID = A.AdminID 
				 AND A.AccountID = C.AccountID 
				 AND A.AdminID = #MyAdminID#)
			ORDER BY POPName
		</cfquery>
		<cfquery name="GetSalesP" datasource="#pds#">
			SELECT C.FirstName, C.LastName, A.AdminID 
			FROM Accounts C, Admin A 
			WHERE C.AccountID = A.AccountID 
			AND A.AdminID IN 
				(SELECT SalesID 
				 FROM SalesAdm 
				 WHERE AdminID = #MyAdminID#)
			<cfif IsDefined("ShowSalesOnly") AND ShowSalesOnly Is "1">
				AND A.SalesPersonYN = 1 
			</cfif>
			ORDER BY C.LastName, C.FirstName 
		</cfquery>
	</cfif>
	<cfif (IsDefined("ShowDateRange")) AND (ShowDateRange Is 1)>
		<cfparam name="StartDateSelect" default="#Now()#">
		<cfparam name="StartDateDropDnS" default="#Now()#">
		<cfparam name="StartDateDropDnE" default="#DateAdd("yyyy",1,StartDateDropDnS)#">
		<cfparam name="EndDateSelect" default="#Now()#">
		<cfparam name="EndDateDropDnS" default="#Now()#">
		<cfparam name="EndDateDropDnE" default="#DateAdd("yyyy",1,EndDateDropDnS)#">
		<!--- From Row --->
		<cfset SelSMonth = Month(StartDateSelect)>
		<cfset NumSDays = DaysInMonth(StartDateSelect)>
		<cfset SelSDay = Day(StartDateSelect)>
		<cfset SelSYear = Year(StartDateSelect)>
		<cfset MinSYear = Year(StartDateDropDnS)>
		<cfset MaxSYear = Year(StartDateDropDnE)>
		<!--- To Row --->
		<cfset SelEMonth = Month(EndDateSelect)>
		<cfset NumEDays = DaysInMonth(EndDateSelect)>
		<cfset SelEDay = Day(EndDateSelect)>
		<cfset SelEYear = Year(EndDateSelect)>
		<cfset MinEYear = Year(EndDateDropDnS)>
		<cfset MaxEYear = Year(EndDateDropDnE)>
	</cfif>
<cfelse>
	<cfquery name="CheckForTabs" datasource="#pds#">
		SELECT ReportTab 
		FROM GrpLists 
		WHERE ReportID = #ReportID# 
		AND AdminID = #MyAdminID# 
		GROUP BY ReportTab 
	</cfquery>
	<cfif CheckForTabs.RecordCount Is 1>
		<cfset Pos1 = ListFindNoCase(SendFields,"ReportTab")>
		<cfif Pos1 GT 0>
			<cfset SendFields = ListDeleteAt(SendFields,Pos1)>
			<cfset SendHeader = ListDeleteAt(SendHeader,Pos1)>
		</cfif>
	</cfif>
</cfif>
<cfif IsDefined("UseExisting")>
	<cfquery name="GetFilter" datasource="#pds#">
		SELECT * 
		FROM Filters 
		WHERE FilterID = #SavedFilter# 
	</cfquery>
	<cfquery name="DomainsFilter" datasource="#pds#">
		SELECT DomainID 
		FROM FilterDomains 
		WHERE FilterID = #SavedFilter#
	</cfquery>
	<cfquery name="PlansFilter" datasource="#pds#">
		SELECT PlanID 
		FROM FilterPlans 
		WHERE FilterID = #SavedFilter# 
	</cfquery>
	<cfquery name="POPsFilter" datasource="#pds#">
		SELECT POPID 
		FROM FilterPOPs 
		WHERE FilterID = #SavedFilter# 
	</cfquery>
	<cfquery name="SalesFilter" datasource="#pds#">
		SELECT AdminID 
		FROM FilterSalesp 
		WHERE FilterID = #SavedFilter# 
	</cfquery>
	<cfif DomainsFilter.RecordCount GT 0>
		<cfset TheDomainID = ValueList(DomainsFilter.DomainID)>
	</cfif>
	<cfif PlansFilter.RecordCOunt GT 0>
		<cfset ThePlanID = ValueList(PlansFilter.PlanID)>
	</cfif>
	<cfif POPsFilter.RecordCount GT 0>
		<cfset ThePOPID = ValueList(POPsFilter.POPID)>
	</cfif>
	<cfif SalesFilter.RecordCount GT 0>
		<cfset TheSalesPID = ValueList(SalesFilter.AdminID)>
	</cfif>
	<cfloop index="B5" list="#CriteriaToSearch#">
		<cfset RField = B5>
		<cfif RField Is NOT "Null">
			<cfset "#RField#" = Evaluate("GetFilter.#RField#")>
		</cfif>
	</cfloop>
	<cfset FilterName = GetFilter.FilterName>
	<cfif GetFilter.FirstParam Is Not "">
		<cfset FirstParam = GetFilter.FirstParam>
	</cfif>
	<cfif GetFilter.FirstAction Is Not "">
		<cfset FirstAction = GetFilter.FirstAction>
	</cfif>
	<cfif GetFilter.FirstField Is Not "">
		<cfset FirstField = GetFilter.FirstField>
	</cfif>
	<cfif GetFilter.LogicConnect Is Not "">
		<cfset LogicConnect = GetFilter.LogicConnect>
	</cfif>
	<cfif GetFilter.SecondParam Is Not "">
		<cfset SecondParam = GetFilter.SecondParam>
	</cfif>
	<cfif GetFilter.SecondAction Is Not "">
		<cfset SecondAction = GetFilter.SecondAction>
	</cfif>
	<cfif GetFilter.SecondField Is Not "">
		<cfset SecondField = GetFilter.SecondField>
	</cfif>
	<cfif GetFilter.FromYear Is Not "">
		<cfset SelSYear = GetFilter.FromYear>
	</cfif>
	<cfif GetFilter.FromMon Is Not "">
		<cfset SelSMonth = GetFilter.FromMon>
	</cfif>
	<cfif GetFilter.FromDay Is Not "">
		<cfset SelSDay = GetFilter.FromDay>
	</cfif>
	<cfif GetFilter.ToYear Is Not "">
		<cfset SelEYear = GetFilter.ToYear>
	</cfif>
	<cfif GetFilter.ToMon Is Not "">
		<cfset SelEMonth = GetFilter.ToMon>
	</cfif>
	<cfif GetFilter.ToDay Is Not "">
		<cfset SelEDay = GetFilter.ToDay>
	</cfif>
</cfif>

<cfsetting enablecfoutputonly="no">
<html>
<head>
<cfoutput>
<title>#ReportTitle#</title>
<cfif CheckFirst.Recordcount Is 0>
<script language="javascript">
<!--
<cfif (IsDefined("ShowDateRange")) AND (ShowDateRange Is 1)>
function checkdates()
	{
	 var var1 = document.getdate.FromYear.options[document.getdate.FromYear.selectedIndex].value
	 var var2 = document.getdate.FromMon.options[document.getdate.FromMon.selectedIndex].value - 1
	 var var3 = document.getdate.FromDay.options[document.getdate.FromDay.selectedIndex].text
	 var var6 = document.getdate.ToYear.options[document.getdate.ToYear.selectedIndex].value
	 var var7 = document.getdate.ToMon.options[document.getdate.ToMon.selectedIndex].value - 1
	 var var8 = document.getdate.ToDay.options[document.getdate.ToDay.selectedIndex].text
	 var var10 = var1 + '/' + var2 + '/' + var3
	 var var16 = var6 + '/' + var7 + '/' + var8
	 date1 = new Date(var1,var2,var3)
	 date2 = new Date(var6,var7,var8)
	 if (date2 < date1)
	 	{
		 alert ('End date can not be before the start date.')
		 return false
		}
	 return true
	}
function getdays()
	{
	 var var1 = document.getdate.FromMon.options[document.getdate.FromMon.selectedIndex].value
	 if (var1 == 1 || var1 == 3 || var1 == 5 || var1 == 7 || var1 == 8 || var1 == 10 || var1 == 12)
		{
		document.getdate.FromDay.options.length = 31
		document.getdate.FromDay.options[28].text = '29'
		document.getdate.FromDay.options[29].text = '30'
		document.getdate.FromDay.options[30].text = '31'	   	   
		var var2 = var1 - 1
		return false
		}
	 else if (var1 == 4 || var1 == 6 || var1 == 9 || var1 == 11)
		{
		 document.getdate.FromDay.options.length = 30
		 document.getdate.FromDay.options[28].text = '29'
		 document.getdate.FromDay.options[29].text = '30'
		 var var2 = var1 - 1
		 var var9 = document.getdate.FromDay.selectedIndex
		 if (var9 == -1)
			{
			 var9 = 0
			}
		 document.getdate.FromDay.options[var9].selected = true		  
		 return false
		}
	 else if (var1 == 2)
		{
		 var var6 = document.getdate.FromYear.options[document.getdate.FromYear.selectedIndex].value
		 var7 = getfebdays(var6)
		 document.getdate.FromDay.options.length = var7
		 if (var7 == 29)
			{
			 document.getdate.FromDay.options[28].text = '29'		
			}
		 var var2 = var1 - 1
		 var var9 = document.getdate.FromDay.selectedIndex
		 if (var9 == -1)
			{
			 var9 = 0
			}
		 document.getdate.FromDay.options[var9].selected = true
		 return false
		}
	 return false
	}
function getdays2()
	{
	 var var1 = document.getdate.ToMon.options[document.getdate.ToMon.selectedIndex].value
	 if (var1 == 1 || var1 == 3 || var1 == 5 || var1 == 7 || var1 == 8 || var1 == 10 || var1 == 12)
		{
		 document.getdate.ToDay.options.length = 31
		 document.getdate.ToDay.options[28].text = '29'
		 document.getdate.ToDay.options[29].text = '30'
		 document.getdate.ToDay.options[30].text = '31'
		 var var2 = var1 - 1
		 document.getdate.ToMon.options[var2].selected = true
		 return false
		}
	 else if (var1 == 4 || var1 == 6 || var1 == 9 || var1 == 11)
		{
		 document.getdate.ToDay.options.length = 30
		 document.getdate.ToDay.options[28].text = '29'
		 document.getdate.ToDay.options[29].text = '30'
		 var var2 = var1 - 1
		 document.getdate.ToMon.options[var2].selected = true
		 document.getdate.ToDay.options[29].selected = true
		 return false
		}
	 else if (var1 == 2)
		{
		 var var6 = document.getdate.ToYear.options[document.getdate.ToYear.selectedIndex].value
		 var7 = getfebdays(var6)
		 document.getdate.ToDay.options.length = var7
		 if (var7 == 29)
			{
			 document.getdate.ToDay.options[28].text = '29'				   
			 document.getdate.ToDay.options[28].selected = true
			}
			 document.getdate.ToDay.options[27].selected = true			
		 return false
		}
	 return false
	}
function getfebdays(theyear)
	{
	 if ((theyear % 4 == 0 && theyear % 100 != 0) || theyear % 400 == 0)
	 return 29
	 else
	 return 28
	}
</cfif>
function MsgWindow()
	{
    window.open('processing.cfm','Processing','scrollbars=no,status=no,width=400,height=150,location=no,resizable=no');
	}
function FilterWindow()
	{
    window.open('filter.cfm?ReportID=#ReportID#','ProgramInfo','scrollbars=yes,status=no,width=400,height=450,location=no,resizable=yes');
	}
// -->
</script>
</cfif>
</cfoutput>
<cfinclude template="coolsheet.cfm">
</head>
<cfoutput><body #colorset#></cfoutput>
<cfinclude template="header.cfm">
<center>
<cfoutput>
<table border="#tblwidth#">
	<tr>
		<th colspan="#HowWide#" bgcolor="#ttclr#"><font size="#ttsize#" <cfif ttface Is Not "NA">face="#perFontName#"</cfif> color="#ttfont#">#ReportTitle#</font></th>
	</tr>
</cfoutput>
<cfif CheckFirst.RecordCount Is 0>
	<cfif (IsDefined("ShowFilters")) AND (ShowFilters Is 1)>
		<tr>
			<cfoutput>
			<td colspan="#HowWide#" align="right" bgcolor="#tdclr#">
			</cfoutput>
				<table border="0" width="100%">
					<tr>
						<cfif SavedFilters.RecordCount GT 0>
							<cfoutput>
							<form method="post" action="#ReturnPage#?RequestTimeout=300">
								<td colspan="2">
									<table border="0" cellpadding="0" cellspacing="0">
										<tr>
											<td><input type="radio" name="EditFilters" value="1" onclick="FilterWindow()" id="col1"><label for="col1">Filters</label></td>
							</form>
							<form method="post" mame="useexisting" action="#ReturnPage#">
							</cfoutput>
											<td><select name="SavedFilter">
												<cfloop query="SavedFilters">
													<cfoutput><option <cfif FilterID Is SavedFilter>selected</cfif> value="#FilterID#">#FilterName#</cfoutput>
												</cfloop>
											</select> <input type="submit" name="UseExisting" value="Load"></td>
										</tr>									
									</table>
								</td>
							</form>
						</cfif>
		<cfoutput>
		<form name="getdate" method="post" action="#ReturnPage#?RequestTimeout=500" onsubmit="MsgWindow()">
						<td colspan="2" align="right"><input type="checkbox" name="SaveFilter" value="1">Save Filter As<input type="text" name="FilterName" value="#FilterName#" size="20" maxlength="150"></td>
					</tr>
				</table>
			</td>
		</tr>
		</cfoutput>
	<cfelse>
		<form name="getdate" method="post" action="#ReturnPage#?RequestTimeout=500" onsubmit="MsgWindow()">
	</cfif>
	<cfif (IsDefined("ShowDateRange")) AND (ShowDateRange Is 1)>
		<cfset HowWide2 = HowWide/2>
		<cfoutput>
		<tr bgcolor="#tdclr#">
			<td bgcolor="#tbclr#" align=right>From:</td>
			<cfset CarryWide = 1>
		</cfoutput>
			<cfset HowWideC2 = HowWide2 - 1>
			<cfset CarryWide = CarryWide + HowWideC2>
			<cfoutput>
			<td colspan="#HowWideC2#"><Select name="FromMon" onChange="getdays()">
			</cfoutput>
				<cfloop index="B5" From="1" To="12">
					<cfif B5 lt 10><cfset B5 = "0" & B5></cfif>
					<cfoutput><option value="#B5#" <cfif SelSMonth is B5>Selected</cfif> >#LSDateFormat("#B5#/1/2000", 'MMMM')#</cfoutput>
				</cfloop>
			</select><SELECT name="FromDay">
				<cfloop index="B4" From="1" To="#NumSDays#">
					<cfif B4 lt 10><cfset B4 = "0" & B4></cfif>
					<cfoutput><option <cfif SelSDay Is B4>selected</cfif> value="#B4#">#B4#</cfoutput>
				</cfloop>
			</select><SELECT name="FromYear" onChange="getdays()">
				<cfloop index="B3" From="#MinSYear#" To="#MaxSYear#">
					<cfoutput><option <cfif SelSYear Is B3>Selected</cfif> value="#B3#">#B3#</cfoutput>
				</cfloop>
			</select></td>
		<cfif HowWide Is 2>
			</tr>
			<cfoutput><tr bgcolor="#tdclr#"></cfoutput>
		</cfif>
		<cfoutput>
			<td bgcolor="#tbclr#" align=right>To:</td>
		</cfoutput>
			<cfset CarryWide = CarryWide + 1>
			<cfset HowWideC4 = HowWide - CarryWide>
			<cfoutput><td colspan="#HowWideC4#"><Select name="ToMon" onChange="getdays2()"></cfoutput>
				<cfloop index="B5" From="1" To="12">
					<cfif B5 lt 10><cfset B5 = "0" & B5></cfif>
					<cfoutput><option <cfif SelEMonth is B5>Selected</cfif> value="#B5#" >#LSDateFormat("#B5#/1/1996", 'MMMM')#</cfoutput>
				</cfloop>
			</select><SELECT name="ToDay">
				<cfloop index="B4" From="1" To="#NumEDays#">
					<cfif B4 lt 10><cfset B4 = "0" & B4></cfif>
					<cfoutput><option <cfif SelEDay is B4>Selected</cfif> value="#B4#">#B4#</cfoutput>
				</cfloop>
			</select><SELECT name="ToYear" onChange="getdays2()">
				<cfloop index="B3" From="#MinEYear#" To="#MaxEYear#">
					<cfoutput><option <cfif SelEYear is B3>Selected</cfif> value="#B3#">#B3#</cfoutput>
				</cfloop>
			</select></td>
		</tr>
	</cfif>
	<cfif ShowLogicNameA Is 1>
		<cfoutput><tr bgcolor="#tdclr#">
			<td colspan="#HowWide#" align="right"></cfoutput>
				<table border="0" width="100%">
					<tr valign="top">
						<td rowspan="2"><SELECT name="FirstParam">
							<cfloop index="B2" list="#FirstDropDown#">
								<cfset OptValue = ListGetAt(B2,1,";")>
								<cfif ListLen(B2,";") GT 1>
									<cfset OptDisp = ListGetAt(B2,2,";")>
								<cfelse>
									<cfset OptDisp = OptValue>
								</cfif>
								<cfoutput><option <cfif FirstParam Is OptValue>selected</cfif> value="#OptValue#">#OptDisp#</cfoutput>
							</cfloop>
						</select></td>
						<cfoutput>
							<td><INPUT type="radio" <cfif FirstAction Is "Starts">checked</cfif> name="FirstAction" value="Starts"> Starts With</td>
							<td><INPUT type="radio" name="FirstAction" <cfif FirstAction Is "contains">checked</cfif> value="contains"> Contains</td>
							<td><INPUT type="radio" name="FirstAction" <cfif FirstAction Is "Like">checked</cfif> value="Like"> Like</td>
							<td rowspan="2"><INPUT NAME="FirstField" TYPE="TEXT" value="#FirstField#" SIZE="20" maxlength="100"></td>
						</cfoutput>
					</tr>
					<tr>
						<td><INPUT type="radio" <cfif FirstAction Is "NotStarts">checked</cfif> name="FirstAction" value="NotStarts">Not Starts With</td>
						<td><INPUT type="radio" name="FirstAction" <cfif FirstAction Is "NotContains">checked</cfif> value="NotContains">Not Contains</td>
						<td><INPUT type="radio" name="FirstAction" <cfif FirstAction Is "Not">checked</cfif> value="Not">Not Like</td>
					</tr>
				</table>
			</td>
		</tr>
	</cfif>
	<cfif (ShowLogicNameA Is 1) AND (ShowLogicNameB Is 1)>
		<cfoutput><tr bgcolor="#tdclr#">
			<td colspan="#HowWide#"></cfoutput>
				<table border="0" width="100%">
					<tr>
						<cfoutput>
							<td colspan="5" align="center" bgcolor="#tdclr#"><INPUT TYPE=RADIO <cfif LogicConnect Is "And">CHECKED</cfif> NAME="LogicConnect" VALUE="And">AND <INPUT TYPE=RADIO <cfif LogicConnect Is "Or">CHECKED</cfif> NAME="LogicConnect" VALUE="Or">OR</td>
						</cfoutput>
					</tr>
				</table>
			</td>
		</tr>
	</cfif>
	<cfif ShowLogicNameB Is 1>
		<cfoutput><tr bgcolor="#tdclr#">
			<td colspan="#HowWide#"></cfoutput>
				<table border="0" width="100%">
					<tr valign="top">
						<td rowspan="2"><SELECT  name="SecondParam">
							<OPTION value="">-
							<cfloop index="B2" list="#SecondDropDown#">
								<cfset OptValue = ListGetAt(B2,1,";")>
								<cfif ListLen(B2,";") GT 1>
									<cfset OptDisp = ListGetAt(B2,2,";")>
								<cfelse>
									<cfset OptDisp = OptValue>
								</cfif>
								<cfoutput><option <cfif SecondParam Is OptValue>selected</cfif> value="#OptValue#">#OptDisp#</cfoutput>
							</cfloop>
						</SELECT></td>
						<cfoutput>
							<td><INPUT type="radio" <cfif SecondAction Is "starts">checked</cfif> name="SecondAction" value="starts"> Starts With</td>
							<td><INPUT type="radio" <cfif SecondAction Is "contains">checked</cfif> name="SecondAction" value="contains"> Contains</td>
							<td><INPUT type="radio" name="SecondAction" <cfif SecondAction Is "Like">checked</cfif> value="Like"> Like</td>
							<td rowspan="2"><INPUT NAME="SecondField" TYPE="TEXT" value="#SecondField#" SIZE="20" maxlength="100"></td>
						</cfoutput>
					</tr>
					<tr>
						<td><INPUT type="radio" <cfif SecondAction Is "NotStarts">checked</cfif> name="SecondAction" value="NotStarts">Not Starts With</td>
						<td><INPUT type="radio" <cfif SecondAction Is "NotContains">checked</cfif> name="SecondAction" value="NotContains">Not Contains</td>
						<td><INPUT type="radio" name="SecondAction" <cfif SecondAction Is "Not">checked</cfif> value="Not"> Not Like</td>
					</tr>
				</table>
			</td>
		</tr>
	</cfif>
	<cfif ListLen(CriteriaToSearch) GT 0>
		<cfset RowCount = 1>
		<cfset HowWide2 = Ceiling(HowWide/2)>
		<cfloop index="B4" list="#CriteriaToSearch#">
			<cfset FName = B4>
			<cfif RowCount Is 1><tr></cfif>
			<cfif FName Is "DueDayBegin">
				<cfoutput>
				<td bgcolor="#tdclr#" align="right"><select name="#FName#">
				</cfoutput>
					<cfloop index="B3" from="1" to="31">
						<cfoutput><option <cfif B3 Is DueDayBegin>selected</cfif> value="#B3#">#B3#</cfoutput>
					</cfloop>
				</select></td>
				<cfoutput><td bgcolor="#tbclr#">Beginning Due Day</td></cfoutput>
			<cfelseif FName Is "DueDayEnd">
				<cfoutput>
				<td bgcolor="#tdclr#" align="right"><select name="#FName#">
				</cfoutput>
					<cfloop index="B3" from="1" to="31">
						<cfoutput><option <cfif B3 Is DueDayEnd>selected</cfif> value="#B3#">#B3#</cfoutput>
					</cfloop>
				</select></td>
				<cfoutput><td bgcolor="#tbclr#">Ending Due Day</td></cfoutput>
			<cfelseif FName Is "OwedMin">
				<cfoutput>
					<td bgcolor="#tdclr#" align="right"><input type="text" name="#FName#" size="5" value="#OwedMin#"></td>
					<td bgcolor="#tbclr#">Minimum Owed</td>
				</cfoutput>
			<cfelseif FName Is "OwedMax">
				<cfoutput>
					<td bgcolor="#tdclr#" align="right"><input type="text" name="#FName#" size="5" value="#OwedMax#"></td>
					<td bgcolor="#tbclr#">Minimum Credit</td>
				</cfoutput>
			<cfelseif FName Is "CreditMin">
				<cfoutput>
					<td bgcolor="#tdclr#" align="right"><input type="text" name="#FName#" size="5" value="#CreditMin#"></td>
					<td bgcolor="#tbclr#">Minimum Credit</td>
				</cfoutput>
			<cfelseif FName Is "CreditMax">
				<cfoutput>
					<td bgcolor="#tdclr#" align="right"><input type="text" name="#FName#" size="5" value="#CreditMax#"></td>
					<td bgcolor="#tbclr#">Maximum Credit</td>
				</cfoutput>
			<cfelseif FName Is "PayCk">
				<cfoutput>
					<td bgcolor="#tdclr#" align="right"><input type="Checkbox" <cfif PayCk Is 1>checked</cfif> name="#FName#" value="1"></td>
					<td bgcolor="#tbclr#">Check/ Cash Customers</td>
				</cfoutput>
			<cfelseif FName Is "PayCC">
				<cfoutput>
					<td bgcolor="#tdclr#" align="right"><input type="Checkbox" <cfif PayCC Is 1>checked</cfif> name="#FName#" value="1"></td>
					<td bgcolor="#tbclr#">Credit Card Customers</td>
				</cfoutput>
			<cfelseif FName Is "PayCD">
				<cfoutput>
					<td bgcolor="#tdclr#" align="right"><input type="Checkbox" <cfif PayCD Is 1>checked</cfif> name="#FName#" value="1"></td>
					<td bgcolor="#tbclr#">Check Debit Customers</td>
				</cfoutput>
			<cfelseif FName Is "PayPO">
				<cfoutput>
					<td bgcolor="#tdclr#" align="right"><input type="Checkbox" <cfif PayPO Is 1>checked</cfif> name="#FName#" value="1"></td>
					<td bgcolor="#tbclr#">Purchase Order Customers</td>
				</cfoutput>
			<cfelseif FName Is "AccntActive">
				<cfoutput>
					<td bgcolor="#tdclr#" align="right"><input type="Checkbox" <cfif AccntActive Is 1>checked</cfif> name="#FName#" value="1"></td>
					<td bgcolor="#tbclr#">Active Accounts</td>
				</cfoutput>
			<cfelseif FName Is "AccntDeact">
				<cfoutput>
					<td bgcolor="#tdclr#" align="right"><input type="Checkbox" <cfif AccntDeact Is 1>checked</cfif> name="#FName#" value="1"></td>
					<td bgcolor="#tbclr#">Include Deactivated Accounts</td>
				</cfoutput>
			<cfelseif FName Is "AccntCancel">
				<cfoutput>
					<td bgcolor="#tdclr#" align="right"><input type="Checkbox" <cfif AccntCancel Is 1>checked</cfif> name="#FName#" value="1"></td>
					<td bgcolor="#tbclr#">Include Cancelled Accounts</td>
				</cfoutput>
			<cfelseif FName Is "Null">
				<cfoutput>
					<td bgcolor="#tdclr#" align="right">&nbsp;</td>
					<td bgcolor="#tbclr#">&nbsp;</td>
				</cfoutput>
			</cfif>
			<cfif RowCount Is HowWide2></tr><cfset RowCount = 0></cfif>
			<cfset RowCount = RowCount + 1>
		</cfloop>
	</cfif>
	<tr>
		<cfoutput>
			<th colspan="#HowWide#"><input type="image" src="images/viewlist.gif" name="Report" border="0"></th>
		</cfoutput>
	</tr>
	<cfif IsDefined("ShowPPDS") AND ShowPPDS Is "1">
		<cfset HowWide2 = HowWide/2>
		<cfoutput>
		<tr bgcolor="#tdclr#" valign="top">
			<td align="right" bgcolor="#tbclr#">Plans</td>
			<cfset CarryWide = 1>
		</cfoutput>
			<cfset HowWideC2 = HowWide2 - 1>
			<cfset CarryWide = CarryWide + HowWideC2>
			<cfoutput><td colspan="#HowWideC2#"><select name="PlanID" multiple size="6"></cfoutput>
				<option <cfif ThePlanID Is "0">selected</cfif> value="0">All Plans
				<cfoutput query="GetPlans">
					<option <cfif ListFind(ThePlanID,PlanID) GT 0>selected</cfif> value="#PlanID#">#PlanDesc#
				</cfoutput>
				<option value="">______________________________
			</select></td>
		<cfif HowWide Is 2>
			</tr>
			<cfoutput><tr bgcolor="#tdclr#"></cfoutput>
		</cfif>
			<cfoutput>
			<td align="right" bgcolor="#tbclr#">POPs</td>
			<cfset CarryWide = CarryWide + 1>
			</cfoutput>
			<cfset HowWideC4 = HowWide - CarryWide>
			<cfoutput><td colspan="#HowWideC4#"><select name="POPID" multiple size="6"></cfoutput>
					<option <cfif ThePOPID Is "0">selected</cfif> value="0">All POPs
					<cfoutput query="GetPOPS">
						<option <cfif ListFind(ThePOPID,POPID) GT 0>selected</cfif> value="#POPID#">#POPName#
					</cfoutput>
					<option value="">______________________________
			</select></td>
		</tr>
		<cfoutput>
		<tr valign="top" bgcolor="#tdclr#">
			<td align="right" bgcolor="#tbclr#">Salesperson</td>
		</cfoutput>
			<cfoutput><td colspan="#HowWideC2#"><select name="SalesPID" multiple size="6"></cfoutput>
				<option <cfif TheSalesPID Is 0>selected</cfif> value="0">All Salespersons
				<cfoutput query="GetSalesP">
					<option <cfif ListFind(TheSalesPID,AdminID) GT 0>selected</cfif> value="#AdminID#">#LastName#, #FirstName#
				</cfoutput>
				<option value="">______________________________
			</select></td>
		<cfif HowWide Is 2>
			</tr>
			<cfoutput><tr bgcolor="#tdclr#"></cfoutput>
		</cfif>
		<cfoutput>
			<td align="right" bgcolor="#tbclr#">Domains</td>
		</cfoutput>
			<cfoutput><td colspan="#HowWideC4#"><select name="DomainID" multiple size="6"></cfoutput>
				<option <cfif TheDomainID Is "0">selected</cfif> value="0">All Domains
				<cfoutput query="GetDomains">
					<option <cfif ListFind(TheDomainID,DomainID) GT 0>selected</cfif> value="#DomainID#">#DomainName#
				</cfoutput>
				<option value="">______________________________
			</select></td>
		</tr>
	</cfif>
<cfelse>	
	<cfoutput>
	<tr>
		<td colspan="#HowWide#" bgcolor="#tbclr#">There is already a report in progress.</td>
	</tr>
	<tr>
		<form method="post" action="grplist.cfm">
			<input type="hidden" name="SendReportID" value="#ReportID#">
			<input type="hidden" name="SendLetterID" value="#LetterID#">
			<input type="hidden" name="ReturnPage" value="#ReturnPage#">
			<input type="hidden" name="SendHeader" value="#SendHeader#">
			<input type="hidden" name="SendFields" value="#SendFields#">
			<th width="50%" colspan="2"><input type="image" src="images/viewlist.gif" name="ViewExisting" border="0"></th>
		</form>
		<form method="post" action="#ReturnPage#">
			<th colspan="2"><input type="image" src="images/changecriteria.gif" name="StartOver" border="0"></th>
		</form>
	</tr>
	</cfoutput>
</cfif>
</table>
</center>
<cfinclude template="footer.cfm">
</body>
</html>
 
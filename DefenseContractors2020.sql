-------------------------------------------------------------------------------------------------------------
--
--
--	Analysis of the Defense Industry
--
--		
--
--
--	Coleman Parks
--	Sep 17, 2022
--
--
--
--	Data Obtained From Kaggle and  THE STOCKHOLM INTERNATIONAL PEACE RESEARCH INSTITUTE
--		Data here : https://www.sipri.org/databases
--
--
--
--	The purpose of this analysis is to paint a picture of where the most money is being spent in the defense sector,
--		as well as where the msot money is being made
--
--	Typically, I'd preview data using top. Since this table only has 100 rows, I choose the select * command instead

SELECT *
FROM [dbo].top_defense_manufacturers_v2$



--	The data source specified that all revenue figures are in millions USD. First I'll fix that

--UPDATE [dbo].top_defense_manufacturers_v2$
--SET defense_revenue_2020 = defense_revenue_2020*1000000, defense_revenue_2019 = defense_revenue_2019*1000000, total_revenue_2020 = total_revenue_2020*1000000



SELECT *
FROM [dbo].top_defense_manufacturers_v2$



--	While the data regarding 2019 and the changes in expenditure from 2019-2020 is important, I believe there is insufficient data 
--		to derive any real conclusions from an anlysis into this. Thereofre I'll get rid of the "rank_2019",
--		"defense_revenue_2019", and "percent_defense_revenue_change"

--ALTER TABLE [dbo].top_defense_manufacturers_v2$
--DROP COLUMN rank_2019, defense_Revenue_2019, percent_defense_revenue_change




SELECT *
FROM [dbo].top_defense_manufacturers_v2$

--	Now to see a list of total revenue by country shown in descending order

Select DISTINCT country,
				count(country) AS 'Number of Companies',
				SUM(total_revenue_2020)/1000000000 AS 'Total Revenue 2020 in Billions'
FROM [dbo].top_defense_manufacturers_v2$
GROUP BY country
ORDER BY [Total Revenue 2020 in Billions] DESC



--	As 50 of the 100 top companies are US-based, I now want to pull in the average revenue

Select DISTINCT country,
				count(country) AS 'Number of Companies',
				SUM(total_revenue_2020)/1000000000 AS 'Total Revenue 2020 in Billions',
				AVG(total_revenue_2020)/1000000000 AS 'Average Revenue in Billions'
FROM [dbo].top_defense_manufacturers_v2$
GROUP BY country
ORDER BY [Total Revenue 2020 in Billions] DESC



--	Looking at the top 5 results, it seems the US might hold the majority of the market, 
--		but there are a few other nations which match or wildly outperform the US in terms of average revenue of their defense contractors.
--
--	In the case of Netherlands/France on Row 5, that is the statistic for single company so its average revenue is an outlier.
--
--	On the other hand, this table explains why China's defence sector generates just over half of the US's despite having 
--		around a seventh as many companies on the Top 100 List
--
--	Along that same vein of thought, let's see the average rank broken down by nation as well

Select DISTINCT country,
				count(country) AS 'Number of Companies',
				ROUND(SUM(total_revenue_2020),0) AS 'Total Revenue', 
				ROUND(SUM(total_revenue_2020)/1000000000,2,0) AS 'Total Revenue 2020 in Billions',
				ROUND(AVG(total_revenue_2020)/1000000000,2,2) AS 'Average Revenue in Billions',
				ROUND(AVG(rank_2020)/count(country),1, 0) AS 'Average Ranking'
FROM [dbo].top_defense_manufacturers_v2$
GROUP BY country
ORDER BY [Total Revenue 2020 in Billions] DESC


--	Now to see how much of that revenue came from defense activities

Select DISTINCT country AS 'Country',
				count(country) AS 'Number of Companies',
				ROUND(SUM(total_revenue_2020),0) AS 'Total Revenue', 
				ROUND(SUM(total_revenue_2020)/1000000000,2,0) AS 'Total Revenue 2020 in Billions',
				ROUND(AVG(total_revenue_2020)/1000000000,2,2) AS 'Average Revenue in Billions',
				ROUND(AVG(rank_2020)/count(country),0, 2) AS 'Average Ranking',
				ROUND(AVG(revenue_from_defense),2,2) AS 'Average Revenue From Defense'
FROM [dbo].top_defense_manufacturers_v2$

GROUP BY country
ORDER BY [Average Revenue From Defense] DESC



--	When cleaning the data I noticed that most companies only identified one leader, whereas some had two leaders.
--
--	The majority of these companies were in China, which coincidently far outperformed the US in every metric
--		except total revenue. 
--
--	By inserting a column for the number of companies with two leaders, I hope to test my hypothesis that:
--		There is a positive correlation between having dual leadership and total revenue generated amongst defense companies.
--
--	I'll do this by first making a column for number of leaders. They will be updated when exporting the tables 
--		before being imported to tableau for visualization.



--ALTER TABLE [dbo].top_defense_manufacturers_v2$
--ADD Number_Of_Leaders nvarchar(255);

SELECT *
FROM [dbo].top_defense_manufacturers_v2$



--UPDATE [dbo].top_defense_manufacturers_v2$
--SET Number_Of_Leaders = 1



SELECT *
FROM [dbo].top_defense_manufacturers_v2$

----------------------------

Select DISTINCT country AS Country,
				COUNT(country) AS 'Number of Companies',
				ROUND(SUM(total_revenue_2020)/1000000000,2,0) AS 'Total Defense Revenue 2020 in Billions ($USD)',
				ROUND(AVG(total_revenue_2020)/1000000000,2,2) AS 'Average Defense Revenue 2020 in Billions ($USD)',
				ROUND(SUM(total_revenue_2020),0) AS 'Total Revenue ($USD)', 
				ROUND(AVG(total_revenue_2020),2,2) AS 'Average Revenue ($USD)',
				ROUND(AVG(rank_2020)/count(country),0, 2) AS 'Average Ranking',
				ROUND(AVG(revenue_from_defense),2,2) AS 'Average Percentage of Revenue From Defense 2020 ($USD)'
	 
FROM [dbo].top_defense_manufacturers_v2$
GROUP BY country
ORDER BY [Total Revenue ($USD)] DESC




--	At this point, the data is ready to start visualizing. I'm going to export some of these tables and make some quick tableau 
--		visualizations in case a stakeholder wants a simple first-glance report while awaiting a more in-depth analysis.
--
--	To do this, I'll recall old code snippets and then copy and paste their output into Excel. Once in Excel, I'll Save the tables
--		according to how they'll be used in Tableau. Once an initial visualization is made and intial feedback is recieved,
--		I'll resume the analysis taking into account the stakeholders input.

--SELECT *
--FROM [dbo].top_defense_manufacturers_v2$


SELECT			
				company AS 'Company',
				country AS 'Country',
				total_revenue_2020 AS 'Total Revenue ($USD)',
				total_revenue_2020/1000000000 AS 'Total Revenue in Billions ($USD)',
				defense_revenue_2020 AS 'Defense Revenue 2020 ($USD)',
				defense_revenue_2020/1000000000 AS 'Defense Revenue 2020 in Billions ($USD)',
				revenue_from_defense AS 'Percentage of Revenue From Defense',
				Number_Of_Leaders
FROM [dbo].top_defense_manufacturers_v2$



--	The analysis is feeling pretty light. I feel like Stakeholders will want some greater insight
--		than possible with this dataset. 
--	
--	By including this data, I hope to see how much of these defense contactors revenue comes directly from their
--		country of origin.
--
--	First a quick glance at the table

SELECT *
FROM [dbo].['Regional totals$']

SELECT  Region,
		[2020]*1000000000 AS 'Total Defense Spending 2020 ($USD)',
		ROUND([2020],2,2) AS 'Total Spending in Billions ($USD)'
FROM [dbo].['Regional totals$']
ORDER BY [2020] DESC



-- Now I'll break it down by continent and world.

SELECT DISTINCT Region,
		[2020]*1000000000 AS 'Total Defense Spending 2020 ($USD)',
		ROUND([2020],2,2) AS 'Total Spending in Billions ($USD)'
FROM [dbo].['Regional totals$']
WHERE Region LIKE '%World%'
	OR Region LIKE 'Africa'
	OR Region LIKE 'North America'
	OR Region LIKE 'South America'
	OR Region LIKE 'Asia & Oceania'
	OR Region LIKE 'Europe'
	OR Region LIKE 'Middle East'

  

-- For a deeper analysis, I'll also pull a list of the top 10 nations in terms of Defense spending

SELECT TOP (10) [Country],
		ROUND([2020]*1000000,2,0) AS 'Total Defense Spending 2020 ($USD)',
		ROUND([2020]/1000,2,2) AS 'Total Spending in Billions ($USD)'
  FROM [Defense Industry Analysis].[dbo].['Constant (2020) USD$']
  ORDER BY [2020] DESC


--	Now to see who's spending the least. Will have to change the rounded column because of how low the numbers are.


SELECT TOP (10) [Country],
		ROUND([2020]*1000000,2,0) AS 'Total Defense Spending 2020 ($USD)',
		[2020] AS 'Total Spending in Millions ($USD)'
  FROM [Defense Industry Analysis].[dbo].['Constant (2020) USD$']
  WHERE [2020] IS NOT NULL 
  ORDER BY [2020] ASC


--	The final metric I want before finishing my anlaysis and heading to the visualization stage is a measure of the
--		countries who spend the most and least on defense in relativity to their overall spending

SELECT TOP (20) [Country],
		ROUND([2020],3)* 100 AS 'Share of Government Spending'
		
  FROM [Defense Industry Analysis].[dbo].['Share of Govt# spending$']
  ORDER BY [2020] DESC



--Now one to see who has the lowest share of Defense spending

SELECT TOP (20) [Country],
		ROUND([2020],3)* 100 AS 'Share of Government Spending'
		
FROM [Defense Industry Analysis].[dbo].['Share of Govt# spending$']
WHERE [2020] IS NOT NULL
ORDER BY [2020] ASC


--	Finally. With that, a number of conclusions can be made about the state of the Defense industry as of 2020. 
--		After exporting these views to Excel sheets, I'll hop into Tableau and make several dashboards to convey the insight gained.

  SELECT COUNT(*) FROM Energy.dbo.Raw_Energy;

-- Data Overview
  SELECT TOP 10 * FROM Energy.dbo.Raw_Energy;


--Missing Values
    SELECT Country, Code 
  FROM Energy.dbo.Raw_Energy 
  WHERE Code = 'No_Value'
  GROUP BY Country, Code
  ORDER BY 1, 2;

  SELECT COUNT(*) AS Missing_Renewables FROM Energy.dbo.Raw_Energy WHERE Primary_Energy_Renewables IS NULL;

-- Duplicate records
  SELECT Country, Year FROM Energy.dbo.Raw_Energy GROUP BY Country, Year HAVING COUNT(*) > 1;

-- Data Distribution 
     SELECT AVG(Primary_Energy_Renewables) AS Avg_Renewables,
     MIN(Primary_Energy_Renewables) AS Min_Renewables,
     MAX(Primary_Energy_Renewables) AS Max_Renewables
     FROM Energy.dbo.Raw_Energy;

	 SELECT Year, AVG(Primary_Energy_Renewables) AS Avg_Renewables
     FROM Energy.dbo.Raw_Energy GROUP BY Year ORDER BY Year;

	 SELECT FLOOR(Year / 10) * 10 AS Decade, 
     AVG(Primary_Energy_Renewables) AS Avg_Renewables
     FROM Energy.dbo.Raw_Energy
     GROUP BY FLOOR(Year / 10) * 10
     ORDER BY Decade;


--Region Analysis

	 SELECT Country, AVG(Primary_Energy_Renewables) AS Avg_Renewables
     FROM Energy.dbo.Raw_Energy
     GROUP BY Country
     ORDER BY Country, Avg_Renewables DESC;

	 -- Top 5 country
	 SELECT TOP 5 Country, AVG(Primary_Energy_Renewables) AS Highest_Avg_Renewables
     FROM Energy.dbo.Raw_Energy
     GROUP BY Country
     ORDER BY Highest_Avg_Renewables DESC;

	 --Bottom 5 country
	 SELECT TOP 5 Country, AVG(Primary_Energy_Renewables) AS Lowest_Avg_Renewables
     FROM Energy.dbo.Raw_Energy
     GROUP BY Country
    ORDER BY Lowest_Avg_Renewables;

     SELECT Country, Year, Primary_Energy_Renewables FROM Energy.dbo.Raw_Energy
     WHERE Primary_Energy_Renewables = (SELECT MAX(Primary_Energy_Renewables) FROM Energy.dbo.Raw_Energy)
     OR Primary_Energy_Renewables = (SELECT MIN(Primary_Energy_Renewables) FROM Energy.dbo.Raw_Energy);

--outliers
	 SELECT * FROM Energy.dbo.Raw_Energy
     WHERE Primary_Energy_Renewables < 0 OR Primary_Energy_Renewables > 100;

--Performance over time
	 --YOY 
	   WITH Yearly_Renewables AS (
         SELECT Year, 
         AVG(Primary_Energy_Renewables) AS Global_Avg_Renewables
         FROM Energy.dbo.Raw_Energy
         GROUP BY Year
)
     SELECT Year,
     Global_Avg_Renewables,
     LAG(Global_Avg_Renewables, 1) OVER (ORDER BY Year) AS Prev_Year_Renewables,
     ((Global_Avg_Renewables - LAG(Global_Avg_Renewables) OVER (ORDER BY Year)) / LAG(Global_Avg_Renewables) OVER (ORDER BY Year)) * 100 AS Growth_Rate
     FROM Yearly_Renewables;

   -- Yearly growth
	SELECT Year, Country, MAX(Primary_Energy_Renewables) AS Max_Renewables
    FROM Energy.dbo.Raw_Energy
    GROUP BY Year, Country
    ORDER BY Year, Max_Renewables DESC;

   --Top 3 Countries per Year:
	    WITH Yearly_Data AS (
         SELECT Year, 
         Country, 
         MAX(Primary_Energy_Renewables) AS Max_Renewables,
         DENSE_RANK() OVER (PARTITION BY Year ORDER BY MAX(Primary_Energy_Renewables) DESC) AS Country_Rank
         FROM Energy.dbo.Raw_Energy
         GROUP BY Year, Country
         HAVING MAX(Primary_Energy_Renewables) > 0
)
    SELECT Year, Country, Max_Renewables, Country_Rank
    FROM Yearly_Data
    WHERE Country_Rank BETWEEN 1 AND 3
    ORDER BY Year, Max_Renewables DESC;

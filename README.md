# RenewableEnergy
Renewable Energy Worldwide Analysis 

## Overview
The primary goal of this project is to analyze global renewable energy adoption trends over time. The analysis focuses on identifying key insights, such as global and regional trends, growth patterns, and outliers, to better understand the progress of renewable energy transition worldwide.

### Data Sources
Renewable_Share_Energy - The primary dataset used for this analysis is "Renewable-share-energy.csv" file, containing detailed information about renewable energy as a percentage of the total energy mix for various countries and regions from 1965 to 2021.

### Tools
  - Python :- Data Extraction and Data Cleaning
  - Microsoft SQL Server Management Studio :- Data Analysis

### Data Extraction

  The dataset was sourced from Kaggle, containing information on renewable energy as a percentage of the total energy mix for various countries and regions from 1965 to 2021.
  - Key columns include:
    - Entity: Country or region name.
    - Code: Three-letter country/region code (e.g., "USA" for the United States).
    - Year: The year for which data is reported.
    - Renewables (% equivalent primary energy): The percentage share of renewable energy in the total energy mix.

### Data Cleaning/ Preparation
1. Data Loading
   - Loaded the dataset 01 renewable-share-energy.csv into a Pandas DataFrame for analysis.
2. Data Inspection
   - Previewed the first five rows of the dataset using df.head() to understand the structure and content.
   - Reviewed the data types of all columns and identified any missing or inconsistent data using df.info().
3. Handling Missing Values
   -  Identified missing values in the Code column and replaced them with the placeholder value 'No_Value' using fillna().
4. Renaming Columns
   - Renamed the following columns for better readability:
     - Entity → Country
     - Renewables (% equivalent primary energy) → Primary_Energy_Renewables
5. Adding New Columns
   - Added a new column Reported_Year to the dataset, which dynamically captures the current year using Python’s datetime library.
6. Data Export to SQL
   - Connected to a Microsoft SQL Server database using SQLAlchemy.
   - Uploaded the cleaned DataFrame to SQL Server into a table named Raw_Energy within the dbo schema.
   - The table was created or replaced in SQL Server using the if_exists='replace' option.
  
### Data Exploration and Analysis (SQL)
   1 - Dataset Overview
  -    Query: Count the total number of records to understand the dataset size - Total records: 5603.
  ``` sql
    SELECT COUNT(*) FROM Energy.dbo.Raw_Energy;
  ```
  - Preview Columns and Missing Values:
    - Displayed the first 10 rows to assess the dataset:
  ``` sql
    SELECT TOP 10 * FROM Energy.dbo.Raw_Energy;
  ```
  - Missing Values in the Code Column:
    - Identified countries with No_Value in the Code field:
  ``` sql
    SELECT Country, Code 
    FROM Energy.dbo.Raw_Energy 
    WHERE Code = 'No_Value'
    GROUP BY Country, Code
    ORDER BY 1, 2;
  ```

 2 - Handling Missing and Duplicate Data
  -    Missing Values in Renewables Column:
       - Counted rows with NULL in Primary_Energy_Renewables:
  ``` sql
    SELECT COUNT(*) AS Missing_Renewables FROM Energy.dbo.Raw_Energy WHERE Primary_Energy_Renewables IS NULL;
  ```
  -    Duplicate Records Check::
       - no duplicate rows for the same region and year:
  ``` sql
    SELECT Country, Year FROM Energy.dbo.Raw_Energy GROUP BY Country, Year HAVING COUNT(*) > 1;
  ```
 3 - Data Distribution and Trend Analysis
  -   Global average, minimum, and maximum for renewable energy shares:
  ``` sql
       SELECT AVG(Primary_Energy_Renewables) AS Avg_Renewables,
       MIN(Primary_Energy_Renewables) AS Min_Renewables,
       MAX(Primary_Energy_Renewables) AS Max_Renewables
       FROM Energy.dbo.Raw_Energy;
```
  -   Analyzed the average global renewable energy percentage year by year:
  ``` sql
       SELECT Year, AVG(Primary_Energy_Renewables) AS Avg_Renewables
       FROM Energy.dbo.Raw_Energy GROUP BY Year ORDER BY Year;
```
  -   Grouped data by decades to observe long-term adoption trends:
  ``` sql
       SELECT FLOOR(Year / 10) * 10 AS Decade, 
       AVG(Primary_Energy_Renewables) AS Avg_Renewables
       FROM Energy.dbo.Raw_Energy
       GROUP BY FLOOR(Year / 10) * 10
       ORDER BY Decade;
```


4 -  Regional Analysis
  -   Rank countries by their average renewable energy share:
  ``` sql
       SELECT Country, AVG(Primary_Energy_Renewables) AS Avg_Renewables
       FROM Energy.dbo.Raw_Energy
       GROUP BY Country
       ORDER BY Country, Avg_Renewables DESC;
```
  -   Top 5 Performers:
  ``` sql
       SELECT TOP 5 Country, AVG(Primary_Energy_Renewables) AS Highest_Avg_Renewables
       FROM Energy.dbo.Raw_Energy
       GROUP BY Country
       ORDER BY Highest_Avg_Renewables DESC;
```
  -   Bottom 5 Performers:
  ``` sql
       SELECT TOP 5 Country, AVG(Primary_Energy_Renewables) AS Lowest_Avg_Renewables
       FROM Energy.dbo.Raw_Energy
       GROUP BY Country
=      ORDER BY Lowest_Avg_Renewables;
```

5 -  Outliers and Extremes
  -   Identifying Outliers:
      -  Detected rows where renewable energy values were outside the valid range (0-100%):
  ``` sql
       SELECT * FROM Energy.dbo.Raw_Energy
       WHERE Primary_Energy_Renewables < 0 OR Primary_Energy_Renewables > 100;
```
  -   Maximum and Minimum Renewable Energy Shares:
  ``` sql
       SELECT Country, Year, Primary_Energy_Renewables FROM Energy.dbo.Raw_Energy
       WHERE Primary_Energy_Renewables = (SELECT MAX(Primary_Energy_Renewables) FROM Energy.dbo.Raw_Energy)
       OR Primary_Energy_Renewables = (SELECT MIN(Primary_Energy_Renewables) FROM Energy.dbo.Raw_Energy);
```

6 -  Year-on-Year Growth
  -   Calculating Growth Rate:
      -  Used the LAG function to calculate year-on-year growth in global renewable energy adoption:
  ``` sql
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

```
 7 -  Top Performers Over Time
  -   Yearly Leaders:
      - Top-performing country by renewable energy share for each year:
  ``` sql
      SELECT Year, Country, MAX(Primary_Energy_Renewables) AS Max_Renewables
      FROM Energy.dbo.Raw_Energy
      GROUP BY Year, Country
      ORDER BY Year, Max_Renewables DESC;
```
 -   Top 3 Countries per Year:
      - DENSE_RANK to rank the top 3 countries for each year::
  ``` sql
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
```
    
    


import pandas as pd
import sqlalchemy as sal
import datetime as dt

df=pd.read_csv('Renewable-share-energy.csv')

#First 5 rows to know data structure
print(df.head())

# datatype of columns
print(df.info())

# replace null values with 'no value'
replace_null= df['Code'].fillna('No_Value',inplace=True)

# rename two columns
df.rename(columns={'Entity': 'Country','Renewables (% equivalent primary energy)': 'Primary_Energy_Renewables'}, inplace=True)

#Adding new column
today = dt.date.today()
df['Reported_Year']=today.year


# # 1- connect to sql server
engine=sal.create_engine('mssql://LAPTOP-ACBFRAS/Energy?driver=ODBC+DRIVER+17+FOR+SQL+SERVER')
connection=engine.connect()
# print(connection)

# # 2- load dataframe to sql server
# # write to schema,name-tablename, if_exists- append to append data or replace to replace table
df.to_sql(name='Raw_Energy',con=engine, if_exists='replace',index=False, schema="dbo")



from sqlalchemy import create_engine
import pandas as pd

server = 'localhost'
port = 1972
namespace = '%SYS'
username = '_SYSTEM'
password = 'SYS'

url = f"iris://{username}:{password}@{server}:{port}/{namespace}"
print(url)
engine = create_engine(url)

# export table to dataframe
df = pd.read_sql_table('consolidator', engine_local, schema="otw_audit")

# print the dataframe
print(df)

##engine_cloud = create_engine('iris://SQLAdmin:mypassword@aws-iscloud.intersystems:1972/USER')
# insert dataframe into table
##df.to_sql('consolidator', engine_cloud, schema="otw_audit" ,if_exists='replace', index=True,
##        dtype={'DayName': types.VARCHAR(50), 'FullDate': types.DATE, 'MonthName': types.VARCHAR(50),
##        'MonthYear': types.INTEGER, 'Year': types.INTEGER})

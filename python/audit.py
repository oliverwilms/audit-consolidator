from sqlalchemy import create_engine, types
import os as os
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
df1 = pd.read_sql_table('consolidator', engine, schema="otw_audit")
df2 = pd.read_sql_table('USERCHANGE', engine, schema="sqluser")

# print the dataframe
print(df2)

cloudserver = os.getenv('ICSHOST')
cloudport = 1972
cloudns = 'USER'
clouduser = 'SQLAdmin'
cloudpw = os.getenv('ICSPASSWORD')

cloudurl = f"iris://{clouduser}:{cloudpw}@{cloudserver}:{cloudport}/{cloudns}"
print(cloudurl)
engine_cloud = create_engine(cloudurl)

# insert dataframe into table
##df.to_sql('consolidator', engine_cloud, schema="otw_audit" ,if_exists='replace', index=True,
##        dtype={'DayName': types.VARCHAR(50), 'FullDate': types.DATE, 'MonthName': types.VARCHAR(50),
##        'MonthYear': types.INTEGER, 'Year': types.INTEGER})
df2.to_sql('USERCHANGE', engine_cloud, schema="otw_audit" ,if_exists='replace', index=True,
        dtype={'AuditIndex': types.INTEGER, 'Description':types.VARCHAR(50), 'Event':types.VARCHAR(50), 'EventData':types.VARCHAR(16384), 
               'OSUsername': types.VARCHAR(50), 'Roles': types.VARCHAR(50), 'SystemID': types.VARCHAR(50),
               'UTCTimeStamp': types.VARCHAR(64), 'Username': types.VARCHAR(50)})

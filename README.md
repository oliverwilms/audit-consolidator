# audit-consolidator

Many thanks to Robert Cemper for his support with bringing this idea to reality.

Many thanks to Dmitry Maslennikov for his support when I struggled to implement using sqlalchemy-iris in this project.

IRIS Audit database logs many events such as login failures for example. It can be configured to log successful logins as well. 

Why is this important? We have a rule to disable a user account if they have not logged in for a certain number of days.

We have IRIS clusters with many IRIS instances. I like to run queries against audit data from ALL IRIS instances and identify user accounts which have not looged into ANY IRIS instance.

I like to export audit data from each IRIS instance and consolidate audit data into ONE database table to run queries against the consolidated audit data.

## Audit Export Task

Command to run Audit Export Task now AND schedule the task to run it daily

%SYS>w ##class(otw.audit.AuditExportTask).RunNow()
1

The Audit Export creates an XML file and stores it in the mgr directory: /usr/irissys/mgr

I created a persistent consolidator class to hold the audit data from ALL my IRIS instances.

## Consolidator Import Task

Command to import all XML files in mgr directory

Do ##class(otw.audit.consolidator).ImportAll()

## Create a SQL View for data related to USERCHANGE events

Do ##class(otw.audit.Util).CreateViewUserChange()

## Copy Audit data to IRIS Cloud SQL deployment using SQLAlchemy-iris
```
export ICSHOST='k8s-a34cb3c6-aa6428f3-181bcb4a5c-1d7a6ab2ab286107.elb.us-east-1.amazonaws.com'
export ICSPASSWORD='Passw0rd123!'
python3 python/audit.py
```
## Online Demo
You can find online demo here - [Management Portal](https://audit-consolidator.demo.community.intersystems.com/csp/sys/UtilHome.csp)

[webterminal](https://audit-consolidator.demo.community.intersystems.com/terminal/)

## Run DDL in IRIS Cloud SQL

A sample DDL file is included in this repo.

## Import SQL

LOAD DATA FROM FILE 'C://InterSystems/IRIS/mgr/audit.CSV'
INTO otw_audit.consolidator1
USING {
 "from":{
    "file":{
     "header":true
   }}}
go

https://portal.sql-contest.isccloud.io/account/login

## Cloud Storage Adapter

https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=ECLOUD_intro

## Cloud Storage API

https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=ECLOUD_api

## Importing SQL Code

https://docs.intersystems.com/iris20223/csp/docbook/Doc.View.cls?KEY=GSQL_import

## Using Embedded SQL

https://docs.intersystems.com/iris20223/csp/docbook/Doc.View.cls?KEY=GSQL_esql

## Write to AWS S3 bucket

https://community.intersystems.com/post/cache-writing-aws-s3-bucket

## AWS S3 Free Tier

As part of the AWS Free Tier, you can get started with Amazon S3 for free. Upon sign-up, new AWS customers receive 5GB of Amazon S3 storage in the S3 Standard storage class; 20,000 GET Requests; 2,000 PUT, COPY, POST, or LIST Requests; and 100 GB of Data Transfer Out each month.

# audit-consolidator

Audit database logs many events such as login failures for example. It cxan be configured to log successful logins as well. 

Why is this important? We have a rule to disable a user account if they ave not logged in for a certain number of days.

## Run Task Now plus Schedule Task to Run Daily

%SYS>w ##class(otw.audit.AuditExportTask).RunNow()
1

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

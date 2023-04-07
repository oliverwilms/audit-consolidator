LOAD DATA FROM FILE 'C://InterSystems/IRIS/mgr/audit.CSV'
INTO otw_audit.consolidator1
USING {
 "from":{
    "file":{
     "header":true
   }}}
go

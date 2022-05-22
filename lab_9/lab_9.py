#!/usr/bin/python3
#-*-coding: utf-8


import psycopg2
import redis
import json


CURS_REDIS = redis.Redis( host='localhost', port=6379, db=0 )

CONN = psycopg2.connect(
                host = 'localhost', dbname = 'market',
                port = 5432, user = 'super', password = '1') 

CURS_POSTGRES = CONN.cursor()

##########################################################################
phone_no = '000010000'

query_postgres = f"select is_verif from client where phone_no ='{phone_no}' "


res = CURS_REDIS.get( phone_no )
print("CURS_REDIS", res)

if res != None :
  res_json = json.loads( res )
  print("res_json", res_json )

else :
  CURS_POSTGRES.execute( query_postgres, )  
  for r in CURS_POSTGRES :
    res = r[0]
  if res != None :
    res_json = json.dumps( res )
    CURS_REDIS.set( phone_no, res_json, ex=100 )
    print("CURS_POSTGRES ",res)
##########################################################################
link = 'https://www.youtube.com/watch?v=nZNd5FjSquk'
query_1 = f"insert into links( address, content ) values('{link}', 'video') returning id ;"
CURS_POSTGRES.execute(query_1,)
for r in CURS_POSTGRES :
  id = r[0]
CURS_REDIS.delete( id )
CURS_REDIS.set( id, link )


link = 'https://www.youtube.com/watch?v=CFzuFNSpycI'
CURS_REDIS.delete( id )
query_2 = f"update links set address = '{link}' WHERE id ='{id}' ; "
CURS_POSTGRES.execute(query_2,)
CURS_REDIS.set( id, link )



CURS_REDIS.delete( id )
query_3 = f"delete from links where id ='{id}' ; "
CURS_POSTGRES.execute(query_3,)
##########################################################################

CONN.commit()
CURS_POSTGRES.close()
CURS_REDIS.close()

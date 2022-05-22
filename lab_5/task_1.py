#!/usr/bin/python3
#-*-coding: utf-8
#postgresql

import psycopg2

CONN = psycopg2.connect(
                host = 'localhost', dbname = 'air_traffic',
                port = 5432, user = 'super', password = '1') 

CURS = CONN.cursor()

##########################################################################

query_0 = '''
  create table if not exists tableName223232 ();
  create table if not exists tableName22323few2();
  create table if not exists qqqqtableName22323few2();
  create table if not exists table212Name22323few2();
'''

CURS.execute(query_0,)

query_0 = '''
  select table_name
      from information_schema.tables
    where
        table_type = 'BASE TABLE'
      and
        table_schema = 'public'
'''

CURS.execute(query_0,)

print("До применения:\n")
for r in CURS :
  print(r)

##########################################################################
  
query_1 = ''' 
  START TRANSACTION ;

  drop function if exists task_1() ;

  create function task_1() returns void as
  $$
  DECLARE
    row record ;
  BEGIN
    FOR row IN 
      select table_name
          from information_schema.tables
        where
            table_type = 'BASE TABLE'
          and
            table_schema = 'public'
          and
            table_name ilike 'tableName%' 
    LOOP
        EXECUTE 'drop table if exists ' || row.table_name || ' cascade ;' ;
        RAISE INFO 'Dropped table: %', row ;
    END LOOP ;
  END ; 
  $$
  language plpgsql
  security definer ;
      
  COMMIT TRANSACTION ;
'''

CURS.execute(query_1,)


query_2 = ''' select task_1() ; '''

CURS.execute(query_2,)

##########################################################################

CURS.execute(query_0,)

print("\n\nПосле применения:\n")
for r in CURS :
  print(r)

CONN.commit()

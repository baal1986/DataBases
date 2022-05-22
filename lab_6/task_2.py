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
   START TRANSACTION ;

  drop function if exists test_1() ;

  create function test_1() returns trigger as
  $$
  DECLARE
  BEGIN
  END ; 
  $$
  language plpgsql
  security definer ;
  
  create trigger check_insert
    before insert ON test1
    for each row 
    execute procedure test_1() ;
    
  create trigger check_update
    before update ON test1
    for each row 
    execute procedure test_1() ;
    
  create trigger check_delete
    before delete ON test1
    for each row 
    execute procedure test_1() ;
  
  COMMIT TRANSACTION ;
'''

CURS.execute(query_0,)

query_0 = '''
  select trigger_name , event_object_table
      from information_schema.triggers
    where 
        event_manipulation = 'UPDATE' 
      or 
        event_manipulation = 'INSERT' 
      or 
        event_manipulation = 'DELETE'
      and 
        trigger_schema = 'public' 
'''

CURS.execute(query_0,)

print("До применения:\n")
for r in CURS :
  print(r)

##########################################################################
  
query_1 = ''' 
  START TRANSACTION ;

    drop function if exists task_2() ;

    create function task_2( OUT counter integer ) returns integer as
    $$
    DECLARE
      row record ;
    BEGIN
      counter := 0 ;
      FOR row IN 
      select trigger_name , event_object_table
          from information_schema.triggers
        where 
            event_manipulation = 'UPDATE' 
          or 
            event_manipulation = 'INSERT' 
          or 
            event_manipulation = 'DELETE'
          or
            event_manipulation = 'TRUNCATE'
          and 
            trigger_schema = 'public' 
            
      LOOP
          EXECUTE 'drop trigger if exists ' || row.trigger_name || ' on ' || row.event_object_table || ' cascade ;' ;
          RAISE INFO 'Dropped trigger: %', row ;
          counter = counter + 1 ;
      END LOOP ;

    END ; 
    $$
    language plpgsql
    security definer ;
      
  COMMIT TRANSACTION ;
'''

CURS.execute(query_1,)


query_2 = ''' select task_2() ; '''

CURS.execute(query_2,)

print("\nБыло удалено: ")
for r in CURS :
  print(r)
  if r[0] == 3 :
    print("\nGOOD")
  else :
    print("BAD")

##########################################################################

CURS.execute(query_0,)

print("\n\nПосле применения:\n")
for r in CURS :
  print(r)

CONN.commit()
CURS.close()
CONN.close()

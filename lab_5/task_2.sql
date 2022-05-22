--postgresql

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

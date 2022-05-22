--postgresql

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

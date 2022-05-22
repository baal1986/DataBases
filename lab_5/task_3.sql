--postgresql

------------------------------------------------------------------------------------
create sequence projects_id_seq ;
create table if not exists projects(
  id        integer     not null primary key default nextval('projects_id_seq') ,
  name      text        not null                                                ,
  start_pr  timestamptz not null                                                ,
  finish_pr timestamptz default null
) ;
alter sequence projects_id_seq owned by projects.id ;
------------------------------------------------------------------------------------

------------------------------------------------------------------------------------

create sequence priority_id_seq ;
create table if not exists priority(
  id    integer not null primary key default nextval('priority_id_seq') ,
  name  text    not null                                                ,
  level integer not null default 2
) ;
alter sequence priority_id_seq owned by priority.id ;
------------------------------------------------------------------------------------

------------------------------------------------------------------------------------
create sequence tasks_id_seq ;
create table if not exists tasks(
 id           integer     not null primary key default nextval('tasks_id_seq') ,
 name         text        not null                                             ,
 rid_priority integer     not null references priority(id)                     ,
 start_tsk    timestamptz not null                                             ,
 finish_tsk   timestamptz default null
) ;
alter sequence tasks_id_seq owned by tasks.id ;
------------------------------------------------------------------------------------

------------------------------------------------------------------------------------
create table if not exists task_in_project(
  rid_project integer not null references projects(id) ,
  rid_task    integer not null references tasks(id)    
) ;
------------------------------------------------------------------------------------



------------------------------------------------------------------------------------
START TRANSACTION ;

drop function if exists task_3() cascade ;

create function task_3() returns trigger as
$$
DECLARE
   row           record          ;
  _priority      integer := 3    ;
  _a             integer         ;
  _b             timestamptz     ; 
  _c             integer         ;
   run_condition boolean = true  ;
BEGIN
  
BEGIN
  IF OLD.finish_pr IS NOT NULL THEN RETURN OLD ; END IF ;
  FOR row IN
    select distinct tp.rid_task 
        from task_in_project as tp
      where tp.rid_project = OLD.id
    
   LOOP
    select into _b, _c t.finish_tsk, t.rid_priority
        from tasks as t
      where t.id = row.rid_task ;
      
    IF _b IS NULL THEN
      select into _a p.level
          from priority as p
        where p.id = _c ;
          
      IF _a >= _priority THEN RETURN OLD ;
      END IF ;
      
    END IF ;
  END LOOP;
  
  RETURN NEW ;
EXCEPTION WHEN others THEN RAISE INFO 'We are have a problem!: %', SQLERRM ; END ;

END ; 
$$
language plpgsql
security definer ;

drop trigger if exists check_update_finish_project on projects ;
create trigger check_update_finish_project
  before update of finish_pr on projects
  for each row 
  execute procedure task_3() ;


COMMIT TRANSACTION ;
------------------------------------------------------------------------------------



------------------------------------------------------------------------------------
--Ex. for testing
insert into projects( name, start_pr, finish_pr )
    values ( 'KZN',  '2019-10-11 10:10:25-07', NULL  ) ,
           ( 'OVB',  '2019-10-11 10:10:25-07', NULL  ) ,
           ( 'KRR',  '2019-10-11 10:10:25-07', NULL  ) ,
           ( 'NUX',  '2019-10-11 10:10:25-07', NULL  ) ,
           ( 'SVX',  '2019-10-11 10:10:25-07', NULL  ) ,
           ( 'AER',  '2019-10-11 10:10:25-07', NULL  ) ;
           
insert into priority( name, level )
 values ( '0',  0 ) ,
        ( '1',  1 ) ,
        ( '2',  2 ) ,
        ( '3',  3 ) ,
        ( '4',  4 ) ,
        ( '5',  5 ) ;
        
insert into tasks( name, rid_priority, start_tsk, finish_tsk )
 values ( '0',  1, '2019-10-11 10:10:25-07', NULL ) ,
        ( '1',  1, '2019-10-11 10:10:25-07', NULL ) ,
        ( '2',  1, '2019-10-11 10:10:25-07', NULL ) ,
        ( '3',  5, '2019-10-11 10:10:25-07', NULL ) ,
        ( '4',  5, '2019-10-11 10:10:25-07', NULL ) ,
        ( '5',  5, '2019-10-11 10:10:25-07', NULL ) ;
        
  
insert into task_in_project( rid_project, rid_task )
 values ( 1, 5 ) ,
        ( 2, 5 ) ,
        ( 1, 2 ) ,
        ( 1, 5 ) ;
------------------------------------------------------------------------------------




------------------------------------------------------------------------------------
--Ex. for testing trigger function

update projects set finish_pr = Now() where id = 1 ;
update projects set start_pr  = Now() where id = 1 ;


insert into task_in_project( rid_project, rid_task )
 values ( 3, 1 ) , 
        ( 3, 1 ) ,
        ( 3, 2 ) ;
 
update projects set finish_pr= Now() where id = 3 ;
 ------------------------------------------------------------------------------------

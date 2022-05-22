-- database: air_traffic

drop database air_traffic ;

create database air_traffic
  with
    owner            =  master_slave
    encoding         = 'UTF-8'
    lc_collate       = 'ru_RU.UTF-8'
    lc_ctype         = 'ru_RU.UTF-8'
    tablespace       =  pg_default
    connection limit =  -1 ;
  
comment on database air_traffic is 'База данных аэропорт на postgresql' ;

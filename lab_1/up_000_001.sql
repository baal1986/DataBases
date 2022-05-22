
-----------------------------------------------------------------------------------
create table if not exists airports (
    airport_code char(3) not null ,  
    airport_name text    not null ,   
    city         text    not null    

) ;

comment on table  airports              is 'Аэропорты'                     ;
comment on column airports.airport_code is 'Код аэропорта'                 ;
comment on column airports.airport_name is 'Название аэропорта'            ;
comment on column airports.city         is 'Город'                         ;
-----------------------------------------------------------------------------------

-----------------------------------------------------------------------------------
create table if not exists flights (
    flight_id           serial        not null ,
    flight_no           char(9)       not null ,
    airline_name        character(25) not null ,
    scheduled_departure timestamptz   not null ,   
    departure_airport   char(3)       not null ,    
    arrival_airport     char(3)       not null ,     
    status              varchar(20)   not null ,    
    aircraft_code       char(3)       not null           

) ;

comment on table  flights                     is 'Рейсы'                       ;
comment on column flights.flight_id           is 'Идентификатор рейса'         ;
comment on column flights.flight_no           is 'Номер рейса'                 ;
comment on column flights.airline_name        is 'Авиаперевозчик'              ;
comment on column flights.scheduled_departure is 'Время прилета по расписанию' ;
comment on column flights.departure_airport   is 'Аэропорт отправления'        ;
comment on column flights.arrival_airport     is 'Аэропорт прибытия'           ;
comment on column flights.status              is 'Статус рейса'                ;
comment on column flights.aircraft_code       is 'Код самолета IATA'           ;
-----------------------------------------------------------------------------------

-----------------------------------------------------------------------------------
create table if not exists aircrafts (
    aircraft_code char(3) not null ,   
    model         text    not null ,    
    range         integer not null     
) ;

comment on table  aircrafts               is 'Самолеты'                          ;
comment on column aircrafts.aircraft_code is 'Код самолета IATA'                 ;
comment on column aircrafts.model         is 'Модель самолета'                   ;
comment on column aircrafts.range         is 'Максимальная дальность полета, км' ;
-----------------------------------------------------------------------------------

-----------------------------------------------------------------------------------
create table if not exists airline (
    airline_code   character(10) not null ,
    airline_name   text          not null 
);

comment on table  airline                 is 'Авиакомпания'           ;
comment on column airline.airline_code    is 'Код Авиакомпании'       ;
comment on column airline.airline_name    is 'Название Авиакомпании'  ;
-----------------------------------------------------------------------------------

--postgresql

-----------------------------------------------------------------------------------
create table if not exists country (
  country_code char(3)     not null primary key ,                                               
  country      varchar(25) not null unique                                              
) ;
-----------------------------------------------------------------------------------

-----------------------------------------------------------------------------------
create sequence cities_id_seq ;

create table if not exists cities (
  id          integer not null primary key default nextval('cities_id_seq') ,
  city        text    not null                                              ,
  rid_country char(3) not null references country(country_code)                                                                                                         
) ;
 
alter sequence cities_id_seq owned by cities.id ;
-----------------------------------------------------------------------------------

-----------------------------------------------------------------------------------
create table if not exists airports (
  airport_code char(3) not null primary key           ,                                                           
  airport_name text    not null                       ,   
  rid_city     integer not null references cities(id)                             
) ;
-----------------------------------------------------------------------------------


-----------------------------------------------------------------------------------
create table if not exists aircrafts (
  aircraft_code char(3) not null primary key      ,                                                          
  model         text    not null                  ,    
  range         integer not null check(range > 0)     
) ;

comment on table  aircrafts               is 'Самолеты'                                   ;
comment on column aircrafts.aircraft_code is 'Код самолета IATA / Идентификатор самолета' ;
comment on column aircrafts.model         is 'Модель самолета'                            ;
comment on column aircrafts.range         is 'Максимальная дальность полета, км'          ;
-----------------------------------------------------------------------------------

-----------------------------------------------------------------------------------
create table if not exists airline (
  airline_code character(10) not null primary key ,
  airline_name text          not null 
) ;
-----------------------------------------------------------------------------------

-----------------------------------------------------------------------------------
create table if not exists flights (
  flight_id             serial        not null primary key                         ,
  flight_no             char(9)       not null                                     ,
  rid_airline_name      character(10) not null references airline(airline_code)    ,                             
  scheduled_departure   timestamptz   not null                                     ,   
  rid_departure_airport char(3)       not null references airports(airport_code)   ,   
  rid_arrival_airport   char(3)       not null references airports(airport_code)   ,                                       
  status                varchar(20)   not null                                     ,    
  rid_aircraft_code     char(3)       not null references aircrafts(aircraft_code)          
) ;

comment on table  flights                       is 'Рейсы'                       ;
comment on column flights.flight_id             is 'Идентификатор рейса'         ;
comment on column flights.flight_no             is 'Номер рейса'                 ;
comment on column flights.rid_airline_name      is 'Авиаперевозчик'              ;
comment on column flights.scheduled_departure   is 'Время прилета по расписанию' ;
comment on column flights.rid_departure_airport is 'Аэропорт отправления'        ;
comment on column flights.rid_arrival_airport   is 'Аэропорт прибытия'           ;
comment on column flights.status                is 'Статус рейса'                ;
comment on column flights.rid_aircraft_code     is 'Код самолета IATA'           ;
-----------------------------------------------------------------------------------

-----------------------------------------------------------------------------------
create sequence boarding_pass_seq ;

create type sex as enum('m', 'f', 'other') ;

create table if not exists boarding_pass (
  boarding_pass_number text        not null primary key default 'DME'||nextval('boarding_pass_seq'::regclass)::text ,
  seat_no              varchar(4)  not null                                                                         , 
  first_name           varchar(50) not null                                                                         ,
  second_name          varchar(50) not null                                                                         ,
  gender               sex         not null     
) ;

alter sequence boarding_pass_seq owned by boarding_pass.boarding_pass_number ;


comment on table  boarding_pass         is 'Пассадочный талон'        ;
comment on column boarding_pass.seat_no is 'Номер места'              ;
comment on column boarding_pass.seat_no is 'Номер пассадочного места' ;
-----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
create table if not exists baggage (
  rid_boarding_pass text        not null primary key references boarding_pass(boarding_pass_number) ,
  quantity          smallint    not null check(quantity >= 0)                                       ,
  weight            real        not null check(weight   >= 0)
) ;

comment on table  baggage          is 'Багаж'                  ;
comment on column baggage.quantity is 'Количество мест багажа' ;
comment on column baggage.weight   is 'Общий вес багажа'       ;
-----------------------------------------------------------------------------------

-----------------------------------------------------------------------------------
create sequence passengers_id_seq ;

create table if not exists passengers (
  id                  integer     not null primary key default nextval('passengers_id_seq')   ,
  document_number     varchar(50) not null                                                    ,
  bithdate            date        not null                                                    ,
  flight_date         date        not null                                                    ,
  rid_flights_number  integer     not null references flights(flight_id)                      ,
  flew_out            boolean     not null default true                                       ,
  rid_boarding_pass   text        not null references boarding_pass(boarding_pass_number)     ,
  rid_baggage         text        not null references baggage(rid_boarding_pass)                             
) ;

alter sequence passengers_id_seq owned by passengers.id ;


comment on table  passengers                    is 'Пассажиры'                                ;
comment on column passengers.rid_flights_number is 'Рейс вылета'                              ;
comment on column passengers.flew_out           is 'Пассажир сел на борт и вылетел'           ;
comment on column passengers.rid_baggage        is 'Багаж'                                    ;
-----------------------------------------------------------------------------------

--postgresql
-- default task ex. default db


-----------------------------------------------------------------------------------------------
--1
  select rid_unit
      from reviews
    where dislike=0 and like_>1000 ;
-----------------------------------------------------------------------------------------------
--2
    select rid_unit 
        from reviews
      where rate_unit between '3' and '5' ;
-----------------------------------------------------------------------------------------------
--3
    select id
        from name
      where name ilike '%онная' ;
-----------------------------------------------------------------------------------------------
--4
  select rid_unit
      from unit_link
    where rid_links in(
        select id
            from links
          where content='video' ) ;
-----------------------------------------------------------------------------------------------
--5
  select rid_unit
      from unit_link
    where exists(
        select 1
            from links
          where content='video' ) ;
-----------------------------------------------------------------------------------------------
--6 
  select rid_unit
      from reviews
    where rate_unit > all(
        select rate_unit
            from reviews
          where rate_unit > 2 ) ;
-----------------------------------------------------------------------------------------------
--7
  select AVG( like ) as average_likes_with_max_rate_for_unit_number_3
      from reviews
    where rate_unit=5 and rid_unit=3 ;
-----------------------------------------------------------------------------------------------
--8
  select 
    ( select count(rid_category) from unit_category where rid_unit=1 ) as unit_1_consist_on ,
    ( select count(rid_category) from unit_category where rid_unit=2 ) as unit_2_consist_on ,
    ( select count(rid_category) from unit_category where rid_unit=3 ) as unit_3_consist_on ,
    ( select count(rid_category) from unit_category where rid_unit=4 ) as unit_4_consist_on ;
-----------------------------------------------------------------------------------------------
--9
  select size ,
      case size when '31' then 'small size'
                when '36' then 'big size' 
      end
    from unit ;
-----------------------------------------------------------------------------------------------
--10
  select color ,
      case  when color='red'   then 'for girls'
            when color='black' then 'for boys'
            when color='green' then 'for boys'
            when color='blue'  then 'for girls'
            else 'unisex'
      end
    from unit ;
-----------------------------------------------------------------------------------------------
--11
  create temp table temp_unit_category as
    select rid_category 
        from unit_category 
      where rid_unit=1 ;
-----------------------------------------------------------------------------------------------
--12
  select u.rid_name as name, 
         u.rid_article as article, 
         u.rid_description as description
      from unit u
        join
          ( select id  from name as n ) sub_n  on u.rid_name=sub_n.id
        join
          ( select id  from article as a ) sub_a  on u.rid_name=sub_a.id ;
-----------------------------------------------------------------------------------------------
--13
  select full_name from full_name where id =
    ( select rid_full_name from question where rid_unit =
      ( select rid_unit from unit_link where rid_links =
        ( select id from links where address = 'https://www.youtube.com/watch?v=go1ldeApiCI' )))
-----------------------------------------------------------------------------------------------
--14
  select rate_unit, COUNT(*) as count_stars
      from reviews
    group by rate_unit ; 
-----------------------------------------------------------------------------------------------
--15
  select rate_unit, COUNT(*) as count_stars
      from reviews
    group by rate_unit
    having COUNT(*) > 0 ;
-----------------------------------------------------------------------------------------------
--16
  insert into client(phone_no, is_verif)
    values( '0123456789', true ) ;
-----------------------------------------------------------------------------------------------
--17
  insert into client(phone_no, is_verif)
    select phone_no, is_verif from client where id=1 ;
-----------------------------------------------------------------------------------------------
--18
  update client set phone_no='9876543210'
    where id=2 ;
-----------------------------------------------------------------------------------------------
--19
  update client set phone_no=
      ( select phone_no from client where id=1 )
    where id=2 ;
-----------------------------------------------------------------------------------------------
--20
  delete from client where id=2 ;
-----------------------------------------------------------------------------------------------
--21
  delete from client where id =
    ( select id  from client where is_verif=true ) ;
-----------------------------------------------------------------------------------------------
--22
  with q1 as(
    select phone_no from client 
  ) 
  select * from q1 ;
-----------------------------------------------------------------------------------------------
--23
--это вычисление чего-то итерациями до выполнения некоторого условия.
--"настоящей" рекурсии в postgresql нет.

--ex:
create table geo(
  id serial int not null primary key , 
  parent_id int references geo(id)   ,  
  name      varchar(50)
) ;

insert into geo (id, parent_id, name) 
values ( 1, null, 'Планета Земля'             ) ,
       ( 2, 1   , 'Континент Евразия'         ) ,
       ( 3, 1   , 'Континент Северная Америка') ,
       ( 4, 2   , 'Европа'                    ) ,
       ( 5, 4   , 'Россия'                    ) ,
       ( 6, 4   , 'Германия'                  ) ,
       ( 7, 5   , 'Москва'                    ) ,
       ( 8, 5   , 'Санкт-Петербург'           ) ,
       ( 9, 6   , 'Берлин'                    ) ;

with recursive r as (
   select id, parent_id, name
      from geo
    where parent_id = 4
  union
   select geo.id, geo.parent_id, geo.name
      from geo
    join r on geo.parent_id = r.id
)
select * from r ;
-----------------------------------------------------------------------------------------------


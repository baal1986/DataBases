--postgresql
-- default task ex.

-----------------------------------------------------------------------------------
create type color as enum( 'red', 'black', 'green', 'blue' ) ;
create type size as enum( '31', '32', '32.5', '36' )         ;
create type weight as enum( '0.5' '1', '1.5', '2' )          ;

create sequence unit_id_seq ;
create table if not exists unit (
	id              integer not null primary key default nextval('unit_id_seq') ,
	rid_name	    integer	not null references name(id)                        ,
	rid_article	    integer	not null references article(id)                     ,
	rid_description integer not null references description(id)                 ,
	color		    color	not null                                            ,
	size		    size	not null                                            ,
	weight		    weight	not null                                                                    
) ;
alter sequence unit_id_seq owned by unit.id ;

create sequence name_id_seq ;
create table if not exists name (
	id   integer 	 not null primary key default nextval('name_id_seq') ,
    name varchar(50) not null                                                                           	
) ;
alter sequence name_id_seq owned by name.id ;

create sequence article_id_seq ;
create table if not exists article (
	id      integer  not null primary key default nextval('article_id_seq') ,
    article char(12) not null unique                                                                           	
) ;
alter sequence article_id_seq owned by article.id ;

create sequence description_id_seq ;
create table if not exists description (
	id          integer not null primary key default nextval('description_id_seq') ,
    description	text    not null                                                                            	
) ;
alter sequence description_id_seq owned by description.id ;
-----------------------------------------------------------------------------------


-----------------------------------------------------------------------------------
create type type_content as enum( 'photo', 'video' ) ;

create sequence links_id_seq ;
create table if not exists links (
	id      integer		 not null primary key default nextval('links_id_seq') ,
	address	text 		 not null                                             , 
	content type_content not null	
) ;
alter sequence links_id_seq owned by links.id ;
----------------------------------------
create table if not exists unit_link (
	id 		  serial  not null primary key          ,
	rid_unit  integer not null references unit(id)  ,
	rid_links integer not null references links(id)                            
) ;
-----------------------------------------------------------------------------------


-----------------------------------------------------------------------------------
create sequence question_id_seq ;
create table if not exists question (
	id            integer     not null primary key default nextval('question_id_seq') ,
	rid_full_name integer     default null references full_name(id)                   ,
	rid_email     integer     default null references email(id)                       ,
	question      text	      not null                                                ,
	rid_unit      integer     not null references unit(id)                                                                                                                  
) ;
alter sequence question_id_seq owned by question.id ;
----------------------------------------
create sequence full_name_id_seq ;
create table if not exists full_name (
	id        integer     not null primary key default nextval('full_name_id_seq') ,
	full_name varchar(50) not null                                                                                                         ,                                          
) ;
alter sequence full_name_id_seq owned by full_name.id ;
----------------------------------------
create sequence email_id_seq ;
create table if not exists email (
	id    integer     not null primary key default nextval('email_id_seq') ,
	email varchar(30) not null                                                                                                         ,                                          
) ;
alter sequence email_id_seq owned by email.id ;
----------------------------------------

START TRANSACTION ;

drop function if exists check_full_name_email() cascade ;
create function check_full_name_email() returns trigger as
$$
DECLARE
BEGIN
  
BEGIN
	IF NEW.rid_full_name IS NOT NULL AND NEW.rid_email IS NOT NULL THEN RETURN NEW ;
	ELSE IF NEW.rid_full_name IS NULL AND NEW.rid_email IS NULL THEN RETURN NEW ; 
	ELSE RETURN OLD ;
	END IF ;
EXCEPTION WHEN others THEN RAISE INFO 'We are have a some problems!: %', SQLERRM ; END ;

END ; 
$$
language plpgsql
security definer ;

drop trigger if exists check_full_name_email_question on question ;
create trigger check_full_name_email_question
  before insert on question
  for each row 
  execute procedure check_full_name_email() ;

COMMIT TRANSACTION ;

----------------------------------------
create sequence admin_answer_id_seq ;
create table if not exists admin_answer (
	id       	 integer not null primary key default nextval('admin_answer_id_seq') ,
	admin_answer text 	 not null                                                                                                      ,                                          
) ;
alter sequence admin_answer_id_seq owned by admin_answer.id ;
----------------------------------------
create table if not exists flood (
	id			 serial  not null primary key                ,
	rid_unit     integer not null references unit(id)        ,
	rid_parent   integer null references admin_answer(id)    ,							  
	rid_answer	 integer unique references admin_answer(id)  ,
	rid_question integer not null references question(id)              
) ;
-----------------------------------------------------------------------------------


-----------------------------------------------------------------------------------
create type raiting as enum( '0', '1', '2', '3', '4', '5' ) ;

create sequence client_id_seq ;
create table if not exists client (
    id       integer     not null primary key default nextval('client_id_seq') ,
	phone_no varchar(10) not null                                              ,
	is_verif boolean 	 default false 
) ;
alter sequence client_id_seq owned by client.id ;
----------------------------------------
create table if not exists reviews (
	rid_unit     integer not null references unit(id)   ,
	rid_client 	 integer not null references client(id) ,
	rate_unit    raiting not null                       ,
	text_reviews text    default null                   ,
	like	     integer not null default 0             ,
	dislike	     integer not null default 0             ,
	
	primary key( rid_unit, rid_client )                 	
) ;
----------------------------------------

START TRANSACTION ;

drop function if exists verification_phone_number() cascade ;
create function verification_phone_number() returns trigger as
$$
DECLARE
BEGIN
  
BEGIN
	IF OLD.is_verif IS TRUE THEN RETURN OLD ;
	ELSE RETURN NEW ;
	END IF ;
EXCEPTION WHEN others THEN RAISE INFO 'We are have a some problems!: %', SQLERRM ; END ;

END ; 
$$
language plpgsql
security definer ;

drop trigger if exists verification_phone_number_client on client ;
create trigger verification_phone_number_client
  before update of is_verif on client
  for each row 
  execute procedure verification_phone_number() ;

COMMIT TRANSACTION ;

----------------------------------------

START TRANSACTION ;

drop function if exists insert_reviews() cascade ;
create function insert_reviews() returns trigger as
$$
DECLARE
	_res boolean ;
BEGIN
  
BEGIN
	_res:= select is_verif
				from client
			where id = NEW.rid_client ;
			
	IF _res IS TRUE THEN RETURN NEW ;
	ELSE RETURN OLD ;
	END IF ;
EXCEPTION WHEN others THEN RAISE INFO 'We are have a some problems!: %', SQLERRM ; END ;

END ; 
$$
language plpgsql
security definer ;

drop trigger if exists insert_reviews_reviews on reviews ;
create trigger insert_reviews_reviews
  before insert on reviews
  for each row 
  execute procedure insert_reviews() ;

COMMIT TRANSACTION ;

-----------------------------------------------------------------------------------


-----------------------------------------------------------------------------------
create sequence category_id_seq ;
create table if not exists category (
    id       integer     not null primary key default nextval('category_id_seq') ,
	name     varchar(30) not null                                              
) ;
alter sequence category_id_seq owned by category.id ;
----------------------------------------
create table if not exists unit_category (
	id 			 serial  not null primary key             ,
    rid_unit 	 integer not null references unit(id)     ,
	rid_category integer not null references category(id)                                              
) ;
-----------------------------------------------------------------------------------

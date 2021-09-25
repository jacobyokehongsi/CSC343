-- Q2. Refunds!

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO air_travel, public;
DROP TABLE IF EXISTS q2 CASCADE;

CREATE TABLE q2 (
    airline CHAR(2),
    name VARCHAR(50),
    year CHAR(4),
    seat_class seat_class,
    refund REAL
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.

DROP VIEW IF EXISTS outbound CASCADE;
DROP VIEW IF EXISTS outbound CASCADE;
DROP VIEW IF EXISTS outbound CASCADE;
DROP VIEW IF EXISTS inbound CASCADE;
DROP VIEW IF EXISTS domestic CASCADE;
DROP VIEW IF EXISTS international CASCADE;
DROP VIEW IF EXISTS domestic_flights_morethan_10 CASCADE;
DROP VIEW IF EXISTS refund_domestic_flights_morethan_10 CASCADE;
DROP VIEW IF EXISTS domestic_flights_morethan_5 CASCADE;
DROP VIEW IF EXISTS international_flights_morethan_12 CASCADE;
DROP VIEW IF EXISTS refund_international_flights_morethan_12 CASCADE;
DROP VIEW IF EXISTS international_flights_morethan_8 CASCADE;
DROP VIEW IF EXISTS refund_international_flights_morethan_8 CASCADE;
DROP VIEW IF EXISTS quickpilots CASCADE;
DROP VIEW IF EXISTS allrefundswithquickpilots CASCADE;
DROP VIEW IF EXISTS allrefundswithoutquickpilots CASCADE;


-- Define views for your intermediate steps here:
create view outbound as
select id, country
from flight, airport
where flight.outbound = airport.code;

create view inbound as
select id, country
from flight, airport
where flight.inbound = airport.code;

create view domestic as
select outbound.id as id
from outbound join inbound on outbound.id = inbound.id
where outbound.country = inbound.country;

create view international as
select outbound.id as id
from outbound join inbound on outbound.id = inbound.id
where outbound.country <> inbound.country;

-- contains data
create view domestic_flights_morethan_10 as
select distinct flight.id, airline.name, airline, 
EXTRACT(YEAR from flight.s_dep) as year
from flight join departure on flight.id = departure.flight_id join domestic on 
flight.id = domestic.id 
join airline on flight.airline = airline.code
where 
(SELECT EXTRACT(epoch FROM departure.datetime - flight.s_dep)/3600 >= 10);

-- only one that has data on
create view refund_domestic_flights_morethan_10 as 
select booking.flight_id as id, name, airline, year, seat_class, sum(price), 
sum(price)*0.5 as refund
from booking join domestic_flights_morethan_10 on 
flight_id = domestic_flights_morethan_10.id
group by booking.id, name, airline, year, seat_class;

create view domestic_flights_morethan_5 as
select distinct flight.id, airline.name, airline, 
EXTRACT(YEAR from flight.s_dep) as year
from flight join departure on flight.id = departure.flight_id join domestic on 
flight.id = domestic.id
join airline on flight.airline = airline.code
where (SELECT EXTRACT(epoch FROM departure.datetime - flight.s_dep)/3600 >= 5) and 
(SELECT EXTRACT(epoch FROM departure.datetime - flight.s_dep)/3600 < 10);

create view refund_domestic_flights_morethan_5 as
select booking.flight_id as id, name, airline, year, seat_class, sum(price), 
sum(price)*0.35 as refund
from booking join domestic_flights_morethan_5 on 
flight_id = domestic_flights_morethan_5.id
group by booking.id, name, airline, year, seat_class;

create view international_flights_morethan_12 as
select distinct flight.id, airline.name, airline, 
EXTRACT(YEAR from flight.s_dep) as year
from flight join departure on flight.id = departure.flight_id join 
international on flight.id = international.id
join airline on flight.airline = airline.code
where 
(SELECT EXTRACT(epoch FROM departure.datetime - flight.s_dep)/3600 >= 12);

create view refund_international_flights_morethan_12 as
select booking.flight_id as id, name, airline, year, seat_class, sum(price), 
sum(price)*0.5 as refund
from booking join international_flights_morethan_12 on 
flight_id = international_flights_morethan_12.id
group by booking.id, name, airline, year, seat_class;

-- 8 and 5 BA
create view international_flights_morethan_8 as
select distinct flight.id, airline.name, airline, 
EXTRACT(YEAR from flight.s_dep) as year
from flight join departure on flight.id = departure.flight_id join 
international on flight.id = international.id
join airline on flight.airline = airline.code
where 
(SELECT EXTRACT(epoch FROM departure.datetime - flight.s_dep)/3600 >= 8) and 
(SELECT EXTRACT(epoch FROM departure.datetime - flight.s_dep)/3600 < 12);

create view refund_international_flights_morethan_8 as
select booking.flight_id as id, name, airline, year, seat_class, sum(price), 
sum(price)*0.35 as refund
from booking join international_flights_morethan_8 on 
flight_id = international_flights_morethan_8.id
group by booking.id, name, airline, year, seat_class;

create view quickpilots as
select distinct flight.id, 
EXTRACT(epoch FROM departure.datetime - flight.s_dep)/3600 as departure_delay, 
EXTRACT(epoch FROM arrival.datetime - flight.s_arv)/3600 as arrival_delay
from flight join departure on flight.id = departure.flight_id join arrival on 
flight.id = arrival.flight_id
where EXTRACT(epoch FROM arrival.datetime - flight.s_arv)/3600 
<= EXTRACT(epoch FROM departure.datetime - flight.s_dep)/3600/2
and EXTRACT(epoch FROM departure.datetime - flight.s_dep)/3600 <> 0
and EXTRACT(epoch FROM arrival.datetime - flight.s_arv)/3600 <> 0;

-- combining all refund data
create view allrefunds as 
select id, airline, name, year, seat_class, refund from 
refund_domestic_flights_morethan_10 union 
select id, airline, name, year, seat_class, refund from 
refund_domestic_flights_morethan_5 union
select id, airline, name, year, seat_class, refund from 
refund_international_flights_morethan_12 union
select id, airline, name, year, seat_class, refund from 
refund_international_flights_morethan_8;

create view allrefundswithquickpilots as 
select id, airline, name, year, seat_class, refund
from allrefunds natural join quickpilots;

create view allrefundswithoutquickpilots as 
select * from allrefunds
except
select * from allrefundswithquickpilots; 


-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q2
select airline, name, year, seat_class, sum(refund)
from allrefundswithoutquickpilots
group by airline, name, year, seat_class;
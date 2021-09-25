-- Q3. North and South Connections

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO air_travel, public;
DROP TABLE IF EXISTS q3 CASCADE;

CREATE TABLE q3 (
    outbound VARCHAR(30),
    inbound VARCHAR(30),
    direct INT,
    one_con INT,
    two_con INT,
    earliest timestamp
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS CanadaUScities CASCADE;
DROP VIEW IF EXISTS CADUSCityCombi CASCADE;
DROP VIEW IF EXISTS OutboundInbound CASCADE;
DROP VIEW IF EXISTS DirectRoutesCities CASCADE;
DROP VIEW IF EXISTS NumDirectRoutes CASCADE;
DROP VIEW IF EXISTS OneConnAirports CASCADE;
DROP VIEW IF EXISTS OneConnCities CASCADE;
DROP VIEW IF EXISTS NumOneConnRoutes CASCADE;
DROP VIEW IF EXISTS TwoConnAirports CASCADE;
DROP VIEW IF EXISTS TwoConnCities CASCADE;
DROP VIEW IF EXISTS NumTwoConnRoutes CASCADE;

-- Define views for your intermediate steps here:
create view CanadaUScities as 
select city, country
from airport
where country = 'Canada' or country = 'USA';

create view CADUSCityCombi as
select distinct c1.city as out_city, c2.city as in_city
from CanadaUScities c1, CanadaUScities c2
where c1.city <> c2.city and c1.country <> c2.country;

create view OutboundInbound as
select outbound, inbound, s_dep, s_arv
from flight
where DATE(s_dep) = '2021-04-30' and DATE(s_arv) = '2021-04-30';

create view DirectRoutesCities as
select OutboundInbound.outbound, a1.city as out_city, OutboundInbound.inbound, 
a2.city as in_city, s_arv as arrival_time
from OutboundInbound
join airport a1 on OutboundInbound.outbound = a1.code 
join airport a2 on OutboundInbound.inbound = a2.code;

create view NumDirectRoutes as 
select cc.out_city, cc.in_city, 
count(cc.out_city = dc.out_city and cc.in_city = dc.in_city) as direct, 
min(dc.arrival_time) as earliest
from CADUSCityCombi cc natural left join DirectRoutesCities dc
group by cc.out_city, cc.in_city;

create view OneConnAirports as 
select oi1.outbound, oi2.inbound, oi1.s_arv, oi2.s_dep, 
oi2.s_arv as arrival_time
from OutboundInbound oi1, OutboundInbound oi2
where oi1.inbound = oi2.outbound and ((oi2.s_dep - oi1.s_arv) >= '00:30:00');

create view OneConnCities as
select OneConnAirports.outbound, a1.city as out_city, OneConnAirports.inbound, 
a2.city as in_city, arrival_time
from OneConnAirports
join airport a1 on OneConnAirports.outbound = a1.code 
join airport a2 on OneConnAirports.inbound = a2.code;

create view NumOneConnRoutes as
select cc.out_city, cc.in_city, 
count(cc.out_city = oc.out_city and cc.in_city = oc.in_city) as one_conn, 
min(oc.arrival_time) as earliest
from CADUSCityCombi cc natural left join OneConnCities oc
group by cc.out_city, cc.in_city;

create view TwoConnAirports as 
select oi1.outbound, oi3.inbound, oi3.s_arv as arrival_time
from OutboundInbound oi1, OutboundInbound oi2, OutboundInbound oi3
where oi1.inbound = oi2.outbound and oi2.inbound = oi3.outbound 
and ((oi2.s_dep - oi1.s_arv) >= '00:30:00') and ((oi3.s_dep - oi2.s_arv) >= '00:30:00');

create view TwoConnCities as
select TwoConnAirports.outbound, a1.city as out_city, TwoConnAirports.inbound, 
a2.city as in_city, arrival_time
from TwoConnAirports
join airport a1 on TwoConnAirports.outbound = a1.code 
join airport a2 on TwoConnAirports.inbound = a2.code;

create view NumTwoConnRoutes as
select cc.out_city, cc.in_city, 
count(cc.out_city = tc.out_city and cc.in_city = tc.in_city) as 
two_conn, min(tc.arrival_time) as earliest
from CADUSCityCombi cc natural left join TwoConnCities tc
group by cc.out_city, cc.in_city;

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q3
select dr.out_city, dr.in_city, direct, one_conn, two_conn,
case 
when (dr.earliest <= oc.earliest or oc.earliest is NULL) and 
(dr.earliest <= tc.earliest or tc.earliest is NULL) then dr.earliest
when (oc.earliest <= dr.earliest or dr.earliest is NULL) and 
(oc.earliest <= tc.earliest or tc.earliest is NULL) then oc.earliest
else tc.earliest
end as earliest
from NumDirectRoutes dr join NumOneConnRoutes oc on 
(dr.out_city = oc.out_city and dr.in_city = oc.in_city) 
join NumTwoConnRoutes tc on (dr.out_city = tc.out_city and dr.in_city = tc.in_city);
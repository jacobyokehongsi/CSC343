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
DROP VIEW IF EXISTS intermediate_step CASCADE;


-- Define views for your intermediate steps here:
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
DROP VIEW IF EXISTS OutAirportsOnDate CASCADE;


-- Define views for your intermediate steps here:

create view CanadaUScities as 
select city, country
from airport
where country = 'Canada' or country = 'USA';

create view CADUSCityCombi as
select distinct c1.city as out_city, c2.city as in_city
from CanadaUScities c1, CanadaUScities c2
where c1.city <> c2.city and c1.country <> c2.country;


create view OutAirportsOnDate as 
select outbound
from flight
where DATE(s_dep) = '2021-04-30';

create view OutCities as
select city
from airport join OutAirportsOnDate on airport.code = OutAirportsOnDate.outbound and 
(airport.country = 'Canada' or airport.country = 'USA');

create view InAirportsOnDate as 
select inbound
from flight
where DATE(s_arv) = '2021-04-30';

create view InCities as
select city
from airport join InAirportsOnDate on airport.code = InAirportsOnDate.inbound and 
(airport.country = 'Canada' or airport.country = 'USA');

-- check with possible routes
create view PossibleRoutesCities as
select distinct OutCities.city as out_city, InCities.city as in_city
from OutCities, InCities
where OutCities.city <> InCities.city;

create view DirectRoutesAirports as
select outbound, inbound
from flight
where DATE(s_dep) = '2021-04-30' and DATE(s_arv) = '2021-04-30';

create view DirectRoutesCities as
select DirectRoutesAirports.outbound, a1.city as out_city, DirectRoutesAirports.inbound, a2.city as in_city
from DirectRoutesAirports
join airport a1 on DirectRoutesAirports.outbound = a1.code 
join airport a2 on DirectRoutesAirports.inbound = a2.code;

create view numdirectroutes as 
select out_city, in_city, count(out_city) as direct
from DirectRoutesCities natural join PossibleRoutesCities
group by out_city, in_city;

create view DirectRoutesAirportsOneConn as 





-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q3

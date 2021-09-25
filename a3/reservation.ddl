-- Reservation Schema.

-- contraints that were enforced:
-- rating has to be a number between 0 and 5, inclusive
-- age has to be a number greater than 0

-- allowed redundancies:
-- redundancies are allowed in the table Booking since there
-- could be the same Skipper using the same Craft on different
-- days

drop schema if exists reservation cascade;
create schema reservation;
set search_path to reservation;

-- A Skipper
CREATE TABLE Skipper (
  sID INT PRIMARY KEY,
  -- The name of the Skipper.
  sName VARCHAR(50) NOT NULL,
  -- The rating of the Skipper.
  rating INT NOT NULL,
  -- The age of the Skipper.
  age INT NOT NULL,
  CHECK(rating >= 0 AND rating <= 5),
  CHECK(age > 0)
);

-- A Craft
CREATE TABLE Craft ( 
  cID INT PRIMARY KEY,
  -- The name of the Craft.
  cName VARCHAR(50) NOT NULL,
  -- The length of the Craft in feet.
  length INT NOT NULL
);

-- A Booking
CREATE TABLE Booking (
  sID INT REFERENCES Skipper,
  cID INT REFERENCES Craft,
  -- The date and time the Craft is reserved for by Skipper.
  day timestamp NOT NULL,
  PRIMARY KEY (sID, cID, day)
);
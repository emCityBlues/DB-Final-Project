# MySQL Final Project - tourist attraction guide with visitor ratings
#
# This file creates, populates, and runs 7 sample proof of concept queries

CREATE SCHEMA IF NOT EXISTS PROJ8DB DEFAULT CHARACTER SET utf8;

USE PROJ8DB;

-- -----------------------------------------------------
-- Table Address
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Address 
(
	addressID			INT 		UNSIGNED 	NOT NULL	AUTO_INCREMENT,
	street 				VARCHAR(45) 			NOT NULL,
	city 				VARCHAR(45) 			NOT NULL,
	state 				VARCHAR(2) 				NOT NULL,
	zip 				VARCHAR(10) 			NOT NULL,
	neighborhood 		VARCHAR(45) 				NULL,
  
	CONSTRAINT	PRIMARY KEY (addressID)
);

-- -----------------------------------------------------
-- Table BizHour
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS BizHour 
(
	bizHourID			INT 		UNSIGNED 	NOT NULL 	AUTO_INCREMENT,
	dayOfWeek	 		SET('Sun','Mon','Tue','Wed','Thur','Fri', 'Sat')	NOT NULL,
	openTime 			TIME 					NOT NULL,
	closeTime 			TIME 					NOT NULL,
  
	CONSTRAINT	PRIMARY KEY (bizHourID)
);

-- -----------------------------------------------------
-- Table Attraction
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Attraction 
(
	attractionID 		INT 		UNSIGNED 	NOT NULL 	AUTO_INCREMENT,
	name 				VARCHAR(45)				NOT NULL,
	description 		VARCHAR(1024)			NOT NULL,
	cost 				DECIMAL(8,2) 			NOT NULL,
	addressID 			INT 		UNSIGNED 	NOT NULL,
	bizHourID 			INT 		UNSIGNED 	NOT NULL,

	CONSTRAINT	PRIMARY KEY (attractionID),
    
    # creating and naming indices since these are created automatically.  
    INDEX IDX_address_addressID_FK (addressID ASC),
	INDEX IDX_bizhour_bizHourID_FK (bizHourID ASC),
	
    CONSTRAINT	address_addressID_FK	FOREIGN KEY (addressID)	REFERENCES Address (addressID),
	CONSTRAINT	bizhour_bizHourID_FK	FOREIGN KEY (bizHourID)	REFERENCES BizHour (bizHourID)
);

-- -----------------------------------------------------
-- Table Category
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Category
(
	categoryID			INT 		UNSIGNED 	NOT NULL 	AUTO_INCREMENT,
	description 		VARCHAR(45) 			NOT NULL,
	note 				VARCHAR(45) 				NULL,
  
	CONSTRAINT	PRIMARY KEY (categoryID)
);

-- -----------------------------------------------------
-- Table Visitor
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Visitor
(
	visitorID			INT 		UNSIGNED 	NOT NULL 	AUTO_INCREMENT,
	username 			VARCHAR(45) 			NOT NULL,
  
	CONSTRAINT	PRIMARY KEY (visitorID)
);

-- -----------------------------------------------------
-- Table StarLevel
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS StarLevel 
(
	starLevelCode 		TINYINT 	UNSIGNED 	NOT NULL,
	description 		VARCHAR(45) 			NOT NULL,
  
	CONSTRAINT	PRIMARY KEY (starLevelCode)
);

-- -----------------------------------------------------
-- Table VisitorComment
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS VisitorComment
(
	visitorCommentID	INT 		UNSIGNED 	NOT NULL 	AUTO_INCREMENT,
	willRecommend		ENUM('Y','N') 			NOT NULL,
	comment				VARCHAR(1024) 				NULL,
	commentDate 	 	TIMESTAMP 				NOT NULL 	DEFAULT CURRENT_TIMESTAMP,
	attractionID 	 	INT 		UNSIGNED 	NOT NULL,
	starLevelCode 	 	TINYINT 	UNSIGNED 	NOT NULL,
	visitorID 		 	INT 		UNSIGNED 	NOT NULL,
  
	CONSTRAINT	PRIMARY KEY (visitorCommentID),
    
    # creating indices and naming them since these are created automatically. 
    INDEX IDX_attraction_attractionID_FK (attractionID ASC),
	INDEX IDX_starLevel_starLevelCode_FK (starLevelCode ASC),
	INDEX IDX_visitor_visitorID_FK (visitorID ASC),
	
    CONSTRAINT attraction_attractionID_FK	FOREIGN KEY (attractionID)	REFERENCES Attraction (attractionID),
	CONSTRAINT starLevel_starLevelCode_FK	FOREIGN KEY (starLevelCode)	REFERENCES StarLevel (starLevelCode),
	CONSTRAINT visitor_visitorID_FK			FOREIGN KEY (visitorID)		REFERENCES Visitor (visitorID)
);


-- -----------------------------------------------------
-- Table AttractionCategory
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS AttractionCategory 
(
	attractionID 		INT 		UNSIGNED 	NOT NULL,
	categoryID 			INT 		UNSIGNED 	NOT NULL,
  
	CONSTRAINT	PRIMARY KEY (attractionID, categoryID),
    
    # creating and naming index since this one is created automatically. 
    INDEX IDX_category_categoryID_FK (categoryID ASC),
	
    CONSTRAINT ac_attraction_attractionID_FK	FOREIGN KEY (attractionID)	REFERENCES Attraction (attractionID),
	CONSTRAINT category_categoryID_FK			FOREIGN KEY (categoryID)	REFERENCES Category (categoryID)
);

-- -----------------------------------------------------
-- View summaryUserRatings
-- -----------------------------------------------------
CREATE OR REPLACE VIEW summaryUserRatings 
AS
	SELECT username, 
		COUNT(*) AS countOfComments, 
		AVG(starLevelCode) AS avgRating
	FROM Visitor
		JOIN VisitorComment USING (visitorID)
	GROUP BY visitorID;

-- -----------------------------------------------------
-- View averageStarsForAttraction
-- -----------------------------------------------------
CREATE OR REPLACE VIEW averageStarsForAttraction 
AS
	SELECT name AS attraction, 
		COUNT(*) AS numOfComments, 
		ROUND(AVG(starLevelCode)) AS averageStars
	FROM Attraction
		JOIN VisitorComment USING (attractionID)
		JOIN StarLevel USING (starLevelCode)
	GROUP BY attractionID;

-- -----------------------------------------------------
-- View categoryTypeForAttractions
-- -----------------------------------------------------
CREATE OR REPLACE VIEW categoryTypeForAttractions
AS
	SELECT name, Category.description
	FROM Attraction
		JOIN AttractionCategory USING (attractionID)
		JOIN Category USING (categoryID)
	ORDER BY attractionID;

-- -----------------------------------------------------
-- View attractionHours
-- -----------------------------------------------------
CREATE OR REPLACE VIEW attractionHours 
AS
	SELECT attractionID, name, dayOfWeek, openTime, closeTime
	FROM Attraction
		JOIN bizHour USING (bizHourID);


-- -----------------------------------------------------
-- begin inserting sample data
-- -----------------------------------------------------

# inserting hours 
INSERT INTO Bizhour VALUES 
('1', 'Mon,Wed,Thur,Sat,Sun', '9:00', '22:30'),
('2', 'Mon,Tue,Thur,Sat,Sun', '10:00', '17:00'),
('3', 'Mon,Tue,Wed,Thur,Sat,Sun', '7:00', '23:00'),
('4', 'Wed,Thur,Fri,Sat,Sun', '10:00', '20:00'),
('5', 'Mon,Wed,Fri,Sat,Sun', '9:30', '17:00'),
('6', 'Tue,Wed,Fri,Sat,Sun', '9:30', '17:30'),
('7', 'Mon,Tue,Wed,Thur,Sat,Sun', '7:00', '20:00'),
('8', 'Mon,Tue,Wed,Sat,Sun', '6:00', '20:00'),
('9', 'Mon,Wed,Thur,Sat,Sun', '12:00', '19:30'),
('10', 'Wed,Fri,Sat,Sun', '17:00', '20:00');

# inserting address
INSERT INTO Address VALUES
('1', '400 Broad St', 'Seattle', 'WA', '98109', 'Queen Anne'),
('2', '325 5th Avenue N', 'Seattle', 'WA', '98109', 'Queen Anne'),
('3', 'Troll Ave N', 'Seattle', 'WA', '98103', 'Fremont'),
('4', '1300 1st Ave', 'Seattle', 'WA', '98101', 'Downtown'),
('5', '2001 Western Ave', 'Seattle', 'WA', '98121', 'Pioneer Square'),
('6', '1483 Alaskan Way', 'Seattle', 'WA', '98101', 'Downtown'),
('7', '2101 N Northlake Way', 'Seattle', 'WA', '98103', 'Wallingford'),
('8', '86 Pike Place', 'Seattle', 'WA', '98101', 'Downtown'),
('9', '508 Maynard Ave S', 'Seattle', 'WA', '98104', 'International District'),
('10', '1247 15th Ave E', 'Seattle', 'WA', '98112', 'Capitol Hill');

# inserting category
INSERT INTO Category VALUES 
('1', 'Sights & Landmarks', ''),
('2', 'Museums', ''),
('3', 'Tours', 'Land and Sea'),
('4', 'Nature & Parks', ''),
('5', 'Outdoor Activities', ''),
('6', 'Zoos & Aquariums', ''),
('7', 'Classes & Workshops', ''),
('8', 'Shopping', ''),
('9', 'Concerts & Shows', ''),
('10', 'Fun & Games', '');

# inserting visitor
INSERT INTO Visitor VALUES
('1', 'petePan123'),
('2', 'mickMouse'),
('3', 'willCoyote2000'),
('4', 'cindyRella4545'),
('5', 'aliceWonder'),
('6', 'eveQueen666'),
('7', 'winPooh88'),
('8', 'tasDevil1999'),
('9', 'pepLePew'),
('10', 'rodRunner1111');

# inserting star level
INSERT INTO StarLevel VALUES
('1', 'nothing worse'),
('2', 'just plain bad'),
('3', 'mediocre'),
('4', 'good'),
('5', 'totally awesome');

# inserting Attraction
INSERT INTO Attraction VALUES
('1', 'Space Needle', 'The Space Needle is an observation tower in Seattle, Washington, a landmark of the Pacific Northwest, ', '23.00', '1', '1'),
('2', 'Museum of Pop Culture', 'MoPOP (earlier called EMP Museum) is a nonprofit museum, dedicated to contemporary popular culture. It was founded by Microsoft co-founder Paul Allen in 2000 as the Experience Music Project.', '25.00', '2', '2'),
('3', 'Fremont Troll', 'The Fremont Troll (also known as The Troll, or the Troll Under the Bridge) is a public sculpture sculpted by four local artists: Steve Badanes, Will Martin, Donna Walter, and Ross Whitehead. The idea of a troll living under a bridge is derived from the Scandinavian (Norwegian) fairytale Three Billy Goats Gruff.', '0', '3', '3'),
('4', 'Seattle Art Museum', 'In addition to the main art museum in Downtown Seattle, SAM maintains two other major facilities: ', '24.95', '4', '4'),
('5', 'Seattle Free Walking Tour', 'Seattle Free Walking Tours was established in 2012, inspired by the adventures and travels of the ', '0', '5', '5'),
('6', 'Seattle Aquarium', 'The Seattle Aquarium is a public aquarium opened in 1977 and located on Pier 59 on the Elliott Bay', '24.50', '6', '6'),
('7', 'Gas Works Park', 'Gas Works Park is a 19.1-acre public park on the site of the former Seattle Gas Light Company ', '0', '7', '7'),
('8', 'Pikes Place Market', 'Pike Place Market is a public market overlooking the Elliott Bay waterfront in Seattle.', '0', '8', '8'),
('9', 'Seattle Pinball Museum', 'The Seattle Pinball Museum was born from a desire to share the games with other local collectors. ', '15.00', '9', '9'),
('10', 'Shakespeare in the Park', 'Seattle Shakespeare Company is the Puget Sound region’s year-round, professional, classical theatre. The outdoor festivals featuring productions of William Shakespeare\'s plays.', '0', '10', '10');

# inserting into linking table for Attracton and Category
INSERT INTO Attractioncategory VALUES 
('1', '1'),
('2', '2'),
('3', '1'),
('4', '2'),
('5', '1'),
('5', '3'),
('6', '6'),
('7', '1'),
('7', '4'),
('8', '1'),
('8', '8'),
('9', '2'),
('9', '10'),
('10', '5'),
('10', '9');

# inserting comments
INSERT INTO Visitorcomment VALUES 
('1', 'Y', 'Space needle has such a pretty view of everything. We went around 4pm -630pm and it was perfect. We got to see the day view, the sunset and the evening views of Seattle. ', '2017-01-03', '1', '5', '1'),
('2', 'Y', 'One of Seattle\'s popular landmark Attractions. The space need is where to come if your new to Seattle. It is beautiful 360 observation deck. If your a king county or Washington resident you get a discount. You must come early because it does get busy and the line gets pretty long.', '2016-02-04', '1', '4', '3'),
('3', 'N', 'Does my review count if I haven\'t actually been up to the observation deck of the Space Needle?  While we opted not go to all the way up to the top - we couldn\'t visit Seattle and not go and see this iconic structure.*  It\'s not my favorite architectural gem but it\'s worth a visit to check out. ', '2014-08-12', '1', '3', '6'),
('4', 'Y', 'Admission prices are $19/pp and they can be purchased ahead of time, at Kiosks outside the Space Needle or online.  You can also purchase tickets from the Chihuly Glass Garden and receive a discount if you visit both... and yes, I highly recommend both!!', '2015-10-28', '1', '4', '10'),
('5', 'N', 'This place is a must go to if you\'re in Seattle. However, ticket prices are quite steep for what you actually get to see. Makes sense since they know that tourists are willing to pay to go up the Space Needle no matter how much it is.', '2000-09-16', '1', '3', '2'),
('6', 'N', ' I was drawn by the soon-to-be-gone Star Trek special exhibit, and that was pretty cool. I\'m glad I went and saw that! The Fantasy/Sci-fi/Horror sections (which seem permanent, or at least long term) are pretty underwhelming. There are definitely some cool things in each, but given the price of admission, it\'s just really not that exciting. ', '2016-11-24', '2', '2', '6'),
('7', 'N', 'While beautiful on the outside, I\'m confused as to how the exhibits mesh with one another. ', '2011-06-08', '2', '3', '4'),
('8', 'Y', 'Lots of interesting and unique things in here. First off, the actual architecture of this place is phenomenal and stunning to look at. I guess it just recently changed, so they\'re not just focused on music anymore, but also on movies and video games!', '2013-02-13', '2', '5', '1'),
('9', 'Y', 'This museum was an awesome choice for a rainy day! I especially loved the exhibits on fantasy, sci-fi and horror. They were really well-constructed, to the point where I want to buy the curator a plate of nachos and figure out how they designed it! If you\'re a Star Wars/Middle Earth/Star Trek/horror buff, that level alone is enough to warrant a visit. ', '2016-12-03', '2', '4', '3'),
('10', 'Y', 'As an MMORPG (at least back in the day) and fantasy enthusiast, seeing a giant monster looming over you is a dream come true! David and Goliath, Gandalf and the Balrog, me and the Fremont Troll. Truly the stuff made of legends!', '2014-05-12', '3', '5', '8'),
('11', 'Y', 'I basically love that this piece is so, very Seattle. Parking in this area is difficult, so I wouldn\'t', '2009-03-02', '3', '4', '2'),
('12', 'Y', 'My friend actually found this place online while we were hanging out at Mislead & Co. since it was a few walks down we\'ve decided to check it out. We actually ended up parking at a small lot where the coffee place was located so we didn\'t have to worry about driving on the narrow streets of Troll Ave. ', '2012-11-04', '3', '4', '9'),
('13', 'Y', 'I can only think of positive things to give the Fremont Troll. In Seattle, you definitely have the coolest, most hipster sights and Attractions; the Troll is another great gem. This place can be visited at any time during the day and there will always be traffic, so be ready to wait with your camera.', '2014-05-10', '3', '5', '4'),
('14', 'Y', 'They have the nicest staffs... Even when I do something naughty, I feel like I\'m treated with respect, well maybe cause they saw me there a lot? ', '2015-10-14', '4', '3', '8'),
('15', 'Y', 'I love SAM, and I\'ve seen some really awesome exhibits here. Most recently, I joined the throng of people at one of the last days of the YSL exhibit which was incredible and definitely one of my favorites to date. ', '2016-11-12', '4', '5', '9'),
('16', 'N', 'This is one of the most pretentious art museums in the country and the middling collection is housed in a building that is more of a recycled Saks Fifth Avenue department store than a proper backdrop for art. ', '2014-08-13', '4', '1', '1'),
('17', 'Y', 'Booked both tours with Jake last Saturday and have to say it was a great intro to Pike Place and the city. Jake has passion for his business and the city, readily sharing that with all participants. ', '2016-06-18', '5', '5', '5'),
('18', 'Y', 'Free Walking Tour is a MUST DO when visiting Seattle. Shawn was our tour guide for both and we found him to be very informative and friendly. He added some humor and interesting facts about Seattle.', '2014-04-18', '5', '5', '3'),
('19', 'Y', 'We loved the Seattle 101 tour! We\'ve done free walking tours in Europe and none compared to Jake\'s in terms of his energy and sense of humor. Do this on your first day in Seattle and you\'ll walk away with a solid, customized list of things to do.', '2015-07-28', '5', '5', '10'),
('20', 'N', 'This place is not bad but I would say its more for little children than adults. They have little kiddy ponds and big cartoon-like signs...definitely more for little children to have fun and place with the animals and creature than for adults. ', '2013-09-25', '6', '2', '4'),
('21', 'N', 'Definitely not a good place if you dislike crowds or clueless parents who frequently stop, armed with their battering ram strollers and luggage sized diaper bags.', '2014-11-15', '6', '3', '2'),
('22', 'Y', 'This one is fairly small in comparison to, say, the Monterey aquarium. But I really liked the emphasis on the educational experience and the accessibility of the exhibits to a wide range of ages and sizes.', '2017-01-06', '6', '4', '5'),
('23', 'Y', 'Gas Works Park is pretty unique. It\'s like a clash of rustic steampunk, with an air of dystopian beauty, enmeshed with good ol\' fashion nature. Tall, rusting pipes, layers upon layers of graffiti, and a bay front view, how can one go wrong!', '2013-06-24', '7', '5', '6'),
('24', 'N', 'Oh Gasworks, my childhood playground, what has happened to you?  Run down, swampy, full of goose poop, and not a place I feel comfortable being in during the bright hours of daylight, the Gasworks of my youth has been replaced by...sadness.', '2015-04-17', '7', '2', '9'),
('25', 'Y', 'After visiting the troll, my family headed over to Gas Works Park. This park used to be the Seattle Gas Light Company coal gasification plant. You can still see the old plant, although it is fenced so you can\'t go in. Pretty interesting to see this at the park where it\'s filled with beautiful green hills and a gorgeous view of the city.', '2012-05-15', '7', '4', '3'),
('26', 'Y', 'It was an awesome place to be really. I found the vendors were very very friendly the produce was very fresh but also quite pricey!!', '2006-12-07', '8', '4', '7'),
('27', 'Y', 'Can\'t visit Seattle without making a stop to Pike Place! Great variety of goods and produce to check out. From dried fruit stands to jams and juices, it was a fun experience walking up and down the market and checking everything out.', '2004-07-12', '8', '5', '2'),
('28', 'Y', 'I like most farmer\'s markets around the globe, even if just to people watch as I pass up buying the beautiful flowers or pricey produce. I especially like the fact that, although this is a tourist Attraction, locals also hang out here to buy stuff, to listen to a street musician.', '2005-03-19', '8', '4', '5'),
('29', 'Y', 'You just have to go and experience it yourself! Fresh fish, flowers, artisanal treats, and jewelry. Right on the water, in downtown, Pike Place is the ultimate Seattle destination. It\'s very crowded on the weekends but there are some fun finds. ', '2007-04-26', '8', '4', '1'),
('30', 'Y', 'The Pinball Museum takes me back to my childhood days of playing Ms Pacman, Dig Dug, pinball, and a bunch of other games in dark and cool arcades. Ah, good times.', '2012-05-06', '9', '5', '7'),
('31', 'Y', 'After paying the entry fee, there is no additional charge to play the machines. Non-alcoholic refreshments and sweets are available. Other than children, everyone pays the same entry fee.', '2014-03-27', '9', '4', '4'),
('32', 'Y', '15 dollars for all you can play pinball. Over 50 machines and an assortment of other games. What is there not to love?', '2015-07-15', '9', '5', '3'),
('33', 'Y', 'All you can eat pinball for one price!?! Who can say no to that, and for just a couple bucks more you can come and go as you please...all day! Very cool concept and you can even get a good bottle of beer served to you. I need to get back soon!', '2016-12-14', '9', '5', '2'),
('34', 'Y', 'This review refers more to the overall experience I had watching Hamlet in Volunteer Park.  The performances were good, the ambience was superb.  You could look over the tree line to the waterfront way down away, by the space needle.  ', '2015-07-28', '10', '4', '9'),
('35', 'Y', 'Great summer time entertainment!  Free Shakespeare in the part - great for families.  Bring dinner, relax and watch some great acting!', '2014-08-19', '10', '5', '5'),
('36', 'Y', 'What can be better than a warm summer evening, your favorite people, a soft blanket, the great outdoors, and William Shakespeare?', '2016-06-17', '10', '4', '1');

# end of inserting sample data

-- -----------------------------------------------------
-- begin sample queries ( 1 - 7 )
-- -----------------------------------------------------

# Query1 - list attractions having a closing time later than 6pm and open on Tuesdays.
#
# CREATE OR REPLACE VIEW attractionHours 
# AS
#	SELECT attractionID, name, dayOfWeek, openTime, closeTime
#	FROM Attraction
#		JOIN bizHour USING (bizHourID);

SELECT * 
FROM attractionHours
WHERE closeTime > '18:00' AND FIND_IN_SET('Tue', dayOfWeek);
    
# Query2 - list attractions in Museum cataegory.
# Query3 - list all categories which Seattle Pinball Museum belongs to. 
#
# CREATE VIEW categoryTypeForAttractions
# AS	
#	SELECT name, Category.description	
#	FROM Attraction		
#		JOIN AttractionCategory USING (attractionID)
#		JOIN Category USING (categoryID)	
#	ORDER BY attractionID;

SELECT * 
	FROM categoryTypeForAttractions
WHERE description = 'Museums';

SELECT * 
	FROM categoryTypeForAttractions
WHERE name = 'Seattle Pinball Museum';

# Query4 - for each attraction, show # of comments and average star ratings.
#
# CREATE VIEW averageStarsForAttraction 
# AS	
#	SELECT name AS attraction, 		   
#		COUNT(*) AS numOfComments, 	
# 		ROUND(AVG(starLevelCode)) AS averageStars	
#	FROM Attraction		
#		JOIN VisitorComment USING (attractionID)		
#		JOIN StarLevel USING (starLevelCode)	
#	GROUP BY attractionID;

SELECT * 
FROM averageStarsForAttraction
ORDER BY averageStars DESC;

# Query5 - show attractions and their hours with star ratings greater than 4.
SELECT name, dayOfWeek, openTime, closeTime
FROM attractionHours    # view  
WHERE name IN
	( SELECT attraction
	  FROM averagestarsforattraction    # vew
	  WHERE averageStars > 4 );	
      
# Query6 - for each visitor, show # of comments they wrote and their average star ratings.
#
# CREATE OR REPLACE VIEW summaryUserRatings 
# AS
#	SELECT username, 
#		COUNT(*) AS countOfComments, 
#		AVG(starLevelCode) AS avgRating
#	FROM Visitor
#		JOIN VisitorComment USING (visitorID)
#	GROUP BY visitorID;

SELECT * 
FROM summaryUserRatings
ORDER BY avgRating DESC;

# Query7 - show attractions and their hours located in Downtown Seattle
SELECT name, dayOfWeek, openTime, closeTime
FROM attractionHours    # view
WHERE attractionID IN
	( SELECT addressID
	  FROM Address
      WHERE neighborhood = 'Downtown');
      
# end of sample queries

# end of project 8
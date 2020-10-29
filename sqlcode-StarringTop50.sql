/* Add new column into the dataset called lexemesStarring */
ALTER TABLE movies
ADD lexemesStarring tsvector;

/* Update the dataset by making lexemesStarring identical to Starring */
UPDATE movies
SET lexemesStarring = to_tsvector(Starring);

/* Query a particular interest on actor Johnny Depp ('Depp') to see related movies */
SELECT url FROM movies
WHERE lexemesStarring @@ to_tsquery('Depp');

                          url                          
-------------------------------------------------------
 donnie-brasco
 alice-through-the-looking-glass
 alice-in-wonderland
 the-astronauts-wife
 benny-joon
 blow
 charlie-and-the-chocolate-factory
 corpse-bride
 dark-shadows
 dead-man
 don-juan-demarco
 edward-scissorhands
 ed-wood
 fear-and-loathing-in-las-vegas
 for-no-good-reason
 from-hell
 into-the-woods
 public-enemies
 lone-ranger
 transcendence
 the-ninth-gate
 once-upon-a-time-in-mexico
 pirates-of-the-caribbean-the-curse-of-the-black-pearl
 pirates-of-the-caribbean-dead-mans-chest
 pirates-of-the-caribbean-at-worlds-end
 pirates-of-the-caribbean-dead-men-tell-no-tales
 rango
 sleepy-hollow
 sweeney-todd-the-demon-barber-of-fleet-street
 the-source
 black-mass
(31 rows)

/* Select the title from a specific movie url and build the recommender system */
UPDATE movies                                                                                     
SET rank = ts_rank(lexemesStarring,plainto_tsquery(
(
SELECT Starring FROM movies WHERE url = 'charlie-and-the-chocolate-factory'
)
));

/* Create a table of movie recommendations based upon the Starring. Movies are ranked in decimals. The higher the number
* the better its rank. The threshold is set very low. Thus, to include many recommendations. 
* The movies are ranked in descending order and has its limit set on 50 movies. */
CREATE TABLE recommendationsBasedOnStarringField2 AS
SELECT url, rank FROM movies WHERE rank > 0.01 ORDER BY rank DESC LIMIT 50;


/* Save the results into a csv file within the working directory */
\copy (SELECT * FROM recommendationsBasedOnStarringField2) to '/home/pi/RSL/StarringTop50.csv' WITH csv;



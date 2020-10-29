/* Add new column into the dataset called lexemesTitle */
ALTER TABLE movies
ADD lexemesTitle tsvector;

/* Update the dataset by making lexemesTitle identical to Title */
UPDATE movies
SET lexemesTitle = to_tsvector(Title);

/* Query a particular interest on 'lord' aka (the lord of the rings) to see related movies */
SELECT url FROM movies
WHERE lexemesTitle @@ to_tsquery('lord') ;

                       url                        
--------------------------------------------------
 the-lord-of-the-rings-the-fellowship-of-the-ring
 lords-of-dogtown
 the-lords-of-salem
 the-lord-of-the-rings-the-return-of-the-king
 the-lord-of-the-rings-the-two-towers
(5 rows)

/* Select the title from a specific movie url and build the recommender system */
test=> UPDATE movies
test-> SET rank = ts_rank(lexemesTitle,plainto_tsquery(
test(> (
test(> SELECT Title FROM movies WHERE url = 'the-lord-of-the-rings-the-fellowship-of-the-ring'
test(> )
test(> ));

/* Create a table of movie recommendations based upon the title. Movies are ranked in decimals. The higher the number
* the better its rank. The threshold is set very low. Thus, to include many recommendations. 
* The movies are ranked in descending order and has its limit set on 50 movies. */
test=> CREATE TABLE recommendationsBasedOnTitleField AS
SELECT url, rank FROM movies WHERE rank > 0.01 ORDER BY rank DESC LIMIT 50;

/* Save the results into a csv file within the working directory */
test=> \copy (SELECT * FROM recommendationsBasedOnTitleField) to '/home/pi/RSL/TitleTop50' WITH csv;




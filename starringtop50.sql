---------------------------
STARRING
---------------------------
/* add new column into the dataset called lexemesStarring 
based on the dataset created previously 'coolmetamovies*/
ALTER TABLE coolmetamovies
ADD lexemesStarring tsvector;

UPDATE coolmetamovies /*update the dataset */
SET lexemesStarring = to_tsvector(Starring); /*Make lexemesStarring identical to Starring */


/* query a particular interest on the Starring Actor 'Depp' to see related movies */
SELECT url from coolmetamovies
WHERE lexemesStarring @@ to_tsquery('Depp');


/* float 4 is already loaded into the dataset on the first go */
/* Finalize the recommender system */
UPDATE coolmetamovies
SET rank = ts_rank(lexemesStarring,plainto_tsquery(
(
SELECT Title FROM coolmetamovies WHERE url = 'charlie-and-the-chocolate-factory'
)
));
/* create a table of 50 recommendations based upon the Starring Actor in Descending rank order.
* The threshold is very low.*/
CREATE table recommendationsbasedonstarrings AS
SELECT url, rank FROM coolmetamovies WHERE rank > 0.0000000000000000000000000001 ORDER BY rank DESC limit 50;

/*copy the results into a csv file within the working directory */
\copy (SELECT * FROM recommendationsBasedOnStarrings) to '/home/pi/RSL/top50Starringrecommendations.csv' WITH csv;

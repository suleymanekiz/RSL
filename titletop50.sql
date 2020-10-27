---------------------------
TITLE
---------------------------
/* add new column into the dataset called lexemesTitle 
based on the dataset created previously 'coolmetamovies*/
ALTER TABLE coolmetamovies
ADD lexemesTitle tsvector;



UPDATE coolmetamovies /*update the dataset */
SET lexemesTitle = to_tsvector(Title); /*Make lexemesTitle identical to Title */


/* query a particular interest on 'godfather' to see related movies */
SELECT url FROM coolmetamovies
WHERE lexemesTitle @@ to_tsquery('godfather');

/* float 4 is already loaded into the dataset on th first go */
/* Finalize the recommender system */
UPDATE coolmetamovies
SET rank = ts_rank(lexemesTitle,plainto_tsquery(
(
SELECT Title FROM coolmetamovies WHERE url = 'the-godfather-part-iii' /* select the Title from a specific movie url */
)
));

/* create a table of 50 recommendations based upon the Title in Descending rank order.
* The threshold is very low.
Output is also low. In total 3 recommendations given.*/
CREATE TABLE recommendationsBAsedOnTitleField AS
SELECT url, rank FROM coolmetamovies WHERE rank > 0.01 ORDER BY rank DESC LIMIT 50;

/*copy the results into a csv file within the working directory */
\copy (SELECT * FROM recommendationsBasedOnTitleField) to '/home/pi/RSL/top50Titlerecommendations.csv' WITH csv;


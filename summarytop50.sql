-----------------------
SUMMARY
-----------------------

/* Here we create a database as prep for the metacritics data and the recommender system. 
* All columns are included
*/
CREATE TABLE coolmetamovies (
url text,
title text,
ReleaseDate text,
Distributor text,
Starring text,
Summary text,
Director text,
Genre text,
Rating text,
Runtime text,
Userscore text,
Metascore text,
coreCounts text
);

/* include the original scraped data from metacritic */
\copy coolmetamovies FROM '/home/pi/RSL/moviesfrommetacritic.csv' delimiter ';' csv header ;

/* checking whether everthing is included together with the favorite movie title of preference */
SELECT * FROM coolmetamovies WHERE url = 'pirates-of-the-caribbean-the-curse-of-the-black-pearl';

/* add new column into the dataset called lexemesSummary */
ALTER TABLE coolmetamovies
ADD lexemesSummary tsvector;
UPDATE coolmetamovies /*update the dataset */
SET lexemesSummary = to_tsvector(Summary); /*Make lexemesSummary identical to Summary */

/* query a particular interest on 'pirates' to see related movies */
SELECT url FROM coolmetamovies
WHERE lexemesSummary @@ to_tsquery('pirate');

/* Finalize the recommender system */
ALTER TABLE coolmetamovies
ADD rank float4;

/* select the Summary from a specific movie url */
Update coolmetamovies
set rank = ts_rank(lexemesSummary,plainto_tsquery(
(
SELECT Summary FROM coolmetamovies WHERE url = 'pirates-of-the-caribbean-the-curse-of-the-black-pearl'
)
));

/* create a table of 50 recommendations based upon the Summary in Descending rank order.
* The threshold is very low */
CREATE TABLE recommendationsBasedOnSummaryField AS
SELECT url, rank FROM coolmetamovies WHERE rank >0.01 ORDER BY rank DESC LIMIT 50;

/*copy the results into a csv file within the working directory */
SELECT * FROM recommendationsBAsedOnSummaryField
\copy (SELECT * FROM recommendationsBasedOnSummaryField) to '/home/pi/RSL/top50recommendations.csv' WITH csv;

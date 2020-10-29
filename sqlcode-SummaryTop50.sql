/* Here we create a table as prep for the metacritics movie data and for creating a recommender system.
* All colums are included */

CREATE TABLE movies (
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
scoreCounts text
);

/* Include the original scraped data from metacritic */
\copy movies FROM '/home/pi/RSL/moviesfrommetacritic.csv' delimiter ';' csv header ;

/* Check whether everything is included together with the favorite movie title of preference */
SELECT * FROM movies WHERE url = 'rocky' ;

/* Add new column into the dataset called lexemesSummary */
ALTER TABLE movies
ADD lexemesSummary tsvector;

/* Update the dataset by making lexemesSummary identical to Summary */
UPDATE movies 
SET lexemesSummary = to_tsvector(Summary); 

/* Query a particular interest on 'rocky' to see related movies */
SELECT url FROM movies
WHERE lexemesSummary @@ to_tsquery('%rocky%'); 

                    url                     
--------------------------------------------
 invincible
 front-cover
 creed
 chuck
 darling-companion
 boyhood
 rocky-iii
 rocky-iv
 kickboxer
 going-the-distance
 happy-christmas
 last-ounce-of-courage
 never-back-down
 rocky
 rocky-ii
 rocky-v
 rocky-balboa
 secrets-lies
 expelled-no-intelligence-allowed
 talladega-nights-the-ballad-of-ricky-bobby
(20 rows)

/* add a single precision floating-point number */
ALTER TABLE movies
ADD rank float4 ;

/* Select the summary from a specific movie url and build the recommender system*/
UPDATE movies
SET rank = ts_rank(lexemesSummary,plainto_tsquery(
(
SELECT Summary FROM movies WHERE url = 'rocky'
)
));

/* Create a table of movie recommendations based upon summaries. Movies are ranked in decimals. The higher the number
* the better its rank. The threshold is set very low. Thus, to include many recommendations. 
* The movies are ranked in descending order and has its limit set on 50 movies. */
CREATE table recommendationsbasedonsummaries AS
select url, rank FROM movies WHERE rank > 0.001 ORDER BY rank DESC LIMIT 50; 

/* Save the results into a csv file within the working directory */
\copy (SELECT * FROM recommendationsbasedonsummaries) to '/home/pi/RSL/SummariesTop50.csv' WITH csv;



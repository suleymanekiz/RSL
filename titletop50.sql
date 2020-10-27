
----------------------
TITLE
----------------------

ALTER TABLE coolmetamovies
ADD lexemesTitle tsvector;



UPDATE coolmetamovies
SET lexemesTitle = to_tsvector(Title);



SELECT url FROM coolmetamovies
WHERE lexemesTitle @@ to_tsquery('godfather');


UPDATE coolmetamovies
SET rank = ts_rank(lexemesTitle,plainto_tsquery(
(
SELECT Title FROM coolmetamovies WHERE url = 'the-godfather-part-iii'
)
));


CREATE TABLE recommendationsBAsedOnTitleField AS
SELECT url, rank FROM coolmetamovies WHERE rank > 0.01 ORDER BY rank DESC LIMIT 50;


\copy (SELECT * FROM recommendationsBasedOnTitleField) to '/home/pi/RSL/top50Titlerecommendations.csv' WITH csv;

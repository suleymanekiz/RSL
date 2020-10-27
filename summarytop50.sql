-----------------------
SUMMARY
-----------------------

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


\copy coolmetamovies FROM '/home/pi/RSL/moviesfrommetacritic.csv' delimiter ';' csv header ;

SELECT * FROM coolmetamovies WHERE url = 'pirates-of-the-caribbean-the-curse-of-the-black-pearl';
ALTER TABLE coolmetamovies
ADD lexemesSummary tsvector;




UPDATE coolmetamovies
SET lexemesSummary = to_tsvector(Summary);


SELECT url FROM coolmetamovies
WHERE lexemesSummary @@ to_tsquery('pirate');

ALTER TABLE coolmetamovies
ADD rank float4;

Update coolmetamovies
set rank = ts_rank(lexemesSummary,plainto_tsquery(
(
SELECT Summary FROM coolmetamovies WHERE url = 'pirates-of-the-caribbean-the-curse-of-the-black-pearl'
)
));


CREATE TABLE recommendationsBasedOnSummaryField AS
SELECT url, rank FROM coolmetamovies WHERE rank >0.01 ORDER BY rank DESC LIMIT 50;

SELECT * FROM recommendationsBAsedOnSummaryField
\copy (SELECT * FROM recommendationsBasedOnSummaryField) to '/home/pi/RSL/top50recommendations.csv' WITH csv;

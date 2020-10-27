---------------------------
STARRING
---------------------------

ALTER TABLE coolmetamovies
ADD lexemesStarring tsvector;

UPDATE coolmetamovies
SET lexemesStarring = to_tsvector(Starring);



SELECT url from coolmetamovies
WHERE lexemesStarring @@ to_tsquery('Depp');



UPDATE coolmetamovies
SET rank = ts_rank(lexemesStarring,plainto_tsquery(
(
SELECT Title FROM coolmetamovies WHERE url = 'charlie-and-the-chocolate-factory'
)
));

CREATE table recommendationsbasedonstarrings AS
SELECT url, rank FROM coolmetamovies WHERE rank > 0.0000000000000000000000000001 ORDER BY rank DESC limit 50;

\copy (SELECT * FROM recommendationsBasedOnStarrings) to '/home/pi/RSL/top50Starringrecommendations.csv' WITH csv

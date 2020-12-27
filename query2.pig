DEFINE CSVExcelStorage org.apache.pig.piggybank.storage.CSVExcelStorage;

ratings_raw = LOAD 'gs://ca40220-movielens-data/data_raw/ratings.csv' USING CSVExcelStorage() AS (userId: int, movieId: int, rating: float, timestamp: int);
grouped_movies = GROUP ratings_raw BY movieId;

avg_ratings = FOREACH grouped_movies GENERATE group AS movieId, AVG($1.$2) AS ratings_avg;

five_star = FILTER ratings_raw BY (rating == 5.0) OR (rating == 4.5);
five_grouped = GROUP five_star BY movieId;
five_counts = FOREACH five_grouped GENERATE group AS movieId, COUNT($1.$2) AS five_star_counts;

four_star = FILTER ratings_raw BY rating == 4.0;
four_grouped = GROUP four_star BY movieId;
four_counts = FOREACH four_grouped GENERATE group AS movieId, COUNT($1.$2) AS four_star_counts;

best_movies = JOIN avg_ratings BY movieId, five_counts BY movieId, four_counts BY movieId;
final = FOREACH best_movies GENERATE $0 AS movieId, $1 AS ratings_avg, $3 AS five_star_count, $5 AS four_star_count;
sorted = ORDER final BY five_star_count DESC;
out = LIMIT sorted 20;
DUMP out;
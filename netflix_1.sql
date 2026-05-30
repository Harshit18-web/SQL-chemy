#use netflix ;
select * from netflix.titles ;

# 1. Count the number of Movies vs TV Shows
select 
type,
count(type) as total
from titles
group by type ;

# 2.Find the most common rating for movies and TV shows
/*select
type,
rating,
count(rating)
from titles 
group by rating,type ;*/

# 3. List all movies released in a specific year (e.g., 2020)
select
title ,
release_year
from titles 
where release_year = 2020 ;

# 4. Find the top 5 countries with the most content on Netflix
select 
country,
count(country) as freq
from titles
where country is not null
group by country 
order by freq desc 
limit 5 ;

# 5. Identify the longest movie - 
SELECT *
FROM titles
WHERE type = 'Movie'
ORDER BY CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) DESC;

# 6. Find content added in the last 5 years
SELECT *
FROM titles
WHERE release_year >=YEAR(CURDATE()) - 5;

# 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT *
FROM titles
WHERE director LIKE '%Rajiv Chilaka%';

# 8. List all TV shows with more than 5 seasons
select *
from titles 
where duration like '%Seasons%' AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) >= 5 ;

# 9. Count the number of content items in each genre

select 
SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', 1),',',-1) AS genre_1,
count(*) as number_of_content
FROM titles
group by genre_1
order by number_of_content desc ;

# 10.Find each year and the average numbers of content release in India on netflix.
# return top 5 year with highest avg content release!

# 11. List all movies that are documentaries
select *
from titles 
where substring_index(substring_index(listed_in,',',1),',',-1) LIKE '%Documentaries%';

select *
from titles 
where listed_in like '%Documentaries%' ;

# 12. Find all content without a director
select *
from titles 
where director is null ;

# 13. Find how many movies actor 'Salman Khan' appeared in last 10 years
SELECT * FROM titles
WHERE cast LIKE '%Salman Khan%' AND release_year > year(curdate()) - 10;
	

# 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

# 15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
# the description field. Label content containing these keywords as 'Bad' and all other 
 # content as 'Good'. Count how many items fall into each category.
 


-- Netflix Project

drop table if exists netflix;

CREATE TABLE netflix
(
	show_id 	VARCHAR(6),
	type 	VARCHAR(10),
	title 	VARCHAR(150),
	director 	VARCHAR(250),
	casts	 VARCHAR(1000),
	country 	VARCHAR(150),
	date_added 	VARCHAR(50),
	release_year 	INT,
	rating	VARCHAR(10),
	duration	VARCHAR(10),
	listed_in	VARCHAR(100),
	description	VARCHAR(250)
);

select * from netflix;

select
	count(*) as total_count
from netflix;

select
	distinct type
from netflix;


-- 15 Business Problems

-- 1. Count the number of Movies vs TV Shows

select 
	type,
	count(*) as total_content
from netflix
group by type;

-- 2. Find the most common rating for movies and TV shows

select 
	type,
	rating
from 
	(
		select 
			type, 
			rating,
			count(*),
			rank() over(partition by type order by count(*) desc) ranking
		from netflix
		group by 1, 2
	) as t1
where ranking = 1;

-- 3. List all movies released in a specific year (e.g., 2020)

select * from netflix
where
	type = 'Movie'
	and
	release_year = 2020;

-- 4. Find the top 5 countries with the most content on Netflix

select 
	unnest(string_to_array(country, ', ')) as new_country,				-- string_to_array = splits two character with given argument.
	count(*)															-- unnest = take the string out from the {} bracket. 
from netflix
group by 1
order by 2 desc
limit 5;

-- 5. Identify the longest movie

-- Method 1:
select 
	title, 
	max(cast(SUBSTRING(duration, 1, POSITION(' ' in duration)-1) as int)) as max_length		-- Position(' ' in duration) = indicates space position.
from netflix
where type = 'Movie' and duration is not null
group by 1
order by 2 desc;

-- Method 2:
select * from 
 (select distinct title as movie,
  split_part(duration,' ',1):: numeric as duration 				-- split_part(duration,' ',1):: numeric = Split the char before space and 
  from netflix																									-- convert into numeric.
  where type ='Movie') as subquery														-- 1 represents the first part.
where duration = (select max(split_part(duration,' ',1):: numeric ) from netflix);

-- 6. Find content added in the last 5 years

select
	*																				-- to_date / current_date / interval '5 years'
from netflix
where
	to_date(date_added, 'month dd, yyyy') >= current_date - interval'5 years';


-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

select *
from netflix
where director ilike '%Rajiv Chilaka%';				-- like = case sensitive / ilike = case insensitive.


-- 8. List all TV shows with more than 5 seasons.

select *
from netflix
where type = 'TV Show'
and 
split_part(duration, ' ', 1):: numeric > 5

-- 9. Count the number of content items in each genre

select 
	unnest(string_to_array(listed_in, ', ')) as genre,
	count(show_id)
from netflix
group by 1;

/* 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release! */

select
	extract(year from to_date(date_added, 'month dd, yyyy')) as year,
	count(*),
	round(count(*):: numeric/(select count(*)
				from netflix
				where country ilike '%India%'):: numeric * 100, 2) as avg_content_per_year
from netflix
where country ilike '%India%'
group by 1;

-- 11. List all movies that are documentaries.

select *
from netflix
where listed_in like '%Documentaries%'

-- 12. Find all content without a director

select * 
from netflix
where director is null;

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

select *
from netflix
where type = 'Movie' and casts like '%Salman Khan%'
and release_year > extract(year from current_date) - 10;

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

select 
	unnest(string_to_array(casts, ', ')) as actors,
	count(*) as total_movies
from netflix
where country ilike '%india%'
group by 1
order by count(*) desc
limit 10

/* 15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category. */

with new_table as (
					select 
							*,
							case
								when 
									description like '%kill%' or 
									description like '%violence%' then 'Bad'
									else 'Good'
							end  category
					from netflix
					)
select 
	category,
	count(*)
from new_table
group by 1;
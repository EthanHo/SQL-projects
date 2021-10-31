-- VERIFYING FUNCTIONAL DEPENDENCY
--  Restaurant ->rank, score
select case
when answer.count = 0 then 'True'
else 'False'
end as 'Functional Dependency'
from 
(select COUNT(*) as count from tripadvisor t1, tripadvisor t2
where t1.Restaurant=t2.Restaurant 
and (t1.Rank!=t2.Rank or t1.Score!=t2.Score)) answer;


--  Rank-> restaurant, score
select case
when answer.count = 0 then 'True'
else 'False'
end as 'Functional Dependency'
from 
(select COUNT(*) as count from tripadvisor t1, tripadvisor t2
where t1.rank=t2.rank 
and (t1.restaurant!=t2.restaurant or t1.Score!=t2.Score)) answer;

-- User "0" is ruining the data and needs to be deleted
CREATE TABLE new_tripadvisor
  AS (select distinct * from tripadvisor where user_name!= '0');
  
-- Restaurant, review_date, user_name -> review_stars, user_reviews, user_restaurant_reviews, user_helpful_votes
select case
when answer.count = 0 then 'True'
else 'False'
end as 'Functional Dependency'
from 
(select COUNT(*) as count from new_tripadvisor t1, new_tripadvisor t2
where (t1.Restaurant=t2.Restaurant and t1.review_date=t2.review_date and t1.user_name=t2.user_name
and (t1.review_stars!=t2.review_stars 
or t1.user_reviews!=t2.user_reviews 
or t1.user_restaurant_reviews!=t2.user_restaurant_reviews 
or t1.user_helpful_votes!=t2.user_helpful_votes))) answer;




-- TripAdvisor is not in the BCNF. The first functional dependency I've identified, shows that Restaurant ->rank, score and not the whole table, thus it's not a superkey, which violates BCNF.

-- CREATE TABLE STATEMENTS BELOW
-- populated subtable which is "normalized"
CREATE TABLE BCNFrestaurants as
select distinct x.Restaurant, x.Rank, x.Score from new_tripadvisor x;

-- populated subtable which is "normalized"
CREATE TABLE BCNFreviews as
select distinct x.Restaurant, X.Review_Date, X.User_Name, X.User_Reviews, X.User_Restaurant_Reviews, X.User_Helpful_Votes from new_tripadvisor x;



-- verifies lossless join since they both have same # of tuples 
select count(*)
from new_tripadvisor;
-- 6353 tuples 
select count(*)
from BCNFrestaurants x left join BCNFreviews y on x.Restaurant = y.Restaurant;
-- 6353 tuples 


-- #1
select beer 
from Sells
where bar = 'Gecko Grill' and beer != 'Hefeweizen';

-- #2
select distinct drinker 
from Likes, (select beer from Likes where drinker = 'Justin') J
where Likes.beer = J.beer
AND NOT drinker = 'Justin';

-- #3
select distinct l.drinker, s.bar
from Likes l, Frequents f, Sells s
where l.beer = s.beer and f.bar = s.bar and f.drinker = l.drinker;

-- #4
select f.bar
from Frequents f
where drinker = 'Justin' and not exists ((select * from Frequents R where drinker = 'Rebecca' and f.bar = R.bar)) or
 (drinker ='Rebecca' and not exists (select * from Frequents R where drinker = 'Justin' and f.bar = R.bar));


-- #5
select distinct l.drinker
from Likes l, Frequents f, Sells s
where l.beer = s.beer and f.bar = s.bar and f.drinker = l.drinker;

-- #6
select distinct bar
from Sells
where beer IN (select beer from Likes where drinker = 'John' or drinker = 'Rebecca') and price < 5;

-- #7
select H.drinker
from (select * from Likes where beer = 'Hefeweizen') H,
(select * from Likes where beer = "Killian's") K
where H.drinker = K.drinker;

-- #8
select name
from Bars
where name LIKE '%The%';

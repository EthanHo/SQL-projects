-- #1
select distinct name 
from Beers 
where Beers.name NOT in (select beer from Sells where bar='Gecko Grill');

-- #2
select distinct drinker 
from Likes L 
right join (select beer from Likes where Likes.drinker = 'Justin')JustinLikes on JustinLikes.beer=L.beer
group by drinker
Having count(L.beer) = count(JustinLikes.beer);

-- #3
select distinct x.drinker, x.bar
from Frequents x
where not exists (select * from Sells y, Likes z
where x.bar =y.bar
and y.beer =z.beer
and z.drinker=x.drinker);

-- #4 
select s.name
from Bars s 
where s.name not in (select f.bar 
from Frequents f 
where f.drinker = 'Justin' or f.drinker = 'Rebecca');


-- #5
select distinct x.drinker from Frequents x where x.drinker not in (select distinct x.drinker
from Frequents x
where not exists (select * from Sells y, Likes z
where x.bar =y.bar
and y.beer =z.beer
and z.drinker=x.drinker));

-- #6
select distinct b.bar
from Sells b
where not exists (select price from Sells s 
where b.bar=s.bar 
and price < 5);

-- #7
select bar
from (select bar,  avg(price) as priceavg
from Sells
group by bar) as maxpriceavg
where priceavg = 
(select max(priceavg) 
from (select bar,  avg(price) as priceavg
from Sells
group by bar) as maxpriceavg);



-- #8

select bar
from (select bar,  avg(price) as priceavg
from Sells group by bar order by priceavg desc) as maxpriceavg;

-- #9
select name
from Bars
where name LIKE '% %';

-- #10
select d.drinker from
(select l.drinker, count(l.drinker) as more
from Likes l group by l.drinker) d
where 0 = (select count(drinker)
from (select n.drinker, count(n.drinker) as most
from Likes n group by n.drinker) m
where m.most > d.more);

-- #11
select beer
from (select beer,  avg(price) as priceavg
from Sells group by beer order by priceavg desc) as maxpriceavg
limit 1;

-- #12 
select d.bar from
(select l.bar, l.price as highAvg
from Sells l where l.beer = "Budweiser") d
where 0 = (select count(bar)
from (select f.bar, f.price as highestAvg
from Sells f where f.beer = "Budweiser") m
where m.highestAvg < d.highAvg);

-- #13
select x.drinker 
from Frequents x
left join (select x.drinker from Frequents x 
left join Sells s on x.bar = s.bar
where s.beer = 'Budweiser') as NB on x.drinker= NB.drinker
where NB.drinker is null;



-- #14
select x.name from Beers x
left join (select b.beer from Frequents y 
left join Sells b on y.bar = b.bar where y.drinker = 'Mike') 
as z on x.name = z.Beer
where z.beer is null;


-- #15
select distinct 'No' as 'yesORno'  from Likes where NOT EXISTS
(select x.beer from 
(select b.beer, count(beer) as c from Likes b group by beer) x
where c = (select count(name) from Drinkers sip))
union
select distinct 'Yes' as 'yesORno'  from Likes where EXISTS
(select x.beer from 
(select b.beer, count(beer) as c from Likes b group by beer) x
where c = (select count(name) from Drinkers sip));

-- #16
select 'No such a beer exists' as beer from Sells where NOT EXISTS
(select b.beer from
(select x.beer, count(beer) as c from Likes x group by beer) b
where c = (select count(name) from Drinkers sip))
union
select distinct beer from Sells where EXISTS
(select b.beer from
(select x.beer, count(beer) as c from Likes x group by beer) b
where c = (select count(name) from Drinkers sip));
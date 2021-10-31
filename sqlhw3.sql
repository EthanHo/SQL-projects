-- #1
select Timestamp
from testDB.penna
group by Timestamp
Having sum(Biden)>sum(Trump)+100000
order by Timestamp asc
limit 1;

-- #2
select min(Timestamp), precinct 
from testDB.penna
where totalpennavotes>0
group by precinct
Having min(Timestamp)= (select min(Timestamp)
from testDB.penna
where totalvotes>0);

-- #3
select precinct 
from (select precinct, (abs(max(Biden)-max(Trump))) as finalDiff
from testDB.penna 
group by precinct
Having finalDiff
=(select min(finalDiff) from
(select precinct, (abs(max(Biden)-max(Trump))) as finalDiff
from testDB.penna 
group by precinct) as finished)) as BIGQUERY;

-- #4
select Timestamp 
from (select Timestamp, (abs(sum(Biden)-sum(Trump))) as finalDiff
from testDB.penna 
group by Timestamp
Having finalDiff
=(select max(finalDiff) from 
(select Timestamp, (abs(sum(Biden)-sum(Trump))) as finalDiff
from testDB.penna 
group by Timestamp) as finished)) as BIGQUERY;

-- #5
select Timestamp, totalTrump, totalBiden
from (select Timestamp, (sum(Trump)-sum(Biden)) as finalDiff, sum(Trump) as totalTrump, sum(Biden) as totalBiden
from testDB.penna 
group by Timestamp
Having finalDiff
=(select finalDiff from 
(select Timestamp, (sum(Trump)-sum(Biden)) as finalDiff
from testDB.penna 
group by Timestamp
Having finalDiff>0) as finished)) as BIGQUERY
where Timestamp > '05-11-2020 00:00:00';

-- #6

select 'Township' as precinctType, 
CASE
	WHEN (ultimatesum.totalTrump > ultimatesum.totalBiden) THEN 'Trump'
    WHEN (ultimatesum.totalTrump < ultimatesum.totalBiden) THEN 'Biden'
    ELSE 'TIE'
END AS Winner, totalBiden, totalTrump
from (select sum(mt) as totalTrump, sum(mb) as totalBiden
from (select precinct, max(Trump) as mt, max(Biden) as mb
from testDB.penna 
where precinct LIKE '%Township%'
group by precinct) as sumthis) as ultimatesum
UNION
select 'Borough' as precinctType, 
CASE
	WHEN (ultimatesum.totalTrump > ultimatesum.totalBiden) THEN 'Trump'
    WHEN (ultimatesum.totalTrump < ultimatesum.totalBiden) THEN 'Biden'
    ELSE 'TIE'
END AS Winner, totalBiden, totalTrump
from (select sum(mt) as totalTrump, sum(mb) as totalBiden
from (select precinct, max(Trump) as mt, max(Biden) as mb
from testDB.penna 
where precinct LIKE '%Borough%'
group by precinct) as sumthis) as ultimatesum
UNION 
select 'Ward' as precinctType, 
CASE
	WHEN (ultimatesum.totalTrump > ultimatesum.totalBiden) THEN 'Trump'
    WHEN (ultimatesum.totalTrump < ultimatesum.totalBiden) THEN 'Biden'
    ELSE 'TIE'
END AS Winner, totalBiden, totalTrump
from (select sum(mt) as totalTrump, sum(mb) as totalBiden
from (select precinct, max(Trump) as mt, max(Biden) as mb
from testDB.penna 
where precinct LIKE '%Ward%'
group by precinct) as sumthis) as ultimatesum;



-- #7
select 'Final Election' as Category,
CASE
	WHEN (ultimatesum.totalTrump > ultimatesum.totalBiden) THEN 'Trump'
    WHEN (ultimatesum.totalTrump < ultimatesum.totalBiden) THEN 'Biden'
    else 'TIE'
END AS winner,
CASE
	WHEN (ultimatesum.totalTrump > ultimatesum.totalBiden) THEN ultimatesum.totalTrump
    WHEN (ultimatesum.totalTrump < ultimatesum.totalBiden) THEN ultimatesum.totalBiden
    else ultimatesum.totalTrump
END AS numberOfTotalVotes  
    from
(select sum(mt) as totalTrump, sum(mb) as totalBiden
from (select precinct, max(Trump) as mt, max(Biden) as mb
from testDB.penna 
group by precinct) as sumthis) as ultimatesum

union

select 'Day 1' as Category,
CASE
	WHEN (TrumpOrBiden.TrumpFirstDay > TrumpOrBiden.BidenFirstDay) THEN 'Trump'
    WHEN (TrumpOrBiden.TrumpFirstDay < TrumpOrBiden.BidenFirstDay) THEN 'Biden'
    else 'TIE'
END AS winner,
CASE
	WHEN (TrumpOrBiden.TrumpFirstDay > TrumpOrBiden.BidenFirstDay) THEN TrumpFirstDay
    WHEN (TrumpOrBiden.TrumpFirstDay < TrumpOrBiden.BidenFirstDay) THEN BidenFirstDay
    WHEN (TrumpOrBiden.TrumpFirstDay = 0 && TrumpOrBiden.BidenFirstDay =0 ) THEN '0'
    
END AS numberOfTotalVotes  
    from
(select firstDay, sum(mt) as TrumpFirstDay, sum(mb) as BidenFirstDay, sum(TV) as TotalFirstDay
from 
(select Date(Timestamp) firstDay, precinct, max(Trump) as mt, max(Biden) as mb, max(totalvotes) as TV
from testDB.penna
group by Date(Timestamp), precinct) as innerTable
group by firstDay
order by firstDay asc
limit 1) as TrumpOrBiden

union 

select 'Last Day' as Category,
CASE
	WHEN (finished.trumpFinish > finished.bidenFinish) THEN 'Trump'
    WHEN (finished.trumpFinish < finished.bidenFinish) THEN 'Biden'
    else 'TIE'
END AS winner,
CASE
	WHEN (finished.trumpFinish > finished.bidenFinish) THEN trumpFinish
    WHEN (finished.trumpFinish < finished.bidenFinish) THEN bidenFinish
    END AS numberOfTotalVotes  
    from
(select (lastDay.TrumpFirstDay-secondLastDay.TrumpFirstDay) trumpFinish, (lastDay.BidenFirstDay -secondLastDay.BidenFirstDay) bidenFinish 
from (select firstDay, sum(mt) as TrumpFirstDay, sum(mb) as BidenFirstDay, sum(TV) as TotalFirstDay
from 
(select Date(Timestamp) firstDay, precinct, max(Trump) as mt, max(Biden) as mb, max(totalvotes) as TV
from testDB.penna
group by Date(Timestamp), precinct) as innerTable
group by firstDay
order by firstDay desc
limit 1) lastDay,
(select firstDay, sum(mt) as TrumpFirstDay, sum(mb) as BidenFirstDay, sum(TV) as TotalFirstDay
from 
(select Date(Timestamp) firstDay, precinct, max(Trump) as mt, max(Biden) as mb, max(totalvotes) as TV
from testDB.penna
group by Date(Timestamp), precinct) as innerTable
group by firstDay
Having firstDay<(select max(DATE(Timestamp)) from testDB.penna)
order by firstDay desc
limit 1) secondLastDay) as finished;



-- #8
select count(precinct)
from 
(select precinct, (max(Trump)-max(Biden)) as finalDiff
from testDB.penna 
group by precinct
having finaldiff>0) as finished;


-- #9 What was the earliest timestamp when Biden was leading Trump?

select Timestamp
from testDB.penna
group by Timestamp
Having sum(Biden)>sum(Trump)
order by Timestamp asc
limit 1;


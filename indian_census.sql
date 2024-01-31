drop database if exists census ;
create database census;
use  census;

SELECT * FROM census.data_census;

-- no of rows in our dataset
select count(*) from data_census;
select count(*) from data_census2;

-- dataset for jharkhand and bihar
select * from data_census
where state in ('jharkhand','bihar');

-- total population in india 
select sum(population) from data_census2;

-- avg growth in india
select avg(growth)*100  as avg_grwth from data_census;


-- avg_sex ratio by state
select state , avg(sex_ratio)  from data_census
group by state 
having avg(sex_ratio)>900
order by avg(sex_ratio) desc;

-- joining the both tables
select d1.district ,  d2.state , d1.sex_ratio*1000 , d2.population from data_census as d1
join  data_census2 as d2 on d1.District = d2.District;

-- females / male = sex_ratio
-- population = males + females
-- females = population - males
-- population - males = males*sex_ratio
-- population = males(sex_ratio+1)

-- no.of males and females in each state
select d.state , sum(d.males) as total_males , sum(d.females) as total_females from
(select c.district , c.state , round((c.population/c.sex_ratio+1),0) as males , round((c.population * c.sex_ratio)/(c.sex_ratio-1),0) 
as females from (select d1.district ,  d2.state , d1.sex_ratio*1000 as sex_ratio , d2.population from data_census as d1
join  data_census2 as d2 on d1.District = d2.District) as c) as d
group by d.state;

-- total literacy rate
-- total literate people / population = literacy_ratio
-- total literate people = population * literacy_ratio
-- total illiterate people = (1-literacy_ratio)*population
select c.state , sum(c.literate_people) as literate_people , sum(c.illiterate_people) as illiterate_people  from
(select d.district , d.state , round((d.population*d.literacy_ratio),0) as literate_people , round((1-d.literacy_ratio)*d.population,0)
as illiterate_people from (select d1.district ,  d2.state , d1.literacy/100 as literacy_ratio , d2.population from data_census as d1
join  data_census2 as d2 on d1.District = d2.District) as d) as c
group by c.state;


-- population from previous census
-- previous_census+previous_census*growth=population
-- previous_census = population/(1+growth)

select sum(m.previous_census_population) as previous_census_population,sum(m.current_census_population) current_census_population 
from(select e.state,sum(e.previous_census_population) as previous_census_population,
sum(e.current_census_population) as current_census_population from
(select d.district,d.state,round(d.population/(1+d.growth),0) as previous_census_population,
d.population as current_census_population from
(select d1.district,d1.state,d1.growth  as growth,d2.population from data_census as d1  inner join
 data_census2 as d2 on d1.district=d2.district) d) as e
group by e.state) as m;

-- population vs area
select g.total_area/g.previous_census_population as previous_census_population,
g.total_area/g.current_census_population as current_census_population from
(select q.*,r.total_area from(
select 'l' as keyy , n.*from
(select sum(m.previous_census_population) as previous_census_population,sum(m.current_census_population) current_census_population from(
select e.state,sum(e.previous_census_population) as previous_census_population,sum(e.current_census_population) as current_census_population from
(select d.district,d.state,round(d.population/(1+d.growth),0) as previous_census_population,d.population as current_census_population from
(select d1.district,d1.state,d1.growth  as growth,d2.population from data_census as d1  inner join data_census2 as d2 on d1.district=d2.district) d) as e
group by e.state) as m)as n) as q inner join(

select 'l' as keyy , z.*from(
select sum(area_km2) as total_area from data_census2) as z) as r on q.keyy = r.keyy) as g;

-- top3 districts with highest literacy rate
select n.* from 
(select district , state , literacy , rank() over(partition  by state order by literacy desc) as rnk from data_census)
as n
where n.rnk in(1,2,3) order by state;






# 1. Para el último año registrado en el modelo, ¿cuál es el top 3 de universidades con la
# mayor relación de estudiantes internacionales en relación con el total de estudiantes?

select distinct university_ranking_year.university_id, university_ranking_year.year, university_ranking_year.score,
university.university_name, university_year.pct_international_students 
from university_ranking_year
inner join university on university_ranking_year.university_id = university.id
inner join university_year on university.id = university_year.university_id 
order by year desc ,score desc, pct_international_students desc
limit 3;

# 2. Identifica las universidades que mejoraron su ranking año tras año durante los últimos
# tres años y muestra su progreso en cada año.

select distinct university_ranking_year.university_id, university_ranking_year.year, university.university_name, avg(score)
from university_ranking_year
inner join university on university_ranking_year.university_id = university.id
where year in(
select distinct year
from university_ranking_year 
order by year desc)
group by 1,2


# 3. Determina el promedio de estudiantes internacionales para universidades que están en
# el top 5 en el año más reciente. Al mismo tiempo, clasifica esos países según el
# promedio de estudiantes internacionales y su ranking en ese año.

with cte as (
  select university_ranking_year.university_id, university_ranking_year.score,country.country_name,
         university.university_name, university_ranking_year.year, 
         university_year.pct_international_students as promedio,
         row_number() over (partition by university_ranking_year.university_id
                            order by university_ranking_year.score desc) as row_num
  from university_ranking_year
  inner join university on university_ranking_year.university_id = university.id
  inner join university_year on university.id = university_year.university_id
  inner join country on country.id = university.country_id
)
select university_id, score, university_name, year, promedio, country_name
from cte
where row_num = 1
order by score desc
limit 5;


# 4. Determina cuál sistema de ranking tiene la mayor cantidad de criterios y muestra la
# universidad mejor rankeada para ese sistema en el año más reciente.

select distinct ranking_system.system_name,university.university_name, max(university_ranking_year.score), 
max(university_ranking_year.year), count(criteria_name) as cantidad_criterio 
from ranking_system
inner join ranking_criteria on ranking_system.id = ranking_criteria.ranking_system_id 
inner join university_ranking_year on ranking_criteria.id = university_ranking_year.ranking_criteria_id 
inner join university on university_ranking_year.university_id = university.id 
group by 1,2
order by cantidad_criterio desc;


# 5. Considerando el año más reciente, muestra el sistema de ranking que tiene el promedio
# de score más alto para las universidades del país que tiene la universidad con el score
# más alto en general

select distinct ranking_system.system_name, university.university_name, country.country_name,
avg(university_ranking_year.score) as promedio_score,
max(university_ranking_year.year)
from university_ranking_year
inner join ranking_criteria on university_ranking_year.ranking_criteria_id = ranking_criteria.id 
inner join ranking_system on ranking_criteria.ranking_system_id = ranking_system.id 
inner join university on university_ranking_year.university_id = university.id 
inner join country on university.country_id = country.id
group by 1,2,3
order by promedio_score desc;


























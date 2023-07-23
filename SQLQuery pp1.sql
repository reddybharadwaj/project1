
select *
from pp1..CovidDeaths
order by 3,4

--select *
--from pp1..CovidVaccinations
--order by 3,4


select location, date, total_cases, new_cases,total_deaths, population
from pp1..CovidDeaths
order by 1,2



--cases vs deaths as death percentage

select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 DeathPercentage
from pp1..CovidDeaths
--where location like 'Canada'
order by 1,2



--total cases vs population as Population percentage
select location, date, total_cases, population, (total_cases/population)*100 PopulationPercentage
from pp1..CovidDeaths
where location like 'Canada'
order by 1,2



--high infection countries
select location,population, max(total_cases) HighInfectionCount, max((total_cases/population))*100 PopulationPercentageInfected
from pp1..CovidDeaths
Group by location, population
order by PopulationPercentageInfected desc



--highest death counts vs population

select location, max(cast(total_deaths as int)) DeathCount
from pp1..CovidDeaths
where continent is not null
Group by location
order by DeathCount desc



--regional breakdown

select continent, max(cast(total_deaths as int)) DeathCount
from pp1..CovidDeaths
where continent is not null
Group by continent
order by DeathCount desc



--worldwide stat

select Sum(new_cases) total_cases, sum(cast(new_deaths as int)) total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 DeathPercentage
from pp1..CovidDeaths
where continent is not null
--group by location
order by 1,2




--joining tables

select *
from pp1..Coviddeaths cod
join pp1..CovidVaccinations cvac
on cod.location = cvac.location
and cod.date = cvac.date



--totalpopulation vs vaccination

select cod.continent, cod.location, cod.date, cod.population, cvac.new_vaccinations
from pp1..Coviddeaths cod
join pp1..CovidVaccinations cvac
on cod.location = cvac.location
and cod.date = cvac.date
where cod.continent is not null
order by 2,3



--RollingPeopleVaccinated

select cod.continent, cod.location, cod.date, cod.population, cvac.new_vaccinations
,sum(cast(cvac.new_vaccinations as int)) 
Over (partition by cod.location order by cod.location, cod.date) RollingPeopleVaccinated
from pp1..Coviddeaths cod
join pp1..CovidVaccinations cvac
on cod.location = cvac.location
and cod.date = cvac.date
where cod.continent is not null
order by 2,3



--cte

with PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select cod.continent, cod.location, cod.date, cod.population, cvac.new_vaccinations
,sum(cast(cvac.new_vaccinations as int)) 
Over (partition by cod.location order by cod.location, cod.date) RollingPeopleVaccinated
from pp1..Coviddeaths cod
join pp1..CovidVaccinations cvac
on cod.location = cvac.location
and cod.date = cvac.date
where cod.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100 RollingVaccinatedPercentage
from PopvsVac




--temp table

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255), 
location nvarchar(255), 
date datetime, 
population numeric,
new_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select cod.continent, cod.location, cod.date, cod.population, cvac.new_vaccinations
,sum(cast(cvac.new_vaccinations as int)) 
Over (partition by cod.location order by cod.location, cod.date) RollingPeopleVaccinated
from pp1..Coviddeaths cod
join pp1..CovidVaccinations cvac
on cod.location = cvac.location
and cod.date = cvac.date
--where cod.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100 RollingVaccinatedPercentage
from #PercentPopulationVaccinated



--create view

create view PercentPopulationVaccinated as
select cod.continent, cod.location, cod.date, cod.population, cvac.new_vaccinations
,sum(cast(cvac.new_vaccinations as int)) 
Over (partition by cod.location order by cod.location, cod.date) RollingPeopleVaccinated
from pp1..Coviddeaths cod
join pp1..CovidVaccinations cvac
on cod.location = cvac.location
and cod.date = cvac.date
where cod.continent is not null
--order by 2,3

select*
from PercentPopulationVaccinated
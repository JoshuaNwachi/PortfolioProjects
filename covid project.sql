/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/
Select *
From Portfolio..covid_deaths
Where continent is not null 
order by 3,4

-- Select Data that we are going to be starting with

select location,
		date,
		total_cases,
		new_cases,
		total_deaths,
		population
from Portfolio..covid_deaths
where continent is not null
order by location,date
 
--  Total Cases vs Total Deaths
-- shows likelihood of dying if you contact covid
select continent,
		location,
		date,
		total_cases,
		total_deaths,
		round((total_deaths/total_cases)*100,2) as death_percentage
from Portfolio..covid_deaths
where continent is not null
order by location,date


--total cases vs population
-- Shows what percentage of population infected with covid
select continent,
		location,
		date,
		population,
		total_cases,
		round((total_cases/population)*100,2) as percent_population_infected
from Portfolio..covid_deaths
where continent is not null
order by location,date


-- countries with highest infection rate compared to population

select continent,
		location,
		population,
		max(total_cases) as highest_infection_count,
		round(max((total_cases/population)*100),2) as percent_population_infected
from Portfolio..covid_deaths
where continent is not null
group by continent,location,population
order by percent_population_infected desc


--showing countries with highest death count per population
select 
		location,
		MAX(cast(total_deaths as int)) as total_death_count
from Portfolio..covid_deaths
where continent is NOT  null
group by continent,location
order by total_death_count desc


-- Breaking Things Down BY CONTINENT

--continents with highest death count per population

select continent,
		MAX(cast(total_deaths as int)) as total_death_count
from Portfolio..covid_deaths
where continent is not null
group by continent
order by total_death_count desc

--GLOBAL NUMBERS 
select
		sum(new_cases) as total_cases,
		sum(cast(new_deaths as int))  total_deaths,
		round((sum(cast(new_deaths as int))/sum(new_cases))*100,3)  death_percentage
from Portfolio..covid_deaths
where continent is not null
order by 1,2


--looking at total Population vs vaccination
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select  distinct dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		sum(cast(vac.new_vaccinations as bigint)) over(partition by dea.location order by dea.location, dea.date )  RollingPeople_vaccinated
from Portfolio..Covid_deaths as dea
join Portfolio..Covid_vaccine as vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

with PopvsVac ( continent,location,date,population,new_vaccinations,RollingPeople_vaccinated)
as 
(
select  distinct dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		sum(cast(vac.new_vaccinations as bigint)) over(partition by dea.location order by dea.location, dea.date )  RollingPeople_vaccinated
from Portfolio..Covid_deaths as dea
join Portfolio..Covid_vaccine as vac
		on dea.location=vac.location
		and dea.date=vac.date
where dea.continent is not null
)

select *,
		round((RollingPeople_vaccinated/population)*100,3)
from PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeople_vaccinated numeric
)

insert into  #PercentPopulationVaccinated
select  distinct dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		sum(cast(vac.new_vaccinations as bigint)) over(partition by dea.location order by dea.location, dea.date )  RollingPeople_vaccinated
from Portfolio..Covid_deaths as dea
join Portfolio..Covid_vaccine as vac
		on dea.location=vac.location
		and dea.date=vac.date
where dea.continent is not null

select *,
		round((RollingPeople_vaccinated/population)*100,3)
from #PercentPopulationVaccinated

-- creating view to store data for later visulization
create view PercentPopulationVaccinated as 
select  distinct dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		sum(cast(vac.new_vaccinations as bigint)) over(partition by dea.location order by dea.location, dea.date )  RollingPeople_vaccinated
from Portfolio..Covid_deaths as dea
join Portfolio..Covid_vaccine as vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null




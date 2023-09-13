-- import the two dataset into the database
-- sorting in order 
select *
from portfolio_projects ..CovidDeaths$
where continent is not null
order by 3,4

select *
from portfolio_projects ..CovidVaccinations$
order by 3,4

-- selecting needed columns

select location, date, total_cases, new_cases, total_deaths, population
from portfolio_projects..CovidDeaths$
order by 1,2; --sorting by location & date


-- Total cases vs Total deaths
-- shows likelihood of dying if you contract covid in your country(nigeria)
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from portfolio_projects..CovidDeaths$
where location like '%nigeria%'
order by 1,2; --sorting by location & date


-- Total cases vs populatiion
-- shows percentage of the population with covid
select location, date, total_cases, population, (total_cases/population)*100 as percentageinfected
from portfolio_projects..CovidDeaths$
where continent is not null
order by 1,2; --sorting by location & date


-- Countries with highest infection rate compared to population

SELECT location, population, Max(total_cases) as HighestInfectionCount, Max(total_cases * 100 / population) AS percentageinfcted
from portfolio_projects..CovidDeaths$
where continent is not null
Group by location, population
order by percentageinfcted desc


--Countries with highest death count per population
SELECT location,  MAX(cast(Total_deaths as int)) as TotalDeathCount
from portfolio_projects..CovidDeaths$
where continent is not null 
Group by location
order by TotalDeathCount desc



--checking with continent instead of location
--continent with highest death count per population
SELECT continent,  MAX(cast(Total_deaths as int)) as TotalDeathCount
from portfolio_projects..CovidDeaths$
where continent is not null 
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS
select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
from portfolio_projects..CovidDeaths$
where continent is not null
Group by date
order by 1,2 

--
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
from portfolio_projects..CovidDeaths$
where continent is not null
--Group by date
order by 1,2 


--looking at the vaccinations table
select *
from portfolio_projects..CovidVaccinations$


--join the two tables
select *
from portfolio_projects..CovidDeaths$ death
join portfolio_projects..CovidVaccinations$ vac
	on death.location = vac.location
	and death.date = vac.date


--looking at total population vs vaccinations
--using a CTE
-- TotalpopsvsVac Table

with TotalpopsvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select  death.continent, death.location, death.date, death.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by death.location order by death.location, death.date) as RollinPeopleVaccinated
from portfolio_projects..CovidDeaths$ death
join portfolio_projects..CovidVaccinations$ vac
	on death.location = vac.location
	and death.date = vac.date
where death.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100 --calculate % of rollingpeoplevaccinated
from TotalpopsvsVac


-- create & of people vaccinated table
drop table if exists PercentPopulationVaccinated
create table PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime, 
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into PercentPopulationVaccinated
select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
from portfolio_projects..CovidDeaths$ death
join portfolio_projects..CovidVaccinations$ vac
	on death.location = vac.location
	and death.date = vac.date
where death.continent is not null
order by 2,3


select *, (RollingPeopleVaccinated/population)*100
from PercentPopulationVaccinated


--creating views to store data to visualize later
create view PercentPopulationVaccinated as
select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
from portfolio_projects..CovidDeaths$ death
join portfolio_projects..CovidVaccinations$ vac
	on death.location = vac.location
	and death.date = vac.date
where death.continent is not null


--create view for Totalpopsvsvacc
create view PopsvsVac as
select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by death.location order by death.location, death.date) as RollinPeopleVaccinated
from portfolio_projects..CovidDeaths$ death
join portfolio_projects..CovidVaccinations$ vac
	on death.location = vac.location
	and death.date = vac.date
where death.continent is not null



select *
from PercentPopulationVaccinated
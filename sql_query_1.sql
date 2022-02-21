/*
Exploration of Covid 19 Data set. 
Skills used: Aggregate Functions, Creating Views, Converting Data Types, Joins, CTE's, Temp Tables, Windows Functions
*/




use PortfolioProject
go
select * from coviddeath


select * 
from PortfolioProject..covidvactinated$
order by 3,4


select location, date, total_cases, new_cases, total_deaths, new_cases,new_deaths ,population
from PortfolioProject..coviddeath
order by 1,2



select location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as deathpercentage
from PortfolioProject..coviddeath
where location like '%india%'
order by 1,2



select location, date, total_cases, population, (total_cases/population)* 100 as casepercentage
from PortfolioProject..coviddeath
order by 1,2


select location,population ,max(total_cases) as highestinfectioncount, max((total_cases/population))*100 as infectedpopulation
from PortfolioProject..coviddeath
group by location , population
order by infectedpopulation desc


select location, population, max(total_deaths) as highestinfectionrate , max((total_deaths/population))*100 as totaldeaths
from PortfolioProject..coviddeath
group by location, population
order by totaldeaths desc


select location, max(cast(total_deaths as int)) as totaldeaths 
from PortfolioProject..coviddeath
where continent is not null
group by location
order by totaldeaths desc


select location, max(cast(Total_deaths as int)) as totaldeaths 
from PortfolioProject..coviddeath
where continent is null
group by location
order by totaldeaths desc

select continent, max(cast(Total_deaths as int)) as totaldeaths 
from PortfolioProject..coviddeath
where continent is not null
group by continent
order by totaldeaths desc


select date, sum(new_cases) as ncases, sum(cast(new_deaths as int)) as ndeaths ,sum(cast(new_deaths as int))/sum(new_cases)*100 as percentage
from PortfolioProject..coviddeath
where continent is not null
group by date
order by 1,2

select sum(new_cases) as ncases, sum(cast(new_deaths as int)) as ndeaths ,sum(cast(new_deaths as int))/sum(new_cases)*100 as percentage
from PortfolioProject..coviddeath
where continent is not null
order by 1,2


select death.continent,death.location, death.date,death.total_cases, death.total_deaths, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int )) OVER (Partition by death.Location Order by death.location, death.Date) as PeopleVaccinated
from PortfolioProject..coviddeath death
join PortfolioProject..covidvactinated$ vac
	on death.location = vac.location
where death.continent is not null
order by 1,2,3

With populationvsvacctination (Continent, Location, Date, Population, New_Vaccinations, PeopleVaccinated)
as
(
select death.continent,death.location, death.date,death.total_cases, death.total_deaths, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int )) OVER (Partition by death.Location Order by death.location, death.Date) as PeopleVaccinated
from PortfolioProject..coviddeath death
join PortfolioProject..covidvactinated$ vac
	on death.location = vac.location
where death.continent is not null
order by 1,2,3
)
Select *, (PeopleVaccinated/Population)*100
From populationvsvacctination



DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
select death.continent,death.location, death.date,death.total_cases, death.total_deaths, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int )) OVER (Partition by death.Location Order by death.location, death.Date) as PeopleVaccinated
from PortfolioProject..coviddeath death
join PortfolioProject..covidvactinated$ vac
	on death.location = vac.location
where death.continent is not null
order by 1,2,3

Select *, (PeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


Create View PercentPopulationVaccinated as
select death.continent,death.location, death.date,death.total_cases, death.total_deaths, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int )) OVER (Partition by death.Location Order by death.location, death.Date) as PeopleVaccinated
from PortfolioProject..coviddeath death
join PortfolioProject..covidvactinated$ vac
	on death.location = vac.location
where death.continent is not null
order by 1,2,3
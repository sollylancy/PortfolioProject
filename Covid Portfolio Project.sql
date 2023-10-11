select *
from CovidDeaths
order by 3,4

--select *
--from CovidVaccinations
--order by 3,4

--select the data that we are going to be using

--select location, date, total_cases, new_cases, total_deaths, population 
--from CovidDeaths
--ORDER BY 1,2

--looking at Total cases vs Total Deaths

select location, date, total_cases, total_deaths, (case when total_deaths > 0 THEN 1 else 0 END)*1.0/ total_cases*100 as DeathPercentage
from CovidDeaths
where location like '%state%'
ORDER BY 1,2

-- Looking at the Total Cases vs Population
-- Shows what percentage of population got Covid

select location, date, population, (case when total_cases > 0 THEN 1 else 0 END)*1.0/ population*100 as PercentageofPopulationInfected
from CovidDeaths
--where location like '%state%'
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (case when total_deaths > 0 THEN 1 else 0 END)*1.0/ total_cases*100 as DeathPercentage
from CovidDeaths
where location like '%states%'
and continent is not null
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population
Select location, population, MAX(total_cases) AS HighestInfectionCount, Max((case when total_cases > 0 THEN 1 else 0 END)*1.0/ population)*100 as PercentPopulationInfected
from CovidDeaths
--where location = '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

-- Showing countries with the Highest Death count per population

Select location, MAX(total_deaths) AS TotalDeathCount
From CovidDeaths
--where location = '%states%'
where continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc


--Let's break things down by continent

Select continent, MAX(total_deaths) AS TotalDeathCount
From CovidDeaths
--where location = '%states%'
where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

--Showing the continent with highest death count per population

Select continent, MAX(total_deaths) AS TotalDeathCount
From CovidDeaths
--where location = '%states%'
where continent is not null
GROUP BY continent

--GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, sum(new_deaths) as total_deaths, (SUM(case when new_deaths > 0 THEN 1 else 0 END)*1.0/sum(new_cases))*100 as DeathPercentage
from CovidDeaths
--where location like '%states%'
where continent is not null
--Group by date
ORDER BY 1,2

-- looking at Total Population vs Vaccinations

--USE CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, RollingPeopleVaccinated/Population*100 --(case when RollingPeopleVaccinated > 0 THEN 1 else 0 END)*1.0/Population)*100
From PopvsVac

-- TEMP TABLE
DROP Table if exists #PercentpopulationVaccinated
CREATE TABLE #PercentpopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentpopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, RollingPeopleVaccinated/Population*100 --(case when RollingPeopleVaccinated > 0 THEN 1 else 0 END)*1.0/Population)*100
From #PercentpopulationVaccinated

--- Creating view to store data for later visualization

create view PercentpopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
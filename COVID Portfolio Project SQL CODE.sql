select * from PortfolioProject..CovidDeath
order by 3,4

--select * from PortfolioProject..CovidVaccination
--order by 3,4

-- Select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeath
where continent is not null
order by 1,2

-- Looking at total cases vs total deaths
-- Shows liklihood of dying if you contract covid in your country which in this case is india
  
select location, date, total_cases, total_deaths, 
(CONVERT(float, total_deaths)/CONVERT(float, total_cases)) * 100 as DeathPercentage
from PortfolioProject..CovidDeath
Where location like '%india%'
order by 1,2


-- Looking at total cases vs population
-- Shows what percentage of popultaion has got covid where location is india
  
select location, date, population, total_cases, 
(CONVERT(float, total_cases)/CONVERT(float, population)) * 100 as PercentOfPopulationInfected
from PortfolioProject..CovidDeath
Where location like '%india%'
order by 1,2

-- Looking at countries with Highest Infection rate Compared to population

select location, population, MAX(total_cases) as HighestInfectionCount, 
MAX((CONVERT(float, total_cases)/CONVERT(float, population))) * 100 as PercentOfPopulationInfected
from PortfolioProject..CovidDeath
--Where location like '%india%'
Group By location, population
order by PercentOfPopulationInfected desc


-- Showing the countries with Highest Death Count per Population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeath
--Where location like '%india%'
where continent is not null
Group By location
order by TotalDeathCount desc


-- Let's break thing down by continent
-- Showing The Continents With Highest Death Count Per Population

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeath
--Where location like '%india%'
where continent is not null
Group By continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, (SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage
FROM PortfolioProject..CovidDeath
WHERE continent IS NOT NULL
--GROUP BY date
HAVING SUM(new_cases) + SUM(new_deaths) <> 0
ORDER BY 1, 2


-- Looking at Total Population vs Vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(float,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null
order by 2,3


  
-- USE CTE

With PopvsVac (continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(float,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null
--order by 2,3
)

select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


-- TEMP TABLE


DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated 
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(float,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null and vac.new_vaccinations is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated




-- Creating View To store Data for later Visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(float,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null
--order by 2,3

Select * 
From  PercentPopulationVaccinated



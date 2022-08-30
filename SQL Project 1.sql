SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

-- Select Data that we are going to be using
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows the Likelihood of dying if you Contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%States%'
Order By 1,2

-- Looking at the Total Cases vs the Population
-- Shows what percentage of the population had Covid
SELECT Location, date, total_cases, population, (total_cases/population) * 100 as CasePercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%States%'
Order By 1,2

--Looking at Countries with Highest INfection Rate compared to Population
SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population) * 100) as 
	PercentageInfected
FROM PortfolioProject..CovidDeaths
-- WHERE Location LIKE '%States%'
GROUP BY Location, Population
Order By PercentageInfected DESC

-- Showing countries with Highest Death Count per Population
SELECT Location, population, MAX(cast(total_deaths as INT)) as TotalDeaths
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL 
GROUP BY Location
Order By TotalDeaths DESC

-- Lets Break it down by Continent
SELECT location, MAX(cast(total_deaths as INT)) as TotalDeaths
FROM PortfolioProject..CovidDeaths
WHERE continent is NULL 
GROUP BY location
Order By TotalDeaths DESC

--Showing the continents with the highest death count per population
SELECT continent, MAX(cast(total_deaths as INT)) as TotalDeaths
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL 
GROUP BY continent
Order By TotalDeaths DESC

--Number of New cases and New Deaths Globally per day
SELECT date, SUM(new_cases) as NewCases, SUM(cast(new_deaths as INT)) as NewDeaths, (SUM(cast(new_deaths as INT)) / SUM(new_cases)) * 100 as 
	GlobalDeathPercent
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
GROUP BY date
Order by 1,2

-- This querty gives the total number of cases and deaths as well as the deathpercentage
SELECT SUM(new_cases) as NewCases, SUM(cast(new_deaths as INT)) as NewDeaths, (SUM(cast(new_deaths as INT)) / SUM(new_cases)) * 100 as 
	GlobalDeathPercent
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
-- GROUP BY date
Order by 1,2

--Lets look at the table from CovidVaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
, SUM(CONVERT(bigint, vacc.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as
RollingPeopleVaccinated
, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vacc
	ON dea.location = vacc.location
	AND dea.date = vacc.date
WHERE dea.continent is not null
order by 2,3



--USE CTE

WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
, SUM(CONVERT(bigint, vacc.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as
RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vacc
	ON dea.location = vacc.location
	AND dea.date = vacc.date
WHERE dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
Cotinent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
, SUM(CONVERT(bigint, vacc.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as
RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vacc
	ON dea.location = vacc.location
	AND dea.date = vacc.date
--WHERE dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--Creating Views to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
, SUM(CONVERT(bigint, vacc.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as
RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vacc
	ON dea.location = vacc.location
	AND dea.date = vacc.date
WHERE dea.continent is not null
--order by 2,3

Select * 
From PercentPopulationVaccinated
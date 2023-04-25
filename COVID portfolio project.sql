SELECT *
FROM CovidDeaths

--SELECT *
--FROM CovidVaccinations

--Select data to use
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

--Change data type from nvarchar to float
ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN total_deaths float

ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN total_cases float

--Total cases vs Total Deaths....it shows the likelihood of dying in nigeria
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location like '%Nigeria%'
ORDER BY 1,2

--what popolation of those in nigeria have gotten covid
SELECT location, date, total_cases, population, (total_cases/population)*100 as PercentageofInfectedCases
FROM CovidDeaths
WHERE location like '%Nigeria%'
ORDER BY 1,2

--COuntries with the highest infection as against population
SELECT location, population, max(total_cases) as HighestInfectedCases, max((total_cases/population))*100 
as PercentageofPopulationInfected
FROM CovidDeaths
GROUP BY location, population
ORDER BY PercentageofPopulationInfected DESC

--Countries with highest death count per population
SELECT location, population, max(total_deaths) as HighestDeathCases, max((total_deaths/population))*100 as 
PercentageDeathperPopulation
FROM CovidDeaths
GROUP BY location, population
ORDER BY HighestDeathCases DESC

SELECT location, max(cast (total_deaths as int)) as HighestDeathCases
FROM CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY HighestDeathCases DESC


---Deaths by continents
SELECT continent, max(cast (total_deaths as int)) as HighestDeathCases
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY HighestDeathCases DESC

--Cases around the world
SELECT date, SUM(new_cases) as TotalCases, SUM(new_deaths) AS TotalDeathCases,
(SUM(new_deaths) * 100) / NULLIF(SUM(new_cases),0) AS DeathPercentage
FROM CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--Total cases in the world
SELECT  SUM(new_cases) as TotalCases, SUM(new_deaths) AS TotalDeathCases,
(SUM(new_deaths) * 100) / NULLIF(SUM(new_cases),0) AS DeathPercentage
FROM CovidDeaths
WHERE continent is not null
ORDER BY 1,2

----COVID VACCINATIONS
SELECT *
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date

--Total vaccination vs population
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER 
(Partition by dea.location order by dea.location, dea.date) as TotalVaccinations
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USING CTE (so that i can include other columns)
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, TotalVaccinations)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER 
(Partition by dea.location order by dea.location, dea.date) as TotalVaccinations
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (TotalVaccinations/Population)*100 AS Percentageoftotvacpop
FROM PopvsVac

---Using TEMP Table
Drop Table if exists #Percentofvaccinations
CREATE TABLE #Percentofvaccinations
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Total_vaccinations numeric
)
INSERT INTO #Percentofvaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER 
(Partition by dea.location order by dea.location, dea.date) as TotalVaccinations
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

SELECT *
FROM #Percentofvaccinations


--CREATE VIEW TO STORE DATA FOR VISUALIZATION
CREATE VIEW Percentofvaccinations AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER 
(Partition by dea.location order by dea.location, dea.date) as TotalVaccinations
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

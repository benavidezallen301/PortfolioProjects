SELECT *
FROM PortfolioProject..COVID_Deaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..COVID_Vaccinations
--ORDER BY 3,4

--SELECT DATA THAT WE ARE GOING TO BE USING
SELECT Location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..COVID_Deaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
--Shows likelihoog of dying if you contract covid in your country
SELECT Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..COVID_Deaths
WHERE location like '%states%'
ORDER BY 1,2


-- Looking at Total Cases vs Population
--Shows What percentage of population got covid

SELECT Location,date,total_cases,Population,(total_deaths/total_cases)*100 AS PercentPopulationInfected
FROM PortfolioProject..COVID_Deaths
WHERE location like '%Mexico%'
ORDER BY 1,2


--Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases)AS HighestInfectionCount, MAX((total_cases/population))* 100 AS PercentPopulationInfected
FROM PortfolioProject..COVID_Deaths
--WHERE location like '%Mexico%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc

--LETS BREAK THINGS DOWN BY CONTINENT



--SHOWING Continents with the highest death count per population
SELECT continent, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..COVID_Deaths
--WHERE location like '%Mexico%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS INT)) AS total_deaths, 
SUM(CAST(new_deaths AS INT))/SUM(new_Cases) *100 AS DeathPercentage
FROM PortfolioProject..COVID_Deaths
--WHERE location is like '%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.Location Order by dea.Location, dea.Date) AS RollingPeoplevaccinated
, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..COVID_Deaths dea
JOIN PortfolioProject..COVID_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2 ,3


--USE CTE
With PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.Location Order by dea.Location, dea.Date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..COVID_Deaths dea
JOIN PortfolioProject..COVID_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2 ,3
)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac



--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.Location Order by dea.Location, dea.Date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..COVID_Deaths dea
JOIN PortfolioProject..COVID_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2 ,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.Location Order by dea.Location, dea.Date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..COVID_Deaths dea
JOIN PortfolioProject..COVID_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2 ,3

SELECT *
FROM PercentPopulationVaccinated

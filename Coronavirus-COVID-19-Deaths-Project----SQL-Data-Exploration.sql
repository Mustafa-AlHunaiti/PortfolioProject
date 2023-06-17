SELECT *
FROM PortfolioProject..CovidDeaths -- table 1
ORDER BY 3, 4


SELECT *
FROM PortfolioProject..CovidVaccinations -- table 2
ORDER BY 3, 4

-- Select the Data that we are going to be using 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL -- get rid of all the ones that were like world and all those other things like(North America, South America, Asia, Europe) cuz it's not location, it 's Continent
ORDER BY 1, 2 -- let's keep this going because i don't like things not being organized 


-- looking at Total Cases VS Total Deaths
-- how many cases are there in this country and how many deaths do they have for their entire cases
-- so let's say they have a thousand people who have been diagnosed they had 10 people who died what's the percentage of people who died who had it
-- so now we want to know the percentage of people who are dying who actually get infected or who report being infected
-- Shows likelihood of dying if you contract covid in your country 

SELECT location, date, total_cases, total_deaths, (total_deaths /total_cases) * 100 AS DeathPercentage 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
      AND
	  (
	  location LIKE '%states%' 
	 OR 
	  location LIKE 'jor%'
	  )
ORDER BY 1, 2 DESC



-- looking at Total Cases VS Population
-- shows what percentage of population has got Covid 
-- it has gotten a test and it's been confirmed 
SELECT location, date, Population, total_cases, (total_cases /Population) * 100 AS PercentPopulationInfected 
FROM PortfolioProject..CovidDeaths
/*
WHERE location LIKE '%states%' 
	 OR 
	  location LIKE 'jor%'
*/
ORDER BY 1, 2 DESC


-- i'm really curious as to what countries have the highest infection rates compared to the population
-- looking at countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases /Population) * 100) AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
/*
WHERE location LIKE '%states%' 
	 OR 
	  location LIKE 'jor%'
*/
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC



-- Showing Countries with Highest Death Count per Population 

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount --  The CAST () function converts a value (of any type) into a specified datatype
FROM PortfolioProject..CovidDeaths
/*
WHERE location LIKE '%states%' 
	 OR 
	  location LIKE 'jor%'
*/
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC



-- LET's BREAK THINGS DOWN BY CONTINENT 
-- Showing Continent with the Highest Death Count per Population 

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths
/*
WHERE location LIKE '%states%' 
	 OR 
	  location LIKE 'jor%'
*/
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC





-- This actually is the correct numbers of  Highest Death Count per Continent not the code above 

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths
/*
WHERE location LIKE '%states%' 
	 OR 
	  location LIKE 'jor%'
*/
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC




-- it works like that, but when I added GROUP BY for example on the date column, it didn't work. gave me this error "Divide by zero error encountered". look at GLOBAL NUMBERS code. so i decide to add HAVING clause to filter all values having 0 in totalDeaths

SELECT  SUM(CAST(new_deaths AS int))/SUM(new_cases) * 100 AS DeathPercentage 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 


-- GLOBAL NUMBERS 

SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS int))AS TotalDeaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
/*
      AND
	  (
	  location LIKE '%states%' 
	 OR 
	  location LIKE 'jor%'
	  )
*/
GROUP BY date -- will give us on each day the total across the world because we're not filtering by any Continent or location or anything it's just by date 
HAVING SUM(new_cases) <> 0
ORDER BY 1


-- GLOBAL NUMBERS 

SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS int))AS TotalDeaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
/*
      AND
	  (
	  location LIKE '%states%' 
	 OR 
	  location LIKE 'jor%'
	  )
*/
ORDER BY 1, 2




-- Looking at total Population VS Vaccination 
-- What is the total amount of people in the world that have been vaccinated 

SELECT dea.continent, dea.location, dea.date, dea.Population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated -- The CONVERT() function converts a value (of any type) into a specified datatype
--, (RollingPeopleVaccinated/dea.Population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3


--USE CTE

WITH PopVSVac (Continent, location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.Population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
-- ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 -- for example, almost 37 percent of the population in Jordan is vaccinated
FROM PopVSVac
-- WHERE location = 'jordan'



-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated 
(
Continent nvarchar(255),
location  nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.Population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL 
--ORDER BY 2, 3



SELECT *, (RollingPeopleVaccinated/Population)*100 
FROM #PercentPopulationVaccinated



-- Creating View to store data for later visualizations 

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.Population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
--ORDER BY 2, 3


SELECT *
FROM PercentPopulationVaccinated


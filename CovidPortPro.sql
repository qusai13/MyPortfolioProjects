--SELECT *
--FROM CovidDeaths

--SELECT *
--FROM CovidVaccination
--WHERE total_vaccinations IS NOT NULL
--ORDER BY 3,4

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM CovidDeaths

-- LOKKING AT THE TOTAL CASES VS TOTAL DEATHS 
--SHOWS THE POSSIBILITY OF DYING FROM COVID IF YOU CAPTURE IT IN YOUR COUNTRY 
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathsPercentage 
FROM CovidDeaths
WHERE location='Turkey'

--LOOKING AT TOTAL CASEs VS POPULATION
SELECT location,date,total_cases,population,(total_cases/population)*100 AS DeathsPercentage 
FROM CovidDeaths
WHERE location='Syria'

-- LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATES COMAPRING TO POPULATION
SELECT location,population,MAX(total_cases) HIGHESTINFECTIONCOUNT ,MAX((total_cases/population))*100 AS PerPopulationInfected 
FROM CovidDeaths
Group by location,population
ORDER BY PerPopulationInfected desc

-- SHOWING COUNTRIES WITH THE HIGHEST DEATH RATES PER POPULATION
SELECT continent,MAX(CAST (total_deaths as int)) AS TotalDeaths
FROM CovidDeaths
WHERE continent IS NOT NULL
Group by continent
ORDER BY TotalDeaths desc


-- Catogotize by continent 
SELECT location,MAX(CAST (total_deaths as int)) AS TotalDeaths
FROM CovidDeaths
WHERE continent IS not NULL
Group by location
ORDER BY TotalDeaths desc

--Creating View for Showing the location with the highest death counts
Create View TotalDeathsPerLocation AS
SELECT location,MAX(CAST (total_deaths as int)) AS TotalDeaths
FROM CovidDeaths
WHERE continent IS not NULL
Group by location
--ORDER BY TotalDeaths desc 

Select *
FROM TotalDeathsPerLocation
Order by TotalDeaths desc




-- Showing the continent with the highest death counts
SELECT continent,MAX(CAST (total_deaths as int)) AS TotalDeaths
FROM CovidDeaths
WHERE continent IS not NULL
Group by continent
ORDER BY TotalDeaths desc

--Creating View for Showing the continent with the highest death counts

Create View TotalDeathsPerContinent AS
SELECT continent,MAX(CAST (total_deaths as int)) AS TotalDeaths
FROM CovidDeaths
WHERE continent IS not NULL
Group by continent
--ORDER BY TotalDeaths desc

Select *
FROM TotalDeathsPerContinent


-- Global Numbers
SELECT SUM(new_cases) NewCases,SUM(CAST(new_deaths as int)) NewDeaths , SUM(CAST(new_deaths as int))/SUM(new_cases)*100 NewDeathPercentage--total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathsPercentage 
FROM CovidDeaths
--WHERE location='Turkey'
WHERE continent IS not NULL
--GROUP BY date
--Order by date

--Looking at total population vs vaccination

SELECT distinct dea.continent ,dea.location , dea.date,dea.population ,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int )/2) over (PARTITION BY dea.location order by dea.location,dea.date) As RollingPeopleVaccinated 
FROM CovidDeaths dea
JOIN CovidVaccination vac
	ON dea.date=vac.date
	AND dea.location=vac.location
WHERE dea.continent IS NOT NULL 
ORDER BY 2,3


--USING CTE 
WITH PopulationvsVaccination(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated) AS
(
SELECT distinct dea.continent ,dea.location , dea.date,dea.population ,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int )/2) over (PARTITION BY dea.location order by dea.location,dea.date) As RollingPeopleVaccinated 
FROM CovidDeaths dea
JOIN CovidVaccination vac
	ON dea.date=vac.date
	AND dea.location=vac.location
WHERE dea.continent IS NOT NULL 
--ORDER BY 2,3
)
SELECT * ,(RollingPeopleVaccinated/population)*100
FROM PopulationvsVaccination

--USING TEMP TABLE 
DROP TABLE IF EXISTS #Temp_Table 
CREATE TABLE #Temp_Table 
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #Temp_Table
SELECT distinct dea.continent ,dea.location , dea.date,dea.population ,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int )/2) over (PARTITION BY dea.location order by dea.location,dea.date) As RollingPeopleVaccinated 
FROM CovidDeaths dea
JOIN CovidVaccination vac
	ON dea.date=vac.date
	AND dea.location=vac.location
WHERE dea.continent IS NOT NULL 
ORDER BY 3

SELECT * ,(RollingPeopleVaccinated/population)*100
FROM #Temp_Table


CREATE VIEW Temp_Table AS  
SELECT distinct dea.continent ,dea.location , dea.date,dea.population ,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int )/2) over (PARTITION BY dea.location order by dea.location,dea.date) As RollingPeopleVaccinated 
FROM CovidDeaths dea
JOIN CovidVaccination vac
	ON dea.date=vac.date
	AND dea.location=vac.location
WHERE dea.continent IS NOT NULL 
--ORDER BY 3

SELECT * 
FROM Temp_Table

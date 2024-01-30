
SELECT *
FROM Portfolio_project..['owid-covid-data$']
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM Portfolio_project..Vaccination_info$
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio_project..['owid-covid-data$']
ORDER BY 1,2

-- TOTAL CASES VS TOTAL DEATH
-- Shows likelihood of dying drom covid
SELECT location, date, total_cases, total_deaths, (TRY_CONVERT(float, total_deaths) / TRY_CONVERT(float, total_cases)) * 100 AS DeathPercentage
FROM Portfolio_project..['owid-covid-data$']
WHERE location LIKE '%pal'
ORDER BY 1,2

--Total Cases vs Population
SELECT location, date, total_cases,population, (TRY_CONVERT(float, total_cases) / TRY_CONVERT(float, population)) * 100 AS PercentPopulationInfected
FROM Portfolio_project..['owid-covid-data$']
WHERE location LIKE '%pal'
ORDER BY 1,2

-- Countries with Highest Infection Rate compared to population
SELECT location,population,MAX(total_cases) AS HighestInfectionCount, MAX((TRY_CONVERT(float, total_cases) / TRY_CONVERT(float, population))) * 100 AS PercentPopulationInfected 
FROM Portfolio_project..['owid-covid-data$']
--WHERE location LIKE '%pal'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


-- Countries with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM Portfolio_project..['owid-covid-data$']
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- BREAKING THINGS DOWN BY CONTINENT
-- Showing continents with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Portfolio_project..['owid-covid-data$']
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--
SELECT  SUM(new_cases) as total_cases, SUM(CAST(new_deaths aS int)) as total_deaths, SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 as Deathpercentage 
FROM Portfolio_project..['owid-covid-data$']
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


-- Total population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_project..['owid-covid-data$'] dea
Join Portfolio_project..Vaccination_info$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3



-- Using CTE to perform Calculation on Partition By in previous query
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_project..['owid-covid-data$'] dea
Join Portfolio_Project..Vaccination_info$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_project..['owid-covid-data$'] dea
Join Portfolio_project..Vaccination_info$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated




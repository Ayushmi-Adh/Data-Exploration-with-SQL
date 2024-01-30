# SQL COVID-19 Data Analysis Project
Certainly! Below is a detailed README file for the provided SQL queries. Please note that you may need to adapt this README to your specific preferences, include any specific instructions, or provide additional context as needed.

---

# COVID-19 Data Analysis SQL Queries

This repository contains a collection of SQL queries for analyzing COVID-19 data from the "owid-covid-data" and "Vaccination_info" datasets. The queries cover various aspects such as infection rates, death rates, and vaccination progress. The goal is to provide insights into the impact of the pandemic on a global and regional scale.

## Table of Contents

1. [Introduction](#introduction)
2. [Queries](#queries)
    - [Infection Analysis](#infection-analysis)
    - [Death Analysis](#death-analysis)
    - [Overall Statistics](#overall-statistics)
    - [Vaccination Analysis](#vaccination-analysis)
3. [Usage](#usage)
4. [Explanation of Queries](#explanation-of-queries)
5. [Examples](#examples)
6. [License](#license)

## Introduction

The COVID-19 pandemic has had a significant impact worldwide. Analyzing the data related to the spread of the virus, death rates, and vaccination progress is crucial for understanding the situation. This repository contains SQL queries designed to extract meaningful information from the available datasets.

## Queries

### Infection Analysis

1. **Countries with Highest Infection Rate Compared to Population:**
   - Identifies countries with the highest infection rates relative to their populations.
   ```sql
   -- Query 1
   SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((TRY_CONVERT(float, total_cases) / TRY_CONVERT(float, population))) * 100 AS PercentPopulationInfected 
   FROM owid-covid-data
   GROUP BY location, population
   ORDER BY PercentPopulationInfected DESC
   ```

2. **Likelihood of Dying from COVID-19:**
   - Shows the likelihood of dying from COVID-19 by calculating the death percentage.
   ```sql
   -- Query 2
   SELECT location, date, total_cases, total_deaths, (TRY_CONVERT(float, total_deaths) / TRY_CONVERT(float, total_cases)) * 100 AS DeathPercentage
   FROM owid-covid-data
   WHERE location LIKE '%pal'
   ORDER BY 1,2
   ```

3. **Total Cases vs Population:**
   - Compares total cases with the population, indicating the percentage of the population infected.
   ```sql
   -- Query 3
   SELECT location, date, total_cases, population, (TRY_CONVERT(float, total_cases) / TRY_CONVERT(float, population)) * 100 AS PercentPopulationInfected
   FROM owid-covid-data
   WHERE location LIKE '%pal'
   ORDER BY 1,2
   ```

### Death Analysis

4. **Countries with Highest Death Count per Population:**
   - Identifies countries with the highest death count per population.
   ```sql
   -- Query 4
   SELECT location, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
   FROM owid-covid-data
   WHERE continent IS NOT NULL
   GROUP BY location
   ORDER BY TotalDeathCount DESC
   ```

5. **Breaking Things Down by Continent:**
   - Shows continents with the highest death count per population.
   ```sql
   -- Query 5
   SELECT continent, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
   FROM owid-covid-data
   WHERE continent IS NOT NULL
   GROUP BY continent
   ORDER BY TotalDeathCount DESC
   ```

### Overall Statistics

6. **Global COVID-19 Statistics:**
   - Provides overall statistics such as total cases, total deaths, and death percentage globally.
   ```sql
   -- Query 6
   SELECT  SUM(new_cases) as total_cases, SUM(CAST(new_deaths as INT)) as total_deaths, SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 as Deathpercentage 
   FROM owid-covid-data
   WHERE continent is not null
   ORDER BY 1,2
   ```

### Vaccination Analysis

7. **Total Population vs Vaccinations:**
   - Shows the percentage of the population that has received at least one COVID vaccine over time.
   ```sql
   -- Query 7
   SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
   , SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
   From owid-covid-data dea
   Join Vaccination_info vac
   On dea.location = vac.location
   and dea.date = vac.date
   where dea.continent is not null 
   order by 2,3
   ```

8. **Using CTE to Perform Calculation on Partition By:**
   - Demonstrates the use of a Common Table Expression (CTE) for performing calculations on the partitioned result set.
   ```sql
   -- Query 8
   With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
   as
   (
   Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
   , SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
   From owid-covid-data dea
   Join Vaccination_info vac
   On dea.location = vac.location
   and dea.date = vac.date
   where dea.continent is not null 
   )
   Select *, (RollingPeopleVaccinated/Population)*100
   From PopvsVac
   ```

9. **Using Temporary Table for Calculations:**
   - Utilizes a temporary table to perform calculations on the partitioned result set.
   ```sql
   -- Query 9
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
   , SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
   From owid-covid-data dea
   Join Vaccination_info vac
   On dea.location = vac.location
   and dea.date = vac.date
   Select *, (RollingPeopleVaccinated/Population)*100
   From #PercentPopulationVaccinated
   ```

## Usage

To use these queries, follow these steps:

1. Ensure you have access to the "owid-covid-data" and "Vaccination_info" datasets in your SQL environment.
2. Copy the relevant

 queries from the repository.
3. Paste the queries into your SQL editor.
4. Execute the queries to retrieve the desired information.

## Explanation of Queries

Each query is commented for clarity, explaining the purpose and logic behind it. The queries are organized by categories, such as infection analysis, death analysis, overall statistics, and vaccination analysis.

## Examples

Here are a few examples of the queries in action:

1. **Top 10 Countries by Infection Rate:**
   ```sql
   -- Query 1
   SELECT location, MAX(total_cases) AS HighestInfectionCount, MAX((TRY_CONVERT(float, total_cases) / TRY_CONVERT(float, population))) * 100 AS PercentPopulationInfected 
   FROM owid-covid-data
   GROUP BY location, population
   ORDER BY PercentPopulationInfected DESC
   ```

2. **Percentage of Population Vaccinated Over Time:**
   ```sql
   -- Query 8
   With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
   as
   (
   Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
   , SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
   From owid-covid-data dea
   Join Vaccination_info vac
   On dea.location = vac.location
   and dea.date = vac.date
   where dea.continent is not null 
   )
   Select *, (RollingPeopleVaccinated/Population)*100
   From PopvsVac
   ```

## License

This project is licensed under the [MIT License](LICENSE).

---

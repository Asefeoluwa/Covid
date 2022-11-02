--Select*from covid_deaths
SELECT * FROM [SQL Tutorial].[dbo].[covid_deaths]
ORDER BY location, date;


-- Create a temp table "temp_covidexplore" to store the data we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
INTO #temp_covidexplore
FROM [SQL Tutorial]..covid_deaths
order by location, date;

select*from #temp_covidexplore
order by location, date;




-- Looking at total cases vs total deaths. 
-- Fascinating: The probability of dying after getting covid in Canada was at its peak 2020-Jun-08 with a whopping 8.5229%
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
From #temp_covidexplore
where location like '%Canada%'
order by location, date;



-- Looking at location with the highest cases
-- Fascinating: World seems to be the largest. I guess there are regional aggregrates in the location data.
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
From #temp_covidexplore
order by total_cases DESC;



-- Looking at the distinct location namesto confirm observation.
-- noticed regional names like Asia, Africa, Europe, World e.t.c  could be considered double counting
select DISTINCT location 
From #temp_covidexplore
ORDER BY location ASC;



-- Looking at Infection count per capita. 
-- Cyprus has highest Infection count with 67% of population infected
SELECT location, population, 
MAX(total_cases) as HighestInfectionCount, 
Max((total_cases/population))*100 as percentagepopinfected
FROM #temp_covidexplore
Group by location,population
ORDER BY percentagepopinfected desc;


-- Create new temp table without regional data.
-- Noticed that original data set has null in continent for regional entries in location.
SELECT location, date, total_cases, new_cases, total_deaths, population
INTO #temp_covidexplore2
FROM [SQL Tutorial]..covid_deaths
WHERE continent IS NOT NULL
order by location, date;


-- Showing death count by continent from larget to smallest 
SELECT continent, MAX(Cast(Total_deaths as int)) AS TotalDeath
FROM [SQL Tutorial]..covid_deaths
WHERE continent is not null
Group BY continent
Order by TotalDeath desc;

-- Global Numbers by date
SELECT date, SUM(new_cases) as total_cases, 
SUM(cast(new_deaths as int)) as total_deaths, 
SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM [SQL Tutorial]..covid_deaths
WHERE continent is not null -- to exclude regional locations Africa, Asia e.t.c
GROUP BY date
Order by 1,2;


-- Looking at Total Ppoulation vs Vaccinations
SELECT continent, location, date, population, new_vaccinations
FROM [SQL Tutorial]..covid_deaths
WHERE continent is not null
order by 2,3;


-- Creating a rolling count that adds up day by day
SELECT continent, location, date, population, new_vaccinations,
SUM(convert(float, new_vaccinations)) OVER(partition by location order by date) as RollingPplVacc
FROM [SQL Tutorial]..covid_deaths
WHERE continent is not null
order by 2,3;



-- Using a CTE because we want to create perecentage of population vaccinated per day in eevery country
With RollingVaccCount as (
SELECT continent, location, date, population, new_vaccinations,
SUM(convert(float, new_vaccinations)) OVER(partition by location order by date) as RollingPplVacc
FROM [SQL Tutorial]..covid_deaths
WHERE continent is not null)

select*, (RollingPplVacc/population)*100 as percentpopvaccinated
from RollingVaccCount;



-- Creating view to store data for future visualizations
CREATE VIEW DailyPercentPopultionVaccinated as
SELECT continent, location, date, population, new_vaccinations,
SUM(convert(float, new_vaccinations)) OVER(partition by location order by date) as RollingPplVacc
FROM [SQL Tutorial]..covid_deaths
WHERE continent is not null;


--THE END

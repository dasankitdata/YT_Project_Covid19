-- select now()

# Portfolio Project with COVID19 data.
# This part consists of Death due to covid data

-- Creating a database to work on the project and using the same.
use yt_covid19;

-- Importing the covid death data from csv files.
-- Use import wizard
-- Check import
-- SELECT * from covid_death;

ALTER TABLE coviddeaths
CHANGE COLUMN continent continent text DEFAULT NULL;

-- Selecting the important fields from the the dataset
SELECT 
	location, date, total_cases, new_cases, population, total_deaths
FROM 
	portfolioproject.coviddeaths
order by
	1,2;

    
-- Comparing deaths against the total number of cases
SELECT
	location,
	SUM(total_cases) AS TotalCases,
    SUM(total_deaths) AS TotalDeaths,
    (SUM(total_deaths)/SUM(total_cases))*100 AS PercentOfDeath
FROM
	portfolioproject.coviddeaths
-- WHERE
-- 	location = "India";
GROUP BY
	location
ORDER BY
	PercentOfDeath DESC;


-- Total cases against the population

SELECT
	location,
    total_cases,
    population,
    (total_cases/population)*100
FROM
	portfolioproject.coviddeaths;
    
-- Cases against the population country wise
SELECT
	location,
    MAX(total_cases) AS TotalCases,
    population,
	MAX((total_cases)/population)*100 AS PercentCases
FROM
	portfolioproject.coviddeaths
-- WHERE
-- 	location = "India"
GROUP BY
	location, population
ORDER BY
	PercentCases DESC;

-- India's statistics of the cases against the population
SELECT
	location,
    date,
    total_cases,
    population,
    (total_cases/population)*100 AS PercentCases
FROM
	portfolioproject.coviddeaths
WHERE 
	location = 'India'
ORDER BY
	date DESC;


-- Total deaths against the location
SELECT 
	location,
    SUM(total_deaths) AS DeathCount
FROM
	portfolioproject.coviddeaths
WHERE
	continent != location
GROUP BY
	location
ORDER BY
	DeathCount DESC;
    
-- updating the table to add all the continents where they are blank
-- where ever the continent is  "" add the data from the location column

-- alter the table to add a column with the name continents_clean
-- update the column with the values same as continent if it is not null and if null take the value of the location.
-- ALTER TABLE coviddeaths
-- ADD continents_clean text default null;

-- UPDATE coviddeaths
-- SET continents_clean = IF(continent = "", location, continent);

-- ALTER TABLE coviddeaths
-- DROP COLUMN continents_clean;

UPDATE coviddeaths
SET continent = IF(continent = "", location, continent);

-- getting data against each continent
SELECT
	continent,
    SUM(total_deaths) AS DeathCount,
    SUM(population) AS TotalPopulation
FROM
	portfolioproject.coviddeaths
-- WHERE
-- 	continent = "Asia"
GROUP BY
	continent
ORDER BY
	DeathCount DESC;


-- global cases and deaths
SELECT
	SUM(new_cases) AS TotalCases,
    SUM(new_deaths) AS TotalDeaths,
    (SUM(new_deaths)/SUM(new_cases))*100 AS DeathPercent
FROM
	portfolioproject.coviddeaths
WHERE
	continent != location;
-- Note
-- The rows where the continent is same as the location the data is repeated
-- Filter out the above mentioned cases as they skew the tota cases and other metrices


-- Joining the coviddeath and covidvaccine tables


-- checking vaccines tables for dirty data
-- SELECT
-- 	distinct continent
-- FROM
-- 	portfolioproject.covidvaccination;

-- Inner joining vaccines on deaths table.
SELECT *
FROM portfolioproject.coviddeaths AS codeath
JOIN portfolioproject.covidvaccination AS covac
ON codeath.location = covac.location AND codeath.date = covac.date;


-- Getting total population and vaccines
SELECT 
	codeath.continent,
    codeath.location,
    codeath.date,
    codeath.population,
    covac.new_vaccinations
FROM 
	portfolioproject.coviddeaths AS codeath
JOIN 
	portfolioproject.covidvaccination AS covac
ON 
	codeath.location = covac.location 
    AND codeath.date = covac.date
WHERE
	codeath.continent != codeath.location
    AND codeath.location = "India"
ORDER BY
	2,3;
    

-- perecent of population vaccinated
SELECT
	codeath.continent,
    codeath.location,
    -- codeath.date,
    codeath.population,
    -- SUM(codeath.new_deaths) AS TotalDeaths,
    -- SUM(covac.new_vaccinations) AS TotalVaccines,
    (SUM(codeath.new_deaths)/codeath.population)*100 AS PercentDeath,
    (sum(covac.new_vaccinations)/codeath.population)*100 AS PercentVaccinated
FROM 
	portfolioproject.coviddeaths AS codeath
JOIN 
	portfolioproject.covidvaccination AS covac
ON 
	codeath.location = covac.location 
    AND codeath.date = covac.date
WHERE
	codeath.continent != codeath.location
GROUP BY
	codeath.location
ORDER BY
	PercentVaccinated DESC;
    

-- Using partition to capture data
SELECT
	codeath.continent,
    codeath.location,
    codeath.date,
    codeath.population,
    covac.new_vaccinations,
	sum(covac.new_vaccinations) over (partition by codeath.location order by codeath.location, codeath.date) 
    AS RollingCount
FROM 
	portfolioproject.coviddeaths AS codeath
JOIN 
	portfolioproject.covidvaccination AS covac
ON 
	codeath.location = covac.location 
    AND codeath.date = covac.date
WHERE
	codeath.continent != codeath.location
    --  and codeath.location = "india"
ORDER BY
	2,3;
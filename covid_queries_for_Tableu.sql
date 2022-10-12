-- for Tableu visualizations


-- Death percentage worldwide
SELECT 
	SUM(new_cases) AS total_cases,
    SUM(CAST(new_deaths AS SIGNED)) AS total_deaths, 
    (SUM(CAST(new_deaths AS SIGNED)) / SUM(new_cases)) * 100 AS percentage_deaths
FROM coviddeaths;

-- Death percentage in Bangladesh
SELECT 
	SUM(new_cases) AS total_cases,
    SUM(CAST(new_deaths AS SIGNED)) AS total_deaths, 
    (SUM(CAST(new_deaths AS SIGNED)) / SUM(new_cases)) * 100 AS percentage_deaths
FROM coviddeaths
WHERE location = 'Bangladesh';

-- Country wise death count
SELECT continent, SUM(CAST(new_deaths as UNSIGNED)) as TotalDeathCount
FROM coviddeaths
WHERE location NOT IN ('World', 'European Union', 'International')
GROUP BY continent
ORDER BY TotalDeathCount DESC;


-- map illustration for location wise population infected
SELECT location,
	population, 
    MAX(total_cases) as HighestInfectionCount,
    MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM coviddeaths
GROUP BY location, population, date
ORDER BY  PercentPopulationInfected DESC;

-- Percentage population infected on specific dates throught the year 2020-21
SELECT location,
	population,
    CAST(date AS datetime),
    MAX(total_cases) AS HighestInfectionCount,
    Max((total_cases/population))*100 AS PercentPopulationInfected
FROM coviddeaths
GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC;


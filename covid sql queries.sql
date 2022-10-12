SELECT * FROM coviddeaths;

-- selecting useful data
SELECT Location,date, new_cases, total_cases, total_deaths, population 
FROM coviddeaths
 ORDER BY 1,2;

-- looking at relationship between total_deaths and total cases
-- rough likelihood of dying if you have covid in Bangladesh
SELECT Location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 AS percentage_deaths 
FROM coviddeaths
WHERE Location = 'Bangladesh'
ORDER BY 1,2;

-- seeing total_cases VS population
-- % of population who got covid
SELECT 
	Location, date, population, total_cases, 
	(total_cases / population)*100 AS percentage_infected
FROM coviddeaths
WHERE Location = 'Bangladesh'
ORDER BY 1,2;

-- Which countries has the highest infection rates
SELECT 
	Location,population,
	MAX(total_cases), 
	MAX((total_cases / population)*100) AS percentage_infected
FROM coviddeaths
GROUP BY Location, population
ORDER BY percentage_infected DESC;

-- countries with highest death count
-- CAST converts data types. Did this for accuracy and sorting issues 
-- SIGNED = integer
SELECT Location, MAX(CAST(total_deaths AS SIGNED)) AS total_death_counts
FROM coviddeaths 
GROUP BY Location
ORDER BY total_death_counts DESC;

-- Breaking down continent wise
-- continent with highest death counts
SELECT continent, MAX(CAST(total_deaths AS SIGNED)) AS total_death_counts
FROM coviddeaths 
GROUP BY continent
ORDER BY total_death_counts DESC;

-- Global Numbers
SELECT 
	SUM(new_cases) as Total_cases, 
	SUM(CAST(new_deaths AS SIGNED)) AS Total_deaths, 
    (SUM(CAST(new_deaths AS SIGNED)) / SUM(new_cases)) * 100 AS Death_percentage 
FROM coviddeaths;


-- Joining death and vaccination table together
SELECT * 
FROM coviddeaths AS deaths
JOIN covidvaccinations AS vac
	ON deaths.location = vac.location AND deaths.date = vac.date;

-- Total Polulation VS Vaccinations 
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations, 
	   SUM(CAST(vac.new_vaccinations AS SIGNED))
			OVER (
				PARTITION BY deaths.location 
                ORDER BY deaths.location, deaths.date
                ) AS RollingPeopleVaccinated
FROM coviddeaths AS deaths
JOIN covidvaccinations AS vac
	ON deaths.location = vac.location AND deaths.date = vac.date
WHERE deaths.continent IS NOT NULL
ORDER BY 2,3;
    
    
-- now see how many % of the people vaccinated
-- using the prev query and buildng on to the nested query
-- need to use CTE (new virtual table)
-- popVSvac is the new table using these new columns

WITH popVSvac (continent,location, date, population, new_vaccinations, RollingPeopleVaccinated ) 
AS (
	SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations, 
		   SUM(CAST(vac.new_vaccinations AS SIGNED))
				OVER (
					PARTITION BY deaths.location 
					ORDER BY deaths.location, deaths.date
					) AS RollingPeopleVaccinated
	FROM coviddeaths AS deaths
	JOIN covidvaccinations AS vac
		ON deaths.location = vac.location AND deaths.date = vac.date
	WHERE deaths.continent IS NOT NULL
	ORDER BY 2,3
)
SELECT * , (RollingPeopleVaccinated / population) * 100
FROM popVSvac;

-- Temp Table
DROP TABLE IF EXISTS PopulationVaccinated;
CREATE Table PopulationVaccinated(
	continent varchar(255),
    location varchar(255),
    date datetime,
    population numeric,
    new_vaccinations BIGINT,
    rollingPeopleVaccinated numeric
);

-- Populate the new table created
INSERT INTO PopulationVaccinated
SELECT  deaths.continent, deaths.location, CAST(deaths.date AS DATETIME), deaths.population, vac.new_vaccinations, 
	    SUM(CAST(vac.new_vaccinations AS DOUBLE))
			OVER (
				PARTITION BY deaths.location 
				ORDER BY deaths.location, deaths.date
				) AS RollingPeopleVaccinated
	FROM coviddeaths AS deaths
	JOIN covidvaccinations AS vac
		ON deaths.location = vac.location AND deaths.date = vac.date
	WHERE deaths.continent IS NOT NULL;

SELECT * , (RollingPeopleVaccinated / population) * 100
FROM PopulationVaccinated;

-- Creating View for visualisation 
CREATE VIEW  PopulationVaccinated AS
SELECT  deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations, 
	    SUM(CAST(vac.new_vaccinations AS SIGNED))
			OVER (
				PARTITION BY deaths.location 
				ORDER BY deaths.location, deaths.date
				) AS RollingPeopleVaccinated
	FROM coviddeaths AS deaths
	JOIN covidvaccinations AS vac
		ON deaths.location = vac.location AND deaths.date = vac.date;

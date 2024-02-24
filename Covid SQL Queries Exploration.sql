
--Covid data exploration

-- Used skills: Joins, Cte, Temp Table, Creating Veiw Table, Aggregate Functions, Windows Functions, Cast & Convert.




SELECT * 
FROM [PortfolioProject1].[dbo].[CovidDeaths$]
WHERE continent is not	NULL
ORDER BY 3, 4

--SELECT [location]
--      ,[date]
--      ,[population]
--      ,[total_cases]
--      ,[total_deaths]
--      FROM [PortfolioProject1].[dbo].[CovidDeaths$]
--	  Order by 1, 2

	  --we are looking at death_rate by total_cases in united states
	 
	 SELECT [location]
      ,[date]
      ,[population]
      ,[total_cases]
      ,[total_deaths]
	  ,(total_deaths/total_cases)*100 as Death_rate
      FROM [PortfolioProject1].[dbo].[CovidDeaths$]
	  where location = 'United States'
	  Order by 1, 2

	 -- Ww're gonna look at what percentage of people in America got covid 
	
	SELECT [location]
      ,[date]
      ,[population]
      ,[total_cases]
	  ,(total_cases/population)*100 as total_cases_rate
      ,[total_deaths]
      FROM [PortfolioProject1].[dbo].[CovidDeaths$]
	  where location = 'United States'
	  Order by 1, 2

	  -- now we're gonna look at highest infection and infection_rate by country and population

	  SELECT [location]
      ,[population]
      ,max([total_cases]) as highest_infection_count
	  ,max((total_cases/population))*100 as highest_infection
      FROM [PortfolioProject1].[dbo].[CovidDeaths$]
	  Group by location, population
	  Order by highest_infection desc

	--  in this area we are going to look at the highest death_count by country

	  SELECT [location]
      ,max(CAST(total_deaths as int)) as highest_death_count
      FROM [PortfolioProject1].[dbo].[CovidDeaths$]
	  WHERE continent is not	NULL
	  Group by location
	  Order by highest_death_count desc

	  --death count by continent

	  SELECT continent
      ,max(CAST(total_deaths as int)) as highest_death_count
      FROM [PortfolioProject1].[dbo].[CovidDeaths$]
	  WHERE continent is not NULL
	  Group by continent
	  Order by highest_death_count desc

	--  Global

	SELECT 
		
      SUM([new_cases]) AS	total_cases
      ,SUM(cast([new_deaths] as int)) AS total_deaths
	  ,SUM(cast([new_deaths] as int))/SUM([new_cases])*100 as death_rate
      FROM [PortfolioProject1].[dbo].[CovidDeaths$]
	  where continent is not null
	  
	-- Looking at total population vs total vaccination by joining two tables

	SELECT 
	 D.[continent]
	,D.[location]
	,D.[date]
	,D.[population]
	,V.[new_vaccinations]
	,SUM(CONVERT(int ,V.[new_vaccinations])) OVER (Partition by V.[location] ORDER BY D.location, D.date) As RollingPeopleVaccinated
	FROM PortfolioProject1..CovidDeaths$ D
	JOIN PortfolioProject1..CovidVaccinations$ V
	ON D.location = V.location
	AND D.date = V.date
	WHERE D.continent IS NOT NULL 
	order by 2, 3

	--with this method we can actually use new table with column name to do some arithmetic operators and other queries

	with popvsvac([continent], [location], [date], [population], [new_vaccinations], RollingPeopleVaccinated)
	as (SELECT 
	 D.[continent]
	,D.[location]
	,D.[date]
	,D.[population]
	,V.[new_vaccinations]
	,SUM(CONVERT(int ,V.[new_vaccinations])) OVER (Partition by V.[location] ORDER BY D.location, D.date) As RollingPeopleVaccinated 
	FROM PortfolioProject1..CovidDeaths$ D
	JOIN PortfolioProject1..CovidVaccinations$ V
	ON D.location = V.location
	AND D.date = V.date
	WHERE D.continent IS NOT NULL 
	--order by 2, 3
	)
	SELECT * , (RollingPeopleVaccinated/population)*100 as Rolling_Vaccination_Rate
	FROM popvsvac

	
	-- Creating TEMP TABLE it is a temporary table and it doesn't exist on database.
	
	Drop Table if exists #PopulationAndVaccinationPercent
	Create Table #PopulationAndVaccinationPercent
	(
	continent nvarchar(255),
	location nvarchar(255), 
	date datetime,
	population numeric,
	new_vaccination numeric,
	RollingPeopleVaccinated numeric
	)
	
	insert into #PopulationAndVaccinationPercent
	SELECT 
	 D.[continent]
	,D.[location]
	,D.[date]
	,D.[population]
	,V.[new_vaccinations]
	,SUM(CONVERT(int ,V.[new_vaccinations])) OVER (Partition by V.[location] ORDER BY D.location, D.date) As RollingPeopleVaccinated 
	FROM PortfolioProject1..CovidDeaths$ D
	JOIN PortfolioProject1..CovidVaccinations$ V
	ON D.location = V.location
	AND D.date = V.date
	--WHERE D.continent IS NOT NULL 
	--order by 2, 3
	
	SELECT * , (RollingPeopleVaccinated/population)*100 as Rolling_Vaccination_Rate
	FROM #PopulationAndVaccinationPercent

	--We can create new saperate table with the create View which will save in database


	Create View PopulationAndVaccinationPercent AS
	SELECT 
	 D.[continent]
	,D.[location]
	,D.[date]
	,D.[population]
	,V.[new_vaccinations]
	,SUM(CONVERT(bigint ,V.[new_vaccinations])) OVER (Partition by V.[location] ORDER BY D.location, D.date) As RollingPeopleVaccinated 
	FROM PortfolioProject1..CovidDeaths$ D
	JOIN PortfolioProject1..CovidVaccinations$ V
	ON D.location = V.location
	AND D.date = V.date
	WHERE D.continent IS NOT NULL 
	--order by 2, 3
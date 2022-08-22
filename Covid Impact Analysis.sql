SELECT * 
FROM [Covid Impact Analysis].dbo.CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT * 
--FROM [Covid Impact Analysis].dbo.CovidVaccinations
--ORDER BY 3,4

-- Select Data to be used in project

Select Location, date, total_cases, new_cases, total_deaths, population
FROM [Covid Impact Analysis].dbo.CovidDeaths
Order by 1,2

--Looking at total cases vs total deaths in United States. Shows likelihood of dying from Covid in USA

Select Location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [Covid Impact Analysis].dbo.CovidDeaths
Where location like '%states%'
and continent is not null
Order by 1,2


--Looking at total cases vs population
--Shows prcentage of US population that contracted Covid

Select Location, date, total_cases, population, (total_cases/population)*100 as [percentage]
FROM [Covid Impact Analysis].dbo.CovidDeaths
Where location like '%states%'
Order by 1,2


-- Looking at countries with highest infection rate compared to population

Select Location, MAX(total_cases) as HighestInfectionRate, population, (MAX(total_cases/population))*100 as [percentageinfected]
FROM [Covid Impact Analysis].dbo.CovidDeaths
--Where location like '%states%'
GROUP BY Location, Population
Order by [percentageinfected] desc


-- Showing the Countries with the highest Death Count per Capita from Covid


Select Location, MAX(cast(total_deaths as int)) as TotalDeaths
FROM [Covid Impact Analysis].dbo.CovidDeaths
--Where location like '%states%'
Where continent is not null
GROUP BY Location
Order by TotalDeaths desc


--Let's look at deaths by continent

Select continent, MAX(cast(total_deaths as int)) as TotalDeaths
FROM [Covid Impact Analysis].dbo.CovidDeaths
--Where location like '%states%'
Where continent is not null
GROUP BY continent
Order by TotalDeaths desc


--Showing continents ordered by death count in descending order

Select location, MAX(cast(total_deaths as int)) as TotalDeaths
FROM [Covid Impact Analysis].dbo.CovidDeaths
Where continent is null
GROUP BY location
Order by TotalDeaths desc


-- Running Global Numbers

Select date, sum(new_cases) as [Total Cases], sum(cast(new_deaths as int)) as [Total Deaths], 
sum(cast(new_deaths as int))/sum(new_cases)*100 as [Death Percentage]
FROM dbo.CovidDeaths
where continent is not null
Group by date
Order by 1,2


--Most up to date global number

Select sum(new_cases) as [Total Cases], sum(cast(new_deaths as int)) as [Total Deaths], 
sum(cast(new_deaths as int))/sum(new_cases)*100 as [Death Percentage]
FROM dbo.CovidDeaths
where continent is not null
Order by 1,2



-- Looking at Total Populations vs # of Vaccines

Select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations,
 sum(cast(vacc.new_vaccinations as int)) over (partition by deaths.location order by deaths.location, deaths.date)
 as RollingPeopleVaccinated
FROM CovidDeaths deaths
JOIN CovidVaccinations vacc
	ON deaths.location = vacc.location
	and deaths.date = vacc.date
where deaths.continent is not null
ORDER BY 2,3


--Using Common Table Expressions

With PopvsVacc (continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations,
 sum(cast(vacc.new_vaccinations as int)) OVER (partition by deaths.location order by deaths.location
 , deaths.date) as RollingPeopleVaccinated
FROM dbo.CovidDeaths deaths
JOIN dbo.CovidVaccinations vacc
	ON deaths.location = vacc.location
	and deaths.date = vacc.date
where deaths.continent is not null
--ORDER BY 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVacc


--Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations,
 sum(cast(vacc.new_vaccinations as int)) OVER (partition by deaths.location order by deaths.location
 , deaths.date) as RollingPeopleVaccinated
FROM dbo.CovidDeaths deaths
JOIN dbo.CovidVaccinations vacc
	ON deaths.location = vacc.location
	and deaths.date = vacc.date
where deaths.continent is not null
--ORDER BY 2,3

Select *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating a view to store data for visualization

Create view PercentPopulationVaccinated as
Select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations,
 sum(cast(vacc.new_vaccinations as int)) OVER (partition by deaths.location order by deaths.location
 , deaths.date) as RollingPeopleVaccinated
FROM dbo.CovidDeaths deaths
JOIN dbo.CovidVaccinations vacc
	ON deaths.location = vacc.location
	and deaths.date = vacc.date
where deaths.continent is not null
--ORDER BY 2,3

Select *
FROM PercentPopulationVaccinated
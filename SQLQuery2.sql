select * 
from PortfolioSqlProject..CovidDeaths
where continent is not null
order by 3,4


--select *
--from PortfolioSqlProject..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

select Location, Date, Total_cases, new_cases,Total_deaths, Population
from PortfolioSqlProject..CovidDeaths
where continent is not null
order by 1,2

--Looking at Total Cases vs. Total Deaths
--Shows the lkelihood of dying if you contracted covid in your country

select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioSqlProject..CovidDeaths
where continent is not null
order by 1,2
 
 Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioSqlProject..CovidDeaths
Where location like '%%'
and continent is not null 
order by 1,2

--Looking at Total Cases vs. Population
--Shows what percentage of population got covid

select Location, date,population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioSqlProject..CovidDeaths
order by 1,2

--Looking at countries with highest infection rate compared to population

select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioSqlProject..CovidDeaths
group by location, population
order by PercentPopulationInfected desc

--Showing the countries with the highest death count per population

select Location, MAX (cast(total_deaths as int)) as TotalDeathCount
from PortfolioSqlProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount  desc

--let's break things down by continent
--Showing the continents with the highest death count per population

select continent, MAX (cast(total_deaths as int)) as TotalDeathCount
from PortfolioSqlProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount  desc

--Global Numbers
 
 Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioSqlProject..CovidDeaths
where continent is not null 
--Group By date
order by 1,2

--Looking at total population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
 from PortfolioSqlProject..CovidDeaths dea
 join PortfolioSqlProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea. date = vac. date 
  where dea.continent is not null
  order by 1,2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
 from PortfolioSqlProject..CovidDeaths dea
 join PortfolioSqlProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea. date = vac. date 
  where dea.continent is not null
  --order by 2,3
  )
  select *, (RollingPeopleVaccinated/Population)
  from PopvsVac


  --Temp Table

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
From PortfolioSqlProject..CovidDeaths dea
Join PortfolioSqlProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating view to store data for later visuals

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioSqlProject..CovidDeaths dea
Join PortfolioSqlProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select * 
from percentpopulationvaccinated

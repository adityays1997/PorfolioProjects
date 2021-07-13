-- https://ourworldindata.org/covid-deaths
Select *
From PortfolioProject..CovidDeaths$
order by 3,4

Select *
From PortfolioProject..CovidVaccinations$
order by 3,4

-- Selecting Data being used

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
Order by 1,2


-- Total cases vs Total Deaths
-- Likelihood of dying if you contract COVID in India
Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as Percentpopulation
From PortfolioProject..CovidDeaths$
Where location like '%India%'
Order by 1,2

--Total Cases vs Population
--Percentage of population infected with Covid

Select location, date, total_cases,population, (total_cases/population)*100 as Percentpopulation
From PortfolioProject..CovidDeaths$
Where location like '%India%'
Order by 1,2

-- Countries with Highest Infection Rate compared to Population

Select location,population, MAX(total_cases) as HighestInfectionrate, MAX((total_cases/population))*100 as PercentpopulationInfected
From PortfolioProject..CovidDeaths$
Group by location,population
Order by PercentpopulationInfected desc

-- Countries with highest death count per population

Select location, MAX(cast(total_deaths as int)) as Totaldeathcount
From PortfolioProject..CovidDeaths$
where continent is not null
Group by location,population
Order by Totaldeathcount desc

-- By continent
-- This does not include Canada in North America and so on
Select continent, MAX(cast(total_deaths as int)) as Totaldeathcount
From PortfolioProject..CovidDeaths$
where continent is not null
Group by continent
Order by Totaldeathcount desc

-- Correct method 
Select location, MAX(cast(total_deaths as int)) as Totaldeathcount
From PortfolioProject..CovidDeaths$
where continent is null
Group by location
Order by Totaldeathcount desc

-- Continents with highest death count per population.

Select continent, MAX(cast(total_deaths as int)) as Totaldeathcount
From PortfolioProject..CovidDeaths$
where continent is not null
Group by continent
Order by Totaldeathcount desc


-- Global numbers of new cases and new deaths per day irrestpective of Location 

Select date, SUM(new_cases), SUM(cast(new_deaths as int))--, (total_deaths/total_cases)*100 as Percentpopulation
From PortfolioProject..CovidDeaths$
where continent is not null
group by date
Order by 1,2

-- Global numbers 

Select date, SUM(new_cases) as totalcases, SUM(cast(new_deaths as int)) as totaldeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercentage
From PortfolioProject..CovidDeaths$
where continent is not null
group by date
Order by 1,2

-- Removing date to give total new cases and deaths across the world
Select SUM(new_cases) as totalcases, SUM(cast(new_deaths as int)) as totaldeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercentage
From PortfolioProject..CovidDeaths$
where continent is not null
Order by 1,2

-- Join both tables
Select * 
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
 on dea.location = vac.location
 and dea.date = vac.date

-- Total Population vs Vaccination and rolling count by location

Select dea.continent, dea.location, dea.date, dea.population, new_vaccinations, Sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 2,3

 -- Number of people vaccinated in that country by CTE

With PopvsVac (continent, location, date, population, new_vaccinations, Rollingpeoplevaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated --(Rollingpeoplevaccinated/population)*100 As
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
)
 Select *, (Rollingpeoplevaccinated/population)*100
 From PopvsVac


-- Temp table

Drop Table if exists #PercentPopulationvaccinated
Create Table #PercentPopulationvaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rollingpeoplevaccinated numeric
)

insert into #PercentPopulationvaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated --(Rollingpeoplevaccinated/population)*100 As
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null

 Select *, (Rollingpeoplevaccinated/population)*100
 From #PercentPopulationvaccinated




 -- data for visulaisation view

 Create View Percentpopulationvaccinated as 
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated --(Rollingpeoplevaccinated/population)*100 As
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null

 Select *
 From Percentpopulationvaccinated
 

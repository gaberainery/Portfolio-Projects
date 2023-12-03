Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4


Select location, date, Total_cases, new_cases, total_deaths, Population
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2


--Looking at Total Cases Vs Total Deaths
-- Shows likelihood of dying if you contract covid in the United States
Select location, date, Total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null
Order by 1,2



-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select location, date, population, Total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null
Order by 1,2


-- Looking at Countries with highest infection Rate compared to Population

Select location, population, Max(Total_cases) as HighestInfectionCount, max((total_cases/population))*100 as
	PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by location, population
Order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by location
Order by TotalDeathCount desc


--Let's Break Things Down By Continent

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null
Group by location
Order by TotalDeathCount desc



-- Global Numbers

Select Sum(new_cases) as total_cases, Sum(Cast(new_deaths as int)) as total_deaths, 
	Sum(Cast(new_deaths as int))/Sum(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group By Date
Order by 1,2

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Cast(vac.new_vaccinations as bigint)) over (partition by dea.location Order by dea.location,
	dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--Use CTE

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Cast(vac.new_vaccinations as bigint)) over (partition by dea.location Order by dea.location,
	dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select*, (RollingPeopleVaccinated/Population)*100
as Percentage_RPV_per_Population
From PopvsVac

--Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated Numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Cast(vac.new_vaccinations as bigint)) over (partition by dea.location Order by dea.location,
	dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
as Percentage_RPV_per_Population
From #PercentPopulationVaccinated


--Creating View to storre data for later visualtions

Delete View PercentPopulationVaccinated as 
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null
Group by location
--Order by TotalDeathCount desc

Create View PercentagePopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Cast(vac.new_vaccinations as bigint)) over (partition by dea.location Order by dea.location,
	dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Create View ContinentPopulationVaccinated as 
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null
Group by location
--Order by TotalDeathCount desc


-- Test Site
Select *
From ContinentPopulationVaccinated
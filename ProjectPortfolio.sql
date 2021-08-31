Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

-- Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the Likelyhood of dying if you contract Covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
and is not null
Order by 1,2

--Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select location, date, Population, total_cases,  (total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

Select location, Population, MAX(total_cases) As HighestInfectionCount,  Max(total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by location,population
Order by PercentagePopulationInfected desc

--Showing Countries with Highest Death Count per Population

Select continent, MAX (cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc

-- Showing continents with the highest death count per population

Select continent, MAX (cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc


-- GLOABAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(new_cases)* 100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
--Group By date
Order by 1,2


-- Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM (cast (vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea. date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject.. CovidVaccinations vac
	On dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null
Order by 2,3


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM (cast (vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea. date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject.. CovidVaccinations vac
	On dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
From PopvsVac

--Temp Table

Drop Table if exists #PercentPopulationVaccinated
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
, SUM (cast (vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea. date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject.. CovidVaccinations vac
	On dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null

Select * , (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM (cast (vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea. date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject.. CovidVaccinations vac
	On dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null

select *
From PercentPopulationVaccinated

Drop view PercentPopulationVaccinated
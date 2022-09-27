select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

-- Select data to be used
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- looking at total cases vs total deaths
select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%Nigeria%' and continent is not null
order by 1,2

-- shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--looking at total cases vs population
select location, date, total_cases, population,(total_cases/population)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

-- looking at total cases vs population
-- shows what percentage of population got covid
select location, date, total_cases, population,(total_cases/population)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%Nigeria%'
order by 1,2

select location, date, total_cases, population,(total_cases/population)*100 as PercentPopulation
from PortfolioProject..CovidDeaths
--where location like '%Nigeria%'
order by 1,2

-- looking at countries with highest infection rate compared to populations
select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulation
from PortfolioProject..CovidDeaths
--where location like '%Nigeria%'
group by location, population
order by PercentPopulation desc

-- showing countries with the highest death count per population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount, round(AVG(median_age), 2) as AvgMedianAge
from PortfolioProject..CovidDeaths
--where location like '%Nigeria%'
where continent is not null
group by location, median_age
order by TotalDeathCount desc

-- checking data by continent
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%Nigeria%'
where continent is null
group by location
order by TotalDeathCount desc


-- showing continents with the highest death count
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount, ROUND(avg(median_age), 2)
from PortfolioProject..CovidDeaths
--where location like '%Nigeria%'
where continent is not null
group by continent
order by TotalDeathCount desc

-- looking at continents with highest infection rate compared to populations
select continent, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulation
from PortfolioProject..CovidDeaths
--where location like '%Nigeria%'
where continent is not null
group by continent, population
order by PercentPopulation desc


-- global numbers
select date, sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%Nigeria%' 
where continent is not null
group by date
order by 1,2

-- death percentage across the world
select sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%Nigeria%' 
where continent is not null
--group by date
order by 1,2

-- death by median age
select sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage, avg(median_age) as average_medianage
from PortfolioProject..CovidDeaths
--where location like '%Nigeria%' 
where continent is not null
--group by date
order by 1,2

-- looking at total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) 
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--using cte
with popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
as 
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) 
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from popvsvac

--temp table

DROP Table if exists #Percentpopulationvaccinated
create table #Percentpopulationvaccinated
(continent nvarchar(255), location nvarchar(255), date datetime, population numeric, new_vaccinations numeric,
RollingPeopleVaccinated numeric)
insert into #Percentpopulationvaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) 
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--order by 2,3
select *, (RollingPeopleVaccinated/population)*100
from #Percentpopulationvaccinated


-- creating view to store data for later visualizations
Create view Percentagepopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) 
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


Create view Globaldeath as
select sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage, avg(median_age) as average_medianage
from PortfolioProject..CovidDeaths
--where location like '%Nigeria%' 
where continent is not null
--group by date
--order by 1,2

create view percentagepopinfected as
select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulation
from PortfolioProject..CovidDeaths
--where location like '%Nigeria%'
group by location, population
--order by PercentPopulation desc

create view totaldeathcount as
select location, MAX(cast(total_deaths as int)) as TotalDeathCount, round(AVG(median_age), 2) as AvgMedianAge
from PortfolioProject..CovidDeaths
--where location like '%Nigeria%'
where continent is not null
group by location, median_age
--order by TotalDeathCount desc

create view deathcountbycontinent as
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount, ROUND(avg(median_age), 2) as avgmedianage
from PortfolioProject..CovidDeaths
--where location like '%Nigeria%'
where continent is not null
group by continent
--order by TotalDeathCount desc


-- 
select *
from Percentagepopulationvaccinated
select*
from [Portofolio Project]..CovidDeath1

select location, date, total_cases, New_cases, total_deaths, population
from [Portofolio Project]..CovidDeath1
where continent is not null
order by 1, 2

--looking at total_cases vs Total_deaths
--showing likelihood of dying if you contract covid	 in your country
select  location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentPopulationInfection
FROM [Portofolio Project]..CovidDeath1
where location like 'united states'
and continent is not null
order by 1, 2

--looking at country with highestinfection
select  location, Population, max (total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfection
FROM [Portofolio Project]..CovidDeath1
--where location like '%states%'
where continent is not null
Group by location, Population
order by PercentPopulationInfection desc

-- showing country with highest death count per population
select  location, Max (cast (total_deaths as int)) as TotalDeathCount
FROM [Portofolio Project]..CovidDeath1
--where location like '%states%'
where continent is not null
Group by location, Population
order by TotalDeathCount desc


-- lets break things down by continent

select  location, Max (cast (total_deaths as int)) as TotalDeathCount
FROM [Portofolio Project]..CovidDeath1
--where location like '%states%'
where continent is not null
Group by location
order by TotalDeathCount desc

--showing continent with the highest death count per population
select  location, Max (cast (total_deaths as int)) as TotalDeathCount
FROM [Portofolio Project]..CovidDeath1
--where location like '%states%'
where continent is not null
Group by location
order by TotalDeathCount desc

--global numbers
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathsPercentage
FROM [Portofolio Project]..CovidDeath1
--where location like '%states%'
where continent is not null
--group by date
order by 1, 2

--Looking at total population vs vaccination

select dea.continent,	dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
from [Portofolio Project]..CovidDeath1 dea
join [Portofolio Project]..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccination,  RollingPeopleVaccinated)
as
(
select dea.continent,	dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
from [Portofolio Project]..CovidDeath1 dea
join [Portofolio Project]..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3 
)
Select*, (RollingPeopleVaccinated/Population)*100 as		
from PopvsVac

--temp table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime, 
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent,	dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
from [Portofolio Project]..CovidDeath1 dea
join [Portofolio Project]..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
Select*, (RollingPeopleVaccinated/Population)*100 
from #PercentPopulationVaccinated

--Create View To Store Data For Later Visualization

Create view PercentPopulationVaccinated as
select dea.continent,	dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
from [Portofolio Project]..CovidDeath1 dea
join [Portofolio Project]..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3 
 

 select *
 from PercentPopulationVaccinated


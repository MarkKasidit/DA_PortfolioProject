select Location, date, total_cases, new_cases, total_deaths, population
from [dbo].[CovidDeaths]
order by 1, 2

-- total cases vs. total deaths
select Location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as DeathPercentage
from [dbo].[CovidDeaths]
--where location like '%states%'
order by 1, 2

-- Looking at countries with Highest Infection Rate compared to Population
select Location, population, max(total_cases) as HighestInfectionCount, max((total_cases / population) * 100) as 
	PercentPopulationInfected
from [dbo].[CovidDeaths]
group by Location, population
--where location like '%states%'
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population

select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from [dbo].[CovidDeaths]
where continent is not null
Group by Location
order by TotalDeathCount desc

-- Let's break things down by continent 
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from [dbo].[CovidDeaths]
where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global Number
select date, SUM(new_cases), sum(cast(new_deaths as int)), sum(cast(new_deaths as int)) / SUM(new_cases) * 100 as DeathPercentage
from [dbo].[CovidDeaths]
where continent is not null
Group by date
order by 1

-- Looking at total population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
where dea.continent is not null
order by  2, 3

-- Use CTE
With PopvsVac (Continet, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated / Population) * 100
from PopvsVac


--Temp Table

--DROP Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
	Continent nvarchar(255)
	,Location nvarchar(255)
	,Date datetime
	,Population numeric
	,New_Vaccinations numeric
	,RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated / Population) * 100
from #PercentPopulationVaccinated


-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
where dea.continent is not null

select * from PercentPopulationVaccinated
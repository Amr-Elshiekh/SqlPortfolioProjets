select location,date,total_cases,total_deaths,population,(total_deaths/total_cases)*100 as DeathPercentage,(total_cases/population)*100 AS CasesToPopulation
from Portfolio.. Deaths
where location like('%Egy%')

-- Looking at the country with the highest infection rate to the population 

select location,Max(cast( total_cases as int)),population ,Max(total_cases/population)*100 as CasesVsPopulation
from Portfolio.. Deaths

group by location , population
order by CasesVsPopulation desc

--Looking at the countries with the highest death cases

select location,max(cast(total_deaths as int)) as highestDeathCases
from Portfolio.. Deaths
where continent is not null
group by location
order by highestDeathCases desc

-- showing the death cases per continent according to population
select continent,max(cast(total_deaths as int)) as TotalDeathCount
from Portfolio.. Deaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- Looking for total population vs total vaccination

select dea.date,Dea.population,Dea.location,Vac.total_vaccinations
from Portfolio.. Deaths Dea
join Portfolio.. Vaccination Vac
on Dea.population=Vac.total_vaccinations

--CTE
with PopvsVac(continent,location,date,population,new_vaccinations,RollingPepoleVaccinated)
as
(select dea.continent,dea.location,dea.date ,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) 
over(partition by dea.location  order by dea.location,dea.date)as RollingPepoleVaccinated
from Portfolio.. Deaths dea
join Portfolio.. Vaccination vac
on dea.location=vac.location
and dea.date=vac.date
where dea.location is not null
)
select * ,(RollingPepoleVaccinated/population)*100
from PopvsVac


--Temp Table

create table #PercentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPepoleVaccinated numeric
)
insert into #PercentagePopulationVaccinated
select dea.continent,dea.location,dea.date ,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) 
over(partition by dea.location  order by dea.location,dea.date)as RollingPepoleVaccinated
from Portfolio.. Deaths dea
join Portfolio.. Vaccination vac
on dea.location=vac.location
and dea.date=vac.date
where dea.location is not null
select * ,(RollingPepoleVaccinated/population)*100
from #PercentagePopulationVaccinated

-- Creating View to store data for later visualization 

create view PercentagePopulationVaccinated as
select dea.continent,dea.location,dea.date ,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) 
over(partition by dea.location  order by dea.location,dea.date)as RollingPepoleVaccinated
from Portfolio.. Deaths dea
join Portfolio.. Vaccination vac
on dea.location=vac.location
and dea.date=vac.date
where dea.location is not null

select * ,(RollingPepoleVaccinated/population)*100
from PercentagePopulationVaccinated
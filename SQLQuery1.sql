Select *
From Portfolio_project..CovidDeaths
Where continent is not NULL
Order by 3,4

--Select *
--From Portfolio_project..CovidVaccinations
--Order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From Portfolio_project..CovidDeaths
Order by 1,2

--Looking at Total death vs Total cases and understand the relationship showing likelihood of death
Select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Per_Case_Percentage
From Portfolio_project..CovidDeaths
Where location like '%states%'
Order by 1,2

--Looking at Population vs Total cases and understand the relationship of size and getting infected
Select location, date, total_cases, new_cases, total_deaths, (total_cases/population)*100 as Death_Per_Case_Percentage
From Portfolio_project..CovidDeaths
--Where location like '%states%'
Order by 1,2

--Show Countries with the highest death count
Select location,  MAX(cast(total_deaths as int)) as Total_Death_Count
From Portfolio_project..CovidDeaths
Where continent is not NULL
--Where location like '%states%'
Group By location
order By Total_Death_Count desc

Select continent,  MAX(cast(total_deaths as int)) as Total_Death_Count
From Portfolio_project..CovidDeaths
Where continent is not NULL
--Where location like '%states%'
Group By continent
order By Total_Death_Count desc


--Looking Global Numbers
Select date,  SUM(new_cases) as  total_cases, sum(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) / SUM(new_cases) * 100 as Death_Percentage
From Portfolio_project..CovidDeaths
Where continent is not NULL
--Where location like '%states%'
group by date
Order by 1,2

--The Global death/ cases
Select SUM(new_cases) as  total_cases, sum(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) / SUM(new_cases) * 100 as Death_Percentage
From Portfolio_project..CovidDeaths
Where continent is not NULL
--Where location like '%states%'
Order by 1,2


--joining the Vaccination Table and inspecting vaccination vs Population
Select dea.date, dea.continent, dea.location, dea.population, vac.new_vaccinations
From Portfolio_project..CovidDeaths dea
 join Portfolio_project..CovidVaccinations vac
On dea.location = vac.location
AND
dea.date = vac.date
Where dea.continent is not NULL
order by 1,2,3

-- Rolling Vaccination Partition
Select dea.date, dea.continent, dea.location, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.date)  as updated_Vaccination 
From Portfolio_project..CovidDeaths dea
 join Portfolio_project..CovidVaccinations vac
On dea.location = vac.location
AND
dea.date = vac.date
Where dea.continent is not NULL
order by 2,3


--USE CTE

with PopulationvsVaccination ( date, continent, location,  population, new_vaccinated, updated_Vaccination)  as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as updated_Vaccination 
From Portfolio_project..CovidDeaths dea
 join Portfolio_project..CovidVaccinations vac
On dea.location = vac.location
AND
dea.date = vac.date
Where dea.continent is not NULL
) 
Select *, (updated_Vaccination/population)*100  from PopulationvsVaccination



--Create a new table
DROP Table if exists temp_table
create table temp_table
( continent varchar(100),
location varchar(100),
date datetime,
population numeric,
new_vaccinations numeric,
updated_Vaccination numeric

)



Insert into temp_table
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as updated_Vaccination 

From Portfolio_project..CovidDeaths dea
join Portfolio_project..CovidVaccinations vac
On dea.location = vac.location
AND
dea.date = vac.date
Select *, (updated_Vaccination/population)*100  from temp_table



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as updated_Vaccination 
--, (RollingPeopleVaccinated/population)*100
From Portfolio_project..CovidDeaths dea
Join Portfolio_project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select * from PercentPopulationVaccinated
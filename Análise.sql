--Casos vs Mortes (percentual)

select location, date, total_cases, new_cases, total_deaths, population, (total_deaths / total_cases)* 100 as PercentualMortes 
from Covid..Mortes where location = 'Brazil'
order by 
  1, 2

--Total de casos vs População

select location, date, total_cases, new_cases, total_deaths, population, (total_cases / population)* 100 as PercentualCasosPop
from Covid..Mortes where location = 'Brazil'
order by 
  1, 2

-- Verificando a maior taxa de infecção
select location, population, MAX(total_cases) as MaiorInfeccao, MAX(total_cases/population)*100 as TaxaInfeccao
from Covid..Mortes
where continent is not null
group by location, population
order by TaxaInfeccao desc

-- Países com maior taxa de morte
select location, MAX(cast(total_deaths as int)) as TotalMortes
from Covid..Mortes
where continent is not null
group by location
order by TotalMortes desc

-- Abrindo por continente
select continent, MAX(cast(total_deaths as int)) as TotalMortes
from Covid..Mortes
where continent is not null
group by continent
order by TotalMortes desc

-- NÚMEROS GLOBAIS

select SUM(new_cases) as 'Total de Casos', SUM(CAST (new_deaths as int)) as 'Total de Mortes', SUM(CAST (new_deaths as int))/SUM(new_cases)*100 as 'Taxa morte global'
from Covid..Mortes
where continent is not null
--group by date
order by 
  1, 2

-- População Total vs Vacinação (Aplicação de JOIN)

select mor.continent, mor.location, mor.date, mor.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by mor.Location order by mor.location, mor.date) as VacAcumulado,
from Covid..Mortes mor
join Covid..Vacina vac
	On mor.location = vac.location
	and mor.date = vac.date
where mor.continent is not null
order by 2,3

-- USO DE CTE PARA MANIPULAR NOVA COLUNA
with PopvsVac (continent, location, date, population, new_vaccinations, VacAcumulado)
as
(
select mor.continent, mor.location, mor.date, mor.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by mor.Location order by mor.location, mor.date) as VacAcumulado
from Covid..Mortes mor
join Covid..Vacina vac
	On mor.location = vac.location
	and mor.date = vac.date
where mor.continent is not null
--order by 2,3
)
select *, (VacAcumulado/population)*100 as TaxaVacina
from PopvsVac

-- UTILAZANDO VIEW PARA ARMAZENAR DADOS PARA VISUALIZAÇÃO
Create View PorcentVacPop as
select mor.continent, mor.location, mor.date, mor.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by mor.Location order by mor.location, mor.date) as VacAcumulado
from Covid..Mortes mor
join Covid..Vacina vac
	On mor.location = vac.location
	and mor.date = vac.date
where mor.continent is not null
--order by 2,3

select * from PorcentVacPop
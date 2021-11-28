USE Covid_Project

SELECT*
FROM Covid_Deaths$
where continent is not null
ORDER BY 3,4;

--SELECT*
--FROM Covid_Vaccionation$
--ORDER BY 3,4;

---SELECCIONAMOS LA DATA QUE VAMOS A ESTAR USANDO

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Covid_Deaths$
where continent is not null
ORDER BY 1,2;

---BUSCAMOS LOS CASOS TOTALES Y LAS MUERTES TOTALES
---LA ULTIMA COLUMNA MUESTRA LA PROBABILIDAD DE CONTRAER COVID EN EL PAIS SELECCIONADO
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Covid_Deaths$
WHERE location LIKE 'MEXI%'
and continent is not null
ORDER BY 1,2;

---CONTRASTAMOS LOS CASOS TOTALES CONTRA LA POBLACION
---MUESTRA QUE PORCENTAJE DE LA POBLACION CONTRAJO COVIDF
SELECT location, date, population,total_cases,(total_cases/population)*100 as InfectedPercentage
FROM Covid_Deaths$
WHERE location LIKE 'MEXI%'
and continent is not null
ORDER BY 1,2;

---BUSQUEDA DE LOS PAISES CON LAS MAS ALTAS TASAS DE INFECCION
SELECT location, population,MAX(total_cases) AS MayorInfectado,Max((total_cases/population))*100 as InfectedPercentage
FROM Covid_Deaths$
where continent is not null
GROUP BY location, population
ORDER BY InfectedPercentage desc

---MUESTRA A LOS PAISES CON MAS MUERTES POR POBLACION
SELECT location, MAX(cast(total_deaths as int)) AS ContadorFallecidos
FROM Covid_Deaths$
where continent is not null
GROUP BY location, population
ORDER BY ContadorFallecidos desc

---MUESTRA EL CONTEO POR CONTINENTE O GRUPO DE INGRESOS
SELECT location, MAX(cast(total_deaths as int)) AS ContadorFallecidos
FROM Covid_Deaths$
where continent is null
GROUP BY location
ORDER BY ContadorFallecidos desc

---NUMEROS GLOBALES
SELECT SUM(new_cases) AS CASOS_TOTALES, SUM(CAST(new_deaths AS INT)) AS MUERTES_TOTALES, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS PORCENTAJE_FALLECIDOS
FROM Covid_Deaths$
--WHERE location LIKE 'MEXI%'
WHERE continent is not null
ORDER BY 1,2;


--VAMOS A PASAR CON LA SEGUNDA TABLA DE LA BASE DE DATOS
--BUSCANDO ENTRE LA POBLACION TOTAL Y LA POBLACION VACUNADA


with PopVsVac (Continent,Location,Date,Population,NuevasVacunaciones,TotalVacunados)
as 
(
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations as NuevasVacunaciones,
SUM(CONVERT(float,VAC.new_vaccinations)) over (partition by DEA.location ORDER BY DEA.location, DEA.date) AS TotalVacunados
--(TotalVacunados/population)*100
FROM Covid_Deaths$ DEA
JOIN Covid_Vaccionation$ VAC
	ON DEA.location=VAC.location
	AND DEA.date=VAC.date
where DEA.continent is NOT null
--ORDER BY 2,3
)
SELECT *, (TotalVacunados/Population)*100
from PopVsVac
--Usando CTE




--TEMP TABLE
drop table if exists PercPopVacc
create table PercPopVacc
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
NuevasVacunaciones numeric,
TotalVacunados numeric,
)

insert into PercPopVacc
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations as NuevasVacunaciones,
SUM(CONVERT(float,VAC.new_vaccinations)) over (partition by DEA.location ORDER BY DEA.location, DEA.date) AS TotalVacunados
--(TotalVacunados/population)*100
FROM Covid_Deaths$ DEA
JOIN Covid_Vaccionation$ VAC
	ON DEA.location=VAC.location
	AND DEA.date=VAC.date
--where DEA.continent is NOT null
--ORDER BY 2,3

SELECT *, (TotalVacunados/Population)*100
from PercPopVacc

-- Creando espectros para la visualización posterior

create view PercPopVacco as 
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations as NuevasVacunaciones,
SUM(CONVERT(float,VAC.new_vaccinations)) over (partition by DEA.location ORDER BY DEA.location, DEA.date) AS TotalVacunados
--(TotalVacunados/population)*100
FROM Covid_Deaths$ DEA
JOIN Covid_Vaccionation$ VAC
	ON DEA.location=VAC.location
	AND DEA.date=VAC.date
where DEA.continent is NOT null
--ORDER BY 2,3

select * from PercPopVacco
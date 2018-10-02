/*Variables*/
DECLARE @fechaInicio AS DATETIME,
        @fechaFin AS DATETIME,
        @estatusPlan AS INT,
        @Origen AS INT;
--SET DATEFORMAT YMD;
SELECT @fechaInicio = '2018-09-01 00:00:00',
       @fechaFin = '2018-09-30 23:59:59',
       @estatusPlan = NULL,
       @Origen = NULL;


/*Crear Tablas Temporales*/
DECLARE @EstatusPlanVE AS TABLE
(
    estatusID INT,
    Estatus VARCHAR(50)
);

DECLARE @Pensiones AS TABLE
(
    pensionID INT,
    Pension VARCHAR(50)
);
/*Llenar Tabla*/
INSERT INTO @EstatusPlanVE
(
    estatusID,
    Estatus
)
VALUES
(   NULL,   -- estatusID - int
    'Todos' -- Estatus - varchar(50)
);

INSERT INTO @EstatusPlanVE
(
    estatusID,
    Estatus
)
SELECT cepv.IdEstatusPlanVE,
       cepv.Estatus
FROM CAT.CIO_EstatusPlanVE AS cepv
ORDER BY cepv.IdEstatusPlanVE ASC;

INSERT INTO @Pensiones
(
    pensionID,
    Pension
)
VALUES
(   NULL,   -- pensionID - int
    'Todas' -- Pension - varchar(50)
);

INSERT INTO @Pensiones
(
    pensionID,
    Pension
)
SELECT cp.IdPension,
       cp.Pension
FROM CAT.CIO_Pensiones AS cp
WHERE cp.IdPension IN (
                          SELECT DISTINCT cpv.IdPension FROM dbo.CIO_PlanesVE AS cpv
                      )
ORDER BY cp.IdPension ASC;

/*Mostar*/

SELECT *
FROM @EstatusPlanVE AS epv
ORDER BY epv.estatusID ASC;
SELECT *
FROM @Pensiones AS p
ORDER BY p.Pension ASC;

/*Consulta Info*/

SELECT cpv.IdPlanVE,
       (
           SELECT CASE
                      WHEN cpv.IdRuta < 2000 THEN
                          'VE'
                      WHEN cpv.IdRuta > 2000 THEN
                          'TI'
                  END
       ) AS UEN,
       cpv.IdRuta,
       cr.NombreRuta,
       cp.Pension,
       cepv.Estatus,
       cpv.FechaInicio,
       cpv.FechaFin,
       cpv.Unidad,
       co1.CveOperador AS 'CveOperador1',
       co2.CveOperador AS 'CveOperador2',
       cpv.FechaBitacora,
       cpv.FechaDespacho
FROM dbo.CIO_PlanesVE AS cpv
    INNER JOIN CAT.CIO_Rutas AS cr
        ON cr.IdRuta = cpv.IdRuta
    INNER JOIN CAT.CIO_Pensiones AS cp
        ON cp.IdPension = cpv.IdPension
    INNER JOIN CAT.CIO_EstatusPlanVE AS cepv
        ON cepv.IdEstatusPlanVE = cpv.IdEstatusPlanVE
    LEFT JOIN CAT.CIO_Operadores AS co1
        ON co1.IdOperador = cpv.IdOperador1
    LEFT JOIN CAT.CIO_Operadores AS co2
        ON co2.IdOperador = cpv.IdOperador2
WHERE (cpv.FechaInicio
      BETWEEN @fechaInicio AND @fechaFin
      )
      AND cpv.IdEstatusPlanVE = ISNULL(@estatusPlan, cpv.IdEstatusPlanVE)
      AND cpv.IdPension = ISNULL(@Origen, cpv.IdPension)
ORDER BY cpv.FechaInicio ASC;
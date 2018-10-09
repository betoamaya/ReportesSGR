)
VALUES
(   0,      -- estatusID - int
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
WHERE cepv.IdEstatusPlanVE IN ( 2, 3, 8 )
ORDER BY cepv.IdEstatusPlanVE ASC;

INSERT INTO @Pensiones
(
    pensionID,
    Pension
)
VALUES
(   0,      -- pensionID - int
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
IF @estatusPlan = 0
BEGIN
    SET @estatusPlan = NULL;
END;

IF @Origen = 0
BEGIN
    SET @Origen = NULL;
END;

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
       cr.NombreRuta AS Ruta,
       ISNULL(bt.Origen, '') AS Origen,
       ISNULL(bt.Destino, '') AS Destino,
       cepv.Estatus,
       cp.IdPension,
       cp.Pension,
       cpv.IdBitacora AS Bitacora,
       cpv.FechaInicio,
       cpv.FechaFin,
       ISNULL(cpv.Unidad, '') AS Unidad,
       ISNULL(co1.CveOperador, '') AS CveOper1,
       ISNULL(co2.CveOperador, '') AS CveOper2,
       cpv.FechaDespacho,
       ISNULL(cpv.UsuarioDespacha, '') AS UsuarioDespacha
FROM dbo.CIO_PlanesVE cpv WITH (NOLOCK)
    LEFT JOIN CAT.CIO_Pensiones cp WITH (NOLOCK)
        ON cp.IdPension = cpv.IdPension
    LEFT JOIN CAT.CIO_Rutas cr WITH (NOLOCK)
        ON cr.IdRuta = cpv.IdRuta
    LEFT JOIN dbo.BitacorasTurismo bt WITH (NOLOCK)
        ON cpv.IdBitacora = bt.Bitacora
           AND bt.Unidad = cpv.Unidad
    LEFT JOIN CAT.CIO_Operadores co1 WITH (NOLOCK)
        ON cpv.IdOperador1 = co1.IdOperador
    LEFT JOIN CAT.CIO_Operadores co2 WITH (NOLOCK)
        ON cpv.IdOperador2 = co2.IdOperador
    LEFT JOIN CAT.CIO_EstatusPlanVE cepv WITH (NOLOCK)
        ON cepv.IdEstatusPlanVE = cpv.IdEstatusPlanVE
WHERE cpv.IdEstatusPlanVE IN ( 2, 3, 8 )
      AND cpv.FechaInicio
      BETWEEN (CONVERT(VARCHAR,@fechaInicio,111) + ' 00:00:00') AND (CONVERT(VARCHAR,@fechaFin,111) + ' 23:59:59')
      AND cpv.IdEstatusPlanVE = ISNULL(@estatusPlan, cpv.IdEstatusPlanVE)
      AND cpv.IdPension = ISNULL(@Origen, cpv.IdPension)
ORDER BY bt.FechaInicio ASC;

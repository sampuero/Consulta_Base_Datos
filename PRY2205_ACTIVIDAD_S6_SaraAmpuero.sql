/*CASO 1 - CREACION DE TABLA Y REPORTE RECAUDACION DE BONOS MEDICOS  */

CREATE TABLE RECAUDACION_BONOS_MEDICOS AS
SELECT
    TO_CHAR(m.rut_med, '99G999G999') || '-' || UPPER(m.DV_run) AS "RUT_MÉDICO",
    UPPER(m.pnombre) || ' ' || UPPER(m.apaterno) || ' ' || UPPER(m.amaterno) AS "NOMBRE_MÉDICO",
    LPAD(TO_CHAR(SUM(p.monto_a_cancelar), 'FML999G999G999G990', 'NLS_NUMERIC_CHARACTERS = '',.'''), 15) AS TOTAL_RECAUDADO,
    u.nombre AS UNIDAD_MEDICA
FROM pagos p 
JOIN bono_consulta b ON p.id_bono = b.id_bono
JOIN medico m ON b.rut_med = m.rut_med 
JOIN unidad_consulta u ON m.uni_id = u.uni_id
WHERE EXTRACT(YEAR FROM p.fecha_pago) = EXTRACT(YEAR FROM SYSDATE) - 1
  AND m.car_id NOT IN (100, 500, 600)
GROUP BY m.rut_med, m.dv_run, m.pnombre, m.apaterno, m.amaterno, u.nombre;

select * from recaudacion_bonos_medicos


/*CASO 2 - INFORME PERDIDAS POR ESPECIALIDAD */

SELECT e.nombre AS "ESPECIALIDAD MEDICA", 
       COUNT(*) AS "CANTIDAD BONOS", 
       LPAD(TO_CHAR(SUM(unpaid.costo), 'FML999G999G999G990', 'NLS_NUMERIC_CHARACTERS = '',.'''), 15) AS "MONTO PÉRDIDA",
       TO_CHAR(MIN(unpaid.fecha_bono), 'DD-MM-YYYY') AS "FECHA BONO",
       CASE 
           WHEN MAX(CASE WHEN EXTRACT(YEAR FROM unpaid.fecha_bono) >= EXTRACT(YEAR FROM SYSDATE) - 1 THEN 1 ELSE 0 END) = 1
           THEN 'COBRABLE'
           ELSE 'INCOBRABLE'
       END AS "ESTADO DE COBRO"
FROM (
    -- Todos los bonos (incluyendo fecha)
    SELECT b.esp_id, b.id_bono, b.costo, b.fecha_bono
    FROM bono_consulta b
    
    MINUS
    
    -- Bonos que tienen pagos (incluyendo fecha)
    SELECT b.esp_id, b.id_bono, b.costo, b.fecha_bono
    FROM bono_consulta b
    JOIN pagos p ON b.id_bono = p.id_bono
) unpaid
JOIN especialidad_medica e ON unpaid.esp_id = e.esp_id
GROUP BY e.nombre
ORDER BY "CANTIDAD BONOS" ASC;

/*CASO 3 - INFORME CANTIDAD BONOS PACIENTE POR AÑO */


INSERT INTO CANT_BONOS_PACIENTES_ANNIO (
    ANNIO_CALCULO,
    PAC_RUN,
    DV_RUN,
    EDAD,
    CANTIDAD_BONOS,
    MONTO_TOTAL_BONOS,
    SISTEMA_SALUD
)
SELECT
    EXTRACT(YEAR FROM SYSDATE) AS ANNIO_CALCULO,
    pac.pac_run,
    pac.dv_run,
    FLOOR(MONTHS_BETWEEN(SYSDATE, pac.fecha_nacimiento) / 12) AS EDAD,
    COUNT(b.pac_run) AS CANTIDAD_BONOS,
    NVL(SUM(b.costo), 0) AS MONTO_TOTAL_BONOS,
    CASE 
        WHEN UPPER(s.descripcion) LIKE '%TRAMO%' THEN 'FONASA'
        ELSE UPPER(s.descripcion)
    END AS SISTEMA_SALUD
FROM paciente pac
JOIN salud s ON s.sal_id = pac.sal_id  
LEFT JOIN bono_consulta b 
    ON pac.pac_run = b.pac_run 
    AND EXTRACT(YEAR FROM b.fecha_bono) = EXTRACT(YEAR FROM SYSDATE)
GROUP BY pac.pac_run, pac.dv_run, pac.fecha_nacimiento, s.descripcion
HAVING COUNT(b.pac_run) <= (
    SELECT ROUND(
        CASE WHEN COUNT(DISTINCT b2.pac_run) = 0 THEN 0
             ELSE COUNT(*) / COUNT(DISTINCT b2.pac_run)
        END
    )
    FROM bono_consulta b2
    WHERE EXTRACT(YEAR FROM b2.fecha_bono) = EXTRACT(YEAR FROM SYSDATE) - 1
);
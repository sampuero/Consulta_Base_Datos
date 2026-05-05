
--CASO 1--
-- Sinónimo privado para TRABAJADOR
CREATE SYNONYM trabajador_priv FOR PRY2205_S7.trabajador;

-- Sinónimo privado para BONO_ANTIGUEDAD
CREATE SYNONYM bono_antiguedad_priv FOR PRY2205_S7.bono_antiguedad;

-- Sinónimo privado para TICKET_CONCIERTO
CREATE SYNONYM ticket_concierto_priv FOR PRY2205_S7.ticket_concierto;

-- Creacion de Secuencia --

CREATE SEQUENCE seq_simulacion_num
START WITH 100
INCREMENT BY 10
NOCACHE;

-- Creacion de la vista --

DROP VIEW simulacion_remuneraciones;

CREATE VIEW simulacion_remuneraciones AS
SELECT 
    t.numrut || '-' || t.dvrut AS RUT,
    INITCAP(t.nombre || ' ' || t.appaterno || ' ' || t.apmaterno) AS NOMBRE_TRABAJADOR,
    TO_CHAR(t.sueldo_base, 'L999G999G999') AS SUELDO_BASE,
    CASE 
        WHEN tc.nro_ticket IS NULL THEN 'No hay info'
        ELSE TO_CHAR(tc.nro_ticket)
    END AS NUM_TICKET,
    INITCAP(REPLACE(t.direccion, ' N ', ' N° ')) AS DIRECCION,
    i.nombre_isapre AS SISTEMA_SALUD,
    TO_CHAR(NVL(tc.monto_ticket,0), 'L999G999G999') AS MONTO,
    TO_CHAR(
        CASE 
            WHEN tc.nro_ticket IS NULL THEN 0
            WHEN tc.monto_ticket <= 50000 THEN 0
            WHEN tc.monto_ticket > 50000 AND tc.monto_ticket <= 100000 
                THEN ROUND(tc.monto_ticket * 0.05)
            WHEN tc.monto_ticket > 100000 
                THEN ROUND(tc.monto_ticket * 0.07)
        END, 'L999G999G999'
    ) AS BONIF_X_TICKET,
    TO_CHAR(
        CASE 
            WHEN tc.nro_ticket IS NULL THEN t.sueldo_base
            WHEN tc.monto_ticket <= 50000 THEN t.sueldo_base
            WHEN tc.monto_ticket > 50000 AND tc.monto_ticket <= 100000 
                THEN ROUND(t.sueldo_base + (tc.monto_ticket * 0.05))
            WHEN tc.monto_ticket > 100000 
                THEN ROUND(t.sueldo_base + (tc.monto_ticket * 0.07))
        END, 'L999G999G999'
    ) AS SIMULACION_X_TICKET,
    TO_CHAR(ROUND(t.sueldo_base * (1 + ba.porcentaje/100)), 'L999G999G999') AS SIMULACION_ANTIGUEDAD
FROM trabajador_priv t
JOIN isapre i 
    ON t.cod_isapre = i.cod_isapre
LEFT JOIN tickets_concierto_priv tc 
    ON t.numrut = tc.numrut_t
JOIN bono_antiguedad_priv ba
    ON FLOOR(MONTHS_BETWEEN(SYSDATE, t.fecing) / 12) 
       BETWEEN ba.limite_inferior AND ba.limite_superior
WHERE i.porc_descto_isapre > 4
  AND FLOOR(MONTHS_BETWEEN(SYSDATE, t.fecnac) / 12) < 50;

-- Creacion de la tabla -- 

CREATE TABLE DETALLE_BONIFICACIONES_TRABAJADOR (
    ID_DETALLE            NUMBER PRIMARY KEY,
    RUT                   VARCHAR2(15),
    NOMBRE_TRABAJADOR     VARCHAR2(100),
    SUELDO_BASE           VARCHAR2(30),
    NUM_TICKET            VARCHAR2(20),
    DIRECCION             VARCHAR2(150),
    SISTEMA_SALUD         VARCHAR2(50),
    MONTO                 VARCHAR2(30),
    BONIF_X_TICKET        VARCHAR2(30),
    SIMULACION_X_TICKET   VARCHAR2(30),
    SIMULACION_ANTIGUEDAD VARCHAR2(30)
);
  
-- INSERTAR EN LA TABLA DE DESTINO CON SECUENCIA --

INSERT INTO DETALLE_BONIFICACIONES_TRABAJADOR (
    ID_DETALLE,
    RUT,
    NOMBRE_TRABAJADOR,
    SUELDO_BASE,
    NUM_TICKET,
    DIRECCION,
    SISTEMA_SALUD,
    MONTO,
    BONIF_X_TICKET,
    SIMULACION_X_TICKET,
    SIMULACION_ANTIGUEDAD
)
SELECT 
    SEQ_DET_BONIF.NEXTVAL,
    v.RUT,
    v.NOMBRE_TRABAJADOR,
    v.SUELDO_BASE,
    v.NUM_TICKET,
    v.DIRECCION,
    v.SISTEMA_SALUD,
    v.MONTO,
    v.BONIF_X_TICKET,
    v.SIMULACION_X_TICKET,
    v.SIMULACION_ANTIGUEDAD
FROM (
    SELECT *
    FROM simulacion_remuneraciones
    ORDER BY 
        CASE 
          WHEN REGEXP_LIKE(MONTO, '^[0-9$.,]+$') 
          THEN TO_NUMBER(REPLACE(REPLACE(MONTO,'$',''),',',''))
          ELSE 0
        END DESC,
        NOMBRE_TRABAJADOR ASC
) v;

-- CASO 2--

CREATE OR REPLACE VIEW V_AUMENTOS_ESTUDIOS AS
SELECT 
    t.numrut || '-' || t.dvrut AS RUT_TRABAJADOR,
    INITCAP(t.nombre || ' ' || t.appaterno || ' ' || t.apmaterno) AS TRABAJADOR,
    e.descrip AS NIVEL_EDUCACION,
    e.porc_bono AS PCT_ESTUDIOS,
    TO_CHAR(t.sueldo_base, 'L999G999G999') AS SUELDO_ACTUAL,
    TO_CHAR(ROUND(t.sueldo_base * (e.porc_bono/100)), 'L999G999G999') AS AUMENTO,
    TO_CHAR(ROUND(t.sueldo_base * (1 + e.porc_bono/100)), 'L999G999G999') AS SUELDO_AUMENTADO
FROM TRABAJADOR t
JOIN BONO_ESCOLAR e
    ON t.ID_ESCOLARIDAD_T = e.ID_ESCOLAR
WHERE 
    -- Restricción: solo cajeros
    t.ID_CATEGORIA_T = (SELECT id_categoria 
                        FROM TIPO_TRABAJADOR 
                        WHERE DESC_CATEGORIA = 'CAJERO')
    OR
    -- Restricción: trabajadores con 1 o 2 cargas familiares
    (SELECT COUNT(*) 
     FROM ASIGNACION_FAMILIAR af 
     WHERE af.numrut_t = t.numrut) BETWEEN 1 AND 2
ORDER BY 
    e.porc_bono ASC,
    INITCAP(t.nombre || ' ' || t.appaterno || ' ' || t.apmaterno) ASC;
	

-- creacion de indice --

CREATE INDEX IDX_TRABAJADOR_RUT_FUNC
ON TRABAJADOR ( (TO_CHAR(NUMRUT) || '-' || DVRUT) );
	
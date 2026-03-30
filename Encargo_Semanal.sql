-- ============================================
-- PASO 1: CREACION Y POBLAMIENTO
-- ============================================
-- ELIMINACIÓN DE TABLAS EXISTENTES
-- ============================================

DROP TABLE RESUMEN_PAGOS_POR_SUCURSAL CASCADE CONSTRAINTS;
DROP TABLE DESCUENTOS CASCADE CONSTRAINTS;
DROP TABLE HABERES CASCADE CONSTRAINTS;
DROP TABLE DETALLE_PROP_ARRENDADAS CASCADE CONSTRAINTS;
DROP TABLE ARRIENDO_PROPIEDAD CASCADE CONSTRAINTS;
DROP TABLE CLIENTE CASCADE CONSTRAINTS;
DROP TABLE PROPIEDAD CASCADE CONSTRAINTS;
DROP TABLE PROPIETARIO CASCADE CONSTRAINTS;
DROP TABLE EMPLEADO CASCADE CONSTRAINTS;
DROP TABLE SUCURSAL CASCADE CONSTRAINTS;
DROP TABLE CATEGORIA_EMPLEADO CASCADE CONSTRAINTS;
DROP TABLE TIPO_PROPIEDAD CASCADE CONSTRAINTS;
DROP TABLE COMUNA CASCADE CONSTRAINTS;

-- ============================================
-- CREACIÓN DE TABLAS
-- ============================================

CREATE TABLE COMUNA (
    id_comuna NUMBER(3) PRIMARY KEY,
    nombre_comuna VARCHAR2(30) NOT NULL
);

CREATE TABLE TIPO_PROPIEDAD (
    id_tipo_propiedad VARCHAR2(1) PRIMARY KEY,
    desc_tipo_propiedad VARCHAR2(30) NOT NULL
);

CREATE TABLE CATEGORIA_EMPLEADO (
    id_categoria_emp NUMBER(1) PRIMARY KEY,
    desc_categoria_emp VARCHAR2(30) NOT NULL
);

CREATE TABLE SUCURSAL (
    id_sucursal NUMBER(3) PRIMARY KEY,
    desc_sucursal VARCHAR2(30) NOT NULL,
    direccion_sucursal VARCHAR2(30) NOT NULL,
    id_comuna NUMBER(3) NOT NULL,
    CONSTRAINT fk_sucursal_comuna FOREIGN KEY (id_comuna)
        REFERENCES COMUNA(id_comuna)
);

CREATE TABLE EMPLEADO (
    numrut_emp        NUMBER(10)      PRIMARY KEY,
    dvruut_emp        VARCHAR2(1)     NOT NULL,
    appaterno_emp     VARCHAR2(15)    NOT NULL,
    apmaterno_emp     VARCHAR2(15)    NOT NULL,
    nombre_emp        VARCHAR2(25)    NOT NULL,
    foto_emp          BLOB,
    direccion_emp     VARCHAR2(80) NOT NULL,
    fonofijo_emp      VARCHAR2(15) NOT NULL,
    celular_emp       VARCHAR2(15),
    fecnac_emp        DATE,
    fecing_emp        DATE NOT NULL,
    sueldo_emp        NUMBER(7) NOT NULL,
    id_categoria_emp  NUMBER(1) NOT NULL,
    id_sucursal       NUMBER(3) NOT NULL,
    CONSTRAINT fk_empleado_categoria
        FOREIGN KEY (id_categoria_emp)
        REFERENCES CATEGORIA_EMPLEADO (id_categoria_emp),
    CONSTRAINT fk_empleado_sucursal
        FOREIGN KEY (id_sucursal)
        REFERENCES SUCURSAL (id_sucursal)
);

CREATE TABLE PROPIETARIO (
    numrut_prop NUMBER(10) PRIMARY KEY,
    dv_rut_prop VARCHAR2(1) NOT NULL,
    apaterno_prop VARCHAR2(15) NOT NULL,
    amaterno_prop VARCHAR2(15) NOT NULL,
    nombre_prop VARCHAR2(15) NOT NULL,
	direccion_prop VARCHAR2(60) NOT NULL,
    fonofijo_prop NUMBER(7) NOT NULL,
    celular_prop NUMBER(8)
);

CREATE TABLE PROPIEDAD (
    nro_propiedad NUMBER(6) PRIMARY KEY,
    direccion_propiedad VARCHAR2(60) NOT NULL,
    superficie NUMBER(5,2) NOT NULL,
    nro_dormitorios NUMBER(1),
    nro_banos NUMBER(1),
    valor_arriendo NUMBER(7) NOT NULL,
    valor_gasto_comun NUMBER(7),
    id_tipo_propiedad VARCHAR2(1) NOT NULL,
    id_comuna NUMBER(3) NOT NULL,
    numrut_prop NUMBER(10) NOT NULL,
    numrut_emp NUMBER(10),
    CONSTRAINT fk_propiedad_tipo FOREIGN KEY (id_tipo_propiedad)
        REFERENCES TIPO_PROPIEDAD(id_tipo_propiedad),
    CONSTRAINT fk_propiedad_comuna FOREIGN KEY (id_comuna)
        REFERENCES COMUNA(id_comuna),
    CONSTRAINT fk_propiedad_propietario FOREIGN KEY (numrut_prop)
        REFERENCES PROPIETARIO(numrut_prop),
    CONSTRAINT fk_propiedad_empleado FOREIGN KEY (numrut_emp)
        REFERENCES EMPLEADO(numrut_emp)
);

CREATE TABLE CLIENTE (
    numrut_cli NUMBER(10) PRIMARY KEY,
    dv_rut_cli VARCHAR2(1) NOT NULL,
    apaterno_cli VARCHAR2(15) NOT NULL,
    amaterno_cli VARCHAR2(15) NOT NULL,
    nombre_cli VARCHAR2(25) NOT NULL,
    fonofijo_cli NUMBER(15) NOT NULL,
    celular_cli NUMBER(8),
    renta_cli NUMBER(7) NOT NULL
);

CREATE TABLE ARRIENDO_PROPIEDAD (
    nro_propiedad NUMBER(6) NOT NULL,
    numrut_cli NUMBER(10) NOT NULL,
    fecini_arriendo DATE NOT NULL,
    fecter_arriendo DATE,
    PRIMARY KEY (nro_propiedad, numrut_cli),
    CONSTRAINT fk_arriendo_prop FOREIGN KEY (nro_propiedad)
        REFERENCES PROPIEDAD(nro_propiedad),
    CONSTRAINT fk_arriendo_cli FOREIGN KEY (numrut_cli)
        REFERENCES CLIENTE(numrut_cli)
);

CREATE TABLE DETALLE_PROP_ARRENDADAS (
    correl_det_prop NUMBER(4) PRIMARY KEY,
    desc_tipo_propiedad VARCHAR2(30) NOT NULL,
    nro_propiedad NUMBER(6) NOT NULL,
    direccion_propiedad VARCHAR2(60) NOT NULL,
    valor_arriendo NUMBER(7) NOT NULL,
    fec_inicio_arriendo DATE NOT NULL,
    fec_termino_arriendo DATE,
    fecha_proceso DATE NOT NULL,
    CONSTRAINT fk_detalle_prop FOREIGN KEY (nro_propiedad)
        REFERENCES PROPIEDAD(nro_propiedad)
);

CREATE TABLE HABERES (
    numrut_emp NUMBER(10) NOT NULL,
    id_sucursal NUMBER(3) NOT NULL,
    mes_proceso NUMBER(2),
    anno_proceso NUMBER(4),
    sueldo_base NUMBER(8) NOT NULL,
    comision_arriendo NUMBER(8) NOT NULL,
    colacion NUMBER(8) NOT NULL,
    movilizacion NUMBER(8) NOT NULL,
    PRIMARY KEY (numrut_emp, mes_proceso, anno_proceso),
    CONSTRAINT fk_haberes_emp FOREIGN KEY (numrut_emp)
        REFERENCES EMPLEADO(numrut_emp)
);

CREATE TABLE DESCUENTOS (
    numrut_emp NUMBER(10) NOT NULL,
    id_sucursal NUMBER(3) NOT NULL,
    mes_proceso NUMBER(2),
    anno_proceso NUMBER(4),
    prevision NUMBER(8) NOT NULL,
    salud NUMBER(8) NOT NULL,
    PRIMARY KEY (numrut_emp, mes_proceso, anno_proceso),
    CONSTRAINT fk_descuentos_emp FOREIGN KEY (numrut_emp)
        REFERENCES EMPLEADO(numrut_emp)
);

CREATE TABLE RESUMEN_PAGOS_POR_SUCURSAL (
    id_sucursal NUMBER(3) NOT NULL,
    mes_proceso NUMBER(2),
    anno_proceso NUMBER(4),
    total_empleados NUMBER(3) NOT NULL,
    total_haberes NUMBER(10) NOT NULL,
    total_descuentos NUMBER(10) NOT NULL,
    PRIMARY KEY (id_sucursal, mes_proceso, anno_proceso),
    CONSTRAINT fk_resumen_sucursal FOREIGN KEY (id_sucursal)
        REFERENCES SUCURSAL(id_sucursal)
);

-- ============================================
-- LIMPIEZA COMPLETA DE DATOS EXISTENTES
-- ============================================
TRUNCATE TABLE RESUMEN_PAGOS_POR_SUCURSAL;

TRUNCATE TABLE DESCUENTOS;

TRUNCATE TABLE HABERES;

TRUNCATE TABLE DETALLE_PROP_ARRENDADAS;

TRUNCATE TABLE ARRIENDO_PROPIEDAD;

TRUNCATE TABLE PROPIEDAD;

TRUNCATE TABLE CLIENTE;

TRUNCATE TABLE PROPIETARIO;

TRUNCATE TABLE EMPLEADO;

TRUNCATE TABLE SUCURSAL;

TRUNCATE TABLE CATEGORIA_EMPLEADO;

TRUNCATE TABLE TIPO_PROPIEDAD;

TRUNCATE TABLE COMUNA;

-- ============================================
-- POBLAMIENTO 
-- ============================================

INSERT INTO
  COMUNA
VALUES
  (81, 'La Florida');

INSERT INTO
  COMUNA
VALUES
  (82, 'Providencia');

INSERT INTO
  COMUNA
VALUES
  (83, 'Ñuñoa');

INSERT INTO
  COMUNA
VALUES
  (84, 'Las Condes');

INSERT INTO
  COMUNA
VALUES
  (87, 'Maipú');

INSERT INTO
  TIPO_PROPIEDAD
VALUES
  ('A', 'Casa');

INSERT INTO
  TIPO_PROPIEDAD
VALUES
  ('B', 'Departamento');

INSERT INTO
  TIPO_PROPIEDAD
VALUES
  ('C', 'Local');
  
INSERT INTO
  TIPO_PROPIEDAD
VALUES
  ('D', 'Parcela sin casa');

INSERT INTO
  TIPO_PROPIEDAD
VALUES
  ('E', 'Parcela con casa');  

INSERT INTO
  CATEGORIA_EMPLEADO
VALUES
  (1, 'Corredor');

INSERT INTO
  CATEGORIA_EMPLEADO
VALUES
  (2, 'Administrativo');

INSERT INTO
  CATEGORIA_EMPLEADO
VALUES
  (3, 'Gerente');

-- Sucursal
INSERT INTO
  SUCURSAL
VALUES
  (
    1,
    'Sucursal La Florida',
    'Av. Vicuña Mackenna 1234',
    81
  );

INSERT INTO
  SUCURSAL
VALUES
  (2, 'Sucursal Las Condes', 'Av. Vitacura 1234', 84);

INSERT INTO
  SUCURSAL
VALUES
  (3, 'Sucursal Maipu', 'Av. Centenario 1234', 87);

-- Empleados (10 registros)
INSERT INTO
  EMPLEADO
VALUES
  (
    12345678,
    '5',
    'Pérez',
    'González',
    'Juan',
    NULL,
    'Calle 1',
    '2222333',
    '98765432',
    DATE '1990-05-15',
    DATE '2020-03-01',
    800000,
    1,
    1
  );

INSERT INTO
  EMPLEADO
VALUES
  (
    13579135,
    '2',
    'Muñoz',
    'Castro',
    'Pedro',
    NULL,
    'Calle 5',
    '2233445',
    '91234567',
    DATE '1985-07-20',
    DATE '2018-06-15',
    750000,
    2,
    1
  );

INSERT INTO
  EMPLEADO
VALUES
  (
    22334455,
    '1',
    'López',
    'Ramírez',
    'Sebastián',
    NULL,
    'Calle 11',
    '2233446',
    '91234568',
    DATE '1992-03-10',
    DATE '2021-01-10',
    700000,
    1,
    1
  );

INSERT INTO
  EMPLEADO
VALUES
  (
    33445566,
    '2',
    'Martínez',
    'Soto',
    'Valentina',
    NULL,
    'Calle 12',
    '3344557',
    '91234569',
    DATE '1995-11-25',
    DATE '2019-09-01',
    720000,
    2,
    2
  );

INSERT INTO
  EMPLEADO
VALUES
  (
    44556677,
    '3',
    'Gutiérrez',
    'Fernández',
    'Jorge',
    NULL,
    'Calle 13',
    '4455667',
    '91234570',
    DATE '1980-01-30',
    DATE '2010-05-20',
    950000,
    1,
    3
  );

INSERT INTO
  EMPLEADO
VALUES
  (
    55667788,
    '4',
    'Rojas',
    'Silva',
    'Claudia',
    NULL,
    'Calle 14',
    '5566778',
    '91234571',
    DATE '1993-09-12',
    DATE '2022-02-01',
    680000,
    2,
    1
  );

INSERT INTO
  EMPLEADO
VALUES
  (
    66778899,
    '5',
    'Hernández',
    'Morales',
    'Felipe',
    NULL,
    'Calle 15',
    '6677889',
    '91234572',
    DATE '1988-12-05',
    DATE '2015-07-10',
    770000,
    1,
    2
  );

INSERT INTO
  EMPLEADO
VALUES
  (
    77889900,
    '6',
    'Vargas',
    'Pino',
    'Camila',
    NULL,
    'Calle 16',
    '7788990',
    '91234573',
    DATE '1996-04-18',
    DATE '2023-01-15',
    690000,
    3,
    3
  );

INSERT INTO
  EMPLEADO
VALUES
  (
    88990011,
    '7',
    'Castillo',
    'Reyes',
    'Andrés',
    NULL,
    'Calle 17',
    '8899001',
    '91234574',
    DATE '1987-08-22',
    DATE '2012-11-01',
    810000,
    2,
    2
  );

INSERT INTO
  EMPLEADO
VALUES
  (
    99001122,
    '8',
    'Salinas',
    'Araya',
    'Paula',
    NULL,
    'Calle 18',
    '9900112',
    '91234575',
    DATE '1991-02-14',
    DATE '2017-04-01',
    730000,
    1,
    1
  );

-- Propietarios (10 registros)
INSERT INTO
  PROPIETARIO
VALUES
  (
    20000001,
    '9',
    'Alvarez',
    'Mendez',
    'Luis',
    'Av. La Florida 101',
    '2233445',
    '99887766'
  );

INSERT INTO
  PROPIETARIO
VALUES
  (
    20000002,
    '5',
    'Bravo',
    'Sanhueza',
    'Patricia',
    'Av. Providencia 202',
    '2233446',
    '99887767'
  );

INSERT INTO
  PROPIETARIO
VALUES
  (
    20000003,
    '3',
    'Silva',
    'Morales',
    'Andrea',
    'Av. Ñuñoa 303',
    '2233447',
    '91230001'
  );

INSERT INTO
  PROPIETARIO
VALUES
  (
    20000004,
    '4',
    'Torres',
    'Castro',
    'Felipe',
    'Av. Las Condes 404',
    '2233448',
    '91230002'
  );

INSERT INTO
  PROPIETARIO
VALUES
  (
    20000005,
    '5',
    'Reyes',
    'Vargas',
    'Camila',
    'Av. Maipú 505',
    '2233449',
    '91230003'
  );

INSERT INTO
  PROPIETARIO
VALUES
  (
    20000006,
    '6',
    'González',
    'Pérez',
    'Diego',
    'Av. La Florida 606',
    '2233450',
    '91230004'
  );

INSERT INTO
  PROPIETARIO
VALUES
  (
    20000007,
    '7',
    'Herrera',
    'Torres',
    'Lucía',
    'Av. Providencia 707',
    '2233451',
    '91230005'
  );

INSERT INTO
  PROPIETARIO
VALUES
  (
    20000008,
    '8',
    'Ibarra',
    'Castro',
    'Pedro',
    'Av. Ñuñoa 808',
    '2233452',
    '91230006'
  );

INSERT INTO
  PROPIETARIO
VALUES
  (
    20000009,
    '9',
    'Jara',
    'Navarro',
    'Sofía',
    'Av. Las Condes 909',
    '2233453',
    '91230007'
  );

INSERT INTO
  PROPIETARIO
VALUES
  (
    20000010,
    '0',
    'Klein',
    'Fuentes',
    'Miguel',
    'Av. Maipú 1010',
    '2233454',
    '91230008'
  );

-- Clientes (10 registros)
INSERT INTO
  CLIENTE
VALUES
  (
    40000001,
    '7',
    'Morales',
    'Pérez',
    'Diego',
    2233445,
    91234567,
    800000
  );

INSERT INTO
  CLIENTE
VALUES
  (
    40000002,
    '2',
    'Navarro',
    'Gutiérrez',
    'Camila',
    3344556,
    98765432,
    950000
  );

INSERT INTO
  CLIENTE
VALUES
  (
    40000003,
    '3',
    'Pino',
    'Navarro',
    'Rodrigo',
    2233446,
    91234568,
    850000
  );

INSERT INTO
  CLIENTE
VALUES
  (
    40000004,
    '4',
    'Araya',
    'Hernández',
    'Paula',
    2233447,
    91234569,
    900000
  );

INSERT INTO
  CLIENTE
VALUES
  (
    40000005,
    '5',
    'Salinas',
    'Rojas',
    'Francisca',
    2233448,
    91234570,
    950000
  );

INSERT INTO
  CLIENTE
VALUES
  (
    40000006,
    '6',
    'Fernández',
    'Martínez',
    'Ana',
    2233449,
    91234571,
    880000
  );

INSERT INTO
  CLIENTE
VALUES
  (
    40000007,
    '7',
    'Soto',
    'Ramírez',
    'Carlos',
    2233450,
    91234572,
    910000
  );

INSERT INTO
  CLIENTE
VALUES
  (
    40000008,
    '8',
    'García',
    'Torres',
    'Lucía',
    2233451,
    91234573,
    870000
  );

INSERT INTO
  CLIENTE
VALUES
  (
    40000009,
    '9',
    'Rojas',
    'Silva',
    'Andrés',
    2233452,
    91234574,
    930000
  );

INSERT INTO
  CLIENTE
VALUES
  (
    40000010,
    '0',
    'Hernández',
    'Morales',
    'Claudia',
    2233453,
    91234575,
    940000
  );

-- Propiedades (10 registros)
INSERT INTO
  PROPIEDAD
VALUES
  (
    3001,
    'Av. La Florida 100',
    120.5,
    3,
    2,
    450000,
    50000,
    'A',
    81,
    20000001,
    12345678
  );

INSERT INTO
  PROPIEDAD
VALUES
  (
    3002,
    'Av. Providencia 200',
    80.0,
    0,
    1,
    350000,
    40000,
    'D',
    82,
    20000002,
    13579135
  );

INSERT INTO
  PROPIEDAD
VALUES
  (
    3003,
    'Av. Ñuñoa 300',
    150.0,
    4,
    3,
    600000,
    70000,
    'C',
    83,
    20000003,
    22334455
  );

INSERT INTO
  PROPIEDAD
VALUES
  (
    3004,
    'Av. Las Condes 400',
    95.0,
    0,
    2,
    520000,
    60000,
    'D',
    84,
    20000004,
    33445566
  );

INSERT INTO
  PROPIEDAD
VALUES
  (
    3005,
    'Av. Maipú 500',
    70.0,
    1,
    1,
    310000,
    30000,
    'E',
    87,
    20000005,
    44556677
  );

INSERT INTO
  PROPIEDAD
VALUES
  (
    3006,
    'Av. La Florida 600',
    110.0,
    3,
    2,
    400000,
    45000,
    'C',
    81,
    20000006,
    55667788
  );

INSERT INTO
  PROPIEDAD
VALUES
  (
    3007,
    'Av. Providencia 700',
    85.0,
    2,
    1,
    360000,
    42000,
    'D',
    82,
    20000007,
    66778899
  );

INSERT INTO
  PROPIEDAD
VALUES
  (
    3008,
    'Av. Ñuñoa 800',
    140.0,
    4,
    3,
    620000,
    68000,
    'C',
    83,
    20000008,
    77889900
  );

INSERT INTO
  PROPIEDAD
VALUES
  (
    3009,
    'Av. Las Condes 900',
    100.0,
    2,
    2,
    540000,
    60000,
    'D',
    84,
    20000009,
    88990011
  );

INSERT INTO
  PROPIEDAD
VALUES
  (
    3010,
    'Av. Maipú 1000',
    75.0,
    1,
    1,
    320000,
    31000,
    'E',
    87,
    20000010,
    99001122
  );

-- Arriendos (8 registros)
INSERT INTO
  ARRIENDO_PROPIEDAD
VALUES
  (
    3001,
    40000001,
    DATE '2024-01-01',
    DATE '2026-12-31'
  );

INSERT INTO
  ARRIENDO_PROPIEDAD
VALUES
  (
    3002,
    40000002,
    DATE '2000-02-01',
    NULL
  );

INSERT INTO
  ARRIENDO_PROPIEDAD
VALUES
  (
    3004,
    40000004,
    DATE '2020-04-01',
    NULL
  );

INSERT INTO
  ARRIENDO_PROPIEDAD
VALUES
  (
    3005,
    40000005,
    DATE '2022-05-01',
    DATE '2026-11-30'
  );

INSERT INTO
  ARRIENDO_PROPIEDAD
VALUES
  (
    3006,
    40000006,
    DATE '2026-01-01',
    DATE '2026-12-31'
  );

INSERT INTO
  ARRIENDO_PROPIEDAD
VALUES
  (
    3007,
    40000007,
    DATE '2021-07-01',
    DATE '2026-12-31'
  );

INSERT INTO
  ARRIENDO_PROPIEDAD
VALUES
  (
    3009,
    40000009,
    DATE '2025-09-01',
    DATE '2026-12-31'
  );

INSERT INTO
  ARRIENDO_PROPIEDAD
VALUES
  (
    3010,
    40000010,
    DATE '2025-10-01',
    NULL
  );

-- Detalle propiedades arrendadas (8 registros)
INSERT INTO
  DETALLE_PROP_ARRENDADAS
VALUES
  (
    1,
    'Casa',
    3001,
    'Av. La Florida 100',
    450000,
    DATE '2026-01-01',
    DATE '2026-12-31',
    SYSDATE
  );

INSERT INTO
  DETALLE_PROP_ARRENDADAS
VALUES
  (
    2,
    'Departamento',
    3002,
    'Av. Providencia 200',
    350000,
    DATE '2026-02-01',
    DATE '2026-08-31',
    SYSDATE
  );

INSERT INTO
  DETALLE_PROP_ARRENDADAS
VALUES
  (
    4,
    'Departamento',
    3004,
    'Av. Las Condes 400',
    520000,
    DATE '2026-04-01',
    DATE '2026-10-31',
    SYSDATE
  );

INSERT INTO
  DETALLE_PROP_ARRENDADAS
VALUES
  (
    5,
    'Oficina',
    3005,
    'Av. Maipú 500',
    310000,
    DATE '2026-05-01',
    DATE '2026-11-30',
    SYSDATE
  );

INSERT INTO
  DETALLE_PROP_ARRENDADAS
VALUES
  (
    6,
    'Casa',
    3006,
    'Av. La Florida 600',
    400000,
    DATE '2026-06-01',
    DATE '2026-12-31',
    SYSDATE
  );

INSERT INTO
  DETALLE_PROP_ARRENDADAS
VALUES
  (
    7,
    'Departamento',
    3007,
    'Av. Providencia 700',
    360000,
    DATE '2026-07-01',
    DATE '2026-12-31',
    SYSDATE
  );

INSERT INTO
  DETALLE_PROP_ARRENDADAS
VALUES
  (
    9,
    'Departamento',
    3009,
    'Av. Las Condes 900',
    540000,
    DATE '2026-09-01',
    DATE '2026-12-31',
    SYSDATE
  );

INSERT INTO
  DETALLE_PROP_ARRENDADAS
VALUES
  (
    10,
    'Oficina',
    3010,
    'Av. Maipú 1000',
    320000,
    DATE '2026-10-01',
    NULL,
    SYSDATE
  );

COMMIT;

-- ============================================
-- PASO 2: INFORMES
-- ============================================
-- CASO 1: Informe de propiedades con formato mejorado y direcciones en mayúsculas
-- ============================================
SELECT 
    nro_propiedad                         AS PROPIEDAD,
    UPPER(direccion_propiedad)            AS DIRECCION,
    TO_CHAR(valor_arriendo, 'L999G999G999G999') AS ARRIENDO,
    NVL(TO_CHAR(valor_gasto_comun, 'L999G999G999G999'), 'SIN DATO') AS GCCC_ACTUAL,
    NVL(TO_CHAR(valor_gasto_comun * 1.10, 'L999G999G999G999'), 'SIN DATO') AS GCCC_AJUSTADO,
    'Propiedad ubicada en comuna ' || id_comuna AS UBICACION
FROM 
    PROPIEDAD
WHERE 
    valor_arriendo < &VALOR_MAXIMO
    AND nro_dormitorios IS NOT NULL
    AND id_comuna IN (82, 84, 87)
ORDER BY 
    CASE WHEN valor_gasto_comun IS NULL THEN 1 ELSE 0 END,  -- nulos al final
    valor_gasto_comun ASC,                                  -- gasto común ascendente
    valor_arriendo DESC;                                    -- arriendo descendente

-- ============================================	
-- CASO 2: Informe de Antigüedad de Propiedades Arrendadas
-- ============================================
SELECT 
    ap.nro_propiedad AS "Propiedad",
    ap.numrut_cli    AS "Código Arrendatario",
    TO_CHAR(ap.fecini_arriendo, 'DD.Mon.YYYY') AS "Fecha Inicio Arriendo",
    NVL(TO_CHAR(ap.fecter_arriendo, 'DD.Mon.YYYY'), 'PROPIEDAD ACTUALMENTE ARRENDADA') AS "Fecha Término Arriendo",
    TO_CHAR(TRUNC(NVL(ap.fecter_arriendo, SYSDATE) - ap.fecini_arriendo), '999G999G999') AS "Días Arriendo",
    TRUNC(MONTHS_BETWEEN(NVL(ap.fecter_arriendo, SYSDATE), ap.fecini_arriendo) / 12) AS "Años Arriendo",
    UPPER(
        CASE 
            WHEN TRUNC(MONTHS_BETWEEN(NVL(ap.fecter_arriendo, SYSDATE), ap.fecini_arriendo) / 12) >= 10 
                THEN 'COMPROMISO DE VENTA'
            WHEN TRUNC(MONTHS_BETWEEN(NVL(ap.fecter_arriendo, SYSDATE), ap.fecini_arriendo) / 12) BETWEEN 5 AND 9 
                THEN 'CLIENTE ANTIGUO'
            ELSE 'CLIENTE NUEVO'
        END
    ) AS "Clasificación Estado"
FROM 
    ARRIENDO_PROPIEDAD ap
WHERE 
    TRUNC(NVL(ap.fecter_arriendo, SYSDATE) - ap.fecini_arriendo) >= &PERIODO_MINIMO
ORDER BY 
    TRUNC(MONTHS_BETWEEN(NVL(ap.fecter_arriendo, SYSDATE), ap.fecini_arriendo) / 12) DESC, -- años
    TRUNC(NVL(ap.fecter_arriendo, SYSDATE) - ap.fecini_arriendo) DESC;                     -- días	

-- ============================================	
-- CASO 3: Informe de Arriendos Promedios por Tipo de Propiedad
-- ============================================
SELECT 
    tp.id_tipo_propiedad AS "TIPO PROPIEDAD",
    tp.desc_tipo_propiedad AS "DESCRIPCION",
    NVL(TO_CHAR(ROUND(AVG(dpa.valor_arriendo)), 'L999G999G999'), 'SIN DATO') AS "PROMEDIO VALOR ARRIENDO",
    NVL(TO_CHAR(ROUND(AVG(dpa.valor_arriendo * 0.15)), 'L999G999G999'), 'SIN DATO') AS "PROMEDIO GASTO COMUN",
    COUNT(dpa.nro_propiedad) AS "CANTIDAD PROPIEDADES",
    TO_CHAR(MAX(dpa.fecha_proceso), 'DD-Mon-YYYY') AS "FECHA PROCESO"
FROM 
    DETALLE_PROP_ARRENDADAS dpa
    JOIN PROPIEDAD p ON dpa.nro_propiedad = p.nro_propiedad
    JOIN TIPO_PROPIEDAD tp ON p.id_tipo_propiedad = tp.id_tipo_propiedad
GROUP BY 
    tp.id_tipo_propiedad, tp.desc_tipo_propiedad
HAVING 
    ROUND(AVG(dpa.valor_arriendo)) >= &VALOR_PROMEDIO_MINIMO
ORDER BY 
    tp.id_tipo_propiedad ASC,
    ROUND(AVG(dpa.valor_arriendo)) DESC;	
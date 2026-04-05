-- ============================================================
--  SISTEMA DE ANESTESIOLOGÍA - MODELO RELACIONAL MySQL 8
--  Pontificia Universidad Javeriana de Cali
-- ============================================================

CREATE DATABASE IF NOT EXISTS anestesia_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE anestesia_db;

-- ============================================================
--  1. USUARIOS
-- ============================================================
CREATE TABLE users (
    id            INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    username      VARCHAR(60)     NOT NULL UNIQUE,
    email         VARCHAR(120)    NOT NULL UNIQUE,
    password_hash VARCHAR(255)    NOT NULL,
    nombre        VARCHAR(80)     NOT NULL,
    apellido      VARCHAR(80)     NOT NULL,
    codigo        VARCHAR(20)     UNIQUE,              -- código estudiantil
    especializacion VARCHAR(100)  DEFAULT 'Anestesiología',
    semestre      TINYINT UNSIGNED DEFAULT 1,
    fecha_ingreso DATE,
    rol           ENUM('estudiante','docente','admin') NOT NULL DEFAULT 'estudiante',
    is_active     BOOLEAN         NOT NULL DEFAULT TRUE,
    created_at    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX idx_users_username (username),
    INDEX idx_users_email (email)
) ENGINE=InnoDB;

-- ============================================================
--  2. PROCEDIMIENTOS (cabecera)
-- ============================================================
CREATE TABLE procedures (
    id                  INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    user_id             INT UNSIGNED    NOT NULL,
    grupo_poblacional   ENUM('Adulto','Pediátrico') NOT NULL,
    tipo_cirugia        ENUM('Emergencia','Urgencia','Programada') NOT NULL,
    grupo_quirurgico    VARCHAR(100)    NOT NULL,
    intentos            TINYINT UNSIGNED NOT NULL DEFAULT 1,
    exitos              TINYINT UNSIGNED NOT NULL DEFAULT 1,
    comentario_evaluador TEXT,
    firma_base64        LONGTEXT,                      -- firma digital en base64 PNG
    fecha               DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_proc_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_proc_user  (user_id),
    INDEX idx_proc_fecha (fecha),
    INDEX idx_proc_grupo (grupo_quirurgico)
) ENGINE=InnoDB;

-- ============================================================
--  3. DETALLE DE PROCEDIMIENTOS (checklist de técnicas)
--     Un row por cada técnica registrada en la pantalla Register
-- ============================================================
CREATE TABLE procedure_items (
    id              INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    procedure_id    INT UNSIGNED    NOT NULL,
    nombre          VARCHAR(100)    NOT NULL,   -- ej. "Intubación orotraqueal"
    realizado       BOOLEAN         NOT NULL,   -- TRUE = Sí, FALSE = No
    PRIMARY KEY (id),
    CONSTRAINT fk_item_proc FOREIGN KEY (procedure_id) REFERENCES procedures(id) ON DELETE CASCADE,
    INDEX idx_item_proc (procedure_id)
) ENGINE=InnoDB;

-- ============================================================
--  4. EVALUACIONES CUSUM
--     Guarda los valores calculados para el gráfico CUSUM
-- ============================================================
CREATE TABLE cusum_records (
    id              INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    user_id         INT UNSIGNED    NOT NULL,
    procedure_id    INT UNSIGNED    NOT NULL,
    cusum_value     DECIMAL(10,4)   NOT NULL DEFAULT 0,
    alerta          BOOLEAN         NOT NULL DEFAULT FALSE,  -- TRUE si supera umbral
    umbral          DECIMAL(10,4)   NOT NULL DEFAULT 5.0,
    fecha           DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_cusum_user  FOREIGN KEY (user_id)      REFERENCES users(id)      ON DELETE CASCADE,
    CONSTRAINT fk_cusum_proc  FOREIGN KEY (procedure_id) REFERENCES procedures(id) ON DELETE CASCADE,
    INDEX idx_cusum_user (user_id),
    INDEX idx_cusum_fecha(fecha)
) ENGINE=InnoDB;

-- ============================================================
--  5. RESULTADOS / MÉTRICAS DASHBOARD
--     Métricas pre-calculadas por usuario (cache rápido)
-- ============================================================
CREATE TABLE user_metrics (
    id                      INT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_id                 INT UNSIGNED NOT NULL UNIQUE,
    total_procedimientos    INT UNSIGNED NOT NULL DEFAULT 0,
    tasa_exito              DECIMAL(5,2) NOT NULL DEFAULT 0.00,  -- porcentaje 0-100
    intubaciones            INT UNSIGNED NOT NULL DEFAULT 0,
    anestesias_generales    INT UNSIGNED NOT NULL DEFAULT 0,
    bloqueos_regionales     INT UNSIGNED NOT NULL DEFAULT 0,
    anestesias_locales      INT UNSIGNED NOT NULL DEFAULT 0,
    updated_at              DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_metric_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================
--  VISTAS ÚTILES
-- ============================================================

-- Vista principal para history.dart
CREATE OR REPLACE VIEW v_procedure_history AS
SELECT
    p.id,
    p.user_id,
    u.nombre,
    u.apellido,
    p.grupo_poblacional,
    p.tipo_cirugia,
    p.grupo_quirurgico,
    p.intentos,
    p.exitos,
    ROUND((p.exitos / NULLIF(p.intentos, 0)) * 100, 1) AS porcentaje_exito,
    p.comentario_evaluador,
    p.fecha,
    p.created_at
FROM procedures p
JOIN users u ON u.id = p.user_id;

-- Vista de items por procedimiento
CREATE OR REPLACE VIEW v_procedure_full AS
SELECT
    p.id,
    p.grupo_quirurgico,
    p.tipo_cirugia,
    p.fecha,
    GROUP_CONCAT(
        CASE WHEN pi.realizado = TRUE THEN pi.nombre END
        SEPARATOR ', '
    ) AS procedimientos_realizados
FROM procedures p
LEFT JOIN procedure_items pi ON pi.procedure_id = p.id
GROUP BY p.id, p.grupo_quirurgico, p.tipo_cirugia, p.fecha;

-- ============================================================
--  DATOS INICIALES
-- ============================================================
INSERT INTO users (username, email, password_hash, nombre, apellido, codigo, rol)
VALUES ('admin', 'admin@javeriana.edu.co',
        '$2b$12$placeholder_hash_reemplazar_con_bcrypt', 'Admin', 'Sistema', 'ADMIN001', 'admin');

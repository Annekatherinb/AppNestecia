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
CREATE TABLE IF NOT EXISTS users (
    id              INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    username        VARCHAR(60)     NOT NULL UNIQUE,
    email           VARCHAR(120)    NOT NULL UNIQUE,
    password_hash   VARCHAR(255)    NOT NULL,
    nombre          VARCHAR(80)     NOT NULL,
    apellido        VARCHAR(80)     NOT NULL,
    codigo          VARCHAR(20)     UNIQUE,
    especializacion VARCHAR(100)    DEFAULT 'Anestesiología',
    semestre        TINYINT UNSIGNED DEFAULT 1,
    fecha_ingreso   DATE,
    rol             ENUM('estudiante','docente','admin') NOT NULL DEFAULT 'estudiante',
    is_active       BOOLEAN         NOT NULL DEFAULT TRUE,
    -- Recuperación de contraseña
    reset_token     VARCHAR(255)    DEFAULT NULL,
    reset_token_exp DATETIME        DEFAULT NULL,
    created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX idx_users_username (username),
    INDEX idx_users_email    (email)
) ENGINE=InnoDB;

-- ============================================================
--  2. PROCEDIMIENTOS (cabecera)
-- ============================================================
CREATE TABLE IF NOT EXISTS procedures (
    id                  INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    user_id             INT UNSIGNED    NOT NULL,
    grupo_poblacional   ENUM('Adulto','Pediátrico') NOT NULL,
    tipo_cirugia        ENUM('Emergencia','Urgencia','Programada') NOT NULL,
    grupo_quirurgico    VARCHAR(100)    NOT NULL,
    intentos            TINYINT UNSIGNED NOT NULL DEFAULT 1,
    exitos              TINYINT UNSIGNED NOT NULL DEFAULT 1,
    comentario_evaluador TEXT,
    firma_base64        LONGTEXT,
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
-- ============================================================
CREATE TABLE IF NOT EXISTS procedure_items (
    id              INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    procedure_id    INT UNSIGNED    NOT NULL,
    nombre          VARCHAR(100)    NOT NULL,
    realizado       BOOLEAN         NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_item_proc FOREIGN KEY (procedure_id) REFERENCES procedures(id) ON DELETE CASCADE,
    INDEX idx_item_proc (procedure_id)
) ENGINE=InnoDB;

-- ============================================================
--  4. EVALUACIONES CUSUM
-- ============================================================
CREATE TABLE IF NOT EXISTS cusum_records (
    id              INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    user_id         INT UNSIGNED    NOT NULL,
    procedure_id    INT UNSIGNED    NOT NULL,
    tipo_procedimiento VARCHAR(50)  NOT NULL DEFAULT 'orotraqueal',
    cusum_value     DECIMAL(10,4)   NOT NULL DEFAULT 0,
    alerta          BOOLEAN         NOT NULL DEFAULT FALSE,
    umbral          DECIMAL(10,4)   NOT NULL DEFAULT 5.0,
    fecha           DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_cusum_user  FOREIGN KEY (user_id)      REFERENCES users(id)      ON DELETE CASCADE,
    CONSTRAINT fk_cusum_proc  FOREIGN KEY (procedure_id) REFERENCES procedures(id) ON DELETE CASCADE,
    INDEX idx_cusum_user  (user_id),
    INDEX idx_cusum_fecha (fecha)
) ENGINE=InnoDB;

-- ============================================================
--  5. MÉTRICAS DEL DASHBOARD
-- ============================================================
CREATE TABLE IF NOT EXISTS user_metrics (
    id                      INT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_id                 INT UNSIGNED NOT NULL UNIQUE,
    total_procedimientos    INT UNSIGNED NOT NULL DEFAULT 0,
    tasa_exito              DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    intubaciones            INT UNSIGNED NOT NULL DEFAULT 0,
    anestesias_generales    INT UNSIGNED NOT NULL DEFAULT 0,
    bloqueos_regionales     INT UNSIGNED NOT NULL DEFAULT 0,
    anestesias_locales      INT UNSIGNED NOT NULL DEFAULT 0,
    updated_at              DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_metric_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================
--  VISTAS
-- ============================================================

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

from sqlalchemy import (Column, Integer, String, Boolean, DateTime,
                        Enum, Text, ForeignKey, SmallInteger, DECIMAL)
from sqlalchemy.sql import func
from app.core.database import Base

class Procedure(Base):
    __tablename__ = "procedures"

    id                   = Column(Integer, primary_key=True, autoincrement=True)
    user_id              = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    grupo_poblacional    = Column(Enum("Adulto", "Pediátrico"), nullable=False)
    tipo_cirugia         = Column(Enum("Emergencia", "Urgencia", "Programada"), nullable=False)
    grupo_quirurgico     = Column(String(100), nullable=False)
    intentos             = Column(SmallInteger, default=1)
    exitos               = Column(SmallInteger, default=1)
    comentario_evaluador = Column(Text, nullable=True)
    firma_base64         = Column(Text, nullable=True)
    fecha                = Column(DateTime, server_default=func.now())
    created_at           = Column(DateTime, server_default=func.now())
    updated_at           = Column(DateTime, server_default=func.now(), onupdate=func.now())


class ProcedureItem(Base):
    __tablename__ = "procedure_items"

    id           = Column(Integer, primary_key=True, autoincrement=True)
    procedure_id = Column(Integer, ForeignKey("procedures.id", ondelete="CASCADE"), nullable=False)
    nombre       = Column(String(100), nullable=False)
    realizado    = Column(Boolean, nullable=False)


class CusumRecord(Base):
    __tablename__ = "cusum_records"

    id                 = Column(Integer, primary_key=True, autoincrement=True)
    user_id            = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    procedure_id       = Column(Integer, ForeignKey("procedures.id", ondelete="CASCADE"), nullable=False)
    tipo_procedimiento = Column(String(50), default="orotraqueal")
    cusum_value        = Column(DECIMAL(10, 4), default=0)
    alerta             = Column(Boolean, default=False)
    umbral             = Column(DECIMAL(10, 4), default=5.0)
    fecha              = Column(DateTime, server_default=func.now())


class UserMetrics(Base):
    __tablename__ = "user_metrics"

    id                   = Column(Integer, primary_key=True, autoincrement=True)
    user_id              = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), unique=True)
    total_procedimientos = Column(Integer, default=0)
    tasa_exito           = Column(DECIMAL(5, 2), default=0.00)
    intubaciones         = Column(Integer, default=0)
    anestesias_generales = Column(Integer, default=0)
    bloqueos_regionales  = Column(Integer, default=0)
    anestesias_locales   = Column(Integer, default=0)
    updated_at           = Column(DateTime, server_default=func.now(), onupdate=func.now())

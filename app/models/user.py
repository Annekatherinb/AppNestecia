from sqlalchemy import Column, Integer, String, Boolean, Date, DateTime, Enum, SmallInteger
from sqlalchemy.sql import func
from app.core.database import Base

class User(Base):
    __tablename__ = "users"

    id              = Column(Integer, primary_key=True, autoincrement=True)
    username        = Column(String(60), unique=True, nullable=False)
    email           = Column(String(120), unique=True, nullable=False)
    password_hash   = Column(String(255), nullable=False)
    nombre          = Column(String(80), nullable=False)
    apellido        = Column(String(80), nullable=False)
    codigo          = Column(String(20), unique=True, nullable=True)
    especializacion = Column(String(100), default="Anestesiología")
    semestre        = Column(SmallInteger, default=1)
    fecha_ingreso   = Column(Date, nullable=True)
    rol             = Column(Enum("estudiante", "docente", "admin"), default="estudiante")
    is_active       = Column(Boolean, default=True)
    reset_token     = Column(String(255), nullable=True)
    reset_token_exp = Column(DateTime, nullable=True)
    created_at      = Column(DateTime, server_default=func.now())
    updated_at      = Column(DateTime, server_default=func.now(), onupdate=func.now())

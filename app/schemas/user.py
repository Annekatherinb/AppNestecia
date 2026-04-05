from pydantic import BaseModel, EmailStr, field_validator
from typing import Optional
from datetime import date

# ─── Registro ──────────────────────────────────────────────────
class UserRegister(BaseModel):
    username:       str
    email:          EmailStr
    password:       str
    nombre:         str
    apellido:       str
    codigo:         Optional[str] = None
    especializacion: Optional[str] = "Anestesiología"
    semestre:       Optional[int] = 1
    fecha_ingreso:  Optional[date] = None

    @field_validator("password")
    @classmethod
    def password_strength(cls, v):
        if len(v) < 6:
            raise ValueError("La contraseña debe tener al menos 6 caracteres")
        return v

# ─── Login ─────────────────────────────────────────────────────
class UserLogin(BaseModel):
    username: str
    password: str

# ─── Respuesta token ───────────────────────────────────────────
class TokenResponse(BaseModel):
    access_token: str
    token_type:   str = "bearer"

# ─── Perfil público ────────────────────────────────────────────
class UserProfile(BaseModel):
    id:             int
    username:       str
    email:          str
    nombre:         str
    apellido:       str
    codigo:         Optional[str]
    especializacion: Optional[str]
    semestre:       Optional[int]
    fecha_ingreso:  Optional[date]
    rol:            str

    class Config:
        from_attributes = True

# ─── Cambiar contraseña (autenticado) ──────────────────────────
class ChangePassword(BaseModel):
    current_password: str
    new_password:     str

    @field_validator("new_password")
    @classmethod
    def password_strength(cls, v):
        if len(v) < 6:
            raise ValueError("La nueva contraseña debe tener al menos 6 caracteres")
        return v

# ─── Solicitar reset (olvidé contraseña) ───────────────────────
class ForgotPassword(BaseModel):
    email: EmailStr

# ─── Resetear con token ────────────────────────────────────────
class ResetPassword(BaseModel):
    token:        str
    new_password: str

    @field_validator("new_password")
    @classmethod
    def password_strength(cls, v):
        if len(v) < 6:
            raise ValueError("La nueva contraseña debe tener al menos 6 caracteres")
        return v

# ─── Actualizar perfil ─────────────────────────────────────────
class UserUpdate(BaseModel):
    nombre:         Optional[str] = None
    apellido:       Optional[str] = None
    email:          Optional[EmailStr] = None
    especializacion: Optional[str] = None
    semestre:       Optional[int] = None

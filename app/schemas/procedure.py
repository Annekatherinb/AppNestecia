from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime

# ─── Item de procedimiento ─────────────────────────────────────
class ProcedureItemIn(BaseModel):
    nombre:   str
    realizado: bool

class ProcedureItemOut(ProcedureItemIn):
    id: int
    class Config:
        from_attributes = True

# ─── Crear procedimiento ───────────────────────────────────────
class ProcedureCreate(BaseModel):
    grupo_poblacional:    str   # "Adulto" | "Pediátrico"
    tipo_cirugia:         str   # "Emergencia" | "Urgencia" | "Programada"
    grupo_quirurgico:     str
    intentos:             int   = 1
    exitos:               int   = 1
    comentario_evaluador: Optional[str] = None
    firma_base64:         Optional[str] = None
    items:                List[ProcedureItemIn] = []

# ─── Respuesta procedimiento ───────────────────────────────────
class ProcedureOut(BaseModel):
    id:                   int
    user_id:              int
    grupo_poblacional:    str
    tipo_cirugia:         str
    grupo_quirurgico:     str
    intentos:             int
    exitos:               int
    comentario_evaluador: Optional[str]
    fecha:                datetime
    items:                List[ProcedureItemOut] = []

    class Config:
        from_attributes = True

# ─── CUSUM ─────────────────────────────────────────────────────
class CusumOut(BaseModel):
    tipo_procedimiento: str
    valores:            List[float]

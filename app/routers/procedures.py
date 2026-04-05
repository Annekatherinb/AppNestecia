from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from decimal import Decimal

from app.core.database import get_db
from app.core.security import get_current_user
from app.models.user import User
from app.models.procedure import Procedure, ProcedureItem, CusumRecord, UserMetrics
from app.schemas.procedure import ProcedureCreate, ProcedureOut, CusumOut

router = APIRouter(prefix="/procedures", tags=["Procedimientos"])


# ─── CREAR PROCEDIMIENTO ───────────────────────────────────────
@router.post("", response_model=ProcedureOut, status_code=201)
def create_procedure(
    data: ProcedureCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    proc = Procedure(
        user_id              = current_user.id,
        grupo_poblacional    = data.grupo_poblacional,
        tipo_cirugia         = data.tipo_cirugia,
        grupo_quirurgico     = data.grupo_quirurgico,
        intentos             = data.intentos,
        exitos               = data.exitos,
        comentario_evaluador = data.comentario_evaluador,
        firma_base64         = data.firma_base64,
    )
    db.add(proc)
    db.flush()  # obtenemos el id antes del commit

    # Items del checklist
    for item in data.items:
        db.add(ProcedureItem(
            procedure_id = proc.id,
            nombre       = item.nombre,
            realizado    = item.realizado,
        ))

    # Calcular CUSUM simple: (exitos/intentos) - 0.8
    cusum_val = round((data.exitos / max(data.intentos, 1)) - 0.8, 4)
    db.add(CusumRecord(
        user_id            = current_user.id,
        procedure_id       = proc.id,
        tipo_procedimiento = _cusum_tipo(data.grupo_quirurgico),
        cusum_value        = Decimal(str(cusum_val)),
        alerta             = cusum_val > 5.0,
    ))

    # Actualizar métricas
    _update_metrics(db, current_user.id, data)

    db.commit()
    db.refresh(proc)

    # Cargar items manualmente para el response
    proc.items = db.query(ProcedureItem).filter(ProcedureItem.procedure_id == proc.id).all()
    return proc


# ─── LISTAR PROCEDIMIENTOS DEL USUARIO ────────────────────────
@router.get("", response_model=List[ProcedureOut])
def list_procedures(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    procs = (db.query(Procedure)
               .filter(Procedure.user_id == current_user.id)
               .order_by(Procedure.fecha.desc())
               .all())
    for p in procs:
        p.items = db.query(ProcedureItem).filter(ProcedureItem.procedure_id == p.id).all()
    return procs


# ─── DETALLE DE UN PROCEDIMIENTO ──────────────────────────────
@router.get("/{procedure_id}", response_model=ProcedureOut)
def get_procedure(
    procedure_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    proc = db.query(Procedure).filter(
        Procedure.id == procedure_id,
        Procedure.user_id == current_user.id,
    ).first()
    if not proc:
        raise HTTPException(404, "Procedimiento no encontrado")
    proc.items = db.query(ProcedureItem).filter(ProcedureItem.procedure_id == proc.id).all()
    return proc


# ─── CUSUM DEL USUARIO ────────────────────────────────────────
@router.get("/cusum/data", response_model=List[CusumOut])
def get_cusum(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    tipos = ["orotraqueal", "subaracnoidea", "mascara_laringea", "nasotraqueal"]
    result = []
    for tipo in tipos:
        records = (db.query(CusumRecord)
                     .filter(CusumRecord.user_id == current_user.id,
                             CusumRecord.tipo_procedimiento == tipo)
                     .order_by(CusumRecord.fecha)
                     .all())
        valores = [float(r.cusum_value) for r in records]
        result.append(CusumOut(tipo_procedimiento=tipo, valores=valores))
    return result


# ─── MÉTRICAS DEL DASHBOARD ───────────────────────────────────
@router.get("/metrics/me")
def get_metrics(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    m = db.query(UserMetrics).filter(UserMetrics.user_id == current_user.id).first()
    if not m:
        return {
            "total_procedimientos": 0,
            "tasa_exito": 0.0,
            "intubaciones": 0,
            "anestesias_generales": 0,
            "bloqueos_regionales": 0,
            "anestesias_locales": 0,
        }
    return {
        "total_procedimientos": m.total_procedimientos,
        "tasa_exito":           float(m.tasa_exito),
        "intubaciones":         m.intubaciones,
        "anestesias_generales": m.anestesias_generales,
        "bloqueos_regionales":  m.bloqueos_regionales,
        "anestesias_locales":   m.anestesias_locales,
    }


# ─── HELPERS ──────────────────────────────────────────────────
def _cusum_tipo(grupo: str) -> str:
    grupo_lower = grupo.lower()
    if "orotraqueal" in grupo_lower:
        return "orotraqueal"
    if "nasotraqueal" in grupo_lower:
        return "nasotraqueal"
    if "laríngea" in grupo_lower or "laringea" in grupo_lower:
        return "mascara_laringea"
    if "subaracnoidea" in grupo_lower:
        return "subaracnoidea"
    return "orotraqueal"


def _update_metrics(db: Session, user_id: int, data: ProcedureCreate):
    m = db.query(UserMetrics).filter(UserMetrics.user_id == user_id).first()
    if not m:
        m = UserMetrics(
            user_id=user_id,
            total_procedimientos=0,
            intubaciones=0,
            anestesias_generales=0,
            bloqueos_regionales=0,
            anestesias_locales=0,
            tasa_exito=0.0,
        )
        db.add(m)
        db.flush()  # persiste el objeto para poder sumarle

    # Asegura que ningún campo sea None antes de sumar
    m.total_procedimientos  = (m.total_procedimientos  or 0) + 1
    m.intubaciones          = (m.intubaciones          or 0)
    m.anestesias_generales  = (m.anestesias_generales  or 0)
    m.bloqueos_regionales   = (m.bloqueos_regionales   or 0)
    m.anestesias_locales    = (m.anestesias_locales    or 0)

    grupo = data.grupo_quirurgico.lower()
    if "intub" in grupo or "orotraqueal" in grupo or "nasotraqueal" in grupo:
        m.intubaciones += 1
    elif "general" in grupo:
        m.anestesias_generales += 1
    elif "regional" in grupo or "bloqueo" in grupo:
        m.bloqueos_regionales += 1
    elif "local" in grupo:
        m.anestesias_locales += 1

    m.tasa_exito = round((data.exitos / max(data.intentos, 1)) * 100, 2)
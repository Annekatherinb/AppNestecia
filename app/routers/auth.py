import secrets
from datetime import datetime, timedelta

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import (hash_password, verify_password,
                                create_access_token, get_current_user)
from app.models.user import User
from app.schemas.user import (UserRegister, TokenResponse,
                               UserProfile, ChangePassword,
                               ForgotPassword, ResetPassword, UserUpdate)

router = APIRouter(prefix="/auth", tags=["Autenticación"])


# ─── REGISTRO ──────────────────────────────────────────────────
@router.post("/register", response_model=UserProfile, status_code=201)
def register(data: UserRegister, db: Session = Depends(get_db)):
    if db.query(User).filter(User.username == data.username).first():
        raise HTTPException(400, "El usuario ya existe")
    if db.query(User).filter(User.email == data.email).first():
        raise HTTPException(400, "El correo ya está registrado")

    user = User(
        username        = data.username,
        email           = data.email,
        password_hash   = hash_password(data.password),
        nombre          = data.nombre,
        apellido        = data.apellido,
        codigo          = data.codigo,
        especializacion = data.especializacion,
        semestre        = data.semestre,
        fecha_ingreso   = data.fecha_ingreso,
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


# ─── LOGIN ─────────────────────────────────────────────────────
# OAuth2PasswordRequestForm es lo que Swagger envía con el botón Authorize.
# Flutter también lo usa enviando username y password como form-data
# (ver api_service.dart — el endpoint /auth/login acepta form-data).
@router.post("/login", response_model=TokenResponse)
def login(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: Session = Depends(get_db),
):
    user = db.query(User).filter(User.username == form_data.username).first()
    if not user or not verify_password(form_data.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Usuario o contraseña incorrectos",
        )
    if not user.is_active:
        raise HTTPException(400, "Cuenta desactivada")

    token = create_access_token({"sub": str(user.id)})
    return {"access_token": token, "token_type": "bearer"}


# ─── PERFIL ACTUAL ─────────────────────────────────────────────
@router.get("/me", response_model=UserProfile)
def me(current_user: User = Depends(get_current_user)):
    return current_user


# ─── ACTUALIZAR PERFIL ─────────────────────────────────────────
@router.patch("/me", response_model=UserProfile)
def update_profile(
    data: UserUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    for field, value in data.model_dump(exclude_none=True).items():
        setattr(current_user, field, value)
    db.commit()
    db.refresh(current_user)
    return current_user


# ─── CAMBIAR CONTRASEÑA (usuario autenticado) ──────────────────
@router.post("/change-password")
def change_password(
    data: ChangePassword,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if not verify_password(data.current_password, current_user.password_hash):
        raise HTTPException(400, "La contraseña actual es incorrecta")

    current_user.password_hash = hash_password(data.new_password)
    db.commit()
    return {"message": "Contraseña actualizada correctamente"}


# ─── OLVIDÉ MI CONTRASEÑA ──────────────────────────────────────
# En producción esto enviaría un email; aquí devuelve el token
# directamente para que lo veas durante el desarrollo.
@router.post("/forgot-password")
def forgot_password(data: ForgotPassword, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == data.email).first()
    # Siempre respondemos igual para no filtrar si el email existe
    if not user:
        return {"message": "Si el correo existe, recibirás instrucciones"}

    token = secrets.token_urlsafe(32)
    user.reset_token     = token
    user.reset_token_exp = datetime.utcnow() + timedelta(hours=1)
    db.commit()

    # ⚠️  En desarrollo devolvemos el token directamente.
    #     En producción: enviar por email y quitar este campo.
    return {
        "message": "Token generado (solo para desarrollo)",
        "reset_token": token,
    }


# ─── RESETEAR CONTRASEÑA CON TOKEN ────────────────────────────
@router.post("/reset-password")
def reset_password(data: ResetPassword, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.reset_token == data.token).first()

    if not user or user.reset_token_exp < datetime.utcnow():
        raise HTTPException(400, "Token inválido o expirado")

    user.password_hash  = hash_password(data.new_password)
    user.reset_token     = None
    user.reset_token_exp = None
    db.commit()
    return {"message": "Contraseña restablecida correctamente"}
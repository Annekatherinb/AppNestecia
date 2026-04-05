from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.database import engine, Base
from app.routers import auth, procedures

Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="API Anestesiología - PUJ Cali",
    description="Backend para el sistema de registro de procedimientos anestésicos",
    version="1.0.0",
)

# ─── CORS ─────────────────────────────────────────────────────
# Permite Flutter Web (Chrome), emulador Android y dispositivos físicos
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:8080",    # flutter run -d chrome (puerto por defecto)
        "http://localhost:8081",    # puerto alternativo
        "http://localhost:3000",
        "http://localhost:5000",
        "http://127.0.0.1:8080",
        "http://10.0.2.2:8000",
        "*",                        # quitar en producción
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(procedures.router)

@app.get("/", tags=["Estado"])
def health():
    return {"status": "ok", "message": "API de Anestesiología funcionando"}
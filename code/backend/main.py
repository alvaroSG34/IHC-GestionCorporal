from fastapi import FastAPI
from database import Base, engine
from app.pacientes.router import paciente
from app.evaluaciones.router import evaluacion
from app.pacientes.model.paciente import Paciente
from app.evaluaciones.model.evaluacion import Evaluacion
from fastapi.middleware.cors import CORSMiddleware
Base.metadata.create_all(bind=engine)

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # o restringe a localhost y tu dominio
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(paciente.router)
app.include_router(evaluacion.router)

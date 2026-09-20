from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from database import Base, engine
from app.pacientes.router import paciente
from app.evaluaciones.router import evaluacion
from app.evolucion.router import evolucion
from app.citas.router import cita
from app.dietas.router import dieta
from app.usuarios.router import usuario
from app.pacientes.model.paciente import Paciente
from app.evaluaciones.model.evaluacion import Evaluacion
from app.citas.model.cita import Cita
from app.dietas.model.dieta import Dieta, Comida, Alimento
from app.usuarios.model.usuario import Usuario

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
app.include_router(evolucion.router)
app.include_router(cita.router)
app.include_router(dieta.router)
app.include_router(usuario.router)

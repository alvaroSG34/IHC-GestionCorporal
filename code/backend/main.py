from fastapi import FastAPI
from database import Base, engine
from app.pacientes.router import paciente
from app.evaluaciones.router import evaluacion
from app.pacientes.model.paciente import Paciente
from app.evaluaciones.model.evaluacion import Evaluacion

Base.metadata.create_all(bind=engine)

app = FastAPI()

app.include_router(paciente.router)
app.include_router(evaluacion.router)

from datetime import datetime
from enum import Enum

from pydantic import BaseModel, Field


class EstadoCita(str, Enum):
    programada = "programada"
    cancelada = "cancelada"


class RegistrarCita(BaseModel):
    paciente_id: int
    fecha_hora: datetime
    tipo_consulta: str = Field(min_length=1, max_length=120)
    observacion: str | None = None


class ActualizarCita(BaseModel):
    paciente_id: int | None = None
    fecha_hora: datetime | None = None
    tipo_consulta: str | None = Field(default=None, min_length=1, max_length=120)
    observacion: str | None = None


class PacienteCita(BaseModel):
    id: int
    nombre: str


class MostrarCita(BaseModel):
    id: int
    paciente: PacienteCita
    fecha_hora: datetime
    tipo_consulta: str
    observacion: str | None
    estado: EstadoCita
    fecha_creacion: datetime


class AgendaCitas(BaseModel):
    hoy: list[MostrarCita]
    proximas: list[MostrarCita]
    anteriores: list[MostrarCita]

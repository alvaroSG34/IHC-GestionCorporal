from datetime import date, datetime
from enum import Enum

from pydantic import BaseModel, Field


class DiaSemana(str, Enum):
    lunes = "lunes"
    martes = "martes"
    miercoles = "miercoles"
    jueves = "jueves"
    viernes = "viernes"
    sabado = "sabado"
    domingo = "domingo"


class TipoComida(str, Enum):
    desayuno = "desayuno"
    almuerzo = "almuerzo"
    cena = "cena"


class CrearDieta(BaseModel):
    paciente_id: int
    nombre: str = Field(min_length=1, max_length=120)
    objetivo: str = Field(min_length=1, max_length=200)
    calorias_diarias: int = Field(gt=0)
    fecha_inicio: date


class ActualizarDieta(BaseModel):
    nombre: str | None = Field(default=None, min_length=1, max_length=120)
    objetivo: str | None = Field(default=None, min_length=1, max_length=200)
    calorias_diarias: int | None = Field(default=None, gt=0)
    fecha_inicio: date | None = None


class MostrarDieta(BaseModel):
    id: int
    paciente_id: int
    nombre: str
    objetivo: str
    calorias_diarias: int
    fecha_inicio: date
    esta_activa: bool
    fecha_creacion: datetime

    class Config:
        from_attributes = True


class CrearAlimento(BaseModel):
    nombre: str = Field(min_length=1, max_length=120)
    porcion: str = Field(min_length=1, max_length=100)
    calorias: int = Field(ge=0)
    observacion: str | None = None


class ActualizarAlimento(BaseModel):
    nombre: str | None = Field(default=None, min_length=1, max_length=120)
    porcion: str | None = Field(default=None, min_length=1, max_length=100)
    calorias: int | None = Field(default=None, ge=0)
    observacion: str | None = None


class MostrarAlimento(BaseModel):
    id: int
    nombre: str
    porcion: str
    calorias: int
    observacion: str | None

    class Config:
        from_attributes = True


class MostrarComida(BaseModel):
    id: int
    dia_semana: DiaSemana
    tipo: TipoComida
    alimentos: list[MostrarAlimento]
    total_calorias: int


class MostrarDiaComidas(BaseModel):
    dieta_id: int
    dia_semana: DiaSemana
    desayuno: MostrarComida | None = None
    almuerzo: MostrarComida | None = None
    cena: MostrarComida | None = None

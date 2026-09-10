from datetime import datetime
from enum import Enum

from pydantic import BaseModel


class MetricaEvolucion(str, Enum):
    peso = "peso"
    imc = "imc"
    masa_muscular = "masa_muscular"


class PeriodoEvolucion(str, Enum):
    ultimas_3 = "ultimas_3"
    ultimo_mes = "ultimo_mes"
    ultimos_3_meses = "ultimos_3_meses"
    todo_historial = "todo_historial"
    personalizado = "personalizado"


class PacienteEvolucion(BaseModel):
    id: int
    nombre: str


class PuntoEvolucion(BaseModel):
    nro_evaluacion: int
    fecha: datetime
    valor: float


class ResumenEvolucion(BaseModel):
    valor_inicial: float | None
    valor_actual: float | None
    cambio: float | None
    cantidad_evaluaciones: int


class MostrarEvolucion(BaseModel):
    paciente: PacienteEvolucion
    metrica: MetricaEvolucion
    unidad: str
    periodo: PeriodoEvolucion
    resumen: ResumenEvolucion
    puntos: list[PuntoEvolucion]

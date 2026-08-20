from pydantic import BaseModel
from datetime import datetime

class RegistrarEvaluacion(BaseModel):
    peso: float
    paciente_id: int

class MostrarEvaluacion(BaseModel):
    id:int
    peso:float
    fecha_registro:datetime
    paciente_id: int
    
    class Config:
        from_attributes = True

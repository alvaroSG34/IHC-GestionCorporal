from pydantic import BaseModel,field_validator
from datetime import date
from typing import Optional,Literal

class RegistrarPaciente(BaseModel):
    nombre: str
    fecha_nacimiento: date
    sexo: Literal["M","F"]
    telefono:Optional[str]=None

class ActualizarPaciente(BaseModel):
    nombre: Optional[str]=None
    fecha_nacimiento: Optional[date]=None
    sexo: Optional[Literal["M","F"]]=None
    telefono:Optional[str]=None

class MostrarPaciente(BaseModel):
    id:int
    nombre:str
    sexo: Literal["M","F"]
    fecha_nacimiento:date
    telefono:Optional[str]

    class Config:
        from_attributes = True    
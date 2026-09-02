from pydantic import BaseModel, computed_field
from datetime import datetime

class RegistrarEvaluacion(BaseModel):

    altura: int
    peso: float
    masa_muscular: float
    observacion: str | None = None
    paciente_id: int

def imc(peso:float,altura:int)->float:
    altura_metro = altura / 100
    altura_cuadrada = altura_metro ** 2
    imc_calculado = round((peso /altura_cuadrada),2)
    return imc_calculado  

class MostrarEvaluacion(BaseModel):
    id:int
    nro_evaluacion: int
    altura: int
    peso:float
    masa_muscular: float
    observacion: str | None = None
    fecha_registro:datetime
    paciente_id: int

    @computed_field
    def imc(self)->float:
        return imc(self.peso,self.altura)
    
    class Config:
        from_attributes = True

class MostrarUltimaEvaluacion(BaseModel):
    altura: int
    peso:float
    
    @computed_field
    def imc(self)->float:
        return imc(self.peso,self.altura)  
    
    class Config:
        from_attributes = True
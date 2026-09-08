from pydantic import BaseModel,EmailStr
from datetime import date
from typing import Optional,Literal

class RegistrarUsuario(BaseModel):
    correo_electronico: EmailStr
    contrasena:str
    fecha_nacimiento: date
    telefono:Optional[str]=None
    profesion:str
    clinica:str

class LoginUsuario(BaseModel):
    correo_electronico:EmailStr
    contrasena:str

class MostrarUsuario(BaseModel):
    id:int
    correo_electronico:EmailStr
    fecha_nacimiento:date
    telefono:Optional[str]
    profesion:str
    clinica:str

    class Config:
        from_attributes = True

class TokenResponse(BaseModel):
    access_token:str
    token_type:str = "bearer"
    usuario: MostrarUsuario


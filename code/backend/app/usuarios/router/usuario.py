from datetime import date
from fastapi import APIRouter, Depends,HTTPException,status
from sqlalchemy.orm import Session
from database import get_db
from app.usuarios.model.usuario import Usuario
from app.usuarios.schema.usuario import RegistrarUsuario,LoginUsuario,MostrarUsuario,TokenResponse
from app.core.security import hash_contrasena,verificar_contrasena
from app.core.auth import crear_token 
import re

router = APIRouter(tags=["usuarios"])

@router.post("/registrar",response_model=TokenResponse,status_code=status.HTTP_201_CREATED)
def registrar_usuario(datos:RegistrarUsuario,db:Session=Depends(get_db)):
    if datos.correo_electronico is None or datos.contrasena is None or datos.fecha_nacimiento is None or datos.profesion is None or datos.clinica is None:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST,detail="Todos los campos son obligatorios")
    if len(datos.contrasena) < 8:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST,detail="La contraseña debe tener al menos 8 caracteres")
    if not re.search(r"[A-Z]", datos.contrasena) or not re.search(r"[a-z]", datos.contrasena) or not re.search(r"\d", datos.contrasena):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST,detail="La contraseña debe contener al menos una letra mayúscula, una letra minúscula y un número")

    if datos.fecha_nacimiento >= date.today():
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST,detail="La fecha de nacimiento debe ser anterior a la fecha actual")


    usuario_existe = db.query(Usuario).filter(Usuario.correo_electronico == datos.correo_electronico).first()
    if usuario_existe is not None:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST,detail="El correo electronico ya esta registrado")
    try:
        nuevo_usuario = Usuario(
        correo_electronico = datos.correo_electronico,
        contrasena = hash_contrasena(datos.contrasena),
        fecha_nacimiento=datos.fecha_nacimiento,
        telefono=datos.telefono,
        profesion=datos.profesion,
        clinica=datos.clinica
        )
        db.add(nuevo_usuario)
        db.commit()
        db.refresh(nuevo_usuario)
        token = crear_token({"sub":str(nuevo_usuario.id)})
        return TokenResponse(access_token=token,usuario=nuevo_usuario)    
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,detail="Error al registrar usuario")

@router.post("/login",response_model=TokenResponse)
def login(datos:LoginUsuario,db:Session=Depends(get_db)):
    usuario = db.query(Usuario).filter(Usuario.correo_electronico == datos.correo_electronico).first()
    if not usuario or not verificar_contrasena(datos.contrasena,usuario.contrasena):
         raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,detail="Credenciales incorrectas")
    token = crear_token({"sub":str(usuario.id)})
    return TokenResponse(access_token=token,usuario=usuario) 


from fastapi import APIRouter, Depends, HTTPException,status
from sqlalchemy.orm import Session
from typing import List
from database import get_db
from app.pacientes.model.paciente import Paciente
from app.pacientes.schema.paciente import RegistrarPaciente,MostrarPaciente,ActualizarPaciente
from datetime import date

router = APIRouter(prefix="/pacientes", tags=["Pacientes"])

@router.post("/", response_model=MostrarPaciente,status_code=status.HTTP_201_CREATED)
def registrar_paciente(datos: RegistrarPaciente,db: Session = Depends(get_db)):
    if(datos.nombre == "" or datos.fecha_nacimiento >= date.today()):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, 
            detail="Datos del paciente son incorrectos",   
            )
    paciente_a_registrar = Paciente(
        nombre=datos.nombre,
        sexo=datos.sexo,
        fecha_nacimiento=datos.fecha_nacimiento,
        telefono=datos.telefono
        )
    try:
        db.add(paciente_a_registrar)
        db.commit()
        db.refresh(paciente_a_registrar)
        return paciente_a_registrar
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code = status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail = "Error al registrar paciente"
        )

@router.get("/{paciente_id}",response_model=MostrarPaciente)
def mostrar_paciente(paciente_id:int,db:Session = Depends(get_db)):
    paciente_obtenido = db.query(Paciente).filter(Paciente.id == paciente_id,Paciente.esta_activo == True).first()
    if paciente_obtenido is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, 
            detail="paciente no encontrado",   
            )
    return paciente_obtenido

@router.get("/",response_model=List[MostrarPaciente])
def mostrar_pacientes(db:Session = Depends(get_db)):
    pacientes_obtenidos = db.query(Paciente).filter(Paciente.esta_activo == True).all() 
    return pacientes_obtenidos

@router.put("/{paciente_id}",response_model=ActualizarPaciente)
def actualizar_paciente(paciente_id:int,datos:ActualizarPaciente,db:Session = Depends(get_db)):
    paciente_a_actualizar = mostrar_paciente(paciente_id,db)
    if paciente_a_actualizar is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="paciente no encontrado",
        )
    if(datos.nombre is None or datos.fecha_nacimiento is None or datos.fecha_nacimiento >= date.today()  or datos.sexo is None):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST, 
                detail="Datos del paciente son incorrectos",   
                )
    paciente_a_actualizar.nombre = datos.nombre
    paciente_a_actualizar.fecha_nacimiento = datos.fecha_nacimiento
    paciente_a_actualizar.sexo = datos.sexo
    paciente_a_actualizar.telefono = datos.telefono
    try:
        db.commit()
        db.refresh(paciente_a_actualizar)
        return paciente_a_actualizar
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error al actualizar paciente",
        )

@router.delete("/{paciente_id}",status_code = status.HTTP_200_OK)
def eliminar_paciente(paciente_id:int,db:Session =Depends(get_db)):
    paciente_a_eliminar = db.query(Paciente).filter(Paciente.id == paciente_id and Paciente.esta_activo == True).first()
    if paciente_a_eliminar is None:
        raise HTTPException(
            status_code =status.HTTP_404_NOT_FOUND,
            detail = "paciente no encontrado",
        )
    if paciente_a_eliminar.esta_activo == False:
        raise HTTPException(
            status_code =status.HTTP_400_BAD_REQUEST,
            detail = "paciente ya eliminado",
        )
    try:
        paciente_a_eliminar.esta_activo = False
        db.commit()
        return {"detail":"paciente eliminado correctamente"}
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code = status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail = "Error al eliminar paciente",
        )
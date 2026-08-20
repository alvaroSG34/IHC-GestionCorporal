from fastapi import APIRouter, Depends, HTTPException,status
from sqlalchemy.orm import Session
from typing import List
from database import get_db
from app.pacientes.model.paciente import Paciente
from app.pacientes.schema.paciente import RegistrarPaciente,MostrarPaciente
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
    paciente_obtenido = db.query(Paciente).filter(Paciente.id == paciente_id).first()
    if paciente_obtenido is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, 
            detail="paciente no encontrado",   
            )
    return paciente_obtenido

@router.get("/",response_model=List[MostrarPaciente])
def mostrar_pacientes(db:Session = Depends(get_db)):
    pacientes_obtenidos = db.query(Paciente).all() 
    return pacientes_obtenidos
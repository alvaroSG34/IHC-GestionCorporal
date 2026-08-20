from fastapi import APIRouter, Depends, HTTPException,status
from sqlalchemy.orm import Session
from typing import List
from database import get_db
from app.evaluaciones.model.evaluacion import Evaluacion
from app.evaluaciones.schema.evaluacion import RegistrarEvaluacion,MostrarEvaluacion
from app.pacientes.model.paciente import Paciente

router = APIRouter(prefix="/evaluaciones", tags=["Evaluaciones"])

@router.post("/", response_model= MostrarEvaluacion,status_code=status.HTTP_201_CREATED)
def registrar_evaluacion(datos:RegistrarEvaluacion,db:Session=Depends(get_db)):
    existe_paciente = db.query(Paciente).filter(Paciente.id==datos.paciente_id).first()
    if existe_paciente is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Paciente no encontrado"
            )
    if datos.peso <= 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="El peso debe ser mayor a 0"
        )
    evaluacion_a_registrar = Evaluacion(
        peso=datos.peso,
        paciente_id=datos.paciente_id
    )
    try:
        db.add(evaluacion_a_registrar)
        db.commit()
        db.refresh(evaluacion_a_registrar)
        return evaluacion_a_registrar
    except Exception:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error al registrar evaluacion"
        )

@router.get("/{evaluacion_id}",response_model=MostrarEvaluacion)
def mostrar_evaluacion(evaluacion_id:int , db:Session=Depends(get_db)):
    evaluacion_obtenida = db.query(Evaluacion).filter(Evaluacion.id==evaluacion_id).first()
    if evaluacion_obtenida is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Evaluacion no encontrada"
        )
    return evaluacion_obtenida
    
@router.get("/paciente/{paciente_id}",response_model=List[MostrarEvaluacion])
def mostrar_evaluaciones_de_paciente(paciente_id:int,db:Session=Depends(get_db)):
    existe_paciente = db.query(Paciente).filter(Paciente.id==paciente_id).first()
    if existe_paciente is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Paciente no encontrado"
        )
    evaluaciones_del_paciente_obtenidas=db.query(Evaluacion).filter(Evaluacion.paciente_id==paciente_id).order_by(Evaluacion.fecha_registro.desc()).all()
    return evaluaciones_del_paciente_obtenidas 
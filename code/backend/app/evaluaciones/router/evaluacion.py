from fastapi import APIRouter, Depends, HTTPException,status
from sqlalchemy.orm import Session
from sqlalchemy import func
from typing import List
from database import get_db
from app.evaluaciones.model.evaluacion import Evaluacion
from app.evaluaciones.schema.evaluacion import RegistrarEvaluacion,MostrarEvaluacion,MostrarUltimaEvaluacion,ActualizarEvaluacion
from app.pacientes.model.paciente import Paciente

router = APIRouter(prefix="/evaluaciones", tags=["Evaluaciones"])

@router.post("/", response_model= MostrarEvaluacion,status_code=status.HTTP_201_CREATED)
def registrar_evaluacion(datos:RegistrarEvaluacion,db:Session=Depends(get_db)):
    existe_paciente = db.query(Paciente).filter(Paciente.id==datos.paciente_id,Paciente.esta_activo==True).first()
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
    if datos.altura <= 0:
        raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="La altura debe ser mayor a 0"
                )
    if datos.masa_muscular <= 0 or datos.masa_muscular >100:
        raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="La masa muscular debe ser mayor a 0 y no mayor a 100"
                ) 
    ultimo_nro_evaluacion = db.query(func.max(Evaluacion.nro_evaluacion)).filter(Evaluacion.paciente_id == datos.paciente_id).scalar()
    nuevo_nro_evaluacion = (ultimo_nro_evaluacion or 0 )+ 1            
    evaluacion_a_registrar = Evaluacion(
        nro_evaluacion= nuevo_nro_evaluacion, 
        altura=datos.altura,
        peso=datos.peso,
        masa_muscular= datos.masa_muscular,
        observacion=datos.observacion,
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
    evaluacion_obtenida = db.query(Evaluacion).filter(Evaluacion.id==evaluacion_id, Evaluacion.esta_activo==True).first()
    if evaluacion_obtenida is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Evaluacion no encontrada"
        )
    return evaluacion_obtenida
    
@router.get("/paciente/{paciente_id}",response_model=List[MostrarEvaluacion])
def mostrar_evaluaciones_de_paciente(paciente_id:int,db:Session=Depends(get_db)):
    existe_paciente = db.query(Paciente).filter(Paciente.id==paciente_id,Paciente.esta_activo==True).first()
    if existe_paciente is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Paciente no encontrado"
        )
    evaluaciones_del_paciente_obtenidas=db.query(Evaluacion).filter(Evaluacion.paciente_id==paciente_id,Evaluacion.esta_activo==True).order_by(Evaluacion.fecha_registro.desc()).all()
    return evaluaciones_del_paciente_obtenidas 

@router.get("/paciente/{paciente_id}/ultimaevaluacion",response_model=MostrarUltimaEvaluacion)
def mostrar_ultima_evaluacion_de_paciente(paciente_id:int,db:Session=Depends(get_db)):
    existe_paciente = db.query(Paciente).filter(Paciente.id==paciente_id,Paciente.esta_activo==True).first()
    if existe_paciente is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Paciente no encontrado"
        )
    ultima_evaluacion_del_paciente_obtenida=db.query(Evaluacion).filter(Evaluacion.paciente_id==paciente_id,Evaluacion.esta_activo==True).order_by(Evaluacion.nro_evaluacion.desc()).first()
    if ultima_evaluacion_del_paciente_obtenida is None:
        raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="Evaluacion no encontrada"
                )
    return ultima_evaluacion_del_paciente_obtenida

@router.put("/{evaluacion_id}",response_model=MostrarEvaluacion)
def actualizar_evaluacion(evaluacion_id:int,datos:ActualizarEvaluacion,db:Session=Depends(get_db)):
    evaluacion_a_actualizar = db.query(Evaluacion).filter(Evaluacion.id==evaluacion_id,Evaluacion.esta_activo==True).first()
    if evaluacion_a_actualizar is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="evaluacion de paciente no encontrado",
        )
    if datos.paciente_id is None:
        raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="paciente no encontrado",
            )
    existe_paciente = db.query(Paciente).filter(Paciente.id==datos.paciente_id,Paciente.esta_activo==True).first()
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
    if datos.altura <= 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="La altura debe ser mayor a 0"
        )
    if datos.masa_muscular <= 0 or datos.masa_muscular >100:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="La masa muscular debe ser mayor a 0 y no mayor a 100"
        ) 
    evaluacion_a_actualizar.altura = datos.altura
    evaluacion_a_actualizar.peso = datos.peso
    evaluacion_a_actualizar.masa_muscular = datos.masa_muscular
    evaluacion_a_actualizar.observacion = datos.observacion
    evaluacion_a_actualizar.paciente_id = datos.paciente_id
    try:
        db.commit()
        db.refresh(evaluacion_a_actualizar)
        return evaluacion_a_actualizar
    except Exception as e:
        db.rollback()
        raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Error al actualizar evaluacion"
            )
@router.delete("/{evaluacion_id}",status_code=status.HTTP_200_OK)
def eliminar_evaluacion(evaluacion_id:int,db:Session=Depends(get_db)):
    evaluacion_a_eliminar = db.query(Evaluacion).filter(Evaluacion.id==evaluacion_id, Evaluacion.esta_activo==True).first()
    if evaluacion_a_eliminar is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Evaluacion no encontrada"
        )
    try:
        evaluacion_a_eliminar.esta_activo = False
        db.commit()
        return {"detail":"evaluacion eliminada correctamente"}
    except Exception as e:
        db.rollback()
        raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Error al eliminar evaluacion"
            )        
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session, joinedload

from app.core.dependencies import obtener_usuario_actual
from app.dietas.model.dieta import Alimento, Comida, Dieta
from app.dietas.schema.dieta import (
    ActualizarAlimento,
    ActualizarDieta,
    CrearAlimento,
    CrearDieta,
    DiaSemana,
    MostrarAlimento,
    MostrarComida,
    MostrarDiaComidas,
    MostrarDieta,
    TipoComida,
)
from app.pacientes.model.paciente import Paciente
from app.usuarios.model.usuario import Usuario
from database import get_db


router = APIRouter(
    prefix="/dietas",
    tags=["Dietas"],
    dependencies=[Depends(obtener_usuario_actual)],
)


def _paciente_del_usuario(paciente_id: int, usuario_id: int, db: Session) -> Paciente:
    paciente = db.query(Paciente).filter(
        Paciente.id == paciente_id,
        Paciente.usuario_id == usuario_id,
        Paciente.esta_activo.is_(True),
    ).first()
    if paciente is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Paciente no encontrado")
    return paciente


def _dieta_del_usuario(dieta_id: int, usuario_id: int, db: Session) -> Dieta:
    dieta = db.query(Dieta).join(Paciente).filter(
        Dieta.id == dieta_id,
        Dieta.esta_activa.is_(True),
        Paciente.usuario_id == usuario_id,
        Paciente.esta_activo.is_(True),
    ).first()
    if dieta is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Dieta no encontrada")
    return dieta


def _comida_del_usuario(
    dieta_id: int,
    dia_semana: DiaSemana,
    tipo: TipoComida,
    usuario_id: int,
    db: Session,
    crear: bool = False,
) -> Comida:
    dieta = _dieta_del_usuario(dieta_id, usuario_id, db)
    comida = db.query(Comida).filter(
        Comida.dieta_id == dieta.id,
        Comida.dia_semana == dia_semana.value,
        Comida.tipo == tipo.value,
    ).first()
    if comida is None and crear:
        comida = Comida(dieta_id=dieta.id, dia_semana=dia_semana.value, tipo=tipo.value)
        db.add(comida)
        db.flush()
    if comida is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Comida no encontrada")
    return comida


def _mostrar_comida(comida: Comida) -> MostrarComida:
    alimentos = [MostrarAlimento.model_validate(alimento) for alimento in comida.alimentos]
    return MostrarComida(
        id=comida.id,
        dia_semana=comida.dia_semana,
        tipo=comida.tipo,
        alimentos=alimentos,
        total_calorias=sum(alimento.calorias for alimento in comida.alimentos),
    )


@router.post("/", response_model=MostrarDieta, status_code=status.HTTP_201_CREATED)
def crear_dieta(
    datos: CrearDieta,
    db: Session = Depends(get_db),
    usuario_actual: Usuario = Depends(obtener_usuario_actual),
):
    paciente = _paciente_del_usuario(datos.paciente_id, usuario_actual.id, db)
    try:
        db.query(Dieta).filter(
            Dieta.paciente_id == paciente.id,
            Dieta.esta_activa.is_(True),
        ).update({Dieta.esta_activa: False}, synchronize_session=False)
        dieta = Dieta(**datos.model_dump())
        db.add(dieta)
        db.commit()
        db.refresh(dieta)
        return dieta
    except Exception:
        db.rollback()
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Error al crear dieta")


@router.get("/paciente/{paciente_id}", response_model=list[MostrarDieta])
def listar_dietas_paciente(
    paciente_id: int,
    db: Session = Depends(get_db),
    usuario_actual: Usuario = Depends(obtener_usuario_actual),
):
    _paciente_del_usuario(paciente_id, usuario_actual.id, db)
    return db.query(Dieta).filter(Dieta.paciente_id == paciente_id).order_by(Dieta.fecha_creacion.desc()).all()


@router.get("/paciente/{paciente_id}/activa", response_model=MostrarDieta)
def obtener_dieta_activa(
    paciente_id: int,
    db: Session = Depends(get_db),
    usuario_actual: Usuario = Depends(obtener_usuario_actual),
):
    _paciente_del_usuario(paciente_id, usuario_actual.id, db)
    dieta = db.query(Dieta).filter(Dieta.paciente_id == paciente_id, Dieta.esta_activa.is_(True)).first()
    if dieta is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="El paciente no tiene una dieta activa")
    return dieta


@router.get("/{dieta_id}", response_model=MostrarDieta)
def obtener_dieta(
    dieta_id: int,
    db: Session = Depends(get_db),
    usuario_actual: Usuario = Depends(obtener_usuario_actual),
):
    return _dieta_del_usuario(dieta_id, usuario_actual.id, db)


@router.patch("/{dieta_id}", response_model=MostrarDieta)
def actualizar_dieta(
    dieta_id: int,
    datos: ActualizarDieta,
    db: Session = Depends(get_db),
    usuario_actual: Usuario = Depends(obtener_usuario_actual),
):
    dieta = _dieta_del_usuario(dieta_id, usuario_actual.id, db)
    cambios = datos.model_dump(exclude_unset=True)
    if not cambios:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail="Debes enviar al menos un campo")
    for campo, valor in cambios.items():
        setattr(dieta, campo, valor)
    try:
        db.commit()
        db.refresh(dieta)
        return dieta
    except Exception:
        db.rollback()
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Error al actualizar dieta")


@router.delete("/{dieta_id}")
def desactivar_dieta(
    dieta_id: int,
    db: Session = Depends(get_db),
    usuario_actual: Usuario = Depends(obtener_usuario_actual),
):
    dieta = _dieta_del_usuario(dieta_id, usuario_actual.id, db)
    if not dieta.esta_activa:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="La dieta ya está inactiva")
    try:
        dieta.esta_activa = False
        db.commit()
        return {"detail": "Dieta desactivada correctamente"}
    except Exception:
        db.rollback()
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Error al desactivar dieta")


@router.get("/{dieta_id}/comidas/{dia_semana}", response_model=MostrarDiaComidas)
def obtener_comidas_del_dia(
    dieta_id: int,
    dia_semana: DiaSemana,
    db: Session = Depends(get_db),
    usuario_actual: Usuario = Depends(obtener_usuario_actual),
):
    _dieta_del_usuario(dieta_id, usuario_actual.id, db)
    comidas = db.query(Comida).options(joinedload(Comida.alimentos)).filter(
        Comida.dieta_id == dieta_id,
        Comida.dia_semana == dia_semana.value,
    ).all()
    por_tipo = {comida.tipo: _mostrar_comida(comida) for comida in comidas}
    return MostrarDiaComidas(
        dieta_id=dieta_id,
        dia_semana=dia_semana,
        desayuno=por_tipo.get(TipoComida.desayuno.value),
        almuerzo=por_tipo.get(TipoComida.almuerzo.value),
        cena=por_tipo.get(TipoComida.cena.value),
    )


@router.post("/{dieta_id}/comidas/{dia_semana}/{tipo}/alimentos", response_model=MostrarComida, status_code=status.HTTP_201_CREATED)
def agregar_alimento(
    dieta_id: int,
    dia_semana: DiaSemana,
    tipo: TipoComida,
    datos: CrearAlimento,
    db: Session = Depends(get_db),
    usuario_actual: Usuario = Depends(obtener_usuario_actual),
):
    try:
        comida = _comida_del_usuario(dieta_id, dia_semana, tipo, usuario_actual.id, db, crear=True)
        db.add(Alimento(comida_id=comida.id, **datos.model_dump()))
        db.commit()
        db.refresh(comida)
        return _mostrar_comida(comida)
    except HTTPException:
        db.rollback()
        raise
    except Exception:
        db.rollback()
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Error al agregar alimento")


@router.patch("/alimentos/{alimento_id}", response_model=MostrarAlimento)
def actualizar_alimento(
    alimento_id: int,
    datos: ActualizarAlimento,
    db: Session = Depends(get_db),
    usuario_actual: Usuario = Depends(obtener_usuario_actual),
):
    alimento = db.query(Alimento).join(Comida).join(Dieta).join(Paciente).filter(
        Alimento.id == alimento_id,
        Paciente.usuario_id == usuario_actual.id,
        Paciente.esta_activo.is_(True),
    ).first()
    if alimento is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Alimento no encontrado")
    cambios = datos.model_dump(exclude_unset=True)
    if not cambios:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail="Debes enviar al menos un campo")
    for campo, valor in cambios.items():
        setattr(alimento, campo, valor)
    try:
        db.commit()
        db.refresh(alimento)
        return alimento
    except Exception:
        db.rollback()
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Error al actualizar alimento")


@router.delete("/alimentos/{alimento_id}")
def eliminar_alimento(
    alimento_id: int,
    db: Session = Depends(get_db),
    usuario_actual: Usuario = Depends(obtener_usuario_actual),
):
    alimento = db.query(Alimento).join(Comida).join(Dieta).join(Paciente).filter(
        Alimento.id == alimento_id,
        Paciente.usuario_id == usuario_actual.id,
        Paciente.esta_activo.is_(True),
    ).first()
    if alimento is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Alimento no encontrado")
    try:
        db.delete(alimento)
        db.commit()
        return {"detail": "Alimento eliminado correctamente"}
    except Exception:
        db.rollback()
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Error al eliminar alimento")

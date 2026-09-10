from datetime import date

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.citas.model.cita import Cita
from app.citas.schema.cita import (
    ActualizarCita,
    AgendaCitas,
    EstadoCita,
    MostrarCita,
    PacienteCita,
    RegistrarCita,
)
from app.core.dependencies import obtener_usuario_actual
from app.pacientes.model.paciente import Paciente
from app.usuarios.model.usuario import Usuario
from database import get_db


router = APIRouter(
    prefix="/citas",
    tags=["Citas"],
    dependencies=[Depends(obtener_usuario_actual)],
)


def _obtener_paciente_del_usuario(
    paciente_id: int,
    usuario_id: int,
    db: Session,
) -> Paciente:
    paciente = (
        db.query(Paciente)
        .filter(
            Paciente.id == paciente_id,
            Paciente.usuario_id == usuario_id,
            Paciente.esta_activo.is_(True),
        )
        .first()
    )
    if paciente is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Paciente no encontrado",
        )
    return paciente


def _obtener_cita_del_usuario(cita_id: int, usuario_id: int, db: Session) -> Cita:
    cita = (
        db.query(Cita)
        .join(Paciente)
        .filter(
            Cita.id == cita_id,
            Cita.usuario_id == usuario_id,
            Paciente.usuario_id == usuario_id,
            Paciente.esta_activo.is_(True),
        )
        .first()
    )
    if cita is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Cita no encontrada",
        )
    return cita


def _validar_horario_disponible(
    fecha_hora,
    usuario_id: int,
    db: Session,
    cita_id_excluida: int | None = None,
) -> None:
    consulta = db.query(Cita).filter(
        Cita.usuario_id == usuario_id,
        Cita.fecha_hora == fecha_hora,
        Cita.estado == EstadoCita.programada.value,
    )
    if cita_id_excluida is not None:
        consulta = consulta.filter(Cita.id != cita_id_excluida)

    if consulta.first() is not None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Ya existe una cita programada para esa fecha y hora",
        )


def _mostrar_cita(cita: Cita) -> MostrarCita:
    return MostrarCita(
        id=cita.id,
        paciente=PacienteCita(id=cita.paciente.id, nombre=cita.paciente.nombre),
        fecha_hora=cita.fecha_hora,
        tipo_consulta=cita.tipo_consulta,
        observacion=cita.observacion,
        estado=cita.estado,
        fecha_creacion=cita.fecha_creacion,
    )


@router.post("/", response_model=MostrarCita, status_code=status.HTTP_201_CREATED)
def registrar_cita(
    datos: RegistrarCita,
    db: Session = Depends(get_db),
    usuario_actual: Usuario = Depends(obtener_usuario_actual),
):
    paciente = _obtener_paciente_del_usuario(datos.paciente_id, usuario_actual.id, db)
    tipo_consulta = datos.tipo_consulta.strip()
    if not tipo_consulta:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="El tipo de consulta es obligatorio",
        )

    _validar_horario_disponible(datos.fecha_hora, usuario_actual.id, db)
    cita = Cita(
        paciente_id=paciente.id,
        usuario_id=usuario_actual.id,
        fecha_hora=datos.fecha_hora,
        tipo_consulta=tipo_consulta,
        observacion=datos.observacion,
    )
    try:
        db.add(cita)
        db.commit()
        db.refresh(cita)
        return _mostrar_cita(cita)
    except Exception:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error al registrar cita",
        )


@router.get("/agenda", response_model=AgendaCitas)
def mostrar_agenda(
    db: Session = Depends(get_db),
    usuario_actual: Usuario = Depends(obtener_usuario_actual),
):
    citas = (
        db.query(Cita)
        .join(Paciente)
        .filter(
            Cita.usuario_id == usuario_actual.id,
            Paciente.usuario_id == usuario_actual.id,
            Paciente.esta_activo.is_(True),
        )
        .all()
    )
    hoy = date.today()
    citas_hoy = []
    proximas = []
    anteriores = []

    for cita in citas:
        respuesta = _mostrar_cita(cita)
        if cita.fecha_hora.date() == hoy:
            citas_hoy.append(respuesta)
        elif cita.fecha_hora.date() > hoy:
            proximas.append(respuesta)
        else:
            anteriores.append(respuesta)

    citas_hoy.sort(key=lambda cita: cita.fecha_hora)
    proximas.sort(key=lambda cita: cita.fecha_hora)
    anteriores.sort(key=lambda cita: cita.fecha_hora, reverse=True)
    return AgendaCitas(hoy=citas_hoy, proximas=proximas, anteriores=anteriores)


@router.get("/{cita_id}", response_model=MostrarCita)
def mostrar_cita(
    cita_id: int,
    db: Session = Depends(get_db),
    usuario_actual: Usuario = Depends(obtener_usuario_actual),
):
    cita = _obtener_cita_del_usuario(cita_id, usuario_actual.id, db)
    return _mostrar_cita(cita)


@router.put("/{cita_id}", response_model=MostrarCita)
def actualizar_cita(
    cita_id: int,
    datos: ActualizarCita,
    db: Session = Depends(get_db),
    usuario_actual: Usuario = Depends(obtener_usuario_actual),
):
    cita = _obtener_cita_del_usuario(cita_id, usuario_actual.id, db)
    if cita.estado == EstadoCita.cancelada.value:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No se puede editar una cita cancelada",
        )

    cambios = datos.model_dump(exclude_unset=True)
    if not cambios:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Debes enviar al menos un campo para actualizar",
        )

    paciente_id = cambios.get("paciente_id", cita.paciente_id)
    _obtener_paciente_del_usuario(paciente_id, usuario_actual.id, db)
    fecha_hora = cambios.get("fecha_hora", cita.fecha_hora)
    _validar_horario_disponible(
        fecha_hora,
        usuario_actual.id,
        db,
        cita_id_excluida=cita.id,
    )

    if "tipo_consulta" in cambios:
        tipo_consulta = cambios["tipo_consulta"]
        if tipo_consulta is None or not tipo_consulta.strip():
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail="El tipo de consulta es obligatorio",
            )
        cita.tipo_consulta = tipo_consulta.strip()
    if "paciente_id" in cambios:
        cita.paciente_id = paciente_id
    if "fecha_hora" in cambios:
        cita.fecha_hora = fecha_hora
    if "observacion" in cambios:
        cita.observacion = cambios["observacion"]

    try:
        db.commit()
        db.refresh(cita)
        return _mostrar_cita(cita)
    except Exception:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error al actualizar cita",
        )


@router.patch("/{cita_id}/cancelar", response_model=MostrarCita)
def cancelar_cita(
    cita_id: int,
    db: Session = Depends(get_db),
    usuario_actual: Usuario = Depends(obtener_usuario_actual),
):
    cita = _obtener_cita_del_usuario(cita_id, usuario_actual.id, db)
    if cita.estado == EstadoCita.cancelada.value:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="La cita ya esta cancelada",
        )

    try:
        cita.estado = EstadoCita.cancelada.value
        db.commit()
        db.refresh(cita)
        return _mostrar_cita(cita)
    except Exception:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error al cancelar cita",
        )

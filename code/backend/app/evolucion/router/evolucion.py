from datetime import date, timedelta

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import Date, cast
from sqlalchemy.orm import Session

from app.core.dependencies import obtener_usuario_actual
from app.evaluaciones.model.evaluacion import Evaluacion
from app.evaluaciones.schema.evaluacion import imc
from app.evolucion.schema.evolucion import (
    MetricaEvolucion,
    MostrarEvolucion,
    PacienteEvolucion,
    PeriodoEvolucion,
    PuntoEvolucion,
    ResumenEvolucion,
)
from app.pacientes.model.paciente import Paciente
from app.usuarios.model.usuario import Usuario
from database import get_db


router = APIRouter(
    prefix="/evolucion",
    tags=["Evolucion"],
    dependencies=[Depends(obtener_usuario_actual)],
)


UNIDADES = {
    MetricaEvolucion.peso: "kg",
    MetricaEvolucion.imc: "kg/m²",
    MetricaEvolucion.masa_muscular: "%",
}


def _valor_de_metrica(evaluacion: Evaluacion, metrica: MetricaEvolucion) -> float:
    if metrica == MetricaEvolucion.peso:
        return float(evaluacion.peso)
    if metrica == MetricaEvolucion.masa_muscular:
        return float(evaluacion.masa_muscular)
    return imc(evaluacion.peso, evaluacion.altura)


def _filtrar_por_periodo(
    consulta,
    periodo: PeriodoEvolucion,
    desde: date | None,
    hasta: date | None,
):
    if periodo == PeriodoEvolucion.personalizado:
        if desde is None or hasta is None:
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail="El periodo personalizado requiere desde y hasta",
            )
        if desde > hasta:
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail="La fecha desde no puede ser posterior a hasta",
            )
        return consulta.filter(cast(Evaluacion.fecha_registro, Date) >= desde).filter(
            cast(Evaluacion.fecha_registro, Date) <= hasta
        )

    if periodo == PeriodoEvolucion.ultimo_mes:
        limite = date.today() - timedelta(days=30)
        return consulta.filter(cast(Evaluacion.fecha_registro, Date) >= limite)

    if periodo == PeriodoEvolucion.ultimos_3_meses:
        limite = date.today() - timedelta(days=90)
        return consulta.filter(cast(Evaluacion.fecha_registro, Date) >= limite)

    return consulta


@router.get("/paciente/{paciente_id}", response_model=MostrarEvolucion)
def mostrar_evolucion_paciente(
    paciente_id: int,
    metrica: MetricaEvolucion = Query(default=MetricaEvolucion.peso),
    periodo: PeriodoEvolucion = Query(default=PeriodoEvolucion.ultimas_3),
    desde: date | None = Query(default=None),
    hasta: date | None = Query(default=None),
    db: Session = Depends(get_db),
    usuario_actual: Usuario = Depends(obtener_usuario_actual),
):
    paciente = (
        db.query(Paciente)
        .filter(
            Paciente.id == paciente_id,
            Paciente.esta_activo.is_(True),
            Paciente.usuario_id == usuario_actual.id,
        )
        .first()
    )
    if paciente is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Paciente no encontrado",
        )

    consulta = db.query(Evaluacion).filter(
        Evaluacion.paciente_id == paciente_id,
        Evaluacion.esta_activo.is_(True),
    )

    if periodo == PeriodoEvolucion.ultimas_3:
        evaluaciones = (
            consulta.order_by(
                Evaluacion.fecha_registro.desc(), Evaluacion.nro_evaluacion.desc()
            )
            .limit(3)
            .all()
        )
        evaluaciones.sort(
            key=lambda evaluacion: (
                evaluacion.fecha_registro,
                evaluacion.nro_evaluacion,
            )
        )
    else:
        evaluaciones = (
            _filtrar_por_periodo(consulta, periodo, desde, hasta)
            .order_by(Evaluacion.fecha_registro.asc(), Evaluacion.nro_evaluacion.asc())
            .all()
        )

    puntos = [
        PuntoEvolucion(
            nro_evaluacion=evaluacion.nro_evaluacion,
            fecha=evaluacion.fecha_registro,
            valor=_valor_de_metrica(evaluacion, metrica),
        )
        for evaluacion in evaluaciones
    ]

    valor_inicial = puntos[0].valor if puntos else None
    valor_actual = puntos[-1].valor if puntos else None
    cambio = (
        round(valor_actual - valor_inicial, 2)
        if valor_inicial is not None and valor_actual is not None
        else None
    )

    return MostrarEvolucion(
        paciente=PacienteEvolucion(id=paciente.id, nombre=paciente.nombre),
        metrica=metrica,
        unidad=UNIDADES[metrica],
        periodo=periodo,
        resumen=ResumenEvolucion(
            valor_inicial=valor_inicial,
            valor_actual=valor_actual,
            cambio=cambio,
            cantidad_evaluaciones=len(puntos),
        ),
        puntos=puntos,
    )

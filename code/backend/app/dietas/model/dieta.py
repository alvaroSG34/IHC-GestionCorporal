from datetime import datetime, timezone

from sqlalchemy import Boolean, CheckConstraint, Column, Date, DateTime, ForeignKey, Integer, String, Text, UniqueConstraint
from sqlalchemy.orm import relationship

from database import Base


class Dieta(Base):
    __tablename__ = "dieta"

    id = Column(Integer, primary_key=True)
    nombre = Column(String(120), nullable=False)
    objetivo = Column(String(200), nullable=False)
    calorias_diarias = Column(Integer, nullable=False)
    fecha_inicio = Column(Date, nullable=False)
    esta_activa = Column(Boolean, nullable=False, default=True)
    fecha_creacion = Column(
        DateTime,
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
    )
    paciente_id = Column(Integer, ForeignKey("paciente.id"), nullable=False)

    __table_args__ = (
        CheckConstraint("calorias_diarias > 0", name="chequeo_calorias_dieta_positivas"),
    )

    paciente = relationship("Paciente", back_populates="dietas")
    comidas = relationship(
        "Comida",
        back_populates="dieta",
        cascade="all, delete-orphan",
    )


class Comida(Base):
    __tablename__ = "comida"

    id = Column(Integer, primary_key=True)
    dia_semana = Column(String(12), nullable=False)
    tipo = Column(String(12), nullable=False)
    dieta_id = Column(Integer, ForeignKey("dieta.id"), nullable=False)

    __table_args__ = (
        UniqueConstraint("dieta_id", "dia_semana", "tipo", name="unico_comida_dieta_dia_tipo"),
        CheckConstraint(
            "dia_semana IN ('lunes', 'martes', 'miercoles', 'jueves', 'viernes', 'sabado', 'domingo')",
            name="chequeo_dia_semana_dieta",
        ),
        CheckConstraint(
            "tipo IN ('desayuno', 'almuerzo', 'cena')",
            name="chequeo_tipo_comida_dieta",
        ),
    )

    dieta = relationship("Dieta", back_populates="comidas")
    alimentos = relationship(
        "Alimento",
        back_populates="comida",
        cascade="all, delete-orphan",
        order_by="Alimento.id",
    )


class Alimento(Base):
    __tablename__ = "alimento"

    id = Column(Integer, primary_key=True)
    nombre = Column(String(120), nullable=False)
    porcion = Column(String(100), nullable=False)
    calorias = Column(Integer, nullable=False)
    observacion = Column(Text, nullable=True)
    comida_id = Column(Integer, ForeignKey("comida.id"), nullable=False)

    __table_args__ = (
        CheckConstraint("calorias >= 0", name="chequeo_calorias_alimento_no_negativas"),
    )

    comida = relationship("Comida", back_populates="alimentos")

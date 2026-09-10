from datetime import datetime, timezone

from sqlalchemy import Boolean, CheckConstraint, Column, DateTime, ForeignKey, Index, Integer, String, Text
from sqlalchemy.orm import relationship

from database import Base


class Cita(Base):
    __tablename__ = "cita"

    id = Column(Integer, primary_key=True)
    fecha_hora = Column(DateTime, nullable=False)
    tipo_consulta = Column(String(120), nullable=False)
    observacion = Column(Text, nullable=True)
    estado = Column(String(20), nullable=False, default="programada")
    fecha_creacion = Column(
        DateTime,
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
    )
    paciente_id = Column(Integer, ForeignKey("paciente.id"), nullable=False)
    usuario_id = Column(Integer, ForeignKey("usuario.id"), nullable=False)

    __table_args__ = (
        CheckConstraint(
            "estado IN ('programada', 'cancelada')",
            name="chequeo_estado_cita",
        ),
        Index("indice_cita_usuario_fecha", "usuario_id", "fecha_hora"),
    )

    paciente = relationship("Paciente", back_populates="citas")
    usuario = relationship("Usuario", back_populates="citas")

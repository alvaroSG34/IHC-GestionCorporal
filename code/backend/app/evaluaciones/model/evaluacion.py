from datetime import datetime,timezone
from sqlalchemy import Column,Float,Integer,ForeignKey,DateTime,Text,UniqueConstraint,CheckConstraint,Boolean
from sqlalchemy.orm import relationship
from database import Base

class Evaluacion(Base):
    __tablename__ = "evaluacion"
    id = Column(Integer, primary_key = True)
    nro_evaluacion = Column(Integer, nullable=False)
    altura = Column(Integer, nullable=False)
    peso = Column(Float, nullable=False)
    masa_muscular = Column(Float, nullable=False)
    observacion = Column(Text,nullable=True)
    fecha_registro = Column(DateTime,nullable=False, default=lambda: datetime.now(timezone.utc))
    esta_activo = Column(Boolean, nullable=False,default=True)
    paciente_id = Column(Integer, ForeignKey("paciente.id"),nullable=False)

    __table_args__ = (
        UniqueConstraint("paciente_id", "nro_evaluacion", name="unico_paciente_nro_evaluacion"),
        CheckConstraint("masa_muscular >= 0 AND masa_muscular <=100", name="chequeo_masa_muscular_rango"),
        CheckConstraint("peso > 0", name="chequeo_peso_positivo"),
        CheckConstraint("altura > 0", name="chequeo_altura_positiva"),
    )

    # relacion con paciente
    paciente = relationship("Paciente",back_populates="evaluaciones")    
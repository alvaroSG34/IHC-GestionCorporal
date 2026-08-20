from datetime import datetime,timezone
from sqlalchemy import Column,Float,Integer,ForeignKey,DateTime
from sqlalchemy.orm import relationship
from database import Base

class Evaluacion(Base):
    __tablename__ = "evaluacion"
    id = Column(Integer, primary_key = True)
    peso = Column(Float, nullable=False)
    fecha_registro = Column(DateTime,nullable=False, default=lambda: datetime.now(timezone.utc))
    paciente_id = Column(Integer, ForeignKey("paciente.id"),nullable=False)

    # relacion con paciente
    paciente = relationship("Paciente",back_populates="evaluaciones")    
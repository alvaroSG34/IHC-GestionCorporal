from sqlalchemy import Column,String,Date,Integer
from sqlalchemy.orm import relationship
from database import Base
class Paciente(Base):
    __tablename__ = "paciente"
    id = Column(Integer, primary_key = True)
    nombre = Column(String,nullable=False)
    sexo = Column(String,nullable=False)
    fecha_nacimiento = Column(Date,nullable=False)
    telefono = Column(String,nullable=True)

    # relacion con evaluacion
    evaluaciones = relationship("Evaluacion", back_populates="paciente")
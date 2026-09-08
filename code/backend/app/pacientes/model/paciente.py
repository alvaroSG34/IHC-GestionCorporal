from sqlalchemy import Column, ForeignKey,String,Date,Integer,Boolean
from sqlalchemy.orm import relationship
from database import Base
class Paciente(Base):
    __tablename__ = "paciente"
    id = Column(Integer, primary_key = True)
    nombre = Column(String,nullable=False)
    sexo = Column(String,nullable=False)
    fecha_nacimiento = Column(Date,nullable=False)
    telefono = Column(String,nullable=True)
    esta_activo = Column(Boolean,nullable=False,default=True)

    usuario_id = Column(Integer,ForeignKey("usuario.id"),nullable=False)

    # relacion con evaluacion y usuario
    evaluaciones = relationship("Evaluacion", back_populates="paciente")
    usuario = relationship("Usuario",back_populates="pacientes")
from sqlalchemy import Column,String,Date,Integer,Boolean
from sqlalchemy.orm import relationship
from database import Base

class Usuario(Base):
    __tablename__ = "usuario"
    id = Column(Integer, primary_key = True)
    correo_electronico = Column(String,nullable=False,unique=True)
    contrasena = Column(String,nullable=False)
    fecha_nacimiento = Column(Date,nullable=False)
    telefono = Column(String,nullable=True)
    profesion = Column(String,nullable=False)
    clinica = Column(String,nullable=False)

    #relacion con paciente
    pacientes = relationship("Paciente", back_populates="usuario")

    


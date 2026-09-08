import os
import jwt
from datetime import datetime, timedelta, timezone
from dotenv import load_dotenv

load_dotenv()
SECRET_KEY = os.getenv("SECRET_KEY")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60*24 

def crear_token(datos:dict,delta_expiracion: timedelta | None = None)->str:
    por_codificar = datos.copy()
    expiracion = datetime.now(timezone.utc) + (delta_expiracion or timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
    por_codificar.update({"exp": expiracion})
    return jwt.encode(por_codificar,SECRET_KEY,algorithm=ALGORITHM)

def decodificar_token(token: str)->dict:
    return jwt.decode(token, SECRET_KEY,algorithms=[ALGORITHM])
    
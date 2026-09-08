from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer,HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
import jwt
from database import get_db
from app.usuarios.model.usuario import Usuario
from app.core.auth import SECRET_KEY,ALGORITHM

esquema_bearer = HTTPBearer()

def obtener_usuario_actual(credenciales:HTTPAuthorizationCredentials = Depends(esquema_bearer), db:Session = Depends(get_db))->Usuario:
    token =credenciales.credentials
    try:
        payload = jwt.decode(token,SECRET_KEY,algorithms=[ALGORITHM])
        usuario_id:str | None = payload.get("sub")
        if usuario_id is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail = "No se pudo validar el token",
                headers={"WWW-Authenticate":"Bearer"},
            )
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,
                            detail = "El token ha expirado") 

    except jwt.InvalidTokenError:
        raise HTTPException(
                        status_code=status.HTTP_401_UNAUTHORIZED,
                        detail = "No se pudo validar el token",
                        headers={"WWW-Authenticate":"Bearer"},
                    )

    usuario = db.query(Usuario).filter(Usuario.id == int(usuario_id)).first()
    if usuario is None:
        raise HTTPException(
                                status_code=status.HTTP_401_UNAUTHORIZED,
                                detail = "No se pudo validar el token",
                                headers={"WWW-Authenticate":"Bearer"},
                            )
    return usuario

    

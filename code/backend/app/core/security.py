import bcrypt

def hash_contrasena(contrasena:str)->str:
    contrasena_bytes = contrasena.encode("utf-8")
    salt = bcrypt.gensalt()
    contrasena_hash = bcrypt.hashpw(contrasena_bytes, salt)
    return contrasena_hash.decode("utf-8")

def verificar_contrasena(contrasena:str, contrasena_hash:str)->bool:
    contrasena_bytes = contrasena.encode("utf-8")
    contrasena_hash_bytes = contrasena_hash.encode("utf-8")
    verificacion_contrasena = bcrypt.checkpw(contrasena_bytes, contrasena_hash_bytes)
    return verificacion_contrasena

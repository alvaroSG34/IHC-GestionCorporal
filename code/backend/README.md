# Inicio del backend del proyecto IHC SIN IA

Este README explica cómo levantar el backend desde cero en un entorno nuevo, paso a paso.


- cd IHC-ProySinIA/code/backend
- python -m venv .venv
- .\.venv\Scripts\Activate.ps1
- pip install -r requirements.txt
- crear .env con DATABASE_URL = .....
- uvicorn main:app --reload --host localhost --port 8000

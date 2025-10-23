import os
from flask import jsonify, request
from functools import wraps

API_KEY = os.environ.get("API_KEY_SECRET")

def require_api_key(view_function):
    """Decorador para verificar que la API Key es enviada y válida."""
    @wraps(view_function)
    def decorated_function(*args, **kwargs):
        # 1. Chequeo de configuración
        if not API_KEY:
            return jsonify({"message": "Error de configuración interna del servidor (API Key faltante)."}, 500)

        # 2. Obtención de la clave
        provided_key = request.headers.get('X-API-Key')
        
        # 3. Chequeo de presencia
        if not provided_key:
            return jsonify({"message": "Acceso denegado: API Key faltante en el header 'X-API-Key'"}), 401
        
        # 4. Chequeo de validez
        if provided_key != API_KEY:
            return jsonify({"message": "Acceso denegado: API Key inválida"}), 403

        return view_function(*args, **kwargs)

    return decorated_function
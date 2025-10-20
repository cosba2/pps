# Archivo: routes/api.py
import os
from flask import Blueprint, jsonify, request
from config.db import db
from models.user import User # Importamos los modelos
# from models.post import Post # Importa los otros modelos según los necesites
# from models.comment import Comment

# --- Obtención de la API Key y Decorador (replicado o importado) ---
# En un proyecto real, el decorador debe ir en un archivo de utilidad (utils/auth.py)
# para evitar replicar el código de require_api_key. Por simplicidad, 
# asumiremos que lo importaremos o lo redefiniremos.
API_KEY = os.environ.get("API_KEY_SECRET")

# Definición del decorador (tomado de app.py)
def require_api_key(view_function):
    # (El código del decorador es el mismo que en app.py)
    # ...
    from functools import wraps
    @wraps(view_function)
    def decorated_function(*args, **kwargs):
        if not API_KEY:
            return jsonify({"message": "Error de configuración interna del servidor (API Key faltante)."}, 500)

        provided_key = request.headers.get('X-API-Key') 
        
        if not provided_key:
            return jsonify({"message": "Acceso denegado: API Key faltante en el header 'X-API-Key'"}), 401
        
        if provided_key != API_KEY:
            return jsonify({"message": "Acceso denegado: API Key inválida"}), 403

        return view_function(*args, **kwargs)
    return decorated_function
# ----------------------------------------------------------------------


# Crear un Blueprint
api_bp = Blueprint('api', __name__, url_prefix='/api/v1')


# Ruta de ejemplo protegida
@api_bp.route('/users', methods=['GET'])
@require_api_key
def get_users():
    """Ruta para obtener la lista de usuarios (protegida)."""
    try:
        users = User.query.all()
        return jsonify([user.to_dict() for user in users]), 200
    except Exception as e:
        return jsonify({"error": "Error al obtener usuarios", "details": str(e)}), 500
    
# Puedes añadir más rutas de Post y Comment aquí
# @api_bp.route('/posts', methods=['GET'])
# ...
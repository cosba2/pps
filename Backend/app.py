# Archivo: app.py
import os
from flask import Flask, jsonify, request
from flask_sqlalchemy import SQLAlchemy
from dotenv import load_dotenv
from datetime import datetime
from functools import wraps

# --- 1. CONFIGURACIÓN INICIAL ---
# Carga las variables de entorno del archivo .env (local)
load_dotenv()

app = Flask(__name__)

# --- 2. CONFIGURACIÓN DE SECRETOS Y DB ---

API_KEY = os.environ.get("API_KEY_SECRET")
if not API_KEY:
    print("FATAL: La variable de entorno 'API_KEY_SECRET' no está configurada.")

# URL de conexión a tu Base de Datos de Render
DATABASE_URL = os.environ.get("DATABASE_URL")
if not DATABASE_URL:
    print("FATAL: La variable de entorno 'DATABASE_URL' no está configurada.")

app.config['SQLALCHEMY_DATABASE_URI'] = DATABASE_URL
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# Inicialización de SQLAlchemy usando la instancia de config/db.py
from config.db import db
db.init_app(app)


# --- 3. DEFINICIÓN DE MODELOS (Simulación de Importación) ---
# En un proyecto real, importarías los modelos:
# from models.user import User
# from models.post import Post
# from models.comment import Comment

# Para que este archivo sea autocontenido y ejecutable, los definimos aquí:

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    # Relaciones ya definidas en post.py y comment.py están implícitas por 'backref'

    def to_dict(self):
        return {'id': self.id, 'username': self.username, 'email': self.email}

class Post(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(100), nullable=False)
    content = db.Column(db.Text, nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    user = db.relationship('User', backref=db.backref('posts', lazy=True))

    def to_dict(self):
        return {'id': self.id, 'title': self.title, 'content': self.content, 'user_id': self.user_id}

class Comment(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    content = db.Column(db.Text, nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    post_id = db.Column(db.Integer, db.ForeignKey('post.id'), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    user = db.relationship('User', backref=db.backref('comments', lazy=True))
    post = db.relationship('Post', backref=db.backref('comments_on_post', lazy=True)) # Nota: 'comments' ya se usó en User

    def to_dict(self):
        return {'id': self.id, 'content': self.content, 'user_id': self.user_id, 'post_id': self.post_id}


# --- 4. DECORADOR DE API KEY ---

def require_api_key(view_function):
    """Decorador para verificar que la API Key es enviada y válida."""
    @wraps(view_function)
    def decorated_function(*args, **kwargs):
        if not API_KEY:
            return jsonify({"message": "Error de configuración interna del servidor (API Key faltante)."}, 500)

        provided_key = request.headers.get('X-API-Key')
        
        if not provided_key:
            return jsonify({"message": "Acceso denegado: API Key faltante en el header 'X-API-Key'"}), 401
        
        if provided_key != API_KEY:
            # Usar una comparación en tiempo constante (secrets.compare_digest) es más seguro, 
            # pero para esta demostración simple, la comparación directa es suficiente.
            return jsonify({"message": "Acceso denegado: API Key inválida"}), 403

        return view_function(*args, **kwargs)

    return decorated_function


# --- 5. RUTAS DE LA API ---

@app.route('/')
def home():
    """Ruta de bienvenida."""
    return "¡Backend de Flask en funcionamiento! Base de datos y seguridad configurada."

@app.route('/test-db-secure', methods=['GET'])
@require_api_key # <--- Ruta protegida para prueba de DB
def test_db_secure():
    """Ruta protegida para probar la conexión a la base de datos (y la API Key)."""
    try:
        # Usamos app_context para asegurarnos de que db.create_all() funcione
        with app.app_context():
            # Esto crea las tablas si no existen.
            db.create_all()

        # Intenta un CRUD simple con el modelo User
        test_username = 'test_user_db'
        test_email = 'test@example.com'
        
        # Eliminar cualquier registro anterior
        User.query.filter_by(username=test_username).delete()
        db.session.commit()

        # Crear
        nuevo_usuario = User(username=test_username, email=test_email)
        db.session.add(nuevo_usuario)
        db.session.commit()

        # Leer
        usuario_test = User.query.filter_by(username=test_username).first()
        
        # Eliminar
        db.session.delete(usuario_test)
        db.session.commit()

        return jsonify({
            "message": "Conexión a la base de datos, creación de tablas y prueba CRUD exitosa.",
            "test_user_info": usuario_test.to_dict()
        }), 200

    except Exception as e:
        return jsonify({
            "error": "Fallo en la conexión o en la operación de base de datos.",
            "details": str(e)
        }), 500

# Ejemplo de otra ruta protegida
@app.route('/api/users', methods=['GET'])
@require_api_key
def get_users():
    """Ruta para obtener la lista de usuarios (protegida)."""
    try:
        users = User.query.all()
        return jsonify([user.to_dict() for user in users]), 200
    except Exception as e:
        return jsonify({"error": "Error al obtener usuarios", "details": str(e)}), 500


# --- 6. EJECUCIÓN DE LA APLICACIÓN ---
if __name__ == '__main__':
    with app.app_context():
        db.create_all() 
    
    app.run(debug=True, port=os.environ.get('PORT', 5000))
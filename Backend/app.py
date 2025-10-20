import os
from flask import Flask, jsonify
from dotenv import load_dotenv
from config.db import db
from models.user import User
from models.post import Post
from models.comment import Comment

# Importar los Blueprints de las rutas
from routes.users_routes import user_routes
from routes.post_routes import post_routes
from routes.comment_routes import comment_routes


# --- 1. CONFIGURACIÓN INICIAL ---
load_dotenv()

app = Flask(__name__)

# --- 2. CONFIGURACIÓN DE SECRETOS Y DB ---

DATABASE_URL = os.environ.get("DATABASE_URL")
if not DATABASE_URL:
    raise RuntimeError("FATAL: DATABASE_URL no está configurada.")

app.config['SQLALCHEMY_DATABASE_URI'] = DATABASE_URL
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# Inicializar SQLAlchemy
db.init_app(app)

API_KEY = os.environ.get("API_KEY_SECRET")
if not API_KEY:
    print("WARNING: API_KEY_SECRET no está configurada. Las rutas protegidas fallarán.")


# --- 3. REGISTRO DE BLUEPRINTS Y RUTAS BÁSICAS ---

app.register_blueprint(user_routes, url_prefix='/api')
app.register_blueprint(post_routes, url_prefix='/api')
app.register_blueprint(comment_routes, url_prefix='/api')

@app.route('/')
def home():
    """Ruta de bienvenida."""
    return "¡Backend de Flask en funcionamiento!."


# --- 4. EJECUCIÓN DE LA APLICACIÓN ---
if __name__ == '__main__':
    with app.app_context():
        db.create_all() 
    
    app.run(debug=True, port=os.environ.get('PORT', 5000))
import os
from flask import Flask, jsonify
from flask_sqlalchemy import SQLAlchemy
from dotenv import load_dotenv

# Carga las variables de entorno del archivo .env (solo para desarrollo local)
load_dotenv()

# --- Configuración de la Aplicación Flask ---
app = Flask(__name__)

# --- Configuración de la Base de Datos ---

# URL de conexión a tu Base de Datos de Render
# **IMPORTANTE:** En producción, usa una variable de entorno.
# Usaremos la URL de ejemplo que proporcionaste.
DATABASE_URL = os.environ.get("DATABASE_URL")

# Asegúrate de que no es None antes de asignarla a la configuración
if not DATABASE_URL:
    raise RuntimeError("DATABASE_URL no está configurada. Verifica tus variables de entorno.")

app.config['SQLALCHEMY_DATABASE_URI'] = DATABASE_URL

app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

# --- Definición del Modelo de Datos (Ejemplo) ---
# Creamos una tabla simple para probar la conexión.
class Tarea(db.Model):
    __tablename__ = 'tareas'
    id = db.Column(db.Integer, primary_key=True)
    titulo = db.Column(db.String(100), nullable=False)
    completada = db.Column(db.Boolean, default=False)

    def to_dict(self):
        return {
            'id': self.id,
            'titulo': self.titulo,
            'completada': self.completada
        }

# --- Rutas de la API ---

@app.route('/')
def home():
    """Ruta de bienvenida para verificar que la app está corriendo."""
    return "¡Backend de Flask en funcionamiento! Conexión a DB configurada."

@app.route('/test-db', methods=['GET'])
def test_db():
    """Ruta para probar la conexión a la base de datos."""
    try:
        # Intenta crear las tablas si no existen (solo si se ejecuta localmente o por primera vez)
        # Esto es más seguro hacerlo con migraciones (Alembic) en producción,
        # pero para el inicio del proyecto es útil.
        with app.app_context():
            db.create_all()

        # Intenta insertar un registro y luego consultarlo
        nueva_tarea = Tarea(titulo='Tarea de Prueba', completada=False)
        db.session.add(nueva_tarea)
        db.session.commit()
        
        # Consulta el registro
        tarea_test = Tarea.query.filter_by(titulo='Tarea de Prueba').first()
        
        # Elimina el registro de prueba
        if tarea_test:
            db.session.delete(tarea_test)
            db.session.commit()

        return jsonify({
            "message": "Conexión a la base de datos y CRUD simple exitoso.",
            "test_data": tarea_test.to_dict() if tarea_test else "No se pudo recuperar la tarea de prueba"
        }), 200

    except Exception as e:
        # Devuelve un error si algo falla
        return jsonify({
            "error": "Fallo en la conexión o en la operación de base de datos.",
            "details": str(e)
        }), 500

# --- Ejecución de la Aplicación ---
if __name__ == '__main__':
    # Esto solo se ejecuta al correr localmente (python app.py)
    # En Render, Gunicorn o similar se encargará de ejecutar la app.
    # Usamos el puerto 5000 por defecto para desarrollo local.
    app.run(debug=True, port=os.environ.get('PORT', 5000))
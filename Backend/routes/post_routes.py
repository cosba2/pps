from flask import Blueprint, request, jsonify
from config.db import db
from models.post import Post
from models.user import User
from routes.api_key_auth import require_api_key

post_routes = Blueprint('post_routes', __name__,)

@post_routes.route('/posts', methods=['POST'])
@require_api_key
def create_post():
    try:
        data = request.json
        user_id = data.get('user_id')
        
        user = User.query.get(user_id)
        if not user:
            return jsonify({"error": "Usuario no encontrado"}), 404

        new_post = Post(title=data['title'], content=data['content'], user_id=user_id)
        db.session.add(new_post)
        db.session.commit()
        
        return jsonify({"message": "Post creado", "post_id": new_post.id}), 201

    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500

@post_routes.route('/posts', methods=['GET'])
@require_api_key
def get_posts():
    posts = Post.query.order_by(Post.created_at.desc()).all()
    return jsonify([
        {
            'id': p.id,
            'title': p.title,
            'content': p.content,
            'author': p.user.username
        } for p in posts
    ])

@post_routes.route('/posts/<int:id>', methods=['DELETE'])
@require_api_key
def delete_post(id):
    post = Post.query.get(id)
    if not post:
        return jsonify({'error': 'Publicación no encontrada'}), 404
    db.session.delete(post)
    db.session.commit()
    return jsonify({'message': 'Publicación eliminada'}), 200

@post_routes.route("/posts/<int:id>", methods=["PUT"])
@require_api_key
def update_post(id):
    post = Post.query.get(id)
    if not post:
        return jsonify({"error": "Publicación no encontrada"}), 404

    data = request.get_json()
    post.title = data.get("title", post.title)
    post.content = data.get("content", post.content)

    db.session.commit()
    return jsonify({"message": "Publicación actualizada correctamente", "post": {
        "id": post.id,
        "title": post.title,
        "content": post.content
    }}), 200

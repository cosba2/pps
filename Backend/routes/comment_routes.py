from flask import Blueprint, request, jsonify
from config.db import db
from models.comment import Comment
from models.user import User
from models.post import Post
from routes.api_key_auth import require_api_key

comment_routes = Blueprint('comment_routes', __name__,)

@comment_routes.route('/comments', methods=['POST'])
@require_api_key
def create_comment():
    try:
        data = request.json
        user_id = data.get('user_id')
        post_id = data.get('post_id')

        # Verificar si el usuario y el post existen
        user = User.query.get(user_id)
        post = Post.query.get(post_id)

        if not user:
            return jsonify({"error": "Usuario no encontrado"}), 404
        if not post:
            return jsonify({"error": "Post no encontrado"}), 404

        new_comment = Comment(content=data['content'], user_id=user_id, post_id=post_id)
        db.session.add(new_comment)
        db.session.commit()

        return jsonify({"message": "Comentario creado", "comment_id": new_comment.id}), 201

    except Exception as e:
        db.session.rollback() 
        return jsonify({"error": str(e)}), 500

@comment_routes.route('/comments', methods=['GET'])
@require_api_key
def get_comments():
    comments = Comment.query.order_by(Comment.created_at.desc()).all()
    return jsonify([{'id_comment': c.id, 'content': c.content, 'user_id': c.user_id, 'post_id': c.post_id} for c in comments])


@comment_routes.route('/comments/<int:id>', methods=['DELETE'])
@require_api_key
def delete_comment(id):
    try:
        comment = Comment.query.get(id)
        if not comment:
            return jsonify({'error': 'Comentario no encontrado'}), 404
        
        db.session.delete(comment)
        db.session.commit()
        return jsonify({'message': 'Comentario eliminado'}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': 'Error al eliminar el comentario', 'details': str(e)}), 500
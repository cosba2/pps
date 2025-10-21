import 'edit_comment_screen.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class CommentDetailScreen extends StatelessWidget {
  final String commentId;
  final ApiService apiService = ApiService();

  CommentDetailScreen({super.key, required this.commentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalles del Comentario')),
      body: FutureBuilder(
        future: apiService.getCommentById(commentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
            return Center(child: Text('No se encontró el comentario.'));
          }

          var comment = snapshot.data!;
          String text = comment['content']?.toString() ?? 'Sin texto';
          String postId = comment['post_id']?.toString() ?? 'Desconocido';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Texto: $text', style: TextStyle(fontSize: 18)),
                Text('Post ID: $postId', style: TextStyle(fontSize: 18)),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditCommentScreen(
                          commentId: commentId, 
                          commentData: comment,
                        ),
                      ),
                    );
                  },
                  child: Text('Editar Comentario'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

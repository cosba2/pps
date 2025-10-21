import 'package:blog_app/screens/comments/create_comment_screen.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'comment_detail_screen.dart';

class CommentsScreen extends StatefulWidget {
  const CommentsScreen({super.key});

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final ApiService apiService = ApiService();
  late Future<List<dynamic>> _futureComments;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  void _loadComments() {
    setState(() {
      _futureComments = apiService.getAllComments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Comentarios')),
      body: FutureBuilder<List<dynamic>>(
        future: _futureComments,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay comentarios disponibles.'));
          }

          var comments = snapshot.data!;
          return ListView.builder(
            itemCount: comments.length,
            itemBuilder: (context, index) {
              var comment = comments[index];
              String commentId = comment['id']?.toString() ?? 'Desconocido';
              String text = comment['content']?.toString() ?? 'Sin texto';
              String postId = comment['post_id']?.toString() ?? 'Desconocido';

              return ListTile(
                title: Text(text),
                subtitle: Text('Post ID: $postId'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CommentDetailScreen(commentId: commentId),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateCommentScreen(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
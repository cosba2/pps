import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';
import 'create_edit_post_screen.dart';

class PostListScreen extends StatelessWidget {
  const PostListScreen({super.key});

  Future<void> _showDeleteDialog(BuildContext context, int postId) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: const Text('¿Estás seguro de que deseas eliminar este post?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); 
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar'),
              onPressed: () {
                context.read<PostProvider>().deletePost(postId);
                Navigator.of(dialogContext).pop(); 
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = context.watch<PostProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts del Blog'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<PostProvider>().fetchPosts();
            },
          ),
        ],
      ),
      body: _buildBody(context, postProvider),
      
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateEditPostScreen(post: null),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, PostProvider provider) {
    if (provider.isLoading && provider.posts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Error: ${provider.error}'),
        ),
      );
    }

    if (provider.posts.isEmpty) {
      return const Center(child: Text('No hay posts todavía.'));
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchPosts(),
      child: ListView.builder(
        itemCount: provider.posts.length,
        itemBuilder: (context, index) {
          final post = provider.posts[index];
          return ListTile(
            title: Text(post.title),
            subtitle: Text(
              post.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            leading: CircleAvatar(
              child: Text(post.author[0]),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Botón de Editar
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateEditPostScreen(post: post),
                      ),
                    );
                  },
                ),
                // Botón de Eliminar
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _showDeleteDialog(context, post.id);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
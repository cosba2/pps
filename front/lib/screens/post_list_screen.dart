import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';

class PostListScreen extends StatelessWidget {
  const PostListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final postProvider = context.watch<PostProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts del Blog'),
        actions: [
          // Botón para refrescar
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<PostProvider>().fetchPosts();
            },
          ),
        ],
      ),
      body: _buildBody(postProvider),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          // TODO: Navegar a una pantalla de "Crear Post"
          // Ejemplo rápido de cómo llamar al método:
          // context.read<PostProvider>().addPost("Nuevo Post desde Flutter", "Contenido...", 1);
        },
      ),
    );
  }

  Widget _buildBody(PostProvider provider) {
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
            subtitle: Text(post.content),
            leading: CircleAvatar(
              child: Text(post.author[0]), 
            ),
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class CreateCommentScreen extends StatefulWidget {
  const CreateCommentScreen({super.key});

  @override
  _CreateCommentScreenState createState() => _CreateCommentScreenState();
}

class _CreateCommentScreenState extends State<CreateCommentScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();
  final TextEditingController textController = TextEditingController();

  List<dynamic> posts = []; // Lista de posts
  List<dynamic> users = []; // Lista de usuarios
  String? selectedPostId; // ID del post seleccionado
  String? selectedUserId; // ID del usuario seleccionado

  @override
  void initState() {
    super.initState();
    _loadPosts(); // Cargar la lista de posts al iniciar la pantalla
    _loadUsers(); // Cargar la lista de usuarios al iniciar la pantalla
  }

  Future<void> _loadPosts() async {
    try {
      var fetchedPosts = await apiService.getPosts();
      setState(() {
        posts = fetchedPosts;
      });
    } catch (e) {
      print('Error al cargar los posts: $e');
    }
  }

  Future<void> _loadUsers() async {
    try {
      var fetchedUsers = await apiService.getUsers();
      setState(() {
        users = fetchedUsers;
      });
    } catch (e) {
      print('Error al cargar los usuarios: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Crear Comentario')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: textController,
                decoration: InputDecoration(labelText: 'Texto'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un texto';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedPostId,
                decoration: InputDecoration(labelText: 'Seleccionar Post'),
                items: posts.map((post) {
                  return DropdownMenuItem(
                    value: post['id'].toString(),
                    child: Text(post['title'] ?? 'Sin título'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedPostId = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor selecciona un post';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedUserId,
                decoration: InputDecoration(labelText: 'Seleccionar Usuario'),
                items: users.map((user) {
                  return DropdownMenuItem(
                    value: user['id'].toString(),
                    child: Text(user['username'] ?? 'Sin nombre'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedUserId = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor selecciona un usuario';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    var commentData = {
                      'content': textController.text,
                      'post_id': selectedPostId,
                      'user_id': selectedUserId,
                    };

                    bool success = await apiService.createComment(commentData);
                    if (success) {
                      Navigator.pop(context, true); // Regresar y recargar la lista
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al crear el comentario')),
                      );
                    }
                  }
                },
                child: Text('Crear Comentario'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
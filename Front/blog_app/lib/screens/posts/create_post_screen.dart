import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  List<dynamic> users = []; // Lista de usuarios
  String? selectedUserId; // ID del usuario seleccionado

  @override
  void initState() {
    super.initState();
    _loadUsers(); // Cargar la lista de usuarios al iniciar la pantalla
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

  Future<void> _createPost() async {
    if (_formKey.currentState!.validate()) {
      try {
        await apiService.createPost(
          titleController.text,
          contentController.text,
          int.parse(selectedUserId!), // Usar el ID del usuario seleccionado
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear el post: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Crear Post')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Título'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un título';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: contentController,
                decoration: InputDecoration(labelText: 'Contenido'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa contenido';
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
                onPressed: _createPost,
                child: Text('Crear Post'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
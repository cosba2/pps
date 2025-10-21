import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class EditUserScreen extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> userData;

  const EditUserScreen({super.key, required this.userId, required this.userData});

  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();
  late TextEditingController usernameController;
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();

    print('Datos del usuario: ${widget.userData}');

    usernameController = TextEditingController(
      text: widget.userData['username']?.toString() ?? '',
    );
    emailController = TextEditingController(
      text: widget.userData['email']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> _updateUser() async {
    if (_formKey.currentState!.validate()) {
      var userData = {
        'username': usernameController.text,
        'email': emailController.text,
      };
      try {
        await apiService.updateUser(widget.userId, userData);
        Navigator.pop(context, true); // Regresa y recarga la lista
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('⚠️ Error al actualizar el usuario: $e')),
        );
      }
    }
  }

  Future<void> _deleteUser() async {
    bool confirmDelete = await _showDeleteConfirmation();
    if (confirmDelete) {
      try {
        await apiService.deleteUser(widget.userId);
        Navigator.pop(context, true); // Regresa y recarga la lista
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar el usuario: $e')),
        );
      }
    }
  }

  Future<bool> _showDeleteConfirmation() async {
    return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Eliminar Usuario'),
          content: Text('¿Estás seguro de que quieres eliminar este usuario? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ) ??
      false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar Usuario')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: usernameController,
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un nombre';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateUser,
                child: Text('Actualizar Usuario'),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: _deleteUser,
                child: Text(
                  'Eliminar Usuario',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

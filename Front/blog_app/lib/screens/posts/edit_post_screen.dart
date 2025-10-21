import 'package:flutter/material.dart';
import '../../services/api_service.dart';
class EditPostScreen extends StatefulWidget {
  final Map<String, dynamic> postData;

  const EditPostScreen({super.key, required this.postData});

  @override
  _EditPostScreenState createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();
  late TextEditingController titleController;
  late TextEditingController contentController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.postData['title']);
    contentController = TextEditingController(text: widget.postData['content']);
  }

  Future<void> _updatePost() async {
    if (_formKey.currentState!.validate()) {
      try {
        await apiService.updatePost(
          widget.postData['id'],
          titleController.text,
          contentController.text,
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar el post: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar Post')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Título'),
                validator: (value) => value!.isEmpty ? 'Ingresa un título' : null,
              ),
              TextFormField(
                controller: contentController,
                decoration: InputDecoration(labelText: 'Contenido'),
                validator: (value) => value!.isEmpty ? 'Ingresa contenido' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updatePost,
                child: Text('Actualizar Post'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

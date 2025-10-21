import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class EditCommentScreen extends StatefulWidget {
  final String commentId;
  final Map<String, dynamic> commentData;

  const EditCommentScreen({super.key, required this.commentId, required this.commentData});

  @override
  _EditCommentScreenState createState() => _EditCommentScreenState();
}

class _EditCommentScreenState extends State<EditCommentScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();
  late TextEditingController textController;
  late TextEditingController postIdController;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController(text: widget.commentData['content']?.toString() ?? '');
    postIdController = TextEditingController(text: widget.commentData['post_id']?.toString() ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar Comentario')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: textController,
                decoration: InputDecoration(labelText: 'Texto'),
                validator: (value) => (value == null || value.isEmpty) ? 'Por favor ingresa un texto' : null,
              ),
              TextFormField(
                controller: postIdController,
                decoration: InputDecoration(labelText: 'Post ID'),
                validator: (value) => (value == null || value.isEmpty) ? 'Por favor ingresa un Post ID' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    var commentData = {
                      'content': textController.text.trim(),
                      'post_id': postIdController.text.trim(),
                    };
                    await apiService.updateComment(widget.commentId, commentData);
                    Navigator.pop(context);
                  }
                },
                child: Text('Actualizar Comentario'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

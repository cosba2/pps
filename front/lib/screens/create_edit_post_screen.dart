import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../providers/post_provider.dart';
import '../providers/user_provider.dart';

class CreateEditPostScreen extends StatefulWidget {
  final Post? post;

  const CreateEditPostScreen({super.key, this.post});

  @override
  State<CreateEditPostScreen> createState() => _CreateEditPostScreenState();
}

class _CreateEditPostScreenState extends State<CreateEditPostScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  int? _selectedUserId;
  bool _isLoading = false;

@override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post?.title ?? '');
    _contentController =
        TextEditingController(text: widget.post?.content ?? '');

    if (widget.post == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final userProvider = context.read<UserProvider>();
        if (userProvider.users.isNotEmpty) {
          setState(() {
            _selectedUserId = userProvider.users.first.id;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (widget.post == null && _selectedUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona un autor')),
      );
      return;
    }

    setState(() { _isLoading = true; });

    final title = _titleController.text;
    final content = _contentController.text;

    try {
      final provider = context.read<PostProvider>();

      if (widget.post == null) {
        await provider.addPost(title, content, _selectedUserId!);
      } else {
        await provider.updatePost(widget.post!.id, title, content);
      }

      if (mounted) Navigator.of(context).pop();

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  Widget _buildUserDropdown() {
    final userProvider = context.watch<UserProvider>();

    if (userProvider.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (userProvider.error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Text("Error al cargar usuarios: ${userProvider.error}", style: const TextStyle(color: Colors.red)),
      );
    }
    
    if (userProvider.users.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Text("No se encontraron usuarios."),
      );
    }

    return DropdownButtonFormField<int>(
      value: _selectedUserId, 
      hint: const Text('Selecciona un autor'),
      decoration: const InputDecoration(labelText: 'Autor'),
      items: userProvider.users.map((User user) {
        return DropdownMenuItem<int>(
          value: user.id,
          child: Text(user.username),
        );
      }).toList(),
      onChanged: (int? newValue) {
        setState(() {
          _selectedUserId = newValue;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Por favor, selecciona un autor';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post == null ? 'Crear Post' : 'Editar Post'),
        actions: [
          if (_isLoading)
          CircularProgressIndicator()
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveForm,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (widget.post == null) ...[
                _buildUserDropdown(), 
                const SizedBox(height: 16),
              ] else ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    "Autor: ${widget.post!.author}",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
                  ),
                ),
              ],

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) { /* ... */ return null; },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: 'Contenido'),
                maxLines: 8,
                validator: (value) { /* ... */ return null; },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
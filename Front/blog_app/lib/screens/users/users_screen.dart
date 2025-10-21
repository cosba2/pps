import 'create_user_screen.dart';
import 'edit_user_screen.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final ApiService apiService = ApiService();
  late Future<List<dynamic>> _futureUsers;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() {
    setState(() {
      _futureUsers = apiService.getUsers().then((dynamic result) {
        return result as List<dynamic>;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Usuarios')),
      body: FutureBuilder<List<dynamic>>(
        future: _futureUsers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay usuarios disponibles.'));
          }

          List<dynamic> users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index];
              return ListTile(
                title: Text(user['username'] ?? 'Nombre no disponible'),
                subtitle: Text(user['email'] ?? 'Email no disponible'),
                onTap: () async {
                  bool? userUpdatedOrDeleted = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditUserScreen(
                        userId: user['id'].toString(),
                        userData: user,
                      ),
                    ),
                  );

                  if (userUpdatedOrDeleted == true) {
                    _loadUsers();
                  }
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navegar a CreateUserScreen y esperar un resultado
          bool? userCreated = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateUserScreen()),
          );

          // Si se creó un usuario, recargar la lista
          if (userCreated == true) {
            _loadUsers();
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
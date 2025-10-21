import 'edit_user_screen.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';


class UserDetailScreen extends StatelessWidget {
  final String userId;
  final ApiService apiService = ApiService();

  UserDetailScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalles del Usuario')),
      body: FutureBuilder(
        future: apiService.getUserById(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            var user = snapshot.data;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nombre: ${user['username'] ?? 'Nombre no disponible'}', style: TextStyle(fontSize: 18)),
                  Text('Email: ${user['email'] ?? 'Email no disponible'}', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditUserScreen(userId: userId, userData: user),
                        ),
                      );
                    },
                    child: Text('Editar Usuario'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
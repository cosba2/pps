import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/post.dart';
import '../models/user.dart';

class ApiService {
  final String _baseUrl = dotenv.env['API_BASE_URL']!;
  final String _apiKey = dotenv.env['API_KEY_SECRET']!;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json; charset=UTF-8',
        'X-API-Key': _apiKey,
      };

  // --- MÉTODOS DE POSTS ---
  //obtener posts
  Future<List<Post>> getPosts() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/posts'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(utf8.decode(response.bodyBytes));
      List<Post> posts = body.map((dynamic item) => Post.fromJson(item)).toList();
      return posts;
    } else {
      throw Exception('Falló al cargar los posts. Código: ${response.statusCode}');
    }
  }
  //crear post
  Future<Post> createPost(String title, String content, int userId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/posts'),
      headers: _headers,
      body: json.encode({
        'title': title,
        'content': content,
        'user_id': userId,
      }),
    );

    if (response.statusCode == 201) { 

      return Post.fromJson(json.decode(utf8.decode(response.bodyBytes))['post']);
    } else {
      throw Exception('Falló al crear el post. ${response.body}');
    }
  }

  //editar post
  Future<void> updatePost(int id, String title, String content) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/posts/$id'),
      headers: _headers,
      body: json.encode({
        'title': title,
        'content': content,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Falló al actualizar el post. ${response.body}');
    }
  }

  //eliminar post
  Future<void> deletePost(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/posts/$id'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Falló al eliminar el post. ${response.body}');
    }
  }

//USUARIOS

// obtener usuarios
  Future<List<User>> getUsers() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/users'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(utf8.decode(response.bodyBytes));
      List<User> users = body.map((dynamic item) => User.fromJson(item)).toList();
      return users;
    } else {
      throw Exception('Falló al cargar los usuarios. Código: ${response.statusCode}');
    }
  }
}


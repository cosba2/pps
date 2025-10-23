// services/api_service.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/post.dart';

class ApiService {
  final String _baseUrl = dotenv.env['API_BASE_URL']!;
  final String _apiKey = dotenv.env['API_KEY_SECRET']!;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json; charset=UTF-8',
        'X-API-Key': _apiKey,
      };

  // --- MÉTODOS DE POSTS ---

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

  Future<void> createPost(String title, String content, int userId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/posts'),
      headers: _headers,
      body: json.encode({
        'title': title,
        'content': content,
        'user_id': userId,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Falló al crear el post. ${response.body}');
    }
  }

  // ... Aquí irían deletePost, updatePost, getUsers, etc.
}
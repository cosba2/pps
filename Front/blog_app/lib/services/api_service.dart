import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Importación clave

class ApiService {
  // Obtiene la URL base y la API Key de las variables de entorno
  // Asume que dotenv ya se cargó en main.dart
  final String _baseUrl =
      dotenv.env['BASE_URL'] ?? "https://pps-bayon.onrender.com";
  final String _apiKey = dotenv.env['API_KEY'] ?? "";

  // Prefijo de la API en el backend
  final String _apiPrefix = '/api';

  // --- FUNCIÓN DE UTILITY PARA HEADERS ---
  Map<String, String> _getHeaders({bool includeJson = true}) {
    Map<String, String> headers = {
      // 🔑 EL HEADER CLAVE DE SEGURIDAD
      'X-API-Key': _apiKey,
    };
    if (includeJson) {
      headers['Content-Type'] = 'application/json; charset=UTF-8';
    }
    return headers;
  }
  // ---------------------------------------------

  Future<dynamic> _handleResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Maneja respuestas 2xx (200 OK, 201 Created)
      if (response.body.isEmpty) {
        // Puede ser una respuesta 200/204 sin contenido (como DELETE/PUT que solo retorna mensaje)
        return null;
      }
      return jsonDecode(response.body);
    } else {
      // Manejo de errores 4xx o 5xx
      String errorDetail = 'Error desconocido';
      try {
        // Intenta obtener un mensaje de error del backend (Flask)
        var errorJson = jsonDecode(response.body);
        errorDetail =
            errorJson['message'] ?? errorJson['error'] ?? response.body;
      } catch (_) {
        errorDetail = response.body;
      }
      throw Exception('${response.statusCode}: $errorDetail');
    }
  }

  // USERS --------------------------------------------------------------------------------

  Future<dynamic> getUsers() async {
    final response = await http.get(
      Uri.parse('$_baseUrl$_apiPrefix/users'),
      headers: _getHeaders(includeJson: false),
    );
    return _handleResponse(response);
  }

  Future<dynamic> getUserById(String id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl$_apiPrefix/users/$id'),
      headers: _getHeaders(includeJson: false),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse('$_baseUrl$_apiPrefix/users'),
      headers: _getHeaders(),
      body: jsonEncode(userData),
    );

    // Como el backend devuelve 201 Created, ajustamos la lógica
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw _handleResponse(response); // Lanza el error capturado
    }
  }

  Future<dynamic> updateUser(String id, Map<String, dynamic> userData) async {
    final response = await http.put(
      Uri.parse('$_baseUrl$_apiPrefix/users/$id'),
      headers: _getHeaders(),
      body: jsonEncode(userData),
    );
    return _handleResponse(response);
  }

  Future<dynamic> deleteUser(String id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl$_apiPrefix/users/$id'),
      headers: _getHeaders(includeJson: false),
    );
    return _handleResponse(response); // Devolverá null si el DELETE fue exitoso
  }

  // POSTS --------------------------------------------------------------------------------

  Future<List<dynamic>> getPosts() async {
    final response = await http.get(
      Uri.parse('$_baseUrl$_apiPrefix/posts'),
      headers: _getHeaders(includeJson: false),
    );
    final result = await _handleResponse(response);

    return (result as List<dynamic>?) ?? [];
  }

  Future<void> createPost(String title, String content, int userId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl$_apiPrefix/posts'),
      headers: _getHeaders(),
      body: jsonEncode({"title": title, "content": content, "user_id": userId}),
    );

    // createPost en el backend devuelve 201
    if (response.statusCode != 201) {
      throw _handleResponse(response);
    }
  }

  Future<void> updatePost(int postId, String title, String content) async {
    final response = await http.put(
      Uri.parse('$_baseUrl$_apiPrefix/posts/$postId'),
      headers: _getHeaders(),
      body: jsonEncode({"title": title, "content": content}),
    );

    if (response.statusCode != 200) {
      throw _handleResponse(response);
    }
  }

  Future<void> deletePost(int postId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl$_apiPrefix/posts/$postId'),
      headers: _getHeaders(includeJson: false),
    );

    if (response.statusCode != 200) {
      throw _handleResponse(response);
    }
  }

  // COMMENTS --------------------------------------------------------------------------------

  Future<List<dynamic>> getAllComments() async {
    final response = await http.get(
      Uri.parse('$_baseUrl$_apiPrefix/comments'),
      headers: _getHeaders(includeJson: false),
    );
    final result = await _handleResponse(response);

    return (result as List<dynamic>?) ?? [];
  }

  Future<Map<String, dynamic>> getCommentById(String commentId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl$_apiPrefix/comments/$commentId'),
      headers: _getHeaders(includeJson: false),
    );
    final result = await _handleResponse(response);

    return (result as Map<String, dynamic>?) ?? {};
  }

  Future<bool> createComment(Map<String, dynamic> commentData) async {
    final response = await http.post(
      Uri.parse('$_baseUrl$_apiPrefix/comments'),
      headers: _getHeaders(),
      body: jsonEncode(commentData),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      _handleResponse(response); // Lanza la excepción
      return false; // Inalcanzable, pero por seguridad
    }
  }

  Future<bool> updateComment(
    String commentId,
    Map<String, dynamic> updatedData,
  ) async {
    final response = await http.put(
      Uri.parse('$_baseUrl$_apiPrefix/comments/$commentId'),
      headers: _getHeaders(),
      body: jsonEncode(updatedData),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      _handleResponse(response); // Lanza la excepción
      return false;
    }
  }

  Future<bool> deleteComment(String commentId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl$_apiPrefix/comments/$commentId'),
      headers: _getHeaders(includeJson: false),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      _handleResponse(response); // Lanza la excepción
      return false;
    }
  }
}

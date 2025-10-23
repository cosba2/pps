import 'package:flutter/foundation.dart';
import '../models/post.dart';
import '../services/api_service.dart';

class PostProvider with ChangeNotifier {
  final ApiService _apiService;

  PostProvider(this._apiService) {
    fetchPosts();
  }

  List<Post> _posts = [];
  bool _isLoading = false;
  String? _error;

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchPosts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _posts = await _apiService.getPosts();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  //añadir post
  Future<void> addPost(String title, String content, int userId) async {
    try {
      Post newPost = await _apiService.createPost(title, content, userId);
      _posts.insert(0, newPost);
      _error = null;
    } catch (e) {
      _error = "Error al crear post: $e";
    }
    notifyListeners();
  }

  //actualizar post
  Future<void> updatePost(int id, String title, String content) async {
    try {
      await _apiService.updatePost(id, title, content);
      
      // actualiza el post en la lista local
      final index = _posts.indexWhere((p) => p.id == id);
      if (index != -1) {
        final originalAuthor = _posts[index].author;
        _posts[index] = Post(id: id, title: title, content: content, author: originalAuthor);
        _error = null;
      }
    } catch (e) {
      _error = "Error al actualizar post: $e";
    }
    notifyListeners();
  }

  //eliminar post
  Future<void> deletePost(int id) async {
    try {
      await _apiService.deletePost(id);
      
      _posts.removeWhere((p) => p.id == id);
      _error = null;
    } catch (e) {
      _error = "Error al eliminar post: $e";
    }
    notifyListeners();
  }
}
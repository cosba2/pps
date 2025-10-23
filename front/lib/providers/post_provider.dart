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

  Future<void> addPost(String title, String content, int userId) async {
    try {
      await _apiService.createPost(title, content, userId);
      await fetchPosts();
    } catch (e) {
      _error = "Error al crear post: $e";
      notifyListeners();
    }
  }
}
// providers/user_provider.dart
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class UserProvider with ChangeNotifier {
  final ApiService _apiService;

  UserProvider(this._apiService) {
    // Carga los usuarios tan pronto como se crea el provider
    fetchUsers();
  }

  List<User> _users = [];
  bool _isLoading = false;
  String? _error;

  // Getters públicos
  List<User> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _users = await _apiService.getUsers();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }
}
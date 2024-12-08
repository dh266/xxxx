import 'dart:convert';
import 'package:shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const String _userKey = 'users';

  // Get all registered users
  static Future<List<User>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getStringList(_userKey) ?? [];
    return usersJson
        .map((userStr) => User.fromJson(jsonDecode(userStr)))
        .toList();
  }

  // Register new user
  static Future<bool> register(String username, String password) async {
    final users = await getUsers();
    
    // Check if username already exists
    if (users.any((user) => user.username == username)) {
      return false;
    }

    final newUser = User(username: username, password: password);
    users.add(newUser);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _userKey,
      users.map((user) => jsonEncode(user.toJson())).toList(),
    );
    return true;
  }

  // Login
  static Future<bool> login(String username, String password) async {
    final users = await getUsers();
    return users.any(
      (user) => user.username == username && user.password == password,
    );
  }
} 
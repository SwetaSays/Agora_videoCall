import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/user_model.dart';

class UserService {
  /// Fetch users from local JSON (works on web & mobile)
  Future<List<UserModel>> fetchUsers() async {
    try {
      // Load JSON from assets
      final jsonString = await rootBundle.loadString('assets/users.json');
      final jsonData = json.decode(jsonString)['data'] as List<dynamic>;

      if (jsonData.isEmpty) return [];

      return jsonData.map((e) => UserModel.fromJson(e)).toList();
    } catch (e) {
      print('Failed to load users: $e');
      return [];
    }
  }
}

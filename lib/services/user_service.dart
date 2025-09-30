import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import '../models/user_model.dart';

class UserService {
  final Dio _dio = Dio();
  final Box box = Hive.box('cacheBox');

  Future<List<UserModel>> fetchUsers({int page = 1}) async {
    final cached = _getCachedUsers();
    try {
      final res = await _dio.get('https://reqres.in/api/users', queryParameters: {'page': page});
      if (res.statusCode == 200) {
        final data = res.data['data'] as List;
        final users = data.map((e) => UserModel.fromJson(e)).toList();
        _cacheUsers(users);
        return users;
      } else {
        if (cached != null) return cached;
        return [];
      }
    } catch (e) {
      if (cached != null) return cached;
      rethrow;
    }
  }

  void _cacheUsers(List<UserModel> users) {
    final list = users.map((u) => u.toJson()).toList();
    box.put('users', list);
    box.put('users_timestamp', DateTime.now().toIso8601String());
  }

  List<UserModel>? _getCachedUsers() {
    final data = box.get('users') as List<dynamic>?;
    if (data == null) return null;
    return data.map((e) => UserModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }
}

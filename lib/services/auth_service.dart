import 'package:dio/dio.dart';

class AuthService {
  final Dio _dio = Dio();

  /// Login with ReqRes API
  /// Returns true if successful
  Future<bool> login(String email, String password) async {
    try {
      final response = await _dio.post(
        'https://reqres.in/api/login',
        data: {
          "email": email,
          "password": password,
        },
        options: Options(
          headers: {"Content-Type": "application/json"},
        ),
      );

      if (response.statusCode == 200 && response.data['token'] != null) {
        print("Login successful! Token: ${response.data['token']}");
        return true;
      } else {
        print("Login failed: ${response.data}");
        return false;
      }
    } on DioError catch (e) {
      print("Login error: ${e.response?.data ?? e.message}");
      return false;
    }
  }
}

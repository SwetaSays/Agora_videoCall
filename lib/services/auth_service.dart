import 'package:dio/dio.dart';

class AuthService {
  final Dio _dio = Dio();

  Future<bool> login(String email, String password) async {
    try {
      final res = await _dio.post('https://reqres.in/api/login', data: {
        'email': email,
        'password': password,
      });
      if (res.statusCode == 200 && res.data['token'] != null) {
        return true;
      }
      return false;
    } on DioError catch (e) {
      return false;
    } catch (e) {
      return false;
    }
  }
}

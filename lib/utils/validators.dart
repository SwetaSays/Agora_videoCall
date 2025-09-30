
class Validators {
  static String? validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(v.trim())) return 'Enter a valid email';
    return null;
  }

  static String? validatePassword(String? v) {
    if (v == null || v.trim().isEmpty) return 'Password is required';
    if (v.trim().length < 4) return 'Password too short';
    return null;
  }
}

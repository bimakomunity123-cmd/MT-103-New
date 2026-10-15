import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _kUsername = 'swiftnet_username';
  static const String _kLoggedIn = 'swiftnet_loggedin';
  static const String _kAuthCode = 'swiftnet_authcode';
  static const String _kToken = 'swiftnet_token';

  Future<void> saveUsername(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUsername, value);
  }

  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kUsername);
  }

  Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kLoggedIn, value);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kLoggedIn) ?? false;
  }

  Future<void> saveAuthCode(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAuthCode, value);
  }

  Future<String?> getAuthCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kAuthCode);
  }

  Future<void> saveToken(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kToken, value);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kToken);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

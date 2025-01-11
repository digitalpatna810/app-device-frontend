 import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static const String IS_FIRST_TIME_KEY = 'isFirstTime';
  static const String USER_EMAIL_KEY = 'userEmail';
  static const String USER_NAME_KEY = 'userName';
  static const String PROFILE_PIC_URL_KEY = 'profilePicUrl';

  static Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(IS_FIRST_TIME_KEY) ?? true;
  }

  static Future<void> setFirstTime(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(IS_FIRST_TIME_KEY, value);
  }

  static Future<void> saveUserData(String email, String name, String? profilePicUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(USER_EMAIL_KEY, email);
    await prefs.setString(USER_NAME_KEY, name);
    if (profilePicUrl != null) {
      await prefs.setString(PROFILE_PIC_URL_KEY, profilePicUrl);
    }
  }

  static Future<Map<String, String?>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'email': prefs.getString(USER_EMAIL_KEY),
      'name': prefs.getString(USER_NAME_KEY),
      'profilePicUrl': prefs.getString(PROFILE_PIC_URL_KEY),
    };
  }
}
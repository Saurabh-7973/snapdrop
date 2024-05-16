import 'package:shared_preferences/shared_preferences.dart';

class FirstTimeLogin {
  static Future<bool?> checkFirstTimeLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? firstTimeAppOpen = prefs.getBool('firstTimeAppOpen');
    return firstTimeAppOpen;
  }

  static Future<bool?> setFirstTimeLoginFalse() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? firstTimeAppOpen = await prefs.setBool('firstTimeAppOpen', false);
    return firstTimeAppOpen;
  }

  static Future<bool?> setFirstTimeLoginTrue() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? firstTimeAppOpen = await prefs.setBool('firstTimeAppOpen', true);
    return firstTimeAppOpen;
  }
}

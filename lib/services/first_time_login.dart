import 'package:shared_preferences/shared_preferences.dart';

class FirstTimeLogin {
  static Future<bool?> checkFirstTimeLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? firstTimeAppOpen = await prefs.getBool('firstTimeAppOpen');
    return firstTimeAppOpen;
  }
}

import 'package:package_info_plus/package_info_plus.dart';

class CheckAppVersion {
  static String? minimumAppVersion;
  static bool isUpdateRequired = false;

  static void checkAppVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String appVersion = packageInfo.version;

    if (_compareVersions(minimumAppVersion!, appVersion) > 0) {
      // Display a message suggesting update
      // print(
      //     'Your app version is outdated. Please update to version $minimumAppVersion or higher.');
      isUpdateRequired = true;
    }
  }

  static int _compareVersions(String v1, String v2) {
    final List<int> version1 = v1.split('.').map(int.parse).toList();
    final List<int> version2 = v2.split('.').map(int.parse).toList();

    for (int i = 0; i < version1.length && i < version2.length; ++i) {
      final int difference = version1[i] - version2[i];
      if (difference != 0) {
        return difference;
      }
    }
    return version1.length - version2.length;
  }
}

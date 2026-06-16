import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:device_info_plus/device_info_plus.dart';

class PermissionProviderServices {
  final deviceInfoPlugin = DeviceInfoPlugin();

  Future<bool> requestMediaAccessPermission() async {
    final deviceInfo = await deviceInfoPlugin.deviceInfo;
    final version = deviceInfo.data['version']['release'];
    // Release strings like "8.1.0" would crash int.parse; tryParse on the
    // major component, fall back to 0 (legacy storage-permission path).
    final majorVersion =
        int.tryParse(version.toString().split('.').first) ?? 0;
    PermissionStatus status;

    if (Platform.isAndroid == true && majorVersion > 12) {
      status = await Permission.photos.request();
    } else {
      status = await Permission.storage.request();
    }
    if (status.isGranted) {
      return true;
    } else {
      PhotoManager.openSetting();
      return false;
    }
  }
}

import 'package:photo_manager/photo_manager.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionProviderServices {
  Future<bool> requestMediaAccessPermission() async {
    PermissionStatus status = await Permission.photos.request();
    if (status.isGranted) {
      return true;
    } else {
      PhotoManager.openSetting();
      return false;
    }
  }
}

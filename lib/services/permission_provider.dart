import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../utils/firebase_initalization_class.dart';

class PermissionProviderServices {
  final deviceInfoPlugin = DeviceInfoPlugin();

  /// The one in-flight request, shared by every caller.
  ///
  /// CRASHLYTICS: `PlatformException(PermissionHandler.PermissionManager, A
  /// request for permissions is already running…)`. The plugin throws — it does
  /// not queue — if `request()` is called while another request is open, and
  /// the grid asks for permission from a callback that can fire more than once
  /// (a rebuild, a retry, a returning user). Every caller now awaits the same
  /// future instead of opening a second request.
  static Future<bool>? _inFlight;

  Future<bool> requestMediaAccessPermission() {
    return _inFlight ??= _request().whenComplete(() => _inFlight = null);
  }

  Future<bool> _request() async {
    try {
      // CRASHLYTICS: this whole read used to be
      // `deviceInfo.data['version']['release']`, three unchecked lookups deep
      // into an untyped map. On any device that does not report that shape it
      // throws before the request is even made, during the first seconds of the
      // session. Read it defensively and fall back to the legacy path.
      int majorVersion = 0;
      try {
        final data = await deviceInfoPlugin.deviceInfo;
        final version = data.data['version'];
        final release = (version is Map) ? version['release'] : null;
        majorVersion =
            int.tryParse(release.toString().split('.').first) ?? 0;
      } catch (e, s) {
        FirebaseInitalizationClass.recordNonFatal(e, s,
            reason: 'deviceInfo read failed; assuming legacy storage path');
      }

      final PermissionStatus status =
          (Platform.isAndroid && majorVersion > 12)
              ? await Permission.photos.request()
              : await Permission.storage.request();

      if (status.isGranted) return true;

      // Limited access (iOS, and Android 14 "selected photos") is NOT denial.
      // Sending those users to system settings is wrong and loses the grid.
      if (status.isLimited) return true;

      // Only a permanent denial is worth opening settings for. Doing it on an
      // ordinary "not now" hijacks the app the first time someone declines.
      if (status.isPermanentlyDenied) PhotoManager.openSetting();
      return false;
    } catch (e, s) {
      // A permission request must never be able to take the app down. The grid
      // shows its empty state instead.
      FirebaseInitalizationClass.recordNonFatal(e, s,
          reason: 'media permission request failed');
      return false;
    }
  }
}

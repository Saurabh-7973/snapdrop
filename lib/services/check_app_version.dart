import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_upgrade_version/flutter_upgrade_version.dart';

class CheckAppVersion {
  static String? minimumAppVersion;
  static bool isUpdateRequired = false;

  static void checkAppVersion() async {
    // This method is not used in your current flow, so it's commented out.
  }

  Future<void> checkForAppUpdate(PackageInfo packageInfo) async {
    try {
      if (Platform.isAndroid) {
        InAppUpdateManager manager = InAppUpdateManager();
        AppUpdateInfo? appUpdateInfo = await manager.checkForUpdate();

        if (appUpdateInfo == null) {
          return;
        }

        if (appUpdateInfo.updateAvailability ==
            UpdateAvailability.developerTriggeredUpdateInProgress) {
          // If an in-app update is already running, resume the update.
          await manager.startAnUpdate(type: AppUpdateType.immediate);
        } else if (appUpdateInfo.updateAvailability ==
            UpdateAvailability.updateAvailable) {
          if (appUpdateInfo.immediateAllowed) {
            await manager.startAnUpdate(type: AppUpdateType.immediate);
          } else if (appUpdateInfo.flexibleAllowed) {
            await manager.startAnUpdate(type: AppUpdateType.flexible);
          }
        }
      } else if (Platform.isIOS) {
        await UpgradeVersion.getiOSStoreVersion(
            packageInfo: packageInfo, regionCode: "US");
      }
    } catch (e) {
      debugPrint('Error checking for updates: $e');
    }
  }
}

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
      debugPrint(
          'App Info: ${packageInfo.appName} ${packageInfo.packageName} ${packageInfo.version} ${packageInfo.buildNumber} ${packageInfo.languageCode} ${packageInfo.regionCode}');

      if (Platform.isAndroid) {
        InAppUpdateManager manager = InAppUpdateManager();
        AppUpdateInfo? appUpdateInfo = await manager.checkForUpdate();

        // Log the app update info
        debugPrint('AppUpdateInfo: $appUpdateInfo');

        if (appUpdateInfo == null) {
          debugPrint('No update info received');
          return;
        }

        if (appUpdateInfo.updateAvailability ==
            UpdateAvailability.developerTriggeredUpdateInProgress) {
          // If an in-app update is already running, resume the update.
          debugPrint('Developer triggered update in progress');
          String? message =
              await manager.startAnUpdate(type: AppUpdateType.immediate);
          debugPrint('Update Message: $message');
        } else if (appUpdateInfo.updateAvailability ==
            UpdateAvailability.updateAvailable) {
          // Update available
          debugPrint('Update available');
          if (appUpdateInfo.immediateAllowed) {
            debugPrint('Immediate update allowed');
            String? message =
                await manager.startAnUpdate(type: AppUpdateType.immediate);
            debugPrint('Update Message: $message');
          } else if (appUpdateInfo.flexibleAllowed) {
            debugPrint('Flexible update allowed');
            String? message =
                await manager.startAnUpdate(type: AppUpdateType.flexible);
            debugPrint('Update Message: $message');
          } else {
            debugPrint(
                'Update available. Immediate & Flexible Update Flow not allowed');
          }
        } else {
          debugPrint('No update available');
        }
      } else if (Platform.isIOS) {
        VersionInfo? versionInfo = await UpgradeVersion.getiOSStoreVersion(
            packageInfo: packageInfo, regionCode: "US");
        debugPrint(versionInfo.toJson().toString());
      }
    } catch (e) {
      debugPrint('Error checking for updates: $e');
    }
  }
}

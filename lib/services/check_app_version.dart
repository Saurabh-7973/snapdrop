import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_upgrade_version/flutter_upgrade_version.dart';
import 'package:flutter_upgrade_version/flutter_upgrade_version.dart'
    as PackageInfoData;
import 'package:package_info_plus/package_info_plus.dart';

class CheckAppVersion {
  static String? minimumAppVersion;
  static bool isUpdateRequired = false;

  static void checkAppVersion() async {
    // This method is not used in your current flow, so it's commented out.
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

  Future<void> checkForAppUpdate(
      PackageInfoData.PackageInfo packageInfo) async {
    try {
      print(
          'App Info: ${packageInfo.appName} ${packageInfo.packageName} ${packageInfo.version} ${packageInfo.buildNumber} ${packageInfo.languageCode} ${packageInfo.regionCode}' ??
              '');

      if (Platform.isAndroid) {
        InAppUpdateManager manager = InAppUpdateManager();
        AppUpdateInfo? appUpdateInfo = await manager.checkForUpdate();
        if (appUpdateInfo == null) return;

        if (appUpdateInfo.updateAvailability ==
            UpdateAvailability.developerTriggeredUpdateInProgress) {
          // If an in-app update is already running, resume the update.
          String? message =
              await manager.startAnUpdate(type: AppUpdateType.immediate);
          debugPrint(message ?? '');
        } else if (appUpdateInfo.updateAvailability ==
            UpdateAvailability.updateAvailable) {
          // Update available
          if (appUpdateInfo.immediateAllowed) {
            String? message =
                await manager.startAnUpdate(type: AppUpdateType.immediate);
            debugPrint(message ?? '');
          } else if (appUpdateInfo.flexibleAllowed) {
            String? message =
                await manager.startAnUpdate(type: AppUpdateType.flexible);
            debugPrint(message ?? '');
          } else {
            debugPrint(
                'Update available. Immediate & Flexible Update Flow not allowed');
          }
        }
      } else if (Platform.isIOS) {
        VersionInfo? versionInfo = await UpgradeVersion.getiOSStoreVersion(
            packageInfo: packageInfo, regionCode: "US");
        debugPrint(versionInfo?.toJson().toString());
      }
    } catch (e) {
      debugPrint('Error checking for updates: $e');
    }
  }
}

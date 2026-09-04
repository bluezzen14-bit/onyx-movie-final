import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:in_app_update/in_app_update.dart';

class AutoUpdateService {
  static Future<void> checkUpdate() async {
    final doc = await FirebaseFirestore.instance.collection('app_config').doc('update').get();
    if (!doc.exists) return;
    final latest = doc['version'];
    final info = await PackageInfo.fromPlatform();
    if (latest != info.version) {
      final updateInfo = await InAppUpdate.checkForUpdate();
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        await InAppUpdate.performImmediateUpdate();
      }
    }
  }
}

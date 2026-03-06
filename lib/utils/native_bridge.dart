import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class SmsNativeBridge {
  static const _methods = MethodChannel('com.wiseframework.sms_mirror/app');

  static Future<void> addSender(String sender) {
    return _methods.invokeMethod('addSender', {'sender': sender});
  }

  static Future<void> removeSender(String sender) {
    return _methods.invokeMethod('removeSender', {'sender': sender});
  }
}

Future<bool> getSmsPermissionsStatus() async {
  final smsStatus = await Permission.sms.status;
  final notifStatus = await Permission.notification.status;

  return smsStatus.isGranted && notifStatus.isGranted;
}

Future<bool> requestPermissions() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.sms,
    Permission.notification,
  ].request();

  if (statuses[Permission.sms]!.isGranted &&
      statuses[Permission.notification]!.isGranted) {
    return true;
  } else {
    openAppSettings();
    // Logic for denied permissions
    return false;
  }
}

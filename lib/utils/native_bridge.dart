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

Future<bool> getSmsPermissions() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.sms,
    Permission.notification,
  ].request();

  if (statuses[Permission.sms]!.isGranted &&
      statuses[Permission.notification]!.isGranted) {
    return true;
  } else {
    // Logic for denied permissions
    return false;
  }
}

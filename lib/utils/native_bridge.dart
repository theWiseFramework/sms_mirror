import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class SmsNativeBridge {
  static const _methods = MethodChannel('com.wiseframework.sms_mirror/app');
  static const _historyStream = EventChannel(
    'com.wiseframework.sms_mirror/history',
  );

  static Future<Map<String, dynamic>> addSender({
    required String sender,
    required List<String> webhooks,
  }) async {
    final raw = await _methods.invokeMethod<dynamic>('addSender', {
      'sender': sender,
      'webhooks': webhooks,
    });
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    throw PlatformException(
      code: 'invalid_native_response',
      message: 'addSender did not return sender payload',
    );
  }

  static Future<bool> removeSender(String sender) async {
    final raw = await _methods.invokeMethod<dynamic>('removeSender', {
      'sender': sender,
    });
    if (raw is bool) return raw;
    return false;
  }

  static Future<List<Map<String, dynamic>>> listSenders() async {
    final raw = await _methods.invokeMethod<dynamic>('listSenders');
    if (raw is! List) return [];

    return raw
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  static Stream<List<Map<String, dynamic>>> historyStream() {
    return _historyStream.receiveBroadcastStream().map((event) {
      if (event is! List) return <Map<String, dynamic>>[];
      return event
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    });
  }
}

Future<bool> getPermissionsStatus() async {
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

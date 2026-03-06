import 'package:sms_mirror/common.dart';

final smsHistoryStreamProvider =
    StreamProvider.autoDispose<List<SmsHistoryModel>>((ref) {
      return SmsNativeBridge.historyStream().map(
        (rows) => rows.map(SmsHistoryModel.fromMap).toList(),
      );
    });

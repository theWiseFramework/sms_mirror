import 'dart:async';

import 'package:sms_mirror/common.dart';

final sendersController =
    AsyncNotifierProvider<SendersController, List<SenderModel>>(
      SendersController.new,
    );

class SendersController extends AsyncNotifier<List<SenderModel>> {
  @override
  FutureOr<List<SenderModel>> build() {
    return [];
  }
}

import 'dart:async';

import 'package:sms_mirror/common.dart';

final sendersController =
    AsyncNotifierProvider<SendersController, List<SenderModel>>(
      SendersController.new,
    );

class SendersController extends AsyncNotifier<List<SenderModel>> {
  @override
  FutureOr<List<SenderModel>> build() async {
    return _loadSenders();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_loadSenders);
  }

  Future<void> upsertSender(SenderModel sender) async {
    final payload = await SmsNativeBridge.addSender(
      sender: sender.name,
      webhooks: sender.webhooks,
    );
    final saved = SenderModel.fromMap(payload);
    final current = [...(state.asData?.value ?? <SenderModel>[])];
    current.removeWhere((item) => item.name == saved.name);
    current.add(saved);
    current.sort((a, b) => a.name.compareTo(b.name));
    state = AsyncValue.data(current);
  }

  Future<void> removeSender(String sender) async {
    await SmsNativeBridge.removeSender(sender);
    final current = [...(state.asData?.value ?? <SenderModel>[])];
    current.removeWhere((item) => item.name == sender.trim().toUpperCase());
    state = AsyncValue.data(current);
  }

  Future<List<SenderModel>> _loadSenders() async {
    final raw = await SmsNativeBridge.listSenders();
    final list = raw.map(SenderModel.fromMap).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return list;
  }
}

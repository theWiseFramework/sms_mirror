class SenderModel {
  final String name;
  final List<String> webhooks;

  const SenderModel({required this.name, required this.webhooks});

  factory SenderModel.fromMap(Map<String, dynamic> map) {
    final rawHooks = map['webhooks'];
    final hooks = rawHooks is List
        ? rawHooks.map((item) => item.toString()).toList()
        : <String>[];
    return SenderModel(name: (map['name'] ?? '').toString(), webhooks: hooks);
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'webhooks': webhooks};
  }
}

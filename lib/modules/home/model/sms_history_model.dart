class SmsHistoryModel {
  final int id;
  final String sender;
  final String body;
  final int timestampMillis;
  final int partsCount;
  final String assemblyStrategy;
  final bool synced;
  final int syncState;
  final String syncStateLabel;
  final int attempts;
  final String? lastError;
  final int createdAtMillis;
  final int syncedAtMillis;

  const SmsHistoryModel({
    required this.id,
    required this.sender,
    required this.body,
    required this.timestampMillis,
    required this.partsCount,
    required this.assemblyStrategy,
    required this.synced,
    required this.syncState,
    required this.syncStateLabel,
    required this.attempts,
    required this.lastError,
    required this.createdAtMillis,
    required this.syncedAtMillis,
  });

  factory SmsHistoryModel.fromMap(Map<String, dynamic> map) {
    return SmsHistoryModel(
      id: _asInt(map['id']),
      sender: (map['sender'] ?? '').toString(),
      body: (map['body'] ?? '').toString(),
      timestampMillis: _asInt(map['timestampMillis']),
      partsCount: _asInt(map['partsCount']),
      assemblyStrategy: (map['assemblyStrategy'] ?? '').toString(),
      synced: map['synced'] == true,
      syncState: _asInt(map['syncState']),
      syncStateLabel: (map['syncStateLabel'] ?? 'UNKNOWN').toString(),
      attempts: _asInt(map['attempts']),
      lastError: map['lastError']?.toString(),
      createdAtMillis: _asInt(map['createdAtMillis']),
      syncedAtMillis: _asInt(map['syncedAtMillis']),
    );
  }

  static int _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

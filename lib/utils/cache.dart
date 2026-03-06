import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class KeyValueStore {
  Future<bool> setString(String key, String value);
  String? getString(String key);

  Future<bool> setInt(String key, int value);
  int? getInt(String key);

  Future<bool> setBool(String key, bool value);
  bool? getBool(String key);

  Future<bool> setDouble(String key, double value);
  double? getDouble(String key);

  Future<bool> setStringList(String key, List<String> value);
  List<String>? getStringList(String key);

  Set<String> getKeys();
  Future<bool> remove(String key);
  Future<void> clear();
}

final class SharedPrefsStore implements KeyValueStore {
  SharedPrefsStore(this._prefs);
  final SharedPreferences _prefs;

  @override
  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);
  @override
  String? getString(String key) => _prefs.getString(key);

  @override
  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);
  @override
  int? getInt(String key) => _prefs.getInt(key);

  @override
  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);
  @override
  bool? getBool(String key) => _prefs.getBool(key);

  @override
  Future<bool> setDouble(String key, double value) =>
      _prefs.setDouble(key, value);
  @override
  double? getDouble(String key) => _prefs.getDouble(key);

  @override
  Future<bool> setStringList(String key, List<String> value) =>
      _prefs.setStringList(key, value);
  @override
  List<String>? getStringList(String key) => _prefs.getStringList(key);

  @override
  Set<String> getKeys() => _prefs.getKeys();
  @override
  Future<bool> remove(String key) => _prefs.remove(key);
  @override
  Future<void> clear() => _prefs.clear();
}

enum CacheNamespace {
  app, // settings, last page, theme, etc.
  api, // API responses
}

final class CacheKey<T> {
  const CacheKey(this.namespace, this.name);
  final CacheNamespace namespace;
  final String name;
}

final class CacheStorage {
  CacheStorage._(this._store);

  static CacheStorage? _instance;
  static CacheStorage get instance {
    final inst = _instance;
    if (inst == null) {
      throw StateError(
        'CacheStorage not initialized. Call CacheStorage.init() first.',
      );
    }
    return inst;
  }

  final KeyValueStore _store;

  // Versioning / environment
  static const String _docVersion = 'V001';
  static final String _envName = () {
    if (kReleaseMode) return 'Prod';
    if (kProfileMode) return 'Test';
    return 'Dev';
  }();

  static String get _suffix => '$_envName-$_docVersion';

  /// Init once at app startup.
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _instance = CacheStorage._(SharedPrefsStore(prefs));
  }

  /// Build a fully qualified key:
  /// e.g. "Prod-V005:api:wallets:list"
  String _k(CacheKey key) => '$_suffix:${key.namespace.name}:${key.name}';

  Future<bool> set<T>(CacheKey<T> key, T value) async {
    final kk = _k(key);

    if (value is String) return _store.setString(kk, value);
    if (value is int) return _store.setInt(kk, value);
    if (value is bool) return _store.setBool(kk, value);
    if (value is double) return _store.setDouble(kk, value);
    if (value is List<String>) return _store.setStringList(kk, value);

    return _store.setString(kk, jsonEncode(value));
  }

  T? get<T>(CacheKey<T> key) {
    final kk = _k(key);

    // Primitive reads
    if (T == String) return _store.getString(kk) as T?;
    if (T == int) return _store.getInt(kk) as T?;
    if (T == bool) return _store.getBool(kk) as T?;
    if (T == double) return _store.getDouble(kk) as T?;
    if (T == List<String>) return _store.getStringList(kk) as T?;

    final raw = _store.getString(kk);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as T;
    } catch (_) {
      return null;
    }
  }

  CacheKey<String> apiDataKey(String name) =>
      CacheKey<String>(CacheNamespace.api, name);
  CacheKey<int> apiTimeKey(String name) =>
      CacheKey<int>(CacheNamespace.api, '$name:time');

  Future<void> cacheApi(String name, String data) async {
    await set(apiDataKey(name), data);
    await set(apiTimeKey(name), DateTime.now().millisecondsSinceEpoch);
  }

  String? readApi(String name, {Duration? maxAge}) {
    final data = get(apiDataKey(name));
    if (data == null) return null;

    if (maxAge == null) return data;

    final t = get(apiTimeKey(name));
    if (t == null) return null;

    final ageMs = DateTime.now().millisecondsSinceEpoch - t;
    if (ageMs > maxAge.inMilliseconds) return null;

    return data;
  }

  // Is the data I have too old to trust?
  bool isApiStale(String name, Duration maxAge) {
    final t = get(apiTimeKey(name));
    if (t == null) return true;
    final ageMs = DateTime.now().millisecondsSinceEpoch - t;
    return ageMs > maxAge.inMilliseconds;
  }

  Future<void> clearNamespace(CacheNamespace ns) async {
    final prefix = '$_suffix:${ns.name}:';
    final keysToRemove = _store
        .getKeys()
        .where((k) => k.startsWith(prefix))
        .toList();
    for (final k in keysToRemove) {
      await _store.remove(k);
    }
  }

  Future<void> clearAll() => _store.clear();

  // Common keys (typed)
  static const themeModeKey = CacheKey<String>(CacheNamespace.app, 'themeMode');
  static const firstTimeUserKey = CacheKey<bool>(
    CacheNamespace.app,
    'firstTimeUser',
  );
}


/*
  ─────────────────────────────────────────────────────────────
  CacheStorage usage guide

  • Define all cache keys as CacheKey<T> constants.
    Avoid raw strings outside this file.

  • Use namespaces to group data:
      - app   → UI state, settings, routes
      - api   → network responses + timestamps
      - users → cached user data, lists, profiles

  • Prefer typed access:
      set(key, value) / get<T>(key)
    This keeps reads safe and predictable.

  • For API data, use cacheApi() + readApi()
    and supply a maxAge when freshness matters.

  • Use clearNamespace() instead of clearAll()
    unless you intentionally want a full reset.

  • Storage backend is abstracted (KeyValueStore),
    so this can later be swapped for Hive, Isar,
    SecureStorage, or an in-memory store for tests.
  ─────────────────────────────────────────────────────────────
*/
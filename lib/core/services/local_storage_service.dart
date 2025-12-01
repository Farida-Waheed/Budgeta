// lib/core/services/local_storage_service.dart
abstract class LocalStorageService {
  Future<void> saveString(String key, String value);
  Future<String?> readString(String key);
  Future<void> delete(String key);

  // for simple offline cache
  Future<void> saveJson(String key, Map<String, dynamic> json);
  Future<Map<String, dynamic>?> readJson(String key);
}

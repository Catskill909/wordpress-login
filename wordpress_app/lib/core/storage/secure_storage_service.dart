import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wordpress_app/core/errors/exceptions.dart';

class SecureStorageService {
  final FlutterSecureStorage _secureStorage;

  SecureStorageService({required FlutterSecureStorage secureStorage})
      : _secureStorage = secureStorage;

  Future<void> saveString(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
    } catch (e) {
      throw CacheException(message: 'Failed to save data: $e');
    }
  }

  Future<String?> getString(String key) async {
    try {
      return await _secureStorage.read(key: key);
    } catch (e) {
      throw CacheException(message: 'Failed to read data: $e');
    }
  }

  Future<void> saveObject(String key, Map<String, dynamic> value) async {
    try {
      final jsonString = jsonEncode(value);
      await _secureStorage.write(key: key, value: jsonString);
    } catch (e) {
      throw CacheException(message: 'Failed to save data: $e');
    }
  }

  Future<Map<String, dynamic>?> getObject(String key) async {
    try {
      final jsonString = await _secureStorage.read(key: key);
      if (jsonString == null) return null;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw CacheException(message: 'Failed to read data: $e');
    }
  }

  Future<void> delete(String key) async {
    try {
      await _secureStorage.delete(key: key);
    } catch (e) {
      throw CacheException(message: 'Failed to delete data: $e');
    }
  }

  Future<void> deleteAll() async {
    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      throw CacheException(message: 'Failed to delete all data: $e');
    }
  }

  Future<bool> containsKey(String key) async {
    try {
      return await _secureStorage.containsKey(key: key);
    } catch (e) {
      throw CacheException(message: 'Failed to check key: $e');
    }
  }
}

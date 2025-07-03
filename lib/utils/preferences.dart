import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Preferences {
  static final _storage = const FlutterSecureStorage();

  static Future<void> clearData(String key) async {
    await _storage.delete(key: key);
  }

  static Future<void> clearAllData() async {
    await _storage.deleteAll();
  }

  static Future<void> saveData(Map<String, dynamic> data) async {
    for (var entry in data.entries) {
      if (entry.value is Map<String, dynamic>) {
        // Serialize map to JSON string
        await _storage.write(key: entry.key, value: jsonEncode(entry.value));
      } else if (entry.value is String ||
          entry.value is int ||
          entry.value is bool ||
          entry.value is double) {
        await _storage.write(key: entry.key, value: entry.value.toString());
      } else if (entry.value is List<String>) {
        await _storage.write(key: entry.key, value: (entry.value as List<String>).join(','));
      }
    }
  }

  static Future<T?> getData<T>(String key) async {
    final value = await _storage.read(key: key);

    if (T == String) {
      return value as T?;
    } 
    
    if (T == int) {
      return int.tryParse(value ?? '') as T?;
    } 
    
    if (T == bool) {
      return (value?.toLowerCase() == 'true') as T?;
    } 
    
    if (T == double) {
      return double.tryParse(value ?? '') as T?;
    } 
    
    if (T == List<String>) {
      return value?.split(',') as T?;
    } 
    
    if (T == Map<String, dynamic>) {
      // Deserialize JSON string to Map
      return value != null ? jsonDecode(value) as T : null;
    }

    return null;
  }

}

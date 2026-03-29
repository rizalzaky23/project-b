import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

// Web fallback menggunakan in-memory storage (karena flutter_secure_storage tidak support web)
final Map<String, String> _webMemoryStorage = {};

class TokenStorage {
  final FlutterSecureStorage _storage;

  static const String _tokenKey = 'auth_token';
  static const String _userKey  = 'user_data';

  TokenStorage(this._storage);

  // ── macOS: gunakan file storage biasa (hindari keychain signing issue) ──
  static Future<File> _getFile(String key) async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/fleet_$key.dat');
  }

  static Future<String?> _readFile(String key) async {
    try {
      final file = await _getFile(key);
      if (!await file.exists()) return null;
      final raw = await file.readAsString();
      if (raw.isEmpty) return null;
      // Simple obfuscation: base64
      return utf8.decode(base64Decode(raw.trim()));
    } catch (_) {
      return null;
    }
  }

  static Future<void> _writeFile(String key, String value) async {
    try {
      final file = await _getFile(key);
      await file.writeAsString(base64Encode(utf8.encode(value)));
    } catch (_) {}
  }

  static Future<void> _deleteFile(String key) async {
    try {
      final file = await _getFile(key);
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }

  static bool get _useMacOSFile =>
      !kIsWeb && Platform.isMacOS;

  // ── Public API ──────────────────────────────────────────────────
  Future<void> saveToken(String token) async {
    if (kIsWeb) {
      _webMemoryStorage[_tokenKey] = token;
    } else if (_useMacOSFile) {
      await _writeFile(_tokenKey, token);
    } else {
      await _storage.write(key: _tokenKey, value: token);
    }
  }

  Future<String?> getToken() async {
    if (kIsWeb) {
      return _webMemoryStorage[_tokenKey];
    }
    if (_useMacOSFile) {
      return await _readFile(_tokenKey);
    }
    try {
      return await _storage.read(key: _tokenKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteToken() async {
    if (kIsWeb) {
      _webMemoryStorage.remove(_tokenKey);
    } else if (_useMacOSFile) {
      await _deleteFile(_tokenKey);
    } else {
      await _storage.delete(key: _tokenKey);
    }
  }

  Future<void> saveUser(String userJson) async {
    if (kIsWeb) {
      _webMemoryStorage[_userKey] = userJson;
    } else if (_useMacOSFile) {
      await _writeFile(_userKey, userJson);
    } else {
      await _storage.write(key: _userKey, value: userJson);
    }
  }

  Future<String?> getUser() async {
    if (kIsWeb) {
      return _webMemoryStorage[_userKey];
    }
    if (_useMacOSFile) {
      return await _readFile(_userKey);
    }
    try {
      return await _storage.read(key: _userKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearAll() async {
    if (kIsWeb) {
      _webMemoryStorage.clear();
    } else if (_useMacOSFile) {
      await _deleteFile(_tokenKey);
      await _deleteFile(_userKey);
    } else {
      await _storage.deleteAll();
    }
  }
}

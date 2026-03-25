import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Web fallback menggunakan in-memory storage (karena flutter_secure_storage tidak support web)
final Map<String, String> _webMemoryStorage = {};

class TokenStorage {
  final FlutterSecureStorage _storage;

  static const String _tokenKey = 'auth_token';
  static const String _userKey  = 'user_data';

  TokenStorage(this._storage);

  Future<void> saveToken(String token) async {
    if (kIsWeb) {
      _webMemoryStorage[_tokenKey] = token;
    } else {
      await _storage.write(key: _tokenKey, value: token);
    }
  }

  Future<String?> getToken() async {
    if (kIsWeb) {
      return _webMemoryStorage[_tokenKey];
    }
    return await _storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    if (kIsWeb) {
      _webMemoryStorage.remove(_tokenKey);
    } else {
      await _storage.delete(key: _tokenKey);
    }
  }

  Future<void> saveUser(String userJson) async {
    if (kIsWeb) {
      _webMemoryStorage[_userKey] = userJson;
    } else {
      await _storage.write(key: _userKey, value: userJson);
    }
  }

  Future<String?> getUser() async {
    if (kIsWeb) {
      return _webMemoryStorage[_userKey];
    }
    return await _storage.read(key: _userKey);
  }

  Future<void> clearAll() async {
    if (kIsWeb) {
      _webMemoryStorage.clear();
    } else {
      await _storage.deleteAll();
    }
  }
}

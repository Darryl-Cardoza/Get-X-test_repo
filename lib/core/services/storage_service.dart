// lib/core/services/storage_service.dart

import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage with AES encryption.
/// - Generates a master key on first run and stores it in secure storage.
/// - Encrypts/decrypts values transparently.
class StorageService {
  static const _masterKeyStorageKey = 'MASTER_KEY';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// Retrieves or generates the AES key.
  Future<Key> _getMasterKey() async {
    String? base64Key = await _secureStorage.read(key: _masterKeyStorageKey);
    if (base64Key == null) {
      final newKey = Key.fromSecureRandom(32);
      base64Key = base64.encode(newKey.bytes);
      await _secureStorage.write(key: _masterKeyStorageKey, value: base64Key);
      return newKey;
    }
    return Key(base64.decode(base64Key));
  }

  /// Encrypts [value] and writes under [keyName].
  Future<void> writeSecure(String keyName, String value) async {
    final masterKey = await _getMasterKey();
    final encrypter = Encrypter(AES(masterKey, mode: AESMode.cbc));
    final iv = IV.fromSecureRandom(16);
    final encrypted = encrypter.encrypt(value, iv: iv);
    final payload = '${iv.base64}:${encrypted.base64}';
    await _secureStorage.write(key: keyName, value: payload);
  }

  /// Reads and decrypts the value stored under [keyName], or `null` if absent.
  Future<String?> readSecure(String keyName) async {
    final payload = await _secureStorage.read(key: keyName);
    if (payload == null) return null;
    final parts = payload.split(':');
    if (parts.length != 2) return null;
    final iv = IV.fromBase64(parts[0]);
    final encrypted = Encrypted.fromBase64(parts[1]);
    final masterKey = await _getMasterKey();
    final encrypter = Encrypter(AES(masterKey, mode: AESMode.cbc));
    return encrypter.decrypt(encrypted, iv: iv);
  }

  /// Deletes the secure entry under [keyName].
  Future<void> deleteSecure(String keyName) async {
    await _secureStorage.delete(key: keyName);
  }
}

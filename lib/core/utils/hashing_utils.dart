// lib/core/utils/hashing_utils.dart
import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Lightweight hashing helper for PIN, pattern, and security-answer
/// storage. Uses the `crypto` package's SHA-256 (pure Dart, no native
/// bindings — negligible app size impact).
///
/// A static app-level salt is combined with each value before hashing.
/// This is not a substitute for a per-user random salt in a
/// server-backed system, but since this is a local-only, non-synced
/// app lock (no data leaves the device), it raises the bar against
/// trivial rainbow-table lookups without adding storage/migration
/// complexity for a per-record salt column.
class HashingUtils {
  HashingUtils._();

  /// App-level static salt. Not a secret — its purpose is to make stored
  /// hashes non-generic, not to withstand a targeted attacker with
  /// database access on a rooted device (no local hash-based storage
  /// scheme can fully protect against that).
  static const String _salt = 'bubimo_app_lock_v1';

  /// Returns the SHA-256 hex digest of [value] combined with the app salt.
  static String hash(String value) {
    final bytes = utf8.encode('$_salt:$value');
    return sha256.convert(bytes).toString();
  }

  /// Compares [value]'s hash against [storedHash] in constant-ish time
  /// (String equality on fixed-length hex digests; sqflite/Dart don't
  /// give us true constant-time comparison, but the fixed-length hex
  /// output avoids the worst length-based timing leaks).
  static bool verify(String value, String storedHash) {
    return hash(value) == storedHash;
  }
}
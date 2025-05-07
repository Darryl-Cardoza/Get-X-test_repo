// lib/core/utils/validators.dart

import 'dart:convert';

/// Utility class providing common validation methods for user input and data models.
class Validators {
  /// Validates that [input] is in a proper email format (e.g. user@example.com).
  /// Allows alphanumeric characters, dots, hyphens, and underscores before '@',
  /// then a domain with at least one dot and 2–4 letter TLD.
  static bool isEmail(String input) {
    final regex = RegExp(r"^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$");
    return regex.hasMatch(input);
  }

  /// Validates phone numbers with optional country code prefix.
  /// Examples: +1-1234567890, +91 9876543210, 1234567890.
  static bool isPhoneNumber(String input) {
    final regex = RegExp(r'^(?:\+\d{1,3}[- ]?)?\d{10}\$');
    return regex.hasMatch(input);
  }

  /// Validates HTTP/HTTPS URLs.
  /// Supports optional protocol, subdomains, domain, and path/query parameters.
  /// Examples: https://example.com/path, http://sub.domain.com, example.com.
  static bool isURL(String input) {
    final regex = RegExp(r'^(https?:\/\/)?'
        r'([\w-]+\.)+[\w-]+'
        r'(\/\S*)?\$');
    return regex.hasMatch(input);
  }

  /// Validates IPv4 addresses (e.g. 192.168.0.1).
  /// Each segment must be between 0 and 255.
  static bool isIPv4(String input) {
    final regex = RegExp(
        r'^((25[0-5]|2[0-4]\d|[01]?\d?\d)\.){3}(25[0-5]|2[0-4]\d|[01]?\d?\d)\$');
    return regex.hasMatch(input);
  }

  /// Validates IPv6 addresses (hex pairs separated by ':').
  /// Does not support compressed shorthand ('::').
  static bool isIPv6(String input) {
    final regex = RegExp(
      r'^([0-9a-f]{1,4}:){7}[0-9a-f]{1,4}\$',
      caseSensitive: false,
    );
    return regex.hasMatch(input);
  }

  /// Validates MAC addresses (e.g. 01:23:45:67:89:AB or 01-23-45-67-89-AB).
  static bool isMacAddress(String input) {
    final regex = RegExp(r'^([0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}\$');
    return regex.hasMatch(input);
  }

  /// Validates strong passwords requiring:
  /// • At least 8 characters
  /// • At least one uppercase letter
  /// • At least one lowercase letter
  /// • At least one digit
  /// • At least one special character from @$!%*?&#^
  static bool isStrongPassword(String input) {
    final regex = RegExp(r'^(?=.*[A-Z])'
        r'(?=.*[a-z])'
        r'(?=.*\d)'
        r'(?=.*[@\$!%*?&#^])'
        r'.{8,}$');
    return regex.hasMatch(input);
  }

  /// Validates credit card numbers using the Luhn algorithm.
  /// Strips non-digits, doubles every second digit from the right,
  /// subtracts 9 if >9, sums all, and checks mod10 == 0.
  static bool isCreditCard(String input) {
    final digits = input
        .replaceAll(RegExp(r'\D'), '')
        .split('')
        .reversed
        .map(int.parse)
        .toList();
    var sum = 0;
    for (var i = 0; i < digits.length; i++) {
      final d = digits[i];
      sum += (i.isOdd ? _doubleDigit(d) : d);
    }
    return sum % 10 == 0;
  }

  /// Helper for Luhn: doubles a digit and subtracts 9 if result >9.
  static int _doubleDigit(int d) {
    final doubled = d * 2;
    return doubled > 9 ? doubled - 9 : doubled;
  }

  /// Validates integer strings (positive or negative).
  static bool isNumeric(String input) {
    final regex = RegExp(r'^-?\d+\$');
    return regex.hasMatch(input);
  }

  /// Validates decimal numbers with optional fractional part.
  /// Examples: 123, -123.45, 0.99
  static bool isDecimal(String input) {
    final regex = RegExp(r'^-?\d+(\.\d+)?\$');
    return regex.hasMatch(input);
  }

  /// Validates alphabetic strings A–Z or a–z only.
  static bool isAlphabetic(String input) {
    final regex = RegExp(r'^[A-Za-z]+\$');
    return regex.hasMatch(input);
  }

  /// Validates alphanumeric strings (letters and digits only).
  static bool isAlphanumeric(String input) {
    final regex = RegExp(r'^[A-Za-z0-9]+\$');
    return regex.hasMatch(input);
  }

  /// Validates alphabetic strings with spaces allowed.
  static bool isAlphabeticWithSpaces(String input) {
    final regex = RegExp(r'^[A-Za-z ]+\$');
    return regex.hasMatch(input);
  }

  /// Validates ISO 8601 date/time strings by attempting DateTime.parse.
  static bool isISO8601(String input) {
    try {
      DateTime.parse(input);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Checks that [input] length is at least [length].
  static bool minLength(String input, int length) => input.length >= length;

  /// Checks that [input] length does not exceed [length].
  static bool maxLength(String input, int length) => input.length <= length;

  /// Checks that [input] length is between [min] and [max], inclusive.
  static bool isLengthBetween(String input, int min, int max) {
    final len = input.length;
    return len >= min && len <= max;
  }

  /// Validates UUID v4 format (8-4-4-4-12 hex digits).
  static bool isUUID(String input) {
    final regex = RegExp(r'^[0-9a-fA-F]{8}-'
        r'[0-9a-fA-F]{4}-'
        r'[0-9a-fA-F]{4}-'
        r'[0-9a-fA-F]{4}-'
        r'[0-9a-fA-F]{12}\$');
    return regex.hasMatch(input);
  }

  /// Validates hex color codes (#FFF or #FFFFFF).
  static bool isHexColor(String input) {
    final regex = RegExp(r'^#?([A-Fa-f0-9]{3}|[A-Fa-f0-9]{6})\$');
    return regex.hasMatch(input);
  }

  /// Validates Base64 strings.
  static bool isBase64(String input) {
    final regex = RegExp(r'^(?:[A-Za-z0-9+/]{4})*'
        r'(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?\$');
    return regex.hasMatch(input);
  }

  /// Validates JSON strings by attempting to decode.
  static bool isJson(String input) {
    try {
      jsonDecode(input);
      return true;
    } catch (_) {
      return false;
    }
  }
}
